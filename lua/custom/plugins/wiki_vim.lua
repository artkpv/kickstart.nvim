return {
  'lervag/wiki.vim',
  lazy = false, -- we don't want to lazy load VimTeX
  init = function(opts)
    -- opts.commit = '43ae314'
    vim.g.wiki_root = '/home/art/mydir/notes/'

    vim.g.wiki_select_method = {
      pages = require('wiki.telescope').pages,
      tags = require('wiki.telescope').tags,
      toc = require('wiki.telescope').toc,
      links = require('wiki.telescope').links,
    }
    vim.g.wiki_filetypes = { 'md' }

    vim.g.wiki_link_creation = {
      md = {
        link_type = 'md',
        url_extension = '.md',
      },
      _ = {
        link_type = 'md',
        url_extension = '.md',
      },
    }

    vim.g.wiki_month_names = {
      '01.Январь',
      '02.Февраль',
      '03.Март',
      '04.Апрель',
      '05.Май',
      '06.Июнь',
      '07.Июль',
      '08.Август',
      '09.Сентябрь',
      '10.Октябрь',
      '11.Ноябрь',
      '12.Декабрь',
    }
    vim.g.wiki_toc_title = 'Содержание'
    vim.g.wiki_journal = {
      -- index_use_journal_scheme = false,
      name = '2024',
      frequency = 'daily',
      date_format = {
        daily = '%Y-%m-%d',
      },
      root = '~/mydir/notes/2024',
    }
    vim.g.init_my_wiki_config = function()
      vim.opt.number = false
      vim.opt.relativenumber = false
      vim.opt.cursorline = false
      vim.opt.cursorcolumn = false
      vim.opt.foldcolumn = '0'
      vim.opt.list = false
      vim.opt.foldlevel = 2
      vim.diagnostic.enable(false)
      vim.cmd.colorscheme 'neobones'
      vim.o.laststatus = 1
      vim.o.ruler = false
      vim.cmd 'Copilot disable'
      vim.cmd 'LspStop'
      vim.o.wrap = true

      -- au! BufWritePost ~/mydir/notes/* !git add "%";git commit -m "Auto commit of %:t." "%"

      vim.api.nvim_create_autocmd('BufWritePost', {
        desc = 'Commit wiki changes',
        group = vim.api.nvim_create_augroup('wiki-commit-hook', { clear = true }),
        pattern = { '*.md' },
        callback = function()
          vim.cmd '!git add "%";git commit -m "Auto commit of %:t." "%"'
        end,
      })
    end
    vim.keymap.set('n', '<leader>wq', vim.g.init_my_wiki_config, { desc = 'Wiki [Q]uite mode on' })
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
  end,
}
