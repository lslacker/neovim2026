-- Java-only indentation (global default stays 2)
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = true

local root_dir = vim.fs.root(0, { "gradlew", "mvnw", "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
if not root_dir then return end

local lombok = vim.fn.stdpath("data") .. "/mason/packages/jdtls/lombok.jar"

local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fs.basename(root_dir)

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("mini.completion").get_lsp_capabilities())

local bundles = vim.split(vim.fn.glob(
    vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"),
  "\n")

vim.list_extend(bundles, vim.split(vim.fn.glob(
  vim.fn.stdpath("data") .. "/mason/packages/java-test/extension/server/*.jar", true), "\n"))

require("jdtls").start_or_attach({
  cmd = { "jdtls", "--jvm-arg=-javaagent:" .. lombok, "-data", workspace },
  root_dir = root_dir,
  capabilities = capabilities,
  settings = {
    java = {
      format = {
        enabled = true,
        settings = {
          url = vim.fn.stdpath("config") .. "/eclipse-formatter.xml",
          profile = "Performance Centre",
        },
      },
    },
  },
  init_options = { bundles = bundles },
  on_attach = function(_, bufnr)
    local jdtls = require("jdtls")
    jdtls.setup_dap({ hotcodereplace = "auto" })

    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- Unit tests via jdtls + java-test bundle (results in dap REPL, failures in quickfix)
    map("<leader>tc", jdtls.test_class, "Test class")
    map("<leader>tm", jdtls.test_nearest_method, "Test nearest method")
    map("<leader>tp", function() jdtls.pick_test() end, "Pick test to run")

    -- Gradle run for the current class (needed for src/testIntegration: javaagent, Testcontainers, env vars)
    map("<leader>tg", function()
      local class = vim.fn.expand("%:t:r")
      local task = vim.fn.expand("%:p"):find("/testIntegration/") and "integrationTest" or "test"
      vim.cmd("botright split | terminal ./gradlew " .. task .. " --offline --tests '*" .. class .. "'")
    end, "Gradle test current class")
  end,
})
