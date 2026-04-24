vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Options ]]
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.breakindent = true
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
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 20
vim.opt.hlsearch = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.confirm = true

-- deferred to avoid slowing startup
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- [[ Keymaps ]]
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- [[ Diagnostics ]]
vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },
	virtual_text = false,
	virtual_lines = true,
	jump = { float = true },
})

-- [[ Autocommands ]]
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- [[ lazy.nvim bootstrap ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	},

	{ "saecki/crates.nvim", tag = "stable", opts = {} },

	"github/copilot.vim",
	"tpope/vim-sleuth",

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup({ notify = false })
			require("which-key").add({
				{ "<leader>c", group = "[C]ode" },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>w", group = "[W]orkspace" },
			})
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		event = "VeryLazy",
		branch = "master",
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
		},
		config = function()
			require("telescope").setup({
				defaults = {
					preview = { treesitter = true },
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })
			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
			end, { desc = "[S]earch [/] in Open Files" })
			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	{
		"mason-org/mason.nvim",
		dependencies = {
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
					map("K", vim.lsp.buf.hover, "Hover Documentation")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_clients({ id = event.data.client_id })[1]
					if not client then
						return
					end

					if client:supports_method("textDocument/documentHighlight", event.buf) then
						local hlgroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = hlgroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = hlgroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if client:supports_method("textDocument/inlayHint", event.buf) then
						vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
					end
				end,
			})

			local capabilities = require("blink.cmp").get_lsp_capabilities()
			vim.lsp.config("*", { capabilities = capabilities })

			vim.lsp.config.gopls = {
				cmd = { "gopls" },
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
				root_markers = { "go.work", "go.mod", ".git" },
			}

			vim.lsp.config.golangci_lint_ls = {
				cmd = { "golangci-lint-langserver" },
				filetypes = { "go", "gomod" },
				root_markers = { ".golangci.yml", ".golangci.yaml", "go.work", "go.mod", ".git" },
				init_options = {
					command = {
						"golangci-lint",
						"run",
						"--output.json.path",
						"stdout",
						"--show-stats=false",
						"--issues-exit-code=1",
					},
				},
			}

			vim.lsp.config.pyright = {
				cmd = { "pyright-langserver", "--stdio" },
				filetypes = { "python" },
				root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
			}

			vim.lsp.config.taplo = {
				cmd = { "taplo", "lsp", "stdio" },
				filetypes = { "toml" },
				root_markers = { ".git" },
			}

			vim.lsp.config.jsonls = {
				cmd = { "vscode-json-language-server", "--stdio" },
				filetypes = { "json", "jsonc" },
				root_markers = { ".git" },
			}

			vim.lsp.config.rust_analyzer = {
				cmd = { "rust-analyzer" },
				filetypes = { "rust" },
				root_markers = { "Cargo.toml", "rust-project.json" },
				-- rust-analyzer requires utf-16; extend rather than replace the global capabilities
				capabilities = vim.tbl_deep_extend("force", capabilities, {
					general = { positionEncodings = { "utf-16" } },
					offsetEncoding = { "utf-16" },
				}),
				settings = {
					["rust-analyzer"] = {
						cargo = { features = "all" },
						check = { command = "clippy", allFeatures = true, extraArgs = { "--", "--no-deps" } },
						checkOnSave = true,
						completion = {
							fullFunctionSignatures = { enable = true },
							postfix = { enable = false },
						},
						inlayHints = {
							lifetimeElisionHints = { enable = true },
							closureReturnTypeHints = { enable = true },
							bindingModeHints = { enable = true },
						},
					},
				},
			}

			vim.lsp.config.ts_ls = {
				cmd = { "typescript-language-server", "--stdio" },
				filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
				root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
			}

			vim.lsp.config.lua_ls = {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				root_markers = {
					".luarc.json",
					".luarc.jsonc",
					".luacheckrc",
					".stylua.toml",
					"stylua.toml",
					"selene.toml",
					"selene.yml",
					".git",
				},
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							library = { "${3rd}/luv/library", unpack(vim.api.nvim_get_runtime_file("", true)) },
						},
						completion = { callSnippet = "Replace" },
						format = { enable = false },
					},
				},
			}

			require("mason").setup()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"gopls",
					"golangci-lint-langserver",
					"pyright",
					"taplo",
					"json-lsp",
					"rust-analyzer",
					"typescript-language-server",
					"lua-language-server",
					"stylua",
					"golangci-lint",
				},
			})

			vim.lsp.enable({
				"gopls",
				"golangci_lint_ls",
				"pyright",
				"taplo",
				"jsonls",
				"rust_analyzer",
				"ts_ls",
				"lua_ls",
			})
		end,
	},

	{
		"stevearc/conform.nvim",
		lazy = false,
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		opts = {
			notify_on_error = true,
			format_on_save = { timeout_ms = 2000 },
			default_format_opts = { lsp_format = "fallback" },
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
			},
		},
	},

	{
		"saghen/blink.cmp",
		version = "1.*",
		opts = {
			keymap = {
				preset = "default",
				["<C-y>"] = { "select_and_accept" },
			},
			appearance = { nerd_font_variant = "mono" },
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			signature = { enabled = true },
		},
	},

	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "night",
			styles = {
				keywords = { italic = false },
				comments = { italic = false },
				functions = { italic = false },
				variables = { italic = false },
			},
		},
		init = function()
			vim.cmd.colorscheme("tokyonight-night")
			vim.cmd.hi("Comment gui=none")
		end,
	},

	{ "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = { signs = false } },

	{
		"nvim-mini/mini.nvim",
		config = function()
			-- avoid conflicts with treesitter incremental selection mappings (0.12)
			require("mini.ai").setup({
				mappings = { around_next = "aa", inside_next = "ii" },
				n_lines = 500,
			})
			require("mini.surround").setup()
			require("mini.pairs").setup()

			local statusline = require("mini.statusline")
			statusline.setup()
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return ""
			end
		end,
	},

	{
		"romus204/tree-sitter-manager.nvim",
		config = function()
			require("tree-sitter-manager").setup({
				ensure_installed = { "rust", "zig" },
				auto_install = false,
				highlight = true,
			})
		end,
	},
})

-- vim: ts=2 sts=2 sw=2 et
