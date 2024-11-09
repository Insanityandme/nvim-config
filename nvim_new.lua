-- Cool shortcut: >i} (indent inside of {}) or any symbol.

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Clipboard support
vim.opt.clipboard:append("unnamedplus")

-- Indentation settings
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 8
-- vim.opt.wrap = false
-- vim.opt.textwidth = 80
vim.opt.foldmethod = "marker"
vim.opt.fileformat = "unix"

-- Disable the Sign Column
vim.opt.signcolumn = "no"

-- Enable syntax highlighting
vim.cmd("syntax enable")

-- Source file with <C-s>
vim.keymap.set("n", "<C-s>", ":source<CR>")

-- Quick navigation
vim.keymap.set("n", "<M-C-f>", ":find ")
vim.keymap.set("n", "<M-f>", "/")

-- Indent in Normal mode
vim.api.nvim_set_keymap('n', '<Tab>', '>>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-Tab>', '<<', { noremap = true, silent = true })

-- Indent in Visual and Visual Line modes
vim.api.nvim_set_keymap('x', '<Tab>', '>gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<S-Tab>', '<gv', { noremap = true, silent = true })

-- Go to next/previous error
vim.keymap.set("n", "<leader>n", ":cn<CR>")
vim.keymap.set("n", "<leader>p", ":cp<CR>")

-- Set leader+b to build (commented out)
-- vim.keymap.set("n", "<leader>b", ":call DoBuildBatchFile()<CR>")

-- Open Netrw
vim.keymap.set("n", "<leader>pv", ":Explore<CR>")

-- Split windows
vim.keymap.set("n", "<leader>v", ":vsplit<CR>")
vim.keymap.set("n", "<leader>h", ":split<CR>")

-- Clear screen highlights
vim.keymap.set("n", "<leader>l", ":noh<CR>")

-- Exit terminal mode with Esc
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- Go to definition (in a split)
function definition_split()
  vim.lsp.buf.definition({
    on_list = function(options)
      -- if there are multiple items, warn the user
      if #options.items > 1 then
        vim.notify("Multiple items found, opening first one", vim.log.levels.WARN)
      end

      -- Open the first item in a vertical split
      local item = options.items[1]
      local cmd = "vsplit +" .. item.lnum .. " " .. item.filename .. "|" .. "normal " .. item.col .. "|"

      vim.cmd("wincmd o")
      vim.cmd(cmd)
      vim.cmd("wincmd p")
      vim.cmd("wincmd r")
    end,
  })
end

-- Force .tf files to be detected as hcl
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.tf", "*.tfvars", "*.tfstack.hcl", "*.tfdeploy.hcl" },
  command = 'set filetype=hcl'
})

-- Hotkeys for LSP stuff
vim.keymap.set("n", "<M-d>", vim.cmd.DiagnosticToggle)
vim.keymap.set('i', '<C-d>', '<c-n>', { noremap = true })
vim.keymap.set('i', '<C-f>', '<c-x><c-o>', { noremap = true })
vim.keymap.set("n", 'gD', definition_split)
vim.keymap.set("n", 'gd', vim.lsp.buf.definition)
vim.keymap.set("n", '<leader>t', function() vim.cmd.terminal() end)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.cmd([[autocmd FileType * set formatoptions-=ro]]) -- Rename the variable under your cursor.

--  Most Language Servers support renaming across files, etc.
vim.keymap.set("n", "<M-r>", vim.lsp.buf.rename, { noremap = true, })
vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format()
end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>r", function()
  vim.cmd("registers")
end, { noremap = true, silent = true }
)

vim.opt.pumheight = 5
vim.opt.shortmess:append("c")

-- Set hidden buffers
vim.opt.hidden = true

-- Open Netrw in current directory if no file is open
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.expand("%") == "" then
      vim.cmd("edit .")
    end
  end,
})

-- Create an autocmd group for Lua file settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.bo.shiftwidth = 2   -- Set the number of spaces for each step of indentation
    vim.bo.tabstop = 2      -- Set the number of spaces that a <Tab> represents
    vim.bo.softtabstop = 2  -- Number of spaces that <Tab> or <BS> inserts/deletes
    vim.bo.expandtab = true -- Use spaces instead of tabs
  end,
})

-- Set errorformats for different compilers
vim.opt.errorformat:append("\\ %#%f(%l\\,%c): %m")                      -- MSBuild
vim.opt.errorformat:append("\\ %#%f(%l): %#%t%[A-z]%# %m")              -- cl.exe
vim.opt.errorformat:append("\\ %#%f(%l\\,%c-%*[0-9]): %#%t%[A-z]%# %m") -- fxc.exe

-- BuildProject C function
function BuildProject()
  local starting_directory = vim.fn.getcwd()
  local curr_directory = vim.fn.expand("%:p:h")
  vim.cmd("cd " .. curr_directory)

  while true do
    if vim.fn.filereadable("build.bat") == 1 then
      vim.opt.makeprg = "build.bat"
      vim.cmd("silent make")
      vim.cmd("wincmd o")
      vim.cmd("vert copen 85")
      vim.cmd("wincmd p")
      vim.cmd("wincmd r")
      print("Compilation finished")
      break
    elseif curr_directory == "/" or curr_directory:match("^[^/].$") then
      break
    else
      vim.cmd("cd ..")
      curr_directory = vim.fn.getcwd()
    end
  end
  vim.cmd("cd " .. starting_directory)
end

-- ExecutePython function
function ExecutePython()
  vim.cmd("wincmd o")
  vim.cmd("vs")
  vim.cmd("term python3 %")
  vim.cmd("wincmd r")
  vim.cmd("wincmd p")
end

-- ExecutePythonTestShell function
function ExecutePythonTestShell()
  vim.cmd("wincmd o")
  vim.cmd("vert copen 65")
  vim.cmd("cd ..")
  vim.cmd("term ./test.sh")
  vim.cmd("wincmd r")
  vim.cmd("wincmd p")
end

-- Set up completion options
vim.opt.completeopt = { "menu", "noselect", "noinsert" }
vim.api.nvim_create_autocmd("CompleteDone", {
  callback = function()
    vim.cmd("pclose")
  end,
})

-- Auto-remove highlighting after searches
vim.opt.incsearch = true
vim.api.nvim_create_autocmd("CmdlineEnter", {
  pattern = { "/", "\\?" },
  callback = function()
    vim.opt.hlsearch = true
  end,
})
vim.api.nvim_create_autocmd("CmdlineLeave", {
  pattern = { "/", "\\?" },
  callback = function()
    vim.opt.hlsearch = false
  end,
})

-- Beautiful highlights =D
-- IF contrast is medium, fg = #282828
-- IF contrast is hard, fg = #1d2021
vim.api.nvim_set_hl(0, "NOTE", { underline = true, reverse = true, fg = "#1d2021", bg = "Green" })
vim.api.nvim_set_hl(0, "TODO", { underline = true, reverse = true, fg = "#1d2021", bg = "Red" })
vim.api.nvim_set_hl(0, "IMPORTANT", { underline = true, reverse = true, fg = "#1d2021", bg = "Yellow" })
vim.api.nvim_set_hl(0, "STUDY", { underline = true, reverse = true, fg = "#1d2021", bg = "Yellow" })

-- Need to execute matchadd for the new highlight group Note
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.fn.execute("execute matchadd(\"Note\", \"NOTE\")")
    vim.fn.execute("execute matchadd(\"Important\", \"IMPORTANT\")")
    vim.fn.execute("execute matchadd(\"Study\", \"STUDY\")")
  end
})

-- Define cmp_enabled outside the function to track its state across toggles
local cmp_enabled = true

vim.api.nvim_create_user_command("DiagnosticToggle", function()
  -- Toggle diagnostic settings
  local config = vim.diagnostic.config
  local diagnostics_enabled = config().virtual_text
  config {
    virtual_text = not diagnostics_enabled,
    underline = not diagnostics_enabled,
    signs = not diagnostics_enabled,
  }

  -- Toggle nvim-cmp enabled state
  cmp_enabled = not cmp_enabled
  require('cmp').setup({
    enabled = function()
      return cmp_enabled
    end
  })

  -- Notify the user about the current state
  print("Diagnostics are " .. (diagnostics_enabled and "disabled" or "enabled"))
  print("nvim-cmp is " .. (cmp_enabled and "enabled" or "disabled"))
end, { desc = "Toggle LSP diagnostics and nvim-cmp" })

-- Hover
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.server_capabilities.hoverProvider then
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = args.buf })
    end
  end,
})

-- Removes highlighting from LSP
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    client.server_capabilities.semanticTokensProvider = true
  end,
});

-- Uses omnifunc for autocompletion
vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

-- Insert Caseys source format
-- vim.api.nvim_create_autocmd({"BufNewFile"}, {
--     pattern = {"*.cpp"},
--     command = 'norm i' ..
--         '/* ========================================================================\n' ..
--         '$File: $\n' ..
--         '$Date: $\n' ..
--         '$Revision: $\n' ..
--         '$Creator: Casey Muratori $\n' ..
--         '$Notice: (C) Copyright 2014 by Molly Rocket, Inc. All Rights Reserved. $\n' ..
--         '======================================================================== */\n'
-- })

-- Insert Caseys header format
-- vim.api.nvim_create_autocmd({"BufNewFile"}, {
--     pattern = {"*.h"},
--     command = 'norm i' ..
--         '#if !defined(' ..
--         'BaseFileName' ..
--         '_H' ..
--         ')\n' ..
--         '/* ========================================================================\n' ..
--         '$File: $\n' ..
--         '$Date: $\n' ..
--         '$Revision: $\n' ..
--         '$Creator: Casey Muratori $\n' ..
--         '$Notice: (C) Copyright 2014 by Molly Rocket, Inc. All Rights Reserved. $\n' ..
--         '======================================================================== */\n' ..
--         '#define ' ..
--         'BaseFileName' ..
--         '_H\n' ..
--         '#endif'
-- })

-- Automatically run python tests when saving a .py file
-- vim.api.nvim_create_autocmd({"BufWritePost"}, {
--     pattern = {"*.py"},
--     command = ':call ExecutePythonTestShell()'
-- })

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = ... },
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        -- Install the languages you need, or use "maintained" for all maintained parsers
        ensure_installed = { 'typescript', 'c', 'hcl', 'bash', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'jsdoc', 'css', 'html', 'editorconfig', 'go', 'gitignore', 'gitattributes', 'json', 'java' },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
          enable = true,
          disable = { "c" }, -- Disable Treesitter highlighting for C
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true, disable = { 'ruby' } },
      }
    end,
  },

  -- Install nvim-lspconfig for LSP support
  {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require('lspconfig')
      local util = require('lspconfig.util')

      -- Configure Deno LSP
      lspconfig.denols.setup {
        root_dir = util.root_pattern('deno.json', 'deno.jsonc'),
        settings = {
          deno = {
            enable = true,
            unstable = true, -- Optional: Enable unstable APIs if needed
          },
        },
      }
      lspconfig.clangd.setup {}
      lspconfig.lua_ls.setup {}

      lspconfig.pylsp.setup {
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = {
                ignore = { 'W391' },
                maxLineLength = 100
              }
            }
          }
        }
      }

      lspconfig.terraformls.setup {}
      -- Configure TypeScript LSP (tsserver)
      -- lspconfig.ts_ls.setup{
      --   root_dir = util.root_pattern('tsconfig.json', 'package.json', '.git'),
      --   on_attach = function(client, bufnr)
      --     -- Disable tsserver in Deno projects
      --     if util.root_pattern('deno.json', 'deno.jsonc')(vim.fn.bufname(bufnr)) then
      --       client.stop()
      --     end
      --   end,
      -- }
    end

  },


  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          -- ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          -- ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          ['<Tab>'] = cmp.mapping.confirm { select = true },
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },
})

-- Default options:
require("gruvbox").setup({
  terminal_colors = true, -- add neovim terminal colors
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = false,
    emphasis = true,
    comments = false,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true,    -- invert background for search, diffs, statuslines and errors
  contrast = "hard", -- can be "hard", "soft" or empty string, change this if you want a softer BG!
  palette_overrides = {
  },
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
})

-- Colorscheme and background
vim.g.gruvbox_contrast_dark = "hard"
vim.cmd("colorscheme gruvbox")
vim.opt.termguicolors = true
vim.opt.background = "dark"
