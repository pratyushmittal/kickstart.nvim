-- Set <space> as the leader key
-- set it before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '

-- Lazy for plugins
-- https://lazy.folke.io/installation
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Use Lazy
-- Setup lazy.nvim
require('lazy').setup {
  -- color theme
  'https://github.com/rktjmp/lush.nvim',
  {
    'https://github.com/olimorris/onedarkpro.nvim',
    opts = {
      options = { cursorline = true },
    },
  },
  {
    'https://github.com/rebelot/kanagawa.nvim',
    opts = {
      dimInactive = true,
      undercurl = true,
      overrides = function(colors)
        return {
          ['@string.special.url'] = { underline = true, undercurl = false },
        }
      end,
    },
  },
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/vague2k/vague.nvim',
  'https://github.com/srcery-colors/srcery-vim',
  { 'https://github.com/catppuccin/nvim', name = 'catppuccin', priority = 1000 },
  -- auto change to dark mode and light mode
  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      set_dark_mode = function()
        vim.cmd 'colorscheme srcery'
      end,
      set_light_mode = function()
        vim.cmd 'colorscheme kanagawa'
      end,
    },
  },
  {
    -- syntax highlighting
    -- https://github.com/nvim-treesitter/nvim-treesitter
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'comment',
        'diff',
        'html',
        'htmldjango',
        'lua',
        'luap',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'python',
        'elixir',
      },
      -- Auto Install languages that are not installed
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      -- https://github.com/RRethy/nvim-treesitter-endwise extension
      endwise = { enable = true },
      -- incremental selection
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = 's',
          node_incremental = 's',
          node_decremental = 'S',
        },
      },
      textobjects = {
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']c'] = '@class.outer',
            -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects?tab=readme-ov-file#built-in-textobjects
            -- ["]]"] = "@function.outer",
          },
          goto_previous_start = {
            -- ["[["] = "@function.outer",
            ['[c'] = '@class.outer',
          },
        },
      },
    },
  },
  -- show current method or class name when scrolling
  { 'nvim-treesitter/nvim-treesitter-context', opts = { max_lines = 2 } },
  -- use mason to install and manage linters, LSPs, DAPs and formatters for vim's LSP
  -- vim's lsp doesn't automatically install these, nor does it provide a way to install these
  {
    -- mason-lspconfig automatically installs the libraries we mention
    -- plus it automatically calls vim.lsp.enable() on them
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      -- check all available LSPs using `:Mason`
      { 'https://github.com/mason-org/mason.nvim', opts = {} },
      'https://github.com/neovim/nvim-lspconfig',
      -- while mason actually installs the binaries for linters
      -- and nvim-lspconfig configures them
      -- mason-tool-installer allow us to configure `ensure_installed` so that these are automatically passed to mason for installation
      {
        'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
        opts = {

          ensure_installed = {
            'bashls',
            'biome',
            'cssls',
            'codebook',
            'djlint',
            'docker_compose_language_service',
            'emmet_language_server',
            'harper_ls',
            'lua_ls',
            'ruff',
            'rust_analyzer',
            'stylua',
            'ty',
            'typescript-language-server',
            'yamlls',
          },
        },
      },
    },
    opts = {
      -- mason-lspconfig supports ensure_installed, but it only works for LSPs, not for linters and formatters
      -- hence used them via mason-tool-installer
      ensure_installed = {},
    },
  },
  -- Useful status updates for LSP.
  { 'j-hui/fidget.nvim', opts = {} },
  -- highlight current word (under cursor) using LSP, tree-sitter
  'https://github.com/RRethy/vim-illuminate',
  -- snippets
  {
    'https://github.com/L3MON4D3/LuaSnip',
    -- enable regex support
    build = 'make install_jsregexp',
    dependencies = {
      -- `friendly-snippets` contains a variety of pre-made snippets
      {
        'https://github.com/rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
          --  snipmate snippets are easier to write, hance use this for custom snippets in `snippets` folder
          require('luasnip.loaders.from_snipmate').lazy_load()
        end,
      },
    },
  },
  -- auto-completion
  {
    'https://github.com/saghen/blink.cmp',
    -- requires version setting to download pre-built fuzzy binary
    -- https://cmp.saghen.dev/configuration/fuzzy#prebuilt-binaries-default-on-a-release-tag
    version = '1.*',
    event = 'VimEnter',
    dependencies = {
      'https://github.com/folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- default keymap
        -- <c-y> to accept ([y]es) the completion.
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = 'default',

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = {
          -- default
          -- https://cmp.saghen.dev/configuration/reference.html#completion-menu-draw
          border = 'rounded',
          draw = {
            columns = {
              { 'label', 'label_description', gap = 1 },
              { 'kind_icon', 'kind' },
            },
          },
        },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },

      snippets = { preset = 'luasnip' },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = 'prefer_rust_with_warning' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },
  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- use telescope for vim.ui.select
      'nvim-telescope/telescope-ui-select.nvim',
      -- use nerd font
      'nvim-tree/nvim-web-devicons',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- `build` is run only once. When the plugin is installed/updated.
        build = 'make',
      },
      -- brew install ripgrep
    },
    config = function()
      require('telescope').setup {
        defaults = { wrap_results = true },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      -- Enable extensions
      require('telescope').load_extension 'fzf'
      require('telescope').load_extension 'ui-select'
    end,
  },
  -- GIT changes: `:help gitsigns`
  {
    'https://github.com/lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  -- auto pair brackets and quotes
  { 'https://github.com/windwp/nvim-autopairs', event = 'InsertEnter', opts = { check_ts = true } },
  -- add quotes around selected text
  { 'https://github.com/echasnovski/mini.surround', version = false, opts = {} },
  -- auto close functions
  'https://github.com/RRethy/nvim-treesitter-endwise',
  -- configure jumps on [[, ]], ]m, [m - for all languages
  -- configured via textobjects in treesitter
  'nvim-treesitter/nvim-treesitter-textobjects',
  -- auto close tags in html
  { 'https://github.com/windwp/nvim-ts-autotag', opts = {} },
  -- multi cursor
  'mg979/vim-visual-multi',
  -- create file on :e
  'https://github.com/jessarcher/vim-heritage',
  -- managing files
  {
    'https://github.com/stevearc/oil.nvim',
    opts = {},
    dependencies = { { 'https://github.com/echasnovski/mini.icons', opts = {} } },
  },
  -- detect tab width automatically based on current file and editorconfig
  'https://github.com/tpope/vim-sleuth',
  -- show indent lines
  { 'https://github.com/lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },
  -- auto format on save
  {
    'https://github.com/stevearc/conform.nvim',
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          -- we need to install these using :MasonInstall
          -- we have fallback for lsp below. Hence need these only when the lsp doesn't do formatting
          lua = { 'stylua' },
          -- Conform will run the first available formatter
          html = { 'djlint', 'prettierd', 'prettier', stop_after_first = true },
          css = { 'biome', 'prettier', stop_after_first = true },
          htmldjango = { 'djlint' },
          python = { 'ruff_fix', 'ruff_organize_imports', 'ruff_format' },
        },
        formatters = {
          djlint = {
            -- requires running djlint once from terminal to prevent timeout
            -- use <c-/> to open terminal
            prepend_args = { '--indent', '2', '--max-blank-lines', '2', '--profile', 'django' },
          },
        },
        -- enable format on save
        format_on_save = function(bufnr)
          -- Disable with a global or buffer-local variable
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          return {
            -- These options will be passed to conform.format()
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end,
      }
    end,
  },
  -- make key-bindings easier to see which whichkey
  {
    'https://github.com/folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- Document existing key chains
      spec = {
        { 'gr', group = '[G]oto [R]eference' },
        { '<leader>a', group = '[A]I' },
        { '<leader>b', group = '[B]uffer' },
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>o', group = '[O]rg mode' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },
  -- Highlight todo, notes, etc in comments
  { 'https://github.com/folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  -- better dialogs
  { 'https://github.com/stevearc/dressing.nvim', opts = {} },
  -- CodeCompanion for ai
  {
    'https://github.com/pratyushmittal/codecompanion.nvim',
    branch = 'tab-autocomplete',
    opts = {
      prompt_library = require 'prompts',
      strategies = {
        chat = {
          adapter = 'openai',
          model = 'gpt-5-2025-08-07',
          tools = {
            opts = {
              auto_submit_errors = false, -- Send any errors to the LLM automatically?
              auto_submit_success = false, -- Send any successful output to the LLM automatically?
            },
          },
        },
        inline = {
          adapter = 'openai',
          model = 'gpt-5-2025-08-07',
        },
        cmd = {
          adapter = 'openai',
          model = 'gpt-5-2025-08-07',
        },
      },
      opts = {
        log_level = 'DEBUG',
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },
  -- Status line
  {
    'https://github.com/nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      sections = {
        -- https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file#filename-component-options
        lualine_b = { { 'filename', path = 1 } },
        lualine_c = { 'diff', 'diagnostics' },
        lualine_x = { 'filetype' },
      },
    },
  },
  -- floating terminal
  {
    'https://github.com/akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = 'float',
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = 'curved',
        winblend = 0,
        highlights = {
          border = 'Normal',
          background = 'Normal',
        },
      },
    },
  },
  -- disable LSP and treesitter for big files over 2mb
  { 'https://github.com/LunarVim/bigfile.nvim', opts = {} },
  -- retain layout on :bd
  'https://github.com/famiu/bufdelete.nvim',
  -- run tests
  'https://github.com/vim-test/vim-test',
  -- run code repl
  {
    'https://github.com/michaelb/sniprun',
    branch = 'master',
    build = 'sh install.sh',
    -- do 'sh install.sh 1' if you want to force compile locally
    -- (instead of fetching a binary from the github release). Requires Rust >= 1.65
    opts = {},
  },
  -- insert log lines automatically
  {
    'https://github.com/Goose97/timber.nvim',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    opts = {},
  },
  -- search and execute commands
  { 'https://github.com/doctorfree/cheatsheet.nvim', opts = { bundled_cheatsheets = { disabled = { 'nerd-fonts' } } } },
  -- lsp supported code completions in markdown and other embeds
  -- need to call :OtterActivate to enable
  { 'https://github.com/jmbuhr/otter.nvim', opts = {} },
  -- jumping between neighbors
  {
    'https://github.com/aaronik/treewalker.nvim',

    -- The following options are the defaults.
    -- Treewalker aims for sane defaults, so these are each individually optional,
    -- and setup() does not need to be called, so the whole opts block is optional as well.
    opts = {
      -- Whether to briefly highlight the node after jumping to it
      highlight = true,

      -- How long should above highlight last (in ms)
      highlight_duration = 250,

      -- The color of the above highlight. Must be a valid vim highlight group.
      -- (see :h highlight-group for options)
      highlight_group = 'CursorLine',
    },
  },
  -- Detect tabstop and shiftwidth automatically
  'https://github.com/NMAC427/guess-indent.nvim',
  -- org mode and todo
  {
    'nvim-orgmode/orgmode',
    event = 'VeryLazy',
    config = function()
      -- Setup orgmode
      require('orgmode').setup(require 'orgmode-config')
      require('orgmode-patches').setup()
    end,
  },
  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'https://github.com/folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
}

-- LSP for linting, definition, references, symbols
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = require('blink.cmp').get_lsp_capabilities()
vim.lsp.config('ruff', { capabilities = capabilities, offset_encoding = 'utf-8' })
vim.lsp.config('rust_analyzer', {
  capabilities = capabilities,
  settings = {
    ['rust-analyzer'] = {
      procMacro = {
        ignored = {
          leptos_macro = {
            -- optional: --
            -- "component",
            'server',
          },
        },
      },
    },
  },
})

vim.lsp.config('cssls', {
  capabilities = capabilities,
  settings = {
    -- we can check all properties by doing :Mason, select tool, "LSP server configuration schema"
    css = {
      lint = { duplicateProperties = 'warning' },
    },
  },
})
vim.lsp.config('yamlls', { capabilities = capabilities })
vim.lsp.config('biome', { capabilities = capabilities })
vim.lsp.config('ts_ls', { capabilities = capabilities })
vim.lsp.config('emmet_language_server', { capabilities = capabilities })
vim.lsp.config('astro', { capabilities = capabilities })
vim.lsp.config('lua_ls', {
  capabilities = capabilities,

  completion = {
    callSnippet = 'Replace',
  },
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
    },
  },
})
vim.lsp.config('docker_compose_language_service', { capabilities = capabilities })
vim.lsp.config('org', { capabilities = capabilities })

vim.lsp.config(
  'ty',
  { capabilities = capabilities, offset_encoding = 'utf-8', settings = {
    ty = {
      experimental = {
        autoImport = true,
      },
    },
  } }
)
vim.lsp.config('harper_ls', {
  capabilities = capabilities,
  filetypes = {
    'gitcommit',
    'html',
    'htmldjango',
    'markdown',
    'rust',
    'swift',
    'toml',
    'php',
    'dart',
  },
  settings = {
    ['harper-ls'] = {
      userDictPath = '~/dict.txt',
      linters = {
        SentenceCapitalization = false,
      },
    },
  },
})

-- show diagnostic errors inline
vim.diagnostic.config {
  virtual_lines = {
    -- Only show virtual line diagnostics for the current cursor line
    current_line = true,
  },
  -- severity_sort = true,
  -- float = { border = 'rounded', source = 'if_many' },
  -- underline = { severity = vim.diagnostic.severity.ERROR },
  -- signs = vim.g.have_nerd_font and {
  --   text = {
  --     [vim.diagnostic.severity.ERROR] = '󰅚 ',
  --     [vim.diagnostic.severity.WARN] = '󰀪 ',
  --     [vim.diagnostic.severity.INFO] = '󰋽 ',
  --     [vim.diagnostic.severity.HINT] = '󰌶 ',
  --   },
  -- } or {},
  -- virtual_text = {
  --   source = 'if_many',
  --   spacing = 2,
  --   format = function(diagnostic)
  --     local diagnostic_message = {
  --       [vim.diagnostic.severity.ERROR] = diagnostic.message,
  --       [vim.diagnostic.severity.WARN] = diagnostic.message,
  --       [vim.diagnostic.severity.INFO] = diagnostic.message,
  --       [vim.diagnostic.severity.HINT] = diagnostic.message,
  --     }
  --     return diagnostic_message[diagnostic.severity]
  --   end,
  -- },
}

-- configure otter for markdown and codecompanion
-- https://github.com/olimorris/codecompanion.nvim/discussions/1284
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { '*.md' },
--   callback = function(args)
--     require("otter").activate()
--     local bufnr = args.buf
--     vim.api.nvim_create_autocmd("BufWritePost", {
--       buffer = bufnr,
--       callback = function()
--         require("otter").activate()
--       end
--     })
--   end
-- })

-- VIM OPTIONS
-- we can see all options using `:help option-list`
-- set theme
vim.o.termguicolors = true -- enable true colors
-- vim.cmd 'colorscheme onelight'

-- Use rounded borders for all floating windows (new in Neovim 0.11)
vim.o.winborder = 'rounded'

-- disable autoinsert of first option in menus
vim.o.completeopt = 'menuone,popup,noinsert'

vim.cmd 'colorscheme onedark_dark'

-- Make line numbers default
vim.o.number = true
vim.o.relativenumber = true

-- hide mode as already shown in lualine
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- wrapped lines have same indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- show signcolumn only when there are changes default
-- vim.o.signcolumn = 'yes'

-- Decrease the auto-save time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
-- :vsplit should open split on right
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 7

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Use treesitter for folding
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldlevelstart = 99

-- KEY BINDINGS
-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- changing buffers
vim.keymap.set('n', '<leader>bp', ':bp<CR>', { desc = '[B]uffer [P]revious' })
vim.keymap.set('n', '<leader>bn', ':bn<CR>', { desc = '[B]uffer [N]ext' })
vim.keymap.set('n', '<leader>bd', ':Bdelete<CR>', { desc = '[B]uffer [D]elete' })

local function get_active_org_clock_title()
  local ok, orgmode = pcall(require, 'orgmode')
  if not ok or not orgmode.files then
    return nil
  end

  local headline = orgmode.files:get_clocked_headline()
  if not headline then
    return nil
  end

  local todo = headline:get_todo()
  local title = headline:get_title()
  local category = headline:get_category()
  local todo_text = todo and (todo .. ' ') or ''
  local category_text = category and category ~= '' and (' [' .. category .. ']') or ''

  return string.format('%s%s%s', todo_text, title, category_text)
end

-- orgmode quick actions
vim.keymap.set('n', '<leader>ow', function()
  local active = get_active_org_clock_title()
  if not active then
    return vim.notify('No active Org clock', vim.log.levels.INFO, { title = 'Orgmode' })
  end
  vim.notify('Working on: ' .. active, vim.log.levels.INFO, { title = 'Orgmode' })
end, { desc = '[O]rg [W]orking task' })

vim.keymap.set('n', '<leader>oj', function()
  require('orgmode').action 'clock.org_clock_goto'
end, { desc = '[O]rg [J]ump to active task' })

vim.keymap.set('n', '<leader>oi', function()
  require('orgmode').action('agenda.open_by_key', 'r')
end, { desc = '[O]rg Refile [I]nbox' })

vim.keymap.set('n', '<leader>ot', function()
  require('orgmode-patches').open_task_view 'T'
end, { desc = '[O]rg [T]asks' })

-- ai codecompanion
vim.keymap.set({ 'n', 'v' }, '<leader>aa', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true, desc = '[A]ctions' })
vim.keymap.set({ 'n', 'v' }, '<leader>ac', '<cmd>CodeCompanionChat<cr>', { noremap = true, silent = true, desc = '[C]hat' })
vim.keymap.set({ 'n', 'v' }, '<leader>at', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true, desc = '[T]oggle' })
vim.keymap.set({ 'i' }, '<C-f>', '<cmd>CodeCompanionComplete<cr>', { noremap = true, silent = true, desc = 'Complete [F]orward' })
vim.keymap.set({ 'n', 'v' }, '<leader>ae', ":'<,'>CodeCompanion #buffer ", { noremap = true, silent = true, desc = '[E]dit' })

-- CoffeeShop mode
-- use CoffeeShop mode to hide what we type in public places
-- we can use it using these commands
vim.api.nvim_create_user_command('CoffeeShopModeOn', function()
  -- Conceal lowercase letters with a bullet in all contexts
  vim.cmd 'syntax match CoffeeShop /[a-z]/ conceal cchar=• contains=NONE containedin=ALL'
  -- Keep default highlight so colors don't change
  vim.cmd 'highlight default link CoffeeShop Normal'
  -- Enable conceal in normal and insert modes
  vim.wo.conceallevel = 2
  vim.wo.concealcursor = 'ni'
end, { desc = 'Enable CoffeeShop mode: conceal lowercase letters with a bullet' })

-- run replt
vim.api.nvim_set_keymap('v', '<leader>x', '<Plug>SnipRun', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>x', '<Plug>SnipRun', { silent = true })

-- LSP keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function()
    -- -- new lsp autocompletion supported natively in neovim
    -- local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- if client:supports_method('textDocument/completion') then
    --   vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    -- end
    -- Jump to the definition of the word under your cursor.
    --  To jump back, press <C-t>.
    vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, { desc = '[G]oto [D]efinition' })
    -- Find references for the word under your cursor.
    vim.keymap.set('n', 'grr', require('telescope.builtin').lsp_references, { desc = '[G]oto [R]eferences' })
    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    vim.keymap.set('n', 'grn', vim.lsp.buf.rename, { desc = '[R]e[n]ame' })
    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    vim.keymap.set({ 'n', 'x' }, 'gra', vim.lsp.buf.code_action, { desc = '[G]oto Code [A]ction' })
  end,
})

-- Git keymaps
-- :help gitsigns
vim.keymap.set('n', ']e', ':Gitsigns next_hunk<CR>', { desc = 'Jump to next git [e]dit' })
vim.keymap.set('n', '[e', ':Gitsigns prev_hunk<CR>', { desc = 'Jump to prev git [e]dit' })
vim.keymap.set({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', { desc = 'git [s]tage hunk' })
vim.keymap.set({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', { desc = 'git [r]eset hunk' })
vim.keymap.set({ 'n', 'v' }, '<leader>hu', ':Gitsigns undo_stage_hunk<CR>', { desc = 'git [u]nstage hunk' })
vim.keymap.set({ 'n', 'v' }, '<leader>hd', ':Gitsigns diffthis<CR>', { desc = 'git [d]iff against index' })
vim.keymap.set({ 'n', 'v' }, '<leader>hp', ':Gitsigns preview_hunk<CR>', { desc = 'git [p]review hunk' })
vim.keymap.set({ 'n', 'v' }, '<leader>hb', ':Gitsigns blame_line<CR>', { desc = 'git [b]lame line' })
vim.keymap.set({ 'n', 'v' }, '<leader>hB', ':Gitsigns blame<CR>', { desc = 'git [B]lame file' })

-- edit file under cursor
vim.keymap.set('n', 'gf', ':edit <cfile><cr>', { desc = '[g]oto [f]ile' })

-- open oil folder for current file
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', function()
  local win = vim.fn.getloclist(0, { winid = 0 })
  if win.winid == 0 then
    vim.diagnostic.setloclist()
  else
    vim.cmd.lclose()
  end
end, { desc = 'Toggle diagnostic [Q]uickfix list' })

-- telescope keymaps `:help telescope.builtin`
-- Most important Telescope keymapping is <C-leader>
-- This allows you to filter existing results
-- We can use !foo to exclude results without foo (negative search)
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sc', builtin.git_status, { desc = '[S]earch [C]hanges' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sl', builtin.lsp_dynamic_workspace_symbols, { desc = '[S]earch [L]SP' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

vim.keymap.set('n', '<leader>sm', function()
  builtin.find_files { cwd = '/Users/pratyush/Websites/mapl-soft-org' }
end, { desc = '[S]earch [M]apl-soft files' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
-- Use CTRL+<hjkl> to switch between windows
-- `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
vim.keymap.set('n', '<C-S-h>', '<C-w>H', { desc = 'Move window to the left' })
vim.keymap.set('n', '<C-S-l>', '<C-w>L', { desc = 'Move window to the right' })
vim.keymap.set('n', '<C-S-j>', '<C-w>J', { desc = 'Move window to the lower' })
vim.keymap.set('n', '<C-S-k>', '<C-w>K', { desc = 'Move window to the upper' })

vim.keymap.set('n', '<leader>f', function()
  -- If there is only one window, open a vertical split
  if vim.fn.winnr() < 2 then
    vim.cmd 'vsp'
  else
    vim.cmd 'only'
  end
end, { desc = 'Make current window [F]ull (close others, or vsp if only one)' })

-- treewalker movement
-- https://github.com/aaronik/treewalker.nvim?tab=readme-ov-file#mapping
vim.keymap.set({ 'n', 'v' }, '[[', '<cmd>Treewalker Up<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, ']]', '<cmd>Treewalker Down<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '[a', '<cmd>Treewalker Left<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, ']a', '<cmd>Treewalker Right<cr>', { silent = true })

-- treewalker swapping
-- vim.keymap.set('n', '{{', '<cmd>Treewalker SwapUp<cr>', { silent = true })
-- vim.keymap.set('n', '}}', '<cmd>Treewalker SwapDown<cr>', { silent = true })
-- vim.keymap.set('n', '<C-S-h>', '<cmd>Treewalker SwapLeft<cr>', { silent = true })
-- vim.keymap.set('n', '<C-S-l>', '<cmd>Treewalker SwapRight<cr>', { silent = true })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- show currently working on whenever we open agenda window
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'orgagenda',
  callback = function(args)
    local orgmode_patches = require 'orgmode-patches'
    vim.keymap.set('n', '1', function()
      orgmode_patches.open_task_view 'T'
    end, { buffer = args.buf, silent = true, desc = 'Org tasks: clear filters' })
    vim.keymap.set('n', '2', function()
      orgmode_patches.open_task_view '2'
    end, { buffer = args.buf, silent = true, desc = 'Org tasks: due in next 6 weeks' })
    vim.keymap.set('n', '3', function()
      orgmode_patches.open_task_view '3'
    end, { buffer = args.buf, silent = true, desc = 'Org tasks: without deadline' })
    vim.keymap.set('n', 'A', function()
      orgmode_patches.add_current_task_to_today()
    end, { buffer = args.buf, silent = true, desc = 'Org tasks: add to today agenda' })

    local active = get_active_org_clock_title()
    if not active then
      return
    end
    vim.schedule(function()
      vim.notify('Working on: ' .. active, vim.log.levels.INFO, { title = 'Org Agenda' })
    end)
  end,
})

-- Add commands to disable and enable Conform if needed
vim.api.nvim_create_user_command('ConformDisable', function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = 'Disable autoformat-on-save',
  bang = true,
})

vim.api.nvim_create_user_command('ConformEnable', function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = 'Re-enable autoformat-on-save',
})

-- Treat .jrnl file as markdown
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.jrnl',
  callback = function()
    vim.bo.filetype = 'markdown'
  end,
})

-- -- The line beneath this is called `modeline`. See `:help modeline`
-- -- vim: ts=2 sts=2 sw=2 et
