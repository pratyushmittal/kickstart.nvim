local M = {}

---@class HtmlCssDefinition
---@field label string
---@field source_name string
---@field range table

---@return HtmlCssDefinition[]
local function definitions_under_cursor()
  local definitions = {}
  local word = vim.fn.expand('<cword>')

  for _, item in ipairs(require('html-css.cache'):get_classes(vim.api.nvim_get_current_buf())) do
    if item.label == word then
      definitions[#definitions + 1] = item
    end
  end

  return definitions
end

---@param callback fun(definition: HtmlCssDefinition)
---@return boolean found
local function select_definition(callback)
  local definitions = definitions_under_cursor()
  if definitions[1] == nil then
    return false
  end

  if definitions[2] == nil then
    callback(definitions[1])
    return true
  end

  vim.ui.select(definitions, {
    prompt = 'Select CSS definition',
    format_item = function(item)
      return string.format('%s:%d', vim.fn.fnamemodify(item.source_name, ':t'), item.range.start.line + 1)
    end,
  }, function(item)
    if not item then
      -- Guard because the definition picker can be cancelled.
      return
    end

    callback(item)
  end)

  return true
end

---Go to the CSS class definition under the cursor.
function M.goto_definition()
  local found = select_definition(function(item)
    vim.lsp.util.show_document({ uri = vim.uri_from_fname(item.source_name), range = item.range }, 'utf-32')
  end)

  if not found then
    -- Fall back because the cursor may be on a regular LSP symbol instead of a CSS class.
    require('telescope.builtin').lsp_definitions()
  end
end

---Find project references to the CSS class under the cursor.
function M.find_references()
  if definitions_under_cursor()[1] == nil then
    -- Fall back because the cursor may be on a regular LSP symbol instead of a CSS class.
    require('telescope.builtin').lsp_references()
    return
  end

  local class = vim.fn.expand('<cword>')
  local escaped_class = vim.fn.escape(class, [=[\.^$|?*+(){}[]]=])

  require('telescope.builtin').grep_string({
    search = string.format('(^|[^a-zA-Z0-9_-])%s([^a-zA-Z0-9_-]|$)', escaped_class),
    use_regex = true,
    cwd = vim.fs.root(0, { '.git' }) or vim.fn.getcwd(),
  })
end

---Show the CSS class definition under the cursor in a floating window.
function M.peek_definition()
  local found = select_definition(function(item)
    local config = require('html-css.config').peek
    local bufnr, winid = vim.lsp.util.open_floating_preview(vim.fn.readfile(item.source_name), 'css', {
      border = config.border,
      max_height = math.floor(vim.o.lines * config.height),
      max_width = math.floor(vim.o.columns * config.width),
      title = vim.fs.basename(item.source_name),
    })

    vim.api.nvim_set_current_win(winid)
    vim.api.nvim_win_set_cursor(winid, { item.range.start.line + 1, item.range.start.character })
    vim.cmd.normal({ 'zz', bang = true })
    vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = bufnr, nowait = true })
  end)

  if not found then
    vim.notify('No CSS definition found')
  end
end

return M
