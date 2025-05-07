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
  'olimorris/onedarkpro.nvim',
  "rebelot/kanagawa.nvim",
  'folke/tokyonight.nvim',
  { 'catppuccin/nvim',                         name = 'catppuccin',     priority = 1000 },
  -- auto change to dark mode and light mode
  { "f-person/auto-dark-mode.nvim", opts = {
    set_dark_mode = function()
      vim.cmd 'colorscheme onedark_dark'
    end,
    set_light_mode = function()
      vim.cmd 'colorscheme onelight'
    end,
  } },
  {
    -- syntax highlighting
    -- https://github.com/nvim-treesitter/nvim-treesitter
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
      ensure_installed = { 'bash', 'c', 'comment', 'diff', 'html', 'lua', 'luap', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'python', 'elixir' },
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
            ["]c"] = "@class.outer",
            -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects?tab=readme-ov-file#built-in-textobjects
            -- ["]]"] = "@function.outer",
          },
          goto_previous_start = {
            -- ["[["] = "@function.outer",
            ["[c"] = "@class.outer",
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
      "neovim/nvim-lspconfig",
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
        'yamlls',
        'astro',
        'docker_compose_language_service',
      },
    }
  },
  -- highlight current word using LSP, tree-sitter
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
        window = {
          completion = cmp.config.window.bordered {
            winhighlight = 'Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None',
            winblend = 0, -- Make completion window opaque
          },
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
  { 'windwp/nvim-autopairs',     event = 'InsertEnter', opts = { check_ts = true } },
  -- add quotes around selected text
  { 'echasnovski/mini.surround', version = false,       opts = {} },
  -- auto close functions
  'RRethy/nvim-treesitter-endwise',
  -- configure jumps on [[, ]], ]m, [m - for all languages
  -- configured via textobjects in treesitter
  'nvim-treesitter/nvim-treesitter-textobjects',
  -- auto close tags in html
  { 'windwp/nvim-ts-autotag',              opts = {} },
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
        { '<leader>c', group = '[C]ode',     mode = { 'n', 'x' } },
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
  { 'stevearc/dressing.nvim',   opts = {} },
  -- codecompanion for ai
  {
    'pratyushmittal/codecompanion.nvim',
    branch = "diff-update",
    opts = {
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
        },
        inline = {
          adapter = 'openai',
        },
        cmd = {
          adapter = 'openai',
        },
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
  { 'LunarVim/bigfile.nvim',     opts = {} },
  -- retain layout on :bd
  'famiu/bufdelete.nvim',
  -- jumping cursor animation
  { 'sphamba/smear-cursor.nvim', opts = {} },
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
    "Goose97/timber.nvim",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {},
  },
  -- search and execute commands
  { 'doctorfree/cheatsheet.nvim', opts = { bundled_cheatsheets = { disabled = { 'nerd-fonts' } } } },
  -- lsp supported code completions in mardown and other embeds
  -- need to call :OtterActivate to enable
  { 'jmbuhr/otter.nvim',          opts = {} },
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
    }
  },
}


-- LSP
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

vim.lsp.config("cssls", {
  capabilities = capabilities,
  settings = {
    -- we can check all properties by doing :Mason, select tool, "LSP server configuration schema"
    css = {
      lint = { duplicateProperties = 'warning' },
    },
  },
})
vim.lsp.config("yamlls", { capabilities = capabilities })
vim.lsp.config("biome", { capabilities = capabilities })
vim.lsp.config("emmet_language_server", { capabilities = capabilities })
vim.lsp.config("astro", { capabilities = capabilities })
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
    },
  },
})
vim.lsp.config("docker_compose_language_service", { capabilities = capabilities })


-- show diagnostic errors inline
vim.diagnostic.config({
  -- Use the default configuration
  virtual_lines = true

  -- Alternatively, customize specific options
  -- virtual_lines = {
  --  -- Only show virtual line diagnostics for the current cursor line
  --  current_line = true,
  -- },
})

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
vim.cmd 'colorscheme onedark_dark'

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- hide mode as already shown in lualine
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- wrapped lines have same indent
vim.opt.breakindent = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Decrease the auto-save time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
-- :vsplit should open split on right
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 3

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
vim.keymap.set({ 'n', 'v' }, '<leader>aa', '<cmd>CodeCompanionActions<cr>',
  { noremap = true, silent = true, desc = '[A]ctions' })
vim.keymap.set({ 'n', 'v' }, '<leader>at', '<cmd>CodeCompanionChat Toggle<cr>',
  { noremap = true, silent = true, desc = '[T]oggle' })
vim.keymap.set({ 'n', 'v' }, '<leader>ae', ":'<,'>CodeCompanion #buffer ",
  { noremap = true, silent = true, desc = '[E]dit' })

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
  callback = function()
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

-- Toggle between equal window sizes and full-width
local window_state = 'equal'
vim.keymap.set('n', '<leader>f', function()
  if window_state == 'equal' then
    vim.cmd 'wincmd |' -- Make window full-width
    window_state = 'full'
  else
    vim.cmd 'wincmd =' -- Make windows equal size
    window_state = 'equal'
  end
end, { desc = 'Toggle [F]ull Screen' })

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
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
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

-- -- The line beneath this is called `modeline`. See `:help modeline`
-- -- vim: ts=2 sts=2 sw=2 et
