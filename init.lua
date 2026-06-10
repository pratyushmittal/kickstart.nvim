-- Leader
vim.g.mapleader = ' '

-- Plugins
vim.pack.add({
  'https://github.com/rebelot/kanagawa.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-orgmode/orgmode',
  'https://github.com/nvim-orgmode/telescope-orgmode.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/echasnovski/mini.nvim', -- Shows open buffers as tabs at the top.
  'https://github.com/lukas-reineke/indent-blankline.nvim', -- Shows vertical indent lines inside code.
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
  'https://github.com/RRethy/vim-illuminate', -- Highlight other uses of the symbol under cursor.
})

-- UI
vim.o.termguicolors = true
vim.cmd.colorscheme('kanagawa')
vim.o.winborder = 'rounded' -- Use rounded borders for floating windows.
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true -- Highlight the current cursor line.
vim.o.scrolloff = 7 -- Keep context lines above/below the cursor while scrolling.
vim.o.list = true -- Show whitespace markers from listchars.
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

require('mini.tabline').setup()
require('which-key').setup()
require('treesitter-context').setup({ max_lines = 2 })

-- Folding
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldlevelstart = 99

-- Indentation guides
vim.api.nvim_set_hl(0, 'IblIndent', { link = 'NonText' })
require('ibl').setup({
  indent = { highlight = 'IblIndent' },
  scope = { enabled = false },
})

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'split' -- Preview substitution results in a split.
vim.o.breakindent = true -- Keep wrapped lines aligned with their indentation.
vim.o.confirm = true -- Ask to save changed buffers instead of failing commands.
vim.o.timeoutlen = 300 -- Shorten mapped-key sequence wait time.

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostics and quickfix
vim.diagnostic.config({
  jump = {
    on_jump = function(diagnostic, bufnr)
      if not diagnostic then
        -- Guard because there may be no diagnostic after a jump attempt.
        return
      end

      -- Show the diagnostic message for the location we just jumped to.
      vim.diagnostic.open_float({ bufnr = bufnr, focus = false, scope = 'cursor' })
    end,
  },
})

vim.keymap.set('n', ']q', '<cmd>cnext<CR>', { desc = 'Next quickfix item' })
vim.keymap.set('n', '[q', '<cmd>cprev<CR>', { desc = 'Previous quickfix item' })
vim.keymap.set('n', '<leader>q', function()
  local winid = vim.fn.getqflist({ winid = 0 }).winid

  if winid ~= 0 then
    vim.cmd.cclose()
    return
  end

  if #vim.diagnostic.get() == 0 then
    -- Guard because opening an empty quickfix window is confusing.
    vim.notify('No diagnostics')
    return
  end

  vim.diagnostic.setqflist({ open = true })
end, { desc = 'Toggle diagnostics quickfix' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function(args)
    vim.keymap.set('n', 'q', '<cmd>cclose<CR>', { buffer = args.buf, silent = true, desc = 'Close quickfix' })
  end,
})

-- Buffers and windows
vim.o.splitright = true -- Open vertical splits to the right.
vim.o.splitbelow = true -- Open horizontal splits below.

vim.keymap.set('n', '<leader><Tab>', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader><S-Tab>', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Toggle between one full window and a vertical split.
vim.keymap.set('n', '<leader>v', function()
  -- If there is only one window, open a vertical split.
  if vim.fn.winnr() < 2 then
    vim.cmd 'vsp'
  else
    vim.cmd 'only'
  end
end, { desc = 'Toggle [V]ertical split/full window' })

-- Telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>sf', telescope.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', telescope.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sc', telescope.git_status, { desc = '[S]earch [C]hanged files' })
vim.keymap.set('n', '<leader>sh', telescope.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', telescope.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sr', telescope.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader><leader>', telescope.buffers, { desc = 'Find existing buffers' })
vim.keymap.set('n', '<leader>sn', function()
  telescope.find_files({ cwd = vim.fn.stdpath('config') })
end, { desc = '[S]earch [N]eovim files' })
vim.keymap.set('n', 'gd', telescope.lsp_definitions, { desc = '[G]oto [D]efinition' })
vim.keymap.set('n', 'grr', telescope.lsp_references, { desc = '[G]oto [R]eferences' })

-- Orgmode
require('orgmode').setup(require('orgmode-config'))
require('telescope').load_extension('orgmode')

local orgmode_actions = require('orgmode-actions')

vim.keymap.set('n', '<leader>o', function()
  orgmode_actions.open_agenda('a')
end, { desc = '[O]rg agenda' })

vim.keymap.set('n', '<leader>so', require('telescope').extensions.orgmode.search_headings, { desc = '[S]earch [O]rg headings' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'orgagenda',
  callback = function(args)
    vim.keymap.set('n', '1', function()
      orgmode_actions.open_agenda('t')
    end, { buffer = args.buf, silent = true, desc = 'Org tasks: clear filters' })

    vim.keymap.set('n', '2', function()
      orgmode_actions.open_agenda('2')
    end, { buffer = args.buf, silent = true, desc = 'Org tasks: this cycle' })

    vim.keymap.set('n', '3', function()
      orgmode_actions.open_agenda('3')
    end, { buffer = args.buf, silent = true, desc = 'Org tasks: later cycles' })

    vim.keymap.set('n', 'c', function()
      orgmode_actions.capture_task('t')
    end, { buffer = args.buf, silent = true, desc = 'Org create task' })

    vim.keymap.set('n', 'A', orgmode_actions.toggle_current_task_today_deadline, { buffer = args.buf, silent = true, desc = 'Org tasks: toggle today deadline' })
  end,
})

-- Git
require('gitsigns').setup({
  linehl = true,
  attach_to_untracked = true,
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    vim.keymap.set('n', ']e', gitsigns.next_hunk, { buffer = bufnr, desc = 'Next git edit' })
    vim.keymap.set('n', '[e', gitsigns.prev_hunk, { buffer = bufnr, desc = 'Previous git edit' })
    local inline_diff = require('git_inline_diff')
    local function refresh_inline_diff()
      inline_diff.refresh(bufnr)
    end

    vim.keymap.set('n', 'm', inline_diff.toggle, { buffer = bufnr, desc = 'Toggle inline git diff' })
    vim.keymap.set('n', 's', function()
      local line = vim.fn.line('.')
      gitsigns.stage_hunk({ line, line }, nil, refresh_inline_diff)
    end, { buffer = bufnr, desc = 'Toggle stage current line' })
    vim.keymap.set('n', 'S', function()
      local actions = gitsigns.get_actions() or {}

      if actions.stage_hunk then
        gitsigns.stage_buffer(refresh_inline_diff)
        return
      end

      gitsigns.reset_buffer_index(refresh_inline_diff)
    end, { buffer = bufnr, desc = 'Toggle stage current file' })
    vim.keymap.set('v', 's', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }, nil, refresh_inline_diff)
    end, { buffer = bufnr, desc = 'Toggle stage selected hunk' })
  end,
})

-- Highlight unstaged added lines, but not staged lines.
vim.api.nvim_set_hl(0, 'GitSignsStagedAddLn', { fg = 'NONE', bg = 'NONE', sp = 'NONE' })
vim.api.nvim_set_hl(0, 'GitSignsStagedChangeLn', { fg = 'NONE', bg = 'NONE', sp = 'NONE' })
vim.api.nvim_set_hl(0, 'GitSignsStagedChangedeleteLn', { fg = 'NONE', bg = 'NONE', sp = 'NONE' })
vim.api.nvim_set_hl(0, 'GitSignsStagedTopdeleteLn', { fg = 'NONE', bg = 'NONE', sp = 'NONE' })
vim.api.nvim_set_hl(0, 'GitSignsStagedUntrackedLn', { fg = 'NONE', bg = 'NONE', sp = 'NONE' })

-- Native niceties
vim.keymap.set('n', 'gf', ':edit <cfile><cr>', { desc = '[G]oto [F]ile' })
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.jrnl',
  callback = function()
    vim.bo.filetype = 'markdown'
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function(args)
    local lua_sections = require('lua_sections')
    vim.keymap.set('n', ']]', lua_sections.next_function, { buffer = args.buf, desc = 'Next Lua function' })
    vim.keymap.set('n', '[[', lua_sections.previous_function, { buffer = args.buf, desc = 'Previous Lua function' })
  end,
})

-- System clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>Y', '"+yy', { desc = 'Yank line to system clipboard' })
vim.keymap.set('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard after cursor' })
vim.keymap.set('n', '<leader>P', '"+P', { desc = 'Paste from system clipboard before cursor' })
vim.keymap.set('v', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })

-- Faltoo
vim.opt.runtimepath:prepend('/Users/pratyush/Websites/faltoo.nvim')
require('faltoo').setup()

-- statusline: file, Faltoo status, flags, and right aligned cursor position with file percent
vim.o.statusline = '%f %{v:lua.require("faltoo").status()}%m%r%h%w%=%-14.(%l,%c%V%) %P'

-- LSP
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.stylua.toml', 'stylua.toml', '.git' },
  completion = {
    callSnippet = 'Replace',
  },
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
      runtime = { version = 'LuaJIT' },
      workspace = {
        -- Only load Neovim's own runtime so plugin source wins over installed plugin copies.
        library = { vim.env.VIMRUNTIME },
        checkThirdParty = false,
      },
    },
  },
})

vim.lsp.config('ruff', {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  offset_encoding = 'utf-8',
})

vim.lsp.config('ty', {
  cmd = { 'ty', 'server' },
  filetypes = { 'python' },
  root_markers = { 'ty.toml', 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
  offset_encoding = 'utf-8',
  settings = {
    ty = {
      experimental = {
        autoImport = true,
      },
    },
  },
})

vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
  settings = {
    ['rust-analyzer'] = {
      procMacro = {
        ignored = {
          leptos_macro = {
            'server',
          },
        },
      },
    },
  },
})

vim.lsp.enable({ 'lua_ls', 'ruff', 'ty', 'rust_analyzer' })
