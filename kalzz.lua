--[[
    ═══════════════════════════════════════════════════════════════════════
    VIOLENCE DISTRICT - BLACK MATRIX AGGRESSIVE v5.0
    ═══════════════════════════════════════════════════════════════════════
    UI      : 800+ lines (4 tabs, animated, full component library)
    Function: 1500+ lines (farm, hop, esp, movement, anti-afk, tools)
    Mode    : AGGRESSIVE - fast loop, multi-remote, auto-recover
    Creator : kalzz | 2026
    ═══════════════════════════════════════════════════════════════════════
--]]

-- ═══════════════════════════════════════════════════════════════════════
-- [01] SERVICES & CORE (Lines 1-60)
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
local GuiService        = game:GetService("GuiService")
local StarterGui        = game:GetService("StarterGui")
local ContextAction     = game:GetService("ContextActionService")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")
local Camera            = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════
-- [02] CONFIG BLOCK (Lines 61-100)
-- ═══════════════════════════════════════════════════════════════════════
local CFG = {
    NAME     = "Black Matrix Aggressive",
    VERSION  = "5.0",
    TAG      = "BMU-AGG",
    CREATOR  = "kalzz",
    YEAR     = "2026",
    PLACE_ID = 93978595733734,
    DEBUG    = false,
}

local DEVICE = {
    MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled,
    TABLET = UserInputService.TouchEnabled and UserInputService.MouseEnabled,
    PC     = not UserInputService.TouchEnabled,
}

local UI = {
    SCALE  = DEVICE.MOBILE and 0.92 or (DEVICE.TABLET and 0.88 or 1),
    PANEL_W = math.floor(410 * (DEVICE.MOBILE and 0.92 or 1)),
    PANEL_H = math.floor(575 * (DEVICE.MOBILE and 0.92 or 1)),
    FAB    = DEVICE.MOBILE and 58 or 52,
}

-- ═══════════════════════════════════════════════════════════════════════
-- [03] GLOBAL STATE (Lines 101-200)
-- ═══════════════════════════════════════════════════════════════════════
local State = {
    -- FARM toggles
    AutoFarm        = false,
    AutoEscape      = false,
    AutoNext        = false,
    AutoAttack      = false,
    AutoParry       = false,
    AutoGenerator   = false,
    AutoHeal        = false,
    AutoSave        = false,
    AutoRevive      = false,
    AutoAvoidKiller = false,
    AutoSprint      = false,
    AutoChat        = false,
    AutoCollect     = false,
    AutoSkillCheck  = false,

    -- HOP toggles
    HopOnFull       = true,
    HopAfterEscape  = true,
    HopOnDeadStreak = false,

    -- MOVEMENT toggles
    SpeedHack       = false,
    InfiniteJump    = false,
    NoClip          = false,
    Fly             = false,
    AutoJump        = false,
    TeleportWalk    = false,

    -- VISUAL toggles
    Fullbright      = false,
    LowGraphics     = false,
    KillerESP       = false,
    SurvivorESP     = false,
    GeneratorESP    = false,
    HitboxExpand    = false,
    CameraLock      = false,

    -- MISC toggles
    AntiAFK         = true,
    AntiStun        = false,
    AntiBlind       = false,
    AutoPing        = false,
    InstantHeal     = false,

    -- NUMERIC
    SpeedValue      = 24,
    JumpPower       = 55,
    FlySpeed        = 65,
    Delay           = 0.5,
    AttackRate      = 0.35,
    ParryRate       = 0.2,
    MaxPlayers      = 4,
    HopCooldown     = 15,
    ChatMessage     = "auto farm...",

    -- STATS
    Farmed          = 0,
    Escaped         = 0,
    NextRound       = 0,
    Hits            = 0,
    Parries         = 0,
    Gens            = 0,
    Saved           = 0,
    Revived         = 0,
    Skills          = 0,
    HopCount        = 0,
    DeathStreak     = 0,
    Status          = "Idle",
    Uptime          = 0,
    SessionStart    = 0,
    BestSession     = 0,

    -- INTERNAL
    _lastAttack     = 0,
    _lastParry      = 0,
    _lastEscape     = 0,
    _lastChat       = 0,
    _lastRevive     = 0,
    _lastSkill      = 0,
    _lastPos        = Vector3.new(0,0,0),
    _stuck          = 0,
    _flyBV          = nil,
    _flyBG          = nil,
    _currentTab     = "FARM",
    _panelVisible   = false,
    _espCache       = {},
    _connections    = {},
    _attached       = false,
}

-- ═══════════════════════════════════════════════════════════════════════
-- [04] THEME (Lines 201-270)
-- ═══════════════════════════════════════════════════════════════════════
local C = {
    Black0    = Color3.fromRGB(0, 0, 0),
    Black1    = Color3.fromRGB(6, 6, 8),
    Black2    = Color3.fromRGB(12, 12, 16),
    Black3    = Color3.fromRGB(20, 20, 26),
    Black4    = Color3.fromRGB(30, 30, 38),
    Black5    = Color3.fromRGB(42, 42, 54),
    Black6    = Color3.fromRGB(58, 58, 72),
    White     = Color3.fromRGB(255, 255, 255),
    OffWhite  = Color3.fromRGB(235, 235, 240),
    Gray1     = Color3.fromRGB(185, 185, 195),
    Gray2     = Color3.fromRGB(125, 125, 140),
    Gray3     = Color3.fromRGB(85, 85, 100),
    Cyan      = Color3.fromRGB(0, 220, 255),
    CyanDim   = Color3.fromRGB(0, 120, 160),
    Green     = Color3.fromRGB(0, 220, 130),
    GreenDim  = Color3.fromRGB(0, 130, 75),
    Red       = Color3.fromRGB(255, 70, 90),
    RedDim    = Color3.fromRGB(160, 35, 55),
    Yellow    = Color3.fromRGB(255, 200, 70),
    YellowDim = Color3.fromRGB(160, 120, 40),
    Purple    = Color3.fromRGB(160, 110, 255),
    PurpleDim = Color3.fromRGB(100, 65, 160),
    Pink      = Color3.fromRGB(255, 110, 200),
    Gold      = Color3.fromRGB(255, 215, 0),
    Blue      = Color3.fromRGB(70, 130, 255),
    Orange    = Color3.fromRGB(255, 140, 60),
}

local F = {
    Bold   = Enum.Font.GothamBold,
    Black  = Enum.Font.GothamBlack,
    Med    = Enum.Font.GothamMedium,
    Norm   = Enum.Font.Gotham,
    Mono   = Enum.Font.Code,
}

local FS = {
    H1 = 18, H2 = 15, H3 = 13,
    Body = 12, Small = 10, Tiny = 9, Micro = 8, Nano = 7,
}

-- ═══════════════════════════════════════════════════════════════════════
-- [05] UTILITY LIBRARY (Lines 271-450)
-- ═══════════════════════════════════════════════════════════════════════
local U = {}

function U.mk(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

function U.rc(o, r) return U.mk("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o) end
function U.st(o, c, t, tr) return U.mk("UIStroke", {Color = c or C.Black5, Thickness = t or 1, Transparency = tr or 0}, o) end
function U.gd(o, cs, r) return U.mk("UIGradient", {Color = ColorSequence.new(cs), Rotation = r or 90}, o) end
function U.ls(o, s, d)
    return U.mk("UIListLayout", {
        Padding = UDim.new(0, s or 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = d or Enum.FillDirection.Vertical,
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

function U.tw(o, p, d, s, dir)
    local t = TweenService:Create(
        o,
        TweenInfo.new(d or 0.2, s or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        p
    )
    t:Play()
    return t
end

function U.twW(o, p, d, s, dir)
    local t = U.tw(o, p, d, s, dir)
    t.Completed:Wait()
    return t
end

function U.dist(a, b) return (a - b).Magnitude end
function U.clamp(v, mn, mx) return math.max(mn, math.min(mx, v)) end
function U.round(n, d)
    d = d or 1
    local m = 10 ^ d
    return math.floor(n * m + 0.5) / m
end
function U.fmt(sec) return string.format("%02d:%02d", math.floor(sec / 60), math.floor(sec % 60)) end
function U.fmtHM(sec)
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = math.floor(sec % 60)
    if h > 0 then return string.format("%dh %dm", h, m) end
    return string.format("%dm %ds", m, s)
end
function U.count(t) local n = 0 for _ in pairs(t) do n = n + 1 end return n end
function U.copy(t) local o = {} for k, v in pairs(t) do o[k] = v end return o end
function U.safe(fn, ...) local ok, r = pcall(fn, ...) return ok and r or nil end
function U.arrayHas(arr, v)
    for _, x in ipairs(arr) do if x == v then return true end end
    return false
end
function U.randomHex(len)
    local s = ""
    for i = 1, len do
        s = s .. string.format("%x", math.random(0, 15))
    end
    return s
end

-- ═══════════════════════════════════════════════════════════════════════
-- [06] LOGGER (Lines 451-520)
-- ═══════════════════════════════════════════════════════════════════════
local Log = {
    history = {},
    max = 500,
    enabled = true,
}

function Log.add(lvl, msg)
    if not Log.enabled then return end
    local entry = {t = os.date("%H:%M:%S"), l = lvl, m = tostring(msg)}
    table.insert(Log.history, entry)
    if #Log.history > Log.max then table.remove(Log.history, 1) end
    if CFG.DEBUG or lvl == "ERROR" or lvl == "WARN" then
        print(string.format("[%s][%s] %s", entry.t, entry.l, entry.m))
    end
end

function Log.info(m) Log.add("INFO", m) end
function Log.warn(m) Log.add("WARN", m) end
function Log.err(m) Log.add("ERROR", m) end
function Log.debug(m) if CFG.DEBUG then Log.add("DEBUG", m) end end

-- ═══════════════════════════════════════════════════════════════════════
-- [07] PLAYER HELPERS (Lines 521-600)
-- ═══════════════════════════════════════════════════════════════════════
local function getChar() return LocalPlayer.Character end
local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getHead()
    local c = getChar()
    return c and c:FindFirstChild("Head")
end
local function isAlive()
    local h = getHum()
    return h and h.Health > 0
end
local function healthPct()
    local h = getHum()
    if not h or h.MaxHealth <= 0 then return 0 end
    return (h.Health / h.MaxHealth) * 100
end
local function getPos() return getRoot() and getRoot().Position or Vector3.zero end
local function getTeamName()
    local t = LocalPlayer.Team
    return t and t.Name or "None"
end
local function isFriend(plr) return LocalPlayer:IsFriendsWith(plr.UserId) end

-- ═══════════════════════════════════════════════════════════════════════
-- [08] ADVANCED REMOTE MANAGER (Lines 601-800)
-- ═══════════════════════════════════════════════════════════════════════
local RemoteCache = {}
local RemoteStats = { fired = 0, failed = 0, discovered = 0 }

local REMOTE_GROUPS = {
    Attack = {
        "Attack", "Hit", "Damage", "Strike", "Swing", "Slash",
        "PerformAttack", "DoAttack", "AttackEvent", "SwingSword",
    },
    Parry = {
        "Parry", "Block", "Counter", "Defend", "ParryEvent",
        "DoParry", "PerformParry",
    },
    Interact = {
        "Interact", "Use", "Activate", "Trigger", "InteractEvent",
        "DoInteract",
    },
    Generator = {
        "ActivateGenerator", "RepairGenerator", "FixGenerator", "Generator",
        "DoGenerator", "CompleteGenerator", "SkillCheck", "CompleteCheck",
        "GeneratorComplete", "FixGen", "RepairGen",
    },
    Escape = {
        "Escape", "Exit", "Leave", "EscapeEvent", "DoEscape",
        "ExitMatch", "EscapeGate", "EscapeDoor",
    },
    NextGame = {
        "NextGame", "Next", "Rejoin", "PlayAgain", "Continue",
        "Requeue", "NextRound", "JoinQueue",
    },
    Save = {
        "Save", "Rescue", "Unhook", "SaveEvent", "DoSave",
        "RescueSurvivor", "UnhookSurvivor",
    },
    Heal = {
        "Heal", "HealSelf", "UseMedkit", "HealEvent", "ApplyHeal",
    },
    Revive = {
        "Revive", "Respawn", "SelfRevive", "ReviveEvent", "DoRevive",
    },
    Collect = {
        "Collect", "Pickup", "Grab", "Take", "CollectEvent",
    },
    Sprint = {
        "Sprint", "Run", "Dash", "ToggleSprint",
    },
}

local function scanRemote(r)
    if not r then return false end
    if not (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return false end
    for group, names in pairs(REMOTE_GROUPS) do
        for _, n in ipairs(names) do
            if r.Name == n then
                RemoteCache[n] = r
                RemoteStats.discovered = RemoteStats.discovered + 1
                Log.info("Discovered remote: " .. n .. " (" .. group .. ")")
                return true
            end
        end
    end
    return false
end

local function fullScanRemotes()
    local scanned = 0
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if scanRemote(obj) then scanned = scanned + 1 end
    end
    if scanned > 0 then
        Log.info("Full scan complete: " .. scanned .. " remotes cached")
    end
end

local function findRemote(name)
    if RemoteCache[name] and RemoteCache[name].Parent then
        return RemoteCache[name]
    end
    local r = ReplicatedStorage:FindFirstChild(name, true)
    if r then
        RemoteCache[name] = r
        return r
    end
    return nil
end

local function fireGroup(group, ...)
    local args = {...}
    local names = REMOTE_GROUPS[group]
    if not names then return false end
    local fired = false
    for _, name in ipairs(names) do
        local r = RemoteCache[name] or ReplicatedStorage:FindFirstChild(name, true)
        if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
            RemoteCache[name] = r
            local ok = pcall(function()
                if r:IsA("RemoteEvent") then
                    r:FireServer(unpack(args))
                else
                    r:InvokeServer(unpack(args))
                end
            end)
            if ok then
                RemoteStats.fired = RemoteStats.fired + 1
                fired = true
            else
                RemoteStats.failed = RemoteStats.failed + 1
            end
        end
    end
    return fired
end

-- Aggressive fire: coba semua remote sekaligus tanpa delay
local function fireAggressive(group)
    local names = REMOTE_GROUPS[group]
    if not names then return end
    for _, name in ipairs(names) do
        local r = RemoteCache[name] or ReplicatedStorage:FindFirstChild(name, true)
        if r then
            RemoteCache[name] = r
            pcall(function()
                if r:IsA("RemoteEvent") then r:FireServer()
                else r:InvokeServer() end
            end)
        end
    end
end

local function fireWithArgs(group, ...)
    return fireGroup(group, ...)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [09] LEADERSTAT MONITOR (Lines 801-880)
-- ═══════════════════════════════════════════════════════════════════════
local function getLeaderstats()
    return LocalPlayer:FindFirstChild("leaderstats")
end

local function scanStats()
    local ls = getLeaderstats()
    if not ls then return {} end
    local out = {}
    for _, v in ipairs(ls:GetChildren()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue") then
            out[v.Name] = v.Value
        end
    end
    return out
end

local function updateStateFromStats()
    local stats = scanStats()
    for k, v in pairs(stats) do
        local kl = k:lower()
        if kl:find("scrue") or kl:find("money") or kl:find("coin") then
            State.Scrue = v
        elseif kl:find("level") then
            State.Level = v
        elseif kl:find("kill") then
            State.Killed = v
        elseif kl:find("win") then
            State.Wins = v
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- [10] NOTIFICATION SYSTEM (Lines 881-980)
-- ═══════════════════════════════════════════════════════════════════════
local nGui = U.mk("ScreenGui", {Name = "BMUNotify", ResetOnSpawn = false, Parent = PlayerGui})

local notifyStack = {}

local function notify(title, msg, color, dur)
    color = color or C.Cyan
    dur = dur or 3

    local f = U.mk("Frame", {
        Size = UDim2.new(0, 280, 0, 62),
        Position = UDim2.new(1, 12, 0, 12),
        BackgroundColor3 = C.Black2,
        BackgroundTransparency = 0.15,
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
        Size = UDim2.new(1, -24, 0, 20),
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
        Size = UDim2.new(1, -24, 0, 26),
        Position = UDim2.new(0, 16, 0, 30),
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

    U.tw(f, {Position = UDim2.new(1, -292, 0, 12)}, 0.4, Enum.EasingStyle.Back)
    table.insert(notifyStack, f)

    task.delay(dur, function()
        if f and f.Parent then
            U.tw(f, {Position = UDim2.new(1, 12, 0, 12), BackgroundTransparency = 1}, 0.3)
            task.wait(0.35)
            for i, n in ipairs(notifyStack) do
                if n == f then table.remove(notifyStack, i); break end
            end
            f:Destroy()
        end
    end)
end

local function notifyClear()
    for _, f in ipairs(notifyStack) do
        if f and f.Parent then f:Destroy() end
    end
    notifyStack = {}
end

-- ═══════════════════════════════════════════════════════════════════════
-- [11] ANTI-AFK SYSTEM (MULTI METHOD) (Lines 981-1120)
-- ═══════════════════════════════════════════════════════════════════════
local AntiAFK = {
    active      = true,
    methodIdle  = true,
    methodJump  = true,
    methodMove  = true,
    methodChat  = false,
    idleCount   = 0,
    _conns      = {},
    _lastJump   = 0,
    _lastMove   = 0,
}

-- METHOD 1: VirtualUser (paling reliable)
if AntiAFK.methodIdle then
    local conn = LocalPlayer.Idled:Connect(function()
        if not State.AntiAFK then return end
        AntiAFK.idleCount = AntiAFK.idleCount + 1
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        Log.info("Anti-AFK (VirtualUser) triggered #" .. AntiAFK.idleCount)
    end)
    table.insert(AntiAFK._conns, conn)
end

-- METHOD 2: Auto Jump (heartbeat)
task.spawn(function()
    while true do
        task.wait(15)
        if State.AntiAFK and AntiAFK.methodJump then
            if tick() - AntiAFK._lastJump > 14 then
                local h = getHum()
                if h then
                    pcall(function()
                        h.Jump = true
                    end)
                    AntiAFK._lastJump = tick()
                end
            end
        end
    end
end)

-- METHOD 3: Slight Move (walking pulse)
task.spawn(function()
    while true do
        task.wait(20)
        if State.AntiAFK and AntiAFK.methodMove then
            if tick() - AntiAFK._lastMove > 19 then
                local root = getRoot()
                if root then
                    pcall(function()
                        local offset = Vector3.new(
                            math.random(-1, 1) * 0.5,
                            0,
                            math.random(-1, 1) * 0.5
                        )
                        root.CFrame = root.CFrame + offset
                    end)
                    AntiAFK._lastMove = tick()
                end
            end
        end
    end
end)

-- METHOD 4: Chat pulse (opsional)
task.spawn(function()
    while true do
        task.wait(60)
        if State.AntiAFK and AntiAFK.methodChat then
            pcall(function()
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
                    :FireServer(".", "All")
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [12] MOVEMENT CORE (Lines 1121-1280)
-- ═══════════════════════════════════════════════════════════════════════
local function moveInstant(pos)
    local root = getRoot()
    if not root then return false end
    root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    return true
end

local function moveTween(pos, dur)
    local root = getRoot()
    if not root then return false end
    local goal = {CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))}
    local tw = TweenService:Create(root, TweenInfo.new(dur or 0.4, Enum.EasingStyle.Linear), goal)
    tw:Play()
    tw.Completed:Wait()
    return true
end

local function moveToSpawn()
    local sp = Workspace:FindFirstChildOfClass("SpawnLocation")
    if sp then moveInstant(sp.Position) end
end

-- ═══════════════════════════════════════════════════════════════════════
-- [13] FLY SYSTEM (Lines 1281-1380)
-- ═══════════════════════════════════════════════════════════════════════
local function flyEnable()
    if State._flyBV then return end
    local root = getRoot()
    if not root then return end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "BMUFlyBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.zero
    bv.Parent = root
    State._flyBV = bv

    local bg = Instance.new("BodyGyro")
    bg.Name = "BMUFlyBG"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 1000
    bg.D = 50
    bg.Parent = root
    State._flyBG = bg

    Log.info("Fly enabled")
end

local function flyDisable()
    if State._flyBV then State._flyBV:Destroy(); State._flyBV = nil end
    if State._flyBG then State._flyBG:Destroy(); State._flyBG = nil end
    Log.info("Fly disabled")
end

local function flyUpdate()
    if not State.Fly or not State._flyBV then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local mv = Vector3.zero

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then mv = mv - Vector3.new(0, 1, 0) end

    if mv.Magnitude > 0 then mv = mv.Unit * State.FlySpeed end
    State._flyBV.Velocity = mv
    State._flyBG.CFrame = cam.CFrame
end

-- ═══════════════════════════════════════════════════════════════════════
-- [14] ANTI-STUCK (Lines 1381-1420)
-- ═══════════════════════════════════════════════════════════════════════
local function antiStuck()
    local root = getRoot()
    if not root then return end
    local now = root.Position
    if U.dist(now, State._lastPos) < 1.5 then
        State._stuck = State._stuck + 1
        if State._stuck >= 3 then
            local offset = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
            root.CFrame = root.CFrame + offset
            State._stuck = 0
            Log.warn("Anti-stuck triggered")
        end
    else
        State._stuck = 0
    end
    State._lastPos = now
end

-- ═══════════════════════════════════════════════════════════════════════
-- [15] VISUAL MANAGER (Lines 1421-1480)
-- ═══════════════════════════════════════════════════════════════════════
local function setFullbright(on)
    if on then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = true
    end
end

local function setLowGraphics(on)
    pcall(function()
        if on then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [16] AGGRESSIVE FARM LOOP (Lines 1481-1620)
-- ═══════════════════════════════════════════════════════════════════════
local farmThread = nil
local farmLoopCount = 0

local function farmTick()
    farmLoopCount = farmLoopCount + 1

    if not isAlive() then
        State.Status = "Respawn..."
        State.DeathStreak = State.DeathStreak + 1

        if State.AutoRevive and tick() - State._lastRevive > 2 then
            fireGroup("Revive")
            State._lastRevive = tick()
            State.Revived = State.Revived + 1
        end

        if State.HopOnDeadStreak and State.DeathStreak >= 5 then
            State.DeathStreak = 0
            task.spawn(function() doHop() end)
        end
        return
    end

    State.DeathStreak = 0
    State.Status = "Farming"

    -- === ATTACK (aggressive) ===
    if State.AutoAttack then
        if tick() - State._lastAttack > State.AttackRate then
            fireGroup("Attack")
            State._lastAttack = tick()
            State.Hits = State.Hits + 1
        end
    end

    -- === PARRY (aggressive) ===
    if State.AutoParry then
        if tick() - State._lastParry > State.ParryRate then
            fireGroup("Parry")
            State._lastParry = tick()
            State.Parries = State.Parries + 1
        end
    end

    -- === GENERATOR (aggressive) ===
    if State.AutoGenerator then
        fireGroup("Generator")
        if State.AutoSkillCheck then
            fireGroup("SkillCheck")
            State.Skills = State.Skills + 1
        end
        State.Gens = State.Gens + 1
    end

    -- === HEAL ===
    if State.AutoHeal and healthPct() < 60 then
        fireGroup("Heal")
    end

    -- === SAVE ===
    if State.AutoSave then
        fireGroup("Save")
        State.Saved = State.Saved + 1
    end

    -- === SPRINT ===
    if State.AutoSprint then
        fireGroup("Sprint")
    end

    -- === INTERACT ===
    fireGroup("Interact")

    -- === COLLECT ===
    if State.AutoCollect then
        fireGroup("Collect")
    end

    -- === MAIN FARM ===
    fireGroup("Farm")
    State.Farmed = State.Farmed + 1

    -- === UPDATE STATS ===
    updateStateFromStats()
    antiStuck()

    -- === AUTO ESCAPE ===
    if State.AutoEscape and tick() - State._lastEscape > 5 then
        State.Status = "Escaping"
        notify("Escape", "Triggered", C.Yellow, 2)
        fireGroup("Escape")
        State._lastEscape = tick()
        State.Escaped = State.Escaped + 1

        task.wait(2)

        if State.HopAfterEscape then
            State.Status = "Hopping"
            task.spawn(function() doHop() end)
            task.wait(6)
        elseif State.AutoNext then
            State.Status = "Next round"
            fireGroup("NextGame")
            State.NextRound = State.NextRound + 1
            task.wait(3)
        end
    end

    -- === AUTO CHAT ===
    if State.AutoChat and tick() - State._lastChat > 45 then
        pcall(function()
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
                :FireServer(State.ChatMessage, "All")
        end)
        State._lastChat = tick()
    end
end

local function farmLoop()
    while State.AutoFarm do
        local ok, err = pcall(farmTick)
        if not ok then
            Log.err("farmTick error: " .. tostring(err))
        end
        task.wait(State.Delay)
    end
    State.Status = "Idle"
end

local function startFarm()
    if farmThread then return end
    State.AutoFarm = true
    State.SessionStart = tick()
    farmThread = task.spawn(farmLoop)
    notify("Farm", "Aggressive mode ON", C.Green, 3)
    Log.info("Farm started (aggressive)")
end

local function stopFarm()
    State.AutoFarm = false
    farmThread = nil
    notify("Farm", "Stopped", C.Red)
    Log.info("Farm stopped")
end

-- ═══════════════════════════════════════════════════════════════════════
-- [17] SERVER HOP (Lines 1621-1780)
-- ═══════════════════════════════════════════════════════════════════════
local Hop = {
    _lastHop = 0,
    _history = {},
    _blacklist = {},
    _searching = false,
}

local function getPlayerCount() return #Players:GetPlayers() end

local function httpGet(url)
    local req = (syn and syn.request)
        or (http and http.request)
        or http_request
        or (fluxus and fluxus.request)
    if not req then return nil end
    local ok, res = pcall(function()
        return req({
            Url = url,
            Method = "GET",
            Headers = {["Accept"] = "application/json", ["User-Agent"] = "Roblox/WinInet"},
        })
    end)
    if not ok or not res or not res.Body then return nil end
    local ok2, data = pcall(function()
        return HttpService:JSONDecode(res.Body)
    end)
    return ok2 and data or nil
end

local function fetchServers(cursor)
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
        game.PlaceId,
        cursor and ("&cursor=" .. cursor) or ""
    )
    return httpGet(url)
end

local function pickServer()
    local list = {}
    local cursor, pages = nil, 0
    while pages < 3 do
        local data = fetchServers(cursor)
        if not data or not data.data then break end
        for _, srv in ipairs(data.data) do
            local id = srv.id
            local playing = srv.playing or 0
            if id ~= game.JobId
                and not Hop._blacklist[id]
                and playing >= 0
                and playing <= State.MaxPlayers
                and not U.arrayHas(Hop._history, id) then
                table.insert(list, {id = id, playing = playing, max = srv.maxPlayers or 0})
            end
        end
        cursor = data.nextPageCursor
        if not cursor then break end
        pages = pages + 1
        task.wait(0.3)
    end
    if #list == 0 then return nil end
    table.sort(list, function(a, b)
        if a.playing ~= b.playing then return a.playing < b.playing end
        return a.max > b.max
    end)
    return list[1]
end

function doHop()
    if Hop._searching then return false end
    if tick() - Hop._lastHop < State.HopCooldown then
        notify("Hop", "Cooldown aktif", C.Yellow, 2)
        return false
    end

    Hop._searching = true
    Hop._lastHop = tick()
    notify("Server Hop", "Nyari server kosong...", C.Blue, 3)
    Log.info("[HOP] Searching servers (max " .. State.MaxPlayers .. " players)")

    local best = pickServer()

    if not best then
        Hop._searching = false
        notify("Hop", "Gak nemu, retry dengan max 8", C.Yellow, 3)
        local oldMax = State.MaxPlayers
        State.MaxPlayers = 8
        best = pickServer()
        State.MaxPlayers = oldMax
    end

    if not best then
        Hop._searching = false
        notify("Hop", "Semua server penuh", C.Red, 4)
        return false
    end

    State.HopCount = State.HopCount + 1
    table.insert(Hop._history, best.id)
    if #Hop._history > 50 then table.remove(Hop._history, 1) end

    pcall(function()
        if writefile then
            writefile("BMU_hop.json", HttpService:JSONEncode({
                autoFarm = State.AutoFarm,
                autoEscape = State.AutoEscape,
                hopCount = State.HopCount,
                history = Hop._history,
                ts = os.time(),
            }))
        end
    end)

    notify("Server Hop", string.format("Masuk server %d/%d", best.playing, best.max), C.Green, 3)
    Log.info("[HOP] Joining " .. best.id:sub(1, 8) .. " (" .. best.playing .. "/" .. best.max .. ")")

    Hop._searching = false
    task.wait(1)

    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LocalPlayer)
    end)

    return true
end

-- Auto restore state setelah hop
task.spawn(function()
    task.wait(3)
    local ok, content = pcall(function()
        if isfile and isfile("BMU_hop.json") then
            return readfile("BMU_hop.json")
        end
    end)
    if not ok or not content then return end

    local ok2, data = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    if not ok2 or type(data) ~= "table" then return end

    if data.history then Hop._history = data.history end
    if data.hopCount then State.HopCount = data.hopCount end

    if data.ts and (os.time() - data.ts) > 120 then
        pcall(function()
            if delfile then delfile("BMU_hop.json") end
        end)
        return
    end

    if data.autoFarm then
        task.wait(2)
        startFarm()
        notify("Restore", "Farm resumed after hop", C.Green, 4)
    end

    pcall(function()
        if delfile then delfile("BMU_hop.json") end
    end)
end)

-- Auto hop monitor
task.spawn(function()
    while true do
        task.wait(5)
        if State.AutoFarm and State.HopOnFull then
            if getPlayerCount() > State.MaxPlayers then
                Log.warn("Server crowded: " .. getPlayerCount() .. "/" .. State.MaxPlayers)
                task.spawn(function() doHop() end)
                task.wait(10)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [18] HEARTBEAT LOOP (Lines 1781-1830)
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.3)
        local hum = getHum()
        if hum then
            if State.SpeedHack then hum.WalkSpeed = State.SpeedValue end
            if State.InfiniteJump then hum.JumpPower = State.JumpPower end
        end
        if State.NoClip and LocalPlayer.Character then
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end
        if State.Fly then flyUpdate() end
        if State.SessionStart > 0 then State.Uptime = tick() - State.SessionStart end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [19] UI COMPONENT - SECTION (Lines 1831-1860)
-- ═══════════════════════════════════════════════════════════════════════
local function mSec(par, txt, col)
    col = col or C.Cyan
    local h = U.mk("Frame", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Parent = par})
    U.mk("Frame", {
        Size = UDim2.new(0, 3, 0, 12),
        Position = UDim2.new(0, 0, 0.5, -6),
        BackgroundColor3 = col,
        BorderSizePixel = 0,
        Parent = h,
    })
    U.mk("TextLabel", {
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = txt,
        TextColor3 = col,
        Font = F.Bold,
        TextSize = FS.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = h,
    })
end

-- ═══════════════════════════════════════════════════════════════════════
-- [20] UI COMPONENT - TOGGLE (Lines 1861-1940)
-- ═══════════════════════════════════════════════════════════════════════
local function mToggle(par, txt, key, cb)
    local h = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = C.Black3,
        BorderSizePixel = 0,
        Parent = par,
    })
    U.rc(h, 8)
    U.st(h, C.Black5, 1)

    U.mk("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = txt,
        TextColor3 = C.OffWhite,
        Font = F.Med,
        TextSize = FS.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = h,
    })

    local tr = U.mk("Frame", {
        Size = UDim2.new(0, 42, 0, 22),
        Position = UDim2.new(1, -54, 0.5, -11),
        BackgroundColor3 = State[key] and C.GreenDim or C.Black5,
        BorderSizePixel = 0,
        Parent = h,
    })
    U.rc(tr, 11)

    local dot = U.mk("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = State[key] and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = C.White,
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
        State[key] = not State[key]
        local on = State[key]
        U.tw(tr, {BackgroundColor3 = on and C.GreenDim or C.Black5}, 0.2)
        U.tw(dot, {Position = on and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.2)
        if cb then pcall(cb, on) end
    end)

    clk.MouseEnter:Connect(function() U.tw(h, {BackgroundColor3 = C.Black4}, 0.12) end)
    clk.MouseLeave:Connect(function() U.tw(h, {BackgroundColor3 = C.Black3}, 0.12) end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [21] UI COMPONENT - SLIDER (Lines 1941-2050)
-- ═══════════════════════════════════════════════════════════════════════
local function mSlider(par, txt, key, mn, mx, df, sfx)
    sfx = sfx or ""
    local h = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = C.Black3,
        BorderSizePixel = 0,
        Parent = par,
    })
    U.rc(h, 8)
    U.st(h, C.Black5, 1)

    U.mk("TextLabel", {
        Size = UDim2.new(1, -80, 0, 18),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = txt,
        TextColor3 = C.Gray1,
        Font = F.Med,
        TextSize = FS.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = h,
    })

    local vl = U.mk("TextLabel", {
        Size = UDim2.new(0, 70, 0, 18),
        Position = UDim2.new(1, -82, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(df) .. sfx,
        TextColor3 = C.Cyan,
        Font = F.Bold,
        TextSize = FS.Small,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = h,
    })

    local tr = U.mk("TextButton", {
        Size = UDim2.new(1, -24, 0, 8),
        Position = UDim2.new(0, 12, 0, 36),
        BackgroundColor3 = C.Black5,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = h,
    })
    U.rc(tr, 4)

    local pct = (df - mn) / (mx - mn)
    local fl = U.mk("Frame", {
        Size = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = C.Cyan,
        BorderSizePixel = 0,
        Parent = tr,
    })
    U.rc(fl, 4)

    local kn = U.mk("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(pct, -8, 0.5, -8),
        BackgroundColor3 = C.White,
        BorderSizePixel = 0,
        Parent = tr,
    })
    U.rc(kn, 8)
    U.st(kn, C.Cyan, 2)

    local drag = false
    local function upd(i)
        local p = U.clamp((i.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + (mx - mn) * p + 0.5)
        fl.Size = UDim2.new(p, 0, 1, 0)
        kn.Position = UDim2.new(p, -8, 0.5, -8)
        vl.Text = tostring(v) .. sfx
        State[key] = v
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

-- ═══════════════════════════════════════════════════════════════════════
-- [22] UI COMPONENT - BUTTON (Lines 2051-2110)
-- ═══════════════════════════════════════════════════════════════════════
local function mBtn(par, txt, col, cb)
    col = col or C.Cyan
    local b = U.mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = C.Black3,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = par,
    })
    U.rc(b, 8)
    U.st(b, col, 1)

    U.mk("Frame", {
        Size = UDim2.new(0, 3, 0, 18),
        Position = UDim2.new(0, 10, 0.5, -9),
        BackgroundColor3 = col,
        BorderSizePixel = 0,
        Parent = b,
    })

    U.mk("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 22, 0, 0),
        BackgroundTransparency = 1,
        Text = txt,
        TextColor3 = C.OffWhite,
        Font = F.Bold,
        TextSize = FS.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = b,
    })

    b.MouseButton1Click:Connect(function()
        U.tw(b, {BackgroundColor3 = col}, 0.1)
        task.wait(0.1)
        U.tw(b, {BackgroundColor3 = C.Black3}, 0.15)
        if cb then pcall(cb) end
    end)

    b.MouseEnter:Connect(function() U.tw(b, {BackgroundColor3 = C.Black4}, 0.12) end)
    b.MouseLeave:Connect(function() U.tw(b, {BackgroundColor3 = C.Black3}, 0.12) end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [23] UI COMPONENT - ROW (Lines 2111-2150)
-- ═══════════════════════════════════════════════════════════════════════
local function mRow(par, lbl, val, col)
    local r = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Parent = par,
    })
    U.mk("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = lbl,
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
        Text = val,
        TextColor3 = col or C.OffWhite,
        Font = F.Bold,
        TextSize = FS.Small,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = r,
    })
    return v
end

-- ═══════════════════════════════════════════════════════════════════════
-- [24] MAIN UI BUILD (Lines 2151-2600)
-- ═══════════════════════════════════════════════════════════════════════
local function buildUI()
    local Screen = U.mk("ScreenGui", {
        Name = "BMU_UI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    }, PlayerGui)

    -- FAB
    local FAB = U.mk("Frame", {
        Size = UDim2.new(0, UI.FAB, 0, UI.FAB),
        Position = UDim2.new(1, -(UI.FAB + 18), 1, -(UI.FAB + 18)),
        BackgroundColor3 = C.Black2,
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 100,
    }, Screen)
    U.rc(FAB, math.floor(UI.FAB / 2))
    U.st(FAB, C.Cyan, 2)

    local ring = U.mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 98,
        Parent = FAB,
    })
    U.rc(ring, math.floor(UI.FAB / 2))
    local ringSt = U.st(ring, C.Cyan, 1, 0.7)

    task.spawn(function()
        while FAB.Parent do
            ring.Size = UDim2.new(1, 0, 1, 0)
            ring.Position = UDim2.new(0, 0, 0, 0)
            ringSt.Transparency = 0.7
            TweenService:Create(ring, TweenInfo.new(2, Enum.EasingStyle.Linear), {
                Size = UDim2.new(1, 26, 1, 26),
                Position = UDim2.new(0, -13, 0, -13),
            }):Play()
            TweenService:Create(ringSt, TweenInfo.new(2, Enum.EasingStyle.Linear), {
                Transparency = 1,
            }):Play()
            task.wait(2)
        end
    end)

    U.mk("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "VD",
        TextColor3 = C.Cyan,
        Font = F.Black,
        TextSize = math.floor(UI.FAB * 0.34),
        ZIndex = 101,
    }, FAB)

    -- Glow
    local Glow = U.mk("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = C.Cyan,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        ZIndex = 48,
    }, Screen)
    U.rc(Glow, 20)

    -- Panel
    local Panel = U.mk("Frame", {
        Size = UDim2.new(0, UI.PANEL_W, 0, UI.PANEL_H),
        Position = UDim2.new(0.5, -UI.PANEL_W / 2, 0.5, -UI.PANEL_H / 2),
        BackgroundColor3 = C.Black1,
        BorderSizePixel = 0,
        Visible = false,
        Active = true,
        Draggable = true,
        ZIndex = 50,
    }, Screen)
    U.rc(Panel, 16)
    U.st(Panel, C.Black4, 1.5)

    -- Top gradient
    local topBar = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        BackgroundColor3 = C.Cyan,
        BorderSizePixel = 0,
        ZIndex = 52,
    }, Panel)
    U.rc(topBar, 16)
    U.gd(topBar, {
        ColorSequenceKeypoint.new(0, C.Cyan),
        ColorSequenceKeypoint.new(0.5, C.Purple),
        ColorSequenceKeypoint.new(1, C.Cyan),
    }, 0)

    -- Header
    local hdr = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundColor3 = C.Black2,
        BorderSizePixel = 0,
        ZIndex = 51,
    }, Panel)
    U.rc(hdr, 16)
    U.gd(hdr, {
        ColorSequenceKeypoint.new(0, C.Black3),
        ColorSequenceKeypoint.new(1, C.Black1),
    }, 90)

    local logodot = U.mk("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0, 18, 0, 22),
        BackgroundColor3 = C.Cyan,
        BorderSizePixel = 0,
        ZIndex = 53,
    }, Panel)
    U.rc(logodot, 5)

    task.spawn(function()
        while logodot.Parent do
            U.tw(logodot, {BackgroundColor3 = C.Purple}, 0.8)
            task.wait(0.8)
            U.tw(logodot, {BackgroundColor3 = C.Cyan}, 0.8)
            task.wait(0.8)
        end
    end)

    U.mk("TextLabel", {
        Size = UDim2.new(1, -100, 0, 20),
        Position = UDim2.new(0, 34, 0, 14),
        BackgroundTransparency = 1,
        Text = "VIOLENCE DISTRICT",
        TextColor3 = C.White,
        Font = F.Black,
        TextSize = FS.H2,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 53,
    }, Panel)

    U.mk("TextLabel", {
        Size = UDim2.new(1, -100, 0, 14),
        Position = UDim2.new(0, 34, 0, 32),
        BackgroundTransparency = 1,
        Text = "AGGRESSIVE v" .. CFG.VERSION .. " | by " .. CFG.CREATOR,
        TextColor3 = C.Gray2,
        Font = F.Norm,
        TextSize = FS.Micro,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 53,
    }, Panel)

    local closeBtn = U.mk("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -46, 0, 14),
        BackgroundColor3 = C.Black3,
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = C.Red,
        Font = F.Bold,
        TextSize = FS.H3,
        AutoButtonColor = false,
        ZIndex = 54,
    }, Panel)
    U.rc(closeBtn, 8)
    U.st(closeBtn, C.Black4, 1)

    closeBtn.MouseButton1Click:Connect(function()
        U.tw(Panel, {Size = UDim2.new(0, 0, 0, 0)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        U.tw(Glow, {Size = UDim2.new(0, 0, 0, 0)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.22)
        Panel.Visible = false
        Panel.Size = UDim2.new(0, UI.PANEL_W, 0, UI.PANEL_H)
        State._panelVisible = false
    end)

    closeBtn.MouseEnter:Connect(function() U.tw(closeBtn, {BackgroundColor3 = C.RedDim}, 0.15) end)
    closeBtn.MouseLeave:Connect(function() U.tw(closeBtn, {BackgroundColor3 = C.Black3}, 0.15) end)

    -- Divider
    U.mk("Frame", {
        Size = UDim2.new(1, -32, 0, 1),
        Position = UDim2.new(0, 16, 0, 56),
        BackgroundColor3 = C.Black4,
        BorderSizePixel = 0,
        ZIndex = 52,
    }, Panel)

    -- Stats grid
    local SR1 = U.mk("Frame", {
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.new(0, 12, 0, 66),
        BackgroundTransparency = 1,
    }, Panel)
    local l1 = U.ls(SR1, 6)
    l1.FillDirection = Enum.FillDirection.Horizontal

    local SR2 = U.mk("Frame", {
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.new(0, 12, 0, 100),
        BackgroundTransparency = 1,
    }, Panel)
    local l2 = U.ls(SR2, 6)
    l2.FillDirection = Enum.FillDirection.Horizontal

    local SC = {}
    local function statPair(row, l1v, v1, c1, l2v, v2, c2)
        local c1f = U.mk("Frame", {
            Size = UDim2.new(0.5, -3, 1, 0),
            BackgroundColor3 = C.Black3,
            BorderSizePixel = 0,
        }, row)
        U.rc(c1f, 8)
        U.st(c1f, C.Black5, 1)
        U.mk("Frame", {
            Size = UDim2.new(0, 2, 0.5, 0),
            Position = UDim2.new(0, 0, 0.25, 0),
            BackgroundColor3 = c1,
            BorderSizePixel = 0,
        }, c1f)
        U.mk("TextLabel", {
            Size = UDim2.new(1, -12, 0, 10),
            Position = UDim2.new(0, 8, 0, 3),
            BackgroundTransparency = 1,
            Text = l1v,
            TextColor3 = C.Gray2,
            Font = F.Bold,
            TextSize = FS.Micro,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, c1f)
        local v1l = U.mk("TextLabel", {
            Size = UDim2.new(1, -12, 0, 14),
            Position = UDim2.new(0, 8, 0, 14),
            BackgroundTransparency = 1,
            Text = tostring(v1),
            TextColor3 = c1,
            Font = F.Black,
            TextSize = FS.Body,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, c1f)

        local c2f = U.mk("Frame", {
            Size = UDim2.new(0.5, -3, 1, 0),
            BackgroundColor3 = C.Black3,
            BorderSizePixel = 0,
        }, row)
        U.rc(c2f, 8)
        U.st(c2f, C.Black5, 1)
        U.mk("Frame", {
            Size = UDim2.new(0, 2, 0.5, 0),
            Position = UDim2.new(0, 0, 0.25, 0),
            BackgroundColor3 = c2,
            BorderSizePixel = 0,
        }, c2f)
        U.mk("TextLabel", {
            Size = UDim2.new(1, -12, 0, 10),
            Position = UDim2.new(0, 8, 0, 3),
            BackgroundTransparency = 1,
            Text = l2v,
            TextColor3 = C.Gray2,
            Font = F.Bold,
            TextSize = FS.Micro,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, c2f)
        local v2l = U.mk("TextLabel", {
            Size = UDim2.new(1, -12, 0, 14),
            Position = UDim2.new(0, 8, 0, 14),
            BackgroundTransparency = 1,
            Text = tostring(v2),
            TextColor3 = c2,
            Font = F.Black,
            TextSize = FS.Body,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, c2f)

        return v1l, v2l
    end

    SC.Farmed, SC.Escaped = statPair(SR1, "FARMED", "0", C.Green, "ESCAPED", "0", C.Yellow)
    SC.Parries, SC.Hits = statPair(SR2, "PARRIES", "0", C.Pink, "HITS", "0", C.Red)

    -- Status bar
    local SB = U.mk("Frame", {
        Size = UDim2.new(1, -24, 0, 28),
        Position = UDim2.new(0, 12, 0, 138),
        BackgroundColor3 = C.Black3,
        BorderSizePixel = 0,
    }, Panel)
    U.rc(SB, 8)
    U.st(SB, C.Black5, 1)

    local sDot = U.mk("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0, 10, 0.5, -4),
        BackgroundColor3 = C.Gray2,
        BorderSizePixel = 0,
    }, SB)
    U.rc(sDot, 4)

    local sLbl = U.mk("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = "Status: Idle",
        TextColor3 = C.Cyan,
        Font = F.Bold,
        TextSize = FS.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, SB)

    -- Tabs
    local TB = U.mk("Frame", {
        Size = UDim2.new(1, -24, 0, 34),
        Position = UDim2.new(0, 12, 0, 172),
        BackgroundColor3 = C.Black2,
        BorderSizePixel = 0,
    }, Panel)
    U.rc(TB, 8)
    U.st(TB, C.Black4, 1)

    local TH = U.mk("Frame", {
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0, 3, 0, 3),
        BackgroundTransparency = 1,
    }, TB)
    local thLs = U.ls(TH, 3)
    thLs.FillDirection = Enum.FillDirection.Horizontal

    local tabNames = {"FARM", "HOP", "MISC", "INFO"}
    local tabBtns, pages = {}, {}

    local Content = U.mk("ScrollingFrame", {
        Size = UDim2.new(1, -24, 1, -218),
        Position = UDim2.new(0, 12, 0, 210),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.Cyan,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, Panel)

    for i, name in ipairs(tabNames) do
        local b = U.mk("TextButton", {
            Size = UDim2.new(1 / #tabNames, -2, 1, 0),
            BackgroundColor3 = (i == 1) and C.Black4 or C.Black2,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = (i == 1) and C.White or C.Gray2,
            Font = F.Bold,
            TextSize = FS.Small,
            AutoButtonColor = false,
        }, TH)
        U.rc(b, 6)
        table.insert(tabBtns, b)

        local p = U.mk("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = (i == 1),
        }, Content)
        U.ls(p, 6)
        pages[name] = p

        b.MouseButton1Click:Connect(function()
            for _, o in ipairs(tabBtns) do
                U.tw(o, {BackgroundColor3 = C.Black2, TextColor3 = C.Gray2}, 0.15)
            end
            U.tw(b, {BackgroundColor3 = C.Black4, TextColor3 = C.White}, 0.15)
            for _, pg in pairs(pages) do pg.Visible = false end
            p.Visible = true
            State._currentTab = name
            p.Position = UDim2.new(0, 8, 0, 0)
            U.tw(p, {Position = UDim2.new(0, 0, 0, 0)}, 0.2)
        end)
    end

    -- ═══════════ FARM PAGE ═══════════
    mSec(pages["FARM"], "FARM CONTROL", C.Cyan)
    mToggle(pages["FARM"], "Auto Farm", "AutoFarm", function(v)
        if v then startFarm() else stopFarm() end
    end)
    mToggle(pages["FARM"], "Auto Attack", "AutoAttack")
    mToggle(pages["FARM"], "Auto Parry", "AutoParry")
    mToggle(pages["FARM"], "Auto Generator", "AutoGenerator")
    mToggle(pages["FARM"], "Auto Skill Check", "AutoSkillCheck")
    mToggle(pages["FARM"], "Auto Heal", "AutoHeal")
    mToggle(pages["FARM"], "Auto Save", "AutoSave")
    mToggle(pages["FARM"], "Auto Revive", "AutoRevive")
    mToggle(pages["FARM"], "Auto Collect", "AutoCollect")
    mToggle(pages["FARM"], "Auto Sprint", "AutoSprint")
    mToggle(pages["FARM"], "Auto Chat", "AutoChat")

    mSec(pages["FARM"], "ESCAPE SYSTEM", C.Yellow)
    mToggle(pages["FARM"], "Auto Escape", "AutoEscape")
    mToggle(pages["FARM"], "Auto Next (in-server)", "AutoNext")

    mSec(pages["FARM"], "QUICK ACTION", C.Green)
    mBtn(pages["FARM"], "Start Aggressive Farm", C.Green, startFarm)
    mBtn(pages["FARM"], "Stop Farm", C.Red, stopFarm)
    mBtn(pages["FARM"], "Force Escape", C.Yellow, function()
        fireGroup("Escape")
        State.Escaped = State.Escaped + 1
        notify("Escape", "Force trigger", C.Yellow)
    end)

    mSec(pages["FARM"], "TIMING", C.Cyan)
    mSlider(pages["FARM"], "Loop Delay", "Delay", 0.1, 3, 0.5, "s")
    mSlider(pages["FARM"], "Attack Rate", "AttackRate", 0.1, 2, 0.35, "s")
    mSlider(pages["FARM"], "Parry Rate", "ParryRate", 0.1, 1, 0.2, "s")

    -- ═══════════ HOP PAGE ═══════════
    mSec(pages["HOP"], "SERVER HOP", C.Blue)
    mToggle(pages["HOP"], "Auto Hop on Full", "HopOnFull")
    mToggle(pages["HOP"], "Hop After Escape", "HopAfterEscape")
    mToggle(pages["HOP"], "Hop on Death Streak", "HopOnDeadStreak")

    mSec(pages["HOP"], "TARGET FILTER", C.Purple)
    mSlider(pages["HOP"], "Max Players", "MaxPlayers", 1, 20, 4)
    mSlider(pages["HOP"], "Hop Cooldown", "HopCooldown", 5, 60, 15, "s")

    mSec(pages["HOP"], "MANUAL ACTION", C.Cyan)
    mBtn(pages["HOP"], "Find Server Now", C.Blue, doHop)
    mBtn(pages["HOP"], "Blacklist Current", C.Red, function()
        Hop._blacklist[game.JobId] = true
        notify("Blacklist", "Current server blocked", C.Red)
    end)
    mBtn(pages["HOP"], "Clear History", C.Yellow, function()
        Hop._history = {}
        Hop._blacklist = {}
        notify("Cleared", "Hop data reset", C.Yellow)
    end)

    -- ═══════════ MISC PAGE ═══════════
    mSec(pages["MISC"], "MOVEMENT", C.Cyan)
    mToggle(pages["MISC"], "Speed Hack", "SpeedHack")
    mSlider(pages["MISC"], "Walk Speed", "SpeedValue", 16, 200, 24)
    mToggle(pages["MISC"], "Infinite Jump", "InfiniteJump")
    mSlider(pages["MISC"], "Jump Power", "JumpPower", 50, 300, 55)
    mToggle(pages["MISC"], "No Clip", "NoClip")
    mToggle(pages["MISC"], "Fly", "Fly", function(v)
        if v then flyEnable() else flyDisable() end
    end)
    mSlider(pages["MISC"], "Fly Speed", "FlySpeed", 20, 250, 65)

    mSec(pages["MISC"], "VISUAL", C.Pink)
    mToggle(pages["MISC"], "Fullbright", "Fullbright", function(v)
        setFullbright(v)
    end)
    mToggle(pages["MISC"], "Low Graphics", "LowGraphics", function(v)
        setLowGraphics(v)
    end)

    mSec(pages["MISC"], "SAFETY", C.Green)
    mToggle(pages["MISC"], "Anti-AFK", "AntiAFK")
    mToggle(pages["MISC"], "Anti Stun", "AntiStun")
    mToggle(pages["MISC"], "Anti Blind", "AntiBlind")
    mToggle(pages["MISC"], "Instant Heal", "InstantHeal")

    mSec(pages["MISC"], "UTILITY", C.Yellow)
    mBtn(pages["MISC"], "Reset Stats", C.Red, function()
        State.Farmed = 0
        State.Escaped = 0
        State.NextRound = 0
        State.Hits = 0
        State.Parries = 0
        State.Gens = 0
        State.Saved = 0
        State.Revived = 0
        notify("Stats", "Reset", C.Red)
    end)
    mBtn(pages["MISC"], "Clear Notifications", C.Cyan, notifyClear)
    mBtn(pages["MISC"], "Rescan Remotes", C.Purple, function()
        RemoteCache = {}
        fullScanRemotes()
        notify("Remotes", "Rescanned: " .. U.count(RemoteCache) .. " cached", C.Purple)
    end)
    mBtn(pages["MISC"], "Teleport Spawn", C.Blue, moveToSpawn)

    -- ═══════════ INFO PAGE ═══════════
    mSec(pages["INFO"], "SCRIPT", C.Cyan)
    local IB = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 170),
        BackgroundColor3 = C.Black3,
        BorderSizePixel = 0,
    }, pages["INFO"])
    U.rc(IB, 8)
    U.st(IB, C.Black5, 1)

    local IBi = U.mk("Frame", {
        Size = UDim2.new(1, -24, 1, -16),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
    }, IB)
    U.ls(IBi, 3)
    mRow(IBi, "Name", CFG.NAME, C.Cyan)
    mRow(IBi, "Version", "v" .. CFG.VERSION, C.Green)
    mRow(IBi, "Tag", CFG.TAG, C.Purple)
    mRow(IBi, "Creator", CFG.CREATOR, C.Pink)
    mRow(IBi, "Device", DEVICE.MOBILE and "Mobile" or (DEVICE.TABLET and "Tablet" or "PC"), C.Gold)
    mRow(IBi, "Place ID", tostring(game.PlaceId), C.Blue)
    mRow(IBi, "Job ID", game.JobId:sub(1, 12) .. "...", C.Yellow)

    mSec(pages["INFO"], "LIVE DATA", C.Green)
    local LB = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 200),
        BackgroundColor3 = C.Black3,
        BorderSizePixel = 0,
    }, pages["INFO"])
    U.rc(LB, 8)
    U.st(LB, C.Black5, 1)

    local LBi = U.mk("Frame", {
        Size = UDim2.new(1, -24, 1, -16),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
    }, LB)
    U.ls(LBi, 3)
    local IF = mRow(LBi, "Farm Count", "0", C.Green)
    local IE = mRow(LBi, "Escape Count", "0", C.Yellow)
    local IH = mRow(LBi, "Hit Count", "0", C.Red)
    local IP = mRow(LBi, "Parry Count", "0", C.Pink)
    local IG = mRow(LBi, "Generator", "0", C.Purple)
    local IS = mRow(LBi, "Skill Check", "0", C.Cyan)
    local IRev = mRow(LBi, "Revived", "0", C.Blue)
    local IHop = mRow(LBi, "Hop Count", "0", C.Orange)
    local IPlay = mRow(LBi, "Players", "0/0", C.Gold)
    local IUp = mRow(LBi, "Uptime", "00:00", C.White)

    mSec(pages["INFO"], "CHAT COMMANDS", C.Yellow)
    local CB = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 190),
        BackgroundColor3 = C.Black3,
        BorderSizePixel = 0,
    }, pages["INFO"])
    U.rc(CB, 8)
    U.st(CB, C.Black5, 1)

    local CBi = U.mk("Frame", {
        Size = UDim2.new(1, -24, 1, -16),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
    }, CB)
    U.ls(CBi, 3)
    mRow(CBi, "!start / !farm", "Mulai farm", C.Green)
    mRow(CBi, "!stop", "Stop farm", C.Red)
    mRow(CBi, "!hop", "Manual hop", C.Blue)
    mRow(CBi, "!escape", "Force escape", C.Yellow)
    mRow(CBi, "!stats", "Show stats", C.Cyan)
    mRow(CBi, "!reset", "Reset stats", C.Red)
    mRow(CBi, "!scan", "Rescan remotes", C.Purple)

    -- FAB toggle
    local fabBtn = U.mk("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 102,
    }, FAB)

    local function togglePanel()
        Panel.Visible = not Panel.Visible
        State._panelVisible = Panel.Visible
        if Panel.Visible then
            Panel.Size = UDim2.new(0, 0, 0, 0)
            Glow.Size = UDim2.new(0, 0, 0, 0)
            U.tw(Panel, {Size = UDim2.new(0, UI.PANEL_W, 0, UI.PANEL_H)}, 0.28, Enum.EasingStyle.Back)
            U.tw(Glow, {Size = UDim2.new(0, UI.PANEL_W + 20, 0, UI.PANEL_H + 20)}, 0.28, Enum.EasingStyle.Back)
        end
    end

    fabBtn.MouseButton1Click:Connect(togglePanel)
    _G.__BMU_Toggle = togglePanel

    -- Live update loop
    task.spawn(function()
        while true do
            task.wait(0.25)
            SC.Farmed.Text = tostring(State.Farmed)
            SC.Escaped.Text = tostring(State.Escaped)
            SC.Parries.Text = tostring(State.Parries)
            SC.Hits.Text = tostring(State.Hits)

            sLbl.Text = "Status: " .. State.Status
            if State.AutoFarm then
                sDot.BackgroundColor3 = C.Green
                sLbl.TextColor3 = C.Green
            else
                sDot.BackgroundColor3 = C.Gray2
                sLbl.TextColor3 = C.Cyan
            end

            IF.Text = tostring(State.Farmed)
            IE.Text = tostring(State.Escaped)
            IH.Text = tostring(State.Hits)
            IP.Text = tostring(State.Parries)
            IG.Text = tostring(State.Gens)
            IS.Text = tostring(State.Skills)
            IRev.Text = tostring(State.Revived)
            IHop.Text = tostring(State.HopCount)
            IPlay.Text = getPlayerCount() .. "/" .. Players.MaxPlayers
            IUp.Text = U.fmt(State.Uptime)

            local cur = pages[State._currentTab]
            if cur then
                Content.CanvasSize = UDim2.new(0, 0, 0, cur.AbsoluteSize.Y + 30)
            end
        end
    end)

    return Screen
end

-- ═══════════════════════════════════════════════════════════════════════
-- [25] KEYBIND SYSTEM (Lines 2601-2680)
-- ═══════════════════════════════════════════════════════════════════════
local Keybinds = {
    toggleUI = Enum.KeyCode.RightControl,
    farm = Enum.KeyCode.F1,
    spawn = Enum.KeyCode.F2,
    attack = Enum.KeyCode.F3,
    parry = Enum.KeyCode.F4,
    escape = Enum.KeyCode.F5,
    hop = Enum.KeyCode.F6,
    panic = Enum.KeyCode.F7,
    enabled = true,
}

local function panicMode()
    State.AutoFarm = false
    State.AutoEscape = false
    State.AutoNext = false
    State.AutoAttack = false
    State.AutoParry = false
    State.AutoGenerator = false
    State.SpeedHack = false
    State.InfiniteJump = false
    State.NoClip = false
    State.Fly = false
    flyDisable()
    local hum = getHum()
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
    notify("PANIC", "All stopped", C.Red, 4)
    Log.warn("PANIC MODE ACTIVATED")
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not Keybinds.enabled then return end
    local k = input.KeyCode

    if k == Keybinds.toggleUI then
        if _G.__BMU_Toggle then _G.__BMU_Toggle() end
    elseif k == Keybinds.farm then
        if State.AutoFarm then stopFarm() else startFarm() end
    elseif k == Keybinds.spawn then
        moveToSpawn()
    elseif k == Keybinds.attack then
        fireGroup("Attack")
        State.Hits = State.Hits + 1
    elseif k == Keybinds.parry then
        fireGroup("Parry")
        State.Parries = State.Parries + 1
    elseif k == Keybinds.escape then
        fireGroup("Escape")
        State.Escaped = State.Escaped + 1
    elseif k == Keybinds.hop then
        task.spawn(function() doHop() end)
    elseif k == Keybinds.panic then
        panicMode()
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [26] SESSION MANAGER (Lines 2681-2740)
-- ═══════════════════════════════════════════════════════════════════════
local Session = {
    Start = tick(),
    EggsAtStart = 0,
    History = {},
}

local function sessionEggs() return State.Farmed - Session.EggsAtStart end

local function sessionEPM()
    local elapsed = (tick() - Session.Start) / 60
    if elapsed <= 0 then return 0 end
    return U.round(sessionEggs() / elapsed, 2)
end

local function sessionReport()
    local r = {
        eggs = sessionEggs(),
        esc = State.Escaped,
        hits = State.Hits,
        parries = State.Parries,
        epm = sessionEPM(),
        duration = U.fmt(tick() - Session.Start),
    }
    table.insert(Session.History, r)
    if #Session.History > 20 then table.remove(Session.History, 1) end
    return r
end

-- ═══════════════════════════════════════════════════════════════════════
-- [27] CHAT COMMANDS (Lines 2741-2820)
-- ═══════════════════════════════════════════════════════════════════════
LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    local args = {}
    for w in msg:gmatch("%S+") do table.insert(args, w) end
    local cmd = args[1]

    if cmd == "!start" or cmd == "!farm" then
        startFarm()
    elseif cmd == "!stop" then
        stopFarm()
    elseif cmd == "!hop" then
        task.spawn(function() doHop() end)
    elseif cmd == "!escape" then
        fireGroup("Escape")
        State.Escaped = State.Escaped + 1
    elseif cmd == "!next" then
        fireGroup("NextGame")
        State.NextRound = State.NextRound + 1
    elseif cmd == "!stats" then
        notify("Stats", string.format(
            "Farm: %d | Esc: %d | Hits: %d | Parries: %d",
            State.Farmed, State.Escaped, State.Hits, State.Parries
        ), C.Cyan, 5)
    elseif cmd == "!reset" then
        State.Farmed = 0
        State.Escaped = 0
        State.Hits = 0
        State.Parries = 0
        State.Gens = 0
        notify("Stats", "Reset", C.Red)
    elseif cmd == "!scan" then
        RemoteCache = {}
        fullScanRemotes()
        notify("Scan", U.count(RemoteCache) .. " remotes cached", C.Purple)
    elseif cmd == "!panic" then
        panicMode()
    elseif cmd == "!session" then
        local r = sessionReport()
        notify("Session", string.format("Eggs: %d | EPM: %s | %s",
            r.eggs, tostring(r.epm), r.duration), C.Cyan, 5)
    elseif cmd == "!players" then
        notify("Players", getPlayerCount() .. "/" .. Players.MaxPlayers, C.Cyan)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [28] INIT & BOOT (Lines 2821-2880)
-- ═══════════════════════════════════════════════════════════════════════
fullScanRemotes()
buildUI()

notify("Black Matrix", "Aggressive v" .. CFG.VERSION .. " loaded", C.Cyan, 4)
notify("Anti-AFK", "Multi-method active", C.Green, 4)

Log.info("================================================")
Log.info(" BLACK MATRIX AGGRESSIVE v" .. CFG.VERSION)
Log.info(" Creator: " .. CFG.CREATOR)
Log.info(" Remotes cached: " .. U.count(RemoteCache))
Log.info(" Device: " .. (DEVICE.MOBILE and "Mobile" or DEVICE.PC and "PC" or "Tablet"))
Log.info("================================================")

print("╔══════════════════════════════════════════════════════════════╗")
print("║   BLACK MATRIX AGGRESSIVE v" .. CFG.VERSION .. "                       ║")
print("║   Creator: " .. CFG.CREATOR .. "                                       ║")
print("║   UI: 800+ lines | Function: 1500+ lines                    ║")
print("║   Anti-AFK: ON (4 methods)                                  ║")
print("║   Aggressive farm: ON                                       ║")
print("╚══════════════════════════════════════════════════════════════╝")
print("[Chat] !start !stop !hop !escape !next !stats !reset !scan !panic !session")
print("[Keybind] RCTRL=UI F1=Farm F2=Spawn F3=Attack F4=Parry F5=Escape F6=Hop F7=Panic")
print("[Note] Pakai Remote Spy di executor kalau farm gak ngasih efek — nama remote bisa beda")
