-- Modular Neovim Configuration
-- Refactored from Kickstart.nvim

-- Set leader keys BEFORE any plugins are loaded
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- 1. Load Core Configuration
require 'config.defaults'
require 'config.keymaps'
require 'config.autocmds'

-- 2. Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- 3. Determine Profile
-- Priority: NVIM_PROFILE env var > Current Directory context > Default ('ide')
local profile = os.getenv 'NVIM_PROFILE'

if not profile then
  local cwd = vim.fn.getcwd()
  -- Check if we are in the notes directory (adjust path string as needed)
  if cwd:find('mydir/notes') then
    profile = 'notes'
  else
    profile = 'ide'
  end
end

-- print('Loading Profile: ' .. profile) -- Uncomment for debugging startup

-- 4. Setup Lazy with Profile Imports
require('lazy').setup({
  -- Always load common plugins
  { import = 'plugins.common' },
  
  -- Load profile-specific plugins
  { import = 'profiles.' .. profile },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et