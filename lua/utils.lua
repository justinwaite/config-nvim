local M = {}

M.augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

function M.packadd(name)
	vim.cmd("packadd " .. name)
end

return M
