-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Quick save with Ctrl-S
vim.keymap.set({ 'n', 'i', 'x' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })

-- настраиваем переключение раскладок клавиатуры по C-^
vim.o.keymap = 'russian-jcukenwin'
vim.o.iminsert = 0 -- default English
vim.o.imsearch = 0 -- default English
vim.keymap.set({ 'i', 'c' }, '<F3>', '<C-^>', { desc = 'Toggle keymap' })

vim.keymap.set('i', '<F4>', '<C-R>=strftime("%Y-%m-%d %H:%M")<CR>', { desc = 'Insert datetime' })
vim.keymap.set('i', '<F5>', '<C-R>=strftime("%H:%M")<CR>', { desc = 'Insert time' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>qq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>qt', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = '[T]oggle diagnostic' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<C-right>', '<cmd>tabnext<CR>')
vim.keymap.set('n', '<C-left>', '<cmd>tabprev<CR>')
vim.keymap.set('n', '<C-up>', '<cmd>bnext<CR>')
vim.keymap.set('n', '<C-down>', '<cmd>bprev<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Open current buffer in a new tab: 
vim.keymap.set('n', '<C-w>t', ':tab split<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>haa', function()
  vim.cmd ':!git aa; git cm save'
end, { desc = 'Git add all and commit' })
vim.keymap.set('n', '<leader>has', function()
  vim.cmd ':!git save'
end, { desc = 'Git add all, commit, and push' })

-- Copy relative path:line (e.g., src/main.py:10)
vim.keymap.set('n', '<leader>cp', function()
  local path = vim.fn.expand '%' .. ':' .. vim.fn.line '.'
  vim.fn.setreg('+', path)
  vim.notify('Copied "' .. path .. '" to clipboard')
end, { desc = 'Copy relative path:line' })

-- Copy full path:line (e.g., /home/user/project/src/main.py:10)
vim.keymap.set('n', '<leader>cP', function()
  local path = vim.fn.expand '%:p' .. ':' .. vim.fn.line '.'
  vim.fn.setreg('+', path)
  vim.notify('Copied "' .. path .. '" to clipboard')
end, { desc = 'Copy full path:line' })

-- Fix the bug (2025-10-11), where `s` does not work
vim.keymap.set({ 'n', 'x' }, 's', 'cl')

-- Toggle ltex spell checking (improved spell check)
local function ltex_start(lang)
  vim.lsp.start {
    name = 'ltex',
    cmd = { vim.fn.stdpath 'data' .. '/mason/bin/ltex-ls' },
    root_dir = vim.fn.getcwd(),
    settings = {
      ltex = {
        enabled = { 'latex', 'tex', 'bib', 'markdown', 'gitcommit', 'text' },
        language = lang,
        diagnosticSeverity = 'information',
        sentenceCacheSize = 2000,
        additionalRules = { enablePickyRules = true, motherTongue = 'en-US' },
      },
    },
  }
  -- ltex_extra is initialized via the LspAttach autocmd in config/autocmds.lua
  vim.diagnostic.enable(true)
  vim.notify('ltex started (' .. lang .. ')')
end

local function ltex_stop()
  local clients = vim.lsp.get_clients { bufnr = 0, name = 'ltex' }
  for _, client in ipairs(clients) do
    client:stop()
  end
  if #clients > 0 then
    vim.diagnostic.enable(false)
    vim.notify 'ltex stopped'
  else
    vim.notify 'ltex is not running'
  end
end

vim.keymap.set('n', '<leader>tB', function()
  vim.o.background = vim.o.background == 'dark' and 'light' or 'dark'
end, { desc = '[T]oggle [B]ackground light/dark' })

vim.keymap.set('n', '<leader>tSe', function() ltex_start 'en-US' end, { desc = '[T]oggle ltex [S]pell [e]nglish' })
vim.keymap.set('n', '<leader>tSr', function() ltex_start 'ru-RU' end, { desc = '[T]oggle ltex [S]pell [r]ussian' })
vim.keymap.set('n', '<leader>tSS', ltex_stop, { desc = '[T]oggle ltex [S]pell off' })
