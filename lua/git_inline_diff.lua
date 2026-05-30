local M = {}

local ns = vim.api.nvim_create_namespace('git-inline-diff')

---@type table<integer, boolean>
local enabled = {}

---@param bufnr integer
local function clear(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  enabled[bufnr] = false
end

---@param args string[]
---@return string[]|nil
local function shell_lines(args)
  local result = vim.system(args, { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end

  return vim.split(vim.trim(result.stdout or ''), '\n', { trimempty = true })
end

---@param bufnr integer
---@return string[]|nil
local function git_diff(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == '' then
    -- Guard because unnamed buffers cannot be diffed with git.
    vim.notify('No file for git diff', vim.log.levels.WARN)
    return nil
  end

  local dir = vim.fs.dirname(filename)
  local root = shell_lines({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' })
  if not root or not root[1] then
    -- Guard because diff preview only works inside a git repository.
    vim.notify('Not inside a git repository', vim.log.levels.WARN)
    return nil
  end

  local relpath = vim.fs.relpath(root[1], filename) or filename
  return shell_lines({ 'git', '-C', root[1], 'diff', '--no-color', '--unified=0', '--', relpath })
end

---@param bufnr integer
---@param line_number integer
---@param deleted string[]
---@param above boolean
local function show_deleted(bufnr, line_number, deleted, above)
  if #deleted == 0 then
    return
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local lnum = math.min(math.max(line_number - 1, 0), line_count - 1)
  local virt_lines = {}

  for _, line in ipairs(deleted) do
    virt_lines[#virt_lines + 1] = { { line, 'DiffDelete' } }
  end

  vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, 0, {
    virt_lines = virt_lines,
    virt_lines_above = above,
  })
end

---@param header string
---@return integer line_number
---@return boolean above
local function parse_hunk_anchor(header)
  local start, length = header:match('%+(%d+),?(%d*)')
  local line_number = math.max(tonumber(start) or 1, 1)
  local is_delete_only = tonumber(length) == 0

  if is_delete_only and start ~= '0' then
    return line_number, false
  end

  return line_number, true
end

---@param bufnr integer
---@param diff string[]
---@return integer
local function render_deleted_lines(bufnr, diff)
  local line_number = 1
  local above = true
  local count = 0
  local deleted = {}
  local in_hunk = false

  local function flush()
    -- Render collected deleted lines at the anchor from the current hunk header.
    count = count + #deleted
    show_deleted(bufnr, line_number, deleted, above)
    deleted = {}
  end

  for _, line in ipairs(diff) do
    if vim.startswith(line, '@@') then
      -- Hunk header tells us where this hunk belongs in the current file.
      flush()
      in_hunk = true
      line_number, above = parse_hunk_anchor(line)
    elseif in_hunk and vim.startswith(line, '-') then
      -- Deleted lines do not exist in the buffer, so collect and render them virtually.
      -- We only parse inside hunks, so Lua comments like ---foo are not confused with diff headers.
      deleted[#deleted + 1] = line:sub(2)
    end
  end

  flush()
  return count
end

---Toggle same-buffer deleted-line preview for the current file's unstaged diff.
function M.toggle()
  local bufnr = vim.api.nvim_get_current_buf()
  if enabled[bufnr] then
    clear(bufnr)
    return
  end

  local diff = git_diff(bufnr)
  if not diff or not diff[1] then
    -- Guard because the file may have no unstaged git changes.
    vim.notify('No unstaged diff')
    return
  end

  clear(bufnr)
  local count = render_deleted_lines(bufnr, diff)
  enabled[bufnr] = count > 0

  if count == 0 then
    -- Guard because a diff can contain only additions.
    vim.notify('No deleted lines in unstaged diff')
  end
end

return M
