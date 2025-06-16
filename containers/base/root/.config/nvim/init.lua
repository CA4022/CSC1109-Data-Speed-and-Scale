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
if not vim.loop.fs_stat(lazypath) then
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
-- Extra keybindings
keys = {
    groups = {
        { "<leader>s", group = "[S]earch" },
        { "<leader>c", group = "[C]ode" },
        { "<leader>d", group = "[D]iagnostics" },
        { "<leader>r", group = "[R]ename" },
        { "<leader>t", group = "[T]ree" },
    },
    neotree = {
        {
            "<leader>tt",
            function()
                vim.api.nvim_command("Neotree toggle")
            end,
            desc = "[T]ree [T]oggle",
            mode = "n",
        },
        {
            "<leader>ts",
            function()
                vim.api.nvim_command("Neotree show")
            end,
            desc = "[T]ree [S]how",
            mode = "n",
        },
        {
            "<leader>tc",
            function()
                vim.api.nvim_command("Neotree close")
            end,
            desc = "[T]ree [C]lose",
            mode = "n",
        },
        {
            "<leader>tf",
            function()
                vim.api.nvim_command("Neotree focus")
            end,
            desc = "[T]ree [F]ocus",
            mode = "n",
        },
        {
            "<leader>tg",
            function()
                vim.api.nvim_command("Neotree git_status")
            end,
            desc = "[T]ree [G]it Status",
            mode = "n",
        },
        {
            "<leader>tb",
            function()
                vim.api.nvim_command("Neotree buffers")
            end,
            desc = "[T]ree [B]uffers",
            mode = "n",
        },
    },
    telescope = function(telescope_builtin)
        return {
            {
                "<leader>sh",
                telescope_builtin.help_tags,
                desc = "[S]earch [H]elp",
                mode = "n",
            },
            {
                "<leader>sk",
                telescope_builtin.keymaps,
                desc = "[S]earch [K]eymaps",
                mode = "n",
            },
            {
                "<leader>sf",
                telescope_builtin.find_files,
                desc = "[S]earch [F]iles",
                mode = "n",
            },
            {
                "<leader>sb",
                telescope_builtin.find_files,
                desc = "[S]earch file [B]rowser",
                mode = "n",
            },
            {
                "<leader>ss",
                telescope_builtin.builtin,
                desc = "[S]earch [S]elect Telescope",
                mode = "n",
            },
            {
                "<leader>sw",
                telescope_builtin.grep_string,
                desc = "[S]earch current [W]ord",
                mode = "n",
            },
            {
                "<leader>sg",
                telescope_builtin.live_grep,
                desc = "[S]earch by [G]rep",
                mode = "n",
            },
            {
                "<leader>sd",
                telescope_builtin.diagnostics,
                desc = "[S]earch [D]iagnostics",
                mode = "n",
            },
            {
                "<leader>sr",
                telescope_builtin.resume,
                desc = "[S]earch [R]esume",
                mode = "n",
            },
            {
                "<leader>s.",
                telescope_builtin.oldfiles,
                desc = '[S]earch Recent Files ("." for repeat)',
                mode = "n",
            },
            {
                "<leader><leader>",
                telescope_builtin.buffers,
                desc = "[ ] Find existing buffers",
                mode = "n",
            },
            {
                "<leader>/",
                function()
                    telescope_builtin.current_buffer_fuzzy_find(
                        require("telescope.themes").get_dropdown({
                            winblend = 10,
                            previewer = false,
                        })
                    )
                end,
                desc = "[/] Fuzzily search in current buffer",
                mode = "n",
            },
            {
                "<leader>s/",
                function()
                    telescope_builtin.live_grep({
                        grep_open_files = true,
                        prompt_title = "Live Grep in Open Files",
                    })
                end,
                desc = "[S]earch [/] in Open Files",
                mode = "n",
            },
            {
                "<leader>sn",
                function()
                    telescope_builtin.find_files({ cwd = vim.fn.stdpath("config") })
                end,
                desc = "[S]earch [N]eovim files",
                mode = "n",
            },
        }
    end,
}
-- Add some plugins for quality of life
plugins = {
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
        event = "VimEnter",
        config = function()
            local wk = require("which-key")
            local groups = keys.groups
            wk.add(groups)
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        event = "VimEnter",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
            { "nvim-telescope/telescope-ui-select.nvim" },
            { "nvim-tree/nvim-web-devicons",               enabled = vim.g.have_nerd_font },
            { "nvim-telescope/telescope-file-browser.nvim" },
        },
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown(),
                    },
                },
            })
            pcall(require("telescope").load_extension, "fzf")
            pcall(require("telescope").load_extension, "ui-select")
            pcall(require("telescope").load_extension, "file-browser")
        end,
        keys = function()
            keys.telescope(require("telescope.builtin"))
        end,
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
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                build = (function()
                    if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                        return
                    end
                    return "make install_jsregexp"
                end)(),
            },
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            luasnip.config.setup({})
            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = { completeopt = "menu,menuone,noinsert" },

                mapping = cmp.mapping.preset.insert({
                    ["<M-n>"] = cmp.mapping.select_next_item(),
                    ["<M-p>"] = cmp.mapping.select_prev_item(),
                    ["<M-y>"] = cmp.mapping.confirm({ select = true }),
                    ["<M-Space>"] = cmp.mapping.complete({}),
                    ["<M-,>"] = cmp.mapping(function()
                        if luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        end
                    end, { "i", "s" }),
                    ["<M-.>"] = cmp.mapping(function()
                        if luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        end
                    end, { "i", "s" }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            { "j-hui/fidget.nvim", opts = {} },
            { "folke/neodev.nvim", opts = {} },
        },
        config = function()
            require("mason").setup({
                PATH = "append",
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set(
                            "n",
                            keys,
                            func,
                            { buffer = event.buf, desc = "LSP: " .. desc }
                        )
                    end
                    map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
                    map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
                    map(
                        "gI",
                        require("telescope.builtin").lsp_implementations,
                        "[G]oto [I]mplementation"
                    )
                    map(
                        "<leader>D",
                        require("telescope.builtin").lsp_type_definitions,
                        "Type [D]efinition"
                    )
                    map(
                        "<leader>gs",
                        require("telescope.builtin").lsp_document_symbols,
                        "[G]oto [S]ymbols"
                    )
                    map(
                        "<leader>ws",
                        require("telescope.builtin").lsp_dynamic_workspace_symbols,
                        "[W]orkspace [S]ymbols"
                    )
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
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend(
                "force",
                capabilities,
                require("cmp_nvim_lsp").default_capabilities()
            )
            local servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                },
            }
            require("mason").setup()
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
            require("mini.completion").setup()
            require("mini.cursorword").setup()
            require("mini.pairs").setup({ mappings = { ["`"] = false } })
            require("mini.sessions").setup()
            require("mini.splitjoin").setup()
            local starter = require('mini.starter')
            local logo = {
                [[                                                                                                   ]],
                [[ /\\\\\_____/\\\_______________________________/\\\________/\\\___________________________         ]],
                [[ \/\\\\\\___\/\\\______________________________\/\\\_______\/\\\__________________________         ]],
                [[ _\/\\\/\\\__\/\\\______________________________\//\\\______/\\\___/\\\_____________________       ]],
                [[  _\/\\\//\\\_\/\\\_____/\\\\\\\\______/\\\\\_____\//\\\____/\\\___\///_____/\\\\\__/\\\\\__       ]],
                [[   _\/\\\\//\\\\/\\\___/\\\/////\\\___/\\\///\\\____\//\\\__/\\\_____/\\\__/\\\///\\\\\///\\\_     ]],
                [[    _\/\\\_\//\\\/\\\__/\\\\\\\\\\\___/\\\__\//\\\____\//\\\/\\\_____\/\\\_\/\\\_\//\\\__\/\\\     ]],
                [[     _\/\\\__\//\\\\\\_\//\\///////___\//\\\__/\\\______\//\\\\\______\/\\\_\/\\\__\/\\\__\/\\\_   ]],
                [[      _\/\\\___\//\\\\\__\//\\\\\\\\\\__\///\\\\\/________\//\\\_______\/\\\_\/\\\__\/\\\__\/\\\   ]],
                [[       _\///_____\/////____\//////////_____\/////___________\///________\///__\///___\///___\///__ ]],
                [[                                                                                                   ]],
            }
            require("mini.starter").setup({
                header = table.concat(logo, "\n") .. "\n Hello, student.",
                items = {
                    starter.sections.recent_files(5, false, false),
                    starter.sections.telescope(),
                },
                footer = "Don't panic! Despite the memes: exiting is as easy as typing `:q`",
            })
            require("mini.statusline").setup()
            require("mini.surround").setup()
            require("mini.trailspace").setup()
            require("mini.visits").setup()
            local notify = require("mini.notify")
            notify.setup()
            vim.notify = notify.make_notify({
                ERROR = { duration = 5000 },
                WARN = { duration = 4000 },
                INFO = { duration = 3000 },
            })
        end,
    },
    { "MunifTanjim/nui.nvim", lazy = true },
    {
        "folke/which-key.nvim",
        event = "VimEnter",
    },
    {
        "sudormrfbin/cheatsheet.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/popup.nvim",
            "nvim-lua/plenary.nvim",
        },
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            quickfile = { enabled = true },
        },
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        event = "VimEnter",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        keys = keys.neotree,
    },
}
require("lazy").setup(plugins, opts)
