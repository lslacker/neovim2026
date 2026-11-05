vim.api.nvim_create_user_command("PackAdd", function(opts)
    vim.pack.add(opts.fargs)
end, { nargs = "+", desc = "Add plugins (:PackAdd user/repo)" })

vim.api.nvim_create_user_command("PackDel", function(opts)
    vim.pack.del(opts.fargs)
end, { nargs = "+", desc = "Delete plugins (:PackDel plugin1 plugin2)" })

vim.api.nvim_create_user_command("PackUpdate", function(opts)
    if opts.args:match("%S") then
        local plugins = vim.split(opts.args, "%s+", { trimempty = true })
        vim.pack.update(plugins)
    else
        vim.pack.update()
    end
end, { nargs = "*", desc = "Update all plugins or specific ones" })

-- vim.api.nvim_create_user_command("PackCheck", function(opts)
--     local non_active = vim.iter(vim.pack.get())
--     :filter(function(x) return not x.active end)
--     :map(function(x) return x.spec.name end)
--     :totable()
--
--     if #non_active == 0 then
--         vim.notify("Ok No non-active plugins found!", vim.log.levels.INFO)
--         return
--     end

-- package name for a Java file under src/<sourceSet>/java, e.g. "com.acme.service"
local function java_package(file)
    local dir = vim.fn.fnamemodify(file, ":p:h")
    local package_path = dir:match("src/[^/]+/java/(.+)$")
    return package_path and package_path:gsub("/", ".") or nil
end

-- Insert (or replace) the package declaration at the top of the current Java buffer
local function insert_java_package(buf)
    buf = buf or 0
    local package_name = java_package(vim.api.nvim_buf_get_name(buf))
    if not package_name then
        vim.notify("Not under src/<sourceSet>/java", vim.log.levels.WARN)
        return
    end
    local line = "package " .. package_name .. ";"
    local first = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
    if first:match("^package%s") then
        vim.api.nvim_buf_set_lines(buf, 0, 1, false, { line })
    else
        local empty = first == "" and vim.api.nvim_buf_line_count(buf) == 1
        vim.api.nvim_buf_set_lines(buf, 0, empty and 1 or 0, false, { line, "" })
    end
end

vim.api.nvim_create_user_command("JavaPackage", function()
    insert_java_package()
end, { desc = "Insert package declaration from the file path" })

vim.keymap.set("n", "<leader>jp", insert_java_package, { desc = "Java: insert package" })

-- New Java files under src/<sourceSet>/java start with just the package line;
-- add the type with the class/record/enum/interface snippets
vim.api.nvim_create_autocmd("BufNewFile", {
    group = vim.api.nvim_create_augroup("JavaNewFile", { clear = true }),
    pattern = "*/src/*/java/**/*.java",
    desc = "Insert package declaration for new Java files",
    callback = function(args)
        insert_java_package(args.buf)
        vim.cmd("normal! G")
    end,
})
