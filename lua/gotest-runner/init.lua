local cfg = require("gotest-runner.config")
local M = {}


local api = vim.api
local ts = vim.treesitter

local function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function command_params(opts)
    -- prepare options
    local o = vim.tbl_extend('force', cfg.opts, opts or {})
    local switches = #o.test_switches > 0 and table.concat(o.test_switches, ' ') or ''
    local envs = #o.envs > 0 and table.concat(o.envs, ' ') or ''

    return switches, envs
end

--@param opts? table user defined options
function M.single_test(opts)
    local bufnr = api.nvim_get_current_buf()
    local node = ts.get_node({ bufnr = bufnr, ignore_injections = false })

    if node == nil or node:type() ~= "function_declaration" then
        print("No test function found.")
        return
    end

    local function_name = ts.get_node_text(node:child(1), bufnr)
    local current_file = vim.fn.expand("%")
    local switches, envs = command_params(opts)
    local command = trim(string.format(envs .. " go test " .. switches .. " -run '^%s$' %s", function_name, current_file))

    local output = vim.fn.systemlist(command)

    for _, line in ipairs(output) do
        if line:find("FAIL") then
            print(line)
            vim.cmd("copen")
            vim.cmd("cgetfile " .. vim.fn.tempname() .. "\n" .. table.concat(output, "\n"))
            vim.cmd("cc 1")
            return
        end
    end

    print("Test '" .. function_name .. "' passed!")
end

--@param opts? table user defined options
function M.file_test(opts)
    local current_file = vim.fn.expand("%")
    local switches, envs = command_params(opts)
    local command = trim(string.format(envs .. " go test " .. switches .. " -run '^Test' %s", current_file))

    local output = vim.fn.systemlist(command)

    for _, line in ipairs(output) do
        if line:find("FAIL") then
            print(line)
            vim.cmd("copen")
            vim.cmd("cgetfile " .. vim.fn.tempname() .. "\n" .. table.concat(output, "\n"))
            vim.cmd("cc 1")
            return
        end
    end
end

--@param opts? table user defined options
function M.suite_single_test(opts)
    local bufnr = api.nvim_get_current_buf()
    local node = ts.get_node({ bufnr = bufnr, ignore_injections = false })

    if node == nil or node:type() ~= "function_declaration" then
        print("No test function found.")
        return
    end

    -- Find the parent node that corresponds to the Testify suite
    local suite_node = node:parent()
    while suite_node ~= nil and suite_node:type() ~= "function_declaration" do
        suite_node = suite_node:parent()
    end

    if suite_node == nil then
        print("No Testify suite found.")
        return
    end

    -- Get the name of the Testify suite and the test function
    local suite_name = ts.get_node_text(suite_node:child(1), bufnr)
    local function_name = ts.get_node_text(node:child(1), bufnr)

    local current_file = vim.fn.expand("%")
    local switches, envs = command_params(opts)
    local command = trim(string.format(envs .. " go test " .. switches .. " -run '^%s$' -testify.m \"%s\" %s", function_name, suite_name, current_file))

    local output = vim.fn.systemlist(command)

    for _, line in ipairs(output) do
        if line:find("FAIL") then
            print(line)
            vim.cmd("copen")
            vim.cmd("cgetfile " .. vim.fn.tempname() .. "\n" .. table.concat(output, "\n"))
            vim.cmd("cc 1")
            return
        end
    end

    print("Test '" .. function_name .. "' in suite '" .. suite_name .. "' passed!")
end

--@param opts? table user defined options
function M.suite_test(opts)
    -- go test -v -run ^TestSuite$ -testify.m ^Test ./suite_test.go

    -- Get the current buffer handle
    local bufnr = api.nvim_get_current_buf()

    -- Get the root node of the syntax tree
    local root = ts.get_parser(bufnr):parse()[1]:root()

    -- Define the Treesitter query to find the function calling `suite.Run`
    local query = ts.parse_query("go", '(function_declaration (identifier)@suite_test_name (block (call_expression (selector_expression)@predicate (#match? @predicate "suite.Run"))))')

    -- Find the function calling `suite.Run` using the Treesitter query
    local matches = query:matches(root)

    -- Check if a matching function is found
    if #matches > 0 then
        -- Extract the line range of the matching function
        matches[1]:range()

        -- Get the current file path
        local file_path = vim.fn.expand("%:p")

        -- Construct the command to run the tests
        local suite_name = matches[1]:child(1):text()
        local switches, envs = command_params(opts)
        local cmd = trim(envs .. " go test " .. switches .." -run ^" .. suite_name .. "$ -testify.m ^Test " .. file_path)

        local output = vim.fn.systemlist(cmd)

        for _, line in ipairs(output) do
            if line:find("FAIL") then
                print(line)
                vim.cmd("copen")
                vim.cmd("cgetfile " .. vim.fn.tempname() .. "\n" .. table.concat(output, "\n"))
                vim.cmd("cc 1")
                return
            end
        end
    else
        print("No Testify suite test function found.")
    end
end

return M
