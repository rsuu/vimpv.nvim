--[[
Videoclip - mp4/webm clips creator for mpv.

Copyright (C) 2021 Ren Tatsumoto

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]] local mp = require('mp')
local mpopt = require('mp.options')
local utils = require('mp.utils')

local Menu = require('Menu')
local utils = require('utils')
local OSD = require('OSD')

local config = {ass_path = "/tmp/", suffix = ".ass"}

local main_menu
local pref_menu
local Timings

-- time
local time_start
local time_end
local time_start_human
local time_end_human
local time_start_format
local time_end_format

-- file
local ass_path = config.ass_path
local suffix = config.suffix

-- LuaFormatter off
local print_ass_text = {
    {"[Script Info]", ""},
    {"Title: ", "Default ASS file"},
    {"ScriptType: ", "v4.00+"},
    {"WrapStyle: ", "2"},
    {"Collisions: ", "Normal"},
    {"PlayResX: ", "1920"},
    {"PlayResY: ", "1080"},
    {"ScaledBorderAndShadow: ", "yes"},
    {"Video Zoom Percent: ", "1"},
    {'\n', '\n'},
    {"[V4+ Styles]", ""},
    {"Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline",
    ", StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding"},
    {"Style: opj,Kozuka Mincho Pr6N H,32,&H00ffffe8,&H00a00000,&H00a00000",
    ",&H80a00000,0,0,0,0,100,100,0,0.00,1,2,0,9,10,10,10,1"
    },
    {'\n', '\n'},
    {"[Events]", ""},
    {"Format: Layer, Start, End, Style, Actor, MarginL",
    ", MarginR, MarginV, Effect, Text"},

}
-- LuaFormatter on

-- Config path: ~/.config/mpv/script-opts/tk4e_menu.conf
mpopt.read_options(config, "tk4e_menu")

------------------------------------------------------------
-- Timings class

Timings = {["start"] = -1, ["end"] = -1}

function Timings:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Timings:reset()
    self["start"] = -1
    self["end"] = -1
end

function Timings:validate()
    return self["start"] >= 0 and self["start"] < self["end"]
end

------------------------------------------------------------
-- Utility functions

function remove_suffix(filename)
    filename = utils:remove_suffix(filename)
    return filename
end

function add_osd_text(osd, osd_text)
    for _, osd_text in pairs(osd_text) do
        osd:tab():item(osd_text[1]):append(osd_text[2]):newline()
    end
end

local function human_readable_time(seconds)
    if type(seconds) ~= "number" or seconds < 0 then return "empty" end

    local parts = {}

    parts.h = math.floor(seconds / 3600)
    parts.m = math.floor(seconds / 60) % 60
    parts.s = math.floor(seconds % 60)
    parts.ms = math.floor((seconds * 1000) % 1000)

    local ret = string.format("%02dm%02ds%03dms", parts.m, parts.s, parts.ms)

    if parts.h > 0 then ret = string.format('%dh%s', parts.h, ret) end

    return ret
end

function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function time_format()

    local time_start_format = time_start_human
    local time_end_format = time_end_human
    local file_name = ass_path .. remove_suffix(mp.get_property("filename")) ..
                          suffix

    if file_exists(file_name) then
        file = io.open(file_name, "a")

        -- Dialogue: 0,0:00:11.13,0:00:18.84,opc,,0000,0000,0000,,text
        file:write("Dialogue: 0,",
                   time_start_format .. "," .. time_end_format ..
                       ",Default,,0000,0000,0000,,", "\n")

    else
        file = io.open(file_name, "a")
        for _, text in pairs(print_ass_text) do
            file:write(text[1] .. text[2], "\n")
            file:write("Dialogue: 0,", time_start_format .. "," ..
                           time_end_format .. ",Default,,0000,0000,0000,,", "\n")

        end

    end

    file:close(file)

end

------------------------------------------------------------
-- Main menu

main_menu = Menu:new()

-- LuaFormatter off
main_menu.keybindings = {
    {key = "s", fn = function() main_menu:set_time_start() end},
    {key = "e", fn = function() main_menu:set_time_end() end},
    {key = "r", fn = function() main_menu:reset_timings("end") end},
    {key = "w", fn = function() time_format() end},
    {key = "p", fn = function() pref_menu:open() end},
    {key = "ESC", fn = function() main_menu:close() end}
}
-- LuaFormatter on

function main_menu:set_time_start()
    self.timings["start"] = mp.get_property_number("time-pos")
    self:update()
end

function main_menu:set_time_end()
    self.timings["end"] = mp.get_property_number("time-pos")
    self:update()
end

function main_menu:reset_timings()
    self.timings = Timings:new()
    self:update()
end

main_menu.open = function()
    main_menu.timings = main_menu.timings or Timings:new()
    Menu.open(main_menu)
end

main_menu.set_start = function() main_menu.set_time_start(main_menu) end

main_menu.set_end = function() main_menu.set_time_end(main_menu) end

function main_menu:update()
    local osd = OSD:new():align(4)

    time_start_human = human_readable_time(self.timings["start"])
    time_end_human = human_readable_time(self.timings["end"])

    -- LuaFormatter off
    local osd_text = {
        {"Clip creator", ""},
        {"  s: Set start time: ", time_start_human},
        {"  e: Set end time: ", time_end_human},
        {"  r: ", "Reset"},
        {"  w: ", "Write"},
        {"  p: ", "Open preferences"},
        {"  ESC: ", "Close"}
    }
    -- LuaFormatter on

    add_osd_text(osd, osd_text)

    self:overlay_draw(osd:get_text())
end

------------------------------------------------------------
-- Preferences

pref_menu = Menu:new(main_menu)

-- LuaFormatter off
pref_menu.keybindings = {
    {key = "ESC", fn = function() pref_menu:close() end}
}
-- LuaFormatter on

function pref_menu:update()
    local osd = OSD:new():align(4)

    local osd_text = {{"  ESC: ", "Close"}}

    osd:submenu('Preferences'):newline()

    add_osd_text(osd, osd_text)

    self:overlay_draw(osd:get_text())
end

------------------------------------------------------------
-- Finally, set an 'entry point' in mpv

mp.add_key_binding('', 'tk4e_menu', main_menu.open)
mp.add_key_binding('', 'tk4e_time_format', time_format)
mp.add_key_binding('', 'tk4e_set_time_start', main_menu.set_start)
mp.add_key_binding('', 'tk4e_set_time_end', main_menu.set_end)
