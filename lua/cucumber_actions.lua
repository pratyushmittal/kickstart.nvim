local M = {}

---@class CucumberDefinition
---@field filename string
---@field line integer
---@field line_start integer
---@field line_end integer
---@field parser 'literal'|'parse'|'re'
---@field pattern string

---@return string
local function current_step()
  return vim.api.nvim_get_current_line():match('^%s*%S+%s+(.+)$') or ''
end

---@param value string
---@param format? string
---@return boolean
local function parse_value_matches(value, format)
  if value:match('^<[^>]+>$') then
    return true
  end
  if not format or format == '' then
    return value ~= ''
  end
  if format == 'd' then
    return value:match('^[+-]?%d+$') ~= nil
  end
  if format == 'f' or format == 'e' or format == 'g' then
    return tonumber(value) ~= nil
  end
  if format == 'w' then
    return value:match('^%w+$') ~= nil
  end

  -- Unknown format types should not hide a possibly valid diagnostic.
  return false
end

---@param pattern string
---@param step string
---@return boolean
local function parse_pattern_matches(pattern, step)
  local formats = {}
  local lua_pattern = '^'
  local position = 1

  while true do
    local start_position, end_position, field = pattern:find('{([^}]+)}', position)
    if not start_position then
      break
    end

    lua_pattern = lua_pattern .. vim.pesc(pattern:sub(position, start_position - 1)) .. '(.-)'
    formats[#formats + 1] = field:match(':(.+)$') or ''
    position = end_position + 1
  end

  lua_pattern = lua_pattern .. vim.pesc(pattern:sub(position)) .. '$'
  local values = { step:match(lua_pattern) }
  if #values ~= #formats then
    return false
  end

  for index, value in ipairs(values) do
    if not parse_value_matches(value, formats[index]) then
      return false
    end
  end

  return true
end

---@param pattern string
---@param step string
---@return boolean
local function regex_pattern_matches(pattern, step)
  pattern = pattern:gsub('%(%?P<[^>]+>', '('):gsub('\\w', '%%w'):gsub('\\d', '%%d'):gsub('\\s', '%%s')
  step = step:gsub('<[^>]+>', 'value')

  local ok, match = pcall(string.match, step, '^' .. pattern .. '$')
  return ok and match ~= nil
end

---@param root string
---@return CucumberDefinition[]
local function definitions_in(root)
  local script = vim.fs.joinpath(vim.fn.stdpath('config'), 'python', 'cucumber_steps.py')
  local result = vim.system({ 'python3', script, root }, { text = true }):wait()
  if result.code ~= 0 then
    -- Preserve native LSP behaviour if the local definition scanner fails.
    return {}
  end

  return vim.json.decode(result.stdout)
end

---@param definition CucumberDefinition
---@param step string
---@return boolean
local function definition_matches(definition, step)
  if definition.parser == 'literal' then
    return definition.pattern == step
  end
  if definition.parser == 're' then
    return regex_pattern_matches(definition.pattern, step)
  end

  return parse_pattern_matches(definition.pattern, step)
end

---@param definitions CucumberDefinition[]
---@param step string
---@return CucumberDefinition[]
local function matching_definitions(definitions, step)
  return vim.tbl_filter(function(definition)
    return definition_matches(definition, step)
  end, definitions)
end

---@return CucumberDefinition[]
local function definitions_at_cursor()
  local root = vim.fs.root(0, { '.git' }) or vim.fn.getcwd()
  return matching_definitions(definitions_in(root), current_step())
end

---@param definition CucumberDefinition
local function open_definition(definition)
  vim.cmd.edit(vim.fn.fnameescape(definition.filename))
  vim.api.nvim_win_set_cursor(0, { definition.line, 0 })
end

---@param definitions CucumberDefinition[]
---@param action fun(definition: CucumberDefinition)
local function select_definition(definitions, action)
  if definitions[1] == nil then
    -- No matching pytest-bdd decorator exists for the current step.
    vim.notify('Step definition not found', vim.log.levels.WARN)
    return
  end

  if definitions[2] == nil then
    action(definitions[1])
    return
  end

  vim.ui.select(definitions, {
    prompt = 'Select step definition',
    format_item = function(definition)
      return string.format('%s:%d', vim.fn.fnamemodify(definition.filename, ':.'), definition.line)
    end,
  }, action)
end

---@param definition CucumberDefinition
local function preview_definition(definition)
  local lines = vim.fn.readfile(definition.filename)

  vim.lsp.util.open_floating_preview(vim.list_slice(lines, definition.line_start, definition.line_end), 'python', {
    border = vim.o.winborder,
    focus_id = 'cucumber_definition',
    max_height = 20,
    title = string.format(' %s:%d ', vim.fn.fnamemodify(definition.filename, ':t'), definition.line),
  })
end

function M.goto_definition()
  select_definition(definitions_at_cursor(), open_definition)
end

function M.peek_definition()
  select_definition(definitions_at_cursor(), preview_definition)
end

---@param err? lsp.ResponseError
---@param result lsp.PublishDiagnosticsParams
---@param ctx lsp.HandlerContext
function M.publish_diagnostics(err, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if not client or not client.root_dir then
    -- Preserve diagnostics if the client has no project root to search.
    vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
    return
  end

  local definitions = definitions_in(client.root_dir)
  local filtered = vim.deepcopy(result)
  filtered.diagnostics = vim.tbl_filter(function(diagnostic)
    local step = diagnostic.code == 'cucumber.undefined-step' and diagnostic.message:match('^Undefined step: (.+)$')
    return not step or matching_definitions(definitions, step)[1] == nil
  end, result.diagnostics)

  vim.lsp.diagnostic.on_publish_diagnostics(err, filtered, ctx)
end

return M
