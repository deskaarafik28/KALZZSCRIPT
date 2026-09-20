--[[
    ╔══════════════════════════════════════════════════════════════════════════╗
    ║   VD FULL HUB - FINAL WORKING EDITION                                    ║
    ║   Silent Veil + Silent Pistol + Auto Gen (FIXED LOGIC)                   ║
    ║   UI: 700+ lines | Logic: 900+ lines | Mobile Responsive                 ║
    ║   by kalzz | 2026                                                        ║
    ╚══════════════════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════════════════════
-- [01] SERVICES
-- ═══════════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local SG = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local VU = game:GetService("VirtualUser")
local TPS = game:GetService("TeleportService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local Cam = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

-- ═══════════════════════════════════════════════════════════════════════════
-- [02] THEME
-- ═══════════════════════════════════════════════════════════════════════════
local T = {
    BG0 = Color3.fromRGB(6, 6, 10),
    BG1 = Color3.fromRGB(12, 12, 18),
    BG2 = Color3.fromRGB(20, 20, 28),
    BG3 = Color3.fromRGB(28, 28, 38),
    BG4 = Color3.fromRGB(42, 42, 56),
    BG5 = Color3.fromRGB(58, 58, 76),
    T1 = Color3.fromRGB(255, 255, 255),
    T2 = Color3.fromRGB(220, 220, 230),
    T3 = Color3.fromRGB(165, 165, 180),
    T4 = Color3.fromRGB(110, 110, 128),
    Accent = Color3.fromRGB(120, 120, 255),
    Accent2 = Color3.fromRGB(160, 160, 255),
    Green = Color3.fromRGB(50, 230, 140),
    Red = Color3.fromRGB(255, 70, 90),
    RedD = Color3.fromRGB(160, 40, 55),
    Yellow = Color3.fromRGB(255, 200, 80),
    Orange = Color3.fromRGB(255, 150, 70),
    Purple = Color3.fromRGB(180, 120, 255),
    Cyan = Color3.fromRGB(50, 200, 255),
    Pink = Color3.fromRGB(255, 120, 200),
}

local F = {
    Bold = Enum.Font.GothamBold,
    Med = Enum.Font.GothamMedium,
    Norm = Enum.Font.Gotham,
    Black = Enum.Font.GothamBlack,
}

local IS_MOBILE = UIS.TouchEnabled and not UIS.MouseEnabled
local IS_TABLET = UIS.TouchEnabled and UIS.MouseEnabled
local SCALE = IS_MOBILE and 0.9 or (IS_TABLET and 0.85 or 1)
local PANEL_W = math.floor(680 * SCALE)
local PANEL_H = math.floor(470 * SCALE)
local SIDEBAR_W = math.floor(175 * SCALE)
local FAB_SIZE = IS_MOBILE and 56 or 52

-- ═══════════════════════════════════════════════════════════════════════════
-- [03] STATE
-- ═══════════════════════════════════════════════════════════════════════════
local S = {
    -- Silent Veil (Killer only)
    SilentVeil = false,
    VeilFOV = 500,
    VeilPredict = 30,
    SpearSpeed = 150,
    SpearGravity = 50,
    GravityComp = true,
    -- Silent Pistol
    SilentPistol = false,
    SilentFOV = 500,
    SilentPredict = 0.15,
    -- Auto Gen
    AutoGen = false,
    GenMode = "Perfect",
    GenRange = 15,
    -- Auto Parry
    AutoParry = false,
    ParryRange = 20,
    ParryDelay = 0.25,
    -- Auto Heal
    AutoHeal = false,
    HealThreshold = 60,
    -- Fast Vault
    FastVault = false,
    -- Killer
    KillerAutoAttack = false,
    AttackRate = 0.4,
    AutoCarry = false,
    AutoHook = false,
    -- Visual
    ESPKiller = false,
    ESPSurvivor = false,
    ESPTransparency = 0.15,
    TracerON = false,
    Fullbright = false,
    BrightnessValue = 4,
    -- Movement
    SpeedBoost = false,
    SpeedValue = 24,
    InfiniteJump = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 60,
    -- Misc
    AntiAFK = true,
    KillerAlert = false,
    AlertRange = 14,
    -- Internal
    _hookOn = false, _oldNC = nil,
    _lastGen = 0, _lastParry = 0, _lastHeal = 0, _lastVault = 0, _lastAtk = 0,
    _lastAlert = 0, _origWalk = 16,
    _flyBV = nil, _flyBG = nil,
    _hl = {}, _tr = {},
    _counts = { gen = 0, parry = 0, veil = 0, aim = 0, vault = 0, heal = 0, atk = 0 },
}

-- ═══════════════════════════════════════════════════════════════════════════
-- [04] UI UTILITY
-- ═══════════════════════════════════════════════════════════════════════════
local UI = {}

function UI.new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end
function UI.corner(obj, r) return UI.new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, obj) end
function UI.stroke(obj, c, t, tr) return UI.new("UIStroke", { Color = c or T.BG5, Thickness = t or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, obj) end
function UI.gradient(obj, colors, rot) return UI.new("UIGradient", { Color = ColorSequence.new(colors), Rotation = rot or 90 }, obj) end
function UI.padding(obj, t, b, l, r) return UI.new("UIPadding", { PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0), PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0) }, obj) end
function UI.list(obj, sp, dir) return UI.new("UIListLayout", { Padding = UDim.new(0, sp or 6), SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = dir or Enum.FillDirection.Vertical }, obj) end
function UI.tweenPlay(obj, props, dur, style, dir) return TS:Create(obj, TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play() end

-- ═══════════════════════════════════════════════════════════════════════════
-- [05] REMOTE CACHE
-- ═══════════════════════════════════════════════════════════════════════════
local RC = {}
local REMOTE_NAMES = {
    "RepairEvent", "RepairAnim", "RepairVFX",
    "SkillCheckEvent", "SkillCheckResultEvent", "SkillCheckFailEvent",
    "ProgressUpdateEvent", "BreakGenEvent",
    "Spearthrow", "Startmori", "updatewep",
    "M2", "m2HitVM", "FovEvent", "alexattack",
    "Escapetime", "parry", "VaultEvent", "fastvault", "VaultCommit",
    "HealEvent", "HealAnimRec",
    "AttackEvent", "BasicAttack", "Lunge", "Leap",
    "CarrySurvivorEvent", "HookEvent", "HookPhase", "HookCommit",
}

for _, obj in ipairs(RS:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        for _, name in ipairs(REMOTE_NAMES) do
            if obj.Name == name and not RC[name] then
                RC[name] = obj
            end
        end
    end
end

local function fire(name, ...)
    local args = {...}
    local r = RC[name]
    if not r then return false end
    return pcall(function()
        if r:IsA("RemoteEvent") then r:FireServer(unpack(args))
        elseif r:IsA("RemoteFunction") then r:InvokeServer(unpack(args)) end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [06] PLAYER HELPERS
-- ═══════════════════════════════════════════════════════════════════════════
local function getChar() return LP.Character end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function isAlive() local h = getHum() return h and h.Health > 0 end
local function getPos() local r = getRoot() return r and r.Position or Vector3.zero end
local function hpPct() local h = getHum() if not h or h.MaxHealth <= 0 then return 0 end return (h.Health / h.MaxHealth) * 100 end
local function teamOf(p) if not p or not p.Team then return "" end return p.Team.Name:lower() end
local function isKiller(p) return teamOf(p):find("killer") ~= nil end
local function isSurv(p) local n = teamOf(p) return n:find("surv") ~= nil or n:find("runner") ~= nil end
local function myRole()
    local t = LP.Team
    if not t then return "?" end
    local n = t.Name:lower()
    if n:find("killer") then return "Killer" end
    if n:find("surv") then return "Survivor" end
    return "?"
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [07] TARGET FINDER - FOV (Screen Space)
-- ═══════════════════════════════════════════════════════════════════════════
local function getTargetInFOV(filterFn, fov)
    local vp = Cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local radius = fov / 2
    local best, bestDist = nil, math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if not filterFn(p) then continue end
        local c = p.Character
        if not c then continue end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end
        
        local screenPos, onScreen = Cam:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist > radius then continue end
        if dist < bestDist then best = p bestDist = dist end
    end
    return best
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [08] NOTIFICATION
-- ═══════════════════════════════════════════════════════════════════════════
local notifyHolder = nil
local notifyStack = {}

local function notify(title, msg, color, dur)
    if not notifyHolder or not notifyHolder.Parent then
        notifyHolder = UI.new("ScreenGui", { Name = "VDNotify", ResetOnSpawn = false, DisplayOrder = 2000, IgnoreGuiInset = true }, PG)
    end
    color = color or T.Accent
    dur = dur or 3
    local idx = #notifyStack
    
    local card = UI.new("Frame", {
        Size = UDim2.new(0, 280, 0, 65),
        Position = UDim2.new(1, 20, 0, 20 + (idx * 75)),
        BackgroundColor3 = T.BG2,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
    }, notifyHolder)
    UI.corner(card, 10)
    UI.stroke(card, color, 1.5, 0.3)
    
    UI.new("Frame", { Size = UDim2.new(0, 4, 1, -20), Position = UDim2.new(0, 8, 0, 10), BackgroundColor3 = color, BorderSizePixel = 0 }, card)
    UI.new("TextLabel", { Size = UDim2.new(1, -30, 0, 20), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1, Text = title, TextColor3 = T.T1, Font = F.Bold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, card)
    UI.new("TextLabel", { Size = UDim2.new(1, -30, 0, 28), Position = UDim2.new(0, 20, 0, 30), BackgroundTransparency = 1, Text = msg, TextColor3 = T.T3, Font = F.Norm, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }, card)
    
    table.insert(notifyStack, card)
    UI.tweenPlay(card, { Position = UDim2.new(1, -300, 0, 20 + (idx * 75)) }, 0.4, Enum.EasingStyle.Back)
    
    task.delay(dur, function()
        if card and card.Parent then
            UI.tweenPlay(card, { Position = UDim2.new(1, 20, 0, 20), BackgroundTransparency = 1 }, 0.3)
            task.wait(0.35)
            for i, n in ipairs(notifyStack) do
                if n == card then table.remove(notifyStack, i) break end
            end
            card:Destroy()
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [09] ESP + TRACER + ALERT
-- ═══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.4)
        if S.ESPKiller or S.ESPSurvivor then
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LP then continue end
                local c = p.Character
                if not c then continue end
                local should = false
                local color = Color3.fromRGB(255, 255, 255)
                if S.ESPKiller and isKiller(p) then should = true color = T.Red end
                if S.ESPSurvivor and isSurv(p) then should = true color = T.Green end
                local ex = S._hl[p]
                if should then
                    if ex and ex.Parent then
                        ex.Adornee = c
                        ex.OutlineColor = color
                    else
                        local h = Instance.new("Highlight")
                        h.Parent = CoreGui
                        h.Adornee = c
                        h.FillColor = color
                        h.OutlineColor = color
                        h.FillTransparency = 1
                        h.OutlineTransparency = S.ESPTransparency
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        S._hl[p] = h
                    end
                else
                    if ex and ex.Parent then ex:Destroy() end
                    S._hl[p] = nil
                end
            end
        else
            for p, h in pairs(S._hl) do
                if h and h.Parent then h:Destroy() end
                S._hl[p] = nil
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not S.TracerON then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not S._tr[p] then
                local l = Drawing.new("Line")
                l.Thickness = 2
                l.Transparency = 1
                S._tr[p] = l
            end
            local pos, vis = Cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if vis then
                S._tr[p].Visible = true
                S._tr[p].From = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y)
                S._tr[p].To = Vector2.new(pos.X, pos.Y)
                S._tr[p].Color = p.Team == LP.Team and T.Green or T.Red
            else
                S._tr[p].Visible = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not S.KillerAlert then return end
    if tick() - S._lastAlert < 4 then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Team ~= LP.Team and p.Character and LP.Character then
            local e = p.Character:FindFirstChild("HumanoidRootPart")
            local m = LP.Character:FindFirstChild("HumanoidRootPart")
            if e and m and (e.Position - m.Position).Magnitude <= S.AlertRange then
                S._lastAlert = tick()
                notify("⚠️ Killer Nearby", p.Name .. " | " .. math.floor((e.Position - m.Position).Magnitude) .. "m", T.Red, 2)
                break
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [10] VISUAL LOCK INDICATOR (Silent Veil + Pistol)
-- ═══════════════════════════════════════════════════════════════════════════
local lockHL = nil
local function updateLockVisual(target)
    if target and target.Character then
        if not lockHL or not lockHL.Parent then
            lockHL = Instance.new("Highlight")
            lockHL.Parent = CoreGui
            lockHL.FillColor = T.Red
            lockHL.OutlineColor = T.Red
            lockHL.FillTransparency = 1
            lockHL.OutlineTransparency = 0
            lockHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
        lockHL.Adornee = target.Character
    else
        if lockHL and lockHL.Parent then lockHL:Destroy() lockHL = nil end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [11] SILENT AIM VEIL (KILLER ONLY - FIXED)
-- ═══════════════════════════════════════════════════════════════════════════
local Veil = {
    Target = nil,
    LastFire = 0,
    FireCooldown = 0.4,
    TrackRate = 0.03,
}

task.spawn(function()
    while true do
        task.wait(Veil.TrackRate)
        
        if not S.SilentVeil then
            updateLockVisual(nil)
            Veil.Target = nil
            continue
        end
        if not isAlive() then continue end
        if myRole() ~= "Killer" then
            updateLockVisual(nil)
            continue
        end
        
        -- Deteksi survivor dalam FOV
        local target = getTargetInFOV(isSurv, S.VeilFOV)
        if not target or not target.Character then
            updateLockVisual(nil)
            Veil.Target = nil
            continue
        end
        Veil.Target = target
        
        -- Ambil coordinate
        local head = target.Character:FindFirstChild("Head")
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        local coord = head or hrp
        if not coord then continue end
        
        -- Predict coordinate (VeilPredict = multiplier ms)
        local ping = LP:GetNetworkPing() * 1000
        local predictTime = (ping / 1000) + (S.VeilPredict / 1000)
        local predicted = coord.Position + (coord.Velocity * predictTime)
        
        -- Gravity compensation
        if S.GravityComp then
            local myPos = Cam.CFrame.Position
            local distance = (predicted - myPos).Magnitude
            local flightTime = distance / math.max(S.SpearSpeed, 1)
            local drop = 0.5 * workspace.Gravity * (flightTime ^ 2) * (S.SpearGravity / 100)
            predicted = predicted - Vector3.new(0, drop, 0)
        end
        
        -- Fire (throttle)
        if tick() - Veil.LastFire > Veil.FireCooldown then
            fire("Spearthrow", predicted)
            fire("Spearthrow", predicted, true)
            fire("Startmori", predicted)
            Veil.LastFire = tick()
            S._counts.veil = S._counts.veil + 1
        end
        
        -- Steer tombak yang terbang
        local myPos = getPos()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if not obj:IsA("BasePart") then continue end
            local n = obj.Name:lower()
            if not (n:find("spear") or n:find("tombak") or n:find("projectile")) then continue end
            if (obj.Position - myPos).Magnitude < 3 then continue end
            
            if not obj:FindFirstChild("VD_BV") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "VD_BV"
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.P = 800
                bv.Velocity = Vector3.zero
                bv.Parent = obj
                local bg = Instance.new("BodyGyro")
                bg.Name = "VD_BG"
                bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                bg.P = 500
                bg.D = 100
                bg.Parent = obj
            end
            
            local dir = predicted - obj.Position
            if dir.Magnitude > 1 then
                if obj:FindFirstChild("VD_BV") then obj.VD_BV.Velocity = dir.Unit * S.SpearSpeed end
                if obj:FindFirstChild("VD_BG") then obj.VD_BG.CFrame = CFrame.lookAt(obj.Position, predicted) end
            end
        end
        
        updateLockVisual(target)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [12] SILENT AIM PISTOL (HOOK - FIXED)
-- ═══════════════════════════════════════════════════════════════════════════
local PISTOL_REMOTES = { "M2", "m2HitVM", "FovEvent", "alexattack" }
local function isPistolRemote(name)
    for _, r in ipairs(PISTOL_REMOTES) do
        if name == r then return true end
    end
    return false
end

local pistolCache = { target = nil, lastUpdate = 0 }
local PISTOL_CACHE_TIME = 0.1
local pistolLastFire = 0
local PISTOL_THROTTLE = 0.03

local function updatePistolCache()
    local now = tick()
    if now - pistolCache.lastUpdate < PISTOL_CACHE_TIME then return end
    pistolCache.lastUpdate = now
    pistolCache.target = getTargetInFOV(isKiller, S.SilentFOV)
end

local function installHook()
    if S._hookOn then return end
    local mt = getrawmetatable(game)
    if not mt then return end
    setreadonly(mt, false)
    S._oldNC = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        if method == "FireServer" and S.SilentPistol and isPistolRemote(self.Name) then
            local now = tick()
            if now - pistolLastFire < PISTOL_THROTTLE then
                return S._oldNC(self, ...)
            end
            pistolLastFire = now
            
            updatePistolCache()
            local target = pistolCache.target
            
            if target and target.Character then
                local hum = target.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local coord = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                    if coord then
                        local ping = LP:GetNetworkPing() * 1000
                        local predictTime = math.min((ping / 1000) + S.SilentPredict, 0.3)
                        local predicted = coord.Position + (coord.Velocity * predictTime)
                        
                        local args = {...}
                        for i, a in ipairs(args) do
                            local t = typeof(a)
                            if t == "Vector3" then args[i] = predicted
                            elseif t == "CFrame" then args[i] = CFrame.lookAt(a.Position, predicted) end
                        end
                        
                        S._counts.aim = S._counts.aim + 1
                        return S._oldNC(self, unpack(args))
                    end
                end
            end
        end
        return S._oldNC(self, ...)
    end)
    
    setreadonly(mt, true)
    S._hookOn = true
    print("[VD] Silent Aim Pistol hook ON")
end

local function removeHook()
    if not S._hookOn then return end
    local mt = getrawmetatable(game)
    if mt and S._oldNC then
        setreadonly(mt, false)
        mt.__namecall = S._oldNC
        setreadonly(mt, true)
    end
    S._hookOn = false
    print("[VD] Silent Aim Pistol hook OFF")
end

RunService.Heartbeat:Connect(function()
    if S.SilentPistol and not S._hookOn then installHook()
    elseif not S.SilentPistol and S._hookOn then removeHook() end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        if S.SilentPistol then updatePistolCache()
        else pistolCache.target = nil end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [13] AUTO GENERATOR (SKILL CHECK DETECTION - FIXED)
-- ═══════════════════════════════════════════════════════════════════════════
local Gen = {
    LastRepair = 0,
    SkillCheckPending = false,
    SkillCheckDelay = 0.12,
}

local SKILL_KEYWORDS = { "skill", "check", "gauge", "circle", "needle", "radial", "timing", "qte", "perfect" }

local function isSkillCheckGUI(obj)
    local n = obj.Name:lower()
    for _, kw in ipairs(SKILL_KEYWORDS) do
        if n:find(kw) then return true end
    end
    return false
end

if PG then
    PG.DescendantAdded:Connect(function(obj)
        if not S.AutoGen then return end
        if Gen.SkillCheckPending then return end
        if not isSkillCheckGUI(obj) then return end
        if not obj.Visible then return end
        
        Gen.SkillCheckPending = true
        task.delay(Gen.SkillCheckDelay, function()
            if not S.AutoGen then
                Gen.SkillCheckPending = false
                return
            end
            if S.GenMode == "Perfect" then
                fire("SkillCheckResultEvent", 1)
                fire("SkillCheckResultEvent", true)
                fire("SkillCheckEvent", 1)
            else
                fire("SkillCheckResultEvent", 0.5)
                fire("SkillCheckEvent", 0.5)
            end
            S._counts.gen = S._counts.gen + 1
            Gen.SkillCheckPending = false
        end)
    end)
end

task.spawn(function()
    local skillRemote = RC["SkillCheckEvent"]
    if skillRemote and skillRemote:IsA("RemoteEvent") then
        skillRemote.OnClientEvent:Connect(function()
            if not S.AutoGen then return end
            task.wait(0.05)
            fire("SkillCheckResultEvent", 1)
            fire("SkillCheckEvent", 1)
            S._counts.gen = S._counts.gen + 1
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        if not S.AutoGen or not isAlive() then continue end
        
        local pos = getPos()
        if pos == Vector3.zero then continue end
        
        local best, bd = nil, S.GenRange
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("generator") then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local d = (part.Position - pos).Magnitude
                    if d < bd then best = obj bd = d end
                end
            end
        end
        
        if best then
            if bd > 8 then
                local r = getRoot()
                local part = best.PrimaryPart or best:FindFirstChildWhichIsA("BasePart")
                if r and part then
                    r.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                end
            end
            if tick() - Gen.LastRepair > 0.3 then
                Gen.LastRepair = tick()
                fire("RepairEvent", best)
                fire("RepairAnim", best)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [14] AUTO PARRY
-- ═══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.1)
        if not S.AutoParry or not isAlive() then continue end
        if tick() - S._lastParry < S.ParryDelay then continue end
        local enemy = getTargetInFOV(isKiller, S.ParryRange * 3)
        if not enemy or not enemy.Character then continue end
        local h = enemy.Character:FindFirstChild("HumanoidRootPart")
        if h and (h.Position - getPos()).Magnitude <= S.ParryRange then
            S._lastParry = tick()
            fire("parry")
            S._counts.parry = S._counts.parry + 1
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [15] AUTO HEAL
-- ═══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.5)
        if S.AutoHeal and isAlive() and hpPct() < S.HealThreshold and tick() - S._lastHeal > 1 then
            S._lastHeal = tick()
            fire("HealEvent")
            task.wait(0.05)
            fire("HealAnimRec")
            S._counts.heal = S._counts.heal + 1
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [16] FAST VAULT
-- ═══════════════════════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not S.FastVault then return end
    if input.KeyCode ~= Enum.KeyCode.Space then return end
    if tick() - S._lastVault < 0.3 then return end
    local c = getChar() if not c then return end
    local hum = getHum() if not hum or not hum.RootPart then return end
    local ray = Ray.new(hum.RootPart.Position, hum.RootPart.CFrame.LookVector * 8)
    local hit = workspace:FindPartOnRay(ray, c)
    if hit then
        local n = hit.Name:lower()
        if n:find("window") or n:find("pallet") or n:find("vault") or n:find("ledge") then
            S._lastVault = tick()
            S._counts.vault = S._counts.vault + 1
            fire("VaultEvent", hit)
            task.wait(0.03)
            fire("fastvault", hit)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [17] KILLER AUTO ATTACK
-- ═══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.1)
        if not isAlive() or myRole() ~= "Killer" then continue end
        if S.KillerAutoAttack and tick() - S._lastAtk >= S.AttackRate then
            S._lastAtk = tick()
            fire("AttackEvent")
            S._counts.atk = S._counts.atk + 1
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if not isAlive() or myRole() ~= "Killer" then continue end
        if S.AutoCarry then fire("CarrySurvivorEvent") end
        if S.AutoHook then
            fire("HookEvent")
            fire("HookPhase")
            fire("HookCommit")
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [18] MOVEMENT
-- ═══════════════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local h = getHum()
    if h then
        if S.SpeedBoost then h.WalkSpeed = S.SpeedValue
        else h.WalkSpeed = S._origWalk end
    end
    if S.Fly and S._flyBV and S._flyBG then
        local mv = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0, 1, 0) end
        if mv.Magnitude > 0 then mv = mv.Unit * S.FlySpeed end
        S._flyBV.Velocity = mv
        S._flyBG.CFrame = Cam.CFrame
    end
end)

RunService.Stepped:Connect(function()
    if not S.NoClip then return end
    local c = getChar() if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
    end
end)

UIS.JumpRequest:Connect(function()
    if S.InfiniteJump then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if S.Fly then
            local r = getRoot()
            if r and not S._flyBV then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Parent = r
                S._flyBV = bv
                local bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.P = 1000
                bg.D = 50
                bg.Parent = r
                S._flyBG = bg
            end
        else
            if S._flyBV then S._flyBV:Destroy() S._flyBV = nil end
            if S._flyBG then S._flyBG:Destroy() S._flyBG = nil end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [19] VISUAL + ANTI-AFK
-- ═══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            if S.Fullbright then
                Lighting.Brightness = S.BrightnessValue
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
            else
                Lighting.Brightness = 2
                Lighting.GlobalShadows = true
            end
        end)
    end
end)

if LP.Idled then
    LP.Idled:Connect(function()
        if S.AntiAFK then
            pcall(function()
                VU:CaptureController()
                VU:ClickButton2(Vector2.new())
            end)
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(15)
        if S.AntiAFK then
            local h = getHum()
            if h then pcall(function() h.Jump = true end) end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [20] UI BUILDER
-- ═══════════════════════════════════════════════════════════════════════════
local function makeCard(parent, title, accent, defaultOpen)
    accent = accent or T.Accent
    if defaultOpen == nil then defaultOpen = true end
    
    local holder = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = T.BG2,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, parent)
    UI.corner(holder, 10)
    UI.stroke(holder, T.BG4, 1, 0.4)
    
    local hdr = UI.new("TextButton", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
    }, holder)
    
    UI.new("Frame", { Size = UDim2.new(0, 4, 0, 20), Position = UDim2.new(0, 14, 0, 12), BackgroundColor3 = accent, BorderSizePixel = 0 }, hdr)
    UI.new("TextLabel", { Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 26, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = T.T1, Font = F.Bold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, hdr)
    
    local arrow = UI.new("TextLabel", { Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -34, 0, 0), BackgroundTransparency = 1, Text = defaultOpen and "▾" or "▸", TextColor3 = T.T3, Font = F.Bold, TextSize = 14 }, hdr)
    
    local content = UI.new("Frame", { Size = UDim2.new(1, -24, 0, 0), Position = UDim2.new(0, 12, 0, 50), BackgroundTransparency = 1 }, holder)
    UI.list(content, 6)
    
    local opened = defaultOpen
    
    hdr.MouseButton1Click:Connect(function()
        opened = not opened
        if opened then
            arrow.Text = "▾"
            UI.tweenPlay(holder, { Size = UDim2.new(1, 0, 0, 44) }, 0.1)
            task.wait(0.05)
            local layout = content:FindFirstChildOfClass("UIListLayout")
            local h = layout and layout.AbsoluteContentSize.Y or 0
            UI.tweenPlay(holder, { Size = UDim2.new(1, 0, 0, 50 + h + 8) }, 0.28, Enum.EasingStyle.Back)
        else
            arrow.Text = "▸"
            UI.tweenPlay(holder, { Size = UDim2.new(1, 0, 0, 44) }, 0.2)
        end
    end)
    
    task.spawn(function()
        task.wait(0.15)
        if opened then
            local layout = content:FindFirstChildOfClass("UIListLayout")
            if layout then
                local h = layout.AbsoluteContentSize.Y
                holder.Size = UDim2.new(1, 0, 0, 50 + h + 8)
                content.Size = UDim2.new(1, -24, 0, h)
            end
        end
    end)
    
    task.spawn(function()
        while holder.Parent do
            task.wait(0.4)
            if opened then
                local layout = content:FindFirstChildOfClass("UIListLayout")
                if layout then
                    local h = layout.AbsoluteContentSize.Y
                    holder.Size = UDim2.new(1, 0, 0, 50 + h + 8)
                    content.Size = UDim2.new(1, -24, 0, h)
                end
            end
        end
    end)
    
    return holder, content
end

local function makeToggle(parent, label, key, cb)
    local h = UI.new("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = T.BG3, BackgroundTransparency = 0.3, BorderSizePixel = 0 }, parent)
    UI.corner(h, 8)
    UI.new("TextLabel", { Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 14, 0, 0), BackgroundTransparency = 1, Text = label, TextColor3 = T.T2, Font = F.Med, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, h)
    
    local track = UI.new("Frame", { Size = UDim2.new(0, 44, 0, 24), Position = UDim2.new(1, -56, 0.5, -12), BackgroundColor3 = S[key] and T.Green or T.BG5, BackgroundTransparency = S[key] and 0 or 0.2, BorderSizePixel = 0 }, h)
    UI.corner(track, 12)
    local knob = UI.new("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = S[key] and UDim2.new(1, -20, 0, 3) or UDim2.new(0, 3, 0, 3), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 }, track)
    UI.corner(knob, 9)
    
    local click = UI.new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 10 }, h)
    click.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        local on = S[key]
        UI.tweenPlay(track, { BackgroundColor3 = on and T.Green or T.BG5, BackgroundTransparency = on and 0 or 0.2 }, 0.2)
        UI.tweenPlay(knob, { Position = on and UDim2.new(1, -20, 0, 3) or UDim2.new(0, 3, 0, 3) }, 0.25, Enum.EasingStyle.Back)
        if cb then pcall(cb, on) end
    end)
end

local function makeSlider(parent, label, key, min, max, default, suffix, cb)
    suffix = suffix or ""
    local h = UI.new("Frame", { Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = T.BG3, BackgroundTransparency = 0.3, BorderSizePixel = 0 }, parent)
    UI.corner(h, 8)
    UI.new("TextLabel", { Size = UDim2.new(0.5, 0, 0, 16), Position = UDim2.new(0, 14, 0, 8), BackgroundTransparency = 1, Text = label, TextColor3 = T.T3, Font = F.Med, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }, h)
    
    local valLbl = UI.new("TextLabel", { Size = UDim2.new(0.5, -14, 0, 16), Position = UDim2.new(0.5, 0, 0, 8), BackgroundTransparency = 1, Text = tostring(default) .. suffix, TextColor3 = T.Accent2, Font = F.Bold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right }, h)
    
    local track = UI.new("TextButton", { Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 0, 38), BackgroundColor3 = T.BG5, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, h)
    UI.corner(track, 3)
    
    local pct = (default - min) / (max - min)
    local fill = UI.new("Frame", { Size = UDim2.new(pct, 0, 1, 0), BackgroundColor3 = T.Accent, BorderSizePixel = 0 }, track)
    UI.corner(fill, 3)
    local knob = UI.new("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(pct, -7, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 }, track)
    UI.corner(knob, 7)
    UI.stroke(knob, T.Accent, 2)
    
    local dragging = false
    local function update(input)
        local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * p + 0.5)
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, -7, 0.5, -7)
        valLbl.Text = tostring(v) .. suffix
        S[key] = v
        if cb then pcall(cb, v) end
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function makeDropdown(parent, label, options, key, cb)
    local h = UI.new("Frame", { Size = UDim2.new(1, 0, 0, 68), BackgroundColor3 = T.BG3, BackgroundTransparency = 0.3, BorderSizePixel = 0, ClipsDescendants = false }, parent)
    UI.corner(h, 8)
    UI.new("TextLabel", { Size = UDim2.new(1, -28, 0, 14), Position = UDim2.new(0, 14, 0, 8), BackgroundTransparency = 1, Text = label, TextColor3 = T.T3, Font = F.Med, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }, h)
    
    local selector = UI.new("TextButton", { Size = UDim2.new(1, -28, 0, 28), Position = UDim2.new(0, 14, 0, 30), BackgroundColor3 = T.BG4, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, h)
    UI.corner(selector, 6)
    
    local selLbl = UI.new("TextLabel", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = S[key] or options[1], TextColor3 = T.T1, Font = F.Med, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, selector)
    UI.new("TextLabel", { Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -22, 0, 0), BackgroundTransparency = 1, Text = "▾", TextColor3 = T.T3, Font = F.Bold, TextSize = 12 }, selector)
    
    local list = nil
    selector.MouseButton1Click:Connect(function()
        if list then list:Destroy() list = nil return end
        list = UI.new("Frame", { Size = UDim2.new(1, 0, 0, #options * 28 + 8), Position = UDim2.new(0, 0, 1, 4), BackgroundColor3 = T.BG2, BackgroundTransparency = 0.05, BorderSizePixel = 0, ZIndex = 300 }, h)
        UI.corner(list, 6)
        UI.stroke(list, T.BG4, 1, 0.3)
        UI.padding(list, 4, 4, 4, 4)
        UI.list(list, 2)
        
        for _, opt in ipairs(options) do
            local optBtn = UI.new("TextButton", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = T.BG3, BackgroundTransparency = 0.4, BorderSizePixel = 0, Text = opt, TextColor3 = T.T2, Font = F.Med, TextSize = 11, AutoButtonColor = false, ZIndex = 301 }, list)
            UI.corner(optBtn, 4)
            optBtn.MouseButton1Click:Connect(function()
                S[key] = opt
                selLbl.Text = opt
                if list then list:Destroy() list = nil end
                if cb then pcall(cb, opt) end
            end)
        end
    end)
end

local function makeButton(parent, label, accent, cb)
    accent = accent or T.Accent
    local btn = UI.new("TextButton", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.BG3, BackgroundTransparency = 0.3, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, parent)
    UI.corner(btn, 8)
    UI.stroke(btn, accent, 1, 0.5)
    
    UI.new("Frame", { Size = UDim2.new(0, 3, 0, 16), Position = UDim2.new(0, 12, 0.5, -8), BackgroundColor3 = accent, BorderSizePixel = 0 }, btn)
    UI.new("TextLabel", { Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 24, 0, 0), BackgroundTransparency = 1, Text = label, TextColor3 = T.T1, Font = F.Bold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, btn)
    
    btn.MouseButton1Click:Connect(function()
        UI.tweenPlay(btn, { BackgroundColor3 = accent, BackgroundTransparency = 0.3 }, 0.1)
        task.wait(0.08)
        UI.tweenPlay(btn, { BackgroundColor3 = T.BG3, BackgroundTransparency = 0.3 }, 0.15)
        if cb then pcall(cb) end
    end)
end

local function buildUI()
    local Screen = UI.new("ScreenGui", {
        Name = "VDRH_UI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    }, PG)
    
    -- FAB
    local FAB = UI.new("Frame", {
        Size = UDim2.new(0, FAB_SIZE, 0, FAB_SIZE),
        Position = UDim2.new(1, -(FAB_SIZE + 18), 1, -(FAB_SIZE + 18)),
        BackgroundColor3 = T.BG2,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 200,
    }, Screen)
    UI.corner(FAB, math.floor(FAB_SIZE / 2))
    UI.stroke(FAB, T.Accent, 2)
    
    UI.new("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "V", TextColor3 = T.Accent2, Font = F.Black, TextSize = math.floor(FAB_SIZE * 0.42), ZIndex = 201 }, FAB)
    
    -- Panel
    local Panel = UI.new("Frame", {
        Size = UDim2.new(0, PANEL_W, 0, PANEL_H),
        Position = UDim2.new(0.5, -PANEL_W / 2, 0.5, -PANEL_H / 2),
        BackgroundColor3 = T.BG1,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Visible = false,
        Active = true,
        Draggable = true,
        ZIndex = 100,
    }, Screen)
    UI.corner(Panel, 14)
    UI.stroke(Panel, T.BG4, 1.5, 0.3)
    
    -- Header
    local Header = UI.new("Frame", { Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = T.BG2, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 101 }, Panel)
    UI.corner(Header, 14)
    
    local topBar = UI.new("Frame", { Size = UDim2.new(1, -20, 0, 2), Position = UDim2.new(0, 10, 0, 0), BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 102 }, Header)
    UI.corner(topBar, 1)
    UI.gradient(topBar, { ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(0.5, T.Purple), ColorSequenceKeypoint.new(1, T.Cyan) }, 0)
    
    UI.new("Frame", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 18, 0, 22), BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 103 }, Header)
    UI.corner(Header:FindFirstChildWhichIsA("Frame"), 6)
    
    UI.new("TextLabel", { Size = UDim2.new(1, -180, 0, 18), Position = UDim2.new(0, 38, 0, 14), BackgroundTransparency = 1, Text = "VD REAL HUB", TextColor3 = T.T1, Font = F.Black, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103 }, Header)
    UI.new("TextLabel", { Size = UDim2.new(1, -180, 0, 12), Position = UDim2.new(0, 38, 0, 32), BackgroundTransparency = 1, Text = "v10.0 | Fixed Edition", TextColor3 = T.T3, Font = F.Norm, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103 }, Header)
    
    local closeBtn = UI.new("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -38, 0, 13), BackgroundColor3 = T.RedD, BackgroundTransparency = 0.3, BorderSizePixel = 0, Text = "✕", TextColor3 = T.T1, Font = F.Bold, TextSize = 13, AutoButtonColor = false, ZIndex = 104 }, Header)
    UI.corner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function()
        UI.tweenPlay(Panel, { Size = UDim2.new(0, 0, 0, 0) }, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.25)
        Panel.Visible = false
        Panel.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
    end)
    
    -- Sidebar
    local Sidebar = UI.new("ScrollingFrame", {
        Size = UDim2.new(0, SIDEBAR_W - 20, 1, -80),
        Position = UDim2.new(0, 10, 0, 64),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.BG4,
        CanvasSize = UDim2.new(0, 0, 0, 300),
        ZIndex = 102,
    }, Panel)
    UI.list(Sidebar, 4)
    
    -- Content
    local Content = UI.new("ScrollingFrame", {
        Size = UDim2.new(1, -SIDEBAR_W - 20, 1, -70),
        Position = UDim2.new(0, SIDEBAR_W + 10, 0, 64),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 102,
    }, Panel)
    UI.list(Content, 8)
    
    local pageTitle = UI.new("TextLabel", {
        Size = UDim2.new(1, -SIDEBAR_W - 20, 0, 24),
        Position = UDim2.new(0, SIDEBAR_W + 10, 0, 30),
        BackgroundTransparency = 1,
        Text = "Survivor",
        TextColor3 = T.T1,
        Font = F.Black,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 103,
    }, Panel)
    
    -- Pages
    local pages = {}
    local sidebarBtns = {}
    
    local function createPage(name, visible)
        local p = UI.new("Frame", { Name = "Page_" .. name, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Visible = visible or false, ZIndex = 102 }, Content)
        UI.list(p, 8)
        pages[name] = p
        return p
    end
    
    local pageSurv = createPage("Survivor", true)
    local pageKiller = createPage("Killer", false)
    local pageVisual = createPage("Visual", false)
    local pageMisc = createPage("Misc", false)
    
    local function switchPage(name)
        for _, p in pairs(pages) do p.Visible = false end
        pages[name].Visible = true
        pageTitle.Text = name
        for _, b in ipairs(sidebarBtns) do
            if b.name == name then
                UI.tweenPlay(b.btn, { BackgroundTransparency = 0.4, BackgroundColor3 = T.BG3 }, 0.15)
                UI.tweenPlay(b.ind, { Size = UDim2.new(0, 3, 0, 22), BackgroundColor3 = T.Accent }, 0.15)
                UI.tweenPlay(b.lbl, { TextColor3 = T.T1 }, 0.15)
            else
                UI.tweenPlay(b.btn, { BackgroundTransparency = 1 }, 0.15)
                UI.tweenPlay(b.ind, { Size = UDim2.new(0, 3, 0, 0), BackgroundColor3 = T.T4 }, 0.15)
                UI.tweenPlay(b.lbl, { TextColor3 = T.T3 }, 0.15)
            end
        end
    end
    
    -- SURVIVOR
    local _, sGen = makeCard(pageSurv, "AUTO GENERATOR", T.Green, true)
    makeToggle(sGen, "Auto Generator", "AutoGen")
    makeDropdown(sGen, "Mode", { "Normal", "Perfect" }, "GenMode")
    makeSlider(sGen, "Gen Range", "GenRange", 5, 50, 15)
    
    local _, sParry = makeCard(pageSurv, "AUTO PARRY", T.Cyan, false)
    makeToggle(sParry, "Auto Parry", "AutoParry")
    makeSlider(sParry, "Parry Range", "ParryRange", 5, 50, 20)
    makeSlider(sParry, "Parry Delay", "ParryDelay", 0.1, 1, 0.25, "s")
    
    local _, sHeal = makeCard(pageSurv, "AUTO HEAL", T.Green, false)
    makeToggle(sHeal, "Auto Heal", "AutoHeal")
    makeSlider(sHeal, "HP Threshold", "HealThreshold", 20, 90, 60, "%")
    
    local _, sMove = makeCard(pageSurv, "MOVEMENT", T.Purple, false)
    makeToggle(sMove, "Fast Vault", "FastVault")
    
    -- KILLER
    local _, kVeil = makeCard(pageKiller, "SILENT AIM VEIL", T.Red, true)
    makeToggle(kVeil, "Silent Aim Veil", "SilentVeil")
    makeSlider(kVeil, "FOV", "VeilFOV", 50, 1000, 500, "px")
    makeSlider(kVeil, "Predict", "VeilPredict", 1, 100, 30)
    makeSlider(kVeil, "Spear Speed", "SpearSpeed", 50, 300, 150)
    makeSlider(kVeil, "Spear Gravity", "SpearGravity", 0, 200, 50)
    makeToggle(kVeil, "Gravity Comp", "GravityComp")
    
    local _, kPistol = makeCard(pageKiller, "SILENT AIM PISTOL", T.Orange, false)
    makeToggle(kPistol, "Silent Aim Pistol", "SilentPistol")
    makeSlider(kPistol, "FOV", "SilentFOV", 50, 1000, 500, "px")
    makeSlider(kPistol, "Predict", "SilentPredict", 0.01, 1, 0.15)
    
    local _, kAttack = makeCard(pageKiller, "KILLER ATTACK", T.Purple, false)
    makeToggle(kAttack, "Auto Attack", "KillerAutoAttack")
    makeSlider(kAttack, "Attack Rate", "AttackRate", 0.1, 2, 0.4, "s")
    makeToggle(kAttack, "Auto Carry", "AutoCarry")
    makeToggle(kAttack, "Auto Hook", "AutoHook")
    
    -- VISUAL
    local _, vESP = makeCard(pageVisual, "ESP (OUTLINE)", T.Cyan, true)
    makeToggle(vESP, "Killer ESP", "ESPKiller")
    makeToggle(vESP, "Survivor ESP", "ESPSurvivor")
    makeSlider(vESP, "Outline Transparency", "ESPTransparency", 0, 1, 0.15)
    
    local _, vTracer = makeCard(pageVisual, "TRACER", T.Pink, false)
    makeToggle(vTracer, "Tracer", "TracerON")
    
    local _, vGfx = makeCard(pageVisual, "GRAPHICS", T.Yellow, false)
    makeToggle(vGfx, "Fullbright", "Fullbright")
    makeSlider(vGfx, "Brightness", "BrightnessValue", 1, 10, 4)
    
    -- MISC
    local _, mSafety = makeCard(pageMisc, "SAFETY", T.Green, true)
    makeToggle(mSafety, "Anti-AFK", "AntiAFK")
    makeToggle(mSafety, "Killer Alert", "KillerAlert")
    makeSlider(mSafety, "Alert Range", "AlertRange", 5, 50, 14)
    
    local _, mMove = makeCard(pageMisc, "MOVEMENT", T.Cyan, false)
    makeToggle(mMove, "Speed Boost", "SpeedBoost")
    makeSlider(mMove, "Speed Value", "SpeedValue", 16, 100, 24)
    makeToggle(mMove, "Infinite Jump", "InfiniteJump")
    makeToggle(mMove, "No Clip", "NoClip")
    makeToggle(mMove, "Fly", "Fly")
    makeSlider(mMove, "Fly Speed", "FlySpeed", 20, 250, 60)
    
    local _, mActions = makeCard(pageMisc, "ACTIONS", T.Purple, false)
    makeButton(mActions, "Rescan Remotes", T.Cyan, function()
        RC = {}
        local n = 0
        for _, obj in ipairs(RS:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                for _, name in ipairs(REMOTE_NAMES) do
                    if obj.Name == name and not RC[name] then
                        RC[name] = obj
                        n = n + 1
                    end
                end
            end
        end
        notify("Remotes", n .. " cached", T.Green)
    end)
    makeButton(mActions, "Rejoin Server", T.Orange, function()
        pcall(function() TPS:Teleport(game.PlaceId, LP) end)
    end)
    
    -- Sidebar buttons
    local function addSidebarButton(name, icon)
        local btn = UI.new("TextButton", { Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = T.BG2, BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, Sidebar)
        UI.corner(btn, 6)
        
        local ind = UI.new("Frame", { Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = T.T4, BorderSizePixel = 0 }, btn)
        UI.corner(ind, 2)
        
        if icon then
            UI.new("TextLabel", { Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = icon, TextColor3 = T.T3, Font = F.Norm, TextSize = 13 }, btn)
        end
        
        local lbl = UI.new("TextLabel", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, (icon and 34 or 20), 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = T.T3, Font = F.Med, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, btn)
        
        btn.MouseButton1Click:Connect(function() switchPage(name) end)
        table.insert(sidebarBtns, { btn = btn, ind = ind, lbl = lbl, name = name })
    end
    
    addSidebarButton("Survivor", "🏃")
    addSidebarButton("Killer", "🔪")
    addSidebarButton("Visual", "👁")
    addSidebarButton("Misc", "⚙")
    
    task.spawn(function() task.wait(0.1) switchPage("Survivor") end)
    
    -- FAB toggle
    local fabClick = UI.new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 202 }, FAB)
    fabClick.MouseButton1Click:Connect(function()
        Panel.Visible = not Panel.Visible
        if Panel.Visible then
            Panel.Size = UDim2.new(0, 0, 0, 0)
            Panel.Position = UDim2.new(0.5, 0, 0.5, 0)
            UI.tweenPlay(Panel, { Size = UDim2.new(0, PANEL_W, 0, PANEL_H), Position = UDim2.new(0.5, -PANEL_W / 2, 0.5, -PANEL_H / 2) }, 0.3, Enum.EasingStyle.Back)
        end
    end)
    
    task.spawn(function()
        while true do
            task.wait(0.5)
            for _, p in pairs(pages) do
                if p.Visible then
                    local layout = p:FindFirstChildOfClass("UIListLayout")
                    if layout then Content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 40) end
                    break
                end
            end
            Sidebar.CanvasSize = UDim2.new(0, 0, 0, #sidebarBtns * 46 + 20)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [21] CHAT + KEYBIND + BOOT
-- ═══════════════════════════════════════════════════════════════════════════
LP.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == "!veil" then
        S.SilentVeil = not S.SilentVeil
        notify("Veil", tostring(S.SilentVeil), T.Red)
    elseif msg == "!pistol" then
        S.SilentPistol = not S.SilentPistol
        notify("Pistol", tostring(S.SilentPistol), T.Orange)
    elseif msg == "!gen" then
        S.AutoGen = not S.AutoGen
        notify("Gen", tostring(S.AutoGen), T.Green)
    elseif msg == "!panic" then
        S.SilentVeil = false
        S.SilentPistol = false
        S.AutoGen = false
        S.AutoParry = false
        S.KillerAutoAttack = false
        S.SpeedBoost = false
        S.Fly = false
        S.NoClip = false
        updateLockVisual(nil)
        notify("PANIC", "All off", T.Red)
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F7 then
        S.SilentVeil = false
        S.SilentPistol = false
        S.AutoGen = false
        S.AutoParry = false
        S.KillerAutoAttack = false
        S.SpeedBoost = false
        S.Fly = false
        S.NoClip = false
        updateLockVisual(nil)
        notify("PANIC", "All stopped", T.Red)
    end
end)

buildUI()

notify("VD Real Hub", "v10.0 loaded", T.Accent, 4)
notify("Silent Veil + Pistol", "Fixed logic", T.Green, 3)

print("╔══════════════════════════════════════════════════════════╗")
print("║   VD REAL HUB v10.0 - FIXED EDITION                      ║")
print("║   Silent Veil: FOV + Predict + Gravity + Real-time Track ║")
print("║   Silent Pistol: Hook M2/m2HitVM/FovEvent                ║")
print("║   Auto Gen: Skill Check Detection + Timing               ║")
print("║   Chat: !veil !pistol !gen !panic                        ║")
print("║   Keybind: F7 = Panic                                    ║")
print("╚══════════════════════════════════════════════════════════╝")
