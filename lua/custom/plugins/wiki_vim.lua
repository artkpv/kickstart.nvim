-- Helper function to get next character sequence
local function get_next_sequence(str)
  if str:match '%d+$' then
    -- If ends with digits, increment the number
    local num = tonumber(str:match '%d+$')
    local prefix = str:match '(.-)%d+$'
    return prefix .. tostring(num + 1)
  elseif str:match '[a-z]+$' then
    -- If ends with letters, increment alphabetically
    local letters = str:match '[a-z]+$'
    local prefix = str:match '(.-)[a-z]+$'

    -- Convert to next letter sequence
    if letters:match '^z+$' then
      -- If all 'z', convert to 'a's with one more letter
      return prefix .. string.rep('a', #letters + 1)
    else
      -- Increment last letter
      local last_char = string.char(letters:byte(-1) + 1)
      return prefix .. letters:sub(1, -2) .. last_char
    end
  end
  return str .. '1'
end

-- Helper function to check if prefix exists
local function prefix_exists(prefix)
  local handle = vim.fn.glob('**/' .. prefix .. '*.md', false, true)
  return #handle > 0
end

function CreateHeaderLink()
  -- This is a lua script for NeoVim that should transform a header in a markdown file into a link following the requirements below.
  --
  --    1) If the markdown file starts with a date in format YYYY-MM-DD then the new link should start also with this date. That is if current file name is "2025-12-13 My file name.md", and the header in this file is "# Here is some header", then the link should be `[Here is some header](2025-12-13 Here is some header)`
  --    2) If the markdown file starts with a prefix in format "<Two digits>.<Digits and letters>", then the new link should start also with this prefix but extended. That is if current file name is "01.1a2b3c1 My file name.md", and the header in this file is "# Here is some header", then the link should be `[Here is some header](01.1a2b3c1a Here is some header)`, where 01.1a2b3c1a is a continuation of 01.1a2b3c1 with appended letter 'a'. Note, if the prefix ends with a letter, then the next character should be a digit, i.e. if the current file name is 01.1a2b3c then this script should create the link with prefix "01.1a2b3c1" (note the last digit added).
  --    3. The new link should be added as a new line above the header
  --
  --
  --    Example:
  --
  --    Before, current file is "01.1a2b3c1 My file name.md"
  --
  --    	```
  --    	# Here is some header
  --    	```
  --
  --    After, in the same file is "01.1a2b3c1 My file name.md"
  --    	```
  --    	[Here is some header](01.1a2b3c1a Here is some header)
  --    	# Here is some header
  --    	```

  -- Get current buffer's filename
  local filename = vim.fn.expand '%:t'
  -- Get current line (header)
  local current_line = vim.api.nvim_get_current_line()

  -- Check if the line starts with # (is a header)
  if not current_line:match '^%s*#+%s+' then
    print 'Current line is not a header'
    return
  end

  -- Extract header text (remove # and trim spaces)
  local header_text = current_line:gsub('^%s*#+%s*', ''):gsub('%s*$', '')

  -- Initialize link prefix
  local link_prefix = ''

  -- Check if filename starts with date pattern (YYYY-MM-DD)
  local date_pattern = '^(%d%d%d%d%-%d%d%-%d%d)'
  local prefix_pattern = '^(%d%d%.%w+)'

  if filename:match(date_pattern) then
    -- Extract date and use it as prefix
    link_prefix = tostring(os.date '%Y-%m-%d')
  elseif filename:match(prefix_pattern) then
    -- Extract prefix and generate unique extension
    local current_prefix = filename:match(prefix_pattern)
    link_prefix = current_prefix

    if link_prefix:match '%d$' then
      link_prefix = link_prefix .. 'a'
    else
      link_prefix = link_prefix .. '1'
    end
    -- Keep generating next prefix until we find a unique one
    while prefix_exists(link_prefix) do
      link_prefix = get_next_sequence(link_prefix)
    end
  else
    print "Filename doesn't match required patterns"
    return
  end

  -- Create the link
  local link = string.format('[%s](<%s %s>)', header_text, link_prefix, header_text)

  -- Get cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_line_num = cursor_pos[1] - 1

  -- Insert the link above the header
  vim.api.nvim_buf_set_lines(0, current_line_num, current_line_num, false, { link })
end

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
    -- vim.g.wiki_filetypes = { 'md' }

    vim.g.wiki_link_creation = {
      _ = {
        link_type = 'md',
        url_extension = '.md',
        url_transform = function(x)
          return vim.fn['wiki#url#utils#url_encode_specific'](x, '()')
        end,
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
      name = '2025',
      frequency = 'daily',
      date_format = {
        daily = '%Y-%m-%d',
      },
      root = '~/mydir/notes/2025',
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

      vim.o.laststatus = 1
      vim.o.ruler = false
      vim.cmd 'Copilot disable'
      vim.cmd 'LspStop'

      vim.g.randombones = { transparent_background = true }
      vim.o.background = 'dark'
      vim.cmd.colorscheme 'randombones'

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

    vim.keymap.set('n', '<leader>mw', function()
      vim.cmd ':!kitty -e nvim "%"&'
    end, { desc = 'Open in a new [W]indow' })

    local function wiki_page_rename()
      local current_file = vim.fn.expand '%'
      local current_name = vim.fn.expand '%:t'
      local name = vim.fn.input('Enter new name (' .. current_name .. '): ')

      if name ~= '' then
        vim.fn.termopen { './ren.sh', current_file, name }
      end
    end

    vim.keymap.set('n', '<leader>wpr', wiki_page_rename, { desc = 'Rename wiki page' })

    vim.keymap.set('n', ',wln', CreateHeaderLink, {
      noremap = true,
      silent = true,
      desc = 'Create a [N]ew link from the current header',
    })

    vim.keymap.set('n', ',wla', function()
      -- TOOD: https://github.com/lervag/wiki.vim/issues/400
      -- vim.cmd 'WikiLinkAdd'
      -- vim.cmd 'WikiLinkExtractHeader'
      -- vim.cmd 'norm F(a..'
      -- vim.cmd 'norm vi(sa>'
    end, {
      noremap = true,
      silent = true,
      desc = 'Create a [N]ew link and fix',
    })
  end,
}
