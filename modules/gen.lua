--[[
    KALZZSCRIPT
    modules/auto-gen.lua - Auto Generator Skill Check
]]

local S = _G.KZ
if not S then return end

local function autoGen()
    local SUCCESS_MIN, SUCCESS_MAX = 102, 116
    local NEUTRAL_MIN, NEUTRAL_MAX = 116, 159
    local TriggerDelay = 0.035
    local LastTrigger = 0
    local Busy = false
    local ScourgeActive = false
    local KingScourgeStart, KingScourgeEnd

    pcall(function()
        local KP = S.RS:WaitForChild("Remotes"):WaitForChild("KillerPerks"):WaitForChild("kingscourge")
        KingScourgeStart = KP:WaitForChild("KingScourgeStart")
        KingScourgeEnd = KP:WaitForChild("KingScourgeEnd")
    end)

    local Check, Line, Goal, Action

    local function RefreshRefs()
        pcall(function()
            local SG = S.PG:FindFirstChild("SkillCheckPromptGui")
            if SG then
                Check = SG:FindFirstChild("Check")
                if Check then
                    Line = Check:FindFirstChild("Line")
                    Goal = Check:FindFirstChild("Goal")
                end
            end
            local SV = S.PG:FindFirstChild("Survivor-mob")
            if SV then
                local C = SV:FindFirstChild("Controls")
                if C then Action = C:FindFirstChild("action") end
            end
        end)
    end

    RefreshRefs()
    task.spawn(function()
        while true do
            task.wait(0.5)
            RefreshRefs()
        end
    end)

    local function TriggerAction()
        if not Action then RefreshRefs() end
        if not Action then return false end
        local Now = os.clock()
        if Now - LastTrigger < TriggerDelay then return false end
        LastTrigger = Now
        pcall(function()
            if Action:IsA("GuiButton") then Action:Activate() end
        end)
        if typeof(firesignal) == "function" then
            pcall(function() firesignal(Action.MouseButton1Down) end)
        end
        return true
    end

    local function GetAngle()
        if not Line or not Goal then return nil end
        return tonumber(Line.Rotation) or 0, tonumber(Goal.Rotation) or 0
    end

    local function IsSuccess()
        local LR, GR = GetAngle()
        if not LR then return false end
        return LR >= GR + SUCCESS_MIN and LR <= GR + SUCCESS_MAX
    end

    local function IsNeutral()
        local LR, GR = GetAngle()
        if not LR then return false end
        return LR > GR + NEUTRAL_MIN and LR <= GR + NEUTRAL_MAX
    end

    local function InstantNormal()
        if not Check or not Line or not Goal then RefreshRefs() end
        if not Check or not Line or not Goal or not Check.Visible then return end
        Line.Rotation = (tonumber(Goal.Rotation) or 0) + 109
        TriggerAction()
    end

    local function InstantScourge()
        if not S.CFG.gene_on or not ScourgeActive then return end
        if not Line or not Goal then RefreshRefs() end
        if not Line or not Goal then return end
        Line.Rotation = (tonumber(Goal.Rotation) or 0) + 109
        TriggerAction()
    end

    if KingScourgeStart then
        KingScourgeStart.OnClientEvent:Connect(function()
            if not S.CFG.gene_on then return end
            ScourgeActive = true
            Busy = false
            task.defer(function()
                if S.CFG.gene_on and S.CFG.gene_method == "INSTANT" then
                    InstantScourge()
                end
            end)
        end)
    end

    if KingScourgeEnd then
        KingScourgeEnd.OnClientEvent:Connect(function()
            ScourgeActive = false
            Busy = false
        end)
    end

    local PreviousVisible = false

    S.RSvc.RenderStepped:Connect(function()
        if not S.CFG.gene_on then
            PreviousVisible = false
            return
        end
        if not Check then RefreshRefs() end
        if not Check then return end

        local Visible = Check.Visible
        local Mode = S.CFG.gene_method or "SUCCESS"

        if Visible and not PreviousVisible then
            Busy = false
            if not ScourgeActive and Mode == "INSTANT" then
                InstantNormal()
            end
        end
        PreviousVisible = Visible

        if Visible and not ScourgeActive and not Busy then
            local ShouldTrigger = false
            if Mode == "SUCCESS" then
                ShouldTrigger = IsSuccess()
            elseif Mode == "NEUTRAL" then
                ShouldTrigger = IsNeutral()
            end
            if ShouldTrigger then
                Busy = true
                TriggerAction()
                task.delay(0.07, function() Busy = false end)
            end
        end

        if ScourgeActive and Visible then
            if Mode == "SUCCESS" and not Busy and IsSuccess() then
                Busy = true
                TriggerAction()
                task.delay(0.06, function() Busy = false end)
            elseif Mode == "NEUTRAL" and not Busy and IsNeutral() then
                Busy = true
                TriggerAction()
                task.delay(0.06, function() Busy = false end)
            elseif Mode == "INSTANT" then
                local CG = tonumber(Goal.Rotation) or 0
                local CL = tonumber(Line.Rotation) or 0
                if math.abs(CL - CG) > 130 then Busy = false end
            end
        end
    end)

    -- Instant loop (Scourge)
    task.spawn(function()
        local LastGoal = nil
        while true do
            task.wait(0.005)
            if S.CFG.gene_on and ScourgeActive and (S.CFG.gene_method or "") == "INSTANT" then
                RefreshRefs()
                if Check and Check.Visible and Goal and Line then
                    local CG = tonumber(Goal.Rotation) or 0
                    if LastGoal == nil then
                        LastGoal = CG
                        InstantScourge()
                    elseif math.abs(CG - LastGoal) > 1 then
                        LastGoal = CG
                        InstantScourge()
                    end
                end
            else
                LastGoal = nil
            end
        end
    end)

    S.LP.CharacterAdded:Connect(function()
        Busy = false
        ScourgeActive = false
        PreviousVisible = false
        task.wait(1)
        RefreshRefs()
    end)

    print("[KZ] auto-gen logic started")
end

pcall(autoGen)
print("[KZ] auto-gen loaded")
