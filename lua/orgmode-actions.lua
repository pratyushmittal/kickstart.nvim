local M = {}

function M.open_agenda(key)
  require('orgmode').action('agenda.open_by_key', key)
end

function M.capture_task(template)
  require('orgmode').capture:open_template_by_shortcut(template)
end

function M.toggle_current_task_today_deadline()
  local orgmode = require('orgmode')
  local Date = require('orgmode.objects.date')
  local headline = orgmode.agenda:get_headline_at_cursor()

  if not headline then
    -- Guard because this only works when an agenda task is selected.
    vim.notify('No agenda task selected', vim.log.levels.INFO, { title = 'Org Agenda' })
    return
  end

  local has_deadline = headline:get_deadline_date() ~= nil

  headline.file
    :update(function()
      if has_deadline then
        -- Remove today's marker when the task already has a deadline.
        return headline:remove_deadline_date()
      end
      return headline:set_deadline_date(Date.today())
    end)
    :next(function()
      return orgmode.agenda:redo('mapping', true)
    end)
    :next(function()
      local message = has_deadline and 'Task deadline removed' or 'Task deadline set to today'
      vim.notify(message, vim.log.levels.INFO, { title = 'Org Agenda' })
    end)
    :catch(function(err)
      vim.notify('Failed to toggle deadline: ' .. tostring(err), vim.log.levels.ERROR, { title = 'Org Agenda' })
    end)
end

return M
