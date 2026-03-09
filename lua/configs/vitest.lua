-- ============================================================================
-- VITEST
-- Minimal vitest runner. Runs tests via the vitest CLI and shows results in a
-- floating window. Requires vitest 3+ for file:line support.
--
-- Feature Requests
-- - Re-run failed tests DONE
-- - Run in current context (e.g. nearest test or describe block) DONE
-- - Show error marker in the gutter for failed tests DONE
-- - Go to failed expectation DONE
-- - Debugging test (use capital letters for debug versions of commands?) DONE
-- ============================================================================

local WRAP = false

local state = {
	buf = nil,
	win = nil,
	job = nil,
	last_cmd = nil,
	last_cwd = nil,
	last_title = nil,
	failed = nil,
	locations = nil,
	last_lines = nil,
	last_highlights = nil,
	debug_rerun = nil,
}

local ns = vim.api.nvim_create_namespace("vitest")
local signs_ns = vim.api.nvim_create_namespace("vitest_signs")

local function find_project_root(path)
	return vim.fs.root(path, {
		"vitest.config.ts",
		"vitest.config.js",
		"vitest.config.mts",
		"vitest.config.mjs",
		"vite.config.ts",
		"vite.config.js",
		"package.json",
	})
end

local function find_vitest_bin(root)
	local bin = root .. "/node_modules/.bin/vitest"
	if vim.uv.fs_stat(bin) then
		return bin
	end
	return "npx"
end

local function buf_valid()
	return state.buf and vim.api.nvim_buf_is_valid(state.buf)
end

local function win_valid()
	return state.win and vim.api.nvim_win_is_valid(state.win)
end

local function goto_location()
	if not state.locations then
		return
	end
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local loc = state.locations[cursor_line]
	if not loc then
		return
	end
	local file = loc.file
	if not vim.uv.fs_stat(file) and state.last_cwd then
		file = state.last_cwd .. "/" .. file
	end
	local target_win = nil
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if win ~= state.win then
			target_win = win
			break
		end
	end
	if not target_win then
		return
	end
	vim.api.nvim_set_current_win(target_win)
	vim.cmd("edit " .. vim.fn.fnameescape(file))
	local buf_lines = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(target_win))
	local target_line = math.min(loc.line, buf_lines)
	vim.api.nvim_win_set_cursor(target_win, { target_line, 0 })
end

local function close_panel()
	if win_valid() then
		vim.api.nvim_win_close(state.win, true)
	end
	state.win = nil
	state.buf = nil
end

local function open_panel(lines, highlights, title)
	if buf_valid() then
		vim.bo[state.buf].modifiable = true
		vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
		vim.bo[state.buf].modifiable = false
	else
		state.buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
		vim.bo[state.buf].modifiable = false
		vim.bo[state.buf].bufhidden = "wipe"
		vim.bo[state.buf].filetype = "vitest"
		vim.keymap.set("n", "q", close_panel, { buffer = state.buf })
		vim.keymap.set("n", "<Esc>", close_panel, { buffer = state.buf })
		vim.keymap.set("n", "<CR>", goto_location, { buffer = state.buf })
	end

	vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
	for _, hl in ipairs(highlights or {}) do
		vim.api.nvim_buf_add_highlight(state.buf, ns, hl[2], hl[1] - 1, hl[3], hl[4])
	end

	local height = math.min(#lines + 1, math.floor(vim.o.lines * 0.3))

	if win_valid() then
		vim.api.nvim_win_set_height(state.win, height)
		vim.wo[state.win].statusline = title or " Vitest "
	else
		vim.cmd("botright " .. height .. "split")
		state.win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(state.win, state.buf)
		vim.wo[state.win].wrap = WRAP
		vim.wo[state.win].number = false
		vim.wo[state.win].relativenumber = false
		vim.wo[state.win].signcolumn = "no"
		vim.wo[state.win].colorcolumn = ""
		vim.wo[state.win].winfixheight = true
		vim.wo[state.win].statusline = title or " Vitest "
	end
end

local function strip_ansi(str)
	return str:gsub("\27%[[%d;]*m", "")
end

local function parse_json(stdout)
	if not stdout then
		return nil
	end
	local json_start = stdout:find("{")
	if not json_start then
		return nil
	end
	local ok, data = pcall(vim.json.decode, stdout:sub(json_start))
	if not ok then
		return nil
	end
	return data
end

local function is_user_file(fpath)
	if not fpath then
		return false
	end
	if fpath:match("^node:") then
		return false
	end
	if fpath:match("node_modules") then
		return false
	end
	return true
end

local function parse_stack_location(line)
	local fpath, fline = line:match("❯%s+(%S+):(%d+)")
	if is_user_file(fpath) then
		return fpath, tonumber(fline)
	end
	fpath, fline = line:match("at%s+%((.+):(%d+):%d+%)")
	if is_user_file(fpath) then
		return fpath, tonumber(fline)
	end
	fpath, fline = line:match("at%s+.-%((.+):(%d+):%d+%)")
	if is_user_file(fpath) then
		return fpath, tonumber(fline)
	end
	fpath, fline = line:match("at%s+(.+):(%d+):%d+$")
	if is_user_file(fpath) then
		return fpath, tonumber(fline)
	end
	return nil
end

local function find_first_user_location(msg)
	for line in msg:gmatch("[^\n]+") do
		local fpath, fline = parse_stack_location(strip_ansi(line))
		if fpath then
			return fpath, fline
		end
	end
	return nil
end

local function format_results(data, stdout, stderr, opts)
	local lines = {}
	local highlights = {}
	local locations = {}

	if not data or not data.testResults then
		table.insert(lines, "  Could not parse vitest JSON output")
		table.insert(lines, "")
		for line in (stdout or ""):gmatch("[^\n]+") do
			table.insert(lines, "  " .. strip_ansi(line))
		end
		if stderr and stderr ~= "" then
			table.insert(lines, "")
			for line in stderr:gmatch("[^\n]+") do
				table.insert(lines, "  " .. strip_ansi(line))
			end
		end
		return lines, highlights, locations
	end

	local passed = data.numPassedTests or 0
	local failed = data.numFailedTests or 0
	local total = data.numTotalTests or 0
	local skipped = total - passed - failed

	local parts = {}
	if passed > 0 then
		table.insert(parts, string.format("✓ %d passed", passed))
	end
	if failed > 0 then
		table.insert(parts, string.format("✗ %d failed", failed))
	end
	if skipped > 0 then
		table.insert(parts, string.format("○ %d skipped", skipped))
	end

	local summary = "  " .. table.concat(parts, "  ")
	table.insert(lines, summary)
	table.insert(highlights, { #lines, failed > 0 and "DiagnosticError" or "DiagnosticOk", 0, -1 })
	table.insert(lines, "  " .. string.rep("─", 56))
	table.insert(lines, "")

	local hide_skipped = opts and opts.hide_skipped

	for _, suite in ipairs(data.testResults) do
		local assertions = suite.assertionResults or {}

		if #assertions == 0 and suite.message and suite.message ~= "" then
			local name = suite.name or "unknown suite"
			if state.last_cwd and name:find(state.last_cwd, 1, true) == 1 then
				name = name:sub(#state.last_cwd + 2)
			end
			table.insert(lines, "  ✗  " .. name)
			table.insert(highlights, { #lines, "DiagnosticError", 0, -1 })
			locations[#lines] = { file = suite.name, line = 1 }
			table.insert(lines, "")
			for fline in strip_ansi(suite.message):gmatch("[^\n]+") do
				table.insert(lines, "      " .. fline)
				table.insert(highlights, { #lines, "DiagnosticError", 0, -1 })
				local fpath, flinenum = parse_stack_location(fline)
				if fpath and flinenum then
					locations[#lines] = { file = fpath, line = flinenum }
				end
			end
			table.insert(lines, "")
			goto next_suite
		end

		for _, test in ipairs(assertions) do
			local is_pass = test.status == "passed"
			local is_skip = test.status == "pending" or test.status == "skipped"
			if hide_skipped and is_skip then
				goto continue
			end
			local icon = is_pass and "✓" or (is_skip and "○" or "✗")
			local hl = is_pass and "DiagnosticOk" or (is_skip and "DiagnosticHint" or "DiagnosticError")

			local name = (test.fullName or test.title or "unknown"):gsub("^%s+", "")
			local line = string.format("  %s  %s", icon, name)
			if test.duration then
				line = line .. string.format(" (%dms)", test.duration)
			end

			table.insert(lines, line)
			local icon_end = is_pass and (2 + #icon) or -1
			table.insert(highlights, { #lines, hl, 0, icon_end })

			if test.location then
				local target_file = suite.name
				local target_line = test.location.line
				if test.status == "failed" and test.failureMessages then
					for _, msg in ipairs(test.failureMessages) do
						local fpath, fline = find_first_user_location(msg)
						if fpath and fline then
							target_file = fpath
							target_line = fline
							break
						end
					end
				end
				locations[#lines] = { file = target_file, line = target_line }
			end

			if test.failureMessages and #test.failureMessages > 0 then
				table.insert(lines, "")
				for _, msg in ipairs(test.failureMessages) do
					for fline in strip_ansi(msg):gmatch("[^\n]+") do
						table.insert(lines, "      " .. fline)
						table.insert(highlights, { #lines, "DiagnosticError", 0, -1 })
						local fpath, flinenum = parse_stack_location(fline)
						if fpath and flinenum then
							locations[#lines] = { file = fpath, line = flinenum }
						end
					end
				end
				table.insert(lines, "")
			end
			::continue::
		end
		::next_suite::
	end

	return lines, highlights, locations
end

local function build_cmd(root, extra_args)
	local bin = find_vitest_bin(root)
	local cmd
	if bin == "npx" then
		cmd = { "npx", "vitest", "run", "--reporter=json", "--no-color", "--includeTaskLocation" }
	else
		cmd = { bin, "run", "--reporter=json", "--no-color", "--includeTaskLocation" }
	end
	for _, arg in ipairs(extra_args) do
		table.insert(cmd, arg)
	end
	return cmd
end

local function collect_failed(data)
	if not data or not data.testResults then
		return nil
	end
	local failed = {}
	for _, suite in ipairs(data.testResults) do
		for _, test in ipairs(suite.assertionResults or {}) do
			if test.status == "failed" and test.location then
				table.insert(failed, { file = suite.name, line = test.location.line })
			end
		end
	end
	if #failed == 0 then
		return nil
	end
	return failed
end

local function place_describe_signs(bufnr, tests)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok or not parser then
		return
	end
	local tree = parser:parse()[1]
	if not tree then
		return
	end
	local function scan(node)
		for child in node:iter_children() do
			if child:type() == "call_expression" then
				local func = child:child(0)
				if func then
					local text = vim.treesitter.get_node_text(func, bufnr)
					local base = text:match("^(%w+)")
					if base == "describe" then
						local start_row, _, end_row = child:range()
						local has_fail, has_pass = false, false
						for _, test in ipairs(tests) do
							if test.location then
								local trow = test.location.line - 1
								if trow >= start_row and trow <= end_row then
									if test.status == "failed" then
										has_fail = true
									elseif test.status == "passed" then
										has_pass = true
									end
								end
							end
						end
						if has_fail then
							pcall(vim.api.nvim_buf_set_extmark, bufnr, signs_ns, start_row, 0, {
								sign_text = "✗",
								sign_hl_group = "DiagnosticError",
							})
						elseif has_pass then
							pcall(vim.api.nvim_buf_set_extmark, bufnr, signs_ns, start_row, 0, {
								sign_text = "✓",
								sign_hl_group = "DiagnosticOk",
							})
						end
					end
				end
			end
			scan(child)
		end
	end
	scan(tree:root())
end

local function place_signs(data)
	if not data or not data.testResults then
		return
	end
	for _, suite in ipairs(data.testResults) do
		local file = suite.name
		for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_name(bufnr) == file then
				vim.api.nvim_buf_clear_namespace(bufnr, signs_ns, 0, -1)
				local tests = suite.assertionResults or {}
				for _, test in ipairs(tests) do
					if test.location then
						local is_pass = test.status == "passed"
						local is_skip = test.status == "pending" or test.status == "skipped"
						local icon = is_pass and "✓" or (is_skip and "○" or "✗")
						local hl = is_pass and "DiagnosticOk" or (is_skip and "DiagnosticHint" or "DiagnosticError")
						pcall(vim.api.nvim_buf_set_extmark, bufnr, signs_ns, test.location.line - 1, 0, {
							sign_text = icon,
							sign_hl_group = hl,
						})
					end
				end
				place_describe_signs(bufnr, tests)
				break
			end
		end
	end
end

local function run_vitest(cmd, cwd, title, opts)
	if state.job then
		state.job:kill(15)
		state.job = nil
	end

	state.last_cmd = cmd
	state.last_cwd = cwd
	state.last_title = title

	open_panel({ "", "  Running vitest...", "" }, {}, " Vitest ⟳ ")

	state.job = vim.system(cmd, { cwd = cwd, text = true }, function(result)
		vim.schedule(function()
			state.job = nil
			local data = parse_json(result.stdout)
			state.failed = collect_failed(data)
			place_signs(data)
			local lines, highlights, locations = format_results(data, result.stdout, result.stderr, opts)
			state.locations = locations
			state.last_lines = lines
			state.last_highlights = highlights
			open_panel(lines, highlights, title)
		end)
	end)
end

local test_call_names = { it = true, test = true, describe = true }

local function is_test_call(node, bufnr)
	if node:type() ~= "call_expression" then
		return false
	end
	local func = node:child(0)
	if not func then
		return false
	end
	local text = vim.treesitter.get_node_text(func, bufnr)
	local base = text:match("^(%w+)")
	return base ~= nil and test_call_names[base] ~= nil
end

local function get_test_name(node, bufnr)
	local args = node:field("arguments")[1]
	if not args then
		return nil
	end
	local first_arg = args:named_child(0)
	if not first_arg then
		return nil
	end
	local text = vim.treesitter.get_node_text(first_arg, bufnr)
	return text:gsub("^['\"`]", ""):gsub("['\"`]$", "")
end

local function find_nearest_test(bufnr, cursor_row)
	-- Walk up from cursor to find the innermost enclosing test/describe call.
	-- Use first non-whitespace column so we land on the call, not indentation.
	local line_text = vim.api.nvim_buf_get_lines(bufnr, cursor_row, cursor_row + 1, false)[1] or ""
	local col = (line_text:find("%S") or 1) - 1
	local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { cursor_row, col } })
	while node do
		if is_test_call(node, bufnr) then
			return node:start() + 1, get_test_name(node, bufnr)
		end
		node = node:parent()
	end

	-- Fallback: find the closest test/describe at or above the cursor
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok or not parser then
		return nil
	end
	local tree = parser:parse()[1]
	if not tree then
		return nil
	end
	local best_row, best_node = nil, nil
	local function scan(n)
		for child in n:iter_children() do
			if is_test_call(child, bufnr) then
				local row = child:start()
				if row <= cursor_row and (not best_row or row > best_row) then
					best_row = row
					best_node = child
				end
			end
			scan(child)
		end
	end
	scan(tree:root())
	if best_row then
		return best_row + 1, get_test_name(best_node, bufnr)
	end
	return nil
end

local function run_at_cursor()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("Buffer has no file", vim.log.levels.ERROR)
		return
	end
	local root = find_project_root(file)
	if not root then
		vim.notify("No vitest/vite project found", vim.log.levels.ERROR)
		return
	end
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local test_line, test_name = find_nearest_test(bufnr, cursor_row)
	if not test_line then
		vim.notify("No test found near cursor", vim.log.levels.WARN)
		return
	end
	local title = test_name and (" Vitest — " .. test_name .. " ") or (" Vitest — line " .. test_line .. " ")
	run_vitest(build_cmd(root, { file .. ":" .. test_line }), root, title, { hide_skipped = true })
end

local function run_file()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("Buffer has no file", vim.log.levels.ERROR)
		return
	end
	local root = find_project_root(file)
	if not root then
		vim.notify("No vitest/vite project found", vim.log.levels.ERROR)
		return
	end
	run_vitest(build_cmd(root, { file }), root, " Vitest — file ")
end

local function run_last()
	if not state.last_cmd then
		vim.notify("No previous vitest run", vim.log.levels.WARN)
		return
	end
	run_vitest(state.last_cmd, state.last_cwd, state.last_title)
end

local function run_failed()
	if not state.failed or #state.failed == 0 then
		vim.notify("No failed tests to re-run", vim.log.levels.WARN)
		return
	end
	local root = state.last_cwd
	if not root then
		vim.notify("No previous test root", vim.log.levels.ERROR)
		return
	end
	local args = {}
	for _, t in ipairs(state.failed) do
		table.insert(args, t.file .. ":" .. t.line)
	end
	run_vitest(build_cmd(root, args), root, " Vitest — re-run failed ", { hide_skipped = true })
end

local function debug_vitest(root, vitest_args, title)
	local vitest_entry = root .. "/node_modules/vitest/vitest.mjs"
	if not vim.uv.fs_stat(vitest_entry) then
		vim.notify("Could not find vitest entry point at " .. vitest_entry, vim.log.levels.ERROR)
		return
	end

	local output_file = vim.fn.tempname() .. ".json"
	state.last_cwd = root
	state.debug_rerun = { output_file = output_file, title = title }

	local args = { "run", "--no-color", "--reporter=json", "--includeTaskLocation", "--outputFile=" .. output_file }
	for _, arg in ipairs(vitest_args) do
		table.insert(args, arg)
	end

	require("dap").run({
		type = "pwa-node",
		request = "launch",
		name = title:match("^%s*(.-)%s*$"),
		program = vitest_entry,
		args = args,
		cwd = root,
		sourceMaps = true,
		resolveSourceMapLocations = { root .. "/**", "!" .. root .. "/node_modules/**" },
		skipFiles = { "<node_internals>/**", "**/node_modules/**" },
		autoAttachChildProcesses = true,
	})
end

local function debug_at_cursor()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("Buffer has no file", vim.log.levels.ERROR)
		return
	end
	local root = find_project_root(file)
	if not root then
		vim.notify("No vitest/vite project found", vim.log.levels.ERROR)
		return
	end
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local test_line, test_name = find_nearest_test(bufnr, cursor_row)
	if not test_line then
		vim.notify("No test found near cursor", vim.log.levels.WARN)
		return
	end
	local title = " Vitest — " .. (test_name or "debug") .. " "
	debug_vitest(root, { file .. ":" .. test_line }, title)
end

local function debug_file()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("Buffer has no file", vim.log.levels.ERROR)
		return
	end
	local root = find_project_root(file)
	if not root then
		vim.notify("No vitest/vite project found", vim.log.levels.ERROR)
		return
	end
	debug_vitest(root, { file }, " Vitest — debug file ")
end

local function debug_failed()
	if not state.failed or #state.failed == 0 then
		vim.notify("No failed tests to debug", vim.log.levels.WARN)
		return
	end
	local root = state.last_cwd
	if not root then
		vim.notify("No previous test root", vim.log.levels.ERROR)
		return
	end
	local args = {}
	for _, t in ipairs(state.failed) do
		table.insert(args, t.file .. ":" .. t.line)
	end
	debug_vitest(root, args, " Vitest — debug failed ")
end

local function reopen_panel()
	if not state.last_lines then
		vim.notify("No previous vitest results", vim.log.levels.WARN)
		return
	end
	open_panel(state.last_lines, state.last_highlights, state.last_title)
end

local function load_debug_results()
	if not state.debug_rerun then
		return
	end
	local r = state.debug_rerun
	local f = io.open(r.output_file, "r")
	if not f then
		return
	end
	state.debug_rerun = nil
	local content = f:read("*a")
	f:close()
	os.remove(r.output_file)
	local data = parse_json(content)
	if not data then
		return
	end
	state.failed = collect_failed(data)
	place_signs(data)
	local lines, highlights, locations = format_results(data, content, nil, { hide_skipped = true })
	state.locations = locations
	state.last_lines = lines
	state.last_highlights = highlights
	state.last_title = r.title
	open_panel(lines, highlights, r.title)
end

require("dap").listeners.after.event_terminated["vitest_debug"] = function()
	vim.defer_fn(load_debug_results, 500)
end

require("dap").listeners.after.event_exited["vitest_debug"] = function()
	vim.defer_fn(load_debug_results, 500)
end

-- stylua: ignore start
vim.keymap.set("n", "<leader>vt", run_at_cursor,    { desc = "Vitest: test at cursor" })
vim.keymap.set("n", "<leader>vf", run_file,         { desc = "Vitest: run file" })
vim.keymap.set("n", "<leader>vl", run_last,          { desc = "Vitest: re-run last" })
vim.keymap.set("n", "<leader>vr", run_failed,        { desc = "Vitest: re-run failed" })
vim.keymap.set("n", "<leader>vo", reopen_panel,      { desc = "Vitest: open last results" })
vim.keymap.set("n", "<leader>vT", debug_at_cursor,   { desc = "Vitest: debug test at cursor" })
vim.keymap.set("n", "<leader>vF", debug_file,        { desc = "Vitest: debug file" })
vim.keymap.set("n", "<leader>vR", debug_failed,      { desc = "Vitest: debug failed" })
-- stylua: ignore end
