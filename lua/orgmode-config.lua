local BASE_TASK = [[* TODO %? :tags:]]

local TASK_WITHOUT_TAGS = string.gsub(BASE_TASK, ':tags:', '')
local TASK_SCREENER = string.gsub(BASE_TASK, ':tags:', ':%%n:')
local DEFAULT_REFILE_FILE = '~/Websites/orgfiles/refile.org'

local TODAYS_AGENDA = {
  type = 'agenda',
  org_agenda_span = 'day',
  org_agenda_overriding_header = 'Today (schedule/deadline)',
}

return {
  -- https://nvim-orgmode.github.io/configuration
  org_agenda_files = { '~/Websites/orgfiles/**/*', '~/Websites/mapl-soft-org/orgfiles/**/*' },
  org_default_notes_file = DEFAULT_REFILE_FILE,
  -- https://nvim-orgmode.github.io/configuration#org_log_into_drawer
  -- drawers are :DRAWERNAME:...:END: thing under headlines
  org_log_into_drawer = 'LOGBOOK',
  -- https://nvim-orgmode.github.io/configuration#org_agenda_custom_commands
  org_agenda_custom_commands = {
    A = {
      description = 'Done tasks without agenda',
      types = {
        TODAYS_AGENDA,
        {
          type = 'tags',
          -- match tasks closed today which didn't have any schedule or deadline
          match = 'closed&!(+SCHEDULED)&!(+DEADLINE)',
          org_agenda_overriding_header = 'Done tasks without agenda',
        },
      },
    },
    r = {
      description = 'Refile inbox (TODO)',
      types = {
        {
          type = 'tags_todo',
          org_agenda_files = { DEFAULT_REFILE_FILE },
          org_agenda_overriding_header = 'Refile inbox',
        },
      },
    },
    ['2'] = {
      description = 'Tasks in this cycle',
      types = {
        TODAYS_AGENDA,
        {
          type = 'tags_todo',
          -- list of more actionable tasks available for pickup
          org_agenda_category_filter_preset = '-Next Cycle -Someday',
          org_agenda_overriding_header = 'Tasks in this cycle',
        },
      },
    },
    ['3'] = {
      description = 'Tasks for later cycles',
      types = {
        {
          type = 'tags_todo',
          org_agenda_category_filter_preset = 'Next Cycle|Someday',
          org_agenda_overriding_header = 'Tasks for later cycles',
        },
      },
    },
    e = {
      description = 'Show everything',
      types = {
        {
          type = 'tags',
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
      whole_file = true,
    },
    w = {
      description = 'Work Task',
      template = TASK_SCREENER,
      target = '~/Websites/mapl-soft-org/orgfiles/3.someday.org',
      whole_file = true,
    },
    p = {
      description = 'Personal Task',
      template = TASK_WITHOUT_TAGS,
      target = '~/Websites/orgfiles/personal-tasks.org',
      whole_file = true,
    },
  },
}
