-- Add the key mappings only for Markdown files in a zk notebook.
local has_zk, zk_util = pcall(require, 'zk.util')
if not has_zk then return end

if zk_util.notebook_root(vim.fn.expand '%:p') ~= nil then
  local function map(...)
    vim.api.nvim_buf_set_keymap(0, ...)
  end
  local opts = { noremap = true, silent = false }

  -- Open the link under the caret.
  map('n', '<CR>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

  -- Create a new note after asking for its title.
  -- This overrides the global `<leader>zn` mapping to create the note in the same directory as the current buffer.
  map('n', '<leader>wn', "<Cmd>ZkNew { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>", opts)
  -- Create a new note in the same directory as the current buffer, using the current selection for title.
  map('v', '<leader>wnt', ":'<,'>ZkNewFromTitleSelection { dir = vim.fn.expand('%:p:h') }<CR>", opts)
  -- Create a new note in the same directory as the current buffer, using the current selection for note content and asking for its title.
  map('v', '<leader>wnc', ":'<,'>ZkNewFromContentSelection { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>", opts)

  -- Open notes linking to the current buffer.
  map('n', '<leader>wb', '<Cmd>ZkBacklinks<CR>', opts)
  -- Alternative for backlinks using pure LSP and showing the source context.
  --map('n', '<leader>zb', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
  -- Open notes linked by the current buffer.
  map('n', '<leader>wl', '<Cmd>ZkLinks<CR>', opts)

  map('n', '<leader>wil', '<Cmd>ZkInsertLink<CR>', opts)
  map('v', '<leader>wil', ":'<,'>ZkInsertLinkAtSelection<CR>", opts)

  -- Preview a linked note.
  map('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  -- Open the code actions for a visual selection.
  map('v', '<leader>wa', ":'<,'>lua vim.lsp.buf.range_code_action()<CR>", opts)

  -- Open notes.
  vim.api.nvim_set_keymap('n', '<leader>wo', "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", opts)
  -- Open notes associated with the selected tags.
  vim.api.nvim_set_keymap('n', '<leader>wt', '<Cmd>ZkTags<CR>', opts)

  -- Search for the notes matching a given query.
  vim.api.nvim_set_keymap('n', '<leader>wf', "<Cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<CR>", opts)
  -- Search for the notes matching the current visual selection.
  vim.api.nvim_set_keymap('v', '<leader>wf', ":'<,'>ZkMatch<CR>", opts)

  vim.keymap.set('n', '<leader>wea', function()
    vim.cmd ':! pidof -sx anki || { anki & }; ./bin/obsidian_to_anki.sh "%"'
  end, { desc = 'Export to [A]nki cards' })

  local function wiki_page_rename()
    local current_file = vim.fn.expand '%'
    local current_name = vim.fn.expand '%:t'
    local name = vim.fn.input('Enter new name (' .. current_name .. '): ')

    if name ~= '' then
      vim.fn.termopen { './ren.sh', current_file, name }
    end
  end

  vim.keymap.set('n', '<leader>wpr', wiki_page_rename, { desc = 'Rename wiki page' })

  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt.cursorline = false
  vim.opt.cursorcolumn = false
  vim.opt.foldcolumn = '0'
  vim.opt.list = false
  vim.opt.foldlevel = 2
  vim.diagnostic.enable(false)

  vim.o.laststatus = 1
  vim.o.ruler = false

  vim.g.duckbones = { transparent_background = true }
  vim.o.background = 'light'
  vim.cmd.colorscheme 'forestbones'
end
