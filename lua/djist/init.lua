M.showViewURLS = function()
  local view, viewBody = nodes.getViewNodes()

  -- Debugging output
  print("view:", view)
  print("viewBody:", viewBody)

  if not view or not viewBody then
    error("Failed to retrieve view or viewBody. Ensure the query matches and the parser is installed.")
  end

  print(ts_utils.get_node_text(view)[1])
  local viewName = ts_utils.get_node_text(view)[1]
  local sRow, _, _, _ = viewBody:range()
  bridge.runPython({ viewName = viewName, rowNo = sRow })
end
