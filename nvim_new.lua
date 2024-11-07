-- Cool shortcuts: >i} (indent inside of {}) or any symbol.

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Leader key
vim.g.mapleader = " "

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

-- Colorscheme and background
vim.g.gruvbox_contrast_dark = "hard"
vim.cmd("colorscheme gruvbox")
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- Enable syntax highlighting
vim.cmd("syntax enable")

-- Source file with <C-s>
vim.keymap.set("n", "<C-s>", ":source<CR>")

-- Quick navigation
vim.keymap.set("n", "<M-C-f>", ":find ")
vim.keymap.set("n", "<M-f>", "/")

-- Tabbing for indent mode
vim.keymap.set("n", "<Tab>", ":cindent<CR>")

-- Tabbing for visual mode
vim.keymap.set("v", "<Tab>", ">")
vim.keymap.set("v", "<S-Tab>", "<")

-- Open Netrw in current directory if no file is open
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.expand("%") == "" then
            vim.cmd("edit .")
        end
    end,
})

-- Set errorformats for different compilers
vim.opt.errorformat:append("\\ %#%f(%l\\,%c): %m")          -- MSBuild
vim.opt.errorformat:append("\\ %#%f(%l): %#%t%[A-z]%# %m")  -- cl.exe
vim.opt.errorformat:append("\\ %#%f(%l\\,%c-%*[0-9]): %#%t%[A-z]%# %m")  -- fxc.exe

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

-- Set hidden buffers
vim.opt.hidden = true

-- Set up completion options
vim.opt.completeopt = { "menu", "noselect", "noinsert" }
vim.api.nvim_create_autocmd("CompleteDone", {
    callback = function()
        vim.cmd("pclose")
    end,
})

vim.opt.pumheight = 5
vim.opt.shortmess:append("c")

-- Use Tab for navigating autocomplete menu
vim.keymap.set("i", "<Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
vim.keymap.set("i", "<S-Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

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

-- Clear screen highlights
vim.keymap.set("n", "<leader>l", ":noh<CR>")

-- Exit terminal mode with Esc
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

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

-- Beautiful highlights =D
-- IF contrast is medium, fg = #282828
-- IF contrast is hard, fg = #1d2021
vim.api.nvim_set_hl(0, "NOTE", {underline=true,reverse=true,fg="#1d2021",bg="Green" })
vim.api.nvim_set_hl(0, "TODO", {underline=true,reverse=true,fg="#1d2021",bg="Red"})
vim.api.nvim_set_hl(0, "IMPORTANT", {underline=true,reverse=true,fg="#1d2021",bg="Yellow"})
vim.api.nvim_set_hl(0, "STUDY", {underline=true,reverse=true,fg="#1d2021",bg="Yellow"})

-- Need to execute matchadd for the new highlight group Note
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.fn.execute("execute matchadd(\"Note\", \"NOTE\")")
        vim.fn.execute("execute matchadd(\"Important\", \"IMPORTANT\")")
        vim.fn.execute("execute matchadd(\"Study\", \"STUDY\")")
    end
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
    {
    -- add your plugins here
    'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',  -- Automatically update parsers when needed
        config = function()
          require'nvim-treesitter.configs'.setup {
            -- Install the languages you need, or use "maintained" for all maintained parsers
            ensure_installed = {"typescript", "c", "hcl"}, -- Adjust to the languages you need
            highlight = {
              enable = true,  -- Enable syntax highlighting using Treesitter
              additional_vim_regex_highlighting = false,  -- Disable Vim regex-based highlighting
            },
            incremental_selection = {
              enable = true,
              keymaps = {
                init_selection = "<CR>",  -- Start a selection
                node_incremental = "<Tab>",  -- Select the next node
                node_decremental = "<S-Tab>",  -- Select the previous node
              },
            },
            indent = {
              enable = true,  -- Enable Treesitter-based indentation
            },
          }
      end
      },
     -- Install nvim-lspconfig for LSP support
      {
        'neovim/nvim-lspconfig',
        config = function()
          local lspconfig = require('lspconfig')
          local util = require('lspconfig.util')

          -- Configure Deno LSP
          lspconfig.denols.setup{
            root_dir = util.root_pattern('deno.json', 'deno.jsonc'),
            settings = {
              deno = {
                enable = true,
                unstable = true,  -- Optional: Enable unstable APIs if needed
              },
            },
          }

          -- Configure TypeScript LSP (tsserver)
          lspconfig.ts_ls.setup{
            root_dir = util.root_pattern('tsconfig.json', 'package.json', '.git'),
            on_attach = function(client, bufnr)
              -- Disable tsserver in Deno projects
              if util.root_pattern('deno.json', 'deno.jsonc')(vim.fn.bufname(bufnr)) then
                client.stop()
              end
            end,
          }

          lspconfig.clangd.setup{}

          lspconfig.pylsp.setup{
              settings = {
                pylsp = {
                  plugins = {
                    pycodestyle = {
                      ignore = {'W391'},
                      maxLineLength = 100
                    }
                  }
                }
              }
            }

          lspconfig.terraformls.setup{}
        end
      },
})

-- Set filetype to hcl for .tf files
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.tf", "*.tfvars", "*.tfstack.hcl", "*.tfdeploy.hcl"},
    callback = function()
        vim.bo.filetype = "hcl"
    end
})

-- Toggle LSP diagnostics
vim.api.nvim_create_user_command("DiagnosticToggle", function()
	local config = vim.diagnostic.config
	local vt = config().virtual_text
	config {
		virtual_text = not vt,
		underline = not vt,
		signs = not vt,
	}
end, { desc = "toggle diagnostic" })

-- Hover
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.server_capabilities.hoverProvider then
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = args.buf })
    end
  end,
})

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

-- Removes highlighting from LSP
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    client.server_capabilities.semanticTokensProvider = true
  end,
});

-- Uses omnifunc for autocompletion
vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

-- Hotkeys <C-x-c-o>
vim.keymap.set("n", "<M-d>", vim.cmd.DiagnosticToggle)
vim.keymap.set('i', '<C-d>', '<c-n>', {noremap = true})
vim.keymap.set('i', '<C-f>', '<c-x><c-o>', {noremap = true})
vim.keymap.set("n", 'gD', definition_split)
vim.keymap.set("n", 'gd', vim.lsp.buf.definition)
vim.keymap.set("n", '<leader>t', function() vim.cmd.terminal() end)

-- https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.cmd([[autocmd FileType * set formatoptions-=ro]])
