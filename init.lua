-- Leader
vim.g.mapleader = ' '

-- Build the native Telescope sorter only when installed or updated.
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('telescope-fzf-build', { clear = true }),
  callback = function(event)
    -- Other plugins and deletion events do not need a build.
    if event.data.spec.name == 'telescope-fzf-native.nvim' and event.data.kind ~= 'delete' then
      local result = vim.system({ 'make' }, { cwd = event.data.path, text = true }):wait()
      assert(result.code == 0, result.stderr)
    end
  end,
})

-- Plugins
vim.pack.add({
  'https://github.com/rebelot/kanagawa.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim', -- Enables filters such as !migrations.
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/nvim-orgmode/orgmode',
  'https://github.com/nvim-orgmode/telescope-orgmode.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/echasnovski/mini.nvim', -- Shows open buffers as tabs at the top.
  'https://github.com/lukas-reineke/indent-blankline.nvim', -- Shows vertical indent lines inside code.
  'https://github.com/nvim-treesitter/nvim-treesitter', -- Manages non-bundled parsers such as CSS; parsing itself is built into Neovim.
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
  'https://github.com/RRethy/vim-illuminate', -- Highlight other uses of the symbol under cursor.
  'https://github.com/Jezda1337/nvim-html-css', -- CSS class navigation from HTML templates.
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
require('oil').setup()
require('treesitter-context').setup({ max_lines = 2 })

if vim.api.nvim_get_runtime_file('parser/css.*', false)[1] == nil then
  -- CSS navigation cannot start until its parser is installed.
  require('nvim-treesitter').install({ 'css' }):wait(300000)
end

require('html-css').setup({
  enable_on = { 'html', 'htmldjango' },
})

local html_css_actions = require('html_css_actions')

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'html', 'htmldjango' },
  callback = function(args)
    vim.opt_local.iskeyword:append('-')
    vim.keymap.set('n', 'gd', html_css_actions.goto_definition, { buffer = args.buf, desc = 'Go to CSS definition' })
    vim.keymap.set('n', 'K', html_css_actions.peek_definition, { buffer = args.buf, desc = 'Peek CSS definition' })
    vim.keymap.set('n', 'grr', html_css_actions.find_references, { buffer = args.buf, desc = 'Find CSS class references' })
  end,
})

-- CoffeeShop mode hides text while working in public places.
vim.api.nvim_create_user_command('CoffeeShopModeOn', function()
  vim.cmd('syntax match CoffeeShop /[a-z]/ conceal cchar=• contains=NONE containedin=ALL')
  vim.cmd('highlight default link CoffeeShop Normal')
  vim.wo.conceallevel = 2
  vim.wo.concealcursor = 'ni'
end, { desc = 'Enable CoffeeShop mode' })

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
vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open parent directory' })

-- Spell check stays off until explicitly toggled.
vim.o.spelllang = 'en_gb'
vim.o.spellsuggest = 'best,9' -- Show the 9 best suggestions first in z=.
local function toggle_spellcheck()
  vim.wo.spell = not vim.wo.spell
  vim.notify('Spellcheck ' .. (vim.wo.spell and 'on' or 'off'))
end

vim.api.nvim_create_user_command('SpellCheck', toggle_spellcheck, { desc = 'Toggle spellcheck' })
vim.keymap.set('n', '<leader>ts', toggle_spellcheck, { desc = '[T]oggle [S]pellcheck' })
-- Native spell keys after enabling: ]s/[s jump, z= suggestions, zg add, zw mark wrong, zug undo.

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
vim.keymap.set('n', 'M', function()
  if vim.wo.diff then
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
      if vim.startswith(name, 'gitsigns://') then
        -- Close gitsigns' generated base buffer when toggling diff off.
        vim.api.nvim_win_close(win, true)
      end
    end

    vim.cmd('diffoff!')
    return
  end

  require('gitsigns').diffthis(nil, { vertical = true })
end, { desc = 'Toggle previous file diff' })

-- Telescope
require('telescope').load_extension('fzf')
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>sf', telescope.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', telescope.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sc', telescope.git_status, { desc = '[S]earch [C]hanged files' })
vim.keymap.set('n', '<leader>sC', function()
  -- Unstaged only: worktree differs from index, plus untracked files
  telescope.git_files({
    prompt_title = 'Unstaged Files',
    git_command = { 'git', 'ls-files', '--modified', '--others', '--exclude-standard', '--deduplicate' },
  })
end, { desc = '[S]earch unstaged [C]hanged files' })
vim.keymap.set('n', '<leader>sh', telescope.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', telescope.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sr', telescope.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader><leader>', telescope.buffers, { desc = 'Find existing buffers' })
vim.keymap.set('n', '<leader>sn', function()
  telescope.find_files({ cwd = vim.fn.stdpath('config') })
end, { desc = '[S]earch [N]eovim files' })
vim.keymap.set('n', 'gd', telescope.lsp_definitions, { desc = '[G]oto [D]efinition' })
vim.keymap.set('n', 'grr', telescope.lsp_references, { desc = '[G]oto [R]eferences' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'cucumber',
  callback = function(args)
    local cucumber_actions = require('cucumber_actions')
    vim.keymap.set('n', 'gd', cucumber_actions.goto_definition, { buffer = args.buf, desc = 'Go to step definition' })
    vim.keymap.set('n', 'K', cucumber_actions.peek_definition, { buffer = args.buf, desc = 'Peek step definition' })
  end,
})

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

-- Use the system clipboard for normal yanks, deletes, and puts.
vim.o.clipboard = 'unnamedplus'

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

vim.lsp.config('denols', {
  cmd = { 'deno', 'lsp' },
  filetypes = { 'javascript', 'javascriptreact' },
  root_markers = { 'deno.json', 'deno.jsonc', '.git' },
  settings = {
    deno = {
      enable = true,
      lint = false,
    },
  },
})

vim.lsp.config('cucumber_language_server', {
  cmd = function(dispatchers, config)
    -- The server resolves discovered files from its process directory.
    return vim.lsp.rpc.start({ 'cucumber-language-server', '--stdio' }, dispatchers, { cwd = config.root_dir })
  end,
  filetypes = { 'cucumber' },
  root_markers = { '.git' },
  handlers = {
    ['textDocument/publishDiagnostics'] = require('cucumber_actions').publish_diagnostics,
  },
  settings = {
    cucumber = {
      features = { '**/tests/features/**/*.feature' },
      glue = { '**/tests/**/*.py' },
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

vim.lsp.enable({ 'lua_ls', 'ruff', 'ty', 'denols', 'cucumber_language_server', 'rust_analyzer' })
