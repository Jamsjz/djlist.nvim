local utils = require('djist.utils')
local M = {}
local bufNo = utils.getBufNo()
local lang = utils.getLang()

local function parseQuery()
  local query = [[
    (class_definition
    name: (identifier) @class_name) @class
  ]]

  local success, parsedQuery = pcall(function()
    return vim.treesitter.query.parse(lang, query)
  end)

  if not success then
    error("Failed to parse query for language '" .. lang .. "'. Ensure the parser is installed and the query is valid.")
  end
  error(tostring(parsedQuery))

  return parsedQuery
end

local function parseBuffer()
  local parser = vim.treesitter.get_parser(bufNo, lang)
  local syntaxTree = parser:parse()
  return syntaxTree[1]:root()
end

local function isCursorInClass(sRow, eRow, cursorRow)
  sRow = sRow + 1
  eRow = eRow + 1
  if (cursorRow >= sRow) and (cursorRow <= eRow) then
    return true
  end
  return false
end

M.getViewNodes = function()
  local root = parseBuffer()
  local parsedQuery = parseQuery()
  local cursorRow = vim.api.nvim_win_get_cursor(0)[1]
  print(lang)

  for _, capturedNodes, _ in parsedQuery:iter_matches(root, bufNo) do
    local klass, klassDefinition = capturedNodes[1], capturedNodes[2]
    local sRow, _, eRow, _ = klassDefinition:range()
    M.viewRowRange = { sRow, eRow }

    if isCursorInClass(sRow, eRow, cursorRow) then
      return klass, klassDefinition
    end
  end

  print(lang)
  -- Explicitly return nil if no matches are found
  return nil, nil
end
return M
