vim.pack.add({
    "https://github.com/bluz71/vim-moonfly-colors",
    "https://github.com/nvim-mini/mini.nvim",
    "http://github.com/rafamadriz/friendly-snippets",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/tpope/vim-fugitive",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/Olical/conjure",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/nvim-lualine/lualine.nvim",
    "https://github.com/windwp/nvim-autopairs",
    "https://github.com/mfussenegger/nvim-jdtls",
    "https://github.com/coder/claudecode.nvim",
    "https://github.com/mfussenegger/nvim-dap"
})


---- mini files ----
require("mini.files").setup({
    mappings = {
        go_in = "<CR>",
        go_in_plus = "L",
        go_out = "_",
        go_out_plus = "H",
        reveal_cwd ='@',
    }
})

vim.keymap.set("n", "-", "<cmd>lua MiniFiles.open()<CR>", { desc = "Toggle mini file explorer" })
vim.keymap.set("n", "<leader>-", function()
    -- Load the plugin module explicitly
    local MiniFiles = require("mini.files")
    -- Open mini.files (it will automatically focus the current file)
    MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
end, { desc = "Toggle into currently opened file" })


---- mini notify ----
require("mini.notify").setup({
    content = {
        format = function(notif)
            return notif.msg
        end
    },
})


---- mini cmdline completion ----
require("mini.cmdline").setup({
    autocorrect = { enable = false }
})


-- mini surround ----
require("mini.surround").setup({})


--- mini picker ----
local MiniPick = require("mini.pick")
local MiniExtra = require("mini.extra")
MiniPick.setup({
    window = {
        config = function()
            local height = math.floor(0.6 * vim.o.lines)
            local width = math.floor(0.85 * vim.o.columns)
            return {
                anchor = "NW",
                height = height,
                width = width,
                row = math.floor(0.5 * (vim.o.lines - height)),
                col = math.floor(0.5 * (vim.o.columns - width)),
            }
        end,
    },
})
MiniExtra.setup()

-- Show "Filename.java  dir/shortened" so the name is readable for deep Java paths.
-- Items stay full paths, so matching and choosing are unaffected.
local pick_ns = vim.api.nvim_create_namespace("pick_name_first")
local function show_name_first(buf_id, items, _)
    local lines, name_lens = {}, {}
    for i, item in ipairs(items) do
        local path = tostring(item)
        local name = vim.fn.fnamemodify(path, ":t")
        local dir = vim.fn.fnamemodify(path, ":h")
        dir = dir:gsub("^.*/src/main/java/", "…/"):gsub("^.*/src/test/java/", "…/test/")
        lines[i] = dir == "." and name or (name .. "  " .. dir)
        name_lens[i] = #name
    end
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
    vim.api.nvim_buf_clear_namespace(buf_id, pick_ns, 0, -1)
    for i, len in ipairs(name_lens) do
        if #lines[i] > len then
            vim.api.nvim_buf_set_extmark(buf_id, pick_ns, i - 1, len, { end_col = #lines[i], hl_group = "Comment" })
        end
    end
end

vim.keymap.set("n", "<leader>pf", function()
    MiniPick.builtin.files(nil, { source = { show = show_name_first } })
end, { desc = "Mini File Picker" })
vim.keymap.set('n', '<leader>pb', '<cmd>Pick buffers<cr>', { desc = 'Buffers' })
vim.keymap.set("n", "<leader>ps", function() MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end, { desc = "Grep word/Search word" })
vim.keymap.set("n", "<leader>vh", function() MiniPick.builtin.help() end, { desc = "Mini Help" })

vim.keymap.set("n", "<leader>xx", function() MiniExtra.pickers.diagnostic() end, { desc = "Mini Picker Diagnostics" })
vim.keymap.set("n", "<leader>pk", function() MiniExtra.pickers.keymaps() end, { desc = 'Search keymaps' })

--- mini completion ----
local MiniCompletion = require("mini.completion")
MiniCompletion.setup({
    lsp_completion = {
        auto_setup = true,
        process_items = function(items, base)
            return MiniCompletion.default_process_items(items, base, {
                filtersort = "fuzzy",
            })
        end,
    }
})


--- mini snippets ---
local MiniSnippets = require("mini.snippets")
MiniSnippets.setup({
    snippets = {
        MiniSnippets.gen_loader.from_lang(),
    },
    expand = {
        insert = function(snippet)
            MiniSnippets.default_insert(snippet, { empty_tabstop = "" })
        end,
    },
})

MiniSnippets.start_lsp_server({ match = false })

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        vim.api.nvim_set_hl(0, "MiniSnippetsCurrent", {})
        vim.api.nvim_set_hl(0, "MiniSnippetsCurrentReplace", {})
        vim.api.nvim_set_hl(0, "MiniSnippetsFinal", {})
        vim.api.nvim_set_hl(0, "MiniSnippetsUnvisited", {})
        vim.api.nvim_set_hl(0, "MiniSnippetsVisited", {})

        -- Clearer selected row in mini.pick (default bg is barely visible on moonfly)
        vim.api.nvim_set_hl(0, "MiniPickMatchCurrent", { bg = "#2f4f7f", fg = "#ffffff", bold = true })
        vim.api.nvim_set_hl(0, "MiniPickMatchMarked", { bg = "#5a3f7f", bold = true })
        vim.api.nvim_set_hl(0, "MiniPickMatchRanges", { fg = "#ffb86c", bold = true })
    end,
})
-- Apply now too, since the colorscheme is already loaded when this file runs
vim.api.nvim_exec_autocmds("ColorScheme", {})

require('mini.statusline').setup()

require('nvim-autopairs').setup({
  disable_filetype = { "TelescopePrompt" , "vim" },
})

---- gitsigns ----
-- Hunks use ]h/[h rather than the README's ]c/[c, which are Vim's own diff-mode
-- motions used in fugitive's :Gdiffsplit (<leader>gd). Diffing is left to fugitive.
require("gitsigns").setup({
    on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        local function selected_lines()
            return { vim.fn.line("."), vim.fn.line("v") }
        end

        map("n", "]h", function() gitsigns.nav_hunk("next") end, "Next git hunk")
        map("n", "[h", function() gitsigns.nav_hunk("prev") end, "Previous git hunk")

        map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk")
        map("n", "<leader>hi", gitsigns.preview_hunk_inline, "Preview hunk inline")
        map("n", "<leader>hs", gitsigns.stage_hunk, "Stage/unstage hunk")
        map("x", "<leader>hs", function() gitsigns.stage_hunk(selected_lines()) end, "Stage selected lines")
        map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
        map("x", "<leader>hr", function() gitsigns.reset_hunk(selected_lines()) end, "Reset selected lines")
        map("n", "<leader>hS", gitsigns.stage_buffer, "Stage buffer")
        map("n", "<leader>hR", gitsigns.reset_buffer, "Reset buffer")
        map("n", "<leader>hb", function() gitsigns.blame_line({ full = true }) end, "Blame line popup")
        map("n", "<leader>hq", gitsigns.setqflist, "Hunks to quickfix")

        map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Toggle inline blame")
        map("n", "<leader>tw", gitsigns.toggle_word_diff, "Toggle word diff")

        map({ "o", "x" }, "ih", gitsigns.select_hunk, "Inside hunk")
    end,
})


---- claude code ----
require("claudecode").setup({
  terminal = { provider = "native" }, -- no snacks.nvim installed
})

vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
vim.keymap.set("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
vim.keymap.set("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
vim.keymap.set("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Select Claude model" })
vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer to Claude" })
vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send selection to Claude" })
vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept Claude diff" })
vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny Claude diff" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "minifiles",
  callback = function()
    vim.keymap.set("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", { buffer = true, desc = "Add file to Claude" })
  end,
})
