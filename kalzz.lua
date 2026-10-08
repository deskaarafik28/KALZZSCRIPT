--[[ KALZZ HUB v12 FINAL | 1 Hook | ToF + Veil + AntiKick | All Features ]]

local P    = game:GetService("Players")
local RS   = game:GetService("ReplicatedStorage")
local RSvc = game:GetService("RunService")
local UIS  = game:GetService("UserInputService")
local WS   = game:GetService("Workspace")
local L    = game:GetService("Lighting")
local TS   = game:GetService("TweenService")
local CG   = game:GetService("CoreGui")
local LP   = P.LocalPlayer
local PG   = LP:WaitForChild("PlayerGui")
local Cam  = WS.CurrentCamera

local INV = "dCYTep9cY"
local URL = "https://discord.gg/"..INV

-- ============================================
-- CONFIG
-- ============================================
local DEF = {
    gene_on=false, gene_method="SUCCESS",
    fast_vault=true,
    parry_on=true, parry_radius=14, parry_sensitive=200,
    parry_aggro=true, parry_circle=true,
    -- ToF
    tof_on=true, tof_fov=500, tof_predict=2.8,
    -- Veil
    veil_on=true, veil_fov=320, veil_predict=2.8,
    -- Misc
    fov_lock_on=true, fov_lock_value=120,
    ambient_on=true, boost_fps=true,
    esp_k=true, esp_s=true, esp_g=true, esp_out=false, esp_range=5000,
    alert=true, stun_indicator=true,
}
local CFG = _G.KALZZ_CFG or {}
for k,v in pairs(DEF) do if CFG[k]==nil then CFG[k]=v end end
_G.KALZZ_CFG = CFG

-- ============================================
-- STATE
-- ============================================
_G.KZ_ToFAimDir = nil
_G.KZ_ToFLockedName = ""
_G.KZ_VeilState = { lookVector = nil, target = nil }

-- ============================================
-- REMOTE CACHE (dengan fallback)
-- ============================================
local RC = { tof=nil, veil=nil, parry=nil, fastvault=nil }
pcall(function()
    RC.tof = RS.Remotes.Items["Twist of Fate"].Fire
end)
pcall(function()
    RC.veil = RS.Remotes.Killers.Veil.Spearthrow
end)
-- fallback scan
local function rescan()
    for _, o in ipairs(RS:GetDescendants()) do
        if o:IsA("RemoteEvent") then
            local n = o.Name:lower()
            local f = ""
            pcall(function() f = o:GetFullName():lower() end)
            if not RC.tof and (n=="fire") and (f:find("twist") or f:find("fate")) then RC.tof = o end
            if not RC.veil and (n=="spearthrow" or n=="spear") then RC.veil = o end
            if not RC.parry and (n=="parry" or f:find("parrying")) then RC.parry = o end
            if not RC.fastvault and (n=="fastvault" or n=="survivorfastvault") then RC.fastvault = o end
        end
    end
end
pcall(function() RC.parry = RS.Remotes.Items["Parrying Dagger"].parry end)
rescan()
task.delay(5, rescan)
task.delay(15, rescan)

-- ============================================
-- HELPERS
-- ============================================
local PID = {
    ["122812055447896"]=1,["133963973694098"]=1,["117042998468241"]=1,["135002183282873"]=1,
    ["121216847022485"]=1,["132817836308238"]=1,["129784271201071"]=1,["82666958311998"]=1,
    ["78432063483146"]=1,["118907603246885"]=1,["139369275981139"]=1,["110355011987939"]=1,
    ["111920872708571"]=1,["105374834496520"]=1,["138720291317243"]=1,["106871536134254"]=1,
    ["130593238885843"]=1,["115244153053858"]=1,["74968262036854"]=1,["113255068724446"]=1,
    ["98163597193511"]=1,["80411309607666"]=1,["101344487600812"]=1,
}
local function rtp(m) if not m then return nil end return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("RootPart") or m:FindFirstChildWhichIsA("BasePart") end
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
local function isKillerChar(ch)
    if not ch or not ch.Parent then return false end
    local pl = P:GetPlayerFromCharacter(ch)
    if not pl then return false end
    return isKiller(pl)
end
local function getRoot(m)
    return m and (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart)
end
_G.KZ_isKiller = isKillerChar

local Sched = { _t = {} }
function Sched:Add(name, fn, hz) self._t[name] = { fn = fn, interval = 1/(hz or 30), last = 0 } end
RSvc.Heartbeat:Connect(function()
    local now = os.clock()
    for _, t in pairs(Sched._t) do
        if now - t.last >= t.interval then t.last = now; pcall(t.fn) end
    end
end)

local COL = {
    bg=Color3.fromRGB(15,15,18), panel=Color3.fromRGB(20,20,24), side=Color3.fromRGB(17,17,21),
    card=Color3.fromRGB(26,26,32), tabOn=Color3.fromRGB(38,38,46), brd=Color3.fromRGB(48,48,56),
    brdS=Color3.fromRGB(38,38,46), tx=Color3.fromRGB(240,240,245), txD=Color3.fromRGB(160,160,175),
    txF=Color3.fromRGB(110,110,125), acc=Color3.fromRGB(100,140,230), off=Color3.fromRGB(52,52,62),
}
local TR, TRP, TRC = 0.30, 0.30, 0.50

-- ============================================
-- AIM LOOP — ToF + Veil (source asli)
-- ============================================
local function getClosest(wantKiller, fov)
    if not Cam then Cam = WS.CurrentCamera end
    if not Cam then return nil end
    local center = Cam.ViewportSize / 2
    local best, bestD = nil, fov
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and p.Character then
            local k = isKiller(p)
            if (wantKiller and k) or (not wantKiller and not k) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local root = getRoot(p.Character)
                if hum and hum.Health > 0 and root then
                    local sp, on = Cam:WorldToViewportPoint(root.Position)
                    if on and sp.Z > 0 then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < bestD then bestD = d; best = root end
                    end
                end
            end
        end
    end
    return best
end

local function getMuzzle()
    local char = LP.Character
    if not char then return Cam and Cam.CFrame.Position or Vector3.zero end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local h = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
        if h then return h.Position + h.CFrame.LookVector * 2 end
    end
    local r = getRoot(char)
    return r and (r.Position + Vector3.new(0, 1.5, 0)) or (Cam and Cam.CFrame.Position or Vector3.zero)
end

RSvc.Heartbeat:Connect(function()
    Cam = WS.CurrentCamera

    -- ToF → Killer
    if CFG.tof_on then
        local t = getClosest(true, CFG.tof_fov)
        if t then
            local origin = getMuzzle()
            local vel = t.AssemblyLinearVelocity or Vector3.zero
            vel = Vector3.new(vel.X, 0, vel.Z)
            local dist = (t.Position - origin).Magnitude
            local ft = math.clamp(dist / 260, 0.04, 0.7)
            local pred = t.Position + vel * ft * CFG.tof_predict + Vector3.new(0, 0.9, 0)
            local dir = pred - origin
            _G.KZ_ToFAimDir = dir.Magnitude > 0.2 and dir.Unit or nil
            local plr = P:GetPlayerFromCharacter(t.Parent)
            _G.KZ_ToFLockedName = plr and plr.Name or ""
        else
            _G.KZ_ToFAimDir = nil
            _G.KZ_ToFLockedName = ""
        end
    else
        _G.KZ_ToFAimDir = nil
    end

    -- Veil → Survivor
    if CFG.veil_on then
        local t = getClosest(false, CFG.veil_fov)
        local my = getRoot(LP.Character)
        if t and my then
            local origin = my.Position
            local hand = LP.Character:FindFirstChild("RightHand")
            if hand then origin = hand.Position end
            local vel = t.AssemblyLinearVelocity or Vector3.zero
            vel = Vector3.new(vel.X, 0, vel.Z)
            local dist = (t.Position - origin).Magnitude
            local ft = math.clamp(dist / 200, 0.05, 0.6)
            local pred = t.Position + vel * ft * CFG.veil_predict
            pred = pred + Vector3.new(0, math.clamp(dist * 0.05, 2, 14), 0)
            local dir = pred - origin
            _G.KZ_VeilState.lookVector = dir.Magnitude > 0.5 and dir.Unit or nil
            _G.KZ_VeilState.target = t
        else
            _G.KZ_VeilState.lookVector = nil
            _G.KZ_VeilState.target = nil
        end
    else
        _G.KZ_VeilState.lookVector = nil
    end
end)

-- ============================================
-- 1 HOOK: Kick + ToF + Veil (KALZZ ALL WORK)
-- ============================================
pcall(function()
    if type(hookmetamethod) ~= "function" or type(newcclosure) ~= "function" then
        warn("[KZ] hookmetamethod tidak tersedia")
        return
    end
    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local m
        pcall(function() m = getnamecallmethod() end)
        if not m then return old(self, ...) end

        if m == "Kick" and self == LP then return nil end

        if m ~= "FireServer" then
            return old(self, ...)
        end

        local args = table.pack(...)
        local n = args.n
        if type(self) ~= "userdata" and type(self) ~= "table" then
            return old(self, table.unpack(args, 1, n))
        end

        -- ToF
        if CFG.tof_on and typeof(_G.KZ_ToFAimDir) == "Vector3" then
            local isToF = (RC.tof and self == RC.tof)
            if not isToF then
                local sn, fn = "", ""
                pcall(function() sn = tostring(self.Name or ""):lower() end)
                pcall(function() fn = tostring(self:GetFullName() or ""):lower() end)
                if fn:find("twist") or fn:find("fate") or fn:find("tof") then
                    isToF = true
                end
                if sn == "fire" and (fn:find("tof") or fn:find("fate")) then
                    isToF = true
                end
            end
            if isToF then
                for i = 1, n do
                    local v = args[i]
                    if typeof(v) == "Vector3" and v.Magnitude <= 5 then
                        args[i] = _G.KZ_ToFAimDir
                        break
                    end
                end
            end
        end

        -- Veil
        if CFG.veil_on and _G.KZ_VeilState and typeof(_G.KZ_VeilState.lookVector) == "Vector3" then
            local isVeil = (RC.veil and self == RC.veil)
            if not isVeil then
                local sn = ""
                pcall(function() sn = tostring(self.Name or "") end)
                if sn == "Spearthrow" then isVeil = true end
            end
            if isVeil and typeof(args[1]) == "Vector3" and args[1].Magnitude <= 5 then
                args[1] = _G.KZ_VeilState.lookVector
            end
        end

        return old(self, table.unpack(args, 1, n))
    end))
    print("[KZ] hook installed (Kick + ToF + Veil)")
end)

-- ============================================
-- FOV LOCK REALTIME
-- ============================================
pcall(function()
    local FOV_TARGET = CFG.fov_lock_value or 120
    local ENABLED = CFG.fov_lock_on ~= false
    local lastApply = 0
    local changing = false
    local function applyFOV()
        if changing then return end
        local c = WS.CurrentCamera
        if not c or not ENABLED then return end
        if math.abs(c.FieldOfView - FOV_TARGET) > 0.01 then
            changing = true; c.FieldOfView = FOV_TARGET; changing = false
        end
    end
    RSvc.Heartbeat:Connect(function()
        if not ENABLED then return end
        local now = os.clock()
        if now - lastApply < 0.02 then return end
        lastApply = now
        FOV_TARGET = CFG.fov_lock_value or 120
        ENABLED = CFG.fov_lock_on ~= false
        applyFOV()
    end)
    applyFOV()
end)

-- ============================================
-- AMBIENT + BOOST
-- ============================================
RSvc.Heartbeat:Connect(function()
    if CFG.ambient_on then
        pcall(function()
            L.Ambient = Color3.fromRGB(180,180,180)
            L.Brightness = 3
            L.OutdoorAmbient = Color3.fromRGB(180,180,180)
            L.GlobalShadows = false
            L.ClockTime = 14
        end)
    end
    if CFG.boost_fps then
        pcall(function() if setfpscap then setfpscap(240) end end)
    end
end)

-- ============================================
-- AUTO PARRY
-- ============================================
pcall(function()
    local ParryRemote = RC.parry
    if not ParryRemote then pcall(function() ParryRemote = RS.Remotes.Items["Parrying Dagger"].parry end) end
    local lastParry = 0
    local busyAnim = false
    local Attached = {}
    local function getDist(model)
        local my = getRoot(LP.Character); local en = getRoot(model)
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
    _G.KZ_ManualParry = doParry
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
            if not PID[id] then return end
            local dist = getDist(model)
            local maxR = (CFG.parry_radius or 14) + ((CFG.parry_sensitive or 200) * 0.01)
            if dist > 0 and dist <= maxR then doParry() end
        end)
    end
    local function scan()
        for _, plr in ipairs(P:GetPlayers()) do
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
    UIS.InputBegan:Connect(function(i,g) if g then return end if i.KeyCode==Enum.KeyCode.P then doParry() end end)

    -- Parry Circle
    local base = Instance.new("Part")
    base.Name = "KZ_ParryCircle"; base.Size = Vector3.new(1, 0.05, 1); base.Anchored = true
    base.CanCollide = false; base.CanQuery = false; base.CanTouch = false
    base.CastShadow = false; base.Material = Enum.Material.SmoothPlastic
    base.Transparency = 1; base.Parent = WS
    local sg = Instance.new("SurfaceGui", base)
    sg.Face = Enum.NormalId.Top; sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    sg.PixelsPerStud = 40; sg.LightInfluence = 0; sg.ZOffset = 1
    local ring = Instance.new("Frame", sg)
    ring.AnchorPoint = Vector2.new(0.5,0.5); ring.Position = UDim2.fromScale(0.5,0.5); ring.Size = UDim2.fromScale(0.96,0.96)
    ring.BackgroundTransparency = 1; ring.BorderSizePixel = 0
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1,0)
    local s1 = Instance.new("UIStroke", ring)
    s1.Thickness = 5; s1.Color = Color3.fromRGB(100,140,230); s1.Transparency = 1
    s1.LineJoinMode = Enum.LineJoinMode.Round
    local curC, fIn = Color3.fromRGB(100,140,230), 0
    local prev = os.clock()
    Sched:Add("Parry_Circle", function()
        local now = os.clock()
        local dt = now - prev; prev = now
        local hrp = LP.Character and (LP.Character:FindFirstChild("HumanoidRootPart") or LP.Character.PrimaryPart)
        local act = CFG.parry_on and CFG.parry_circle and hrp
        if act then fIn = math.min(1, fIn+dt*5) else fIn = math.max(0, fIn-dt*5) end
        if fIn <= 0.001 then base.Transparency = 1 return end
        if act then
            local hasE = false
            for _, pl in ipairs(P:GetPlayers()) do
                if pl ~= LP and pl.Character and isKiller(pl) then
                    local er = pl.Character:FindFirstChild("HumanoidRootPart")
                    if er then
                        local hu = pl.Character:FindFirstChildOfClass("Humanoid")
                        if hu and hu.Health > 0 and (er.Position - hrp.Position).Magnitude <= CFG.parry_radius then hasE = true; break end
                    end
                end
            end
            curC = curC:Lerp(hasE and Color3.fromRGB(230,90,90) or Color3.fromRGB(100,140,230), math.min(1, dt*8))
            local r = CFG.parry_radius * 2
            base.Size = Vector3.new(r, 0.05, r)
            base.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2.95, 0))
            s1.Color = curC
            s1.Transparency = math.clamp(1 - (fIn * 0.8), 0, 1)
        else
            s1.Transparency = math.clamp(1 - (fIn * 0.72), 0, 1)
        end
    end, 60)
end)

-- ============================================
-- AUTO GENERATOR
-- ============================================
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
                    Line = Check:FindFirstChild("Line")
                    Goal = Check:FindFirstChild("Goal")
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
end)

-- ============================================
-- FAST VAULT
-- ============================================
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

-- ============================================
-- ESP ALL
-- ============================================
pcall(function()
    local CK_E = Color3.fromRGB(230, 80, 80)
    local CS_E = Color3.fromRGB(80, 160, 230)
    local CG_E = Color3.fromRGB(80, 220, 120)
    local playerHL = {}
    local genHL = {}
    local genCache, genCacheT = {}, 0
    local ep = PG

    local function clearHL(tbl, key)
        if tbl[key] then pcall(function() tbl[key]:Destroy() end); tbl[key] = nil end
    end
    local function isGenerator(obj)
        if not obj or not obj.Parent then return false end
        if not (obj:IsA("Model") or obj:IsA("BasePart")) then return false end
        local n = obj.Name:lower()
        if n == "gen" then return false end
        return n:find("generator") or n:find("fuse")
    end
    local function isGenDone(obj)
        if not obj or not obj.Parent then return true end
        if obj:GetAttribute("Completed") or obj:GetAttribute("Finished") or obj:GetAttribute("Done") then return true end
        local prog = obj:GetAttribute("Progress") or obj:GetAttribute("progress")
        if typeof(prog) == "number" and prog >= 99.5 then return true end
        local p = obj:FindFirstChild("Progress", true)
        if p then
            if p:IsA("NumberValue") or p:IsA("IntValue") then
                if p.Value >= 99.5 then return true end
            elseif p:IsA("StringValue") then
                local n = tonumber(p.Value)
                if n and n >= 99.5 then return true end
            end
        end
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                local t = d.Text or ""
                local pct = t:match("(%d+)%s*%%")
                if pct and tonumber(pct) >= 100 then return true end
            end
            if d:IsA("NumberValue") and d.Name:lower():find("progress") then
                if d.Value >= 99.5 then return true end
            end
        end
        return false
    end

    Sched:Add("ESP_Players", function()
        local my = getRoot(LP.Character)
        local myPos = my and my.Position or (Cam and Cam.CFrame.Position) or Vector3.zero
        for _, pl in ipairs(P:GetPlayers()) do
            if pl == LP then
                clearHL(playerHL, pl)
            else
                local ch = pl.Character
                if not ch then clearHL(playerHL, pl)
                else
                    local root = getRoot(ch)
                    local hum = ch:FindFirstChildOfClass("Humanoid")
                    if not root or not hum or hum.Health <= 0 then
                        clearHL(playerHL, pl)
                    else
                        local killer = isKiller(pl)
                        local enabled = (killer and CFG.esp_k) or (not killer and CFG.esp_s)
                        local dist = (root.Position - myPos).Magnitude
                        if enabled and dist <= (CFG.esp_range or 5000) then
                            if not playerHL[pl] then
                                local hl = Instance.new("Highlight")
                                hl.Name = "KZ_ESP"
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = ep
                                playerHL[pl] = hl
                            end
                            local hl = playerHL[pl]
                            hl.Adornee = ch
                            hl.FillColor = killer and CK_E or CS_E
                            hl.OutlineColor = killer and CK_E or CS_E
                            hl.FillTransparency = CFG.esp_out and 1 or 0.55
                            hl.OutlineTransparency = 0
                            hl.Enabled = true
                        else
                            if playerHL[pl] then playerHL[pl].Enabled = false end
                        end
                    end
                end
            end
        end
    end, 5)

    Sched:Add("ESP_Gen", function()
        if not CFG.esp_g then
            for o, hl in pairs(genHL) do pcall(function() hl:Destroy() end); genHL[o] = nil end
            return
        end
        local now = os.clock()
        if now - genCacheT > 4 then
            genCache = {}
            for _, o in ipairs(WS:GetDescendants()) do
                if isGenerator(o) then table.insert(genCache, o) end
            end
            genCacheT = now
        end
        for _, o in ipairs(genCache) do
            if not o.Parent then clearHL(genHL, o)
            elseif isGenDone(o) then clearHL(genHL, o)
            else
                if not genHL[o] then
                    local hl = Instance.new("Highlight")
                    hl.Name = "KZ_GEN"
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = ep
                    genHL[o] = hl
                end
                local hl = genHL[o]
                hl.Adornee = o
                hl.FillColor = CG_E
                hl.OutlineColor = CG_E
                hl.FillTransparency = CFG.esp_out and 1 or 0.6
                hl.OutlineTransparency = 0
                hl.Enabled = true
            end
        end
        for o, hl in pairs(genHL) do
            if not o.Parent or isGenDone(o) then clearHL(genHL, o) end
        end
    end, 2)

    P.PlayerRemoving:Connect(function(pl) clearHL(playerHL, pl) end)
end)

-- ============================================
-- ALERT + STUN
-- ============================================
pcall(function()
    local ag = Instance.new("ScreenGui")
    ag.Name = "KZ_Alert"; ag.ResetOnSpawn = false; ag.IgnoreGuiInset = true; ag.DisplayOrder = 1000001
    ag.Parent = PG
    local al = Instance.new("TextLabel", ag)
    al.Size = UDim2.fromOffset(260,60); al.Position = UDim2.new(0.5,-130,0.14,0)
    al.BackgroundTransparency = 1; al.TextColor3 = Color3.fromRGB(240,210,140)
    al.Font = Enum.Font.GothamBlack; al.TextSize = 34
    al.TextStrokeTransparency = 0; al.TextStrokeColor3 = Color3.fromRGB(0,0,0); al.Visible = false
    local as2 = Instance.new("TextLabel", ag)
    as2.Size = UDim2.fromOffset(260,16); as2.Position = UDim2.new(0.5,-130,0.14,58)
    as2.BackgroundTransparency = 1; as2.TextColor3 = Color3.fromRGB(230,230,240)
    as2.Font = Enum.Font.GothamBold; as2.TextSize = 11; as2.TextStrokeTransparency = 0.3; as2.Visible = false
    Sched:Add("Alert", function()
        if not CFG.alert then al.Visible=false; as2.Visible=false; return end
        local mr = getRoot(LP.Character); if not mr then al.Visible=false; as2.Visible=false; return end
        local cl = math.huge
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= LP and pl.Character and isKiller(pl) then
                local hrp = getRoot(pl.Character)
                if hrp then
                    local hu = pl.Character:FindFirstChildOfClass("Humanoid")
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
            else al.Visible=false; as2.Visible=false; return end
            al.Text = t; al.TextColor3 = c; al.Visible = true
            as2.Text = string.format("KILLER %.1f studs", cl); as2.Visible = true
        else al.Visible=false; as2.Visible=false end
    end, 5)
end)

pcall(function()
    local stunBB = {}
    local function isStunned(hum)
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
    Sched:Add("Stun", function()
        if not CFG.stun_indicator then
            for plr, bb in pairs(stunBB) do pcall(function() bb:Destroy() end); stunBB[plr]=nil end
            return
        end
        for _, plr in ipairs(P:GetPlayers()) do
            if plr == LP or not plr.Character or not isKiller(plr) then
                if stunBB[plr] then pcall(function() stunBB[plr]:Destroy() end); stunBB[plr]=nil end
            else
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and root then
                    if isStunned(hum) then
                        if not stunBB[plr] then stunBB[plr] = cBB(root) end
                    else
                        if stunBB[plr] then pcall(function() stunBB[plr]:Destroy() end); stunBB[plr]=nil end
                    end
                end
            end
        end
    end, 10)
end)

-- ============================================
-- UI HUB
-- ============================================
local GUI, Main
pcall(function()
    local function getParentTarget()
        if gethui then local ok, h = pcall(gethui); if ok and h then return h end end
        return CG
    end

    GUI = Instance.new("ScreenGui")
    GUI.Name = "KalzzHub_"..tostring(os.time())
    GUI.ResetOnSpawn = false
    GUI.IgnoreGuiInset = true
    GUI.DisplayOrder = 999999
    GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GUI.Enabled = true
    pcall(function() GUI.Parent = getParentTarget() end)
    if not GUI.Parent then GUI.Parent = PG end
    Instance.new("UIScale", GUI).Scale = 0.80

    local function cR(o,r) local c=Instance.new("UICorner",o) c.CornerRadius=UDim.new(0,r or 8) return c end
    local function cS(o,c,t,tr) local s=Instance.new("UIStroke",o) s.Color=c or COL.brd s.Thickness=t or 1 s.Transparency=tr or 0.4 return s end

    Main = Instance.new("Frame", GUI)
    Main.Name = "KZ_Main"
    Main.Size = UDim2.fromOffset(580, 480)
    Main.Position = UDim2.new(0.5,-290,0.5,-240)
    Main.BackgroundColor3 = COL.bg
    Main.BackgroundTransparency = TR
    Main.BorderSizePixel = 0; Main.ZIndex = 10
    cR(Main,10); cS(Main,COL.brd,1,0.4)

    local Hdr = Instance.new("Frame", Main)
    Hdr.Size = UDim2.new(1,0,0,48)
    Hdr.BackgroundColor3 = COL.panel
    Hdr.BackgroundTransparency = TRP
    Hdr.BorderSizePixel = 0; Hdr.ZIndex = 11; cR(Hdr,10)

    local Title = Instance.new("TextLabel", Hdr)
    Title.Size = UDim2.new(1,-140,0,20)
    Title.Position = UDim2.fromOffset(18,8)
    Title.BackgroundTransparency = 1
    Title.Text = "KALZZ HUB v12"
    Title.TextColor3 = COL.tx; Title.Font = Enum.Font.GothamBold; Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left; Title.ZIndex = 12

    local Sub = Instance.new("TextLabel", Hdr)
    Sub.Size = UDim2.new(1,-140,0,14)
    Sub.Position = UDim2.fromOffset(18,28)
    Sub.BackgroundTransparency = 1
    Sub.Text = "discord.gg/"..INV.."  |  1 Hook All Work"
    Sub.TextColor3 = COL.txF; Sub.Font = Enum.Font.Gotham; Sub.TextSize = 10
    Sub.TextXAlignment = Enum.TextXAlignment.Left; Sub.ZIndex = 12

    local MinBtn = Instance.new("TextButton", Hdr)
    MinBtn.Size = UDim2.fromOffset(26,26); MinBtn.Position = UDim2.new(1,-68,0.5,-13)
    MinBtn.BackgroundColor3 = Color3.fromRGB(60,60,75); MinBtn.Text = "–"
    MinBtn.TextColor3 = Color3.fromRGB(240,240,240); MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14; MinBtn.BorderSizePixel = 0; MinBtn.AutoButtonColor = false; MinBtn.ZIndex = 12
    cR(MinBtn,6)

    local ClsBtn = Instance.new("TextButton", Hdr)
    ClsBtn.Size = UDim2.fromOffset(26,26); ClsBtn.Position = UDim2.new(1,-36,0.5,-13)
    ClsBtn.BackgroundColor3 = Color3.fromRGB(220,80,80); ClsBtn.Text = "×"
    ClsBtn.TextColor3 = Color3.fromRGB(240,240,240); ClsBtn.Font = Enum.Font.GothamBold
    ClsBtn.TextSize = 14; ClsBtn.BorderSizePixel = 0; ClsBtn.AutoButtonColor = false; ClsBtn.ZIndex = 12
    cR(ClsBtn,6)

    local drg, ds, sp
    Hdr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drg = true; ds = i.Position; sp = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - ds
            Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=false end
    end)

    local Side = Instance.new("Frame", Main)
    Side.Size = UDim2.new(0,150,1,-58); Side.Position = UDim2.fromOffset(8,54)
    Side.BackgroundColor3 = COL.side; Side.BackgroundTransparency = TRP
    Side.BorderSizePixel = 0; Side.ZIndex = 11; cR(Side,8)

    local SideL = Instance.new("ScrollingFrame", Side)
    SideL.Size = UDim2.new(1,-8,1,-8); SideL.Position = UDim2.fromOffset(4,4)
    SideL.BackgroundTransparency = 1; SideL.BorderSizePixel = 0
    SideL.ScrollBarThickness = 2; SideL.ScrollBarImageColor3 = COL.brd
    SideL.CanvasSize = UDim2.new(0,0,0,300); SideL.ZIndex = 12

    local Cont = Instance.new("Frame", Main)
    Cont.Size = UDim2.new(1,-172,1,-58); Cont.Position = UDim2.fromOffset(162,54)
    Cont.BackgroundColor3 = COL.bg; Cont.BackgroundTransparency = TRP
    Cont.BorderSizePixel = 0; Cont.ZIndex = 11; cR(Cont,8)

    local CT = Instance.new("TextLabel", Cont)
    CT.Size = UDim2.new(1,-32,0,22); CT.Position = UDim2.fromOffset(16,14)
    CT.BackgroundTransparency = 1; CT.Text = ""
    CT.TextColor3 = COL.tx; CT.Font = Enum.Font.GothamBold; CT.TextSize = 16
    CT.TextXAlignment = Enum.TextXAlignment.Left; CT.ZIndex = 12

    local CSL = Instance.new("ScrollingFrame", Cont)
    CSL.Size = UDim2.new(1,-16,1,-50); CSL.Position = UDim2.fromOffset(8,44)
    CSL.BackgroundTransparency = 1; CSL.BorderSizePixel = 0
    CSL.ScrollBarThickness = 3; CSL.ScrollBarImageColor3 = COL.brd
    CSL.CanvasSize = UDim2.new(0,0,0,2000); CSL.ZIndex = 12

    local W = {T={},TB={},Cur=nil,Cnt=0}
    function W:Show(n)
        for k,p in pairs(self.T) do p.P.Visible = (k==n) end
        for k,b in pairs(self.TB) do
            local a = (k==n)
            TS:Create(b,TweenInfo.new(0.15),{BackgroundColor3=a and COL.tabOn or COL.side,BackgroundTransparency=a and 0 or 1}):Play()
            local l = b:FindFirstChild("Lbl")
            if l then TS:Create(l,TweenInfo.new(0.15),{TextColor3=a and COL.tx or COL.txD}):Play() end
        end
        self.Cur = n; CT.Text = n
    end

    function W:AddTab(cfg)
        local n = cfg.Title
        self.Cnt = self.Cnt + 1
        local i = self.Cnt - 1
        local b = Instance.new("TextButton", SideL)
        b.Size = UDim2.new(1,-4,0,34); b.Position = UDim2.new(0,2,0,i*38+2)
        b.BackgroundColor3 = COL.side; b.BackgroundTransparency = 1
        b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false; b.ZIndex = 13; cR(b,6)
        local l = Instance.new("TextLabel", b)
        l.Name = "Lbl"; l.Size = UDim2.new(1,-20,1,0); l.Position = UDim2.fromOffset(14,0)
        l.BackgroundTransparency = 1; l.Text = n
        l.TextColor3 = COL.txD; l.Font = Enum.Font.GothamMedium; l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 14
        b.MouseButton1Click:Connect(function() W:Show(n) end)
        local p = Instance.new("Frame", CSL)
        p.Size = UDim2.new(1,0,0,2000); p.BackgroundTransparency = 1; p.Visible = false; p.ZIndex = 13
        local t = {P=p, Y=4}

        function t:Sec(s)
            local x = Instance.new("TextLabel", p)
            x.Size = UDim2.new(1,-8,0,24); x.Position = UDim2.fromOffset(4, self.Y)
            x.BackgroundTransparency = 1; x.Text = string.upper(s)
            x.TextColor3 = COL.txF; x.Font = Enum.Font.GothamBold; x.TextSize = 11
            x.TextXAlignment = Enum.TextXAlignment.Left; x.ZIndex = 14
            self.Y = self.Y + 28
            return self
        end

        function t:Btn(c)
            local b2 = Instance.new("TextButton", p)
            b2.Size = UDim2.new(1,-8,0,38); b2.Position = UDim2.fromOffset(4, self.Y)
            b2.BackgroundColor3 = COL.card; b2.BackgroundTransparency = TRC
            b2.BorderSizePixel = 0; b2.Text = ""; b2.AutoButtonColor = false; b2.ZIndex = 14
            cR(b2,8); cS(b2,COL.brdS,1,0.5)
            local l2 = Instance.new("TextLabel", b2)
            l2.Size = UDim2.new(1,-20,1,0); l2.Position = UDim2.fromOffset(14,0)
            l2.BackgroundTransparency = 1; l2.Text = c.Title
            l2.TextColor3 = COL.tx; l2.Font = Enum.Font.GothamMedium; l2.TextSize = 12
            l2.TextXAlignment = Enum.TextXAlignment.Left; l2.ZIndex = 15
            b2.MouseButton1Click:Connect(function() if c.Callback then pcall(c.Callback) end end)
            self.Y = self.Y + 44
            return self
        end

        function t:Tog(id, c)
            local row = Instance.new("Frame", p)
            row.Size = UDim2.new(1,-8,0,42); row.Position = UDim2.fromOffset(4, self.Y)
            row.BackgroundColor3 = COL.card; row.BackgroundTransparency = TRC
            row.BorderSizePixel = 0; row.ZIndex = 14
            cR(row,8); cS(row,COL.brdS,1,0.5)
            local l2 = Instance.new("TextLabel", row)
            l2.Size = UDim2.new(1,-80,1,0); l2.Position = UDim2.fromOffset(14,0)
            l2.BackgroundTransparency = 1; l2.Text = c.Title or id
            l2.TextColor3 = COL.tx; l2.Font = Enum.Font.GothamMedium; l2.TextSize = 12
            l2.TextXAlignment = Enum.TextXAlignment.Left; l2.ZIndex = 15
            local st = c.Default or false
            local tr = Instance.new("Frame", row)
            tr.Size = UDim2.fromOffset(40,22); tr.Position = UDim2.new(1,-54,0.5,-11)
            tr.BackgroundColor3 = st and COL.acc or COL.off
            tr.BackgroundTransparency = 0.1; tr.BorderSizePixel = 0; tr.ZIndex = 15; cR(tr,11)
            local k = Instance.new("Frame", tr)
            k.Size = UDim2.fromOffset(16,16)
            k.Position = st and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,3,0.5,-8)
            k.BackgroundColor3 = Color3.fromRGB(255,255,255); k.BorderSizePixel = 0; k.ZIndex = 16; cR(k,8)
            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 17
            btn.MouseButton1Click:Connect(function()
                st = not st
                TS:Create(k,TweenInfo.new(0.2),{Position=st and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
                TS:Create(tr,TweenInfo.new(0.2),{BackgroundColor3=st and COL.acc or COL.off}):Play()
                if c.Callback then pcall(c.Callback, st) end
            end)
            self.Y = self.Y + 48
            return self
        end

        function t:Sl(id, c)
            local row = Instance.new("Frame", p)
            row.Size = UDim2.new(1,-8,0,56); row.Position = UDim2.fromOffset(4, self.Y)
            row.BackgroundColor3 = COL.card; row.BackgroundTransparency = TRC
            row.BorderSizePixel = 0; row.ZIndex = 14
            cR(row,8); cS(row,COL.brdS,1,0.5)
            local l2 = Instance.new("TextLabel", row)
            l2.Size = UDim2.new(1,-80,0,18); l2.Position = UDim2.fromOffset(14,9)
            l2.BackgroundTransparency = 1; l2.Text = c.Title or id
            l2.TextColor3 = COL.tx; l2.Font = Enum.Font.GothamMedium; l2.TextSize = 12
            l2.TextXAlignment = Enum.TextXAlignment.Left; l2.ZIndex = 15
            local vL = Instance.new("TextLabel", row)
            vL.Size = UDim2.fromOffset(56,18); vL.Position = UDim2.new(1,-70,0,9)
            vL.BackgroundTransparency = 1; vL.Text = tostring(c.Default or c.Min or 0)
            vL.TextColor3 = COL.acc; vL.Font = Enum.Font.GothamBold; vL.TextSize = 12
            vL.TextXAlignment = Enum.TextXAlignment.Right; vL.ZIndex = 15
            local tr = Instance.new("Frame", row)
            tr.Size = UDim2.new(1,-28,0,4); tr.Position = UDim2.new(0,14,1,-16)
            tr.BackgroundColor3 = COL.off; tr.BackgroundTransparency = 0.1
            tr.BorderSizePixel = 0; tr.ZIndex = 15; cR(tr,2)
            local mn, mx = c.Min or 0, c.Max or 100
            local pct = ((c.Default or mn)-mn)/(mx-mn)
            local f = Instance.new("Frame", tr)
            f.Size = UDim2.new(pct,0,1,0); f.BackgroundColor3 = COL.acc
            f.BorderSizePixel = 0; f.ZIndex = 16; cR(f,2)
            local k = Instance.new("Frame", tr)
            k.Size = UDim2.fromOffset(14,14); k.Position = UDim2.new(pct,-7,0.5,-7)
            k.BackgroundColor3 = Color3.fromRGB(255,255,255); k.BorderSizePixel = 0; k.ZIndex = 17; cR(k,7)
            local dg = false
            local function upd(x)
                local a = math.clamp((x-tr.AbsolutePosition.X)/tr.AbsoluteSize.X, 0, 1)
                local v = math.floor(mn+(mx-mn)*a+0.5)
                f.Size = UDim2.new(a,0,1,0); k.Position = UDim2.new(a,-7,0.5,-7)
                vL.Text = tostring(v)
                if c.Callback then pcall(c.Callback, v) end
            end
            local hb = Instance.new("TextButton", row)
            hb.Size = UDim2.new(1,-20,0,26); hb.Position = UDim2.new(0,10,1,-30)
            hb.BackgroundTransparency = 1; hb.Text = ""; hb.ZIndex = 18
            hb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true upd(i.Position.X) end end)
            UIS.InputChanged:Connect(function(i) if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end end)
            self.Y = self.Y + 62
            return self
        end

        function t:Drop(id, c)
            local row = Instance.new("Frame", p)
            row.Size = UDim2.new(1,-8,0,42); row.Position = UDim2.fromOffset(4, self.Y)
            row.BackgroundColor3 = COL.card; row.BackgroundTransparency = TRC
            row.BorderSizePixel = 0; row.ZIndex = 14
            cR(row,8); cS(row,COL.brdS,1,0.5)
            local l2 = Instance.new("TextLabel", row)
            l2.Size = UDim2.new(1,-140,1,0); l2.Position = UDim2.fromOffset(14,0)
            l2.BackgroundTransparency = 1; l2.Text = c.Title or id
            l2.TextColor3 = COL.tx; l2.Font = Enum.Font.GothamMedium; l2.TextSize = 12
            l2.TextXAlignment = Enum.TextXAlignment.Left; l2.ZIndex = 15
            local vs = c.Values or {}
            local cur = c.Default or vs[1] or "?"
            local vL = Instance.new("TextLabel", row)
            vL.Size = UDim2.new(0,110,1,0); vL.Position = UDim2.new(1,-122,0,0)
            vL.BackgroundTransparency = 1; vL.Text = cur
            vL.TextColor3 = COL.txD; vL.Font = Enum.Font.GothamMedium; vL.TextSize = 11
            vL.TextXAlignment = Enum.TextXAlignment.Right; vL.ZIndex = 15
            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 16
            local hd = Instance.new("Frame", p)
            hd.Size = UDim2.new(1,-8,0,0); hd.Position = UDim2.fromOffset(4, self.Y + 46)
            hd.BackgroundColor3 = COL.card; hd.BackgroundTransparency = 0.1
            hd.BorderSizePixel = 0; hd.ClipsDescendants = true; hd.Visible = false; hd.ZIndex = 20
            cR(hd,8); cS(hd,COL.brd,1,0.4)
            for i,v in ipairs(vs) do
                local opt = Instance.new("TextButton", hd)
                opt.Size = UDim2.new(1,-8,0,28); opt.Position = UDim2.fromOffset(4,(i-1)*30+4)
                opt.BackgroundColor3 = COL.card; opt.BackgroundTransparency = 1
                opt.BorderSizePixel = 0; opt.Text = ""; opt.AutoButtonColor = false; opt.ZIndex = 22; cR(opt,5)
                local oL = Instance.new("TextLabel", opt)
                oL.Size = UDim2.new(1,-16,1,0); oL.Position = UDim2.fromOffset(12,0)
                oL.BackgroundTransparency = 1; oL.Text = v
                oL.TextColor3 = COL.txD; oL.Font = Enum.Font.GothamMedium; oL.TextSize = 11
                oL.TextXAlignment = Enum.TextXAlignment.Left; oL.ZIndex = 23
                opt.MouseButton1Click:Connect(function()
                    cur = v; vL.Text = v
                    TS:Create(hd,TweenInfo.new(0.2),{Size=UDim2.new(1,-8,0,0)}):Play()
                    task.delay(0.2, function() hd.Visible = false end)
                    if c.Callback then pcall(c.Callback, v) end
                end)
            end
            local hH = math.min(#vs*30+8, 150)
            btn.MouseButton1Click:Connect(function()
                if hd.Visible then
                    TS:Create(hd,TweenInfo.new(0.2),{Size=UDim2.new(1,-8,0,0)}):Play()
                    task.delay(0.2, function() hd.Visible = false end)
                else
                    hd.Visible = true
                    TS:Create(hd,TweenInfo.new(0.2),{Size=UDim2.new(1,-8,0,hH)}):Play()
                end
            end)
            self.Y = self.Y + 48
            return self
        end
        self.T[n] = t
        self.TB[n] = b
        SideL.CanvasSize = UDim2.new(0,0,0, self.Cnt*38+8)
        if not self.Cur then self:Show(n) end
        return t
    end

    -- TABS
    local TSurv = W:AddTab({Title="Survi"})
    local TKil  = W:AddTab({Title="Killer"})
    local TEsp  = W:AddTab({Title="ESP"})
    local TMisc = W:AddTab({Title="Misc"})
    local TCfg  = W:AddTab({Title="Config"})

    TSurv:Sec("Silent Aim (ToF)")
    TSurv:Tog("tof_on", {Title="Enable ToF", Default=CFG.tof_on, Callback=function(v) CFG.tof_on=v end})
    TSurv:Sl("tof_fov", {Title="FOV (1-500)", Min=1, Max=500, Default=CFG.tof_fov, Callback=function(v) CFG.tof_fov=v end})
    TSurv:Sl("tof_predict", {Title="Predict x10", Min=10, Max=60, Default=math.floor(CFG.tof_predict*10), Callback=function(v) CFG.tof_predict=v/10 end})

    TSurv:Sec("Auto Gen")
    TSurv:Tog("gene_on", {Title="Enable Auto Gen", Default=CFG.gene_on, Callback=function(v) CFG.gene_on=v end})
    TSurv:Drop("gene_method", {Title="Method", Values={"SUCCESS","NEUTRAL","INSTANT"}, Default=CFG.gene_method, Callback=function(v) CFG.gene_method=v end})

    TSurv:Sec("Auto Parry")
    TSurv:Tog("parry_on", {Title="Enable Parry", Default=CFG.parry_on, Callback=function(v) CFG.parry_on=v end})
    TSurv:Sl("parry_radius", {Title="Radius", Min=1, Max=30, Default=CFG.parry_radius, Callback=function(v) CFG.parry_radius=v end})
    TSurv:Sl("parry_sensitive", {Title="Sensitive", Min=0, Max=500, Default=CFG.parry_sensitive, Callback=function(v) CFG.parry_sensitive=v end})
    TSurv:Tog("parry_aggro", {Title="Aggressive", Default=CFG.parry_aggro, Callback=function(v) CFG.parry_aggro=v end})
    TSurv:Tog("parry_circle", {Title="Show Circle", Default=CFG.parry_circle, Callback=function(v) CFG.parry_circle=v end})
    TSurv:Sec("Movement")
    TSurv:Tog("fv", {Title="Always Fast Vault", Default=CFG.fast_vault, Callback=function(v) CFG.fast_vault=v end})

    TKil:Sec("Silent Aim (Veil)")
    TKil:Tog("veil_on", {Title="Enable Veil", Default=CFG.veil_on, Callback=function(v) CFG.veil_on=v end})
    TKil:Sl("veil_fov", {Title="FOV Veil", Min=1, Max=600, Default=CFG.veil_fov, Callback=function(v) CFG.veil_fov=v end})
    TKil:Sl("veil_predict", {Title="Predict x10", Min=10, Max=60, Default=math.floor(CFG.veil_predict*10), Callback=function(v) CFG.veil_predict=v/10 end})

    TEsp:Sec("ESP Targets")
    TEsp:Tog("esp_k", {Title="Killer ESP", Default=CFG.esp_k, Callback=function(v) CFG.esp_k=v end})
    TEsp:Tog("esp_s", {Title="Survivor ESP", Default=CFG.esp_s, Callback=function(v) CFG.esp_s=v end})
    TEsp:Tog("esp_g", {Title="Generator ESP", Default=CFG.esp_g, Callback=function(v) CFG.esp_g=v end})
    TEsp:Tog("esp_out", {Title="Outline Only", Default=CFG.esp_out, Callback=function(v) CFG.esp_out=v end})
    TEsp:Sl("esp_range", {Title="Range", Min=100, Max=5000, Default=CFG.esp_range, Callback=function(v) CFG.esp_range=v end})

    TMisc:Sec("Vision")
    TMisc:Tog("fov_lock_on", {Title="FOV Lock", Default=CFG.fov_lock_on, Callback=function(v) CFG.fov_lock_on=v end})
    TMisc:Sl("fov_lock_value", {Title="FOV Value", Min=30, Max=140, Default=CFG.fov_lock_value, Callback=function(v) CFG.fov_lock_value=v end})
    TMisc:Tog("ambient_on", {Title="Ambient Cerah", Default=CFG.ambient_on, Callback=function(v) CFG.ambient_on=v end})
    TMisc:Tog("boost_fps", {Title="Boost FPS", Default=CFG.boost_fps, Callback=function(v) CFG.boost_fps=v end})
    TMisc:Sec("Alerts")
    TMisc:Tog("alert", {Title="Proximity Alert", Default=CFG.alert, Callback=function(v) CFG.alert=v end})
    TMisc:Tog("stun_indicator", {Title="Stun Indicator", Default=CFG.stun_indicator, Callback=function(v) CFG.stun_indicator=v end})
    TMisc:Sec("Debug")
    TMisc:Btn({Title="Print RC", Callback=function()
        print("[KZ] ToF:", RC.tof~=nil, "Veil:", RC.veil~=nil, "Parry:", RC.parry~=nil, "FV:", RC.fastvault~=nil)
    end})

    local CONFIG_FILE = "kalzz_v12.json"
    local hasFS = (type(writefile)=="function") and (type(readfile)=="function") and (type(isfile)=="function")
    TCfg:Sec("Config File")
    TCfg:Btn({Title="Save Config", Callback=function()
        if not hasFS then return end
        pcall(function() writefile(CONFIG_FILE, game:GetService("HttpService"):JSONEncode(CFG)) end)
    end})
    TCfg:Btn({Title="Load Config", Callback=function()
        if not hasFS then return end
        pcall(function()
            if isfile(CONFIG_FILE) then
                local d = game:GetService("HttpService"):JSONDecode(readfile(CONFIG_FILE))
                if type(d)=="table" then for k,v in pairs(d) do CFG[k]=v end end
            end
        end)
    end})
    TCfg:Btn({Title="Reset Config", Callback=function()
        if not hasFS then return end
        pcall(function() if isfile(CONFIG_FILE) then delfile(CONFIG_FILE) end end)
    end})
    TCfg:Sec("Info")
    TCfg:Btn({Title="Copy Discord", Callback=function() pcall(function() if setclipboard then setclipboard(URL) end end) end})
    TCfg:Btn({Title="Unload UI", Callback=function() pcall(function() GUI:Destroy() end) end})

    W:Show("Survi")

    MinBtn.MouseButton1Click:Connect(function() Main.Visible=false end)
    ClsBtn.MouseButton1Click:Connect(function() Main.Visible=false end)

    Sched:Add("UI_Watchdog", function()
        if not GUI or not GUI.Parent then
            pcall(function() GUI.Parent = getParentTarget() end)
            if not GUI.Parent then GUI.Parent = PG end
        end
        if GUI and not GUI.Enabled then GUI.Enabled = true end
        if GUI and Main and not Main.Parent then Main.Parent = GUI end
    end, 2)
end)

-- ============================================
-- KEYBINDS
-- ============================================
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.V then CFG.tof_on = not CFG.tof_on end
    if i.KeyCode == Enum.KeyCode.B then CFG.veil_on = not CFG.veil_on end
    if i.KeyCode == Enum.KeyCode.RightShift then
        if Main then Main.Visible = not Main.Visible end
    end
end)

print("==========================================")
print("[KALZZ HUB v12] FINAL")
print("Hook : 1 unified (Kick + ToF + Veil)")
print("ToF  : FOV", CFG.tof_fov, "| predict", CFG.tof_predict)
print("Veil : FOV", CFG.veil_fov, "| predict", CFG.veil_predict)
print("Keybinds: V=ToF | B=Veil | RShift=UI | P=Parry")
print("==========================================")
