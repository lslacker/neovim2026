require("mason").setup()

vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format Local buffer" })
vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = { current_line = true },
    severity_sort = true,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("mini.completion").get_lsp_capabilities())

vim.lsp.config("*", { capabilities = capabilities })
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
        },
    },
})

vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      analysis = {
        autoImportCompletions = true,       -- Enables auto-import suggestions in completion menu
        autoSearchPaths = true,             -- Automatically searches for packages in virtualenvs
        useLibraryCodeForTypes = true,      -- Parses installed library code to find missing packages
        diagnosticMode = "openFilesOnly",   -- Limits background scanning overhead
        typeCheckingMode = "basic",         -- Options: "off", "basic", "standard", "strict"
      },
    },
  },
})

-- Configure Clojure LSP options
vim.lsp.config["clojure_lsp"] = {
  cmd = { "clojure-lsp" },
  filetypes = { "clojure", "edn" },
  root_markers = { "deps.edn", "project.clj", "shadow-cljs.edn", "build.boot", ".git" },
}

vim.lsp.enable({
    "lua_ls",
    "ts_ls",
    "marksman",
    "gopls",
    "rust_analyzer",
    "basedpyright",
    "ruff",
    "gleam",
    "clojure_lsp",
})
