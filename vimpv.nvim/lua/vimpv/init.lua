local M = {}

local shell = os.execute
local a = vim.api
local config = require('vimpv.config')

local opts = {noremap = true, silent = true}

function create_dir(dirname) os.execute("mkdir -p " .. dirname) end

-- Check exists
exists = {

    --- Check if a file or directory exists in this path
    file = function(file)
        local ok, err, code = os.rename(file, file)
        if not ok then
            if code == 13 then
                -- Permission denied, but it exists
                return true
            end
        end
        return ok, err
    end,

    --- Check if a directory exists in this path
    dir = function(path)
        -- "/" works on both Unix and Windows
        return exists.file(path .. "/")
    end

}

mpv_key = {

    check = function()
        if exists.dir(config.values.tmp_dir) then
            -- print(tmp_dir)
        else
            create_dir(config.values.tmp_dir)
        end

    end,

    pause = function()
        shell("echo 'cycle pause' | socat - " .. config.values.tmp_path)
    end,

    write = function()
        shell("echo 'script-binding tk4e_time_format' | socat - " ..
                  config.values.tmp_path)
    end,

    menu = function()
        shell("echo 'script-binding tk4e_menu' | socat - " ..
                  config.values.tmp_path)
    end,

    set_time_start = function()
        shell("echo 'script-binding tk4e_set_time_start' | socat - " ..
                  config.values.tmp_path)
    end,

    set_time_end = function()
        shell("echo 'script-binding tk4e_set_time_end' | socat - " ..
                  config.values.tmp_path)
    end,

    seek_two = function()
        shell("echo 'seek +2' | socat - " .. config.values.tmp_path)
    end,

    seek_minus_two = function()
        shell("echo 'seek -2' | socat - " .. config.values.tmp_path)
    end

}

function set_keymap(mode, fn, key)
    a.nvim_buf_set_keymap(0, mode, key,
                          '<Cmd>lua require"vimpv".' .. fn .. '()<CR>', opts)

end

M.pause = function() mpv_key.pause() end

M.write = function()
    mpv_key.write()
    vim.api.nvim_exec([[
    :e | norm! G
    ]], false)
end

M.menu = function()
    mpv_key.check()

    local mode = config.values.mode
    local key = config.values.key

    set_keymap(mode, 'pause', key.pause)
    set_keymap(mode, 'seek_two', key.seek_two)
    set_keymap(mode, 'seek_minus_two', key.seek_minus_two)
    set_keymap(mode, 'set_time_start', key.set_time_start)
    set_keymap(mode, 'set_time_end', key.set_time_end)
    set_keymap(mode, 'write', key.write)

    mpv_key.menu()
end

M.set_time_start = function() mpv_key.set_time_start() end

M.set_time_end = function() mpv_key.set_time_end() end

M.seek_two = function() mpv_key.seek_two() end

M.seek_minus_two = function() mpv_key.seek_minus_two() end

---@param prefs table
M.setup = function(prefs) config.set_default_values(prefs) end

return M
