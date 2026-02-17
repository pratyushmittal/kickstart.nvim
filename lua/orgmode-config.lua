local BASE_TASK = [[* TODO %? :tags:]]

local TASK_WITHOUT_TAGS = string.gsub(BASE_TASK, ':tags:', '')
local TASK_SCREENER = string.gsub(BASE_TASK, ':tags:', ':%%n:')
local DEFAULT_REFILE_FILE = '~/Websites/orgfiles/refile.org'

return {
  -- https://nvim-orgmode.github.io/configuration
  org_agenda_files = { '~/Websites/orgfiles/**/*', '~/Websites/mapl-soft-org/orgfiles/**/*' },
  org_default_notes_file = DEFAULT_REFILE_FILE,
  org_agenda_custom_commands = {
    r = {
      description = 'Refile inbox (TODO)',
      types = {
        {
          type = 'tags_todo',
          match = 'level>=1',
          org_agenda_files = { DEFAULT_REFILE_FILE },
          org_agenda_overriding_header = 'Refile inbox',
        },
      },
    },
    T = {
      description = 'All tasks',
      types = {
        {
          type = 'tags_todo',
          match = 'level>=1',
          org_agenda_overriding_header = 'All tasks',
        },
      },
    },
    ['2'] = {
      description = 'Tasks with deadline in next 6 weeks',
      types = {
        {
          type = 'tags_todo',
          match = 'DEADLINE>="<today>"+DEADLINE<="<+6w>"',
          org_agenda_overriding_header = 'Tasks with deadline in next 6 weeks',
        },
      },
    },
    ['3'] = {
      description = 'Tasks without deadline',
      types = {
        {
          type = 'tags_todo',
          match = 'level>=1',
          org_agenda_todo_ignore_deadlines = 'all',
          org_agenda_overriding_header = 'Tasks without deadline',
        },
      },
    },
  },
  mappings = {
    agenda = {
      -- use m to move tasks
      org_agenda_refile = 'm',
    },
  },
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
