local M = {}

M.getBufNo = function() return vim.api.nvim_win_get_buf(0) end
M.getLang = function()
  local bufnr = M.getBufNo()
  return vim.api.nvim_get_option_value('ft', { buf = bufnr })
end

return M
