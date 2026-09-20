--[[
    ╔══════════════════════════════════════════════════════════════════════════╗
    ║   VD COMBO HUB v13.0 - PREMIUM EDITION                                   ║
    ║                                                                          ║
    ║   • ESP / Tracer / Alert  → Verbatim dari Denoting2 HUB (readable)       ║
    ║   • Silent Veil           → Custom (FOV + Predict + Gravity + Steer)     ║
    ║   • Silent Pistol         → Custom (Hook FireServer + Replace Coord)     ║
    ║   • Auto Generator        → Custom (White Zone + Needle Real-time)       ║
    ║                                                                          ║
    ║   UI/UX: Modern glass morphism + animations + mobile responsive          ║
    ║   by kalzz | 2026                                                        ║
    ╚══════════════════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════════════════════
-- [01] SERVICES
-- ═══════════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════════════════
-- [02] THEME PALETTE
-- ═══════════════════════════════════════════════════════════════════════════
local T = {
    BG0 = Color3.fromRGB(8, 8, 12),
    BG1 = Color3.fromRGB(14, 14, 20),
    BG2 = Color3.fromRGB(22, 22, 30),
    BG3 = Color3.fromRGB(32, 32, 42),
    BG4 = Color3.fromRGB(46, 46, 60),
    BG5 = Color3.fromRGB(62, 62, 80),
    BG6 = Color3.fromRGB(84, 84, 104),
    T1 = Color3.fromRGB(255, 255, 255),
    T2 = Color3.fromRGB(224, 224, 232),
    T3 = Color3.fromRGB(168, 168, 180),
    T4 = Color3.fromRGB(112, 112, 128),
    Accent = Color3.fromRGB(130, 130, 255),
    AccentGlow = Color3.fromRGB(170, 170, 255),
    AccentDark = Color3.fromRGB(80, 80, 180),
    Green = Color3.fromRGB(50, 230, 140),
    GreenDark = Color3.fromRGB(28, 130, 84),
    Red = Color3.fromRGB(255, 70, 90),
    RedDark = Color3.fromRGB(150, 40, 55),
    Yellow = Color3.fromRGB(255, 200, 80),
    Orange = Color3.fromRGB(255, 150, 70),
    Purple = Color3.fromRGB(180, 120, 255),
    Cyan = Color3.fromRGB(50, 200, 255),
    Pink = Color3.fromRGB(255, 120, 200),
    Lime = Color3.fromRGB(180, 255, 100),
}

local F = {
    Bold = Enum.Font.GothamBold,
    Med = Enum.Font.GothamMedium,
    Norm = Enum.Font.Gotham,
    Black = Enum.Font.GothamBlack,
    Mono = Enum.Font.Code,
}

-- ═══════════════════════════════════════════════════════════════════════════
-- [03] DEVICE DETECTION
-- ═══════════════════════════════════════════════════════════════════════════
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local IS_TABLET = UserInputService.TouchEnabled and UserInputService.MouseEnabled
local SCALE = IS_MOBILE and 0.9 or (IS_TABLET and 0.85 or 1)
local PANEL_W = math.floor(680 * SCALE)
local PANEL_H = math.floor(460 * SCALE)
local SIDEBAR_W = math.floor(170 * SCALE)
local FAB_SIZE = IS_MOBILE and 58 or 54
local BTN_H = IS_MOBILE and 44 or 40

-- ═══════════════════════════════════════════════════════════════════════════
-- [04] STATE
-- ═══════════════════════════════════════════════════════════════════════════
local S = {
    -- ESP
    ESP_ON = false,
    ESPKiller = true,
    ESPSurvivor = true,
    ESPOutlineTransparency = 0.1,

    -- Tracer
    TRACER_ON = false,
    TracerThickness = 2,

    -- Alert
    ALERT_ON = false,
    AlertRange = 14,
    AlertCooldown = 4,

    -- Fullbright
    FULLBRIGHT_ON = false,

    -- Speed
    SpeedBoost = false,
    SpeedValue = 19,
    DefaultSpeed = 16,

    -- Silent Veil
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
    GenDebug = false,

    -- Internal
    _lastAlert = 0,
    _lastGen = 0,
    _hookOn = false,
    _oldNC = nil,
    _counts = { gen = 0, veil = 0, aim = 0, alert = 0 },
    _sessionStart = tick(),
}

-- ═══════════════════════════════════════════════════════════════════════════
-- [05] REMOTE CACHE
-- ═══════════════════════════════════════════════════════════════════════════
local RC = {}
local REMOTE_LIST = {
    "RepairEvent", "RepairAnim",
    "SkillCheckEvent", "SkillCheckResultEvent", "SkillCheckFailEvent",
    "Spearthrow", "Startmori",
    "M2", "m2HitVM", "FovEvent", "alexattack",
    "VaultEvent", "fastvault", "VaultCommit",
    "HealEvent", "HealAnimRec",
    "parry", "AttackEvent",
}

local function cacheRemotes()
    local n = 0
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            for _, name in ipairs(REMOTE_LIST) do
                if obj.Name == name and not RC[name] then
                    RC[name] = obj
                    n = n + 1
                end
            end
        end
    end
    return n
end

cacheRemotes()

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
-- [06] HELPERS
-- ═══════════════════════════════════════════════════════════════════════════
local function getChar() return LocalPlayer.Character end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function isAlive() local h = getHum() return h and h.Health > 0 end
local function getPos() local r = getRoot() return r and r.Position or Vector3.zero end
local function teamOf(p) if not p or not p.Team then return "" end return p.Team.Name:lower() end
local function isKiller(p) return teamOf(p):find("killer") ~= nil end
local function isSurv(p) local n = teamOf(p) return n:find("surv") ~= nil or n:find("runner") ~= nil end
local function myRole()
    local t = LocalPlayer.Team
    if not t then return "?" end
    local n = t.Name:lower()
    if n:find("killer") then return "Killer" end
    if n:find("surv") then return "Survivor" end
    return "?"
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [07] ESP (VERBATIM FROM DENOTING2 HUB)
-- ═══════════════════════════════════════════════════════════════════════════
local highlights = {}

local function AddESP(plr)
    if plr == LocalPlayer then return end

    local function Setup(char)
        if highlights[plr] then highlights[plr]:Destroy() end
        local h = Instance.new("Highlight")
        h.Parent = game.CoreGui
        h.Adornee = char
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

        if plr.Team == LocalPlayer.Team then
            h.FillColor = Color3.fromRGB(0, 255, 180)
        else
            h.FillColor = Color3.fromRGB(255, 60, 60)
        end

        h.FillTransparency = 1
        h.OutlineColor = Color3.new(1, 1, 1)
        h.OutlineTransparency = S.ESPOutlineTransparency
        highlights[plr] = h
    end

    if plr.Character then Setup(plr.Character) end
    plr.CharacterAdded:Connect(Setup)
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if S.ESP_ON then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and not highlights[p] then
                    AddESP(p)
                end
            end
        else
            for p, h in pairs(highlights) do
                if h then h:Destroy() end
                highlights[p] = nil
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [08] TRACER (VERBATIM FROM DENOTING2 HUB)
-- ═══════════════════════════════════════════════════════════════════════════
local tracers = {}

RunService.RenderStepped:Connect(function()
    if not S.TRACER_ON then
        for p, t in pairs(tracers) do
            if t then t.Visible = false end
        end
        return
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if not tracers[plr] then
                local line = Drawing.new("Line")
                line.Thickness = S.TracerThickness
                line.Transparency = 1
                tracers[plr] = line
            end

            local pos, visible = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if visible then
                tracers[plr].Visible = true
                tracers[plr].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracers[plr].To = Vector2.new(pos.X, pos.Y)
                if plr.Team == LocalPlayer.Team then
                    tracers[plr].Color = Color3.fromRGB(0, 255, 180)
                else
                    tracers[plr].Color = Color3.fromRGB(255, 60, 60)
                end
            else
                tracers[plr].Visible = false
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [09] KILLER ALERT (VERBATIM FROM DENOTING2 HUB)
-- ═══════════════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not S.ALERT_ON then return end
    if tick() - S._lastAlert < S.AlertCooldown then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and LocalPlayer.Character then
            local enemy = plr.Character:FindFirstChild("HumanoidRootPart")
            local me = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if enemy and me then
                local dist = (enemy.Position - me.Position).Magnitude
                if dist <= S.AlertRange then
                    S._lastAlert = tick()
                    S._counts.alert = S._counts.alert + 1
                    pcall(function()
                        StarterGui:SetCore("SendNotification", {
                            Title = "⚠️ Killer Nearby",
                            Text = plr.Name .. " | " .. math.floor(dist) .. "m",
                            Duration = 2,
                        })
                    end)
                    break
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [10] FULLBRIGHT (VERBATIM FROM DENOTING2 HUB)
-- ═══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        if S.FULLBRIGHT_ON then
            Lighting.Brightness = 4
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(180, 180, 180)
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        else
            Lighting.Brightness = 2
            Lighting.GlobalShadows = true
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [11] SPEED BOOST
-- ═══════════════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local h = getHum()
    if h then
        if S.SpeedBoost then h.WalkSpeed = S.SpeedValue
        else h.WalkSpeed = S.DefaultSpeed end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [12] FOV TARGET FINDER
-- ═══════════════════════════════════════════════════════════════════════════
local function getTargetInFOV(filterFn, fov)
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local radius = fov / 2
    local best, bestDist = nil, math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not filterFn(p) then continue end
        local c = p.Character
        if not c then continue end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist > radius then continue end
        if dist < bestDist then best = p bestDist = dist end
    end
    return best
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [13] SILENT AIM VEIL (CUSTOM - FOV + PREDICT + GRAVITY + STEER)
-- ═══════════════════════════════════════════════════════════════════════════
local Veil = { LastFire = 0, FireCooldown = 0.4 }

task.spawn(function()
    while true do
        task.wait(0.03)

        if not S.SilentVeil then continue end
        if not isAlive() then continue end
        if myRole() ~= "Killer" then continue end

        local target = getTargetInFOV(isSurv, S.VeilFOV)
        if not target or not target.Character then continue end

        local coord = target.Character:FindFirstChild("Head")
            or target.Character:FindFirstChild("HumanoidRootPart")
        if not coord then continue end

        local ping = LocalPlayer:GetNetworkPing() * 1000
        local predictTime = (ping / 1000) + (S.VeilPredict / 1000)
        local predicted = coord.Position + (coord.Velocity * predictTime)

        if S.GravityComp then
            local myPos = Camera.CFrame.Position
            local distance = (predicted - myPos).Magnitude
            local flightTime = distance / math.max(S.SpearSpeed, 1)
            local drop = 0.5 * workspace.Gravity * (flightTime ^ 2) * (S.SpearGravity / 100)
            predicted = predicted - Vector3.new(0, drop, 0)
        end

        if tick() - Veil.LastFire > Veil.FireCooldown then
            fire("Spearthrow", predicted)
            fire("Spearthrow", predicted, true)
            fire("Startmori", predicted)
            Veil.LastFire = tick()
            S._counts.veil = S._counts.veil + 1
        end

        -- Steer tombak aktif
        local mp = getPos()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if not obj:IsA("BasePart") then continue end
            local n = obj.Name:lower()
            if not (n:find("spear") or n:find("tombak") or n:find("projectile")) then continue end
            if (obj.Position - mp).Magnitude < 3 then continue end

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
                if obj:FindFirstChild("VD_BV") then
                    obj.VD_BV.Velocity = dir.Unit * S.SpearSpeed
                end
                if obj:FindFirstChild("VD_BG") then
                    obj.VD_BG.CFrame = CFrame.lookAt(obj.Position, predicted)
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [14] SILENT AIM PISTOL (HOOK FIRESERVER + REPLACE COORD)
-- ═══════════════════════════════════════════════════════════════════════════
local PISTOL_REMOTES = { "M2", "m2HitVM", "FovEvent", "alexattack" }

local function isPistolRemote(name)
    for _, r in ipairs(PISTOL_REMOTES) do
        if name == r then return true end
    end
    return false
end

local pistolCache = { target = nil, lastUpdate = 0 }
local pistolLastFire = 0
local aimHitCount = 0

local function updatePistolCache()
    local now = tick()
    if now - pistolCache.lastUpdate < 0.08 then return end
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
            if now - pistolLastFire < 0.03 then
                return S._oldNC(self, ...)
            end
            pistolLastFire = now

            updatePistolCache()
            local target = pistolCache.target

            if target and target.Character then
                local hum = target.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local coord = target.Character:FindFirstChild("Head")
                        or target.Character:FindFirstChild("HumanoidRootPart")

                    if coord then
                        local ping = LocalPlayer:GetNetworkPing() * 1000
                        local predictTime = math.min((ping / 1000) + S.SilentPredict, 0.3)
                        local targetPos = coord.Position + (coord.Velocity * predictTime)
                        local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPos)

                        local args = {...}

                        for i = 1, #args do
                            local a = args[i]
                            local t = typeof(a)

                            if t == "Vector3" then
                                local distFromCam = (a - Camera.CFrame.Position).Magnitude
                                if distFromCam > 3 then args[i] = targetPos end
                            elseif t == "CFrame" then
                                args[i] = targetCF
                            elseif t == "table" then
                                for k, v in pairs(a) do
                                    local vt = typeof(v)
                                    if vt == "Vector3" then
                                        local d = (v - Camera.CFrame.Position).Magnitude
                                        if d > 3 then a[k] = targetPos end
                                    elseif vt == "CFrame" then
                                        a[k] = targetCF
                                    end
                                end
                            end
                        end

                        S._counts.aim = S._counts.aim + 1
                        aimHitCount = aimHitCount + 1

                        if aimHitCount % 5 == 0 then
                            print(string.format("[AIM] #%d → %s | (%.1f, %.1f, %.1f)",
                                aimHitCount, target.Name, targetPos.X, targetPos.Y, targetPos.Z))
                        end

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
-- [15] AUTO GENERATOR - WHITE ZONE + NEEDLE DETECTION
-- ═══════════════════════════════════════════════════════════════════════════
local Gen = {
    LastRepair = 0,
    LastFire = 0,
    Active = false,
    SkillGUI = nil,
    Needle = nil,
    WhiteZones = {},
}

local SKILL_KEYWORDS = {
    "skill", "check", "gauge", "circle", "needle", "radial",
    "timing", "qte", "perfect", "sweetspot", "zone", "cursor", "pointer",
}

local function isSkillCheck(obj)
    local n = obj.Name:lower()
    for _, kw in ipairs(SKILL_KEYWORDS) do
        if n:find(kw) then return true end
    end
    return false
end

local function isWhite(c)
    return c.R >= 0.85 and c.G >= 0.85 and c.B >= 0.85
end

local function findWhiteZones(gui)
    local zones = {}
    if not gui then return zones end
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("ImageLabel") then
            if isWhite(obj.BackgroundColor3) and obj.BackgroundTransparency < 0.6 then
                table.insert(zones, { obj = obj })
            end
            local stroke = obj:FindFirstChildOfClass("UIStroke")
            if stroke and isWhite(stroke.Color) and stroke.Transparency < 0.6 then
                table.insert(zones, { obj = obj })
            end
        end
    end
    return zones
end

local needleTracker = { lastRot = {} }

local function findNeedle(gui)
    if not gui then return nil end
    local best, bestMove = nil, 0

    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("ImageLabel") then
            local rotChange = 0
            if needleTracker.lastRot[obj] then
                rotChange = math.abs(obj.Rotation - needleTracker.lastRot[obj])
            end
            needleTracker.lastRot[obj] = obj.Rotation

            if rotChange > bestMove and rotChange > 0.5 then
                best = obj
                bestMove = rotChange
            end
        end
    end
    return best
end

local function needleInWhite(needle, zones)
    if not needle or #zones == 0 then return false end

    local nPos = needle.AbsolutePosition
    local nSize = needle.AbsoluteSize
    local nCenter = Vector2.new(nPos.X + nSize.X / 2, nPos.Y + nSize.Y / 2)

    for _, zone in ipairs(zones) do
        local z = zone.obj
        local zPos = z.AbsolutePosition
        local zSize = z.AbsoluteSize
        local zCenter = Vector2.new(zPos.X + zSize.X / 2, zPos.Y + zSize.Y / 2)
        local zRadius = math.max(zSize.X, zSize.Y) / 2

        local dist = (nCenter - zCenter).Magnitude
        if dist <= zRadius + 20 then return true end
    end
    return false
end

local function fireSkill(mode)
    local vals
    if mode == "Perfect" then
        vals = { 1, true, "Perfect", 1.0 }
    else
        vals = { 0.5, "Normal" }
    end
    for _, v in ipairs(vals) do
        fire("SkillCheckResultEvent", v)
        fire("SkillCheckEvent", v)
    end
    fire("SkillCheckResultEvent")
    fire("SkillCheckEvent")

    S._counts.gen = S._counts.gen + 1
    Gen.Active = false
    Gen.Needle = nil
    Gen.WhiteZones = {}
    Gen.LastFire = tick()
    print("[GEN] Fired:", mode)
end

if PlayerGui then
    PlayerGui.DescendantAdded:Connect(function(obj)
        if not S.AutoGen then return end
        if not isSkillCheck(obj) then return end
        if not obj.Visible then return end

        local root = obj
        for i = 1, 4 do
            if root.Parent and root.Parent ~= PlayerGui then
                root = root.Parent
            end
        end

        if Gen.Active then return end
        Gen.SkillGUI = root
        Gen.Active = true
        Gen.WhiteZones = findWhiteZones(root)

        if S.GenDebug then
            print("[GEN] Skill check:", root.Name, "| Zones:", #Gen.WhiteZones)
        end

        task.delay(1.5, function()
            if Gen.Active and S.AutoGen then
                fireSkill(S.GenMode)
            end
        end)
    end)
end

task.spawn(function()
    while true do
        task.wait(0.015)
        if not S.AutoGen then
            Gen.Active = false
            continue
        end
        if not Gen.Active then continue end
        if not Gen.SkillGUI or not Gen.SkillGUI.Parent then
            Gen.Active = false
            continue
        end

        if #Gen.WhiteZones == 0 then
            Gen.WhiteZones = findWhiteZones(Gen.SkillGUI)
        end

        Gen.Needle = findNeedle(Gen.SkillGUI)
        if not Gen.Needle then continue end

        if needleInWhite(Gen.Needle, Gen.WhiteZones) then
            if tick() - Gen.LastFire > 0.1 then
                fireSkill(S.GenMode)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        if not S.AutoGen or not isAlive() then continue end

        local pos = getPos()
        if pos == Vector3.zero then continue end

        local best, bd = nil, 15
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
            if tick() - Gen.LastRepair > 0.4 then
                Gen.LastRepair = tick()
                fire("RepairEvent", best)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [16] ANTI-AFK (3 METHODS)
-- ═══════════════════════════════════════════════════════════════════════════
if LocalPlayer.Idled then
    LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

task.spawn(function()
    while true do
        task.wait(15)
        local h = getHum()
        if h then pcall(function() h.Jump = true end) end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [17] UI UTILITY LIBRARY
-- ═══════════════════════════════════════════════════════════════════════════
local UI = {}

function UI.new(c, p, par)
    local o = Instance.new(c)
    for k, v in pairs(p or {}) do o[k] = v end
    if par then o.Parent = par end
    return o
end

function UI.corner(o, r) return UI.new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o) end
function UI.stroke(o, c, t, tr)
    return UI.new("UIStroke", {
        Color = c or T.BG5,
        Thickness = t or 1,
        Transparency = tr or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
end
function UI.gradient(o, cs, r)
    return UI.new("UIGradient", { Color = ColorSequence.new(cs), Rotation = r or 90 }, o)
end
function UI.padding(o, t, b, l, r)
    return UI.new("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
    }, o)
end
function UI.list(o, s, d)
    return UI.new("UIListLayout", {
        Padding = UDim.new(0, s or 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = d or Enum.FillDirection.Vertical,
    }, o)
end
function UI.tween(o, p, d, s)
    return TweenService:Create(o, TweenInfo.new(d or 0.2, s or Enum.EasingStyle.Quart), p):Play()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [18] UI COMPONENT - CARD (COLLAPSIBLE)
-- ═══════════════════════════════════════════════════════════════════════════
local function makeCard(parent, title, accent, defaultOpen)
    accent = accent or T.Accent
    if defaultOpen == nil then defaultOpen = true end

    local holder = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = T.BG2,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, parent)
    UI.corner(holder, 10)
    UI.stroke(holder, T.BG4, 1, 0.4)

    -- Accent bar left
    local accentBar = UI.new("Frame", {
        Size = UDim2.new(0, 3, 0, 24),
        Position = UDim2.new(0, 0, 0, 11),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
    }, holder)
    UI.corner(accentBar, 2)

    local hdr = UI.new("TextButton", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
    }, holder)

    UI.new("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = T.T1,
        Font = F.Bold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, hdr)

    local arrow = UI.new("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -32, 0, 0),
        BackgroundTransparency = 1,
        Text = defaultOpen and "▾" or "▸",
        TextColor3 = T.T3,
        Font = F.Bold,
        TextSize = 14,
    }, hdr)

    local content = UI.new("Frame", {
        Size = UDim2.new(1, -24, 0, 0),
        Position = UDim2.new(0, 12, 0, 52),
        BackgroundTransparency = 1,
    }, holder)
    UI.list(content, 6)

    local opened = defaultOpen

    hdr.MouseButton1Click:Connect(function()
        opened = not opened
        if opened then
            arrow.Text = "▾"
            UI.tween(holder, { Size = UDim2.new(1, 0, 0, 46) }, 0.1)
            task.wait(0.05)
            local layout = content:FindFirstChildOfClass("UIListLayout")
            local h = layout and layout.AbsoluteContentSize.Y or 0
            UI.tween(holder, { Size = UDim2.new(1, 0, 0, 52 + h + 8) }, 0.28, Enum.EasingStyle.Back)
        else
            arrow.Text = "▸"
            UI.tween(holder, { Size = UDim2.new(1, 0, 0, 46) }, 0.2)
        end
    end)

    task.spawn(function()
        task.wait(0.15)
        if opened then
            local layout = content:FindFirstChildOfClass("UIListLayout")
            if layout then
                local h = layout.AbsoluteContentSize.Y
                holder.Size = UDim2.new(1, 0, 0, 52 + h + 8)
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
                    holder.Size = UDim2.new(1, 0, 0, 52 + h + 8)
                    content.Size = UDim2.new(1, -24, 0, h)
                end
            end
        end
    end)

    return holder, content
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [19] UI COMPONENT - TOGGLE
-- ═══════════════════════════════════════════════════════════════════════════
local function makeToggle(parent, label, key, cb)
    local h = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = T.BG3,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
    }, parent)
    UI.corner(h, 8)

    UI.new("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = T.T2,
        Font = F.Med,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, h)

    local track = UI.new("Frame", {
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = S[key] and T.Green or T.BG5,
        BackgroundTransparency = S[key] and 0 or 0.2,
        BorderSizePixel = 0,
    }, h)
    UI.corner(track, 12)

    local knob = UI.new("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = S[key] and UDim2.new(1, -20, 0, 3) or UDim2.new(0, 3, 0, 3),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    }, track)
    UI.corner(knob, 9)

    local click = UI.new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 10,
    }, h)

    click.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        local on = S[key]
        UI.tween(track, {
            BackgroundColor3 = on and T.Green or T.BG5,
            BackgroundTransparency = on and 0 or 0.2,
        }, 0.2)
        UI.tween(knob, {
            Position = on and UDim2.new(1, -20, 0, 3) or UDim2.new(0, 3, 0, 3),
        }, 0.25, Enum.EasingStyle.Back)
        if cb then pcall(cb, on) end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [20] UI COMPONENT - SLIDER
-- ═══════════════════════════════════════════════════════════════════════════
local function makeSlider(parent, label, key, min, max, default, suffix)
    suffix = suffix or ""

    local h = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = T.BG3,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
    }, parent)
    UI.corner(h, 8)

    UI.new("TextLabel", {
        Size = UDim2.new(0.5, 0, 0, 16),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = T.T3,
        Font = F.Med,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, h)

    local valLbl = UI.new("TextLabel", {
        Size = UDim2.new(0.5, -14, 0, 16),
        Position = UDim2.new(0.5, 0, 0, 8),
        BackgroundTransparency = 1,
        Text = tostring(default) .. suffix,
        TextColor3 = T.AccentGlow,
        Font = F.Bold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, h)

    local track = UI.new("TextButton", {
        Size = UDim2.new(1, -28, 0, 6),
        Position = UDim2.new(0, 14, 0, 38),
        BackgroundColor3 = T.BG5,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, h)
    UI.corner(track, 3)

    local pct = (default - min) / (max - min)
    local fill = UI.new("Frame", {
        Size = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
    }, track)
    UI.corner(fill, 3)

    local knob = UI.new("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(pct, -7, 0.5, -7),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    }, track)
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
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [21] UI COMPONENT - DROPDOWN
-- ═══════════════════════════════════════════════════════════════════════════
local function makeDropdown(parent, label, options, key)
    local h = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 68),
        BackgroundColor3 = T.BG3,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ClipsDescendants = false,
    }, parent)
    UI.corner(h, 8)

    UI.new("TextLabel", {
        Size = UDim2.new(1, -28, 0, 14),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = T.T3,
        Font = F.Med,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, h)

    local selector = UI.new("TextButton", {
        Size = UDim2.new(1, -28, 0, 28),
        Position = UDim2.new(0, 14, 0, 30),
        BackgroundColor3 = T.BG4,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, h)
    UI.corner(selector, 6)

    local selLbl = UI.new("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = S[key] or options[1],
        TextColor3 = T.T1,
        Font = F.Med,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, selector)

    UI.new("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -22, 0, 0),
        BackgroundTransparency = 1,
        Text = "▾",
        TextColor3 = T.T3,
        Font = F.Bold,
        TextSize = 12,
    }, selector)

    local list = nil

    selector.MouseButton1Click:Connect(function()
        if list then list:Destroy() list = nil return end

        list = UI.new("Frame", {
            Size = UDim2.new(1, 0, 0, #options * 28 + 8),
            Position = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = T.BG2,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            ZIndex = 300,
        }, h)
        UI.corner(list, 6)
        UI.stroke(list, T.BG4, 1, 0.3)
        UI.padding(list, 4, 4, 4, 4)
        UI.list(list, 2)

        for _, opt in ipairs(options) do
            local ob = UI.new("TextButton", {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = T.BG3,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                Text = opt,
                TextColor3 = T.T2,
                Font = F.Med,
                TextSize = 11,
                AutoButtonColor = false,
                ZIndex = 301,
            }, list)
            UI.corner(ob, 4)

            ob.MouseButton1Click:Connect(function()
                S[key] = opt
                selLbl.Text = opt
                if list then list:Destroy() list = nil end
            end)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [22] UI COMPONENT - BUTTON
-- ═══════════════════════════════════════════════════════════════════════════
local function makeButton(parent, label, accent, cb)
    accent = accent or T.Accent

    local btn = UI.new("TextButton", {
        Size = UDim2.new(1, 0, 0, BTN_H),
        BackgroundColor3 = T.BG3,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, parent)
    UI.corner(btn, 8)
    UI.stroke(btn, accent, 1, 0.5)

    UI.new("Frame", {
        Size = UDim2.new(0, 3, 0, 16),
        Position = UDim2.new(0, 12, 0.5, -8),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
    }, btn)

    UI.new("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = T.T1,
        Font = F.Bold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, btn)

    btn.MouseButton1Click:Connect(function()
        UI.tween(btn, { BackgroundColor3 = accent, BackgroundTransparency = 0.3 }, 0.1)
        task.wait(0.08)
        UI.tween(btn, { BackgroundColor3 = T.BG3, BackgroundTransparency = 0.3 }, 0.15)
        if cb then pcall(cb) end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [23] UI COMPONENT - INFO ROW
-- ═══════════════════════════════════════════════════════════════════════════
local function makeInfoRow(parent, label, value, color)
    color = color or T.T2

    local row = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
    }, parent)

    UI.new("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = T.T4,
        Font = F.Med,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local v = UI.new("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = value,
        TextColor3 = color,
        Font = F.Bold,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)
    return v
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [24] MAIN UI BUILDER
-- ═══════════════════════════════════════════════════════════════════════════
local function buildUI()
    local Screen = UI.new("ScreenGui", {
        Name = "VDComboUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    }, PlayerGui)

    -- ═══════════════════════════════════════
    -- FAB (Floating Action Button)
    -- ═══════════════════════════════════════
    local FAB = UI.new("Frame", {
        Size = UDim2.new(0, FAB_SIZE, 0, FAB_SIZE),
        Position = UDim2.new(1, -(FAB_SIZE + 20), 1, -(FAB_SIZE + 20)),
        BackgroundColor3 = T.BG2,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 200,
    }, Screen)
    UI.corner(FAB, math.floor(FAB_SIZE / 2))
    UI.stroke(FAB, T.Accent, 2)

    -- Pulse ring
    local ring = UI.new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 198,
    }, FAB)
    UI.corner(ring, math.floor(FAB_SIZE / 2))
    local ringSt = UI.stroke(ring, T.Accent, 1.5, 0.5)

    task.spawn(function()
        while FAB.Parent do
            ring.Size = UDim2.new(1, 0, 1, 0)
            ring.Position = UDim2.new(0, 0, 0, 0)
            ringSt.Transparency = 0.5
            UI.tween(ring, {
                Size = UDim2.new(1, 24, 1, 24),
                Position = UDim2.new(0, -12, 0, -12),
            }, 2, Enum.EasingStyle.Linear)
            UI.tween(ringSt, { Transparency = 1 }, 2, Enum.EasingStyle.Linear)
            task.wait(2)
        end
    end)

    UI.new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "V",
        TextColor3 = T.AccentGlow,
        Font = F.Black,
        TextSize = math.floor(FAB_SIZE * 0.42),
        ZIndex = 201,
    }, FAB)

    -- ═══════════════════════════════════════
    -- MAIN PANEL
    -- ═══════════════════════════════════════
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

    -- Glow
    local glow = UI.new("Frame", {
        Size = UDim2.new(1, 6, 1, 6),
        Position = UDim2.new(0, -3, 0, -3),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        ZIndex = 99,
    }, Panel)

    -- ═══════════════════════════════════════
    -- HEADER
    -- ═══════════════════════════════════════
    local Header = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = T.BG2,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 101,
    }, Panel)
    UI.corner(Header, 14)

    -- Top gradient bar
    local topBar = UI.new("Frame", {
        Size = UDim2.new(1, -20, 0, 2),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 102,
    }, Header)
    UI.corner(topBar, 1)
    UI.gradient(topBar, {
        ColorSequenceKeypoint.new(0, T.Accent),
        ColorSequenceKeypoint.new(0.5, T.Purple),
        ColorSequenceKeypoint.new(1, T.Cyan),
    }, 0)

    -- Logo dot (animated)
    local logoDot = UI.new("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 18, 0, 23),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 103,
    }, Header)
    UI.corner(logoDot, 6)

    task.spawn(function()
        while logoDot.Parent do
            UI.tween(logoDot, { BackgroundColor3 = T.Purple }, 1)
            task.wait(1)
            UI.tween(logoDot, { BackgroundColor3 = T.Cyan }, 1)
            task.wait(1)
            UI.tween(logoDot, { BackgroundColor3 = T.Accent }, 1)
            task.wait(1)
        end
    end)

    -- Title
    UI.new("TextLabel", {
        Size = UDim2.new(1, -180, 0, 18),
        Position = UDim2.new(0, 40, 0, 14),
        BackgroundTransparency = 1,
        Text = "VD COMBO HUB",
        TextColor3 = T.T1,
        Font = F.Black,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 103,
    }, Header)

    UI.new("TextLabel", {
        Size = UDim2.new(1, -180, 0, 12),
        Position = UDim2.new(0, 40, 0, 32),
        BackgroundTransparency = 1,
        Text = "v13.0 | Premium Edition",
        TextColor3 = T.T3,
        Font = F.Norm,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 103,
    }, Header)

    -- Status indicator
    local statusDot = UI.new("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(1, -88, 0, 26),
        BackgroundColor3 = T.Green,
        BorderSizePixel = 0,
        ZIndex = 103,
    }, Header)
    UI.corner(statusDot, 3)

    -- Minimize button
    local minBtn = UI.new("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -74, 0, 13),
        BackgroundColor3 = T.BG3,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = "−",
        TextColor3 = T.T2,
        Font = F.Bold,
        TextSize = 16,
        AutoButtonColor = false,
        ZIndex = 104,
    }, Header)
    UI.corner(minBtn, 6)

    minBtn.MouseButton1Click:Connect(function()
        Panel.Visible = false
    end)

    -- Close button
    local closeBtn = UI.new("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -38, 0, 13),
        BackgroundColor3 = T.RedDark,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = "✕",
        TextColor3 = T.T1,
        Font = F.Bold,
        TextSize = 13,
        AutoButtonColor = false,
        ZIndex = 104,
    }, Header)
    UI.corner(closeBtn, 6)

    closeBtn.MouseButton1Click:Connect(function()
        UI.tween(Panel, { Size = UDim2.new(0, 0, 0, 0) }, 0.22, Enum.EasingStyle.Back)
        task.wait(0.25)
        Panel.Visible = false
        Panel.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
    end)

    -- ═══════════════════════════════════════
    -- SIDEBAR
    -- ═══════════════════════════════════════
    local Sidebar = UI.new("ScrollingFrame", {
        Size = UDim2.new(0, SIDEBAR_W - 20, 1, -80),
        Position = UDim2.new(0, 10, 0, 68),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.BG4,
        CanvasSize = UDim2.new(0, 0, 0, 300),
        ZIndex = 102,
    }, Panel)
    UI.list(Sidebar, 4)

    -- ═══════════════════════════════════════
    -- CONTENT
    -- ═══════════════════════════════════════
    local Content = UI.new("ScrollingFrame", {
        Size = UDim2.new(1, -SIDEBAR_W - 20, 1, -74),
        Position = UDim2.new(0, SIDEBAR_W + 10, 0, 68),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 102,
    }, Panel)
    UI.list(Content, 8)

    -- Page title
    local pageTitle = UI.new("TextLabel", {
        Size = UDim2.new(1, -SIDEBAR_W - 20, 0, 24),
        Position = UDim2.new(0, SIDEBAR_W + 10, 0, 32),
        BackgroundTransparency = 1,
        Text = "Survivor",
        TextColor3 = T.T1,
        Font = F.Black,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 103,
    }, Panel)

    -- ═══════════════════════════════════════
    -- PAGES
    -- ═══════════════════════════════════════
    local pages = {}
    local sidebarBtns = {}

    local function createPage(name, visible)
        local p = UI.new("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = visible or false,
            ZIndex = 102,
        }, Content)
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
                UI.tween(b.btn, { BackgroundTransparency = 0.4, BackgroundColor3 = T.BG3 }, 0.15)
                UI.tween(b.ind, { Size = UDim2.new(0, 3, 0, 22), BackgroundColor3 = T.Accent }, 0.15)
                UI.tween(b.lbl, { TextColor3 = T.T1 }, 0.15)
                if b.icon then UI.tween(b.icon, { TextColor3 = T.AccentGlow }, 0.15) end
            else
                UI.tween(b.btn, { BackgroundTransparency = 1 }, 0.15)
                UI.tween(b.ind, { Size = UDim2.new(0, 3, 0, 0), BackgroundColor3 = T.T4 }, 0.15)
                UI.tween(b.lbl, { TextColor3 = T.T3 }, 0.15)
                if b.icon then UI.tween(b.icon, { TextColor3 = T.T3 }, 0.15) end
            end
        end
    end

    -- ═══ SURVIVOR PAGE ═══
    local _, survGen = makeCard(pageSurv, "AUTO GENERATOR", T.Green, true)
    makeToggle(survGen, "Auto Generator", "AutoGen")
    makeDropdown(survGen, "Mode", { "Normal", "Perfect" }, "GenMode")
    makeToggle(survGen, "Debug Mode", "GenDebug")

    local _, survMisc = makeCard(pageSurv, "MISC", T.Cyan, false)
    makeToggle(survMisc, "Speed Boost", "SpeedBoost")
    makeSlider(survMisc, "Speed Value", "SpeedValue", 16, 100, 19)

    -- ═══ KILLER PAGE ═══
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

    -- ═══ VISUAL PAGE ═══
    local _, vESP = makeCard(pageVisual, "ESP (OUTLINE)", T.Cyan, true)
    makeToggle(vESP, "ESP Player", "ESP_ON")
    makeSlider(vESP, "Outline Transparency", "ESPOutlineTransparency", 0, 1, 0.1)

    local _, vTracer = makeCard(pageVisual, "TRACER", T.Purple, false)
    makeToggle(vTracer, "Tracer", "TRACER_ON")
    makeSlider(vTracer, "Thickness", "TracerThickness", 1, 5, 2)

    local _, vGfx = makeCard(pageVisual, "GRAPHICS", T.Yellow, false)
    makeToggle(vGfx, "Fullbright", "FULLBRIGHT_ON")

    -- ═══ MISC PAGE ═══
    local _, mAlert = makeCard(pageMisc, "ALERT", T.Red, true)
    makeToggle(mAlert, "Killer Alert", "ALERT_ON")
    makeSlider(mAlert, "Alert Range", "AlertRange", 5, 50, 14)

    local _, mLive = makeCard(pageMisc, "LIVE STATS", T.Green, false)
    local statGen = makeInfoRow(mLive, "Generator", "0", T.Green)
    local statVeil = makeInfoRow(mLive, "Veil Hits", "0", T.Red)
    local statAim = makeInfoRow(mLive, "Aim Hits", "0", T.Orange)
    local statAlert = makeInfoRow(mLive, "Alert Count", "0", T.Yellow)
    local statUptime = makeInfoRow(mLive, "Uptime", "00:00", T.Cyan)

    task.spawn(function()
        while true do
            task.wait(0.5)
            statGen.Text = tostring(S._counts.gen)
            statVeil.Text = tostring(S._counts.veil)
            statAim.Text = tostring(S._counts.aim)
            statAlert.Text = tostring(S._counts.alert)
            local uptime = tick() - S._sessionStart
            statUptime.Text = string.format("%02d:%02d", math.floor(uptime / 60), math.floor(uptime % 60))
        end
    end)

    local _, mActions = makeCard(pageMisc, "ACTIONS", T.Purple, false)
    makeButton(mActions, "Rescan Remotes", T.Cyan, function()
        RC = {}
        local n = cacheRemotes()
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = "Remotes", Text = n .. " cached", Duration = 2 })
        end)
    end)
    makeButton(mActions, "Rejoin Server", T.Orange, function()
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end)

    -- ═══════════════════════════════════════
    -- SIDEBAR BUTTONS
    -- ═══════════════════════════════════════
    local function addSidebarButton(name, icon)
        local btn = UI.new("TextButton", {
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = T.BG2,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        }, Sidebar)
        UI.corner(btn, 6)

        local ind = UI.new("Frame", {
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = T.T4,
            BorderSizePixel = 0,
        }, btn)
        UI.corner(ind, 2)

        local iconLbl
        if icon then
            iconLbl = UI.new("TextLabel", {
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = icon,
                TextColor3 = T.T3,
                Font = F.Norm,
                TextSize = 13,
            }, btn)
        end

        local lbl = UI.new("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, (icon and 34 or 20), 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = T.T3,
            Font = F.Med,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, btn)

        btn.MouseButton1Click:Connect(function() switchPage(name) end)
        table.insert(sidebarBtns, { btn = btn, ind = ind, lbl = lbl, icon = iconLbl, name = name })
    end

    addSidebarButton("Survivor", "🏃")
    addSidebarButton("Killer", "🔪")
    addSidebarButton("Visual", "👁")
    addSidebarButton("Misc", "⚙")

    task.spawn(function()
        task.wait(0.1)
        switchPage("Survivor")
    end)

    -- ═══════════════════════════════════════
    -- FAB TOGGLE
    -- ═══════════════════════════════════════
    local fabClick = UI.new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 202,
    }, FAB)

    fabClick.MouseButton1Click:Connect(function()
        Panel.Visible = not Panel.Visible
        if Panel.Visible then
            Panel.Size = UDim2.new(0, 0, 0, 0)
            Panel.Position = UDim2.new(0.5, 0, 0.5, 0)
            UI.tween(Panel, {
                Size = UDim2.new(0, PANEL_W, 0, PANEL_H),
                Position = UDim2.new(0.5, -PANEL_W / 2, 0.5, -PANEL_H / 2),
            }, 0.3, Enum.EasingStyle.Back)
        end
    end)

    -- Auto canvas size
    task.spawn(function()
        while true do
            task.wait(0.5)
            for _, p in pairs(pages) do
                if p.Visible then
                    local layout = p:FindFirstChildOfClass("UIListLayout")
                    if layout then
                        Content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 40)
                    end
                    break
                end
            end
            Sidebar.CanvasSize = UDim2.new(0, 0, 0, #sidebarBtns * 46 + 20)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [25] CHAT COMMANDS
-- ═══════════════════════════════════════════════════════════════════════════
LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == "!veil" then
        S.SilentVeil = not S.SilentVeil
        print("[VD] Silent Veil:", S.SilentVeil)
    elseif msg == "!pistol" then
        S.SilentPistol = not S.SilentPistol
        print("[VD] Silent Pistol:", S.SilentPistol)
    elseif msg == "!gen" then
        S.AutoGen = not S.AutoGen
        print("[VD] Auto Gen:", S.AutoGen)
    elseif msg == "!esp" then
        S.ESP_ON = not S.ESP_ON
    elseif msg == "!tracer" then
        S.TRACER_ON = not S.TRACER_ON
    elseif msg == "!alert" then
        S.ALERT_ON = not S.ALERT_ON
    elseif msg == "!panic" then
        S.SilentVeil = false
        S.SilentPistol = false
        S.AutoGen = false
        S.ESP_ON = false
        S.TRACER_ON = false
        S.SpeedBoost = false
        print("[VD] PANIC - All stopped")
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- [26] BOOT
-- ═══════════════════════════════════════════════════════════════════════════
buildUI()

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "VD Combo Hub",
        Text = "v13.0 Premium loaded",
        Duration = 4,
    })
end)

print("╔══════════════════════════════════════════════════════════════════════╗")
print("║   VD COMBO HUB v13.0 - PREMIUM EDITION                               ║")
print("║   ESP/Tracer/Alert: Verbatim from Denoting2 HUB (readable)           ║")
print("║   Silent Veil/Pistol/AutoGen: Custom logic                           ║")
print("║   Chat: !veil !pistol !gen !esp !tracer !alert !panic                ║")
print("╚══════════════════════════════════════════════════════════════════════╝")
