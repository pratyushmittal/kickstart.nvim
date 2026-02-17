local M = {}

local TASK_VIEW_KEYS = {
  T = true,
  ['2'] = true,
  ['3'] = true,
}

local function is_task_view(view)
  if type(view.id) ~= 'string' then
    return false
  end
  local shortcut = view.id:match('^([^_]+)_')
  return TASK_VIEW_KEYS[shortcut] == true
end

function M.setup()
  local ok_todo, OrgAgendaTodosType = pcall(require, 'orgmode.agenda.types.todo')
  if not ok_todo or OrgAgendaTodosType._custom_tasks_patched then
    return
  end

  local ok_token, AgendaLineToken = pcall(require, 'orgmode.agenda.view.token')
  if not ok_token then
    return
  end

  OrgAgendaTodosType._custom_tasks_patched = true

  local original_build_line = OrgAgendaTodosType._build_line
  local original_sort = OrgAgendaTodosType._sort

  function OrgAgendaTodosType:_build_line(headline, metadata)
    local line = original_build_line(self, headline, metadata)
    if not line or not is_task_view(self) then
      return line
    end

    local deadline = headline:get_deadline_date()
    local scheduled = headline:get_scheduled_date()
    local source_file = vim.fn.fnamemodify(headline.file.filename, ':t')

    line:add_token(AgendaLineToken:new({
      content = ' F:' .. source_file,
      hl_group = 'Comment',
    }))

    if deadline then
      line:add_token(AgendaLineToken:new({
        content = ' D:' .. deadline:to_date_string(),
        hl_group = '@org.agenda.deadline',
      }))
    end

    if scheduled then
      line:add_token(AgendaLineToken:new({
        content = ' S:' .. scheduled:to_date_string(),
        hl_group = '@org.agenda.scheduled',
      }))
    end

    if not deadline and not scheduled then
      line:add_token(AgendaLineToken:new({
        content = ' D:- S:-',
        hl_group = 'Comment',
      }))
    end

    return line
  end

  function OrgAgendaTodosType:_sort(todos)
    if not is_task_view(self) then
      return original_sort(self, todos)
    end

    table.sort(todos, function(a, b)
      local a_deadline = a:get_deadline_date()
      local b_deadline = b:get_deadline_date()
      if a_deadline and b_deadline and a_deadline ~= b_deadline then
        return a_deadline < b_deadline
      end
      if a_deadline and not b_deadline then
        return true
      end
      if b_deadline and not a_deadline then
        return false
      end

      local a_priority = a:get_priority_sort_value()
      local b_priority = b:get_priority_sort_value()
      if a_priority ~= b_priority then
        return a_priority > b_priority
      end

      local a_scheduled = a:get_scheduled_date()
      local b_scheduled = b:get_scheduled_date()
      if a_scheduled and b_scheduled and a_scheduled ~= b_scheduled then
        return a_scheduled < b_scheduled
      end
      if a_scheduled and not b_scheduled then
        return true
      end
      if b_scheduled and not a_scheduled then
        return false
      end

      if a.file.index ~= b.file.index then
        return a.file.index < b.file.index
      end
      return (a.index or 0) < (b.index or 0)
    end)

    return todos
  end
end

function M.open_task_view(shortcut)
  return require('orgmode').action('agenda.open_by_key', shortcut)
end

function M.add_current_task_to_today()
  local orgmode = require 'orgmode'
  local Promise = require 'orgmode.utils.promise'
  local Date = require 'orgmode.objects.date'

  local headline = orgmode.agenda:get_headline_at_cursor()
  if not headline then
    return vim.notify('No agenda task selected', vim.log.levels.INFO, { title = 'Org Agenda' })
  end

  headline.file
    :update(function()
      return Promise.resolve(headline:set_deadline_date(Date.today())):next(function()
        return headline:refresh()
      end)
    end)
    :next(function()
      return orgmode.agenda:redo('mapping', true)
    end)
    :next(function()
      vim.notify('Task deadline set to today', vim.log.levels.INFO, { title = 'Org Agenda' })
    end)
    :catch(function(err)
      vim.notify('Failed to set deadline: ' .. tostring(err), vim.log.levels.ERROR, { title = 'Org Agenda' })
    end)
end

return M
