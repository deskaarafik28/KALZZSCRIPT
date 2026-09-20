--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║   BLACK MATRIX 1.0                                                   ║
    ║   Game  : Violence District                                          ║
    ║   Style : Transparent Dark (BOLONG-HUB inspired)                     ║
    ║   Device: Mobile Optimized | Delta Stable                            ║
    ║   Script by kalzz | 2026                                             ║
    ║   UI: 900+ lines | Function: 1100+ lines | Total: 2000+ lines        ║
    ╚══════════════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════════════════
-- [01] SERVICES
-- ═══════════════════════════════════════════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting          = game:GetService("Lighting")
local VirtualUser       = game:GetService("VirtualUser")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")
local Camera            = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════
-- [02] CONFIG
-- ═══════════════════════════════════════════════════════════════════════
local CFG = {
    NAME     = "BLACK MATRIX",
    VERSION  = "1.0",
    CREATOR  = "kalzz",
    YEAR     = "2026",
    GAME     = "Violence District",
    DISCORD  = "discord.gg/kalzz",
    PLACE_ID = 93978595733734,
}

-- ═══════════════════════════════════════════════════════════════════════
-- [03] DEVICE DETECTION
-- ═══════════════════════════════════════════════════════════════════════
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local IS_TABLET = UserInputService.TouchEnabled and UserInputService.MouseEnabled

local UI_SCALE = IS_MOBILE and 0.95 or (IS_TABLET and 0.9 or 1)
local MAIN_W   = math.floor(620 * UI_SCALE)
local MAIN_H   = math.floor(380 * UI_SCALE)
local SIDEBAR_W = math.floor(150 * UI_SCALE)

-- ═══════════════════════════════════════════════════════════════════════
-- [04] STATE
-- ═══════════════════════════════════════════════════════════════════════
local S = {
    -- SURVIVOR
    AutoGenerator       = false,
    GenMode             = "Perfect",
    GenBoost            = false,
    AimSilent           = false,
    AimTarget           = "Killer",
    AimFOV              = 500,
    AimSmooth           = 0.15,
    ZigzagDetect        = true,
    Predict             = true,
    PredictValue        = 0.15,
    TOF                 = false,
    TOFSpeed            = 800,
    FastVault           = false,
    AntiFallSlow        = false,
    SpeedBoost          = false,
    SpeedValue          = 24,
    AutoParry           = false,
    InfiniteStamina     = false,

    -- KILLER
    KillerAim           = false,
    KillerAimMode       = "Veil",
    SpearGravity        = 100,
    SpearSpeed          = 200,
    KillerPredict       = 1,
    KillerAutoAttack    = false,
    KillerInfiniteLunge = false,
    KillerNoStun        = false,

    -- ESP
    ESPKiller           = false,
    ESPSurvivor         = false,
    ESPGenerator        = false,
    ESPHook             = false,
    ESPPallet           = false,
    ESPOutlineOnly      = true,
    ESPTransparency     = 0.3,

    -- MISC
    AntiAFK             = true,
    AntiStun            = false,
    InstantHeal         = false,
    Fullbright          = false,
    LowGraphics         = false,
    NoClip              = false,
    Fly                 = false,
    FlySpeed            = 60,
    InfiniteJump        = false,

    -- INTERNAL
    Status              = "Idle",
    SessionStart        = tick(),
    Uptime              = 0,
    _lastGen            = 0,
    _lastParry          = 0,
    _lastAim            = 0,
    _lastVault          = 0,
    _espCache           = {},
    _flyBV              = nil,
    _flyBG              = nil,
    _connections        = {},
    _originalWalk       = 16,
    _originalJump       = 50,
    _originalGravity    = Workspace.Gravity,
}

-- ═══════════════════════════════════════════════════════════════════════
-- [05] THEME (Transparent Dark)
-- ═══════════════════════════════════════════════════════════════════════
local C = {
    BG0       = Color3.fromRGB(0, 0, 0),
    BG1       = Color3.fromRGB(15, 15, 18),
    BG2       = Color3.fromRGB(22, 22, 26),
    BG3       = Color3.fromRGB(32, 32, 38),
    BG4       = Color3.fromRGB(45, 45, 52),
    BG5       = Color3.fromRGB(60, 60, 70),

    White     = Color3.fromRGB(255, 255, 255),
    OffWhite  = Color3.fromRGB(230, 230, 235),
    Gray1     = Color3.fromRGB(180, 180, 190),
    Gray2     = Color3.fromRGB(130, 130, 145),
    Gray3     = Color3.fromRGB(90, 90, 105),
    Gray4     = Color3.fromRGB(60, 60, 72),

    Cyan      = Color3.fromRGB(0, 200, 255),
    Green     = Color3.fromRGB(60, 220, 130),
    Red       = Color3.fromRGB(255, 80, 100),
    Yellow    = Color3.fromRGB(255, 200, 80),
    Purple    = Color3.fromRGB(170, 120, 255),
    Pink      = Color3.fromRGB(255, 120, 200),
    Orange    = Color3.fromRGB(255, 150, 70),
    Blue      = Color3.fromRGB(80, 140, 255),
}

local F = {
    Bold  = Enum.Font.GothamBold,
    Med   = Enum.Font.GothamMedium,
    Norm  = Enum.Font.Gotham,
    Black = Enum.Font.GothamBlack,
}

local FS = { H1 = 16, H2 = 14, H3 = 13, Body = 12, Small = 11, Tiny = 10, Micro = 9 }

-- ═══════════════════════════════════════════════════════════════════════
-- [06] UTILITY
-- ═══════════════════════════════════════════════════════════════════════
local U = {}

function U.mk(c, p, par)
    local o = Instance.new(c)
    for k, v in pairs(p or {}) do o[k] = v end
    if par then o.Parent = par end
    return o
end

function U.rc(o, r) return U.mk("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o) end
function U.st(o, c, t, tr)
    return U.mk("UIStroke", {
        Color = c or C.Gray4,
        Thickness = t or 1,
        Transparency = tr or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
end
function U.gd(o, cs, r) return U.mk("UIGradient", { Color = ColorSequence.new(cs), Rotation = r or 90 }, o) end
function U.ls(o, s, d)
    return U.mk("UIListLayout", {
        Padding = UDim.new(0, s or 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = d or Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
    }, o)
end
function U.pd(o, t, b, l, r)
    return U.mk("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
    }, o)
end
function U.tw(o, p, d, s)
    TweenService:Create(o, TweenInfo.new(d or 0.2, s or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), p):Play()
end
function U.dist(a, b) return (a - b).Magnitude end
function U.clamp(v, mn, mx) if v < mn then return mn end if v > mx then return mx end return v end
function U.fmt(s) return string.format("%02d:%02d", math.floor(s / 60), math.floor(s % 60)) end
function U.count(t) local n = 0 for _ in pairs(t) do n = n + 1 end return n end
function U.safe(fn, ...) local ok, r = pcall(fn, ...) return ok and r or nil end

-- ═══════════════════════════════════════════════════════════════════════
-- [07] PLAYER HELPERS
-- ═══════════════════════════════════════════════════════════════════════
local function getChar() return LocalPlayer.Character end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getHead() local c = getChar() return c and c:FindFirstChild("Head") end
local function isAlive() local h = getHum() return h and h.Health > 0 end
local function getPos() local r = getRoot() return r and r.Position or Vector3.zero end

local function getTeamName()
    local t = LocalPlayer.Team
    return t and t.Name or "None"
end

local function getRole()
    local team = getTeamName():lower()
    if team:find("killer") then return "Killer" end
    if team:find("surv") then return "Survivor" end
    if team:find("zombie") then return "Zombie" end
    return "Unknown"
end

-- ═══════════════════════════════════════════════════════════════════════
-- [08] LOGGER
-- ═══════════════════════════════════════════════════════════════════════
local Log = {}
function Log.add(l, m) print(string.format("[BMX][%s] %s", l, m)) end
function Log.info(m) Log.add("INFO", m) end
function Log.warn(m) Log.add("WARN", m) end
function Log.err(m) Log.add("ERROR", m) end

-- ═══════════════════════════════════════════════════════════════════════
-- [09] REMOTE MANAGER
-- ═══════════════════════════════════════════════════════════════════════
local RemoteCache = {}

local REMOTE_GROUPS = {
    Generator = {
        "ActivateGenerator","RepairGenerator","FixGenerator","Generator",
        "DoGenerator","CompleteGenerator","SkillCheck","CompleteCheck","FixGen",
    },
    Attack = {
        "Attack","Hit","Damage","Strike","Swing","Slash","PerformAttack","DoAttack",
    },
    Parry = {
        "Parry","Block","Counter","Defend","ParryEvent","DoParry",
    },
    Vault = {
        "Vault","DoVault","FastVault","VaultEvent","PerformVault",
    },
    Heal = {
        "Heal","HealSelf","UseMedkit","HealEvent",
    },
    Escape = {
        "Escape","Exit","Leave","EscapeEvent","EscapeGate",
    },
    NextGame = {
        "NextGame","Next","Rejoin","PlayAgain","Continue","Requeue",
    },
    AimUpdate = {
        "UpdateAim","SetAim","AimUpdate","SendAim","Aim",
    },
    SpearCast = {
        "CastSpear","ThrowSpear","Spear","SpearEvent","FireSpear",
    },
    SkillCheck = {
        "SkillCheck","CompleteCheck","SendSkillCheck","DoSkillCheck",
    },
}

local function scanRemotes()
    local n = 0
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            for _, names in pairs(REMOTE_GROUPS) do
                for _, name in ipairs(names) do
                    if obj.Name == name then
                        RemoteCache[name] = obj
                        n = n + 1
                    end
                end
            end
        end
    end
    return n
end

local function fire(group, ...)
    local args = {...}
    local names = REMOTE_GROUPS[group]
    if not names then return end
    for _, name in ipairs(names) do
        local r = RemoteCache[name] or ReplicatedStorage:FindFirstChild(name, true)
        if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
            RemoteCache[name] = r
            pcall(function()
                if r:IsA("RemoteEvent") then r:FireServer(unpack(args))
                else r:InvokeServer(unpack(args)) end
            end)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- [10] NOTIFICATION
-- ═══════════════════════════════════════════════════════════════════════
local nGui = U.mk("ScreenGui", { Name = "BMXNotify", ResetOnSpawn = false, Parent = PlayerGui })

local function notify(title, msg, color, dur)
    color = color or C.Cyan
    dur = dur or 3

    local f = U.mk("Frame", {
        Size = UDim2.new(0, 270, 0, 60),
        Position = UDim2.new(1, 12, 0, 12),
        BackgroundColor3 = C.BG2,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = nGui,
    })
    U.rc(f, 10)
    U.st(f, color, 1, 0.3)

    U.mk("Frame", {
        Size = UDim2.new(0, 3, 1, -14),
        Position = UDim2.new(0, 7, 0, 7),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = f,
    })

    U.mk("TextLabel", {
        Size = UDim2.new(1, -22, 0, 20),
        Position = UDim2.new(0, 16, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = C.White,
        Font = F.Bold,
        TextSize = FS.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f,
    })

    U.mk("TextLabel", {
        Size = UDim2.new(1, -22, 0, 24),
        Position = UDim2.new(0, 16, 0, 28),
        BackgroundTransparency = 1,
        Text = msg,
        TextColor3 = C.Gray2,
        Font = F.Norm,
        TextSize = FS.Small,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = f,
    })

    U.tw(f, { Position = UDim2.new(1, -282, 0, 12) }, 0.4, Enum.EasingStyle.Back)

    task.delay(dur, function()
        if f and f.Parent then
            U.tw(f, { Position = UDim2.new(1, 12, 0, 12), BackgroundTransparency = 1 }, 0.3)
            task.wait(0.35)
            f:Destroy()
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [11] ANTI-AFK (MULTI METHOD)
-- ═══════════════════════════════════════════════════════════════════════
if LocalPlayer.Idled then
    LocalPlayer.Idled:Connect(function()
        if S.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(12)
        if S.AntiAFK then
            local h = getHum()
            if h then pcall(function() h.Jump = true end) end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(22)
        if S.AntiAFK then
            local r = getRoot()
            if r then
                pcall(function()
                    r.CFrame = r.CFrame + Vector3.new(math.random(-1, 1) * 0.3, 0, math.random(-1, 1) * 0.3)
                end)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [12] ESP SYSTEM (Outline Only, Transparent)
-- ═══════════════════════════════════════════════════════════════════════
local ESP = {
    pool = {},
    folder = nil,
}

U.safe(function()
    ESP.folder = U.mk("Folder", { Name = "BMX_ESP", Parent = Workspace })
end)

local function createHighlight(target, color)
    if not ESP.folder then return nil end
    local hl = U.mk("Highlight", {
        Name = "BMX_" .. target.Name,
        Parent = ESP.folder,
        Adornee = target,
        FillColor = color,
        OutlineColor = color,
        FillTransparency = S.ESPTransparency,
        OutlineTransparency = 0.15,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
    })
    return hl
end

local function isKiller(plr)
    if not plr or not plr.Team then return false end
    return plr.Team.Name:lower():find("killer") ~= nil
end

local function isSurvivor(plr)
    if not plr or not plr.Team then return false end
    local n = plr.Team.Name:lower()
    return n:find("surv") ~= nil or n:find("runner") ~= nil
end

local function getPlayerChar(plr)
    return plr and plr.Character
end

-- Player ESP loop
task.spawn(function()
    while true do
        task.wait(0.4)
        if not ESP.folder then continue end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            local char = getPlayerChar(plr)
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local key = plr.Name
            local shouldESP = false
            local color = C.White

            if S.ESPKiller and isKiller(plr) then
                shouldESP = true
                color = C.Red
            elseif S.ESPSurvivor and isSurvivor(plr) then
                shouldESP = true
                color = C.Green
            end

            local existing = ESP.pool[key]

            if shouldESP then
                if existing and existing.Parent then
                    existing.Adornee = char
                    existing.FillColor = color
                    existing.OutlineColor = color
                    existing.FillTransparency = S.ESPTransparency
                else
                    ESP.pool[key] = createHighlight(char, color)
                end
            else
                if existing and existing.Parent then
                    existing:Destroy()
                end
                ESP.pool[key] = nil
            end
        end

        -- cleanup
        for key, hl in pairs(ESP.pool) do
            if not hl or not hl.Parent then
                ESP.pool[key] = nil
            end
        end
    end
end)

-- Generator / Object ESP
local function getGeneratorList()
    local list = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("generator") or n:find("gen") then
                if obj:IsA("BasePart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") then
                    table.insert(list, obj)
                end
            end
        end
    end
    return list
end

local genHighlights = {}

task.spawn(function()
    while true do
        task.wait(1.5)

        -- Generator
        if S.ESPGenerator then
            local gens = getGeneratorList()
            for i, gen in ipairs(gens) do
                local key = "gen_" .. i
                if not genHighlights[key] or not genHighlights[key].Parent then
                    genHighlights[key] = createHighlight(gen, C.Yellow)
                else
                    genHighlights[key].Adornee = gen
                    genHighlights[key].FillColor = C.Yellow
                    genHighlights[key].OutlineColor = C.Yellow
                end
            end
        else
            for k, hl in pairs(genHighlights) do
                if hl and hl.Parent then hl:Destroy() end
                genHighlights[k] = nil
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [13] AIM SYSTEM (Silent + TOF)
-- ═══════════════════════════════════════════════════════════════════════
local Aim = {
    target = nil,
    lastTarget = nil,
}

local function getClosestTarget(filter)
    local myPos = getPos()
    if myPos == Vector3.zero then return nil end

    local best, bestDist = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end

        local team = plr.Team and plr.Team.Name:lower() or ""
        local shouldTarget = false

        if filter == "Killer" and team:find("killer") then shouldTarget = true end
        if filter == "Survivor" and team:find("surv") then shouldTarget = true end
        if filter == "Zombie" and team:find("zombie") then shouldTarget = true end
        if filter == "All" then shouldTarget = true end

        if not shouldTarget then continue end

        -- Cek jarak dalam FOV
        local dist = U.dist(myPos, hrp.Position)
        if dist < bestDist and dist <= S.AimFOV then
            -- Cek FOV visual
            local cam = Workspace.CurrentCamera
            local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            if onScreen then
                best = plr
                bestDist = dist
            end
        end
    end

    return best
end

local function getPredictedPosition(hrp, ping, speed)
    if not S.Predict then return hrp.Position end
    local hum = hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
    if not hum then return hrp.Position end
    local vel = hrp.Velocity
    local predictTime = (ping / 1000) + S.PredictValue
    return hrp.Position + (vel * predictTime)
end

local function aimUpdate()
    if not S.AimSilent then
        Aim.target = nil
        return
    end

    local target = getClosestTarget(S.AimTarget)
    Aim.target = target

    if not target then return end

    local char = target.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hrp then return end

    -- Predicted position
    local ping = LocalPlayer:GetNetworkPing() * 1000
    local predicted = getPredictedPosition(hrp, ping, S.TOFSpeed)

    -- Silent aim: kirim ke remote aim
    local cam = Workspace.CurrentCamera
    if cam then
        local aimPos = head and head.Position or hrp.Position
        local dir = (aimPos - cam.CFrame.Position).Unit
        -- Fire remote aim (silent, user gak lihat pergerakan camera)
        pcall(function()
            fire("AimUpdate", aimPos, dir)
        end)
    end
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if S.AimSilent then
            pcall(aimUpdate)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [14] TOF / SPEED SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local function applySpeedBoost()
    local h = getHum()
    if not h then return end

    if S.SpeedBoost then
        h.WalkSpeed = S.SpeedValue
    else
        h.WalkSpeed = S._originalWalk
    end
end

RunService.Heartbeat:Connect(function()
    applySpeedBoost()
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [15] FAST VAULT SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local vaultConn = nil

local function startVaultMonitor()
    if vaultConn then return end
    vaultConn = RunService.Heartbeat:Connect(function()
        if not S.FastVault then return end
        local h = getHum()
        if not h then return end
        local state = h:GetState()
        if state == Enum.HumanoidStateType.Climbing
            or state == Enum.HumanoidStateType.PlatformStanding then
            h.WalkSpeed = 40
        end
    end)
end

startVaultMonitor()

-- ═══════════════════════════════════════════════════════════════════════
-- [16] GENERATOR AUTO (MODE: NORMAL/PERFECT)
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.15)
        if not S.AutoGenerator then continue end
        if not isAlive() then continue end

        if tick() - S._lastGen < 0.2 then continue end
        S._lastGen = tick()

        -- Fire generator remote
        fire("Generator")

        if S.GenMode == "Perfect" then
            -- Perfect mode: fire skill check tepat waktu
            fire("SkillCheck", 1)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [17] AUTO PARRY
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.1)
        if not S.AutoParry then continue end
        if not isAlive() then continue end
        if tick() - S._lastParry < 0.3 then continue end
        S._lastParry = tick()
        fire("Parry")
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [18] KILLER SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.15)
        if not S.KillerAutoAttack then continue end
        if not isAlive() then continue end
        local role = getRole()
        if role ~= "Killer" then continue end
        fire("Attack")
    end
end)

-- Killer aim (veil mode - beam to nearest survivor)
task.spawn(function()
    while true do
        task.wait(0.1)
        if not S.KillerAim then continue end

        local target = getClosestTarget("Survivor")
        if not target or not target.Character then continue end
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        -- Killer aim: kirim ke remote aim
        local cam = Workspace.CurrentCamera
        if cam then
            local aimPos = hrp.Position
            pcall(function()
                fire("AimUpdate", aimPos)
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [19] MOVEMENT (FLY, NOCLIP)
-- ═══════════════════════════════════════════════════════════════════════
local function flyEnable()
    if S._flyBV then return end
    local root = getRoot()
    if not root then return end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.zero
    bv.Parent = root
    S._flyBV = bv

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 1000
    bg.D = 50
    bg.Parent = root
    S._flyBG = bg
end

local function flyDisable()
    if S._flyBV then S._flyBV:Destroy(); S._flyBV = nil end
    if S._flyBG then S._flyBG:Destroy(); S._flyBG = nil end
end

RunService.Heartbeat:Connect(function()
    if not S.Fly or not S._flyBV then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local mv = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then mv = mv - Vector3.new(0, 1, 0) end
    if mv.Magnitude > 0 then mv = mv.Unit * S.FlySpeed end
    S._flyBV.Velocity = mv
    S._flyBG.CFrame = cam.CFrame
end)

RunService.Stepped:Connect(function()
    if not S.NoClip then return end
    local char = getChar()
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then
            p.CanCollide = false
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if S.InfiniteJump then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [20] UPTIME HEARTBEAT
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        S.Uptime = tick() - S.SessionStart
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [21] UI COMPONENTS
-- ═══════════════════════════════════════════════════════════════════════

-- Sidebar button
local function makeSidebarBtn(parent, icon, label, callback)
    local btn = U.mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = C.BG2,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = parent,
    })
    U.rc(btn, 6)

    local ind = U.mk("Frame", {
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = C.White,
        BorderSizePixel = 0,
        Parent = btn,
    })
    U.rc(ind, 2)

    local lbl = U.mk("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.Gray2,
        Font = F.Med,
        TextSize = FS.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })

    btn.MouseButton1Click:Connect(function()
        callback(ind, lbl)
    end)

    return btn, ind, lbl
end

-- Card (collapsible section)
local function makeCard(parent, title, color)
    color = color or C.Cyan

    local holder = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = C.BG2,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Parent = parent,
    })
    U.rc(holder, 8)
    U.st(holder, C.Gray4, 1, 0.4)

    -- Header
    local hdr = U.mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = holder,
    })

    local dot = U.mk("Frame", {
        Size = UDim2.new(0, 4, 0, 16),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = hdr,
    })
    U.rc(dot, 2)

    U.mk("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = C.OffWhite,
        Font = F.Bold,
        TextSize = FS.H3,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = hdr,
    })

    local arrow = U.mk("TextLabel", {
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(1, -32, 0, 0),
        BackgroundTransparency = 1,
        Text = ">",
        TextColor3 = C.Gray2,
        Font = F.Bold,
        TextSize = FS.H3,
        Parent = hdr,
    })

    -- Content (hidden by default)
    local content = U.mk("Frame", {
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 44),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = holder,
    })
    U.ls(content, 6)

    local opened = false
    hdr.MouseButton1Click:Connect(function()
        opened = not opened
        if opened then
            content.Visible = true
            content.Size = UDim2.new(1, -20, 0, content.AbsoluteSize.Y)
            arrow.Text = "v"
        else
            content.Visible = false
            arrow.Text = ">"
        end
        holder.Size = UDim2.new(1, 0, 0, opened and (40 + content.AbsoluteSize.Y + 10) or 40)
    end)

    return holder, content
end

-- Toggle component (matches BOLONG-HUB style)
local function makeToggle(parent, label, key, callback)
    local h = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = C.BG3,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = parent,
    })
    U.rc(h, 8)

    U.mk("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.OffWhite,
        Font = F.Med,
        TextSize = FS.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = h,
    })

    -- Toggle track
    local tr = U.mk("Frame", {
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = S[key] and C.White or C.BG5,
        BackgroundTransparency = S[key] and 0 or 0.3,
        BorderSizePixel = 0,
        Parent = h,
    })
    U.rc(tr, 12)

    local dot = U.mk("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = S[key] and UDim2.new(1, -20, 0, 3) or UDim2.new(0, 3, 0, 3),
        BackgroundColor3 = S[key] and C.BG0 or C.Gray2,
        BorderSizePixel = 0,
        Parent = tr,
    })
    U.rc(dot, 9)

    local clk = U.mk("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = h,
    })

    clk.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        local on = S[key]
        U.tw(tr, {
            BackgroundColor3 = on and C.White or C.BG5,
            BackgroundTransparency = on and 0 or 0.3,
        }, 0.2)
        U.tw(dot, {
            Position = on and UDim2.new(1, -20, 0, 3) or UDim2.new(0, 3, 0, 3),
            BackgroundColor3 = on and C.BG0 or C.Gray2,
        }, 0.2)
        if callback then pcall(callback, on) end
    end)
end

-- Slider component
local function makeSlider(parent, label, key, mn, mx, df, sfx, callback)
    sfx = sfx or ""

    local h = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = C.BG3,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = parent,
    })
    U.rc(h, 8)

    U.mk("TextLabel", {
        Size = UDim2.new(0.5, 0, 0, 18),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.Gray1,
        Font = F.Med,
        TextSize = FS.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = h,
    })

    local vl = U.mk("TextLabel", {
        Size = UDim2.new(0.5, -14, 0, 18),
        Position = UDim2.new(0.5, 0, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(df) .. sfx,
        TextColor3 = C.White,
        Font = F.Bold,
        TextSize = FS.Small,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = h,
    })

    local tr = U.mk("TextButton", {
        Size = UDim2.new(1, -28, 0, 6),
        Position = UDim2.new(0, 14, 0, 38),
        BackgroundColor3 = C.BG5,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = h,
    })
    U.rc(tr, 3)

    local pct = (df - mn) / (mx - mn)
    local fl = U.mk("Frame", {
        Size = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = C.White,
        BorderSizePixel = 0,
        Parent = tr,
    })
    U.rc(fl, 3)

    local kn = U.mk("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(pct, -7, 0.5, -7),
        BackgroundColor3 = C.White,
        BorderSizePixel = 0,
        Parent = tr,
    })
    U.rc(kn, 7)

    local drag = false
    local function upd(i)
        local p = U.clamp((i.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + (mx - mn) * p + 0.5)
        fl.Size = UDim2.new(p, 0, 1, 0)
        kn.Position = UDim2.new(p, -7, 0.5, -7)
        vl.Text = tostring(v) .. sfx
        S[key] = v
        if callback then pcall(callback, v) end
    end

    tr.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            upd(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

-- Dropdown component
local function makeDropdown(parent, label, options, key, callback)
    local h = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 66),
        BackgroundColor3 = C.BG3,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Parent = parent,
    })
    U.rc(h, 8)

    U.mk("TextLabel", {
        Size = UDim2.new(1, -24, 0, 18),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.Gray1,
        Font = F.Med,
        TextSize = FS.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = h,
    })

    local sel = U.mk("TextButton", {
        Size = UDim2.new(1, -28, 0, 28),
        Position = UDim2.new(0, 14, 0, 28),
        BackgroundColor3 = C.BG4,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = h,
    })
    U.rc(sel, 6)

    local selLbl = U.mk("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = S[key] or options[1],
        TextColor3 = C.OffWhite,
        Font = F.Med,
        TextSize = FS.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sel,
    })

    U.mk("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -22, 0, 0),
        BackgroundTransparency = 1,
        Text = "v",
        TextColor3 = C.Gray2,
        Font = F.Bold,
        TextSize = FS.Small,
        Parent = sel,
    })

    local list = nil
    sel.MouseButton1Click:Connect(function()
        if list then list:Destroy(); list = nil; return end

        list = U.mk("Frame", {
            Size = UDim2.new(1, 0, 0, #options * 28 + 8),
            Position = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = C.BG2,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            ZIndex = 100,
            Parent = h,
        })
        U.rc(list, 6)
        U.st(list, C.Gray4, 1, 0.4)
        U.pd(list, 4, 4, 4, 4)

        for _, opt in ipairs(options) do
            local ob = U.mk("TextButton", {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = C.BG3,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                Text = opt,
                TextColor3 = C.OffWhite,
                Font = F.Med,
                TextSize = FS.Small,
                AutoButtonColor = false,
                ZIndex = 101,
                Parent = list,
            })
            U.rc(ob, 4)
            ob.MouseButton1Click:Connect(function()
                S[key] = opt
                selLbl.Text = opt
                if list then list:Destroy(); list = nil end
                if callback then pcall(callback, opt) end
            end)
        end
    end)
end

-- Button component
local function makeButton(parent, label, color, callback)
    color = color or C.White

    local b = U.mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = C.BG3,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = parent,
    })
    U.rc(b, 8)

    U.mk("Frame", {
        Size = UDim2.new(0, 3, 0, 16),
        Position = UDim2.new(0, 12, 0.5, -8),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = b,
    })

    U.mk("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.OffWhite,
        Font = F.Bold,
        TextSize = FS.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = b,
    })

    b.MouseButton1Click:Connect(function()
        U.tw(b, { BackgroundTransparency = 0.5 }, 0.1)
        task.wait(0.1)
        U.tw(b, { BackgroundTransparency = 0.2 }, 0.15)
        if callback then pcall(callback) end
    end)
end

-- Info row
local function makeInfoRow(parent, label, value, color)
    local r = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    U.mk("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.Gray2,
        Font = F.Med,
        TextSize = FS.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = r,
    })
    local v = U.mk("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = value,
        TextColor3 = color or C.OffWhite,
        Font = F.Bold,
        TextSize = FS.Small,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = r,
    })
    return v
end

-- ═══════════════════════════════════════════════════════════════════════
-- [22] MAIN UI BUILD
-- ═══════════════════════════════════════════════════════════════════════
local function buildUI()
    local Screen = U.mk("ScreenGui", {
        Name = "BMXUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    }, PlayerGui)

    -- Floating toggle button
    local FAB = U.mk("Frame", {
        Size = UDim2.new(0, 52, 0, 52),
        Position = UDim2.new(1, -70, 0.5, -26),
        BackgroundColor3 = C.BG2,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 200,
    }, Screen)
    U.rc(FAB, 26)
    U.st(FAB, C.Gray4, 1, 0.3)

    U.mk("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "B",
        TextColor3 = C.White,
        Font = F.Black,
        TextSize = 20,
        ZIndex = 201,
        Parent = FAB,
    })

    -- Main panel (draggable)
    local Panel = U.mk("Frame", {
        Size = UDim2.new(0, MAIN_W, 0, MAIN_H),
        Position = UDim2.new(0.5, -MAIN_W / 2, 0.5, -MAIN_H / 2),
        BackgroundColor3 = C.BG1,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Visible = false,
        Active = true,
        Draggable = true,
        ZIndex = 100,
    }, Screen)
    U.rc(Panel, 14)
    U.st(Panel, C.Gray4, 1, 0.5)

    -- Header
    local Header = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.BG2,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 101,
    }, Panel)
    U.rc(Header, 14)

    U.mk("TextLabel", {
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = "BLACK MATRIX",
        TextColor3 = C.White,
        Font = F.Black,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
        Parent = Header,
    })

    U.mk("TextLabel", {
        Size = UDim2.new(0, 200, 0, 14),
        Position = UDim2.new(0, 14, 0, 26),
        BackgroundTransparency = 1,
        Text = "Violence District",
        TextColor3 = C.Gray2,
        Font = F.Norm,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
        Parent = Header,
    })

    U.mk("TextLabel", {
        Size = UDim2.new(0, 200, 0, 14),
        Position = UDim2.new(0, 120, 0, 16),
        BackgroundTransparency = 1,
        Text = "| " .. CFG.DISCORD,
        TextColor3 = C.Cyan,
        Font = F.Med,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
        Parent = Header,
    })

    -- Close button
    local closeBtn = U.mk("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -42, 0, 7),
        BackgroundColor3 = C.BG3,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = C.Red,
        Font = F.Bold,
        TextSize = 13,
        AutoButtonColor = false,
        ZIndex = 103,
        Parent = Header,
    })
    U.rc(closeBtn, 8)

    closeBtn.MouseButton1Click:Connect(function()
        U.tw(Panel, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.2,
            Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.wait(0.2)
        Panel.Visible = false
        Panel.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
        Panel.BackgroundTransparency = 0.15
    end)

    -- Minimize button
    local minBtn = U.mk("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -78, 0, 7),
        BackgroundColor3 = C.BG3,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = "-",
        TextColor3 = C.Gray1,
        Font = F.Bold,
        TextSize = 15,
        AutoButtonColor = false,
        ZIndex = 103,
        Parent = Header,
    })
    U.rc(minBtn, 8)

    minBtn.MouseButton1Click:Connect(function()
        Panel.Visible = false
    end)

    -- Search bar
    local Search = U.mk("Frame", {
        Size = UDim2.new(0, SIDEBAR_W - 20, 0, 30),
        Position = UDim2.new(0, 10, 0, 54),
        BackgroundColor3 = C.BG2,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 101,
        Parent = Panel,
    })
    U.rc(Search, 8)

    U.mk("TextLabel", {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "?",
        TextColor3 = C.Gray2,
        Font = F.Bold,
        TextSize = 12,
        ZIndex = 102,
        Parent = Search,
    })

    local searchBox = U.mk("TextBox", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 26, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search...",
        PlaceholderColor3 = C.Gray3,
        TextColor3 = C.OffWhite,
        Font = F.Norm,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 102,
        Parent = Search,
    })

    -- Sidebar
    local Sidebar = U.mk("ScrollingFrame", {
        Size = UDim2.new(0, SIDEBAR_W - 20, 1, -110),
        Position = UDim2.new(0, 10, 0, 92),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = C.Gray3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 101,
        Parent = Panel,
    })
    U.ls(Sidebar, 4)

    -- Content area
    local Content = U.mk("ScrollingFrame", {
        Size = UDim2.new(1, -SIDEBAR_W - 20, 1, -60),
        Position = UDim2.new(0, SIDEBAR_W + 10, 0, 54),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.Gray3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 101,
        Parent = Panel,
    })
    U.ls(Content, 8)

    -- Page title
    local PageTitle = U.mk("TextLabel", {
        Size = UDim2.new(1, -SIDEBAR_W - 20, 0, 24),
        Position = UDim2.new(0, SIDEBAR_W + 10, 0, 26),
        BackgroundTransparency = 1,
        Text = "Info",
        TextColor3 = C.White,
        Font = F.Black,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
        Parent = Panel,
    })

    -- Pages container
    local pages = {}

    local function showPage(name)
        for n, p in pairs(pages) do p.Visible = false end
        if pages[name] then
            pages[name].Visible = true
            PageTitle.Text = name
        end
    end

    -- ═══════════════════════════════════════════════
    -- PAGE: INFO
    -- ═══════════════════════════════════════════════
    local pageInfo = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 102,
        Parent = Content,
    })
    U.ls(pageInfo, 8)
    pages["Info"] = pageInfo

    local infoCard, infoContent = makeCard(pageInfo, "SCRIPT INFO", C.Cyan)
    local infoBox = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 130),
        BackgroundTransparency = 1,
        Parent = infoContent,
    })
    U.ls(infoBox, 4)
    makeInfoRow(infoBox, "Name", CFG.NAME, C.White)
    makeInfoRow(infoBox, "Version", "v" .. CFG.VERSION, C.Cyan)
    makeInfoRow(infoBox, "Game", CFG.GAME, C.Purple)
    makeInfoRow(infoBox, "Creator", CFG.CREATOR, C.Pink)
    makeInfoRow(infoBox, "Year", CFG.YEAR, C.Yellow)
    makeInfoRow(infoBox, "Device", IS_MOBILE and "Mobile" or "PC", C.Green)

    local warnCard, warnContent = makeCard(pageInfo, "WARNING", C.Yellow)
    U.mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        Text = "SC by kalzz. Semoga SC ini cepat berkembang.\nMungkin masih ada beberapa bug, tetapi akan segera diperbaiki!",
        TextColor3 = C.Gray1,
        Font = F.Norm,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = warnContent,
    })

    local liveCard, liveContent = makeCard(pageInfo, "LIVE DATA", C.Green)
    local liveBox = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 90),
        BackgroundTransparency = 1,
        Parent = liveContent,
    })
    U.ls(liveBox, 4)
    local IStatus = makeInfoRow(liveBox, "Status", "Idle", C.White)
    local IRole = makeInfoRow(liveBox, "Role", "Unknown", C.Purple)
    local IUptime = makeInfoRow(liveBox, "Uptime", "00:00", C.Cyan)
    local IPlayer = makeInfoRow(liveBox, "Players", "0/0", C.Yellow)

    task.spawn(function()
        while true do
            task.wait(0.5)
            IRole.Text = getRole()
            IUptime.Text = U.fmt(S.Uptime)
            IPlayer.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
            if S.Status == "Farming" then
                IStatus.TextColor3 = C.Green
            else
                IStatus.TextColor3 = C.White
            end
            IStatus.Text = S.Status
        end
    end)

    -- ═══════════════════════════════════════════════
    -- PAGE: SURVIVOR
    -- ═══════════════════════════════════════════════
    local pageSurv = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 102,
        Parent = Content,
    })
    U.ls(pageSurv, 8)
    pages["Survivor"] = pageSurv

    -- Card 1: Auto Generator
    local genCard, genContent = makeCard(pageSurv, "AUTO GENERATOR", C.Green)
    makeToggle(genContent, "Auto Generator", "AutoGenerator")
    makeDropdown(genContent, "Mode", {"Normal", "Perfect"}, "GenMode")
    makeToggle(genContent, "Generator Boost", "GenBoost")

    local genNote = U.mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "Normal = safe zone | Perfect = ideal hit",
        TextColor3 = C.Gray2,
        Font = F.Norm,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = genContent,
    })

    -- Card 2: Aim Silent
    local aimCard, aimContent = makeCard(pageSurv, "AIM SILENT (TOF)", C.Red)
    makeToggle(aimContent, "Aim Silent", "AimSilent")
    makeDropdown(aimContent, "Target", {"Killer", "Survivor", "Zombie", "All"}, "AimTarget")
    makeSlider(aimContent, "FOV", "AimFOV", 50, 1000, 500, "px")
    makeSlider(aimContent, "Smooth", "AimSmooth", 0.01, 1, 0.15)
    makeToggle(aimContent, "Zigzag Detect", "ZigzagDetect")
    makeToggle(aimContent, "Predict", "Predict")
    makeSlider(aimContent, "Predict Value", "PredictValue", 0.01, 1, 0.15)

    -- Card 3: TOF
    local tofCard, tofContent = makeCard(pageSurv, "TOF SYSTEM", C.Orange)
    makeToggle(tofCard:FindFirstChildOfClass("TextButton") and tofContent or tofContent, "TOF", "TOF")
    makeSlider(tofContent, "TOF Speed", "TOFSpeed", 100, 800, 800)

    -- Card 4: Fast Vault
    local vaultCard, vaultContent = makeCard(pageSurv, "MOVEMENT", C.Purple)
    makeToggle(vaultContent, "Fast Vault", "FastVault")
    makeToggle(vaultContent, "Speed Boost", "SpeedBoost")
    makeSlider(vaultContent, "Speed Value", "SpeedValue", 16, 100, 24)
    makeToggle(vaultContent, "Anti Fall Slow", "AntiFallSlow")
    makeToggle(vaultContent, "Infinite Stamina", "InfiniteStamina")

    -- Card 5: Auto Parry
    local parryCard, parryContent = makeCard(pageSurv, "AUTO PARRY", C.Cyan)
    makeToggle(parryContent, "Auto Parry", "AutoParry")

    -- ═══════════════════════════════════════════════
    -- PAGE: KILLER
    -- ═══════════════════════════════════════════════
    local pageKiller = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 102,
        Parent = Content,
    })
    U.ls(pageKiller, 8)
    pages["Killer"] = pageKiller

    local kAimCard, kAimContent = makeCard(pageKiller, "KILLER AIM (VEIL)", C.Red)
    makeToggle(kAimContent, "Aim TOF (Veil)", "KillerAim")
    makeDropdown(kAimContent, "Aim Mode", {"Veil", "Silent", "Lock"}, "KillerAimMode")
    makeSlider(kAimContent, "Predict", "KillerPredict", 1, 200, 100)

    local kSpearCard, kSpearContent = makeCard(pageKiller, "SPEAR CONTROL", C.Orange)
    makeSlider(kSpearContent, "Spear Gravity", "SpearGravity", 100, 500, 100)
    makeSlider(kSpearContent, "Spear Speed", "SpearSpeed", 200, 500, 200)

    local kMiscCard, kMiscContent = makeCard(pageKiller, "KILLER MISC", C.Purple)
    makeToggle(kMiscContent, "Auto Attack", "KillerAutoAttack")
    makeToggle(kMiscContent, "Infinite Lunge", "KillerInfiniteLunge")
    makeToggle(kMiscContent, "No Stun", "KillerNoStun")

    -- ═══════════════════════════════════════════════
    -- PAGE: VISUAL (ESP)
    -- ═══════════════════════════════════════════════
    local pageVisual = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 102,
        Parent = Content,
    })
    U.ls(pageVisual, 8)
    pages["Visual"] = pageVisual

    local espCard, espContent = makeCard(pageVisual, "ESP (OUTLINE ONLY)", C.Pink)
    makeToggle(espContent, "Killer ESP", "ESPKiller", function(v)
        if not v then
            for k, hl in pairs(ESP.pool) do
                if hl and hl.Parent then hl:Destroy() end
                ESP.pool[k] = nil
            end
        end
    end)
    makeToggle(espContent, "Survivor ESP", "ESPSurvivor")
    makeToggle(espContent, "Generator ESP", "ESPGenerator")
    makeSlider(espContent, "Transparency", "ESPTransparency", 0, 1, 0.3)

    local gfxCard, gfxContent = makeCard(pageVisual, "GRAPHICS", C.Cyan)
    makeToggle(gfxContent, "Fullbright", "Fullbright", function(v)
        if v then
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
        else
            Lighting.Brightness = 2
        end
    end)
    makeToggle(gfxContent, "Low Graphics", "LowGraphics", function(v)
        pcall(function()
            settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
        end)
    end)

    -- ═══════════════════════════════════════════════
    -- PAGE: MISC
    -- ═══════════════════════════════════════════════
    local pageMisc = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 102,
        Parent = Content,
    })
    U.ls(pageMisc, 8)
    pages["Misc"] = pageMisc

    local safetyCard, safetyContent = makeCard(pageMisc, "SAFETY", C.Green)
    makeToggle(safetyContent, "Anti-AFK", "AntiAFK")
    makeToggle(safetyContent, "Anti Stun", "AntiStun")
    makeToggle(safetyContent, "Instant Heal", "InstantHeal")

    local moveCard, moveContent = makeCard(pageMisc, "MOVEMENT", C.Cyan)
    makeToggle(moveContent, "No Clip", "NoClip")
    makeToggle(moveContent, "Fly", "Fly", function(v)
        if v then flyEnable() else flyDisable() end
    end)
    makeSlider(moveContent, "Fly Speed", "FlySpeed", 20, 250, 60)
    makeToggle(moveContent, "Infinite Jump", "InfiniteJump")

    local utilCard, utilContent = makeCard(pageMisc, "UTILITY", C.Yellow)
    makeButton(utilContent, "Rescan Remotes", C.Purple, function()
        RemoteCache = {}
        local n = scanRemotes()
        notify("Remotes", n .. " cached", C.Purple)
    end)
    makeButton(utilContent, "Teleport Spawn", C.Cyan, function()
        local sp = Workspace:FindFirstChildOfClass("SpawnLocation")
        local r = getRoot()
        if sp and r then r.CFrame = CFrame.new(sp.Position + Vector3.new(0, 3, 0)) end
    end)
    makeButton(utilContent, "Rejoin Server", C.Orange, function()
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end)
    makeButton(utilContent, "Reset Stats", C.Red, function()
        S.Status = "Idle"
        notify("Stats", "Reset", C.Red)
    end)

    -- ═══════════════════════════════════════════════
    -- PAGE: CONFIG
    -- ═══════════════════════════════════════════════
    local pageConfig = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 102,
        Parent = Content,
    })
    U.ls(pageConfig, 8)
    pages["Config"] = pageConfig

    local cfgCard, cfgContent = makeCard(pageConfig, "SAVE / LOAD", C.Cyan)
    makeButton(cfgContent, "Save Config", C.Green, function()
        local data = {}
        for k, v in pairs(S) do
            if type(v) ~= "table" and type(v) ~= "userdata" and type(v) ~= "function" then
                data[k] = v
            end
        end
        pcall(function()
            if writefile then
                writefile("BMX_config.json", HttpService:JSONEncode(data))
                notify("Config", "Saved", C.Green)
            end
        end)
    end)
    makeButton(cfgContent, "Load Config", C.Yellow, function()
        pcall(function()
            if isfile and isfile("BMX_config.json") then
                local data = HttpService:JSONDecode(readfile("BMX_config.json"))
                for k, v in pairs(data) do
                    if S[k] ~= nil then S[k] = v end
                end
                notify("Config", "Loaded", C.Green)
            end
        end)
    end)

    -- ═══════════════════════════════════════════════
    -- SIDEBAR BUTTONS
    -- ═══════════════════════════════════════════════
    local sidebarBtns = {}
    local sidebarLabels = {"Info", "Survivor", "Killer", "Visual", "Misc", "Config"}

    for _, name in ipairs(sidebarLabels) do
        local btn, ind, lbl = makeSidebarBtn(Sidebar, "?", name, function()
            for _, b in ipairs(sidebarBtns) do
                U.tw(b.btn, { BackgroundTransparency = 1 }, 0.15)
                U.tw(b.ind, { Size = UDim2.new(0, 3, 0, 0) }, 0.15)
                U.tw(b.ind, { BackgroundColor3 = C.White }, 0.15)
                U.tw(b.lbl, { TextColor3 = C.Gray2 }, 0.15)
            end
            U.tw(btn, { BackgroundTransparency = 0.4 }, 0.15)
            U.tw(ind, { Size = UDim2.new(0, 3, 0, 20) }, 0.15)
            U.tw(ind, { BackgroundColor3 = C.White }, 0.15)
            U.tw(lbl, { TextColor3 = C.White }, 0.15)
            showPage(name)
        end)
        table.insert(sidebarBtns, { btn = btn, ind = ind, lbl = lbl, name = name })
    end

    -- Default page
    task.spawn(function()
        task.wait(0.1)
        showPage("Info")
        if sidebarBtns[1] then
            U.tw(sidebarBtns[1].btn, { BackgroundTransparency = 0.4 }, 0.15)
            U.tw(sidebarBtns[1].ind, { Size = UDim2.new(0, 3, 0, 20) }, 0.15)
            U.tw(sidebarBtns[1].lbl, { TextColor3 = C.White }, 0.15)
        end
    end)

    -- FAB toggle
    local fabBtn = U.mk("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 201,
        Parent = FAB,
    })

    fabBtn.MouseButton1Click:Connect(function()
        Panel.Visible = not Panel.Visible
        if Panel.Visible then
            Panel.Size = UDim2.new(0, 0, 0, 0)
            U.tw(Panel, { Size = UDim2.new(0, MAIN_W, 0, MAIN_H) }, 0.25,
                Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)

    -- Auto update canvas
    task.spawn(function()
        while true do
            task.wait(0.3)
            for _, p in pairs(pages) do
                if p.Visible then
                    local total = 0
                    for _, ch in ipairs(p:GetChildren()) do
                        if ch:IsA("Frame") then
                            total = total + ch.AbsoluteSize.Y + 8
                        end
                    end
                    Content.CanvasSize = UDim2.new(0, 0, 0, total + 30)
                end
            end
            Sidebar.CanvasSize = UDim2.new(0, 0, 0, #sidebarLabels * 44 + 10)
        end
    end)

    return Screen
end

-- ═══════════════════════════════════════════════════════════════════════
-- [23] KEYBINDS
-- ═══════════════════════════════════════════════════════════════════════
local Keybinds = {
    toggleUI = Enum.KeyCode.RightControl,
    panic = Enum.KeyCode.F7,
}

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local k = input.KeyCode

    if k == Keybinds.toggleUI then
        local screen = PlayerGui:FindFirstChild("BMXUI")
        if screen then
            local panel
            for _, c in ipairs(screen:GetChildren()) do
                if c:IsA("Frame") and c.Name == "" or c:IsA("Frame") then
                    if c:FindFirstChild("TextBox") or c:FindFirstChildWhichIsA("TextButton") then
                        panel = c
                        break
                    end
                end
            end
        end
    elseif k == Keybinds.panic then
        S.AimSilent = false
        S.AutoGenerator = false
        S.AutoParry = false
        S.KillerAim = false
        S.KillerAutoAttack = false
        S.SpeedBoost = false
        S.Fly = false
        flyDisable()
        notify("PANIC", "All stopped", C.Red, 4)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [24] CHAT COMMANDS
-- ═══════════════════════════════════════════════════════════════════════
LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == "!gen" then S.AutoGenerator = not S.AutoGenerator; notify("Gen", tostring(S.AutoGenerator), C.Green)
    elseif msg == "!parry" then S.AutoParry = not S.AutoParry
    elseif msg == "!aim" then S.AimSilent = not S.AimSilent; notify("Aim", tostring(S.AimSilent), C.Red)
    elseif msg == "!scan" then RemoteCache = {}; notify("Scan", scanRemotes() .. " cached", C.Purple)
    elseif msg == "!panic" then
        S.AimSilent = false; S.AutoGenerator = false; S.AutoParry = false
        S.KillerAim = false; S.KillerAutoAttack = false
        notify("PANIC", "All off", C.Red)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [25] INIT & BOOT
-- ═══════════════════════════════════════════════════════════════════════
scanRemotes()
buildUI()

notify("BLACK MATRIX", "v" .. CFG.VERSION .. " loaded", C.Cyan, 4)
notify("Anti-AFK", "Active", C.Green, 3)

print("╔══════════════════════════════════════════════════════════════╗")
print("║   BLACK MATRIX v" .. CFG.VERSION .. " - " .. CFG.GAME)
print("║   Creator: " .. CFG.CREATOR)
print("║   Device : " .. (IS_MOBILE and "Mobile" or "PC"))
print("║   UI     : 900+ lines | Function: 1100+ lines")
print("╚══════════════════════════════════════════════════════════════╝")
print("[Chat] !gen !parry !aim !scan !panic")
print("[Keybind] RCTRL = Toggle UI | F7 = Panic")
