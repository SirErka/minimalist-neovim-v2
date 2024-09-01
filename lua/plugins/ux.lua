return {
  {
    "willothy/nvim-cokeline",
    dependencies = {
      "nvim-lua/plenary.nvim",    -- Required for v0.4.0+
      "nvim-tree/nvim-web-devicons", -- If you want devicons
      "stevearc/resession.nvim",  -- Optional, for persistent history
    },
    config = function()
      require("cokeline").setup({
        show_if_buffers_are_at_least = 1,
        sidebar = {
          filetype = { "NvimTree", "neo-tree", "SidebarNvim" },
        },
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
      -- Eviline config for lualine (configured to my liking hehe :3)
      -- Author: shadmansaleh
      -- Credit: glepnir
      local lualine = require("lualine")

      -- Color table for highlights
      -- stylua: ignore
      local colors = {
        bg       = '#faf4ed',
        fg       = '#575279',
        yellow   = '#ea9d34',
        cyan     = '#56949f',
        darkblue = '#286983',
        green    = '#286983',
        orange   = '#d7827e',
        violet   = '#907aa9',
        magenta  = '#d7827e',
        blue     = '#56949f',
        red      = '#b4637a',
      }

      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
          local filepath = vim.fn.expand("%:p:h")
          local gitdir = vim.fn.finddir(".git", filepath .. ";")
          return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
      }

      -- Config
      local config = {
        options = {
          -- Disable sections and component separators
          component_separators = "",
          section_separators = "",
          theme = {
            -- We are going to use lualine_c an lualine_x as left and
            -- right section. Both are highlighted by c theme .  So we
            -- are just setting default looks o statusline
            normal = { c = { fg = colors.fg, bg = colors.bg } },
            inactive = { c = { fg = colors.fg, bg = colors.bg } },
          },
          ignore_focus = { "neo-tree" },
        },
        sections = {
          -- these are to remove the defaults
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          -- These will be filled later
          lualine_c = {},
          lualine_x = {},
        },
        inactive_sections = {
          -- these are to remove the defaults
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
      }

      -- Inserts a component in lualine_c at left section
      local function ins_left(component)
        table.insert(config.sections.lualine_c, component)
      end

      -- Inserts a component in lualine_x at right section
      local function ins_right(component)
        table.insert(config.sections.lualine_x, component)
      end

      ins_left({
        function()
          return "▊"
        end,
        color = { fg = colors.blue },  -- Sets highlighting of component
        padding = { left = 0, right = 1 }, -- We don't need space before this
      })

      ins_left({
        -- mode component
        function()
          return ""
        end,
        color = function()
          -- auto change color according to neovims mode
          local mode_color = {
            n = colors.red,
            i = colors.green,
            v = colors.blue,
            ["␖"] = colors.blue,
            V = colors.blue,
            c = colors.magenta,
            no = colors.red,
            s = colors.orange,
            S = colors.orange,
            ["␓"] = colors.orange,
            ic = colors.yellow,
            R = colors.violet,
            Rv = colors.violet,
            cv = colors.red,
            ce = colors.red,
            r = colors.cyan,
            rm = colors.cyan,
            ["r?"] = colors.cyan,
            ["!"] = colors.red,
            t = colors.red,
          }
          return { fg = mode_color[vim.fn.mode()] }
        end,
        padding = { right = 1 },
      })

      ins_left({
        -- filesize component
        "filesize",
        cond = conditions.buffer_not_empty,
      })

      ins_left({
        "filename",
        cond = conditions.buffer_not_empty,
        color = { fg = colors.magenta, gui = "bold" },
      })

      ins_left({ "location" })

      ins_left({ "progress", color = { fg = colors.fg, gui = "bold" } })

      ins_left({
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " " },
        diagnostics_color = {
          error = { fg = colors.red },
          warn = { fg = colors.yellow },
          info = { fg = colors.cyan },
        },
      })

      -- Insert mid section. You can make any number of sections in neovim :)
      -- for lualine it's any number greater then 2
      ins_left({
        function()
          return "%="
        end,
      })

      ins_left({
        -- Lsp server name .
        function()
          local msg = "No Active Lsp"
          local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
          local clients = vim.lsp.get_clients()
          if next(clients) == nil then
            return msg
          end
          for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
              return client.name
            end
          end
          return msg
        end,
        icon = " LSP:",
        color = { fg = "#ffffff", gui = "bold" },
      })

      -- Add components to right sections
      ins_right({
        "o:encoding",   -- option component same as &encoding in viml
        fmt = string.upper, -- I'm not sure why it's upper case either ;)
        cond = conditions.hide_in_width,
        color = { fg = colors.green, gui = "bold" },
      })

      ins_right({
        "fileformat",
        fmt = string.upper,
        icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
        color = { fg = colors.green, gui = "bold" },
      })

      ins_right({
        "branch",
        icon = "",
        color = { fg = colors.violet, gui = "bold" },
      })

      ins_right({
        "diff",
        -- Is it me or the symbol for modified us really weird
        symbols = { added = " ", modified = "󰝤 ", removed = " " },
        diff_color = {
          added = { fg = colors.green },
          modified = { fg = colors.orange },
          removed = { fg = colors.red },
        },
        cond = conditions.hide_in_width,
      })

      ins_right({
        function()
          return "▊"
        end,
        color = { fg = colors.blue },
        padding = { left = 1 },
      })

      -- Now don't forget to initialize lualine
      lualine.setup(config)
    end,
  },
  {
    "m4xshen/autoclose.nvim",
    config = function()
      require("autoclose").setup({
        keys = {
          ["<"] = { escape = true, close = true, pair = "<>" },
          [">"] = { escape = false, close = false, pair = "<>" },
        },
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("ibl").setup()
    end,
  },
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Set header
      dashboard.section.header.val = {
        "   ********        **               **          ",
        "  /**/////        /**              //*          ",
        "  /**       ******/**  **  ******   /   ******  ",
        "  /******* //**//*/** **  //////**     **////   ",
        "  /**////   /** / /****    *******    //*****   ",
        "  /**       /**   /**/**  **////**     /////**  ",
        "  /********/***   /**//**//********    ******   ",
        "  //////// ///    //  //  ////////    //////    ",
        "                                ",
        "                                ",
        "         ****     ** ********   *******   **      ** ** ****     **** ",
        "        /**/**   /**/**/////   **/////** /**     /**/**/**/**   **/** ",
        "        /**//**  /**/**       **     //**/**     /**/**/**//** ** /** ",
        "        /** //** /**/******* /**      /**//**    ** /**/** //***  /** ",
        "        /**  //**/**/**////  /**      /** //**  **  /**/**  //*   /** ",
        "        /**   //****/**      //**     **   //****   /**/**   /    /** ",
        "        /**    //***/******** //*******     //**    /**/**        /** ",
        "        //      /// ////////   ///////       //     // //         //  ",
      }

      -- Set menu
      dashboard.section.buttons.val = {
        dashboard.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("f", "  > Find file", ":cd $HOME/Workspace | Telescope find_files<CR>"),
        dashboard.button("r", "  > Recent", ":Telescope oldfiles<CR>"),
        dashboard.button("s", "  > Settings", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>"),
        dashboard.button("q", "󰈆  > Quit NVIM", ":qa<CR>"),
      }

      -- Set footer
      --   NOTE: This is currently a feature in my fork of alpha-nvim (opened PR #21, will update snippet if added to main)
      --   To see test this yourself, add the function as a dependecy in packer and uncomment the footer lines
      --   ```init.lua
      --   return require('packer').startup(function()
      --       use 'wbthomason/packer.nvim'
      --       use {
      --           'goolord/alpha-nvim', branch = 'feature/startify-fortune',
      --           requires = {'BlakeJC94/alpha-nvim-fortune'},
      --           config = function() require("config.alpha") end
      --       }
      --   end)
      --   ```

      -- Send config to alpha
      alpha.setup(dashboard.opts)

      -- Disable folding on alpha buffer
      vim.cmd("autocmd FileType alpha setlocal nofoldenable")
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
  {
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
    end,
  },
  -- lazy.nvim
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true,    -- use a classic bottom cmdline for search
          command_palette = true,  -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false,      -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false,  -- add a border to hover docs and signature help
        },
      })
    end,
  },
  {
    "gelguy/wilder.nvim",
    config = function()
      local wilder = require("wilder")
      wilder.setup({ modes = { ":", "/", "?" } })
    end,
  },
}
