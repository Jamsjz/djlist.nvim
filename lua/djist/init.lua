local M = {}
local nodes = require('djist.nodes')
local bridge = require('djist.pybridge')
local ts_utils = vim.treesitter

M.showViewURLS = function()
  local view, viewBody = nodes.getViewNodes()

  -- Debugging output
  print("view:", view)
  print("viewBody:", viewBody)

  if not view or not viewBody then
    print("No matching nodes found. Ensure your query is correct and the filetype is supported.")
    return
  end

  print(ts_utils.get_node_text(view)[1])

  local viewName = ts_utils.get_node_text(view)[1]
  local sRow, _, _, _ = viewBody:range()

  bridge.runPython({ viewName = viewName, rowNo = sRow })
end

return M
