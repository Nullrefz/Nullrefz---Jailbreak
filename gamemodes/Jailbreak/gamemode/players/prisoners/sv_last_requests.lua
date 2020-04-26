util.AddNetworkString("SendCustomLR")
util.AddNetworkString("SetLRPlayer")
util.AddNetworkString("SetLR")
util.AddNetworkString("SendLR")
util.AddNetworkString("RequestLR")
util.AddNetworkString("GiveFreeday")
JB.curLRDay = ""

net.Receive("SendLR", function(ln, ply)
    local lrNotification = {
        TEXT = "Last request given",
        TYPE = 2,
        TIME = 7,
        COLOR = Color(255, 175, 0, 200)
    }

    local lastRequest = net.ReadString()

    if lastRequest == "tic tac toe" then
        JB:SetTicTacToe()
    elseif lastRequest == "knife battle" then
        JB:SetKnifeBattle()
    elseif lastRequest == "calendar" then
        JB:OpenMenu(lastRequest)
    elseif lastRequest == "sniper battle" then
        JB:SetSniperBattle()
    elseif lastRequest == "custom" then
        JB:SetCustom()
    elseif lastRequest ~= "" then
        local notification = {
            TEXT = "Next round is gonna be " .. lastRequest,
            TYPE = 2,
            TIME = 10,
            COLOR = Color(255, 0, 0, 200)
        }

        JB:SendNotification(lrNotification)
        JB:SendNotification(notification)
        JB.nextDay = lastRequest
    end
end)

net.Receive("GiveFreeday", function(ln, ply)
    local players = net.ReadTable()
    JB:SetExclusiveFreeday(players)
end)

--End the round
function JB:SetExclusiveFreeday(players)
    for k, v in pairs(players) do
        local notification = {
            TEXT = "Next round " .. v:Name() .. " will receive a freeday",
            TYPE = 2,
            TIME = 5,
            COLOR = Color(255, 175, 0, 200)
        }
        self.nextDay = lastRequest
        self:UpdateLR()
        self:SendNotification(notification)
    end
end

function JB:SetTicTacToe()
    -- TP players to tic tac toe
end

function JB:SetKnifeBattle()
    -- TP players to knife battle
end

function JB:SetSniperBattle()
    -- TP players to sniper battle
end

function JB:SetCustom()
    -- Open Message Text
end

function JB:ConsumeLR()
    if self.nextDay ~= "" then
        self.curLR = self.nextDay
        self:HandleDay(self.curLR)
        self.nextDay = ""
    end
end

function JB:UpdateLR(ply)
    net.Start("SetLR")
    net.WriteString(self.nextDay)

    if ply then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

function JB:InitiateLR(ply)
    local notification = {
        TEXT = ply:Name() .. " gets the last request",
        TYPE = 2
    }

    self:SendNotification(notification)
    local playersToHighlight = {ply}
    self:HighlightPlayer(playersToHighlight)
    self:SetLRPlayer(ply)
end

function JB:EndLR()
    self.curLRDay = ""
    self:HighlightPlayer()
    self:SetLRPlayer()
    self:UpdateLR()
end

net.Receive("RequestLR", function(ln, ply)
    JB:UpdateLR(ply)
end)

hook.Add("jb_round_active", "HonorLR", function()
    JB:ConsumeLR()
end)

hook.Add("jb_round_ending", "ResetLR", function()
    JB:EndLR()
end)

function JB:SetLRPlayer(ply)
    net.Start("SetLRPlayer")
    net.WriteEntity(ply)

    if ply then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

function JB:CheckLR()
    if #self:GetAlivePlayersByTeam(Team.PRISONERS) ~= 1 or self.dayPhase == "Purge Day" or self.dayPhase == "Warday" or self:GetActivePhase() ~= "Active" then return end
    self:InitiateLR(self:GetAlivePlayersByTeam(Team.PRISONERS)[1])
end

hook.Add("PostPlayerDeath", "CheckForLR", function(ply)
    if ply:Team() > Team.PRISONERS then return end
    JB:CheckLR()
end)

hook.Add("PlayerDisconnected", "CheckForLRAfterDisconnect", function(ply)
    if ply:Team() > Team.PRISONERS then return end
    JB:CheckLR()
end)