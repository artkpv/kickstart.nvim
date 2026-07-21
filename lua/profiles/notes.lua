vim.o.guifont = 'Monaspace Xenon:h13'

return {
  {
    'hrsh7th/nvim-cmp',
    opts = function(_, opts)
      opts.completion = opts.completion or {}
      opts.completion.autocomplete = false
      return opts
    end,
  },
  {
    'L3MON4D3/LuaSnip',
    config = function()
      require('luasnip.loaders.from_snipmate').lazy_load {
        paths = { vim.fn.expand '~/mydir/notes/bin/snippets' },
      }
    end,
  },
  {
    'preservim/vim-markdown',
    ft = { 'markdown' },
    branch = 'master',
    dependencies = { 'godlygeek/tabular' },
    init = function(opts)
      vim.keymap.set('n', '<leader>m\\', '<cmd>WikiToc<CR>')
      vim.keymap.set({ 'n', 'v' }, '<leader>mi', "<cmd>'<,'>HeaderIncrease<CR>")
      vim.keymap.set({ 'n', 'v' }, '<leader>md', "<cmd>'<,'>HeaderDecrease<CR>")
      vim.keymap.set({ 'n', 'v' }, '<leader>mh', '<cmd>norm I#<CR>')
      vim.keymap.set({ 'n', 'v' }, '<leader>mo', '<cmd>Toc<CR>')
      vim.keymap.set('n', '<leader>mf', function() vim.cmd ':!firefox --new-window "%"&' end, { desc = 'Open in [F]irefox' })
      return opts
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    opts = {
      latex = { enabled = false },
      file_types = { 'markdown', 'Avante' },
    },
    ft = { 'markdown', 'Avante' },
  },
  {
    'jalvesaq/zotcite',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-telescope/telescope.nvim' },
    config = function()
      require('zotcite').setup {
        open_in_zotero = true,
        key_type = 'zotero',
        citation_template = '{Author}-{year}',
      }
    end,
  },
  {
    'stevearc/aerial.nvim',
    opts = {
      col1_width = 4,
      col2_width = 30,
      format_symbol = function(symbol_path, filetype)
        if filetype == 'json' or filetype == 'yaml' then return table.concat(symbol_path, '.') else return symbol_path[#symbol_path] end
      end,
      show_columns = 'both',
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    config = function(_, opts)
      require('aerial').setup(opts)
      vim.keymap.set('n', '<leader>so', function() require('telescope').extensions.aerial.aerial() end, { desc = '[S]earch [O]utline' })
    end
  },
  { 'jupj/vim-timeclock', ft = { 'timeclock' } },
  {
    'freitass/todo.txt-vim',
    config = function() vim.g.todo_done_filename = 'done.txt' end,
  },
  { 'qadzek/link.vim' },
  {
    'HakonHarnes/img-clip.nvim',
    event = 'VeryLazy',
    opts = {
      prompt_for_file_name = true,
      embed_image_as_base64 = false,
      dir_path = 'assets',
    },
    keys = {
      { '<leader>p', '<cmd>PasteImage<cr>', desc = 'Paste image from system clipboard' },
    },
  },
  {
    '3rd/image.nvim',
    config = function()
      require('image').setup {
        backend = 'kitty',
        processor = 'magick_cli',
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            floating_windows = false,
            filetypes = { 'markdown', 'vimwiki' },
          },
          neorg = { enabled = true, filetypes = { 'norg' } },
          typst = { enabled = true, filetypes = { 'typst' } },
          html = { enabled = false },
          css = { enabled = false },
        },
        max_height_window_percentage = 50,
        hijack_file_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.avif' },
      }
    end,
  },
  {
    'Thiago4532/mdmath.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'zk-org/zk-nvim',
    config = function()
      require('zk').setup {
        picker = 'telescope',
        lsp = {
          config = { name = 'zk', cmd = { 'zk', 'lsp' }, filetypes = { 'markdown' } },
          auto_attach = { enabled = true },
        },
      }
      -- HOTFIX for zk.util
      local util = require 'zk.util'
      util.get_lsp_location_from_selection = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local encoding = 'utf-16'
        local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'zk' })[1]
        if client and client.offset_encoding then encoding = client.offset_encoding end
        local params = vim.lsp.util.make_given_range_params(nil, nil, bufnr, encoding)
        return { uri = params.textDocument.uri, range = params.range }
      end
      util.get_lsp_location_from_caret = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local uri = vim.uri_from_bufnr(bufnr)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        return {
          uri = uri,
          range = {
            start = { line = row - 1, character = col + 1 },
            ['end'] = { line = row - 1, character = col + 1 },
          },
        }
      end
    end,
  },
  {
    'lervag/vimtex',
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_compiler_method = 'tectonic'
      vim.g.vimtex_quickfix_mode = 0
    end,
  },
}
