local BASE_TASK = [[* TODO %? :tags:
DEADLINE: %U
:LOGBOOK:
CLOCK: %T
:END:
]]

local TASK_WITHOUT_TAGS = string.gsub(BASE_TASK, ':tags:', '')
local TASK_SCREENER = string.gsub(BASE_TASK, ':tags:', ':%u:')

return {
  -- https://nvim-orgmode.github.io/configuration
  org_agenda_files = { '~/Websites/orgfiles/**/*', '~/Websites/mapl-soft-org/orgfiles/**/*' },
  org_default_notes_file = '~/Websites/orgfiles/refile.org',
  -- org_todo_keywords = {'TODO', 'AI-DOING', 'ON-IT', 'REVIEW', '|', 'DONE'}
  -- https://nvim-orgmode.github.io/configuration#org_capture_templates
  org_capture_templates = {
    t = {
      description = 'Task',
      template = TASK_WITHOUT_TAGS,
    },
    w = {
      description = 'Work Task',
      template = TASK_SCREENER,
      target = '~/Websites/mapl-soft-org/orgfiles/tasks.org',
    },
    p = {
      description = 'Personal Task',
      template = TASK_WITHOUT_TAGS,
      target = '~/Websites/orgfiles/tasks.org',
    },
  },
}
