local M = {}
local uv = vim.loop
local ui = require('djist.ui')

local function onread(err, data)
  assert(not err, err)
  --if data then
  --local vals = vim.split(data, "\n")
  --for _, d in pairs(vals) do
  --if d == "" then goto continue end
  --table.insert(M.urls, d)
  --::continue::
  --table.insert(M.urls, data)
  --end
  --end
  if data then
    table.insert(M.urls, data)
  end
end

local function onerr(err, data)
  assert(not err, err)
  -- Ignore errors for now
end

local function getPythonScript()
  local scriptDir = vim.api.nvim_get_runtime_file('**/djlist.nvim/scripts/', false)[1]
  if not scriptDir or scriptDir == '' then
    scriptDir = "/home/viola/.local/share/nvim/lazy/djlist.nvim/scripts"
    -- error(
    --   'Could not find the Python script. It should be inside <runtimedir>/djlist.nvim/scripts/ where runtimedir is a directory present in the runtimepath.'
    -- )
  end
  local script = scriptDir .. '/get_urls.py'
  local fileExists = vim.loop.fs_stat(script)
  if not fileExists then
    error('Python script "get_urls.py" does not exist at: ' .. script)
  end

  return script
end

M.runPython = function(args)
  M.urls = {}
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  local pythonVenvPath = vim.env.VIRTUAL_ENV

  local function extractURLS(input_data)
    return table.concat(input_data)
  end

  local function showViritualText()
    ui.setVirtualText(extractURLS(M.urls), args.rowNo)
  end

  local pyScript = getPythonScript()

  local pythonPath = pythonVenvPath .. "/bin/python"
  handle, pid = uv.spawn(pythonPath, {
    args = { pyScript, args.viewName },
    stdio = { nil, stdout, stderr },
  }, vim.schedule_wrap(function()
    stdout:read_stop()
    stderr:read_stop()
    stdout:close()
    stderr:close()
    handle:close()
    showViritualText()
  end)
  )

  uv.read_start(stdout, onread)
  uv.read_start(stderr, onerr)
end

return M
