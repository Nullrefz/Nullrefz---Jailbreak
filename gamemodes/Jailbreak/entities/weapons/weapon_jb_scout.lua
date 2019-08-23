AddCSLuaFile()

if (CLIENT) then
    SWEP.PrintName = "Scout"
    SWEP.Author = "Counter-Strike"
    SWEP.Slot = 3
    SWEP.SlotPos = 1
    SWEP.IconLetter = "n"
end

SWEP.HoldType = "ar2"
SWEP.Base = "weapon_jb_base"
SWEP.Category = "Counter-Strike"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.WorldModel = "models/weapons/w_snip_scout.mdl"
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Primary.Sound = Sound("Weapon_Scout.Single")
SWEP.Primary.Recoil = 0.1
SWEP.Primary.Damage = 80
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0
SWEP.Primary.ClipSize = 10
SWEP.Primary.Delay = 1.25
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "css_762mm"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.IronSightsPos = Vector(-6, -5, 3)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.ZoomDelay = 0.25

if CLIENT then
    function SWEP:AdjustMouseSensitivity()
        return self:GetNWMode() == AIM.Focus and .08 or 1
    end

    local scopeMat = Material("jailbreak/vgui/scope.png")
    local percent = 0

    function SWEP:DrawHUD()
        if self:GetNWMode() == AIM.Focus then
            percent = Lerp(FrameTime() * 10, percent, 1)
        else
            percent = Lerp(FrameTime() * 10, percent, 0)
        end

        self.CurFOV = math.Clamp(self.TargetFOV * (1 - percent), 10, self.TargetFOV)
        local trace = LocalPlayer():GetEyeTrace()
        draw.DrawArc(w / 2, h / 2, toHRatio(500) * percent, toHRatio(2500), 360, 30, Color(255, 255, 200, 255 * percent))

        if trace.Entity:IsValid() and trace.Entity:GetClass() == "player" then
            local bone = trace.HitBox

            if bone == 0 then
                surface.SetDrawColor(255, 0, 50, 150 * percent)
            else
                surface.SetDrawColor(0, 0, 0, 150 * percent)
            end
        else
            surface.SetDrawColor(0, 0, 0, 100 * percent)
        end

        surface.DrawLine(0, ScrH() / 2, ScrW(), ScrH() / 2)
        surface.DrawLine(ScrW() / 2, 0, ScrW() / 2, ScrH())
        surface.SetDrawColor(Color(0, 0, 0, 255 * percent))
        surface.DrawRect(0, 0, (ScrW() - h) / 2, h)
        surface.DrawRect(ScrW() - ((ScrW() - h) / 2), 0, (ScrW() - h) / 2, h)
        if not IsValid(LocalPlayer()) then return end
        surface.SetDrawColor(Color(0, 0, 0, 255 * percent))
        surface.SetMaterial(scopeMat)
        surface.DrawTexturedRect((ScrW() / 2) - (h / 2), 0, h, h)
    end
end