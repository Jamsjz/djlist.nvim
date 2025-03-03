local M = {}
local ns_id = vim.api.nvim_create_namespace("djist-virtual-text") -- Create a namespace

M.setVirtualText = function(text, lineNo)
  vim.api.nvim_buf_set_extmark(0, ns_id, lineNo, 0, {
    virt_text = { { text, "Comment" } },
    virt_text_pos = "eol",
  })
end

return M
