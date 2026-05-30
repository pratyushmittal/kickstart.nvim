---@alias GitInlineDiffDeletedLine string

local M = {}

local ns = vim.api.nvim_create_namespace('git-inline-diff')

---@type table<integer, boolean>
local enabled = {}

---Clear inline diff virtual lines from a buffer.
---@param bufnr integer
local function clear(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  enabled[bufnr] = false
end

---Run a git command and return stdout lines.
---@param args string[]
---@return string[]|nil
local function git_lines(args)
  local result = vim.system(args, { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end

  return vim.split(vim.trim(result.stdout or ''), '\n', { trimempty = true })
end

---Find the git repository root for a file.
---@param filename string
---@return string|nil
local function git_root(filename)
  local dir = vim.fs.dirname(filename)
  local lines = git_lines({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' })
  if not lines or not lines[1] then
    -- Guard because diff preview only works inside a git repository.
    vim.notify('Not inside a git repository', vim.log.levels.WARN)
    return nil
  end

  return lines[1]
end

---Show deleted lines above their current-buffer anchor line.
---@param bufnr integer
---@param new_line integer
---@param deleted GitInlineDiffDeletedLine[]
local function add_virtual_deleted_lines(bufnr, new_line, deleted)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local at_eof = new_line > line_count
  local lnum = at_eof and line_count - 1 or math.max(new_line - 1, 0)
  local virt_lines = {}

  for _, line in ipairs(deleted) do
    virt_lines[#virt_lines + 1] = { { line, 'DiffDelete' } }
  end

  vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, 0, {
    virt_lines = virt_lines,
    virt_lines_above = not at_eof,
  })
end

---Parse unified diff lines and render deleted lines in-place.
---@param bufnr integer
---@param diff string[]
---@return integer count
local function show_deleted_lines(bufnr, diff)
  local new_line = 1

  ---@type GitInlineDiffDeletedLine[]
  local deleted = {}
  local count = 0

  ---Render and reset the current deleted-line group.
  local function flush_deleted()
    if #deleted == 0 then
      -- Guard because most diff lines are context/additions, not deleted lines.
      return
    end

    add_virtual_deleted_lines(bufnr, new_line, deleted)
    count = count + #deleted
    deleted = {}
  end

  for _, line in ipairs(diff) do
    if vim.startswith(line, '@@') then
      flush_deleted()
      new_line = tonumber(line:match('%+(%d+)')) or 1
    elseif vim.startswith(line, '-') and not vim.startswith(line, '---') then
      deleted[#deleted + 1] = line:sub(2)
    elseif vim.startswith(line, '+') and not vim.startswith(line, '+++') then
      flush_deleted()
      new_line = new_line + 1
    elseif vim.startswith(line, ' ') then
      flush_deleted()
      new_line = new_line + 1
    else
      flush_deleted()
    end
  end

  flush_deleted()
  return count
end

---Toggle same-buffer deleted-line preview for the current file's unstaged diff.
function M.toggle()
  local bufnr = vim.api.nvim_get_current_buf()
  if enabled[bufnr] then
    clear(bufnr)
    return
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == '' then
    -- Guard because unnamed buffers cannot be diffed with git.
    vim.notify('No file for git diff', vim.log.levels.WARN)
    return
  end

  local root = git_root(filename)
  if not root then
    return
  end

  local relpath = vim.fs.relpath(root, filename) or filename
  local diff = git_lines({ 'git', '-C', root, 'diff', '--no-color', '--unified=10', '--inter-hunk-context=10', '--', relpath })
  if not diff or not diff[1] then
    -- Guard because the file may have no unstaged git changes.
    vim.notify('No unstaged diff')
    return
  end

  clear(bufnr)
  local count = show_deleted_lines(bufnr, diff)
  enabled[bufnr] = count > 0

  if count == 0 then
    -- Guard because a diff can contain only additions.
    vim.notify('No deleted lines in unstaged diff')
  end
end

return M
