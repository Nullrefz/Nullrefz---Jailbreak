local mats = {
    Door = Material("jailbreak/vgui/icons/opencelldoors.png", "smooth")
}

LOGBOX = {}

function LOGBOX:Init()
end

function LOGBOX:PerformLayout(width, height)
end

function LOGBOX:SetInfo(log)
    self.log = log

    if self.log.Type == "Pickup" or self.log.Type == "Drop" then
        self:DrawPickup(self.log)
    elseif self.log.Type == "Doors" then
        self:DrawDoors(self.log)
    end
end

function LOGBOX:DrawPickup(log)
    self:DrawTitle(log)
    local bottomPanel = vgui.Create("Panel", self)
    bottomPanel:Dock(BOTTOM)
    bottomPanel:SetTall(16)
    bottomPanel:DockMargin(0, 0, 0, 0)

    function bottomPanel:Paint(width, height)
        draw.DrawRect(0, 0, width, height, Color(0, 150, 255, 20))
        draw.DrawText(string.gsub(log.Weapon, "weapon_jb_", ""), "Jailbreak_Font_16", width / 2, -2,
            Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    end

    local LeftSide = vgui.Create("Panel", self)
    LeftSide:Dock(FILL)
    local material = Material("jailbreak/vgui/weapons/" .. tostring(log.Weapon) .. ".png")
    local imgHeight = material:Height()
    local imgWidth = material:Width()
    function LeftSide:Paint(width, height)
        local imgWid = imgWidth / imgHeight * 72
        draw.DrawRect((width - imgWid) / 2, -12, imgWid, height + 32, Color(255, 255, 255), material)
    end
end

function LOGBOX:DrawDoors(log)
    self:DrawTitle(log)
    self:SetWide(64)
    self.image = vgui.Create("DPanel", self)
    self.image:Dock(FILL)
    local size = 32
    function self.image:Paint(width, height)
        draw.DrawRect(width / 2 - size / 2, height / 2 - size / 2 - 2, size, size, Color(255, 255, 255), mats.Door)
    end
end

function LOGBOX:DrawTitle(log)

    -- Title
    local topPanel = vgui.Create("Panel", self)
    topPanel:Dock(TOP)
    topPanel:SetTall(16)
    topPanel:DockMargin(0, 0, 0, 0)

    function topPanel:Paint(width, height)
        draw.DrawText(log.Type, "Jailbreak_Font_16", width / 2, 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    end

end
function LOGBOX:Paint(width, height)
    draw.ChamferedBox(width / 2, height / 2, width, height, 2, JB:GetLogColor(self.log.Type))
    draw.DrawRect(0, height / 2, width, height / 2, Color(30, 30, 30, 70))
end

vgui.Register("JailbreakLogBox", LOGBOX)
