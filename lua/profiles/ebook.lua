-- Ebook reader profile: light background, black text, no transparency, minimal distractions
-- Activate with: NVIM_PROFILE=ebook nvim  or from i3 via mod+y then e

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    -- Force light background / gruvbox light colorscheme
    vim.o.background = 'light'
    vim.cmd.colorscheme 'gruvbox'
    vim.cmd.hi 'Comment gui=none'
    -- Ensure no transparency leaks through
    local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
    if not normal_hl.bg then
      vim.api.nvim_set_hl(0, 'Normal', { bg = '#fbf1c7' })
    end
  end,
})

-- Disable transparent background for zenbones (set before plugin loads)
vim.g.forestbones = { transparent_background = false }

-- Ebook-friendly reading settings
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = 'no'
vim.opt.cursorline = false
vim.opt.list = false
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.colorcolumn = ''

-- Expose a command to toggle ebook mode from within nvim
vim.api.nvim_create_user_command('EbookMode', function()
  vim.o.background = 'light'
  vim.cmd.colorscheme 'gruvbox'
  vim.cmd.hi 'Comment gui=none'
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt.signcolumn = 'no'
  vim.opt.cursorline = false
  vim.opt.list = false
  vim.opt.wrap = true
  vim.opt.linebreak = true
  print 'Ebook mode activated'
end, { desc = 'Switch to ebook reader mode (light theme, clean view)' })

return {}
