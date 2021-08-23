local defaults_values = {
    tmp_dir = "/tmp/mpv/",
    tmp_file = "ass.lock",
    tmp_path = "/tmp/mpv/ass.lock",
    mode = "i",
    key = {
        pause = "<c-SPACE>",
        write = "<c-w>",
        set_time_start = "<c-s>",
        set_time_end = "<c-e>",
        seek_two = "<c-RIGHT>",
        seek_minus_two = "<c-LEFT>"
    }
}

local config = {}

config.values = {}

---@param opts table
function config.set_default_values(opts)
    config.values = vim.tbl_deep_extend('force', defaults_values, opts or {})
end

return config
