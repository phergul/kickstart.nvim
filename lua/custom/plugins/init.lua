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

      -----------------------------------------------------------------
      -- 🔑 Keymaps for convenience
      -----------------------------------------------------------------
      local keymap = vim.keymap.set
      local opts = { noremap = true, silent = true, desc = '' }

      keymap('n', '<leader>tt', '<cmd>ToggleTerm<CR>', vim.tbl_extend('force', opts, { desc = 'Toggle terminal' }))
      keymap('n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<CR>', vim.tbl_extend('force', opts, { desc = 'Horizontal terminal' }))
      keymap('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical size=50<CR>', vim.tbl_extend('force', opts, { desc = 'Vertical terminal' }))
      keymap('n', '<leader>tf', '<cmd>ToggleTerm direction=float<CR>', vim.tbl_extend('force', opts, { desc = 'Floating terminal' }))

      -----------------------------------------------------------------
      -- 🧠 Terminal mode mappings
      -----------------------------------------------------------------
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
        end,
      }

      keymap('n', '<leader>tg', function()
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
        -- visual mode
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [s]tage hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [r]eset hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
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
}
