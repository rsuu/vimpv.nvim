------------------------------------------------------------
-- Menu interface

local Menu = {}
Menu.__index = Menu

function Menu:new(parent)
    local o = {
        parent = parent,
        overlay = parent and parent.overlay or
            mp.create_osd_overlay("ass-events"),
        keybindings = {}
    }
    return setmetatable(o, self)
end

function Menu:overlay_draw(text)
    self.overlay.data = text
    self.overlay:update()
end

function Menu:open()
    if self.parent then self.parent:close() end
    for _, val in pairs(self.keybindings) do
        mp.add_forced_key_binding(val.key, val.key, val.fn)
    end
    self:update()
end

function Menu:close()
    for _, val in pairs(self.keybindings) do mp.remove_key_binding(val.key) end
    if self.parent then
        self.parent:open()
    else
        self.overlay:remove()
    end
end

function Menu:update()
    local osd = OSD:new():align(4)
    osd:append("Dummy menu."):newline()
    self:overlay_draw(osd:get_text())
end

return Menu
