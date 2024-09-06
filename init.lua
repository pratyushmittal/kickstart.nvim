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

-- -- Intro to Lazy
-- require('lazy').setup {
--   'loctvl842/monokai-pro.nvim',
-- }
--
-- require('monokai-pro').setup { filter = 'spectrum' }
-- vim.cmd.colorscheme 'monokai-pro'

-- Use Lazy
-- Setup lazy.nvim
require('lazy').setup {
  -- color theme
  -- https://github.com/loctvl842/monokai-pro.nvim
  {
    'loctvl842/monokai-pro.nvim',
    lazy = false,
    priority = 1000,
    opts = { filter = 'spectrum' },
    init = function()
      vim.cmd.colorscheme 'monokai-pro'
    end,
  },
  {
    -- syntax highlighting
    -- https://github.com/nvim-treesitter/nvim-treesitter
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'python', 'elixir' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      -- RRethy/nvim-treesitter-endwise extension
      endwise = { enable = true },
    },
  },
  -- show current method or class name when scrolling
  -- https://github.com/nvim-treesitter/nvim-treesitter-context
  { 'nvim-treesitter/nvim-treesitter-context', opts = { max_lines = 1 } },
  -- LSP for linting, definition, references, symbols
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- check all available LSPs using `:Mason`
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      local lspconfig = require 'lspconfig'
      lspconfig.pyright.setup {}

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- local capabilities = require('cmp_nvim_lsp').default_capabilities()
      lspconfig.ruff.setup { capabilities = capabilities }
      lspconfig.cssls.setup { capabilities = capabilities }
      lspconfig.emmet_language_server.setup { capabilities = capabilities }
      lspconfig.lua_ls.setup {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
          },
        },
      }
    end,
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
          { name = 'luasnip' },
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
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
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },
  -- add quotes around selected text
  { 'echasnovski/mini.surround', version = false, opts = {} },
  -- auto close functions
  'RRethy/nvim-treesitter-endwise',
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
          lua = { 'stylua' },
          -- You can customize some of the format options for the filetype (:help conform.format)
          rust = { 'rustfmt', lsp_format = 'fallback' },
          -- Conform will run the first available formatter
          javascript = { 'prettierd', 'prettier', stop_after_first = true },
        },
        -- enable format on save
        format_on_save = {
          -- These options will be passed to conform.format()
          timeout_ms = 500,
          lsp_format = 'fallback',
        },
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
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },
  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  -- avante for AI
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    opts = {
      silent_warning = true,
      skip_warning = true,
      support_paste_image = false,
      paste_image = false,
    },
    dependencies = {
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      {
        -- Make sure to setup it properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },
  --
  -- plugins can be:
  -- 'repo/name',
  -- {'repo/name', opts = {}}
  -- {'repo/name', config = function ()}
  -- Use `opts = {}` to force a plugin to be loaded.
  -- passing opts is equal to: require('gitsigns').setup({ ... })
  --
  -- Use `config =` to run commands and other things after loading
}

-- VIM OPTIONS
-- we can see all options using `:help option-list`
-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = false

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

-- -- Decrease mapped sequence wait time
-- -- Displays which-key popup sooner
-- vim.opt.timeoutlen = 300

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

-- use indents for fold
vim.opt.foldmethod = 'indent'
vim.opt.foldlevelstart = 99

-- KEY BINDINGS
-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

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
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- telescope keymaps `:help telescope.builtin`
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
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

vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat buffer' })

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

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
