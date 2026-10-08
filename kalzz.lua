--[[ KALZZ HUB ULTIMATE | UI Kit | No Standalone AutoGen UI ]]

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RSvc = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local Cam = WS.CurrentCamera

-- ====================================================
-- CONFIG
-- ====================================================
local CFG = _G.KALZZ_CFG or {
    tof_on = true, tof_fov = 480, tof_predict = 3.2, tof_maxdist = 800,
    veil_on = true, veil_fov = 280, veil_maxdist = 500,
    veil_lead = 1.4, veil_speed = 165, veil_grav = 103,
    parry_on = true, parry_radius = 14, parry_sensitive = 200, parry_aggro = true,
    fov_lock_on = true, fov_lock_value = 120,
    fast_vault = true,
    esp_k = true, esp_s = true, esp_g = true, esp_range = 5000,
    alert = true,
    stun_indicator = true,
    gene_on = false, gene_method = "SUCCESS",
}
_G.KALZZ_CFG = CFG

-- ====================================================
-- FOV LOCK REALTIME
-- ====================================================
pcall(function()
    local FOV_TARGET = CFG.fov_lock_value or 120
    local ENABLED = CFG.fov_lock_on ~= false
    local lastApply = 0
    local changing = false
    local camConn = nil

    local function applyFOV()
        if changing then return end
        local c = WS.CurrentCamera
        if not c or not ENABLED then return end
        if math.abs(c.FieldOfView - FOV_TARGET) > 0.01 then
            changing = true
            c.FieldOfView = FOV_TARGET
            changing = false
        end
    end

    local function bindCam()
        if camConn then camConn:Disconnect(); camConn = nil end
        local c = WS.CurrentCamera
        if not c then return end
        camConn = c:GetPropertyChangedSignal("FieldOfView"):Connect(function()
            if not ENABLED or changing then return end
            if math.abs(c.FieldOfView - FOV_TARGET) > 0.01 then
                changing = true
                c.FieldOfView = FOV_TARGET
                changing = false
            end
        end)
    end
    bindCam()

    RSvc.Heartbeat:Connect(function()
        if not ENABLED then return end
        local now = os.clock()
        if now - lastApply < 0.02 then return end
        lastApply = now
        applyFOV()
    end)

    WS:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        task.wait(0.1); bindCam(); applyFOV()
    end)

    _G.KZ_SetFOV = function(v) FOV_TARGET = v; CFG.fov_lock_value = v; applyFOV() end
    _G.KZ_ToggleFOVLock = function(s) ENABLED = s; CFG.fov_lock_on = s; if s then applyFOV() end end
    applyFOV()
    print("[KZ] Realtime FOV Lock | value =", FOV_TARGET)
end)

-- ====================================================
-- REMOTE CACHE
-- ====================================================
local RC = { tof = nil, veil = nil, parry = nil, fastvault = nil }
local function scanRemotes()
    local function scan(parent, depth)
        if depth > 4 or not parent then return end
        for _, o in ipairs(parent:GetChildren()) do
            if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
                local n = o.Name:lower()
                local full = ""
                pcall(function() full = o:GetFullName():lower() end)
                if not RC.tof and (full:find("twist") or full:find("fate")) then RC.tof = o end
                if not RC.veil and (n == "spearthrow" or full:find("spearthrow")) then RC.veil = o end
                if not RC.parry and (n == "parry" or full:find("parrying")) then RC.parry = o end
                if not RC.fastvault and (n == "fastvault" or n == "survivorfastvault") then RC.fastvault = o end
            elseif o:IsA("Folder") or o:IsA("Model") then
                scan(o, depth + 1)
            end
        end
    end
    scan(RS, 0)
end
pcall(function() RC.tof = RS.Remotes.Items["Twist of Fate"].Fire end)
pcall(function() RC.parry = RS.Remotes.Items["Parrying Dagger"].parry end)
scanRemotes()
task.delay(5, scanRemotes)
print("[KZ] RC ToF:", RC.tof ~= nil, "| Veil:", RC.veil ~= nil, "| Parry:", RC.parry ~= nil)

-- ====================================================
-- HELPERS
-- ====================================================
local function isKiller(p)
    if not p or p == LP or not p.Character then return false end
    local role = p.Character:GetAttribute("Role") or p:GetAttribute("Role")
    if type(role) == "string" then
        local r = role:lower()
        if r:find("killer") then return true end
        if r:find("survivor") then return false end
    end
    if p.Team and p.Team.Name then
        local t = p.Team.Name:lower()
        if t:find("killer") then return true end
        if t:find("survivor") then return false end
    end
    return false
end

local function isLocalKiller()
    local ch = LP.Character
    if not ch then return false end
    local role = ch:GetAttribute("Role") or LP:GetAttribute("Role")
    if type(role) == "string" and role:lower():find("killer") then return true end
    if LP.Team and LP.Team.Name:lower():find("killer") then return true end
    return false
end

local function getRoot(ch)
    if not ch then return nil end
    return ch:FindFirstChild("HumanoidRootPart")
end

-- ====================================================
-- SILENT AIM ToF
-- ====================================================
_G.KZ_ToFAimDir = nil
pcall(function()
    local function getMuzzle()
        local char = LP.Character
        if not char then return Cam and Cam.CFrame.Position or Vector3.zero end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local h = tool:FindFirstChild("Handle") or tool:FindFirstChild("Gun") or tool:FindFirstChildWhichIsA("BasePart")
            if h then return h.Position + h.CFrame.LookVector * 2 end
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then return root.Position + Vector3.new(0, 1.5, 0) end
        return Cam and Cam.CFrame.Position or Vector3.zero
    end

    local function getBestToF()
        if not Cam then Cam = WS.CurrentCamera end
        if not Cam then return nil end
        local myRoot = getRoot(LP.Character)
        local myPos = myRoot and myRoot.Position or Cam.CFrame.Position
        local center = Cam.ViewportSize / 2
        local best, bestScore = nil, CFG.tof_fov or 480
        for _, p in ipairs(Players:GetPlayers()) do
            if isKiller(p) then
                local ch = p.Character
                local hum = ch:FindFirstChildOfClass("Humanoid")
                local root = getRoot(ch)
                if hum and hum.Health > 0 and root then
                    local wd = (root.Position - myPos).Magnitude
                    if wd <= (CFG.tof_maxdist or 800) then
                        local sp, on = Cam:WorldToViewportPoint(root.Position)
                        if on and sp.Z > 0 then
                            local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            local score = sd + (wd * 0.08)
                            if score < bestScore then
                                bestScore = score
                                best = root
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    RSvc.Heartbeat:Connect(function()
        if not CFG.tof_on then _G.KZ_ToFAimDir = nil; return end
        local target = getBestToF()
        if not target then _G.KZ_ToFAimDir = nil; return end
        local origin = getMuzzle()
        local vel = target.AssemblyLinearVelocity or Vector3.zero
        vel = Vector3.new(vel.X, 0, vel.Z)
        local dist = (target.Position - origin).Magnitude
        local flight = math.clamp(dist / 240, 0.05, 0.9)
        local pred = target.Position + vel * flight * (CFG.tof_predict or 3.2)
        pred = pred + Vector3.new(0, 1.0, 0)
        local dir = pred - origin
        _G.KZ_ToFAimDir = dir.Magnitude > 0.25 and dir.Unit or nil
    end)
end)

-- ====================================================
-- SILENT AIM Veil
-- ====================================================
_G.KZ_VeilState = { lookVector = nil, target = nil, velHistory = {} }
pcall(function()
    local VS = _G.KZ_VeilState

    local function solvePitch(v0, g, d, dy)
        d = math.max(d, 0.1)
        local s2 = v0 * v0
        local root = s2 * s2 - g * (g * d * d + 2 * dy * s2)
        if root < 0 then root = 0 end
        local tanTheta = (s2 - math.sqrt(root)) / (g * d)
        local theta = math.atan(tanTheta)
        local t = d / (v0 * math.cos(theta))
        return theta, t
    end

    local function getVel(char)
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
        if not root or not root:IsA("BasePart") then return Vector3.zero end
        local now = os.clock()
        local last = VS.velHistory[char]
        local measured = Vector3.zero
        if last and now - last.t > 0.02 then
            measured = (root.Position - last.pos) / (now - last.t)
            if measured.Magnitude > 150 then measured = last.smooth or Vector3.zero end
        end
        local smooth = last and last.smooth or measured
        smooth = smooth:Lerp(measured, 0.65)
        VS.velHistory[char] = { pos = root.Position, t = now, smooth = smooth }
        if smooth.Magnitude < 1 then return Vector3.zero end
        return Vector3.new(smooth.X, 0, smooth.Z)
    end

    Players.PlayerRemoving:Connect(function(p)
        if p.Character then VS.velHistory[p.Character] = nil end
    end)

    RSvc.Heartbeat:Connect(function()
        if not CFG.veil_on or not isLocalKiller() then
            VS.lookVector = nil; VS.target = nil; return
        end
        local cam = WS.CurrentCamera
        if not cam then return end
        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local nearest, nearestPart, bestDist = nil, nil, CFG.veil_fov or 280
        local maxStud = CFG.veil_maxdist or 500

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local pc = p.Character
                local hum = pc:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and not isKiller(p) then
                    local isDown = pc:GetAttribute("Knocked") == true or pc:GetAttribute("HookProgressDepleting") == true
                    if not isDown then
                        local part = pc:FindFirstChild("UpperTorso") or pc:FindFirstChild("Torso") or pc:FindFirstChild("HumanoidRootPart")
                        if part then
                            local sd3 = (part.Position - hrp.Position).Magnitude
                            if sd3 <= maxStud then
                                local sp, on = cam:WorldToViewportPoint(part.Position)
                                if on and sp.Z > 0 then
                                    local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                    if sd < bestDist then bestDist = sd; nearest = p; nearestPart = part end
                                end
                            end
                        end
                    end
                end
            end
        end

        if not nearest or not nearestPart then VS.lookVector = nil; VS.target = nil; return end

        local tp = nearestPart.Position
        local hand = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
        local origin = (hand and hand:IsA("BasePart")) and hand.Position or hrp.Position
        local dir = tp - origin
        local dist = dir.Magnitude
        if dist < 0.1 or dist > maxStud then return end

        local v0 = CFG.veil_speed or 165
        local g = CFG.veil_grav or 103
        local aimPoint = tp
        local vel = getVel(nearest.Character)
        if vel.Magnitude > 0.5 then
            local h0 = Vector3.new(dir.X, 0, dir.Z)
            local _, tFlight = solvePitch(v0, g, h0.Magnitude, dir.Y)
            local ping = 0.08
            pcall(function() ping = math.clamp(LP:GetNetworkPing(), 0, 0.35) end)
            local delay = tFlight + 0.10 + ping + 0.04
            for _ = 1, 2 do
                local lead = vel * delay * (CFG.veil_lead or 1.4)
                local maxLead = math.clamp(dist * 0.6, 3, 45)
                if lead.Magnitude > maxLead then lead = lead.Unit * maxLead end
                aimPoint = tp + lead
                local ad = aimPoint - origin
                local ah = Vector3.new(ad.X, 0, ad.Z)
                local _, t2 = solvePitch(v0, g, math.max(ah.Magnitude, 0.1), ad.Y)
                delay = t2 + 0.10 + ping + 0.04
            end
        end

        local adir = aimPoint - origin
        local ah = Vector3.new(adir.X, 0, adir.Z)
        local ahDist = ah.Magnitude
        local pitch = solvePitch(v0, g, ahDist, adir.Y)
        if ahDist > 0.001 then
            VS.lookVector = ah.Unit * math.cos(pitch) + Vector3.new(0, math.sin(pitch), 0)
        else
            VS.lookVector = adir.Unit
        end
        VS.target = nearest
    end)
end)

-- ====================================================
-- UNIFIED __namecall HOOK
-- ====================================================
pcall(function()
    if type(hookmetamethod) ~= "function" or type(newcclosure) ~= "function" then
        warn("[KZ] hookmetamethod unavailable")
        return
    end

    local OLD
    OLD = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local m
        pcall(function() m = getnamecallmethod() end)
        if not m then return OLD(self, ...) end

        if m == "Kick" then
            if self == LP then return nil end
            return OLD(self, ...)
        end
        if m ~= "FireServer" then return OLD(self, ...) end

        local args = table.pack(...)
        local n = args.n
        if type(self) ~= "userdata" and type(self) ~= "table" then
            return OLD(self, table.unpack(args, 1, n))
        end

        if CFG.tof_on and typeof(_G.KZ_ToFAimDir) == "Vector3" then
            local isToF = false
            if RC.tof and self == RC.tof then isToF = true
            else
                local sname = ""; pcall(function() sname = tostring(self.Name or ""):lower() end)
                local f = ""; pcall(function() f = tostring(self:GetFullName() or ""):lower() end)
                if f:find("twist") or f:find("fate") or f:find("tof")
                   or (sname == "fire" and f:find("tof"))
                   or (sname == "fire" and f:find("fate")) then isToF = true end
            end
            if isToF then
                for i = 1, n do
                    local v = args[i]
                    if typeof(v) == "Vector3" and v.Magnitude <= 5 then
                        args[i] = _G.KZ_ToFAimDir; break
                    end
                end
            end
        end

        if CFG.veil_on and _G.KZ_VeilState and typeof(_G.KZ_VeilState.lookVector) == "Vector3" then
            local isVeil = false
            if RC.veil and self == RC.veil then isVeil = true
            else
                local sname = ""; pcall(function() sname = tostring(self.Name or "") end)
                if sname == "Spearthrow" then isVeil = true end
            end
            if isVeil and typeof(args[1]) == "Vector3" then
                args[1] = _G.KZ_VeilState.lookVector
            end
        end

        return OLD(self, table.unpack(args, 1, n))
    end))
    print("[KZ] unified __namecall hook installed")
end)

-- ====================================================
-- AUTO PARRY
-- ====================================================
pcall(function()
    local VALID = {
        ["122812055447896"]=true, ["133963973694098"]=true, ["117042998468241"]=true,
        ["135002183282873"]=true, ["121216847022485"]=true, ["132817836308238"]=true,
        ["129784271201071"]=true, ["82666958311998"]=true, ["78432063483146"]=true,
        ["118907603246885"]=true, ["139369275981139"]=true, ["110355011987939"]=true,
        ["111920872708571"]=true, ["105374834496520"]=true, ["138720291317243"]=true,
        ["106871536134254"]=true, ["130593238885843"]=true, ["115244153053858"]=true,
        ["74968262036854"]=true, ["113255068724446"]=true, ["98163597193511"]=true,
        ["80411309607666"]=true, ["101344487600812"]=true,
    }
    local ParryRemote = RC.parry
    if not ParryRemote then pcall(function() ParryRemote = RS.Remotes.Items["Parrying Dagger"].parry end) end
    local lastParry = 0
    local busyAnim = false
    local Attached = {}

    local function getRootM(m) return m and (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart) end
    local function getDist(model)
        local my = getRootM(LP.Character); local en = getRootM(model)
        if not my or not en then return 999 end
        return (my.Position - en.Position).Magnitude
    end

    local function setupBusy(char)
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local anim = hum:FindFirstChildOfClass("Animator"); if not anim then return end
        anim.AnimationPlayed:Connect(function(track)
            if not track or not track.Animation then return end
            local n = (track.Animation.Name or ""):lower()
            if n:find("vault") or n:find("window") or n:find("pallet") or n:find("drop") then
                busyAnim = true; task.delay(0.9, function() busyAnim = false end)
            end
        end)
    end

    local function fireMobile()
        pcall(function()
            local mob = PG:FindFirstChild("Survivor-mob"); if not mob then return end
            local controls = mob:FindFirstChild("Controls"); if not controls then return end
            local btn = controls:FindFirstChild("Gui-mob") or controls:FindFirstChild("action") or controls:FindFirstChildWhichIsA("ImageButton")
            if btn and typeof(firesignal) == "function" then
                firesignal(btn.MouseButton1Down); task.wait(0.005); firesignal(btn.MouseButton1Up)
            end
        end)
    end

    local function doParry()
        if busyAnim or not CFG.parry_on then return end
        local now = os.clock()
        if now - lastParry < ((CFG.parry_aggro and 0.04) or 0.11) then return end
        lastParry = now
        if ParryRemote then for _ = 1, 10 do pcall(function() ParryRemote:FireServer() end) end end
        fireMobile()
    end

    local function bind(model)
        if not model or Attached[model] then return end
        Attached[model] = true
        local hum = model:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local anim = hum:FindFirstChildOfClass("Animator")
        if not anim then task.delay(0.35, function() Attached[model]=nil; bind(model) end); return end
        anim.AnimationPlayed:Connect(function(track)
            if not CFG.parry_on or busyAnim then return end
            if not track or not track.Animation then return end
            local id = tostring(track.Animation.AnimationId or ""):match("%d+") or ""
            if not VALID[id] then return end
            local dist = getDist(model)
            local maxR = (CFG.parry_radius or 14) + ((CFG.parry_sensitive or 200) * 0.01)
            if dist > 0 and dist <= maxR then doParry() end
        end)
    end

    local function scan()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then bind(plr.Character) end
        end
        for _, obj in ipairs(WS:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then bind(obj) end
        end
    end

    scan()
    task.spawn(function() while true do task.wait(0.8); scan() end end)
    WS.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            task.wait(0.25); bind(obj)
        end
    end)
    LP.CharacterAdded:Connect(function(c) task.wait(1); setupBusy(c) end)
    if LP.Character then task.spawn(function() setupBusy(LP.Character) end) end
    _G.KZ_ManualParry = doParry
    print("[KZ] Auto Parry Loaded")
end)

-- ====================================================
-- AUTO GENERATOR — Logic only (NO UI)
-- Control via CFG.gene_on + CFG.gene_method
-- ====================================================
pcall(function()
    local SUCCESS_MIN, SUCCESS_MAX = 102, 116
    local NEUTRAL_MIN, NEUTRAL_MAX = 116, 159
    local TriggerDelay = 0.035
    local LastTrigger = 0
    local Busy = false
    local ScourgeActive = false
    local PreviousVisible = false

    local KingScourgeStart, KingScourgeEnd
    pcall(function()
        local KP = RS:WaitForChild("Remotes"):WaitForChild("KillerPerks"):WaitForChild("kingscourge")
        KingScourgeStart = KP:WaitForChild("KingScourgeStart")
        KingScourgeEnd = KP:WaitForChild("KingScourgeEnd")
    end)

    local Check, Line, Goal, Action
    local function RefreshRefs()
        pcall(function()
            local SG = PG:FindFirstChild("SkillCheckPromptGui")
            if SG then
                Check = SG:FindFirstChild("Check")
                if Check then
                    Line = Check:FindFirstChild("Line"); Goal = Check:FindFirstChild("Goal")
                end
            end
            local SV = PG:FindFirstChild("Survivor-mob")
            if SV then
                local C = SV:FindFirstChild("Controls")
                if C then Action = C:FindFirstChild("action") end
            end
        end)
    end
    RefreshRefs()
    task.spawn(function() while true do task.wait(0.5); RefreshRefs() end end)

    local function TriggerAction()
        if not Action then RefreshRefs() end
        if not Action then return false end
        local Now = os.clock()
        if Now - LastTrigger < TriggerDelay then return false end
        LastTrigger = Now
        pcall(function() if Action:IsA("GuiButton") then Action:Activate() end end)
        if typeof(firesignal) == "function" then pcall(function() firesignal(Action.MouseButton1Down) end) end
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
        if not CFG.gene_on or not ScourgeActive then return end
        if not Line or not Goal then RefreshRefs() end
        if not Line or not Goal then return end
        Line.Rotation = (tonumber(Goal.Rotation) or 0) + 109
        TriggerAction()
    end

    if KingScourgeStart then
        KingScourgeStart.OnClientEvent:Connect(function()
            if not CFG.gene_on then return end
            ScourgeActive = true; Busy = false
            task.defer(function()
                if CFG.gene_on and CFG.gene_method == "INSTANT" then InstantScourge() end
            end)
        end)
    end
    if KingScourgeEnd then
        KingScourgeEnd.OnClientEvent:Connect(function() ScourgeActive = false; Busy = false end)
    end

    RSvc.RenderStepped:Connect(function()
        if not CFG.gene_on then PreviousVisible = false; return end
        if not Check then RefreshRefs() end
        if not Check then return end
        local Visible = Check.Visible
        local Mode = CFG.gene_method or "SUCCESS"

        if Visible and not PreviousVisible then
            Busy = false
            if not ScourgeActive and Mode == "INSTANT" then InstantNormal() end
        end
        PreviousVisible = Visible

        if Visible and not ScourgeActive and not Busy then
            local Trig = false
            if Mode == "SUCCESS" then Trig = IsSuccess()
            elseif Mode == "NEUTRAL" then Trig = IsNeutral() end
            if Trig then Busy = true; TriggerAction(); task.delay(0.07, function() Busy = false end) end
        end

        if ScourgeActive and Visible then
            if Mode == "SUCCESS" and not Busy and IsSuccess() then
                Busy = true; TriggerAction(); task.delay(0.06, function() Busy = false end)
            elseif Mode == "NEUTRAL" and not Busy and IsNeutral() then
                Busy = true; TriggerAction(); task.delay(0.06, function() Busy = false end)
            end
        end
    end)

    task.spawn(function()
        local LastGoal = nil
        while true do
            task.wait(0.005)
            if CFG.gene_on and ScourgeActive and (CFG.gene_method or "") == "INSTANT" then
                RefreshRefs()
                if Check and Check.Visible and Goal and Line then
                    local CG = tonumber(Goal.Rotation) or 0
                    if LastGoal == nil then LastGoal = CG; InstantScourge()
                    elseif math.abs(CG - LastGoal) > 1 then LastGoal = CG; InstantScourge() end
                end
            else LastGoal = nil end
        end
    end)

    LP.CharacterAdded:Connect(function()
        Busy = false; ScourgeActive = false; PreviousVisible = false
        task.wait(1); RefreshRefs()
    end)

    print("[KZ] Auto Generator Logic loaded (no UI)")
end)

-- ====================================================
-- FAST VAULT
-- ====================================================
pcall(function()
    local lastFV = 0
    local FV_ANIM_ID = "79965656177566"
    local function onAnim(t)
        if not CFG.fast_vault or not t or not t.Animation then return end
        local n = (t.Animation.Name or ""):lower()
        local id = tostring(t.Animation.AnimationId or "")
        if n:find("vault") or n:find("window") or n:find("pallet") or n:find("climb") or id:find(FV_ANIM_ID) then
            local now = os.clock()
            if now - lastFV < 0.1 then return end
            lastFV = now
            pcall(function() t:AdjustSpeed(1.7) end)
            if RC.fastvault then pcall(function() RC.fastvault:FireServer() end) end
        end
    end
    LP.CharacterAdded:Connect(function(c)
        task.wait(1)
        local hum = c:FindFirstChildOfClass("Humanoid")
        local anim = hum and hum:FindFirstChildOfClass("Animator")
        if anim then anim.AnimationPlayed:Connect(onAnim) end
    end)
    if LP.Character then task.spawn(function()
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        local anim = hum and hum:FindFirstChildOfClass("Animator")
        if anim then anim.AnimationPlayed:Connect(onAnim) end
    end) end
end)

-- ====================================================
-- ESP
-- ====================================================
pcall(function()
    local CK = Color3.fromRGB(230,80,80)
    local CS = Color3.fromRGB(80,160,230)
    local CGr = Color3.fromRGB(80,220,120)
    local eD, eG = {}, {}
    local ep = PG

    local function dESP(pl)
        local d = eD[pl]; if not d then return end
        pcall(function() if d.hl then d.hl:Destroy() end end); eD[pl] = nil
    end
    local function isGD(o)
        local p = o:FindFirstChild("Progress") or o:GetAttribute("Progress")
        if typeof(p)=="number" and p >= 100 then return true end
        return false
    end
    local function isG(o)
        if not o or not o.Parent then return false end
        if not (o:IsA("Model") or o:IsA("BasePart")) then return false end
        local n = o.Name:lower()
        return n:find("generator") or n:find("fuse")
    end

    RSvc.Heartbeat:Connect(function()
        local mr = getRoot(LP.Character)
        local mp = mr and mr.Position or Cam.CFrame.Position
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and pl.Character then
                local ch = pl.Character
                local hrp = getRoot(ch)
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local isK = isKiller(ch)
                    local en = (isK and CFG.esp_k) or (not isK and CFG.esp_s)
                    if en and (hrp.Position - mp).Magnitude <= CFG.esp_range then
                        if not eD[pl] then
                            local hl = Instance.new("Highlight", ep)
                            hl.Name = "KZ_HL"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            eD[pl] = {hl = hl}
                        end
                        local d = eD[pl]; local cl = isK and CK or CS
                        d.hl.Adornee = ch; d.hl.FillColor = cl; d.hl.OutlineColor = cl
                        d.hl.FillTransparency = 0.55; d.hl.OutlineTransparency = 0; d.hl.Enabled = true
                    else
                        if eD[pl] and eD[pl].hl then eD[pl].hl.Enabled = false end
                    end
                else dESP(pl) end
            elseif eD[pl] then dESP(pl) end
        end
    end)

    local genCache, genT = {}, 0
    task.spawn(function()
        while true do
            task.wait(2)
            if CFG.esp_g then
                local now = os.clock()
                if now - genT > 5 then
                    genCache = {}
                    for _, o in ipairs(WS:GetDescendants()) do if isG(o) then table.insert(genCache, o) end end
                    genT = now
                end
                for _, o in ipairs(genCache) do
                    if o.Parent and not isGD(o) and not eG[o] then
                        local hl = Instance.new("Highlight", ep)
                        hl.Name = "KZ_GEN"; hl.Adornee = o
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillColor = CGr; hl.FillTransparency = 0.6; hl.OutlineColor = CGr
                        eG[o] = hl
                    end
                end
            else
                for _, hl in pairs(eG) do pcall(function() hl:Destroy() end) end
                eG = {}
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(p) dESP(p) end)
end)

-- ====================================================
-- PROXIMITY ALERT
-- ====================================================
pcall(function()
    local ag = Instance.new("ScreenGui")
    ag.Name = "KZ_Alert"; ag.ResetOnSpawn = false; ag.IgnoreGuiInset = true; ag.DisplayOrder = 1000001
    ag.Parent = PG
    local al = Instance.new("TextLabel", ag)
    al.Size = UDim2.fromOffset(260,60); al.Position = UDim2.new(0.5,-130,0.14,0)
    al.BackgroundTransparency = 1; al.TextColor3 = Color3.fromRGB(240,210,140)
    al.Font = Enum.Font.GothamBlack; al.TextSize = 34
    al.TextStrokeTransparency = 0; al.TextStrokeColor3 = Color3.fromRGB(0,0,0); al.Visible = false
    local as = Instance.new("TextLabel", ag)
    as.Size = UDim2.fromOffset(260,16); as.Position = UDim2.new(0.5,-130,0.14,58)
    as.BackgroundTransparency = 1; as.TextColor3 = Color3.fromRGB(230,230,240)
    as.Font = Enum.Font.GothamBold; as.TextSize = 11; as.TextStrokeTransparency = 0.3; as.Visible = false

    RSvc.Heartbeat:Connect(function()
        if not CFG.alert then al.Visible=false; as.Visible=false; return end
        local mr = getRoot(LP.Character); if not mr then al.Visible=false; as.Visible=false; return end
        local cl = math.huge
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and pl.Character then
                local ch = pl.Character; local hrp = getRoot(ch)
                if hrp and isKiller(ch) then
                    local hu = ch:FindFirstChildOfClass("Humanoid")
                    if hu and hu.Health > 0 then
                        local d = (hrp.Position - mr.Position).Magnitude
                        if d < cl then cl = d end
                    end
                end
            end
        end
        if cl < math.huge then
            local t, c
            if cl <= 10 then t="!!!"; c=Color3.fromRGB(255,90,90)
            elseif cl <= 17 then t="!!"; c=Color3.fromRGB(255,160,100)
            elseif cl <= 25 then t="!"; c=Color3.fromRGB(255,220,130)
            else al.Visible=false; as.Visible=false; return end
            al.Text = t; al.TextColor3 = c; al.Visible = true
            as.Text = string.format("KILLER %.1f studs", cl); as.Visible = true
        else al.Visible=false; as.Visible=false end
    end)
end)

-- ====================================================
-- STUN INDICATOR
-- ====================================================
pcall(function()
    local stunBB = {}
    local function isStunned(hum, char)
        if not hum then return false end
        if hum.WalkSpeed <= 4 and not hum.Sit then return true end
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Stunned or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Ragdoll then return true end
        return false
    end
    local function cBB(root)
        local bb = Instance.new("BillboardGui")
        bb.Name = "KZ_Stun"; bb.Size = UDim2.fromOffset(100,28); bb.StudsOffset = Vector3.new(0,4.2,0)
        bb.AlwaysOnTop = true; bb.Adornee = root; bb.Parent = PG
        local bg = Instance.new("Frame", bb); bg.Size = UDim2.new(1,0,1,0)
        bg.BackgroundColor3 = Color3.fromRGB(20,20,25); bg.BackgroundTransparency = 0.25; bg.BorderSizePixel = 0
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0,6)
        local lbl = Instance.new("TextLabel", bg); lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
        lbl.Text = "STUNNED"; lbl.TextColor3 = Color3.fromRGB(255,220,40); lbl.TextStrokeTransparency = 0.3
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
        return bb
    end
    RSvc.Heartbeat:Connect(function()
        if not CFG.stun_indicator then
            for plr, bb in pairs(stunBB) do pcall(function() bb:Destroy() end); stunBB[plr]=nil end
            return
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LP or not plr.Character or not isKiller(plr.Character) then
                if stunBB[plr] then pcall(function() stunBB[plr]:Destroy() end); stunBB[plr]=nil end
            else
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and root then
                    if isStunned(hum, plr.Character) then
                        if not stunBB[plr] then stunBB[plr] = cBB(root) end
                    else
                        if stunBB[plr] then pcall(function() stunBB[plr]:Destroy() end); stunBB[plr]=nil end
                    end
                end
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(plr) if stunBB[plr] then pcall(function() stunBB[plr]:Destroy() end); stunBB[plr]=nil end end)
end)

-- ====================================================
-- UI KIT — Control Hub (No Standalone AutoGen)
-- ====================================================
pcall(function()
    local COL = {
        bg = Color3.fromRGB(15,15,18),
        panel = Color3.fromRGB(20,20,24),
        card = Color3.fromRGB(26,26,32),
        tabOn = Color3.fromRGB(38,38,46),
        brd = Color3.fromRGB(48,48,56),
        tx = Color3.fromRGB(240,240,245),
        txD = Color3.fromRGB(160,160,175),
        acc = Color3.fromRGB(100,140,230),
        off = Color3.fromRGB(52,52,62),
        red = Color3.fromRGB(220,80,80),
        grn = Color3.fromRGB(80,220,120),
    }

    local UI = Instance.new("ScreenGui")
    UI.Name = "KalzzHub"
    UI.ResetOnSpawn = false
    UI.IgnoreGuiInset = true
    UI.DisplayOrder = 999999
    pcall(function() if gethui then UI.Parent = gethui() else UI.Parent = game:GetService("CoreGui") end end)
    if not UI.Parent then UI.Parent = PG end
    Instance.new("UIScale", UI).Scale = 0.80

    local function cR(o, r) local c = Instance.new("UICorner", o); c.CornerRadius = UDim.new(0, r or 8); return c end
    local function cS(o, c, t) local s = Instance.new("UIStroke", o); s.Color = c or COL.brd; s.Thickness = t or 1; s.Transparency = 0.4; return s end

    local Main = Instance.new("Frame", UI)
    Main.Size = UDim2.fromOffset(340, 420)
    Main.Position = UDim2.new(0.5, -170, 0.5, -210)
    Main.BackgroundColor3 = COL.bg
    Main.BackgroundTransparency = 0.15
    Main.BorderSizePixel = 0
    Main.ZIndex = 10
    cR(Main, 10); cS(Main, COL.brd, 1)

    local Hdr = Instance.new("Frame", Main)
    Hdr.Size = UDim2.new(1, 0, 0, 42)
    Hdr.BackgroundColor3 = COL.panel
    Hdr.BackgroundTransparency = 0.15
    Hdr.BorderSizePixel = 0
    Hdr.ZIndex = 11
    cR(Hdr, 10)

    local Title = Instance.new("TextLabel", Hdr)
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.fromOffset(14, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "KALZZ HUB"
    Title.TextColor3 = COL.tx
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 12

    local MinBtn = Instance.new("TextButton", Hdr)
    MinBtn.Size = UDim2.fromOffset(24, 24)
    MinBtn.Position = UDim2.new(1, -32, 0.5, -12)
    MinBtn.BackgroundColor3 = COL.card
    MinBtn.Text = "–"
    MinBtn.TextColor3 = COL.tx
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14
    MinBtn.BorderSizePixel = 0
    MinBtn.ZIndex = 12
    cR(MinBtn, 6)

    local Body = Instance.new("Frame", Main)
    Body.Size = UDim2.new(1, -16, 1, -58)
    Body.Position = UDim2.fromOffset(8, 50)
    Body.BackgroundTransparency = 1
    Body.ZIndex = 11

    local SL = Instance.new("ScrollingFrame", Body)
    SL.Size = UDim2.new(1, 0, 1, 0)
    SL.BackgroundTransparency = 1
    SL.BorderSizePixel = 0
    SL.ScrollBarThickness = 3
    SL.ScrollBarImageColor3 = COL.brd
    SL.CanvasSize = UDim2.new(0, 0, 0, 800)
    SL.ZIndex = 12

    local yPos = 4
    local function nextY(h)
        local y = yPos; yPos = yPos + h; SL.CanvasSize = UDim2.new(0, 0, 0, yPos + 8); return y
    end

    -- Section header
    local function section(txt)
        local l = Instance.new("TextLabel", SL)
        l.Size = UDim2.new(1, -8, 0, 22)
        l.Position = UDim2.fromOffset(4, nextY(26))
        l.BackgroundTransparency = 1
        l.Text = string.upper(txt)
        l.TextColor3 = COL.acc
        l.Font = Enum.Font.GothamBold
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 13
    end

    -- Toggle row
    local function toggle(label, key, cb)
        local row = Instance.new("Frame", SL)
        row.Size = UDim2.new(1, -8, 0, 36)
        row.Position = UDim2.fromOffset(4, nextY(40))
        row.BackgroundColor3 = COL.card
        row.BackgroundTransparency = 0.4
        row.BorderSizePixel = 0
        row.ZIndex = 13
        cR(row, 6); cS(row, COL.brd, 1)

        local txt = Instance.new("TextLabel", row)
        txt.Size = UDim2.new(1, -70, 1, 0)
        txt.Position = UDim2.fromOffset(12, 0)
        txt.BackgroundTransparency = 1
        txt.Text = label
        txt.TextColor3 = COL.tx
        txt.Font = Enum.Font.GothamMedium
        txt.TextSize = 12
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.ZIndex = 14

        local state = CFG[key] ~= false and CFG[key] ~= nil
        local sw = Instance.new("Frame", row)
        sw.Size = UDim2.fromOffset(36, 20)
        sw.Position = UDim2.new(1, -48, 0.5, -10)
        sw.BackgroundColor3 = state and COL.acc or COL.off
        sw.BorderSizePixel = 0
        sw.ZIndex = 14
        cR(sw, 10)
        local knob = Instance.new("Frame", sw)
        knob.Size = UDim2.fromOffset(14, 14)
        knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 15
        cR(knob, 7)

        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 16
        btn.MouseButton1Click:Connect(function()
            state = not state
            local T = game:GetService("TweenService")
            T:Create(knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
            T:Create(sw, TweenInfo.new(0.15), {BackgroundColor3 = state and COL.acc or COL.off}):Play()
            CFG[key] = state
            if cb then pcall(cb, state) end
        end)
    end

    -- Cycle button (untuk mode)
    local function cycle(label, key, values, cb)
        local row = Instance.new("Frame", SL)
        row.Size = UDim2.new(1, -8, 0, 36)
        row.Position = UDim2.fromOffset(4, nextY(40))
        row.BackgroundColor3 = COL.card
        row.BackgroundTransparency = 0.4
        row.BorderSizePixel = 0
        row.ZIndex = 13
        cR(row, 6); cS(row, COL.brd, 1)

        local txt = Instance.new("TextLabel", row)
        txt.Size = UDim2.new(0.5, 0, 1, 0)
        txt.Position = UDim2.fromOffset(12, 0)
        txt.BackgroundTransparency = 1
        txt.Text = label
        txt.TextColor3 = COL.tx
        txt.Font = Enum.Font.GothamMedium
        txt.TextSize = 12
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.ZIndex = 14

        local val = Instance.new("TextLabel", row)
        val.Size = UDim2.new(0.5, -12, 1, 0)
        val.Position = UDim2.new(0.5, 0, 0, 0)
        val.BackgroundTransparency = 1
        val.Text = tostring(CFG[key] or values[1])
        val.TextColor3 = COL.acc
        val.Font = Enum.Font.GothamBold
        val.TextSize = 12
        val.TextXAlignment = Enum.TextXAlignment.Right
        val.ZIndex = 14

        local idx = 1
        for i, v in ipairs(values) do if v == CFG[key] then idx = i; break end end

        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 15
        btn.MouseButton1Click:Connect(function()
            idx = idx % #values + 1
            CFG[key] = values[idx]
            val.Text = tostring(values[idx])
            if cb then pcall(cb, values[idx]) end
        end)
    end

    -- Slider
    local function slider(label, key, min, max, cb)
        local row = Instance.new("Frame", SL)
        row.Size = UDim2.new(1, -8, 0, 48)
        row.Position = UDim2.fromOffset(4, nextY(52))
        row.BackgroundColor3 = COL.card
        row.BackgroundTransparency = 0.4
        row.BorderSizePixel = 0
        row.ZIndex = 13
        cR(row, 6); cS(row, COL.brd, 1)

        local txt = Instance.new("TextLabel", row)
        txt.Size = UDim2.new(0.6, 0, 0, 18)
        txt.Position = UDim2.fromOffset(12, 6)
        txt.BackgroundTransparency = 1
        txt.Text = label
        txt.TextColor3 = COL.tx
        txt.Font = Enum.Font.GothamMedium
        txt.TextSize = 12
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.ZIndex = 14

        local vL = Instance.new("TextLabel", row)
        vL.Size = UDim2.new(0.4, -12, 0, 18)
        vL.Position = UDim2.new(0.6, 0, 0, 6)
        vL.BackgroundTransparency = 1
        vL.Text = tostring(CFG[key] or min)
        vL.TextColor3 = COL.acc
        vL.Font = Enum.Font.GothamBold
        vL.TextSize = 12
        vL.TextXAlignment = Enum.TextXAlignment.Right
        vL.ZIndex = 14

        local track = Instance.new("Frame", row)
        track.Size = UDim2.new(1, -24, 0, 4)
        track.Position = UDim2.new(0, 12, 1, -14)
        track.BackgroundColor3 = COL.off
        track.BackgroundTransparency = 0.1
        track.BorderSizePixel = 0
        track.ZIndex = 14
        cR(track, 2)

        local pct = ((CFG[key] or min) - min) / (max - min)
        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        fill.BackgroundColor3 = COL.acc
        fill.BorderSizePixel = 0
        fill.ZIndex = 15
        cR(fill, 2)

        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.fromOffset(12, 12)
        knob.Position = UDim2.new(pct, -6, 0.5, -6)
        knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 16
        cR(knob, 6)

        local hb = Instance.new("TextButton", row)
        hb.Size = UDim2.new(1, -20, 0, 24)
        hb.Position = UDim2.new(0, 10, 1, -24)
        hb.BackgroundTransparency = 1
        hb.Text = ""
        hb.ZIndex = 17

        local drag = false
        local function upd(x)
            local a = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max - min) * a + 0.5)
            fill.Size = UDim2.new(a, 0, 1, 0)
            knob.Position = UDim2.new(a, -6, 0.5, -6)
            vL.Text = tostring(v)
            CFG[key] = v
            if cb then pcall(cb, v) end
        end
        hb.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true; upd(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                upd(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
        end)
    end

    -- Button (aksi)
    local function action(label, cb)
        local row = Instance.new("TextButton", SL)
        row.Size = UDim2.new(1, -8, 0, 32)
        row.Position = UDim2.fromOffset(4, nextY(36))
        row.BackgroundColor3 = COL.card
        row.BackgroundTransparency = 0.4
        row.BorderSizePixel = 0
        row.Text = label
        row.TextColor3 = COL.tx
        row.Font = Enum.Font.GothamBold
        row.TextSize = 12
        row.AutoButtonColor = false
        row.ZIndex = 13
        cR(row, 6); cS(row, COL.brd, 1)
        row.MouseButton1Click:Connect(function()
            if cb then pcall(cb) end
        end)
    end

    -- BUILD UI
    section("Silent Aim")
    toggle("ToF Silent Aim", "tof_on")
    slider("ToF FOV", "tof_fov", 50, 800)
    slider("ToF Predict x10", "tof_predict", 10, 60, function(v) CFG.tof_predict = v/10 end)
    slider("ToF Max Dist", "tof_maxdist", 100, 2000)

    section("Veil Silent Aim")
    toggle("Veil Enable", "veil_on")
    slider("Veil FOV", "veil_fov", 50, 700)
    slider("Veil Max Dist", "veil_maxdist", 100, 1500)
    slider("Veil Lead x10", "veil_lead", 5, 30, function(v) CFG.veil_lead = v/10 end)
    slider("Spear Speed", "veil_speed", 80, 400)
    slider("Spear Gravity", "veil_grav", 50, 250)

    section("Auto Parry")
    toggle("Parry Enable", "parry_on")
    slider("Radius", "parry_radius", 1, 30)
    slider("Sensitivity", "parry_sensitive", 0, 500)
    toggle("Aggressive", "parry_aggro")
    action("Manual Parry (P)", function() if _G.KZ_ManualParry then _G.KZ_ManualParry() end end)

    section("Auto Generator")
    toggle("Auto Gen Enable", "gene_on")
    cycle("Mode", "gene_method", {"SUCCESS", "NEUTRAL", "INSTANT"})

    section("Vision")
    toggle("FOV Lock", "fov_lock_on", function(v) if _G.KZ_ToggleFOVLock then _G.KZ_ToggleFOVLock(v) end end)
    slider("FOV Value", "fov_lock_value", 30, 140, function(v) if _G.KZ_SetFOV then _G.KZ_SetFOV(v) end end)
    toggle("Killer ESP", "esp_k")
    toggle("Survivor ESP", "esp_s")
    toggle("Generator ESP", "esp_g")
    slider("ESP Range", "esp_range", 100, 5000)

    section("Extras")
    toggle("Fast Vault", "fast_vault")
    toggle("Proximity Alert", "alert")
    toggle("Stun Indicator", "stun_indicator")

    -- DRAG
    local drag, ds, sp
    Hdr.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = i.Position; sp = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)

    -- MINIMIZE
    local min = false
    MinBtn.MouseButton1Click:Connect(function()
        min = not min
        Main.Size = min and UDim2.fromOffset(340, 42) or UDim2.fromOffset(340, 420)
        MinBtn.Text = min and "+" or "–"
    end)

    -- TOGGLE UI via RightShift
    local visible = true
    UIS.InputBegan:Connect(function(i, g)
        if g then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            visible = not visible
            Main.Visible = visible
        end
    end)

    print("[KZ] UI Kit loaded — RightShift to toggle")
end)

-- ====================================================
-- KEYBINDS
-- ====================================================
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.V then CFG.tof_on = not CFG.tof_on; print("[KZ] ToF:", CFG.tof_on) end
    if i.KeyCode == Enum.KeyCode.B then CFG.veil_on = not CFG.veil_on; print("[KZ] Veil:", CFG.veil_on) end
    if i.KeyCode == Enum.KeyCode.P then if _G.KZ_ManualParry then _G.KZ_ManualParry() end end
end)

print("==========================================")
print("[KALZZ HUB ULTIMATE] ALL FEATURES LOADED")
print("==========================================")
print("UI Kit: RightShift toggle | Drag header")
print("Keybinds: V=ToF | B=Veil | P=Parry")
print("==========================================")
