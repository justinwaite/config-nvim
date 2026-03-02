-- ============================================================================
-- DEBUGGING (DAP)
-- Debug Adapter Protocol setup for TypeScript/JavaScript via vscode-js-debug.
-- Uses js-debug-adapter installed through Mason (dapDebugServer.js).
-- ============================================================================

local packadd = require("utils").packadd

vim.pack.add({
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/theHamsta/nvim-dap-virtual-text",
})

packadd("nvim-dap")
packadd("nvim-dap-ui")
packadd("nvim-nio")
packadd("nvim-dap-virtual-text")

local dap = require("dap")
local dapui = require("dapui")

-- ============================================================================
-- ADAPTER
-- vscode-js-debug's standalone DAP server, spawned per-session on a free port.
-- ============================================================================

local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

for _, adapter_type in ipairs({ "pwa-node", "pwa-chrome" }) do
	dap.adapters[adapter_type] = {
		type = "server",
		host = "localhost",
		port = "${port}",
		executable = {
			command = "node",
			args = { js_debug_path, "${port}" },
		},
	}
end

-- ============================================================================
-- CONFIGURATIONS
-- ============================================================================

local common = {
	sourceMaps = true,
	resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
	skipFiles = { "<node_internals>/**", "**/node_modules/**" },
}

local function with(overrides)
	return vim.tbl_deep_extend("force", common, overrides)
end

--- Discover all active Node.js inspector ports. Returns a list of tables:
--- { inspector_port = N, pid = N, app_ports = {N, ...} }
local function discover_inspectors()
	-- Build a map of PID -> all LISTEN ports
	local lsof = vim.fn.system("lsof -c node -iTCP -sTCP:LISTEN -P -Fn 2>/dev/null")
	local pid_ports = {}
	local current_pid
	for line in lsof:gmatch("[^\n]+") do
		local pid = line:match("^p(%d+)")
		if pid then
			current_pid = tonumber(pid)
			if not pid_ports[current_pid] then
				pid_ports[current_pid] = {}
			end
		end
		local port = line:match("^n[^:]+:(%d+)")
		if port and current_pid then
			table.insert(pid_ports[current_pid], tonumber(port))
		end
	end

	-- Collect unique ports and check which are inspectors
	local inspector_set = {}
	local all_ports = {}
	for _, ports in pairs(pid_ports) do
		for _, p in ipairs(ports) do
			if not all_ports[p] then
				all_ports[p] = true
				local probe = vim.fn.system(
					string.format("curl -s --max-time 0.5 http://127.0.0.1:%d/json/version 2>/dev/null", p)
				)
				if probe:match('"Browser"') then
					inspector_set[p] = true
				end
			end
		end
	end

	-- Build results with correlated app ports
	local results = {}
	for pid, ports in pairs(pid_ports) do
		for _, p in ipairs(ports) do
			if inspector_set[p] then
				local app_ports = {}
				for _, other in ipairs(ports) do
					if not inspector_set[other] then
						table.insert(app_ports, other)
					end
				end
				table.sort(app_ports)
				table.insert(results, { inspector_port = p, pid = pid, app_ports = app_ports })
			end
		end
	end

	table.sort(results, function(a, b)
		return a.inspector_port < b.inspector_port
	end)
	return results
end

local function format_inspector(entry)
	local label = string.format("inspector :%d (pid %d)", entry.inspector_port, entry.pid)
	if #entry.app_ports > 0 then
		local port_strs = {}
		for _, p in ipairs(entry.app_ports) do
			table.insert(port_strs, tostring(p))
		end
		label = label .. " → app :" .. table.concat(port_strs, ", :")
	end
	return label
end

--- Attach to all discovered inspector ports at once via separate DAP sessions.
local function attach_all_inspectors()
	local inspectors = discover_inspectors()
	if #inspectors == 0 then
		vim.notify(
			"No Node.js inspector ports found.\nRun with: NODE_OPTIONS='--inspect=0' pnpm sst dev",
			vim.log.levels.ERROR
		)
		return
	end
	for i, entry in ipairs(inspectors) do
		local config = with({
			type = "pwa-node",
			request = "attach",
			name = format_inspector(entry),
			port = entry.inspector_port,
			cwd = vim.fn.getcwd(),
			restart = true,
			continueOnAttach = true,
		})
		if i == 1 then
			dap.run(config)
		else
			dap.run(config, { new = true })
		end
	end
	vim.notify(string.format("Attached to %d inspector(s)", #inspectors))
end

for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
	dap.configurations[language] = {
		-- Run SST in your own terminal with: NODE_OPTIONS='--inspect=0' pnpm sst dev
		with({
			type = "pwa-node",
			request = "attach",
			name = "Attach (by app port)",
			port = function()
				return coroutine.create(function(dap_run_co)
					vim.ui.input({ prompt = "App port: ", default = "3000" }, function(input)
						if not input or input == "" then
							coroutine.resume(dap_run_co, dap.ABORT)
							return
						end
						local app_port = tonumber(input)
						local inspectors = discover_inspectors()
						for _, entry in ipairs(inspectors) do
							if vim.tbl_contains(entry.app_ports, app_port) then
								vim.notify("Attaching to " .. format_inspector(entry))
								coroutine.resume(dap_run_co, entry.inspector_port)
								return
							end
						end
						vim.notify("No inspector found for app port " .. input, vim.log.levels.ERROR)
						coroutine.resume(dap_run_co, dap.ABORT)
					end)
				end)
			end,
			cwd = "${workspaceFolder}",
			restart = true,
			continueOnAttach = true,
		}),
		with({
			type = "pwa-node",
			request = "attach",
			name = "Attach (auto-discover)",
			port = function()
				return coroutine.create(function(dap_run_co)
					local inspectors = discover_inspectors()
					if #inspectors == 0 then
						vim.notify(
							"No Node.js inspector ports found.\nRun with: NODE_OPTIONS='--inspect=0' pnpm sst dev",
							vim.log.levels.ERROR
						)
						coroutine.resume(dap_run_co, dap.ABORT)
					elseif #inspectors == 1 then
						vim.notify("Attaching to " .. format_inspector(inspectors[1]))
						coroutine.resume(dap_run_co, inspectors[1].inspector_port)
					else
						vim.ui.select(inspectors, {
							prompt = "Select inspector:",
							format_item = format_inspector,
						}, function(choice)
							if choice then
								coroutine.resume(dap_run_co, choice.inspector_port)
							else
								coroutine.resume(dap_run_co, dap.ABORT)
							end
						end)
					end
				end)
			end,
			cwd = "${workspaceFolder}",
			restart = true,
			continueOnAttach = true,
		}),
		with({
			type = "pwa-node",
			request = "attach",
			name = "Attach (inspector port)",
			port = function()
				return coroutine.create(function(dap_run_co)
					vim.ui.input({ prompt = "Inspector port: ", default = "9229" }, function(input)
						coroutine.resume(dap_run_co, tonumber(input))
					end)
				end)
			end,
			cwd = "${workspaceFolder}",
			restart = true,
			continueOnAttach = true,
		}),
		with({
			type = "pwa-node",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			cwd = "${workspaceFolder}",
		}),
		with({
			type = "pwa-chrome",
			request = "launch",
			name = "Launch Chrome",
			url = function()
				return coroutine.create(function(dap_run_co)
					vim.ui.input({ prompt = "URL: ", default = "http://localhost:3000" }, function(input)
						coroutine.resume(dap_run_co, input)
					end)
				end)
			end,
			webRoot = "${workspaceFolder}",
		}),
	}
end

-- .vscode/launch.json support -- loaded automatically by nvim-dap on continue/new

-- ============================================================================
-- SIGNS
-- ============================================================================

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticError" })
vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticOk", linehl = "DapStoppedLine" })

vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

-- ============================================================================
-- DAP-UI
-- ============================================================================

dapui.setup({
	icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
	layouts = {
		{
			elements = {
				{ id = "scopes", size = 0.35 },
				{ id = "breakpoints", size = 0.15 },
				{ id = "stacks", size = 0.25 },
				{ id = "watches", size = 0.25 },
			},
			size = 50,
			position = "left",
		},
		{
			elements = {
				{ id = "repl", size = 0.5 },
				{ id = "console", size = 0.5 },
			},
			size = 0.25,
			position = "bottom",
		},
	},
})

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close({})
end

-- ============================================================================
-- VIRTUAL TEXT
-- ============================================================================

require("nvim-dap-virtual-text").setup({
	commented = true,
})

-- ============================================================================
-- KEYMAPS
-- ============================================================================

-- stylua: ignore start
vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Conditional breakpoint" })
vim.keymap.set("n", "<leader>dl", function() dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, { desc = "Log point" })
vim.keymap.set("n", "<leader>dc", function() dap.continue() end, { desc = "Continue / Start" })
vim.keymap.set("n", "<leader>dC", function() dap.run_to_cursor() end, { desc = "Run to cursor" })
vim.keymap.set("n", "<leader>di", function() dap.step_into() end, { desc = "Step into" })
vim.keymap.set("n", "<leader>do", function() dap.step_over() end, { desc = "Step over" })
vim.keymap.set("n", "<leader>dO", function() dap.step_out() end, { desc = "Step out" })
vim.keymap.set("n", "<leader>dp", function() dap.pause() end, { desc = "Pause" })
vim.keymap.set("n", "<leader>dr", function() dap.restart() end, { desc = "Restart" })
vim.keymap.set("n", "<leader>dt", function() dap.terminate() end, { desc = "Terminate" })
vim.keymap.set("n", "<leader>dR", function() dap.repl.toggle() end, { desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>du", function() dapui.toggle({}) end, { desc = "Toggle DAP UI" })
vim.keymap.set({ "n", "v" }, "<leader>de", function() dapui.eval() end, { desc = "Eval under cursor" })
vim.keymap.set("n", "<leader>dj", function() dap.down() end, { desc = "Down in stack" })
vim.keymap.set("n", "<leader>dk", function() dap.up() end, { desc = "Up in stack" })
vim.keymap.set("n", "<leader>dL", function() dap.run_last() end, { desc = "Run last" })
vim.keymap.set("n", "<leader>dw", function() require("dap.ui.widgets").hover() end, { desc = "Widgets hover" })
vim.keymap.set("n", "<leader>da", attach_all_inspectors, { desc = "Attach all inspectors" })
-- stylua: ignore end
