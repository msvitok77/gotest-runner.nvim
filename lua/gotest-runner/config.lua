local config = {}

--@param strategy? string we have two strategies ['toggleterm', 'nvim']
--@param envs? table you can create any ENV variable before running tests
--@param envs? table you can pass any go test switches like '-v' here
local defaults = {
    strategy = 'toggleterm',
    envs = {},
    test_switches = {},
}

config.opts = {}

---@param user_opts? table
config.setup = function(user_opts)
    config.opts = vim.tbl_extend('force', defaults, user_opts or {})
end

-- initialize config
config.setup()

return config
