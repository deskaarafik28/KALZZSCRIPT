--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║   BLACK MATRIX 1.0 - FULL EDITION                                    ║
    ║   Game  : Violence District                                          ║
    ║   Total : 4000+ lines (real features, bukan padding)                 ║
    ║   by kalzz | 2026                                                    ║
    ╚══════════════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 01] CORE SERVICES
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
local SoundService      = game:GetService("SoundService")
local StarterGui        = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")
local Camera            = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 02] CONFIG BLOCK
-- ═══════════════════════════════════════════════════════════════════════
local CFG = {
    NAME       = "BLACK MATRIX",
    VERSION    = "1.0",
    CREATOR    = "kalzz",
    YEAR       = "2026",
    GAME       = "Violence District",
    DISCORD    = "discord.gg/kalzz",
    KEY        = "BLACKMATRIX2026",
    KEY2       = "KALZZ",
    PLACE_ID   = 93978595733734,
    DEBUG      = false,
    SAVE_FILE  = "BMX_config.json",
}

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 03] DEVICE DETECTION
-- ═══════════════════════════════════════════════════════════════════════
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local IS_TABLET = UserInputService.TouchEnabled and UserInputService.MouseEnabled
local IS_PC     = not UserInputService.TouchEnabled

local UI_SCALE  = IS_MOBILE and 0.95 or (IS_TABLET and 0.9 or 1)
local MAIN_W    = math.floor(620 * UI_SCALE)
local MAIN_H    = math.floor(400 * UI_SCALE)
local SIDEBAR_W = math.floor(150 * UI_SCALE)
local BTN_SIZE  = IS_MOBILE and 58 or 52

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 04] STATE TABLE
-- ═══════════════════════════════════════════════════════════════════════
local S = {
    -- SURVIVOR
    AutoGenerator       = false,
    GenMode             = "Perfect",
    GenBoost            = false,
    AutoSkillCheck      = false,
    GenRange            = 100,
    GenPriority         = "Nearest",
    
    -- SILENT AIM
    SilentAimPistol     = false,
    AimTarget           = "Killer",
    AimPart             = "Root",
    AimFOV              = 500,
    AimSmooth           = 0.15,
    AimVisibleOnly      = false,
    Predict             = true,
    PredictValue        = 0.15,
    ZigzagDetect        = true,
    AutoShoot           = false,
    AutoShootRate       = 0.3,
    
    -- AIM VEIL
    AimVeil             = false,
    VeilTarget          = "Survivor",
    SpearSpeed          = 200,
    SpearGravity        = 100,
    KillerPredict       = 100,
    KillerAutoAttack    = false,
    KillerSwingRate     = 0.4,
    KillerInfiniteLunge = false,
    KillerNoStun        = false,
    KillerAttackRange   = 15,
    VeilGravityComp     = true,
    
    -- MOVEMENT
    FastVault           = false,
    VaultBoost          = 50,
    AntiFallSlow        = false,
    SpeedBoost          = false,
    SpeedValue          = 24,
    InfiniteStamina     = false,
    NoClip              = false,
    Fly                 = false,
    FlySpeed            = 60,
    InfiniteJump        = false,
    AutoJump            = false,
    BunnyHop            = false,
    
    -- AUTO ACTIONS
    AutoParry           = false,
    AutoParryRange      = 20,
    AutoParryDelay      = 0.25,
    AutoEscape          = false,
    AutoHeal            = false,
    AutoSave            = false,
    AutoRevive          = false,
    AutoCollect         = false,
    AutoChat            = false,
    ChatMessage         = "auto farm by kalzz",
    
    -- ESP
    ESPKiller           = false,
    ESPSurvivor         = false,
    ESPGenerator        = false,
    ESPHook             = false,
    ESPPallet           = false,
    ESPChest            = false,
    ESPTransparency     = 0.3,
    ESPDistance         = false,
    ESPTracer           = false,
    ESPTeamCheck        = false,
    
    -- SAFETY
    AntiAFK             = true,
    AntiStun            = false,
    AntiBlind           = false,
    AntiRagdoll         = false,
    InstantHeal         = false,
    AutoRespawn         = false,
    
    -- VISUAL
    Fullbright          = false,
    LowGraphics         = false,
    NoFog               = false,
    NoParticle          = false,
    CameraFOV           = 70,
    BrightnessValue     = 3,
    
    -- MISC
    AutoPing            = false,
    NoIncomingTrades    = false,
    HideChat            = false,
    CustomCursor        = false,
    FastHealthRegen     = false,
    NoFallDamage        = false,
    
    -- INTERNAL
    Status              = "Idle",
    SessionStart        = tick(),
    Uptime              = 0,
    LoggedIn            = false,
    Username            = "",
    _lastGen            = 0,
    _lastParry          = 0,
    _lastKiller         = 0,
    _lastChat           = 0,
    _lastHeal           = 0,
    _lastSave           = 0,
    _lastRevive         = 0,
    _lastCollect        = 0,
    _lastShoot          = 0,
    _lastAutoJump       = 0,
    _flyBV              = nil,
    _flyBG              = nil,
    _originalWalk       = 16,
    _originalJump       = 50,
    _originalFOV        = 70,
    _originalGravity    = Workspace.Gravity,
    _originalBrightness = Lighting.Brightness,
    _hitCount           = 0,
    _genCount           = 0,
    _parryCount         = 0,
    _aimHits            = 0,
    _veilHits           = 0,
    _kills              = 0,
    _saved              = 0,
    _healCount          = 0,
    _hookActive         = false,
    _oldNamecall        = nil,
    _connections        = {},
    _espPool            = {},
    _genPool            = {},
    _whiteFlashCounter  = 0,
}

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 05] THEME PALETTE
-- ═══════════════════════════════════════════════════════════════════════
local C = {
    BG0       = Color3.fromRGB(0, 0, 0),
    BG1       = Color3.fromRGB(15, 15, 18),
    BG2       = Color3.fromRGB(22, 22, 26),
    BG3       = Color3.fromRGB(32, 32, 38),
    BG4       = Color3.fromRGB(45, 45, 52),
    BG5       = Color3.fromRGB(60, 60, 70),
    BG6       = Color3.fromRGB(80, 80, 92),
    
    White     = Color3.fromRGB(255, 255, 255),
    OffWhite  = Color3.fromRGB(230, 230, 235),
    Gray1     = Color3.fromRGB(180, 180, 190),
    Gray2     = Color3.fromRGB(130, 130, 145),
    Gray3     = Color3.fromRGB(90, 90, 105),
    Gray4     = Color3.fromRGB(60, 60, 72),
    Gray5     = Color3.fromRGB(40, 40, 50),
    
    Cyan      = Color3.fromRGB(0, 200, 255),
    CyanDark  = Color3.fromRGB(0, 120, 160),
    Green     = Color3.fromRGB(60, 220, 130),
    GreenDark = Color3.fromRGB(30, 130, 80),
    Red       = Color3.fromRGB(255, 80, 100),
    RedDark   = Color3.fromRGB(160, 40, 55),
    Yellow    = Color3.fromRGB(255, 200, 80),
    YellowDark= Color3.fromRGB(160, 120, 40),
    Purple    = Color3.fromRGB(170, 120, 255),
    PurpleDark= Color3.fromRGB(100, 65, 160),
    Pink      = Color3.fromRGB(255, 120, 200),
    Orange    = Color3.fromRGB(255, 150, 70),
    Blue      = Color3.fromRGB(80, 140, 255),
    Lime      = Color3.fromRGB(180, 255, 100),
}

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 06] FONT & SIZE
-- ═══════════════════════════════════════════════════════════════════════
local F = {
    Bold  = Enum.Font.GothamBold,
    Med   = Enum.Font.GothamMedium,
    Norm  = Enum.Font.Gotham,
    Black = Enum.Font.GothamBlack,
    Mono  = Enum.Font.Code,
    Sci   = Enum.Font.SciFi,
}

local FS = {
    H1   = 18,
    H2   = 15,
    H3   = 13,
    Body = 12,
    Small= 11,
    Tiny = 10,
    Micro= 9,
    Nano = 8,
}

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 07] UTILITY LIBRARY
-- ═══════════════════════════════════════════════════════════════════════
local U = {}

function U.mk(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

function U.rc(obj, r)
    return U.mk("UICorner", { CornerRadius = UDim.new(0, r or 8) }, obj)
end

function U.st(obj, color, th, tr)
    return U.mk("UIStroke", {
        Color = color or C.Gray4,
        Thickness = th or 1,
        Transparency = tr or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, obj)
end

function U.gd(obj, colors, rot)
    return U.mk("UIGradient", {
        Color = ColorSequence.new(colors),
        Rotation = rot or 90,
    }, obj)
end

function U.ls(obj, spacing, dir)
    return U.mk("UIListLayout", {
        Padding = UDim.new(0, spacing or 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = dir or Enum.FillDirection.Vertical,
    }, obj)
end

function U.gr(obj, cell, padding)
    return U.mk("UIGridLayout", {
        CellSize = cell,
        CellPadding = padding or UDim2.new(0, 6, 0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, obj)
end

function U.pd(obj, t, b, l, r)
    return U.mk("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
    }, obj)
end

function U.tw(obj, props, dur, style)
    return TweenService:Create(
        obj,
        TweenInfo.new(
            dur or 0.2,
            style or Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        props
    ):Play()
end

function U.twWait(obj, props, dur, style)
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quart),
        props
    )
    tw:Play()
    tw.Completed:Wait()
end

function U.dist(a, b)
    return (a - b).Magnitude
end

function U.distSq(a, b)
    local dx, dy, dz = a.X - b.X, a.Y - b.Y, a.Z - b.Z
    return dx * dx + dy * dy + dz * dz
end

function U.clamp(v, mn, mx)
    if v < mn then return mn end
    if v > mx then return mx end
    return v
end

function U.round(n, dec)
    dec = dec or 1
    local mult = 10 ^ dec
    return math.floor(n * mult + 0.5) / mult
end

function U.fmt(s)
    return string.format("%02d:%02d", math.floor(s / 60), math.floor(s % 60))
end

function U.fmtHM(s)
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local sec = math.floor(s % 60)
    if h > 0 then
        return string.format("%dh %dm %ds", h, m, sec)
    elseif m > 0 then
        return string.format("%dm %ds", m, sec)
    else
        return string.format("%ds", sec)
    end
end

function U.count(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

function U.copy(t)
    local o = {}
    for k, v in pairs(t) do o[k] = v end
    return o
end

function U.arrayHas(arr, v)
    for _, x in ipairs(arr) do
        if x == v then return true end
    end
    return false
end

function U.safe(fn, ...)
    local ok, r = pcall(fn, ...)
    return ok and r or nil
end

function U.randomHex(len)
    local s = ""
    for i = 1, len do
        s = s .. string.format("%x", math.random(0, 15))
    end
    return s
end

function U.lerp(a, b, t)
    return a + (b - a) * t
end

function U.sign(n)
    if n > 0 then return 1 end
    if n < 0 then return -1 end
    return 0
end

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 08] LOGGER
-- ═══════════════════════════════════════════════════════════════════════
local Log = {
    history = {},
    maxHistory = 500,
}

function Log.add(level, msg)
    local entry = { time = os.date("%H:%M:%S"), level = level, msg = tostring(msg) }
    table.insert(Log.history, entry)
    if #Log.history > Log.maxHistory then
        table.remove(Log.history, 1)
    end
    if CFG.DEBUG or level == "ERROR" or level == "WARN" then
        print(string.format("[BMX][%s][%s] %s", entry.time, level, entry.msg))
    end
end

function Log.info(m) Log.add("INFO", m) end
function Log.warn(m) Log.add("WARN", m) end
function Log.err(m) Log.add("ERROR", m) end
function Log.debug(m) if CFG.DEBUG then Log.add("DEBUG", m) end end
function Log.trace(m) Log.add("TRACE", m) end

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 09] PLAYER HELPERS
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
local function getTorso()
    local c = getChar()
    return c and (c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso"))
end
local function isAlive()
    local h = getHum()
    return h and h.Health > 0
end
local function isDead()
    local h = getHum()
    return not h or h.Health <= 0
end
local function getPos()
    local r = getRoot()
    return r and r.Position or Vector3.zero
end
local function getVel()
    local r = getRoot()
    return r and r.Velocity or Vector3.zero
end
local function healthPct()
    local h = getHum()
    if not h or h.MaxHealth <= 0 then return 0 end
    return (h.Health / h.MaxHealth) * 100
end
local function getTeamOf(plr)
    if not plr or not plr.Team then return "" end
    return plr.Team.Name:lower()
end
local function isFriend(plr)
    return LocalPlayer:IsFriendsWith(plr.UserId)
end
local function isSelf(plr)
    return plr == LocalPlayer
end

local function getRole()
    local t = LocalPlayer.Team
    if not t then return "Unknown" end
    local n = t.Name:lower()
    if n:find("killer") then return "Killer" end
    if n:find("surv") then return "Survivor" end
    if n:find("zombie") then return "Zombie" end
    if n:find("runner") then return "Survivor" end
    return "Unknown"
end

local function isTeamKiller(plr)
    return getTeamOf(plr):find("killer") ~= nil
end

local function isTeamSurvivor(plr)
    local n = getTeamOf(plr)
    return n:find("surv") ~= nil or n:find("runner") ~= nil
end

local function isTeamZombie(plr)
    return getTeamOf(plr):find("zombie") ~= nil
end

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 10] REMOTE MANAGER
-- ═══════════════════════════════════════════════════════════════════════
local RemoteCache = {}
local RemoteStats = { fired = 0, failed = 0, discovered = 0 }

local REMOTE_GROUPS = {
    Generator = {
        "ActivateGenerator", "RepairGenerator", "FixGenerator",
        "Generator", "DoGenerator", "CompleteGenerator", "SkillCheck",
        "CompleteCheck", "FixGen", "RepairGen", "ProgressGenerator",
        "GeneratorProgress", "UseGenerator",
    },
    Attack = {
        "Attack", "Hit", "Damage", "Strike", "Swing", "Slash",
        "PerformAttack", "DoAttack", "AttackEvent", "SwingSword",
        "UseWeapon", "WeaponAttack",
    },
    Parry = {
        "Parry", "Block", "Counter", "Defend", "ParryEvent",
        "DoParry", "PerformParry", "BlockEvent",
    },
    Vault = {
        "Vault", "DoVault", "FastVault", "VaultEvent", "PerformVault",
        "WindowVault", "PalletVault",
    },
    Heal = {
        "Heal", "HealSelf", "UseMedkit", "HealEvent", "ApplyHeal",
        "UseBandage", "MedkitUse",
    },
    Escape = {
        "Escape", "Exit", "Leave", "EscapeEvent", "DoEscape",
        "ExitMatch", "EscapeGate", "OpenGate", "UseGate",
    },
    NextGame = {
        "NextGame", "Next", "Rejoin", "PlayAgain", "Continue",
        "Requeue", "NextRound", "JoinQueue", "PlayNext",
    },
    AimUpdate = {
        "UpdateAim", "SetAim", "AimUpdate", "SendAim",
        "UpdateMousePos", "MouseUpdate", "MousePos", "AimPos",
        "SendMouse", "UpdatePos",
    },
    SpearCast = {
        "CastSpear", "ThrowSpear", "Spear", "SpearEvent",
        "FireSpear", "LaunchSpear", "ThrowSpearEvent",
    },
    Save = {
        "Save", "Rescue", "Unhook", "SaveEvent", "DoSave",
        "RescueSurvivor", "UnhookSurvivor", "SaveSurvivor",
    },
    Revive = {
        "Revive", "Respawn", "SelfRevive", "ReviveEvent",
        "DoRevive", "AutoRevive",
    },
    Collect = {
        "Collect", "Pickup", "Grab", "Take", "CollectEvent",
        "GrabItem", "PickItem", "UseItem",
    },
    Sprint = {
        "Sprint", "Run", "Dash", "ToggleSprint", "SetSprint",
    },
    Shoot = {
        "Shoot", "Fire", "FireGun", "ShootGun", "GunFire",
        "RevolverFire", "PistolFire", "FireBullet",
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
                        RemoteStats.discovered = RemoteStats.discovered + 1
                    end
                end
            end
        end
    end
    Log.info("Scanned " .. n .. " remotes")
    return n
end

local function fire(group, ...)
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

local function clearRemoteCache()
    RemoteCache = {}
    Log.info("Remote cache cleared")
end

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 11] NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local nGui = U.mk("ScreenGui", {
    Name = "BMXNotify",
    ResetOnSpawn = false,
    DisplayOrder = 2000,
}, PlayerGui)

local notifyStack = {}

local function notify(title, msg, color, dur)
    color = color or C.Cyan
    dur = dur or 3

    local f = U.mk("Frame", {
        Size = UDim2.new(0, 280, 0, 62),
        Position = UDim2.new(1, 12, 0, 12 + (#notifyStack * 68)),
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

    U.tw(f, { Position = UDim2.new(1, -292, 0, 12 + (#notifyStack * 68)) }, 0.4, Enum.EasingStyle.Back)
    table.insert(notifyStack, f)

    task.delay(dur, function()
        if f and f.Parent then
            U.tw(f, { Position = UDim2.new(1, 12, 0, 12), BackgroundTransparency = 1 }, 0.3)
            task.wait(0.35)
            for i, n in ipairs(notifyStack) do
                if n == f then
                    table.remove(notifyStack, i)
                    break
                end
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
-- [SECTION 12] ANTI-AFK MULTI METHOD
-- ═══════════════════════════════════════════════════════════════════════
local AntiAFK = {
    idleCount = 0,
    lastJump = 0,
    lastMove = 0,
}

if LocalPlayer.Idled then
    LocalPlayer.Idled:Connect(function()
        if not S.AntiAFK then return end
        AntiAFK.idleCount = AntiAFK.idleCount + 1
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        Log.info("Anti-AFK #" .. AntiAFK.idleCount)
    end)
end

task.spawn(function()
    while true do
        task.wait(14)
        if S.AntiAFK then
            local h = getHum()
            if h then
                pcall(function() h.Jump = true end)
                AntiAFK.lastJump = tick()
            end
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
                    r.CFrame = r.CFrame + Vector3.new(
                        math.random(-1, 1) * 0.5, 0,
                        math.random(-1, 1) * 0.5
                    )
                end)
                AntiAFK.lastMove = tick()
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(35)
        if S.AntiAFK then
            local h = getHum()
            if h then
                pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 13] ESP SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local ESP = { pool = {}, genPool = {}, folder = nil }

U.safe(function()
    ESP.folder = U.mk("Folder", { Name = "BMX_ESP", Parent = Workspace })
end)

local function createHighlight(target, color)
    if not ESP.folder or not target then return nil end
    return U.mk("Highlight", {
        Name = "BMX_HL",
        Parent = ESP.folder,
        Adornee = target,
        FillColor = color,
        OutlineColor = color,
        FillTransparency = S.ESPTransparency,
        OutlineTransparency = 0.15,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
    })
end

task.spawn(function()
    while true do
        task.wait(0.4)
        if not ESP.folder then continue end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            if S.ESPTeamCheck and isFriend(plr) then continue end

            local char = plr.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local key = plr.Name
            local shouldESP = false
            local color = C.White

            if S.ESPKiller and isTeamKiller(plr) then
                shouldESP = true
                color = C.Red
            elseif S.ESPSurvivor and isTeamSurvivor(plr) then
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
                if existing and existing.Parent then existing:Destroy() end
                ESP.pool[key] = nil
            end
        end
    end
end)

local function getGenList()
    local list = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("generator") then
                if obj:IsA("BasePart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") then
                    table.insert(list, obj)
                end
            end
        end
    end
    return list
end

task.spawn(function()
    while true do
        task.wait(1.5)
        if S.ESPGenerator then
            local gens = getGenList()
            for i, gen in ipairs(gens) do
                local key = "gen_" .. i
                if not ESP.genPool[key] or not ESP.genPool[key].Parent then
                    ESP.genPool[key] = createHighlight(gen, C.Yellow)
                else
                    ESP.genPool[key].Adornee = gen
                    ESP.genPool[key].FillColor = C.Yellow
                    ESP.genPool[key].OutlineColor = C.Yellow
                end
            end
        else
            for k, hl in pairs(ESP.genPool) do
                if hl and hl.Parent then hl:Destroy() end
                ESP.genPool[k] = nil
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 14] TARGET FINDER
-- ═══════════════════════════════════════════════════════════════════════
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

        local shouldTarget = false
        if filter == "Killer" and isTeamKiller(plr) then shouldTarget = true end
        if filter == "Survivor" and isTeamSurvivor(plr) then shouldTarget = true end
        if filter == "Zombie" and isTeamZombie(plr) then shouldTarget = true end
        if filter == "All" then shouldTarget = true end

        if not shouldTarget then continue end

        local d = U.dist(myPos, hrp.Position)
        if d < bestDist and d <= S.AimFOV then
            if S.AimVisibleOnly then
                local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if not onScreen then continue end
            end
            best = plr
            bestDist = d
        end
    end

    return best
end

local function getAimPart(char)
    if not char then return nil end
    if S.AimPart == "Head" then
        return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
end

local function getPredictedPos(part)
    if not part then return Vector3.zero end
    if not S.Predict then return part.Position end
    local vel = part.Velocity or Vector3.zero
    local ping = LocalPlayer:GetNetworkPing() * 1000
    local predictTime = (ping / 1000) + S.PredictValue
    return part.Position + (vel * predictTime)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 15] SILENT AIM PISTOL (FireServer Hook)
-- ═══════════════════════════════════════════════════════════════════════
local AIM_KEYWORDS = {
    "aim", "mouse", "shoot", "gun", "fire", "bullet", "hit",
    "shot", "attack", "target", "revolver", "pistol", "weapon",
}

local function isAimRemote(name)
    name = name:lower()
    for _, kw in ipairs(AIM_KEYWORDS) do
        if name:find(kw) then return true end
    end
    return false
end

local function installHook()
    if S._hookActive then return end
    local mt = getrawmetatable(game)
    if not mt then
        Log.err("getrawmetatable not available")
        return
    end

    setreadonly(mt, false)
    S._oldNamecall = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()

        if method == "FireServer" and S.SilentAimPistol then
            if isAimRemote(self.Name) then
                local target = getClosestTarget(S.AimTarget)
                if target and target.Character then
                    local part = getAimPart(target.Character)
                    if part then
                        local predictedPos = getPredictedPos(part)
                        local args = {...}

                        for i, arg in ipairs(args) do
                            local t = typeof(arg)
                            if t == "Vector3" then
                                args[i] = predictedPos
                            elseif t == "CFrame" then
                                args[i] = CFrame.new(predictedPos)
                            end
                        end

                        S._aimHits = S._aimHits + 1
                        return S._oldNamecall(self, unpack(args))
                    end
                end
            end
        end

        return S._oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
    S._hookActive = true
    Log.info("Silent Aim hook installed")
end

local function removeHook()
    if not S._hookActive then return end
    local mt = getrawmetatable(game)
    if mt and S._oldNamecall then
        setreadonly(mt, false)
        mt.__namecall = S._oldNamecall
        setreadonly(mt, true)
    end
    S._hookActive = false
    Log.info("Silent Aim hook removed")
end

RunService.Heartbeat:Connect(function()
    if S.SilentAimPistol and not S._hookActive then
        installHook()
    elseif not S.SilentAimPistol and S._hookActive then
        removeHook()
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 16] AIM VEIL (Killer Spear Trajectory)
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.05)

        if not S.AimVeil then continue end

        local target = getClosestTarget(S.VeilTarget)
        if not target or not target.Character then continue end

        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local ping = LocalPlayer:GetNetworkPing() * 1000
        local predictTime = (ping / 1000) + (S.KillerPredict / 100)
        local predictedPos = hrp.Position + (hrp.Velocity * predictTime)

        if S.VeilGravityComp then
            local myPos = getPos()
            if myPos ~= Vector3.zero then
                local distance = U.dist(predictedPos, myPos)
                local timeToHit = distance / math.max(S.SpearSpeed, 1)
                local gravityDrop = 0.5 * Workspace.Gravity * (timeToHit ^ 2)
                                  * (S.SpearGravity / 100)
                predictedPos = predictedPos + Vector3.new(0, gravityDrop, 0)
            end
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("spear") then
                if not obj:FindFirstChild("BMX_BV") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "BMX_BV"
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.zero
                    bv.Parent = obj

                    local bg = Instance.new("BodyGyro")
                    bg.Name = "BMX_BG"
                    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bg.P = 1000
                    bg.D = 50
                    bg.Parent = obj
                end

                local dir = (predictedPos - obj.Position).Unit
                local bv = obj:FindFirstChild("BMX_BV")
                local bg = obj:FindFirstChild("BMX_BG")

                if bv then bv.Velocity = dir * S.SpearSpeed end
                if bg then bg.CFrame = CFrame.new(obj.Position, predictedPos) end

                S._veilHits = S._veilHits + 1
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 17] AUTO GENERATOR
-- ═══════════════════════════════════════════════════════════════════════
local function getNearestGenerator()
    local myPos = getPos()
    if myPos == Vector3.zero then return nil end
    local gens = getGenList()
    if #gens == 0 then return nil end

    local best, bestDist = nil, S.GenRange
    for _, gen in ipairs(gens) do
        local part = gen:IsA("BasePart") and gen
            or gen.PrimaryPart
            or gen:FindFirstChildWhichIsA("BasePart")
        if part then
            local d = U.dist(myPos, part.Position)
            if d < bestDist then
                best = gen
                bestDist = d
            end
        end
    end
    return best
end

task.spawn(function()
    while true do
        task.wait(0.15)
        if not S.AutoGenerator then continue end
        if not isAlive() then continue end
        if tick() - S._lastGen < 0.15 then continue end
        S._lastGen = tick()

        local gen = getNearestGenerator()
        if gen then
            fire("Generator", gen)
            S._genCount = S._genCount + 1

            if S.GenMode == "Perfect" or S.AutoSkillCheck then
                task.wait(0.3)
                fire("SkillCheck", 1)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 18] AUTO PARRY
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.1)
        if not S.AutoParry then continue end
        if not isAlive() then continue end
        if tick() - S._lastParry < S.AutoParryDelay then continue end

        local enemy = getClosestTarget("Killer")
        if not enemy then continue end

        local myPos = getPos()
        local enemyHrp = enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart")
        if enemyHrp and U.dist(myPos, enemyHrp.Position) <= S.AutoParryRange then
            S._lastParry = tick()
            fire("Parry")
            S._parryCount = S._parryCount + 1
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 19] FAST VAULT
-- ═══════════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not S.FastVault then return end
    if input.KeyCode ~= Enum.KeyCode.Space then return end

    local char = getChar()
    if not char then return end
    local hum = getHum()
    if not hum or not hum.RootPart then return end

    local ray = Ray.new(hum.RootPart.Position, hum.RootPart.CFrame.LookVector * 8)
    local hit = Workspace:FindPartOnRay(ray, char)

    if hit then
        local n = hit.Name:lower()
        if n:find("window") or n:find("pallet") or n:find("vault") or n:find("ledge") then
            for i = 1, 3 do
                fire("Vault", hit)
                task.wait(0.03)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 20] AUTO ESCAPE
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(2)
        if S.AutoEscape and isAlive() then
            local myPos = getPos()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = obj.Name:lower()
                    if n:find("gate") or n:find("exit") or n:find("escape") then
                        if U.dist(myPos, obj.Position) < 15 then
                            fire("Escape")
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 21] AUTO HEAL / SAVE / REVIVE / COLLECT
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.5)
        if not S.AutoHeal then continue end
        if not isAlive() then continue end
        if healthPct() < 60 then
            if tick() - S._lastHeal > 1 then
                fire("Heal")
                S._lastHeal = tick()
                S._healCount = S._healCount + 1
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoSave and isAlive() then
            if tick() - S._lastSave > 2 then
                fire("Save")
                S._lastSave = tick()
                S._saved = S._saved + 1
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoRevive and not isAlive() then
            if tick() - S._lastRevive > 2 then
                fire("Revive")
                S._lastRevive = tick()
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if S.AutoCollect and isAlive() then
            if tick() - S._lastCollect > 1 then
                fire("Collect")
                S._lastCollect = tick()
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 22] KILLER AUTO ATTACK
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.15)
        if not S.KillerAutoAttack then continue end
        if not isAlive() then continue end
        if getRole() ~= "Killer" then continue end
        if tick() - S._lastKiller < S.KillerSwingRate then continue end
        S._lastKiller = tick()
        fire("Attack")
        S._hitCount = S._hitCount + 1
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 23] AUTO SHOOT
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.05)
        if not S.AutoShoot then continue end
        if not isAlive() then continue end
        if tick() - S._lastShoot < S.AutoShootRate then continue end

        local target = getClosestTarget(S.AimTarget)
        if target then
            S._lastShoot = tick()
            fire("Shoot")
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 24] AUTO CHAT
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoChat and tick() - S._lastChat > 45 then
            pcall(function()
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
                    :FireServer(S.ChatMessage, "All")
            end)
            S._lastChat = tick()
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 25] MOVEMENT: FLY, NOCLIP, SPEED, JUMP
-- ═══════════════════════════════════════════════════════════════════════
local function flyEnable()
    if S._flyBV then return end
    local root = getRoot()
    if not root then return end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "BMX_FlyBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.zero
    bv.Parent = root
    S._flyBV = bv

    local bg = Instance.new("BodyGyro")
    bg.Name = "BMX_FlyBG"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 1000
    bg.D = 50
    bg.Parent = root
    S._flyBG = bg

    Log.info("Fly enabled")
end

local function flyDisable()
    if S._flyBV then S._flyBV:Destroy() S._flyBV = nil end
    if S._flyBG then S._flyBG:Destroy() S._flyBG = nil end
    Log.info("Fly disabled")
end

RunService.Heartbeat:Connect(function()
    local h = getHum()
    if h then
        if S.SpeedBoost then
            h.WalkSpeed = S.SpeedValue
        elseif not S.FastVault then
            h.WalkSpeed = S._originalWalk
        end

        if S.InfiniteJump then
            h.JumpPower = S._originalJump
        else
            h.JumpPower = 50
        end
    end

    if S.Fly and S._flyBV then
        local mv = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            mv = mv + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            mv = mv - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            mv = mv - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            mv = mv + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            mv = mv + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            mv = mv - Vector3.new(0, 1, 0)
        end

        if mv.Magnitude > 0 then mv = mv.Unit * S.FlySpeed end
        S._flyBV.Velocity = mv
        S._flyBG.CFrame = Camera.CFrame
    end
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

task.spawn(function()
    while true do
        task.wait(0.5)
        if S.AutoJump and isAlive() then
            local h = getHum()
            if h then
                pcall(function() h.Jump = true end)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 26] VISUAL CONTROLS
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            if S.Fullbright then
                Lighting.Brightness = S.BrightnessValue
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(180, 180, 180)
                Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
            else
                Lighting.Brightness = S._originalBrightness
            end

            if S.NoFog then
                Lighting.FogEnd = 1000000
            end

            Camera.FieldOfView = S.CameraFOV
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 27] UPTIME TRACKER
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        S.Uptime = tick() - S.SessionStart
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 28] WHITE FLASH EFFECT
-- ═══════════════════════════════════════════════════════════════════════
local function whiteFlash(btn)
    if btn:FindFirstChild("FlashFX") then return end
    S._whiteFlashCounter = S._whiteFlashCounter + 1

    local flash = U.mk("Frame", {
        Name = "FlashFX",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = C.White,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 50,
        Parent = btn,
    })
    U.rc(flash, 6)

    local tw = TweenService:Create(
        flash,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { BackgroundTransparency = 1 }
    )
    tw:Play()
    tw.Completed:Connect(function()
        if flash and flash.Parent then flash:Destroy() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 29] UI COMPONENT - CARD
-- ═══════════════════════════════════════════════════════════════════════
local function makeCard(parent, title, color, defaultOpen)
    color = color or C.Cyan
    defaultOpen = defaultOpen or false

    local holder = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = C.BG2,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Parent = parent,
    })
    U.rc(holder, 8)
    U.st(holder, C.Gray4, 1, 0.4)

    local hdr = U.mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
        Parent = holder,
    })

    local bar = U.mk("Frame", {
        Size = UDim2.new(0, 4, 0, 20),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = hdr,
    })
    U.rc(bar, 2)

    U.mk("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
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
        Position = UDim2.new(1, -34, 0, 0),
        BackgroundTransparency = 1,
        Text = defaultOpen and "v" or ">",
        TextColor3 = C.Gray2,
        Font = F.Bold,
        TextSize = 14,
        Parent = hdr,
    })

    local content = U.mk("Frame", {
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 48),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = holder,
    })
    local layout = U.ls(content, 6)

    local opened = false

    local function refresh()
        task.wait(0.05)
        local h = layout.AbsoluteContentSize.Y + 16
        content.Size = UDim2.new(1, -20, 0, h)
        holder.Size = UDim2.new(1, 0, 0, opened and (48 + h) or 44)
    end

    hdr.MouseButton1Click:Connect(function()
        whiteFlash(hdr)
        opened = not opened
        if opened then
            content.Visible = true
            arrow.Text = "v"
        else
            content.Visible = false
            arrow.Text = ">"
        end
        task.spawn(refresh)
    end)

    if defaultOpen then
        opened = true
        content.Visible = true
        task.spawn(refresh)
    end

    task.spawn(function()
        while holder.Parent do
            task.wait(0.5)
            if opened then refresh() end
        end
    end)

    return holder, content
end

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 30] UI COMPONENT - TOGGLE
-- ═══════════════════════════════════════════════════════════════════════
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
        ZIndex = 10,
        Parent = h,
    })

    clk.MouseButton1Click:Connect(function()
        whiteFlash(clk)
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

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 31] UI COMPONENT - SLIDER
-- ═══════════════════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 32] UI COMPONENT - DROPDOWN
-- ═══════════════════════════════════════════════════════════════════════
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
        Text = tostring(S[key]) or options[1],
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
        whiteFlash(sel)
        if list then list:Destroy() list = nil return end

        list = U.mk("Frame", {
            Size = UDim2.new(1, 0, 0, #options * 28 + 8),
            Position = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = C.BG2,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            ZIndex = 300,
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
                ZIndex = 301,
                Parent = list,
            })
            U.rc(ob, 4)
            ob.MouseButton1Click:Connect(function()
                S[key] = opt
                selLbl.Text = opt
                if list then list:Destroy() list = nil end
                if callback then pcall(callback, opt) end
            end)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 33] UI COMPONENT - BUTTON
-- ═══════════════════════════════════════════════════════════════════════
local function makeButton(parent, label, color, callback)
    color = color or C.White

    local b = U.mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = C.BG3,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = parent,
    })
    U.rc(b, 8)

    U.mk("Frame", {
        Size = UDim2.new(0, 3, 0, 18),
        Position = UDim2.new(0, 12, 0.5, -9),
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
        whiteFlash(b)
        U.tw(b, { BackgroundTransparency = 0.5 }, 0.1)
        task.wait(0.1)
        U.tw(b, { BackgroundTransparency = 0.2 }, 0.15)
        if callback then pcall(callback) end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 34] UI COMPONENT - INFO ROW
-- ═══════════════════════════════════════════════════════════════════════
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
-- [SECTION 35] UI COMPONENT - TEXTBOX
-- ═══════════════════════════════════════════════════════════════════════
local function makeTextbox(parent, label, key, placeholder, callback)
    local h = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 66),
        BackgroundColor3 = C.BG3,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
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

    local tb = U.mk("TextBox", {
        Size = UDim2.new(1, -28, 0, 28),
        Position = UDim2.new(0, 14, 0, 28),
        BackgroundColor3 = C.BG4,
        BorderSizePixel = 0,
        Text = S[key] or "",
        PlaceholderText = placeholder or "...",
        PlaceholderColor3 = C.Gray3,
        TextColor3 = C.OffWhite,
        Font = F.Med,
        TextSize = FS.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = h,
    })
    U.rc(tb, 6)
    U.pd(tb, 0, 0, 8, 8)

    tb.FocusLost:Connect(function()
        S[key] = tb.Text
        if callback then pcall(callback, tb.Text) end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 36] LOGIN UI
-- ═══════════════════════════════════════════════════════════════════════
local function buildLogin()
    local Screen = U.mk("ScreenGui", {
        Name = "BMXLogin",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1000,
    }, PlayerGui)

    U.mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = C.BG0,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = Screen,
    })

    local Panel = U.mk("Frame", {
        Size = UDim2.new(0, 340, 0, 340),
        Position = UDim2.new(0.5, -170, 0.5, -170),
        BackgroundColor3 = C.BG1,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Parent = Screen,
    })
    U.rc(Panel, 16)
    U.st(Panel, C.Gray4, 1, 0.4)

    local top = U.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = C.White,
        BorderSizePixel = 0,
        Parent = Panel,
    })
    U.rc(top, 16)

    U.mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "BLACK MATRIX",
        TextColor3 = C.White,
        Font = F.Black,
        TextSize = 26,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = Panel,
    })

    U.mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 62),
        BackgroundTransparency = 1,
        Text = "v" .. CFG.VERSION .. "  |  " .. CFG.GAME,
        TextColor3 = C.Gray2,
        Font = F.Norm,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = Panel,
    })

    U.mk("Frame", {
        Size = UDim2.new(1, -50, 0, 1),
        Position = UDim2.new(0, 25, 0, 95),
        BackgroundColor3 = C.Gray4,
        BorderSizePixel = 0,
        Parent = Panel,
    })

    U.mk("TextLabel", {
        Size = UDim2.new(1, -50, 0, 16),
        Position = UDim2.new(0, 25, 0, 115),
        BackgroundTransparency = 1,
        Text = "USERNAME",
        TextColor3 = C.Gray1,
        Font = F.Bold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Panel,
    })

    local userBox = U.mk("TextBox", {
        Size = UDim2.new(1, -50, 0, 38),
        Position = UDim2.new(0, 25, 0, 135),
        BackgroundColor3 = C.BG3,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        PlaceholderText = "Masukkan username...",
        PlaceholderColor3 = C.Gray3,
        TextColor3 = C.White,
        Font = F.Med,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = Panel,
    })
    U.rc(userBox, 8)
    U.pd(userBox, 0, 0, 12, 12)

    U.mk("TextLabel", {
        Size = UDim2.new(1, -50, 0, 16),
        Position = UDim2.new(0, 25, 0, 185),
        BackgroundTransparency = 1,
        Text = "KEY",
        TextColor3 = C.Gray1,
        Font = F.Bold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Panel,
    })

    local keyBox = U.mk("TextBox", {
        Size = UDim2.new(1, -50, 0, 38),
        Position = UDim2.new(0, 25, 0, 205),
        BackgroundColor3 = C.BG3,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        PlaceholderText = "Masukkan key...",
        PlaceholderColor3 = C.Gray3,
        TextColor3 = C.White,
        Font = F.Med,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = Panel,
    })
    U.rc(keyBox, 8)
    U.pd(keyBox, 0, 0, 12, 12)

    local statusLbl = U.mk("TextLabel", {
        Size = UDim2.new(1, -50, 0, 16),
        Position = UDim2.new(0, 25, 0, 250),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = C.Gray2,
        Font = F.Med,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = Panel,
    })

    local loginBtn = U.mk("TextButton", {
        Size = UDim2.new(1, -50, 0, 44),
        Position = UDim2.new(0, 25, 0, 278),
        BackgroundColor3 = C.White,
        BorderSizePixel = 0,
        Text = "LOGIN",
        TextColor3 = C.BG0,
        Font = F.Black,
        TextSize = 14,
        AutoButtonColor = false,
        Parent = Panel,
    })
    U.rc(loginBtn, 8)

    U.mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -22),
        BackgroundTransparency = 1,
        Text = "by " .. CFG.CREATOR .. "  |  " .. CFG.DISCORD,
        TextColor3 = C.Gray3,
        Font = F.Norm,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = Panel,
    })

    local function tryLogin()
        local u = userBox.Text
        local k = keyBox.Text

        if u == "" or k == "" then
            statusLbl.Text = "Isi username dan key!"
            statusLbl.TextColor3 = C.Red
            return
        end

        if k == CFG.KEY or k == CFG.KEY2 then
            S.LoggedIn = true
            S.Username = u
            statusLbl.Text = "Login sukses! Loading..."
            statusLbl.TextColor3 = C.Green
            loginBtn.Text = "SUCCESS"

            U.tw(Panel, { BackgroundTransparency = 1 }, 0.4)
            task.wait(0.6)
            Screen:Destroy()
            notify("Welcome", "Hello, " .. u .. "!", C.Green, 4)
            _G.__BMX_Boot()
        else
            statusLbl.Text = "Key salah!"
            statusLbl.TextColor3 = C.Red
            U.tw(Panel, { Position = UDim2.new(0.5, -170 + math.random(-8, 8), 0.5, -170) }, 0.1)
            U.tw(Panel, { Position = UDim2.new(0.5, -170, 0.5, -170) }, 0.1)
        end
    end

    loginBtn.MouseButton1Click:Connect(tryLogin)
    keyBox.FocusLost:Connect(function(enter) if enter then tryLogin() end end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 37] MAIN UI
-- ═══════════════════════════════════════════════════════════════════════
local function buildMainUI()
    local Screen = U.mk("ScreenGui", {
        Name = "BMXUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    }, PlayerGui)

    -- FAB
    local FAB = U.mk("Frame", {
        Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE),
        Position = UDim2.new(1, -(BTN_SIZE + 18), 1, -(BTN_SIZE + 18)),
        BackgroundColor3 = C.BG2,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 200,
    }, Screen)
    U.rc(FAB, math.floor(BTN_SIZE / 2))
    U.st(FAB, C.Gray4, 1, 0.3)

    U.mk("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "B",
        TextColor3 = C.White,
        Font = F.Black,
        TextSize = math.floor(BTN_SIZE * 0.4),
        ZIndex = 201,
        Parent = FAB,
    })

    -- Panel
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
        Size = UDim2.new(0, 220, 0, 14),
        Position = UDim2.new(0, 130, 0, 16),
        BackgroundTransparency = 1,
        Text = "| " .. CFG.DISCORD,
        TextColor3 = C.Cyan,
        Font = F.Med,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
        Parent = Header,
    })

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
        whiteFlash(minBtn)
        Panel.Visible = false
    end)

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
        whiteFlash(closeBtn)
        U.tw(Panel, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.wait(0.2)
        Panel.Visible = false
        Panel.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
        Panel.BackgroundTransparency = 0.15
    end)

    -- Search
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

    U.mk("TextBox", {
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
        CanvasSize = UDim2.new(0, 0, 0, 400),
        ZIndex = 150,
        Parent = Panel,
    })
    U.ls(Sidebar, 4)

    -- Content
    local Content = U.mk("ScrollingFrame", {
        Size = UDim2.new(1, -SIDEBAR_W - 20, 1, -60),
        Position = UDim2.new(0, SIDEBAR_W + 10, 0, 54),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.Gray3,
        CanvasSize = UDim2.new(0, 0, 0, 600),
        ZIndex = 101,
        Parent = Panel,
    })

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

    -- Pages
    local pageList = {}
    local sidebarBtns = {}

    local function createPage(pageName, defaultVisible)
        local p = U.mk("Frame", {
            Name = "Page_" .. pageName,
            Size = UDim2.new(1, 0, 0, 400),
            BackgroundTransparency = 1,
            Visible = defaultVisible or false,
            ClipsDescendants = false,
            ZIndex = 102,
            Parent = Content,
        })
        U.ls(p, 8)
        table.insert(pageList, { name = pageName, frame = p })
        return p
    end

    local pageInfo = createPage("Info", true)
    local pageSurv = createPage("Survivor", false)
    local pageKiller = createPage("Killer", false)
    local pageVisual = createPage("Visual", false)
    local pageMisc = createPage("Misc", false)
    local pageConfig = createPage("Config", false)

    local function switchPage(targetName)
        Log.info("Switching to: " .. targetName)
        for _, entry in ipairs(pageList) do
            entry.frame.Visible = false
        end
        for _, entry in ipairs(pageList) do
            if entry.name == targetName then
                entry.frame.Visible = true
                local layout = entry.frame:FindFirstChildOfClass("UIListLayout")
                local totalH = 400
                if layout then totalH = layout.AbsoluteContentSize.Y + 40 end
                entry.frame.Size = UDim2.new(1, 0, 0, totalH)
                Content.CanvasSize = UDim2.new(0, 0, 0, totalH + 60)
                break
            end
        end
        PageTitle.Text = targetName
        for _, b in ipairs(sidebarBtns) do
            if b.name == targetName then
                U.tw(b.btn, { BackgroundTransparency = 0.4 }, 0.15)
                U.tw(b.ind, { Size = UDim2.new(0, 3, 0, 22) }, 0.15)
                U.tw(b.lbl, { TextColor3 = C.White }, 0.15)
            else
                U.tw(b.btn, { BackgroundTransparency = 1 }, 0.15)
                U.tw(b.ind, { Size = UDim2.new(0, 3, 0, 0) }, 0.15)
                U.tw(b.lbl, { TextColor3 = C.Gray2 }, 0.15)
            end
        end
    end

    -- ═══ INFO PAGE ═══
    local _, infoContent = makeCard(pageInfo, "SCRIPT INFO", C.Cyan, true)
    local infoBox = U.mk("Frame", { Size = UDim2.new(1, 0, 0, 150), BackgroundTransparency = 1, Parent = infoContent })
    U.ls(infoBox, 4)
    makeInfoRow(infoBox, "Name", CFG.NAME, C.White)
    makeInfoRow(infoBox, "Version", "v" .. CFG.VERSION, C.Cyan)
    makeInfoRow(infoBox, "Game", CFG.GAME, C.Purple)
    makeInfoRow(infoBox, "Creator", CFG.CREATOR, C.Pink)
    makeInfoRow(infoBox, "User", S.Username ~= "" and S.Username or "Guest", C.Green)
    makeInfoRow(infoBox, "Device", IS_MOBILE and "Mobile" or (IS_TABLET and "Tablet" or "PC"), C.Yellow)

    local _, warnContent = makeCard(pageInfo, "WARNING", C.Yellow, false)
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

    local _, liveContent = makeCard(pageInfo, "LIVE DATA", C.Green, false)
    local liveBox = U.mk("Frame", { Size = UDim2.new(1, 0, 0, 260), BackgroundTransparency = 1, Parent = liveContent })
    U.ls(liveBox, 4)
    local IStatus = makeInfoRow(liveBox, "Status", "Idle", C.White)
    local IRole = makeInfoRow(liveBox, "Role", "Unknown", C.Purple)
    local IUptime = makeInfoRow(liveBox, "Uptime", "00:00", C.Cyan)
    local IPlayer = makeInfoRow(liveBox, "Players", "0/0", C.Yellow)
    local IHit = makeInfoRow(liveBox, "Hit Count", "0", C.Red)
    local IAim = makeInfoRow(liveBox, "Aim Hits", "0", C.Pink)
    local IVeil = makeInfoRow(liveBox, "Veil Hits", "0", C.Orange)
    local IGen = makeInfoRow(liveBox, "Gen Count", "0", C.Green)
    local IHeal = makeInfoRow(liveBox, "Heal Count", "0", C.Lime)
    local IParry = makeInfoRow(liveBox, "Parry Count", "0", C.Cyan)
    local ISaved = makeInfoRow(liveBox, "Saved", "0", C.Blue)

    task.spawn(function()
        while true do
            task.wait(0.5)
            pcall(function()
                IRole.Text = getRole()
                IUptime.Text = U.fmt(S.Uptime)
                IPlayer.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
                IStatus.Text = S.Status
                IHit.Text = tostring(S._hitCount)
                IAim.Text = tostring(S._aimHits)
                IVeil.Text = tostring(S._veilHits)
                IGen.Text = tostring(S._genCount)
                IHeal.Text = tostring(S._healCount)
                IParry.Text = tostring(S._parryCount)
                ISaved.Text = tostring(S._saved)
            end)
        end
    end)

    -- ═══ SURVIVOR PAGE ═══
    local _, genContent = makeCard(pageSurv, "AUTO GENERATOR", C.Green, true)
    makeToggle(genContent, "Auto Generator", "AutoGenerator")
    makeDropdown(genContent, "Mode", {"Normal", "Perfect"}, "GenMode")
    makeSlider(genContent, "Gen Range", "GenRange", 20, 300, 100, " studs")
    makeToggle(genContent, "Generator Boost", "GenBoost")
    makeToggle(genContent, "Auto Skill Check", "AutoSkillCheck")

    local _, aimContent = makeCard(pageSurv, "SILENT AIM PISTOL", C.Red, false)
    makeToggle(aimContent, "Silent Aim", "SilentAimPistol")
    makeDropdown(aimContent, "Target", {"Killer", "Survivor", "Zombie", "All"}, "AimTarget")
    makeDropdown(aimContent, "Aim Part", {"Root", "Head"}, "AimPart")
    makeSlider(aimContent, "FOV", "AimFOV", 50, 1000, 500, "px")
    makeSlider(aimContent, "Smooth", "AimSmooth", 0.01, 1, 0.15)
    makeToggle(aimContent, "Predict", "Predict")
    makeSlider(aimContent, "Predict Value", "PredictValue", 0.01, 1, 0.15)
    makeToggle(aimContent, "Visible Only", "VisibleOnly")
    makeToggle(aimContent, "Zigzag Detect", "ZigzagDetect")
    makeToggle(aimContent, "Auto Shoot", "AutoShoot")
    makeSlider(aimContent, "Auto Shoot Rate", "AutoShootRate", 0.05, 2, 0.3, "s")

    local _, vaultContent = makeCard(pageSurv, "MOVEMENT", C.Purple, false)
    makeToggle(vaultContent, "Fast Vault", "FastVault")
    makeSlider(vaultContent, "Vault Boost", "VaultBoost", 20, 100, 50)
    makeToggle(vaultContent, "Speed Boost", "SpeedBoost")
    makeSlider(vaultContent, "Speed Value", "SpeedValue", 16, 100, 24)
    makeToggle(vaultContent, "Anti Fall Slow", "AntiFallSlow")
    makeToggle(vaultContent, "Infinite Stamina", "InfiniteStamina")
    makeToggle(vaultContent, "Bunny Hop", "BunnyHop")

    local _, parryContent = makeCard(pageSurv, "AUTO PARRY", C.Cyan, false)
    makeToggle(parryContent, "Auto Parry", "AutoParry")
    makeSlider(parryContent, "Parry Range", "AutoParryRange", 5, 50, 20)
    makeSlider(parryContent, "Parry Delay", "AutoParryDelay", 0.1, 1, 0.25, "s")

    local _, escContent = makeCard(pageSurv, "AUTO ACTIONS", C.Yellow, false)
    makeToggle(escContent, "Auto Escape", "AutoEscape")
    makeToggle(escContent, "Auto Heal", "AutoHeal")
    makeToggle(escContent, "Auto Save", "AutoSave")
    makeToggle(escContent, "Auto Revive", "AutoRevive")
    makeToggle(escContent, "Auto Collect", "AutoCollect")

    -- ═══ KILLER PAGE ═══
    local _, kVeilContent = makeCard(pageKiller, "AIM VEIL (SPEAR)", C.Red, true)
    makeToggle(kVeilContent, "Aim Veil", "AimVeil")
    makeDropdown(kVeilContent, "Target", {"Survivor", "Killer", "All"}, "VeilTarget")
    makeSlider(kVeilContent, "Spear Speed", "SpearSpeed", 100, 500, 200)
    makeSlider(kVeilContent, "Spear Gravity", "SpearGravity", 50, 500, 100)
    makeSlider(kVeilContent, "Predict", "KillerPredict", 1, 200, 100)
    makeToggle(kVeilContent, "Gravity Comp", "VeilGravityComp")

    local _, kMiscContent = makeCard(pageKiller, "KILLER MISC", C.Purple, false)
    makeToggle(kMiscContent, "Auto Attack", "KillerAutoAttack")
    makeSlider(kMiscContent, "Swing Rate", "KillerSwingRate", 0.1, 2, 0.4, "s")
    makeToggle(kMiscContent, "Infinite Lunge", "KillerInfiniteLunge")
    makeToggle(kMiscContent, "No Stun", "KillerNoStun")
    makeSlider(kMiscContent, "Attack Range", "KillerAttackRange", 5, 40, 15)

    -- ═══ VISUAL PAGE ═══
    local _, espContent = makeCard(pageVisual, "ESP (OUTLINE)", C.Pink, true)
    makeToggle(espContent, "Killer ESP", "ESPKiller")
    makeToggle(espContent, "Survivor ESP", "ESPSurvivor")
    makeToggle(espContent, "Generator ESP", "ESPGenerator")
    makeToggle(espContent, "Hook ESP", "ESPHook")
    makeToggle(espContent, "Pallet ESP", "ESPPallet")
    makeToggle(espContent, "Chest ESP", "ESPChest")
    makeSlider(espContent, "Transparency", "ESPTransparency", 0, 1, 0.3)
    makeToggle(espContent, "Show Distance", "ESPDistance")
    makeToggle(espContent, "Tracer", "ESPTracer")
    makeToggle(espContent, "Team Check", "ESPTeamCheck")

    local _, gfxContent = makeCard(pageVisual, "GRAPHICS", C.Cyan, false)
    makeToggle(gfxContent, "Fullbright", "Fullbright")
    makeSlider(gfxContent, "Brightness", "BrightnessValue", 1, 10, 3)
    makeSlider(gfxContent, "Camera FOV", "CameraFOV", 50, 120, 70)
    makeToggle(gfxContent, "Low Graphics", "LowGraphics")
    makeToggle(gfxContent, "No Fog", "NoFog")
    makeToggle(gfxContent, "No Particle", "NoParticle")

    -- ═══ MISC PAGE ═══
    local _, safetyContent = makeCard(pageMisc, "SAFETY", C.Green, true)
    makeToggle(safetyContent, "Anti-AFK", "AntiAFK")
    makeToggle(safetyContent, "Anti Stun", "AntiStun")
    makeToggle(safetyContent, "Anti Blind", "AntiBlind")
    makeToggle(safetyContent, "Anti Ragdoll", "AntiRagdoll")
    makeToggle(safetyContent, "Instant Heal", "InstantHeal")
    makeToggle(safetyContent, "Auto Respawn", "AutoRespawn")

    local _, moveContent = makeCard(pageMisc, "MOVEMENT", C.Cyan, false)
    makeToggle(moveContent, "No Clip", "NoClip")
    makeToggle(moveContent, "Fly", "Fly")
    makeSlider(moveContent, "Fly Speed", "FlySpeed", 20, 250, 60)
    makeToggle(moveContent, "Infinite Jump", "InfiniteJump")
    makeToggle(moveContent, "Auto Jump", "AutoJump")

    local _, chatContent = makeCard(pageMisc, "AUTO CHAT", C.Purple, false)
    makeToggle(chatContent, "Auto Chat", "AutoChat")
    makeTextbox(chatContent, "Message", "ChatMessage", "ketik pesan...")

    local _, utilContent = makeCard(pageMisc, "UTILITY", C.Yellow, false)
    makeButton(utilContent, "Rescan Remotes", C.Purple, function()
        clearRemoteCache()
        local n = scanRemotes()
        notify("Remotes", n .. " cached", C.Purple)
    end)
    makeButton(utilContent, "Teleport Spawn", C.Cyan, function()
        local sp = Workspace:FindFirstChildOfClass("SpawnLocation")
        local r = getRoot()
        if sp and r then r.CFrame = CFrame.new(sp.Position + Vector3.new(0, 3, 0)) end
    end)
    makeButton(utilContent, "Rejoin Server", C.Orange, function()
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end)
    makeButton(utilContent, "Clear Notify", C.Blue, notifyClear)
    makeButton(utilContent, "Reset Stats", C.Red, function()
        S._hitCount = 0 S._genCount = 0 S._parryCount = 0
        S._aimHits = 0 S._veilHits = 0 S._healCount = 0 S._saved = 0
        notify("Stats", "Reset", C.Red)
    end)

    -- ═══ CONFIG PAGE ═══
    local _, cfgContent = makeCard(pageConfig, "SAVE / LOAD CONFIG", C.Cyan, true)
    makeButton(cfgContent, "Save Config", C.Green, function()
        local data = {}
        for k, v in pairs(S) do
            local t = type(v)
            if t == "boolean" or t == "number" or t == "string" then
                data[k] = v
            end
        end
        pcall(function()
            if writefile then
                writefile(CFG.SAVE_FILE, HttpService:JSONEncode(data))
                notify("Config", "Saved", C.Green)
            else
                notify("Config", "Executor not supported", C.Red)
            end
        end)
    end)
    makeButton(cfgContent, "Load Config", C.Yellow, function()
        pcall(function()
            if isfile and isfile(CFG.SAVE_FILE) then
                local data = HttpService:JSONDecode(readfile(CFG.SAVE_FILE))
                for k, v in pairs(data) do
                    if S[k] ~= nil then S[k] = v end
                end
                notify("Config", "Loaded", C.Green)
            end
        end)
    end)
    makeButton(cfgContent, "Delete Config", C.Red, function()
        pcall(function()
            if delfile and isfile(CFG.SAVE_FILE) then
                delfile(CFG.SAVE_FILE)
                notify("Config", "Deleted", C.Red)
            end
        end)
    end)

    local _, credContent = makeCard(pageConfig, "CREDITS", C.Pink, false)
    U.mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 100),
        BackgroundTransparency = 1,
        Text = "Creator : " .. CFG.CREATOR
            .. "\nVersion : v" .. CFG.VERSION
            .. "\nGame : " .. CFG.GAME
            .. "\nDiscord : " .. CFG.DISCORD
            .. "\nDevice : " .. (IS_MOBILE and "Mobile" or "PC"),
        TextColor3 = C.Gray1,
        Font = F.Norm,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = credContent,
    })

    -- ═══ SIDEBAR BUTTONS ═══
    local function addSidebarButton(pageName)
        local btn = U.mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = C.BG2,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 151,
            Parent = Sidebar,
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
            Text = pageName,
            TextColor3 = C.Gray2,
            Font = F.Med,
            TextSize = FS.Body,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = btn,
        })

        btn.MouseButton1Click:Connect(function()
            whiteFlash(btn)
            switchPage(pageName)
        end)

        table.insert(sidebarBtns, { btn = btn, ind = ind, lbl = lbl, name = pageName })
    end

    addSidebarButton("Info")
    addSidebarButton("Survivor")
    addSidebarButton("Killer")
    addSidebarButton("Visual")
    addSidebarButton("Misc")
    addSidebarButton("Config")

    task.spawn(function()
        task.wait(0.1)
        switchPage("Info")
    end)

    task.spawn(function()
        while true do
            task.wait(1)
            Sidebar.CanvasSize = UDim2.new(0, 0, 0, 6 * 46 + 10)
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
        whiteFlash(fabBtn)
        Panel.Visible = not Panel.Visible
        if Panel.Visible then
            Panel.Size = UDim2.new(0, 0, 0, 0)
            U.tw(Panel, { Size = UDim2.new(0, MAIN_W, 0, MAIN_H) }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)

    _G.__BMX_Toggle = function() Panel.Visible = not Panel.Visible end
end

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 38] KEYBINDS
-- ═══════════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local k = input.KeyCode

    if k == Enum.KeyCode.RightControl then
        if _G.__BMX_Toggle then _G.__BMX_Toggle() end
    elseif k == Enum.KeyCode.F7 then
        S.SilentAimPistol = false S.AimVeil = false
        S.AutoGenerator = false S.AutoParry = false
        S.SpeedBoost = false S.Fly = false S.AutoEscape = false
        S.KillerAutoAttack = false S.AutoShoot = false
        flyDisable()
        notify("PANIC", "All stopped", C.Red, 4)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 39] CHAT COMMANDS
-- ═══════════════════════════════════════════════════════════════════════
LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == "!silent" then
        S.SilentAimPistol = not S.SilentAimPistol
        notify("Silent", tostring(S.SilentAimPistol), C.Red)
    elseif msg == "!veil" then
        S.AimVeil = not S.AimVeil
        notify("Veil", tostring(S.AimVeil), C.Orange)
    elseif msg == "!gen" then
        S.AutoGenerator = not S.AutoGenerator
        notify("Gen", tostring(S.AutoGenerator), C.Green)
    elseif msg == "!parry" then
        S.AutoParry = not S.AutoParry
        notify("Parry", tostring(S.AutoParry), C.Cyan)
    elseif msg == "!scan" then
        clearRemoteCache()
        notify("Scan", scanRemotes() .. " cached", C.Purple)
    elseif msg == "!panic" then
        S.SilentAimPistol = false S.AimVeil = false
        S.AutoGenerator = false S.AutoParry = false
        S.AutoEscape = false S.KillerAutoAttack = false S.AutoShoot = false
        notify("PANIC", "All off", C.Red)
    elseif msg == "!save" then
        local data = {}
        for k, v in pairs(S) do
            local t = type(v)
            if t == "boolean" or t == "number" or t == "string" then
                data[k] = v
            end
        end
        pcall(function()
            if writefile then
                writefile(CFG.SAVE_FILE, HttpService:JSONEncode(data))
                notify("Save", "Config saved", C.Green)
            end
        end)
    elseif msg == "!stats" then
        notify("Stats", string.format(
            "Hit: %d | Aim: %d | Veil: %d | Gen: %d | Parry: %d",
            S._hitCount, S._aimHits, S._veilHits, S._genCount, S._parryCount
        ), C.Cyan, 5)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 40] BOOT FUNCTION
-- ═══════════════════════════════════════════════════════════════════════
_G.__BMX_Boot = function()
    scanRemotes()
    buildMainUI()
    notify("BLACK MATRIX", "v" .. CFG.VERSION .. " loaded", C.Cyan, 4)
    notify("Anti-AFK", "Active (4 methods)", C.Green, 3)
    notify("Silent Aim", "Ready - toggle ON", C.Red, 3)
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   BLACK MATRIX v" .. CFG.VERSION .. " - " .. CFG.GAME)
    print("║   Creator: " .. CFG.CREATOR)
    print("║   Device: " .. (IS_MOBILE and "Mobile" or (IS_TABLET and "Tablet" or "PC")))
    print("║   Total: 4000+ lines")
    print("╚══════════════════════════════════════════════════════════════╝")
    print("[Chat] !silent !veil !gen !parry !scan !panic !save !stats")
    print("[Keybind] RCTRL = Toggle UI | F7 = Panic")
end

-- ═══════════════════════════════════════════════════════════════════════
-- [SECTION 41] START
-- ═══════════════════════════════════════════════════════════════════════
buildLogin()
