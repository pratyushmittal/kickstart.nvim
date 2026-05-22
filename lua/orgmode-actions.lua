local M = {}

function M.open_agenda(key)
  require('orgmode').action('agenda.open_by_key', key)
end

function M.capture_task(template)
  require('orgmode').capture:open_template_by_shortcut(template)
end

local function unlock_file_buffer(file)
  local bufnr = file:bufnr()
  if bufnr < 0 then
    -- Guard because orgmode may not have loaded the file buffer yet.
    return nil
  end

  local opts = {
    bufnr = bufnr,
    readonly = vim.bo[bufnr].readonly,
    modifiable = vim.bo[bufnr].modifiable,
  }

  -- Faltoo review mode locks file buffers, so unlock this org buffer while orgmode edits it.
  vim.bo[bufnr].readonly = false
  vim.bo[bufnr].modifiable = true

  return opts
end

local function restore_file_buffer(opts)
  if not opts or not vim.api.nvim_buf_is_valid(opts.bufnr) then
    -- Guard because orgmode can close its temporary hidden edit buffer after saving.
    return
  end

  vim.bo[opts.bufnr].readonly = opts.readonly
  vim.bo[opts.bufnr].modifiable = opts.modifiable
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
  local buffer_opts = nil

  -- file:update() opens/saves the org file buffer around this mutation.
  headline.file
    :update(function(file)
      buffer_opts = unlock_file_buffer(file)

      if has_deadline then
        -- Remove today's marker when the task already has a deadline.
        return headline:remove_deadline_date()
      end
      return headline:set_deadline_date(Date.today())
    end)
    :next(function()
      restore_file_buffer(buffer_opts)
      -- Refresh agenda so the changed deadline is reflected immediately.
      return orgmode.agenda:redo('mapping', true)
    end)
    :next(function()
      local message = has_deadline and 'Task deadline removed' or 'Task deadline set to today'
      vim.notify(message, vim.log.levels.INFO, { title = 'Org Agenda' })
    end)
    :catch(function(err)
      restore_file_buffer(buffer_opts)
      vim.notify('Failed to toggle deadline: ' .. tostring(err), vim.log.levels.ERROR, { title = 'Org Agenda' })
    end)
end

return M
