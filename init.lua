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
  {
    'olimorris/onedarkpro.nvim',
    opts = {
      options = { cursorline = true },
    },
  },
  'rebelot/kanagawa.nvim',
  'folke/tokyonight.nvim',
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
  -- auto change to dark mode and light mode
  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      set_dark_mode = function()
        vim.cmd 'colorscheme onedark_dark'
      end,
      set_light_mode = function()
        vim.cmd 'colorscheme onelight'
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
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      -- RRethy/nvim-treesitter-endwise extension
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
  -- vim's lsp DOESN'T automatically install these, nor does it provide a way to install these
  {
    -- mason-lspconfig automatically installs the libraries we mention
    -- plus it automatically calls vim.lsp.enable() on them
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      -- check all available LSPs using `:Mason`
      { 'williamboman/mason.nvim', opts = {} },
      'neovim/nvim-lspconfig',
    },
    opts = {
      ensure_installed = {
        'biome',
        'cssls',
        'rust_analyzer',
        'emmet_language_server',
        'lua_ls',
        'ruff',
        'pyright',
        'ty',
        'yamlls',
        'astro',
        'docker_compose_language_service',
        'harper_ls',
      },
    },
  },
  -- highlight current word (under cursor) using LSP, tree-sitter
  -- https://github.com/RRethy/vim-illuminate
  'RRethy/vim-illuminate',
  -- snippets
  {
    'L3MON4D3/LuaSnip',
    build = 'make install_jsregexp',
    dependencies = {
      -- `friendly-snippets` contains a variety of premade snippets
      --    https://github.com/rafamadriz/friendly-snippets
      {
        'rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
    },
  },
  -- auto-completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- snippets
      'saadparwaiz1/cmp_luasnip',
      -- lsp
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      cmp.setup {
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'luasnip' },
        },
        -- `:help ins-completion`
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- Manually trigger a completion from nvim-cmp.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- move to next / prev param in snippets
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
      }
    end,
  },
  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
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
      }
      -- Enable extensions
      require('telescope').load_extension 'fzf'
    end,
  },
  -- GIT changes: `:help gitsigns`
  {
    'lewis6991/gitsigns.nvim',
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
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = { check_ts = true } },
  -- add quotes around selected text
  { 'echasnovski/mini.surround', version = false, opts = {} },
  -- auto close functions
  'RRethy/nvim-treesitter-endwise',
  -- configure jumps on [[, ]], ]m, [m - for all languages
  -- configured via textobjects in treesitter
  'nvim-treesitter/nvim-treesitter-textobjects',
  -- auto close tags in html
  { 'windwp/nvim-ts-autotag', opts = {} },
  -- multi cursor
  'mg979/vim-visual-multi',
  -- create file on :e
  'jessarcher/vim-heritage',
  -- managing files
  {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  },
  -- detect tab width automatically based on current file and editorconfig
  'tpope/vim-sleuth',
  -- show indent lines
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },
  -- auto format on save
  {
    'stevearc/conform.nvim',
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          -- we need to install these using :MasonInstall
          -- we have fallback for lsp below. Hence need these only when the lsp doesn't do formatting
          lua = { 'stylua' },
          -- Conform will run the first available formatter
          html = { 'prettierd', 'prettier', stop_after_first = true },
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
  -- make key-bindings easier to see
  {
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- Document existing key chains
      spec = {
        { '<leader>a', group = '[A]I' },
        { '<leader>b', group = '[B]uffer' },
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },
  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  -- better dialogs
  { 'stevearc/dressing.nvim', opts = {} },
  -- codecompanion for ai
  {
    'olimorris/codecompanion.nvim',
    -- branch = '*',
    opts = {
      prompt_library = require 'prompts',
      adapters = {
        openai = function()
          return require('codecompanion.adapters').extend('openai', {
            schema = {
              model = {
                -- default = 'o4-mini-2025-04-16',
                default = 'gpt-4.1-2025-04-14',
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = 'openai',
          tools = {
            opts = {
              auto_submit_errors = false, -- Send any errors to the LLM automatically?
              auto_submit_success = false, -- Send any successful output to the LLM automatically?
            },
          },
        },
        inline = {
          adapter = 'openai',
        },
        cmd = {
          adapter = 'openai',
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
    'nvim-lualine/lualine.nvim',
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
    'akinsho/toggleterm.nvim',
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
  { 'LunarVim/bigfile.nvim', opts = {} },
  -- retain layout on :bd
  'famiu/bufdelete.nvim',
  -- run tests
  'vim-test/vim-test',
  -- run code repl
  {
    'michaelb/sniprun',
    branch = 'master',
    build = 'sh install.sh',
    -- do 'sh install.sh 1' if you want to force compile locally
    -- (instead of fetching a binary from the github release). Requires Rust >= 1.65
    opts = {},
  },
  -- insert log lines automatically
  {
    'Goose97/timber.nvim',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    opts = {},
  },
  -- search and execute commands
  { 'doctorfree/cheatsheet.nvim', opts = { bundled_cheatsheets = { disabled = { 'nerd-fonts' } } } },
  -- lsp supported code completions in mardown and other embeds
  -- need to call :OtterActivate to enable
  { 'jmbuhr/otter.nvim', opts = {} },
  -- jumping between neighbours
  {
    'aaronik/treewalker.nvim',

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
}

-- LSP for linting, definition, references, symbols
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.lsp.config('ruff', { capabilities = capabilities, offset_encoding = 'utf-8' })
vim.lsp.config('pyright', {
  capabilities = capabilities,
  offset_encoding = 'utf-8',
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        ignore = { '*' },
      },
    },
  },
})
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
vim.lsp.config('emmet_language_server', { capabilities = capabilities })
vim.lsp.config('astro', { capabilities = capabilities })
vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
    },
  },
})
vim.lsp.config('docker_compose_language_service', { capabilities = capabilities })

vim.lsp.config('ty', { capabilities = capabilities, offset_encoding = 'utf-8' })
vim.lsp.config('harper_ls', {
  capabilities = capabilities,
  filetypes = {
    'gitcommit',
    'html',
    'htmldjango',
    'javascript',
    'lua',
    'markdown',
    'python',
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
vim.opt.termguicolors = true -- enable true colors
-- vim.cmd 'colorscheme onelight'

-- Use rounded borders for all floating windows (new in Neovim 0.11)
vim.o.winborder = 'rounded'

-- disable autoinsert of first option in menus
vim.o.completeopt = 'menuone,popup,noinsert'

vim.cmd 'colorscheme onedark_dark'

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- hide mode as already shown in lualine
vim.opt.showmode = false
-- -- [[ Setting options ]]
-- -- See `:help vim.o`
-- -- NOTE: You can change these options as you wish!
-- --  For more options, you can see `:help option-list`
--
-- -- Make line numbers default
-- vim.o.number = true
-- -- You can also add relative line numbers, to help with jumping.
-- --  Experiment for yourself to see if you like it!
-- -- vim.o.relativenumber = true
--
-- -- Enable mouse mode, can be useful for resizing splits for example!
-- vim.o.mouse = 'a'
--
-- -- Don't show the mode, since it's already in the status line
-- vim.o.showmode = false

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

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

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
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevelstart = 99

-- KEY BINDINGS
-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- changing buffers
vim.keymap.set('n', '<leader>bp', ':bp<CR>', { desc = '[B]uffer [P]revious' })
vim.keymap.set('n', '<leader>bn', ':bn<CR>', { desc = '[B]uffer [N]ext' })
vim.keymap.set('n', '<leader>bd', ':Bdelete<CR>', { desc = '[B]uffer [D]elete' })

-- ai codecompanion
vim.keymap.set({ 'n', 'v' }, '<leader>aa', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true, desc = '[A]ctions' })
vim.keymap.set({ 'n', 'v' }, '<leader>ac', '<cmd>CodeCompanionChat<cr>', { noremap = true, silent = true, desc = '[C]hat' })
vim.keymap.set({ 'n', 'v' }, '<leader>at', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true, desc = '[T]oggle' })
vim.keymap.set({ 'n', 'v' }, '<leader>ae', ":'<,'>CodeCompanion #buffer ", { noremap = true, silent = true, desc = '[E]dit' })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd [[cab cc CodeCompanion]]

-- run tests easily
vim.keymap.set('n', '<leader>t', ':TestNearest<CR>', { desc = '[T]est nearest' })
vim.g['test#python#djangotest#options'] = '--keepdb --settings=$DJANGO_TEST_SETTINGS'

-- run replt
vim.api.nvim_set_keymap('v', '<leader>x', '<Plug>SnipRun', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>x', '<Plug>SnipRun', { silent = true })

-- LSP keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    -- -- new lsp autocompletion supported natively in neovim
    -- local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- if client:supports_method('textDocument/completion') then
    --   vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    -- end
    -- Jump to the definition of the word under your cursor.
    --  To jump back, press <C-t>.
    vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, { desc = '[G]oto [D]efinition' })
    -- Find references for the word under your cursor.
    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { desc = '[G]oto [R]eferences' })
    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[R]e[n]ame' })
    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    vim.keymap.set({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, { desc = '[C]ode [A]ction' })
  end,
})

-- Git keymaps
-- :help gitsigns
vim.keymap.set('n', ']e', ':Gitsigns next_hunk<CR>', { desc = 'Jump to next git [e]dit' })
vim.keymap.set('n', '[e', ':Gitsigns prev_hunk<CR>', { desc = 'Jump to prev git [e]dit' })
vim.keymap.set({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', { desc = 'git [s]tage hunk' })
vim.keymap.set({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', { desc = 'git [r]eset hunk' })
vim.keymap.set({ 'n', 'v' }, '<leader>hd', ':Gitsigns diffthis<CR>', { desc = 'git [d]iff against index' })
vim.keymap.set({ 'n', 'v' }, '<leader>hp', ':Gitsigns preview_hunk<CR>', { desc = 'git [p]review hunk' })
vim.keymap.set({ 'n', 'v' }, '<leader>hb', ':Gitsigns blame_line<CR>', { desc = 'git [b]lame line' })

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
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

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
-- -- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- -- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- -- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- -- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- -- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

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
-- end
--
-- ---@type vim.Option
-- local rtp = vim.opt.rtp
-- rtp:prepend(lazypath)
--
-- -- [[ Configure and install plugins ]]
-- --
-- --  To check the current status of your plugins, run
-- --    :Lazy
-- --
-- --  You can press `?` in this menu for help. Use `:q` to close the window
-- --
-- --  To update plugins you can run
-- --    :Lazy update
-- --
-- -- NOTE: Here is where you install your plugins.
-- require('lazy').setup({
--   -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
--   'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically
--
--   -- NOTE: Plugins can also be added by using a table,
--   -- with the first argument being the link and the following
--   -- keys can be used to configure plugin behavior/loading/etc.
--   --
--   -- Use `opts = {}` to automatically pass options to a plugin's `setup()` function, forcing the plugin to be loaded.
--   --
--
--   -- Alternatively, use `config = function() ... end` for full control over the configuration.
--   -- If you prefer to call `setup` explicitly, use:
--   --    {
--   --        'lewis6991/gitsigns.nvim',
--   --        config = function()
--   --            require('gitsigns').setup({
--   --                -- Your gitsigns configuration here
--   --            })
--   --        end,
--   --    }
--   --
--   -- Here is a more advanced example where we pass configuration
--   -- options to `gitsigns.nvim`.
--   --
--   -- See `:help gitsigns` to understand what the configuration keys do
--   { -- Adds git related signs to the gutter, as well as utilities for managing changes
--     'lewis6991/gitsigns.nvim',
--     opts = {
--       signs = {
--         add = { text = '+' },
--         change = { text = '~' },
--         delete = { text = '_' },
--         topdelete = { text = '‾' },
--         changedelete = { text = '~' },
--       },
--     },
--   },
--
--   -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
--   --
--   -- This is often very useful to both group configuration, as well as handle
--   -- lazy loading plugins that don't need to be loaded immediately at startup.
--   --
--   -- For example, in the following configuration, we use:
--   --  event = 'VimEnter'
--   --
--   -- which loads which-key before all the UI elements are loaded. Events can be
--   -- normal autocommands events (`:help autocmd-events`).
--   --
--   -- Then, because we use the `opts` key (recommended), the configuration runs
--   -- after the plugin has been loaded as `require(MODULE).setup(opts)`.
--
--   { -- Useful plugin to show you pending keybinds.
--     'folke/which-key.nvim',
--     event = 'VimEnter', -- Sets the loading event to 'VimEnter'
--     opts = {
--       -- delay between pressing a key and opening which-key (milliseconds)
--       -- this setting is independent of vim.o.timeoutlen
--       delay = 0,
--       icons = {
--         -- set icon mappings to true if you have a Nerd Font
--         mappings = vim.g.have_nerd_font,
--         -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
--         -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
--         keys = vim.g.have_nerd_font and {} or {
--           Up = '<Up> ',
--           Down = '<Down> ',
--           Left = '<Left> ',
--           Right = '<Right> ',
--           C = '<C-…> ',
--           M = '<M-…> ',
--           D = '<D-…> ',
--           S = '<S-…> ',
--           CR = '<CR> ',
--           Esc = '<Esc> ',
--           ScrollWheelDown = '<ScrollWheelDown> ',
--           ScrollWheelUp = '<ScrollWheelUp> ',
--           NL = '<NL> ',
--           BS = '<BS> ',
--           Space = '<Space> ',
--           Tab = '<Tab> ',
--           F1 = '<F1>',
--           F2 = '<F2>',
--           F3 = '<F3>',
--           F4 = '<F4>',
--           F5 = '<F5>',
--           F6 = '<F6>',
--           F7 = '<F7>',
--           F8 = '<F8>',
--           F9 = '<F9>',
--           F10 = '<F10>',
--           F11 = '<F11>',
--           F12 = '<F12>',
--         },
--       },
--
--       -- Document existing key chains
--       spec = {
--         { '<leader>s', group = '[S]earch' },
--         { '<leader>t', group = '[T]oggle' },
--         { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
--       },
--     },
--   },
--
--   -- NOTE: Plugins can specify dependencies.
--   --
--   -- The dependencies are proper plugin specifications as well - anything
--   -- you do for a plugin at the top level, you can do for a dependency.
--   --
--   -- Use the `dependencies` key to specify the dependencies of a particular plugin
--
--   { -- Fuzzy Finder (files, lsp, etc)
--     'nvim-telescope/telescope.nvim',
--     event = 'VimEnter',
--     dependencies = {
--       'nvim-lua/plenary.nvim',
--       { -- If encountering errors, see telescope-fzf-native README for installation instructions
--         'nvim-telescope/telescope-fzf-native.nvim',
--
--         -- `build` is used to run some command when the plugin is installed/updated.
--         -- This is only run then, not every time Neovim starts up.
--         build = 'make',
--
--         -- `cond` is a condition used to determine whether this plugin should be
--         -- installed and loaded.
--         cond = function()
--           return vim.fn.executable 'make' == 1
--         end,
--       },
--       { 'nvim-telescope/telescope-ui-select.nvim' },
--
--       -- Useful for getting pretty icons, but requires a Nerd Font.
--       { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
--     },
--     config = function()
--       -- Telescope is a fuzzy finder that comes with a lot of different things that
--       -- it can fuzzy find! It's more than just a "file finder", it can search
--       -- many different aspects of Neovim, your workspace, LSP, and more!
--       --
--       -- The easiest way to use Telescope, is to start by doing something like:
--       --  :Telescope help_tags
--       --
--       -- After running this command, a window will open up and you're able to
--       -- type in the prompt window. You'll see a list of `help_tags` options and
--       -- a corresponding preview of the help.
--       --
--       -- Two important keymaps to use while in Telescope are:
--       --  - Insert mode: <c-/>
--       --  - Normal mode: ?
--       --
--       -- This opens a window that shows you all of the keymaps for the current
--       -- Telescope picker. This is really useful to discover what Telescope can
--       -- do as well as how to actually do it!
--
--       -- [[ Configure Telescope ]]
--       -- See `:help telescope` and `:help telescope.setup()`
--       require('telescope').setup {
--         -- You can put your default mappings / updates / etc. in here
--         --  All the info you're looking for is in `:help telescope.setup()`
--         --
--         -- defaults = {
--         --   mappings = {
--         --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
--         --   },
--         -- },
--         -- pickers = {}
--         extensions = {
--           ['ui-select'] = {
--             require('telescope.themes').get_dropdown(),
--           },
--         },
--       }
--
--       -- Enable Telescope extensions if they are installed
--       pcall(require('telescope').load_extension, 'fzf')
--       pcall(require('telescope').load_extension, 'ui-select')
--
--       -- See `:help telescope.builtin`
--       local builtin = require 'telescope.builtin'
--       vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
--       vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
--       vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
--       vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
--       vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
--       vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
--       vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
--       vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
--       vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
--       vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
--
--       -- Slightly advanced example of overriding default behavior and theme
--       vim.keymap.set('n', '<leader>/', function()
--         -- You can pass additional configuration to Telescope to change the theme, layout, etc.
--         builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
--           winblend = 10,
--           previewer = false,
--         })
--       end, { desc = '[/] Fuzzily search in current buffer' })
--
--       -- It's also possible to pass additional configuration options.
--       --  See `:help telescope.builtin.live_grep()` for information about particular keys
--       vim.keymap.set('n', '<leader>s/', function()
--         builtin.live_grep {
--           grep_open_files = true,
--           prompt_title = 'Live Grep in Open Files',
--         }
--       end, { desc = '[S]earch [/] in Open Files' })
--
--       -- Shortcut for searching your Neovim configuration files
--       vim.keymap.set('n', '<leader>sn', function()
--         builtin.find_files { cwd = vim.fn.stdpath 'config' }
--       end, { desc = '[S]earch [N]eovim files' })
--     end,
--   },
--
--   -- LSP Plugins
--   {
--     -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
--     -- used for completion, annotations and signatures of Neovim apis
--     'folke/lazydev.nvim',
--     ft = 'lua',
--     opts = {
--       library = {
--         -- Load luvit types when the `vim.uv` word is found
--         { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
--       },
--     },
--   },
--   {
--     -- Main LSP Configuration
--     'neovim/nvim-lspconfig',
--     dependencies = {
--       -- Automatically install LSPs and related tools to stdpath for Neovim
--       -- Mason must be loaded before its dependents so we need to set it up here.
--       -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
--       { 'mason-org/mason.nvim', opts = {} },
--       'mason-org/mason-lspconfig.nvim',
--       'WhoIsSethDaniel/mason-tool-installer.nvim',
--
--       -- Useful status updates for LSP.
--       { 'j-hui/fidget.nvim', opts = {} },
--
--       -- Allows extra capabilities provided by blink.cmp
--       'saghen/blink.cmp',
--     },
--     config = function()
--       -- Brief aside: **What is LSP?**
--       --
--       -- LSP is an initialism you've probably heard, but might not understand what it is.
--       --
--       -- LSP stands for Language Server Protocol. It's a protocol that helps editors
--       -- and language tooling communicate in a standardized fashion.
--       --
--       -- In general, you have a "server" which is some tool built to understand a particular
--       -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
--       -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
--       -- processes that communicate with some "client" - in this case, Neovim!
--       --
--       -- LSP provides Neovim with features like:
--       --  - Go to definition
--       --  - Find references
--       --  - Autocompletion
--       --  - Symbol Search
--       --  - and more!
--       --
--       -- Thus, Language Servers are external tools that must be installed separately from
--       -- Neovim. This is where `mason` and related plugins come into play.
--       --
--       -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
--       -- and elegantly composed help section, `:help lsp-vs-treesitter`
--
--       --  This function gets run when an LSP attaches to a particular buffer.
--       --    That is to say, every time a new file is opened that is associated with
--       --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
--       --    function will be executed to configure the current buffer
--       vim.api.nvim_create_autocmd('LspAttach', {
--         group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
--         callback = function(event)
--           -- NOTE: Remember that Lua is a real programming language, and as such it is possible
--           -- to define small helper and utility functions so you don't have to repeat yourself.
--           --
--           -- In this case, we create a function that lets us more easily define mappings specific
--           -- for LSP related items. It sets the mode, buffer and description for us each time.
--           local map = function(keys, func, desc, mode)
--             mode = mode or 'n'
--             vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
--           end
--
--           -- Rename the variable under your cursor.
--           --  Most Language Servers support renaming across files, etc.
--           map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
--
--           -- Execute a code action, usually your cursor needs to be on top of an error
--           -- or a suggestion from your LSP for this to activate.
--           map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
--
--           -- Find references for the word under your cursor.
--           map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
--
--           -- Jump to the implementation of the word under your cursor.
--           --  Useful when your language has ways of declaring types without an actual implementation.
--           map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
--
--           -- Jump to the definition of the word under your cursor.
--           --  This is where a variable was first declared, or where a function is defined, etc.
--           --  To jump back, press <C-t>.
--           map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
--
--           -- WARN: This is not Goto Definition, this is Goto Declaration.
--           --  For example, in C this would take you to the header.
--           map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
--
--           -- Fuzzy find all the symbols in your current document.
--           --  Symbols are things like variables, functions, types, etc.
--           map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
--
--           -- Fuzzy find all the symbols in your current workspace.
--           --  Similar to document symbols, except searches over your entire project.
--           map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
--
--           -- Jump to the type of the word under your cursor.
--           --  Useful when you're not sure what type a variable is and you want to see
--           --  the definition of its *type*, not where it was *defined*.
--           map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')
--
--           -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
--           ---@param client vim.lsp.Client
--           ---@param method vim.lsp.protocol.Method
--           ---@param bufnr? integer some lsp support methods only in specific files
--           ---@return boolean
--           local function client_supports_method(client, method, bufnr)
--             if vim.fn.has 'nvim-0.11' == 1 then
--               return client:supports_method(method, bufnr)
--             else
--               return client.supports_method(method, { bufnr = bufnr })
--             end
--           end
--
--           -- The following two autocommands are used to highlight references of the
--           -- word under your cursor when your cursor rests there for a little while.
--           --    See `:help CursorHold` for information about when this is executed
--           --
--           -- When you move your cursor, the highlights will be cleared (the second autocommand).
--           local client = vim.lsp.get_client_by_id(event.data.client_id)
--           if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
--             local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
--             vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
--               buffer = event.buf,
--               group = highlight_augroup,
--               callback = vim.lsp.buf.document_highlight,
--             })
--
--             vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
--               buffer = event.buf,
--               group = highlight_augroup,
--               callback = vim.lsp.buf.clear_references,
--             })
--
--             vim.api.nvim_create_autocmd('LspDetach', {
--               group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
--               callback = function(event2)
--                 vim.lsp.buf.clear_references()
--                 vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
--               end,
--             })
--           end
--
--           -- The following code creates a keymap to toggle inlay hints in your
--           -- code, if the language server you are using supports them
--           --
--           -- This may be unwanted, since they displace some of your code
--           if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
--             map('<leader>th', function()
--               vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
--             end, '[T]oggle Inlay [H]ints')
--           end
--         end,
--       })
--
--       -- Diagnostic Config
--       -- See :help vim.diagnostic.Opts
--       vim.diagnostic.config {
--         severity_sort = true,
--         float = { border = 'rounded', source = 'if_many' },
--         underline = { severity = vim.diagnostic.severity.ERROR },
--         signs = vim.g.have_nerd_font and {
--           text = {
--             [vim.diagnostic.severity.ERROR] = '󰅚 ',
--             [vim.diagnostic.severity.WARN] = '󰀪 ',
--             [vim.diagnostic.severity.INFO] = '󰋽 ',
--             [vim.diagnostic.severity.HINT] = '󰌶 ',
--           },
--         } or {},
--         virtual_text = {
--           source = 'if_many',
--           spacing = 2,
--           format = function(diagnostic)
--             local diagnostic_message = {
--               [vim.diagnostic.severity.ERROR] = diagnostic.message,
--               [vim.diagnostic.severity.WARN] = diagnostic.message,
--               [vim.diagnostic.severity.INFO] = diagnostic.message,
--               [vim.diagnostic.severity.HINT] = diagnostic.message,
--             }
--             return diagnostic_message[diagnostic.severity]
--           end,
--         },
--       }
--
--       -- LSP servers and clients are able to communicate to each other what features they support.
--       --  By default, Neovim doesn't support everything that is in the LSP specification.
--       --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
--       --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
--       local capabilities = require('blink.cmp').get_lsp_capabilities()
--
--       -- Enable the following language servers
--       --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--       --
--       --  Add any additional override configuration in the following tables. Available keys are:
--       --  - cmd (table): Override the default command used to start the server
--       --  - filetypes (table): Override the default list of associated filetypes for the server
--       --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
--       --  - settings (table): Override the default settings passed when initializing the server.
--       --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
--       local servers = {
--         -- clangd = {},
--         -- gopls = {},
--         -- pyright = {},
--         -- rust_analyzer = {},
--         -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
--         --
--         -- Some languages (like typescript) have entire language plugins that can be useful:
--         --    https://github.com/pmizio/typescript-tools.nvim
--         --
--         -- But for many setups, the LSP (`ts_ls`) will work just fine
--         -- ts_ls = {},
--         --
--
--         lua_ls = {
--           -- cmd = { ... },
--           -- filetypes = { ... },
--           -- capabilities = {},
--           settings = {
--             Lua = {
--               completion = {
--                 callSnippet = 'Replace',
--               },
--               -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
--               -- diagnostics = { disable = { 'missing-fields' } },
--             },
--           },
--         },
--       }
--
--       -- Ensure the servers and tools above are installed
--       --
--       -- To check the current status of installed tools and/or manually install
--       -- other tools, you can run
--       --    :Mason
--       --
--       -- You can press `g?` for help in this menu.
--       --
--       -- `mason` had to be setup earlier: to configure its options see the
--       -- `dependencies` table for `nvim-lspconfig` above.
--       --
--       -- You can add other tools here that you want Mason to install
--       -- for you, so that they are available from within Neovim.
--       local ensure_installed = vim.tbl_keys(servers or {})
--       vim.list_extend(ensure_installed, {
--         'stylua', -- Used to format Lua code
--       })
--       require('mason-tool-installer').setup { ensure_installed = ensure_installed }
--
--       require('mason-lspconfig').setup {
--         ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
--         automatic_installation = false,
--         handlers = {
--           function(server_name)
--             local server = servers[server_name] or {}
--             -- This handles overriding only values explicitly passed
--             -- by the server configuration above. Useful when disabling
--             -- certain features of an LSP (for example, turning off formatting for ts_ls)
--             server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
--             require('lspconfig')[server_name].setup(server)
--           end,
--         },
--       }
--     end,
--   },
--
--   { -- Autoformat
--     'stevearc/conform.nvim',
--     event = { 'BufWritePre' },
--     cmd = { 'ConformInfo' },
--     keys = {
--       {
--         '<leader>f',
--         function()
--           require('conform').format { async = true, lsp_format = 'fallback' }
--         end,
--         mode = '',
--         desc = '[F]ormat buffer',
--       },
--     },
--     opts = {
--       notify_on_error = false,
--       format_on_save = function(bufnr)
--         -- Disable "format_on_save lsp_fallback" for languages that don't
--         -- have a well standardized coding style. You can add additional
--         -- languages here or re-enable it for the disabled ones.
--         local disable_filetypes = { c = true, cpp = true }
--         if disable_filetypes[vim.bo[bufnr].filetype] then
--           return nil
--         else
--           return {
--             timeout_ms = 500,
--             lsp_format = 'fallback',
--           }
--         end
--       end,
--       formatters_by_ft = {
--         lua = { 'stylua' },
--         -- Conform can also run multiple formatters sequentially
--         -- python = { "isort", "black" },
--         --
--         -- You can use 'stop_after_first' to run the first available formatter from the list
--         -- javascript = { "prettierd", "prettier", stop_after_first = true },
--       },
--     },
--   },
--
--   { -- Autocompletion
--     'saghen/blink.cmp',
--     event = 'VimEnter',
--     version = '1.*',
--     dependencies = {
--       -- Snippet Engine
--       {
--         'L3MON4D3/LuaSnip',
--         version = '2.*',
--         build = (function()
--           -- Build Step is needed for regex support in snippets.
--           -- This step is not supported in many windows environments.
--           -- Remove the below condition to re-enable on windows.
--           if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
--             return
--           end
--           return 'make install_jsregexp'
--         end)(),
--         dependencies = {
--           -- `friendly-snippets` contains a variety of premade snippets.
--           --    See the README about individual language/framework/plugin snippets:
--           --    https://github.com/rafamadriz/friendly-snippets
--           -- {
--           --   'rafamadriz/friendly-snippets',
--           --   config = function()
--           --     require('luasnip.loaders.from_vscode').lazy_load()
--           --   end,
--           -- },
--         },
--         opts = {},
--       },
--       'folke/lazydev.nvim',
--     },
--     --- @module 'blink.cmp'
--     --- @type blink.cmp.Config
--     opts = {
--       keymap = {
--         -- 'default' (recommended) for mappings similar to built-in completions
--         --   <c-y> to accept ([y]es) the completion.
--         --    This will auto-import if your LSP supports it.
--         --    This will expand snippets if the LSP sent a snippet.
--         -- 'super-tab' for tab to accept
--         -- 'enter' for enter to accept
--         -- 'none' for no mappings
--         --
--         -- For an understanding of why the 'default' preset is recommended,
--         -- you will need to read `:help ins-completion`
--         --
--         -- No, but seriously. Please read `:help ins-completion`, it is really good!
--         --
--         -- All presets have the following mappings:
--         -- <tab>/<s-tab>: move to right/left of your snippet expansion
--         -- <c-space>: Open menu or open docs if already open
--         -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
--         -- <c-e>: Hide menu
--         -- <c-k>: Toggle signature help
--         --
--         -- See :h blink-cmp-config-keymap for defining your own keymap
--         preset = 'default',
--
--         -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
--         --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
--       },
--
--       appearance = {
--         -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
--         -- Adjusts spacing to ensure icons are aligned
--         nerd_font_variant = 'mono',
--       },
--
--       completion = {
--         -- By default, you may press `<c-space>` to show the documentation.
--         -- Optionally, set `auto_show = true` to show the documentation after a delay.
--         documentation = { auto_show = false, auto_show_delay_ms = 500 },
--       },
--
--       sources = {
--         default = { 'lsp', 'path', 'snippets', 'lazydev' },
--         providers = {
--           lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
--         },
--       },
--
--       snippets = { preset = 'luasnip' },
--
--       -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
--       -- which automatically downloads a prebuilt binary when enabled.
--       --
--       -- By default, we use the Lua implementation instead, but you may enable
--       -- the rust implementation via `'prefer_rust_with_warning'`
--       --
--       -- See :h blink-cmp-config-fuzzy for more information
--       fuzzy = { implementation = 'lua' },
--
--       -- Shows a signature help window while you type arguments for a function
--       signature = { enabled = true },
--     },
--   },
--
--   { -- You can easily change to a different colorscheme.
--     -- Change the name of the colorscheme plugin below, and then
--     -- change the command in the config to whatever the name of that colorscheme is.
--     --
--     -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
--     'folke/tokyonight.nvim',
--     priority = 1000, -- Make sure to load this before all the other start plugins.
--     config = function()
--       ---@diagnostic disable-next-line: missing-fields
--       require('tokyonight').setup {
--         styles = {
--           comments = { italic = false }, -- Disable italics in comments
--         },
--       }
--
--       -- Load the colorscheme here.
--       -- Like many other themes, this one has different styles, and you could load
--       -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
--       vim.cmd.colorscheme 'tokyonight-night'
--     end,
--   },
--
--   -- Highlight todo, notes, etc in comments
--   { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
--
--   { -- Collection of various small independent plugins/modules
--     'echasnovski/mini.nvim',
--     config = function()
--       -- Better Around/Inside textobjects
--       --
--       -- Examples:
--       --  - va)  - [V]isually select [A]round [)]paren
--       --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
--       --  - ci'  - [C]hange [I]nside [']quote
--       require('mini.ai').setup { n_lines = 500 }
--
--       -- Add/delete/replace surroundings (brackets, quotes, etc.)
--       --
--       -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
--       -- - sd'   - [S]urround [D]elete [']quotes
--       -- - sr)'  - [S]urround [R]eplace [)] [']
--       require('mini.surround').setup()
--
--       -- Simple and easy statusline.
--       --  You could remove this setup call if you don't like it,
--       --  and try some other statusline plugin
--       local statusline = require 'mini.statusline'
--       -- set use_icons to true if you have a Nerd Font
--       statusline.setup { use_icons = vim.g.have_nerd_font }
--
--       -- You can configure sections in the statusline by overriding their
--       -- default behavior. For example, here we set the section for
--       -- cursor location to LINE:COLUMN
--       ---@diagnostic disable-next-line: duplicate-set-field
--       statusline.section_location = function()
--         return '%2l:%-2v'
--       end
--
--       -- ... and there is more!
--       --  Check out: https://github.com/echasnovski/mini.nvim
--     end,
--   },
--   { -- Highlight, edit, and navigate code
--     'nvim-treesitter/nvim-treesitter',
--     build = ':TSUpdate',
--     main = 'nvim-treesitter.configs', -- Sets main module to use for opts
--     -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
--     opts = {
--       ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
--       -- Autoinstall languages that are not installed
--       auto_install = true,
--       highlight = {
--         enable = true,
--         -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
--         --  If you are experiencing weird indenting issues, add the language to
--         --  the list of additional_vim_regex_highlighting and disabled languages for indent.
--         additional_vim_regex_highlighting = { 'ruby' },
--       },
--       indent = { enable = true, disable = { 'ruby' } },
--     },
--     -- There are additional nvim-treesitter modules that you can use to interact
--     -- with nvim-treesitter. You should go explore a few and see what interests you:
--     --
--     --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
--     --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
--     --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
--   },
--
--   -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
--   -- init.lua. If you want these files, they are in the repository, so you can just download them and
--   -- place them in the correct locations.
--
--   -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
--   --
--   --  Here are some example plugins that I've included in the Kickstart repository.
--   --  Uncomment any of the lines below to enable them (you will need to restart nvim).
--   --
--   -- require 'kickstart.plugins.debug',
--   -- require 'kickstart.plugins.indent_line',
--   -- require 'kickstart.plugins.lint',
--   -- require 'kickstart.plugins.autopairs',
--   -- require 'kickstart.plugins.neo-tree',
--   -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps
--
--   -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
--   --    This is the easiest way to modularize your config.
--   --
--   --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
--   -- { import = 'custom.plugins' },
--   --
--   -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
--   -- Or use telescope!
--   -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
--   -- you can continue same window with `<space>sr` which resumes last telescope search
-- }, {
--   ui = {
--     -- If you are using a Nerd Font: set icons to an empty table which will use the
--     -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
--     icons = vim.g.have_nerd_font and {} or {
--       cmd = '⌘',
--       config = '🛠',
--       event = '📅',
--       ft = '📂',
--       init = '⚙',
--       keys = '🗝',
--       plugin = '🔌',
--       runtime = '💻',
--       require = '🌙',
--       source = '📄',
--       start = '🚀',
--       task = '📌',
--       lazy = '💤 ',
--     },
--   },
})

vim.api.nvim_create_user_command('ConformEnable', function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = 'Re-enable autoformat-on-save',
})

-- -- The line beneath this is called `modeline`. See `:help modeline`
-- -- vim: ts=2 sts=2 sw=2 et
