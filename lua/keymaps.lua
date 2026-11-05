vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.g["conjure#log#hud#enabled"] = true
vim.g["conjure#log#hud#anchor"] = "NE" -- Position the HUD in the Top-Right quadrant
vim.g["conjure#client#clojure#nrepl#connection_order"] = {
  "bencode",    -- Standard active project port (.nrepl-port)
  "auto",       -- Searches for a running shadow-cljs or local process
  "babashka",   -- Absolute local fallback fallback
}

-- replaces selected text WITHOUT losing what you yanked
vim.keymap.set("x", "p", [["_dP"]], { desc = "Paste over selection without losing yanked text"})


-- delete text without saving it to any register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d"]], { desc = "Delete without yanking" })

vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search highlighting", silent = true })


vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })

vim.keymap.set("v", "<", "<gv", { desc = "Unindent and keep selection" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent and keep selection" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })


vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result cursor centered" })
vim.keymap.set("n", "N", "nzzzv", { desc = "Previous search result cursor centered" })


vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Replace word cursor" })
vim.keymap.set("n", "<leader>X", "<cmd>!chmod +x %s<CR>", { silent = true, desc = "makes file executable" })

vim.keymap.set("n", "<leader>u", function()
    vim.cmd.packadd("nvim.undotree")
    require("undotree").open()
end, {desc = "Toggle Builtin Undotree"})


-- fugitive
-- Quick-bind to open the core Fugitive interactive staging panel (:G)
vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git Status Panel" })

-- Direct tracking for side-by-side vertical git diffs against the index
vim.keymap.set("n", "<leader>gd", ":Gdiffsplit<CR>", { desc = "Git Diff Split" })

-- Blame allocation pane (press enter on a line to see the full commit details)
vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "Git Blame Line" })

-- Quick log timeline view
vim.keymap.set("n", "<leader>gl", ":Git log --oneline<CR>", { desc = "Git Log Summary" })


-- New file in the current file's directory (prompt pre-filled with the path)
vim.keymap.set("n", "<leader>nf", function()
    local dir = vim.fn.expand("%:p:h") .. "/"
    vim.ui.input({ prompt = "New file: ", default = dir, completion = "file" }, function(path)
        if not path or path == "" or path == dir then return end
        vim.fn.mkdir(vim.fs.dirname(path), "p")
        vim.cmd.edit(vim.fn.fnameescape(path))
    end)
end, { desc = "New file in current file's directory" })
