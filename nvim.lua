-- DEBUG: echo exepath('server_executable')
-- Cool shortcuts: >i} (indent inside of {}) or any symbol.

vim.cmd([[
    set number
    set relativenumber
    let mapleader = " "

    set clipboard+=unnamedplus

    set tabstop=4 " The width of a TAB is set to 4.
    set softtabstop=4 " Sets the number of columns for a TAB.
    set shiftwidth=4 " Indents will have a width of 4.
    set expandtab " Expand TABS to spaces.
    set scrolloff=8
    " set nowrap
    " set textwidth=80
    set foldmethod=marker
    set ff=unix

    let g:gruvbox_contrast_dark = 'hard'
    colorscheme gruvbox
    set termguicolors
    set bg=dark

    syntax enable

    " source file
    nnoremap <C-s> :source<CR>

    " Quick navigation 
    nnoremap <M-C-f> :find 
    nnoremap <M-f> /

    " Tabbing for indent mode
    nnoremap <Tab> :cindent<CR>

    " Tabbing for select mode?
    vnoremap <Tab> > 
    vnoremap <S-Tab> <
    " inoremap <Tab> >gv<CR>

    " Checks if there is a file open after Vim starts up,
    " and if not, open the current working directory in Netrw.
    augroup InitNetrw
      autocmd!
      autocmd VimEnter * if expand("%") == "" | edit . | endif
    augroup END

    " Ensure the buffer for building code opens in a new view, does it?
    " set switchbuf=uselast,split

    " Thanks to https://forums.handmadehero.org/index.php/forum?view=topic&catid=4&id=704#3982
    " error message formats
    " Microsoft MSBuild
    set errorformat+=\\\ %#%f(%l\\\,%c):\ %m
    " Microsoft compiler: cl.exe
    set errorformat+=\\\ %#%f(%l)\ :\ %#%t%[A-z]%#\ %m
    " Microsoft HLSL compiler: fxc.exe
    set errorformat+=\\\ %#%f(%l\\\,%c-%*[0-9]):\ %#%t%[A-z]%#\ %m
     
    function! BuildProject()
        " save the current working directory so we can come back
        let l:starting_directory = getcwd()

        " get the directory of the currently focused file
        let l:curr_directory = expand('%:p:h')
        " move to the current file
        execute "cd " . l:curr_directory

        while 1
            " check if build.bat exists in the current directory
            " TODO: make this not remove window if nothing happens
            if filereadable("build.bat")
                " run make and exit
                set makeprg=build
                silent make 
                wincmd o " there shall only be one
                vert copen 85" open vertically
                wincmd p " keep cursor on previous window
                wincmd r " rotate windows
                " wincmd = " full size pls
                echo 'Compilation finished'
            break
            elseif l:curr_directory ==# "/" || l:curr_directory =~# '^[^/]..$'
                " if we've hit the top level directory, break out
                break
            else
                " move up a directory
                cd ..
                let l:curr_directory = getcwd()
            endif
        endwhile

        "reset directory
        execute "cd " . l:starting_directory
    endfunction

    function! ExecutePython()
        wincmd o " there shall only be one
        execute ":vs"
        execute ":term python3 %"
        wincmd r " rotate windows
        wincmd p " keep cursor on previous window
    endfunction

    function! ExecutePythonTestShell()
        wincmd o " there shall only be one
        execute ":vert copen 65"
        cd ..
        execute ":term ./test.sh"
        wincmd r " rotate windows
        wincmd p " keep cursor on previous window
    endfunction

    "Go to next error
    nnoremap <leader>n :cn<CR>
    "Go to previous error
    nnoremap <leader>p :cp<CR>
     
    " Set leader+b to build. I like this since I use visual studio with the c++ build env
    " nnoremap <leader>b :call DoBuildBatchFile()<CR>
    
    " execute c file for casey
    " nnoremap <M-m> :call BuildProject()<CR>

    " execute current python file
    " nnoremap <M-m> :call ExecutePython()<CR>

    " execute test python file
    " nnoremap <M-p> :call ExecutePythonTestShell()<CR>

    " autocmd! FileType qf nnoremap <buffer> <leader><Enter> <C-w><Enter><C-w>L

    " Opens netrw
    nnoremap <leader>pv :Explore<CR>

    " just splits a window vertically
    nnoremap <leader>v :vsplit<CR>

    " just splits a window horizontally
    nnoremap <leader>h :split<CR>

    " This is set hidden to prevent the deletion of buffers
    " if they go out of view.
    set hidden

    " close preview window/scratch buffer
    set completeopt+=menu,noselect,noinsert " don't insert text automatically
    " set completeopt+=menu
    autocmd CompleteDone * pclose " close preview window

    set pumheight=5 " keep the autocomplete suggestion menu small
    set shortmess+=c " don't give ins-completion-menu messages

    " use tab for navigating the autocomplete menu
    inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

    " automatically remove highlighting for searches
    set incsearch 
    autocmd CmdlineEnter /,\? :set hlsearch
    autocmd CmdlineLeave /,\? :set nohlsearch

    " clear screen of highlights (probably not necessary anymore)
    nnoremap <nowait><silent> <leader>l :noh<CR>
   
    " to map <Esc> to exit terminal-mode
    tnoremap <Esc> <C-\><C-n>
]])

-- Insert Caseys source format
vim.api.nvim_create_autocmd({"BufNewFile"}, {
    pattern = {"*.cpp"},
    command = 'norm i' ..
        '/* ========================================================================\n' ..
        '$File: $\n' ..
        '$Date: $\n' ..
        '$Revision: $\n' ..
        '$Creator: Casey Muratori $\n' ..
        '$Notice: (C) Copyright 2014 by Molly Rocket, Inc. All Rights Reserved. $\n' ..
        '======================================================================== */\n' 
})

-- TODO(filip): add include guard to header file
-- Insert Caseys header format
vim.api.nvim_create_autocmd({"BufNewFile"}, {
    pattern = {"*.h"},
    command = 'norm i' ..
        '#if !defined(' ..
        'BaseFileName' ..
        '_H' ..
        ')\n' ..
        '/* ========================================================================\n' ..
        '$File: $\n' ..
        '$Date: $\n' ..
        '$Revision: $\n' ..
        '$Creator: Casey Muratori $\n' ..
        '$Notice: (C) Copyright 2014 by Molly Rocket, Inc. All Rights Reserved. $\n' ..
        '======================================================================== */\n' ..
        '#define ' ..
        'BaseFileName' ..
        '_H\n' ..
        '#endif'
})

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
        end
      },
})

-- LSP config for C/C++
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = {"*.c", "*.h", "*.cpp"},
    callback = function()
        vim.lsp.start({
            name = 'c-lsp',
            cmd = {'clangd'},
        })
    end
})

-- LSP config for Python 
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = {"*.py"},
    callback = function()
        vim.lsp.start({
            name = 'python-lsp',
            cmd = {'jedi-language-server'},
        })
    end
})

-- LSP config for Javacript/Typescript 
-- vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
--     pattern = {"*.js", "*.ts", "*.tsx"},
--     callback = function()
--         vim.lsp.start({
--             name = 'js-lsp',
--             cmd = {'typescript-language-server.cmd', '--stdio'}
--         })
--     end
-- })

-- Set filetype to hcl for .tf files
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.tf", "*.tfvars", "*.tfstack.hcl", "*.tfdeploy.hcl"},
    callback = function()
        vim.bo.filetype = "hcl"
    end
})
-- LSP config for Terraform 
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = {"*.tf", "*.tfvars", "*.tfstack.hcl", "*.tfdeploy.hcl"},
    callback = function()
        vim.lsp.start({
            name = 'terraform-ls',
            cmd = {'terraform-ls', 'serve'}
        })
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

-- toggles C LSP on and off
function toggle_lsp() 
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
        vim.lsp.start({
            name = 'c-lsp',
            cmd = {'clangd'},
        })
    else 
        vim.lsp.stop_client(vim.lsp.get_active_clients())
    end 
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
vim.keymap.set("n", '<M-r>', toggle_lsp)
vim.keymap.set("n", '<leader>t', function() vim.cmd.terminal() end)

-- https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.cmd([[autocmd FileType * set formatoptions-=ro]])


