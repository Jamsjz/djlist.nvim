local M = {}

M.getBufNo = function() return vim.api.nvim_win_get_buf(0) end
M.getLang = function() return vim.api.nvim_get_option(M.getBufNo(), 'ft') end

return M
