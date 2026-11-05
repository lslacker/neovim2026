local dap = require("dap")

dap.configurations.java = {
  { type = "java", request = "attach", name = "frontend (Tomcat :8787)",    hostName = "127.0.0.1", port = 8787 },
  { type = "java", request = "attach", name = "calculation-api (:5006)",    hostName = "127.0.0.1", port = 5006 },
  { type = "java", request = "attach", name = "gateway (:5007)",            hostName = "127.0.0.1", port = 5007 },
  { type = "java", request = "attach", name = "calculation-engine (:5008)", hostName = "127.0.0.1", port = 5008 },
}

local map = vim.keymap.set
map("n", "<F5>", dap.continue, { desc = "DAP continue / attach" })
map("n", "<F8>", dap.step_over, { desc = "DAP step over" })
map("n", "<F7>", dap.step_into, { desc = "DAP step into" })
map("n", "<S-F7>", dap.step_out, { desc = "DAP step out" })
map("n", "<F9>", dap.continue, { desc = "DAP resume" })
map("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
map("n", "<leader>B", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, { desc = "Conditional breakpoint" })
map("n", "<leader>dr", dap.repl.toggle, { desc = "DAP REPL" })
map("n", "<leader>dK", function() require("dap.ui.widgets").hover() end, { desc = "DAP hover" })
map("n", "<leader>ds", function()
  local w = require("dap.ui.widgets"); w.centered_float(w.scopes)
end, { desc = "DAP scopes" })
