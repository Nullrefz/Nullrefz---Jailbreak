menuTypes = {"waypoint", "commands", "actions", "calendar", "lastRequest", "contest", "competition"}

if CLIENT then
    function JB:RegistereMenu(slots)
        local menu = {}
        menu.active = false

        menu.Show = function()
            if not self.active then
                self.active = true
                self.panel = vgui.Create("JailbreakOptionMenu")
                self.panel:SetSize(w, h)
                self.panel:SetPos(0, 0)

                for k, v in ipairs(slots) do
                    self.panel:AddSlot(v.NAME, v.ACTION, v.COLOR, v.CLOSE)
                end

                menu.Hide = function()
                    self.active = false

                    if self.panel:IsValid() then
                        self.panel:Exit()
                    end
                end
            end
        end

        return menu
    end
end