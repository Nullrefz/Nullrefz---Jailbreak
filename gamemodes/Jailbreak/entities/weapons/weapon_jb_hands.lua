AddCSLuaFile()
SWEP.PrintName = "Hands"
SWEP.Author = "Kilburn, robotboy655, MaxOfS2D & Tenrys & Nullrefz"
SWEP.Purpose = ""
SWEP.Base = "weapon_jb_base"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.Spawnable = false
SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false
SWEP.HitDistance = 48
SWEP.CanDrop = false
SWEP.TargetFOV = 68

if (CLIENT) then
    SWEP.PrintName = "Hands"
    SWEP.Author = "Counter-Strike"
    SWEP.Slot = 0
    SWEP.SlotPos = 1
    SWEP.IconLetter = "H"




end


local SwingSound = Sound("WeaponFrag.Throw")
local HitSound = Sound("Flesh.ImpactHard")
local fov = 45

function SWEP:Initialize()
    self:SetHoldType("fist")
end

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "NextMeleeAttack")
    self:NetworkVar("Float", 1, "NextIdle")
    self:NetworkVar("Int", 2, "Combo")
end

function SWEP:UpdateNextIdle()
    local vm = self.Owner:GetViewModel()
    self:SetNextIdle(CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate())
end

function SWEP:PrimaryAttack(right)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    local anim = "fists_left"

    if (right) then
        anim = "fists_right"
    end

    if (self:GetCombo() >= 2) then
        anim = "fists_uppercut"
    end

    local vm = self.Owner:GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
    self:EmitSound(SwingSound)
    self:UpdateNextIdle()
    self:SetNextMeleeAttack(CurTime() + 0.2)
    self:SetNextPrimaryFire(CurTime() + 0.9)
    self:SetNextSecondaryFire(CurTime() + 0.9)
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack(true)
end

function SWEP:DealDamage()
    local anim = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())
    self.Owner:LagCompensation(true)

    local tr = util.TraceLine({
        start = self.Owner:GetShootPos(),
        endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
        filter = self.Owner,
        mask = MASK_SHOT_HULL
    })

    if (not IsValid(tr.Entity)) then
        tr = util.TraceHull({
            start = self.Owner:GetShootPos(),
            endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
            filter = self.Owner,
            mins = Vector(-10, -10, -8),
            maxs = Vector(10, 10, 8),
            mask = MASK_SHOT_HULL
        })
    end

    -- We need the second part for single player because SWEP:Think is ran shared in SP
    if (tr.Hit and not (game.SinglePlayer() and CLIENT)) then
        self:EmitSound(HitSound)
    end

    local hit = false

    if (SERVER and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0)) then
        local dmginfo = DamageInfo()
        local attacker = self.Owner

        if (not IsValid(attacker)) then
            attacker = self
        end

        dmginfo:SetAttacker(attacker)
        dmginfo:SetInflictor(self)
        dmginfo:SetDamage(math.random(8, 12))

        if (anim == "fists_left") then
            dmginfo:SetDamageForce(self.Owner:GetRight() * 4912 + self.Owner:GetForward() * 9998) -- Yes we need those specific numbers
        elseif (anim == "fists_right") then
            dmginfo:SetDamageForce(self.Owner:GetRight() * -4912 + self.Owner:GetForward() * 9989)
        elseif (anim == "fists_uppercut") then
            dmginfo:SetDamageForce(self.Owner:GetUp() * 5158 + self.Owner:GetForward() * 10012)
            dmginfo:SetDamage(math.random(12, 24))
        end

        tr.Entity:TakeDamageInfo(dmginfo)
        hit = true
    end

    if (SERVER and IsValid(tr.Entity)) then
        local phys = tr.Entity:GetPhysicsObject()

        if (IsValid(phys)) then
            phys:ApplyForceOffset(self.Owner:GetAimVector() * 80 * phys:GetMass(), tr.HitPos)
        end
    end

    if (SERVER) then
        if (hit and anim ~= "fists_uppercut") then
            self:SetCombo(self:GetCombo() + 1)
        else
            self:SetCombo(0)
        end
    end

    self.Owner:LagCompensation(false)
end

function SWEP:OnDrop()
    self:Remove() -- You can't drop fists
end

function SWEP:Deploy()
    local speed = GetConVarNumber("sv_defaultdeployspeed")
    local vm = self.Owner:GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))
    vm:SetPlaybackRate(speed)
    self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration() / speed)
    self:SetNextSecondaryFire(CurTime() + vm:SequenceDuration() / speed)
    self:UpdateNextIdle()

    if (SERVER) then
        self:SetCombo(0)
    end

    return true
end

-- function SWEP:Holster(newWeapon)
--     local complete = false

--     LerpFloat(50, self.ViewModelFOV, 3, function(val)
--         fov = val
--     end, INTERPOLATION.SmoothStep, function()
--         complete = true
--         newWeapon:Deploy()
--     end)

--     return true
-- end

function SWEP:Think()
    local vm = self.Owner:GetViewModel()
    local curtime = CurTime()
    local idletime = self:GetNextIdle()

    if (idletime > 0 and CurTime() > idletime) then
        vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_idle_0" .. math.random(1, 2)))
        self:UpdateNextIdle()
    end

    local meleetime = self:GetNextMeleeAttack()

    if (meleetime > 0 and CurTime() > meleetime) then
        self:DealDamage()
        self:SetNextMeleeAttack(0)
    end

    if (SERVER and CurTime() > self:GetNextPrimaryFire() + 0.1) then
        self:SetCombo(0)
    end
end

function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:Reload()
    return false
end
