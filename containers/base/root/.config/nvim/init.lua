-- Basic settings
vim.loader.enable()
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.g.have_nerd_font = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.api.nvim_set_hl(0, 'CursorLine', { ctermbg = 'darkgrey', bg = '#2c2c2c', underline = false })
vim.opt.scrolloff = 4
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
vim.diagnostic.config({
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
    signs = true,
    underline = true,
    update_in_insert = true,
    severity_sort = false,
})
-- Install lazy
vim.go.loadplugins = true
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Add some plugins for quality of life
local plugins = {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        init = function()
            vim.cmd.colorscheme("catppuccin")
        end,
    },
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup({
                color_icons = true,
            })
        end,
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            spec = {
                { "<leader>c", group = "[C]ode" },
                { "<leader>d", group = "[D]iagnostics" },
                { "<leader>r", group = "[R]ename" },
                { "<leader>s", group = "[S]earch" },
                { "<leader>t", group = "[T]ree/Explorer" },
            },
        },
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            quickfile = { enabled = true },
            bigfile = { enabled = true },
            notifier = { enabled = true },
            words = { enabled = true },
            picker = { enabled = true },
            explorer = { enabled = true },
            dashboard = {
                enabled = true,
                preset = {
                    header = [[

 /\\\\\_____/\\\_______________________________/\\\________/\\\___________________________
 \/\\\\\\___\/\\\______________________________\/\\\_______\/\\\__________________________
 _\/\\\/\\\__\/\\\______________________________\//\\\______/\\\___/\\\_____________________
  _\/\\\//\\\_\/\\\_____/\\\\\\\\______/\\\\\_____\//\\\____/\\\___\///_____/\\\\\__/\\\\\__
   _\/\\\\//\\\\/\\\___/\\\/////\\\___/\\\///\\\____\//\\\__/\\\_____/\\\__/\\\///\\\\\///\\\_
    _\/\\\_\//\\\/\\\__/\\\\\\\\\\\___/\\\__\//\\\____\//\\\/\\\_____\/\\\_\/\\\_\//\\\__\/\\\
     _\/\\\__\//\\\\\\_\//\\///////___\//\\\__/\\\______\//\\\\\______\/\\\_\/\\\__\/\\\__\/\\\_
      _\/\\\___\//\\\\\__\//\\\\\\\\\\__\///\\\\\/________\//\\\_______\/\\\_\/\\\__\/\\\__\/\\\
       _\///_____\/////____\//////////_____\/////___________\///________\///__\///___\///___\///__

 Hello, student.
]],
                },
                sections = {
                    { section = "header" },
                    { section = "keys", gap = 1, padding = 1 },
                    { section = "startup" },
                    {
                        text = {
                            { "\nDon't panic! Despite the memes: exiting is as easy as typing `:q`", hl = "Comment" },
                        },
                        align = "center",
                    },
                },
            },
        },
        keys = {
            -- Snacks Picker mappings
            { "<leader>sh", function() Snacks.picker.help() end, desc = "[S]earch [H]elp" },
            { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "[S]earch [K]eymaps (Cheatsheet)" },
            { "<leader>sf", function() Snacks.picker.files() end, desc = "[S]earch [F]iles" },
            { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "[S]earch current [W]ord" },
            { "<leader>sg", function() Snacks.picker.grep() end, desc = "[S]earch by [G]rep" },
            { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "[S]earch [D]iagnostics" },
            { "<leader>sr", function() Snacks.picker.resume() end, desc = "[S]earch [R]esume" },
            { "<leader>s.", function() Snacks.picker.recent() end, desc = '[S]earch Recent Files ("." for repeat)' },
            { "<leader><leader>", function() Snacks.picker.buffers() end, desc = "[ ] Find existing buffers" },
            { "<leader>/", function() Snacks.picker.lines() end, desc = "[/] Fuzzily search in current buffer" },
            { "<leader>sn", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "[S]earch [N]eovim files" },

            -- Snacks Explorer mappings
            { "<leader>tt", function() Snacks.explorer() end, desc = "[T]ree [T]oggle" },
            { "<leader>tf", function() Snacks.explorer({ focus = true }) end, desc = "[T]ree [F]ocus" },
        },
    },
    {
        "stevearc/conform.nvim",
        event = "VimEnter",
        opts = {
            notify_on_error = false,
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
            ensure_installed = { "bash", "c", "lua", "python", "java", "scala" },
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" },
        version = "*",
        opts = {
            keymap = { preset = "super-tab" },
            appearance = { nerd_font_variant = "mono" },
            completion = { documentation = { auto_show = true } },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            { "j-hui/fidget.nvim", opts = {} },
            {
                "folke/lazydev.nvim",
                ft = "lua",
                opts = {
                    library = {
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
        },
        config = function()
            require("mason").setup({ PATH = "append" })

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    -- Use Snacks for LSP integrations
                    map("gd", function() Snacks.picker.lsp_definitions() end, "[G]oto [D]efinition")
                    map("gr", function() Snacks.picker.lsp_references() end, "[G]oto [R]eferences")
                    map("gI", function() Snacks.picker.lsp_implementations() end, "[G]oto [I]mplementation")
                    map("<leader>D", function() Snacks.picker.lsp_type_definitions() end, "Type [D]efinition")
                    map("<leader>gs", function() Snacks.picker.lsp_symbols() end, "[G]oto [S]ymbols")
                    map("<leader>ws", function() Snacks.picker.lsp_workspace_symbols() end, "[W]orkspace [S]ymbols")
                    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
                    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
                    map("K", vim.lsp.buf.hover, "Hover Documentation")
                    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider then
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = event.buf,
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = event.buf,
                            callback = vim.lsp.buf.clear_references,
                        })
                    end
                end,
            })

            -- Integrate blink.cmp with lspconfig capabilities
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            if pcall(require, "blink.cmp") then
                capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
            end

            local servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = { callSnippet = "Replace" },
                        },
                    },
                },
            }

            local ensure_installed = vim.tbl_keys(servers or {})
            require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
            require("mason-lspconfig").setup({
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend(
                            "force",
                            {},
                            capabilities,
                            server.capabilities or {}
                        )
                        require("lspconfig")[server_name].setup(server)
                    end,
                },
            })
        end,
    },
    {
        "echasnovski/mini.nvim",
        config = function()
            require("mini.ai").setup({ n_lines = 500 })
            require("mini.comment").setup()
            require("mini.pairs").setup({ mappings = { ["`"] = false } })
            require("mini.sessions").setup()
            require("mini.splitjoin").setup()
            require("mini.statusline").setup()
            require("mini.surround").setup()
            require("mini.trailspace").setup()
            require("mini.visits").setup()
        end,
    },
    { "MunifTanjim/nui.nvim", lazy = true },
}

require("lazy").setup(plugins, {})
