return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup {
        close_if_last_window = true,
        filesystem = {
          follow_current_file = { enabled = true },
          hijack_netrw_behavior = 'open_default',
        },
        window = {
          width = 30,
          mappings = {
            ['<space>'] = 'none', -- disable space toggling folders if you prefer
            ['l'] = 'open', -- open file or expand folder
            ['h'] = 'close_node', -- collapse folder
          },
        },
      }

      vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Toggle Neo-tree file explorer' })

      vim.keymap.set('n', '<leader>st', '<cmd>Neotree focus<CR>', { desc = 'Focus Neo-tree file explorer' })

      vim.keymap.set('n', '<leader>sv', '<cmd>Neotree reveal<CR>', { desc = 'Reveal current file in Neo-tree' })
    end,
  },

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      local list = harpoon:list()
      local ui = harpoon.ui

      vim.keymap.set('n', '<leader>a', function()
        list:add()
      end)
      vim.keymap.set('n', '<C-e>', function()
        ui:toggle_quick_menu(list)
      end)

      vim.keymap.set('n', '<C-h>', function()
        list:select(1)
      end)
      vim.keymap.set('n', '<C-j>', function()
        list:select(2)
      end)
      vim.keymap.set('n', '<C-k>', function()
        list:select(3)
      end)
      vim.keymap.set('n', '<C-l>', function()
        list:select(4)
      end)
    end,
  },

  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        -- 🧠 General Settings
        size = 15,
        open_mapping = [[<C-`>]], -- Toggle terminal with Ctrl + \
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = 'float', -- 'vertical' | 'horizontal' | 'float' | 'tab'
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = 'curved',
          winblend = 0,
        },
      }

      local keymap = vim.keymap.set
      local opts = { noremap = true, silent = true, desc = '' }

      keymap('n', '<leader>tt', '<cmd>ToggleTerm<CR>', vim.tbl_extend('force', opts, { desc = 'Toggle terminal' }))
      keymap('n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<CR>', vim.tbl_extend('force', opts, { desc = 'Horizontal terminal' }))
      keymap('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical size=50<CR>', vim.tbl_extend('force', opts, { desc = 'Vertical terminal' }))
      keymap('n', '<leader>tf', '<cmd>ToggleTerm direction=float<CR>', vim.tbl_extend('force', opts, { desc = 'Floating terminal' }))

      local function set_terminal_keymaps(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
        -- vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      end

      vim.api.nvim_create_autocmd('TermOpen', {
        group = vim.api.nvim_create_augroup('TerminalKeymaps', { clear = true }),
        pattern = 'term://*',
        callback = set_terminal_keymaps,
      })

      local Terminal = require('toggleterm.terminal').Terminal
      local lazygit = Terminal:new {
        cmd = 'lazygit',
        hidden = true,
        direction = 'float',
        float_opts = {
          border = 'double',
        },
        on_open = function(term)
          vim.cmd 'startinsert!'
          vim.wo[term.window].number = false
          vim.wo[term.window].relativenumber = false
          vim.api.nvim_buf_set_keymap(term.bufnr, 't', '<C-g>', '<cmd>close<CR>', { noremap = true, silent = true })
        end,
        on_close = function()
          vim.cmd 'stopinsert'
        end,
      }

      keymap('n', '<C-g>', function()
        lazygit:toggle()
      end, { desc = 'Toggle Lazygit (floating)' })
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = {
        char = '│',
        highlight = { 'IblIndent' },
      },
      whitespace = {
        remove_blankline_trail = true,
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
        highlight = { 'IblScope' },
        include = {
          node_type = { ['*'] = { '*' } },
        },
      },
    },
    config = function(_, opts)
      require('ibl').setup(opts)
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- normal mode
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })
        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
      end,
    },
  },
  -- {
  --   'nvim-java/nvim-java',
  --   dependencies = {
  --     'nvim-java/nvim-java-core', -- core LSP & JDT integration
  --     'lua-async-await', -- internal async library used by nvim-java
  --     'mfussenegger/nvim-jdtls', -- the actual LSP client (JDT LS)
  --     'williamboman/mason.nvim', -- installs jdtls via Mason
  --     'williamboman/mason-lspconfig.nvim', -- connects mason <-> lspconfig
  --     'neovim/nvim-lspconfig', -- base LSP framework
  --   },
  --   config = function()
  --     require('java').setup {
  --       jdk = {
  --         auto_install = true,
  --       },
  --     }
  --   end,
  -- },
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    init = function()
      vim.g.copilot_no_maps = true
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
    end,
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = '<C-l>',
            next = '<C-]>',
            prev = '<C-[>',
            dismiss = '<C-\\>',
          },
          show_predictive_index = false,
        },
        panel = { enabled = false },
      }
      vim.api.nvim_create_autocmd('InsertEnter', {
        callback = function()
          vim.keymap.set('i', '<Esc>', '<Esc>', { noremap = true, silent = true, buffer = true })
        end,
      })
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'zbirenbaum/copilot.lua',
    },
    opts = {
      model = 'claude-sonnet-4',
      debug = false,
      context = 'buffers',
      window = {
        layout = 'vertical',
        position = 'right',
        width = 0.3,
      },
      headers = {
        user = 'You',
        assistant = 'Copilot',
      },
    },

    config = function()
      local function set_copilotchat_highlights()
        vim.api.nvim_set_hl(0, 'CopilotChatResource', { fg = '#F7768E', bold = true })
        vim.api.nvim_set_hl(0, 'CopilotChatTool', { fg = '#E0AF68', bold = true })
        vim.api.nvim_set_hl(0, 'CopilotChatPrompt', { fg = '#9ECE6A', bold = true })
        vim.api.nvim_set_hl(0, 'CopilotChatModel', { fg = '#BB9AF7', italic = true })
        vim.api.nvim_set_hl(0, 'CopilotChatUri', { fg = '#7dcfff', underline = true })
      end

      set_copilotchat_highlights()

      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = set_copilotchat_highlights,
      })
    end,

    keys = function()
      local chat = require 'CopilotChat'
      return {
        {
          '<leader>cc',
          function()
            chat.toggle()
          end,
          desc = 'Toggle Copilot Chat',
        },
        {
          '<leader>cb',
          function()
            chat.open { context = 'buffers' }
          end,
          desc = 'Chat: buffers context',
        },
        {
          '<leader>cw',
          function()
            chat.open { context = 'workspace' }
          end,
          desc = 'Chat: workspace context',
        },
        {
          '<leader>cv',
          function()
            chat.open { context = 'selection' }
          end,
          mode = 'v',
          desc = 'Chat: visual selection',
        },
        {
          '<leader>ce',
          function()
            chat.ask '/Explain'
          end,
          desc = 'Explain code',
        },
        {
          '<leader>cq',
          function()
            chat.close()
          end,
          desc = 'Close Copilot Chat',
        },
        {
          '<leader>cfb',
          function()
            local filepath = vim.fn.expand '%:p'
            require('CopilotChat').open()
            require('CopilotChat').ask('#file:' .. filepath)
          end,
          desc = 'Chat with current file context',
        },
      }
    end,
  },
}
