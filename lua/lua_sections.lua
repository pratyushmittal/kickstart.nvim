local M = {}

local function_patterns = {
  '^%s*local%s+function%s+',
  '^%s*function%s+',
  '^%s*local%s+[%w_]+%s*=%s*function',
  '^%s*[%w_%.:]+%s*=%s*function',
}

---@param line string
---@return boolean
local function is_function_start(line)
  for _, pattern in ipairs(function_patterns) do
    if line:match(pattern) then
      return true
    end
  end

  return false
end

---@param step 1|-1
local function jump_function(step)
  local line_number = vim.fn.line('.') + step
  local last_line = vim.fn.line('$')
  local remaining = vim.v.count1

  while line_number >= 1 and line_number <= last_line do
    if is_function_start(vim.fn.getline(line_number)) then
      remaining = remaining - 1
      if remaining == 0 then
        vim.api.nvim_win_set_cursor(0, { line_number, 0 })
        return
      end
    end

    line_number = line_number + step
  end
end

---Jump to the next Lua function-like section.
function M.next_function()
  jump_function(1)
end

---Jump to the previous Lua function-like section.
function M.previous_function()
  jump_function(-1)
end

return M
