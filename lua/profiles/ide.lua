return {
  -- LSP Plugins
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = { { path = 'luvit-meta/library', words = { 'vim%.uv' } } },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- LspAttach keymaps + diagnostic signs are in config/autocmds.lua (shared across profiles)

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        tectonic = {},
        bashls = {},
        -- LaTeX LSP
        texlab = {
          keys = {
            { '<leader>K', '<plug>(vimtex-doc-package)', desc = 'Vimtex Docs', silent = true },
          },
        },
        ltex = {
          filetypes = { 'latex', 'tex', 'bib', 'markdown', 'gitcommit', 'text' },
          settings = {
            ltex = {
              enabled = { 'latex', 'tex', 'bib', 'markdown' },
              language = 'en-US',
              diagnosticSeverity = 'information',
              sentenceCacheSize = 2000,
              additionalRules = {
                enablePickyRules = true,
                motherTongue = 'en-US',
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
      }

      require('mason').setup()
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, { 'stylua' })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
        end
        return { timeout_ms = 500, lsp_format = lsp_format_opt }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
      },
    },
  },

  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-python',
    },
    config = function()
      require('neotest').setup {
        adapters = { require 'neotest-python' },
      }
    end,
  },

  -- Aerial (Code Outline)
  {
    'stevearc/aerial.nvim',
    opts = {
      col1_width = 4,
      col2_width = 30,
      format_symbol = function(symbol_path, filetype)
        if filetype == 'json' or filetype == 'yaml' then
          return table.concat(symbol_path, '.')
        else
          return symbol_path[#symbol_path]
        end
      end,
      show_columns = 'both',
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    config = function(_, opts)
      require('aerial').setup(opts)
      vim.keymap.set('n', '<leader>so', function()
        require('telescope').extensions.aerial.aerial()
      end, { desc = '[S]earch [O]utline' })
    end,
  },

  -- Avante.nvim (Claude Agent + Autosuggestions)
  {
    'yetone/avante.nvim',
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = vim.fn.has 'win32' ~= 0 and 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false' or 'make',
    event = 'VeryLazy',
    lazy = false,
    version = false,
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      provider = 'claude',
      auto_suggestions_provider = 'claude',
      providers = {
        claude = {
          endpoint = 'https://api.anthropic.com',
          --- auth_type = 'max', -- Set to "max" to sign in with Claude Pro/Max subscription
          auth_type = 'api',
          model = 'claude-haiku-4-5',
          timeout = 30000, -- Timeout in milliseconds
          extra_request_body = {
            temperature = 0.7,
            max_tokens = 20480,
          },
        },
        gemini = {
          model = 'gemini-3-flash-preview',
          timeout = 30000,
          temperature = 0.7,
          max_tokens = 20480,
        },
      },
      mappings = {
        suggestion = {
          accept = '<C-y>',
          next = '<C-f>',
          prev = '<C-b>',
          -- dismiss = '<C-c>',
        },
      },
      behaviour = {
        auto_suggestions = false,
      },
    },
    config = function(_, opts)
      require('avante').setup(opts)
      vim.keymap.set('i', '<C-f>', function()
        local _, _, sg = require('avante').get()
        if sg:is_visible() then
          sg:next()
        else
          sg:suggest()
        end
      end, { desc = 'avante: trigger or next suggestion' })
    end,
    build = 'make',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'nvim-mini/mini.pick', -- for file_selector provider mini.pick
      'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
      'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
      'ibhagwan/fzf-lua', -- for file_selector provider fzf
      'stevearc/dressing.nvim', -- for input provider dressing
      'folke/snacks.nvim', -- for input provider snacks
      'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },

  -- ClaudeCode.nvim
  {
    'coder/claudecode.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim' },
    config = function()
      require('claudecode').setup {}
    end,
    keys = {
      { '<leader>cc', nil, desc = 'AI/Claude Code' },
      { '<leader>cc', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
      { '<leader>cf', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
      { '<leader>cr', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
      { '<leader>cC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
      { '<leader>cm', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
      { '<leader>cb', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
      { '<leader>cs', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
      {
        '<leader>cs',
        '<cmd>ClaudeCodeTreeAdd<cr>',
        desc = 'Add file',
        ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
      },
      -- Diff management
      { '<leader>ct', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
      { '<leader>cd', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
    },
  },

  -- Jupytext (Jupyter Notebook as Markdown/Script)
  {
    'goerz/jupytext.nvim',
    lazy = false,
    opts = {},
  },

  -- LaTeX Support
  {
    'lervag/vimtex',
    lazy = false, -- VimTeX is important, load it immediately
    init = function()
      -- VimTeX configuration
      vim.g.vimtex_view_method = 'zathura' -- standard linux pdf viewer
      vim.g.vimtex_compiler_method = 'tectonic' -- use tectonic since latexmk is missing
      vim.g.vimtex_quickfix_mode = 0 -- suppress error reporting on save/build
    end,
  },
  {
    'hat0uma/csvview.nvim',
    ---@module "csvview"
    ---@type CsvView.Options
    opts = {
      parser = { comments = { '#', '//' } },
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { 'if', mode = { 'o', 'x' } },
        textobject_field_outer = { 'af', mode = { 'o', 'x' } },
        -- Excel-like navigation:
        -- Use <Tab> and <S-Tab> to move horizontally between fields.
        -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
        -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
        jump_next_field_end = { '<Tab>', mode = { 'n', 'v' } },
        jump_prev_field_end = { '<S-Tab>', mode = { 'n', 'v' } },
        jump_next_row = { '<Enter>', mode = { 'n', 'v' } },
        jump_prev_row = { '<S-Enter>', mode = { 'n', 'v' } },
      },
    },
    cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
  },
}
