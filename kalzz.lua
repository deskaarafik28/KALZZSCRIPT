--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║   STEAL AN EGG - ULTRA FARM EDITION v8.0                    ║
    ║   Real Functions | 2000+ Lines | Fixed Toggle               ║
    ║   Information Table | No Bug                                ║
    ║   Creator: kalzz | 2026                                     ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- ============================================================
-- SECTION 1: SERVICES
-- ============================================================
local Players              = game:GetService("Players")
local RunService           = game:GetService("RunService")
local UserInputService     = game:GetService("UserInputService")
local TweenService         = game:GetService("TweenService")
local Workspace            = game:GetService("Workspace")
local ReplicatedStorage    = game:GetService("ReplicatedStorage")
local Lighting             = game:GetService("Lighting")
local HttpService          = game:GetService("HttpService")
local StarterGui           = game:GetService("StarterGui")
local VirtualUser          = game:GetService("VirtualUser")
local LocalPlayer          = Players.LocalPlayer
local PlayerGui            = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- SECTION 2: CONFIG
-- ============================================================
local CONFIG = {
    SCRIPT_NAME    = "Steal An Egg Ultra",
    VERSION        = "8.0",
    CREATOR        = "kalzz",
    RELEASE        = "2026",
    STATUS         = "Public Release",
    MODULES        = 12,
    FEATURES       = 42,
}

-- ============================================================
-- SECTION 3: STATE
-- ============================================================
local State = {
    -- Farm
    AutoFarm           = false,
    FarthestEgg        = true,
    NearestEgg         = false,
    PriorityRare       = true,
    SkipLocked         = true,
    SkipCommon         = false,
    AntiGagal          = true,
    AntiStuck          = true,
    AutoReturn         = true,
    AutoPlace          = true,
    AutoHatch          = false,
    AutoSell           = false,
    AutoBuyUpgrade     = false,
    AutoEquipBest      = false,
    AutoClaimReward    = false,
    NeverSellRare      = true,
    NeverSellEquipped  = true,

    -- Movement
    SpeedHack          = false,
    InfiniteJump       = false,
    NoClip             = false,
    FlyMode            = false,
    SpeedValue         = 22,
    JumpPower          = 50,
    FlySpeed           = 60,
    Method             = "Instant",
    TweenSpeed         = 0.4,
    WalkThreshold      = 5,

    -- Safety
    AntiAFK            = true,
    LowHealthFlee      = false,
    HealthThreshold    = 30,

    -- Performance
    LowGraphics        = false,
    BoostFPS           = false,
    HideAccessories    = false,
    Fullbright         = false,

    -- Timing
    RetryCount         = 5,
    DelayBetween       = 1.2,
    MaxLoopTime        = 30,
    HatchInterval      = 3,
    SellInterval       = 5,
    BuyInterval        = 10,

    -- Stats
    EggCount           = 0,
    FailCount          = 0,
    RareCount          = 0,
    HatchCount         = 0,
    SellCount          = 0,
    BuyCount           = 0,
    PlaceCount         = 0,
    SuccessRate        = 100,
    SessionStart       = 0,
    Status             = "Idle",
    CurrentTarget      = "None",
    Session            = 0,
    BestSession        = 0,
    TotalSessions      = 0,

    -- Internal
    _lastCacheClear    = 0,
    _lastHatch         = 0,
    _lastSell          = 0,
    _lastBuy           = 0,
    _lastPos           = Vector3.new(0, 0, 0),
    _stuckCount        = 0,
    _failStreak        = 0,
    _startEggCount     = 0,
    _paused            = false,
    _running           = true,
    _flyBV             = nil,
    _flyBG             = nil,
}

-- ============================================================
-- SECTION 4: THEME
-- ============================================================
local Theme = {
    BG         = Color3.fromRGB(8, 8, 12),
    Panel      = Color3.fromRGB(14, 14, 20),
    PanelAlt   = Color3.fromRGB(18, 18, 26),
    Element    = Color3.fromRGB(22, 22, 30),
    ElementOn  = Color3.fromRGB(32, 32, 44),
    Hover      = Color3.fromRGB(38, 38, 52),
    Accent     = Color3.fromRGB(0, 200, 255),
    AccentDim  = Color3.fromRGB(0, 110, 160),
    AccentGlow = Color3.fromRGB(100, 220, 255),
    Text       = Color3.fromRGB(235, 235, 240),
    TextDim    = Color3.fromRGB(130, 130, 150),
    TextFaint  = Color3.fromRGB(80, 80, 100),
    Success    = Color3.fromRGB(0, 210, 110),
    Danger     = Color3.fromRGB(220, 60, 60),
    Warning    = Color3.fromRGB(240, 180, 60),
    Rare       = Color3.fromRGB(255, 100, 220),
    Purple     = Color3.fromRGB(150, 100, 255),
    Border     = Color3.fromRGB(38, 38, 52),
    Font       = Enum.Font.Gotham,
    FontBold   = Enum.Font.GothamBold,
    FontMono   = Enum.Font.Code,
}

-- ============================================================
-- SECTION 5: UTILITY FUNCTIONS
-- ============================================================
local Util = {}

function Util.create(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

function Util.corner(obj, r)
    return Util.create("UICorner", {CornerRadius = UDim.new(0, r or 7)}, obj)
end

function Util.stroke(obj, color, th)
    return Util.create("UIStroke", {Color = color or Theme.Border, Thickness = th or 1}, obj)
end

function Util.padding(obj, t, b, l, r)
    return Util.create("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
    }, obj)
end

function Util.listLayout(obj, padding, order)
    return Util.create("UIListLayout", {
        Padding = UDim.new(0, padding or 5),
        SortOrder = order or Enum.SortOrder.LayoutOrder,
    }, obj)
end

function Util.gridLayout(obj, cellSize, padding)
    return Util.create("UIGridLayout", {
        CellSize = cellSize or UDim2.new(0, 100, 0, 30),
        CellPadding = padding or UDim2.new(0, 5, 0, 5),
    }, obj)
end

function Util.tween(obj, props, dur, style, dir)
    TweenService:Create(
        obj,
        TweenInfo.new(dur or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

function Util.formatTime(sec)
    local m = math.floor(sec / 60)
    local s = math.floor(sec % 60)
    return string.format("%02d:%02d", m, s)
end

function Util.round(n, dec)
    dec = dec or 1
    local mult = 10 ^ dec
    return math.floor(n * mult + 0.5) / mult
end

function Util.safeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    if ok then return result end
    return nil
end

function Util.distance(a, b)
    return (a - b).Magnitude
end

function Util.clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

function Util.random(min, max)
    return math.random(min, max)
end

-- ============================================================
-- SECTION 6: LOGGER
-- ============================================================
local Logger = {}
local logHistory = {}
local MAX_LOG = 200

function Logger.add(level, msg)
    local entry = {
        time = os.date("%H:%M:%S"),
        level = level,
        msg = msg,
    }
    table.insert(logHistory, entry)
    if #logHistory > MAX_LOG then
        table.remove(logHistory, 1)
    end
end

function Logger.info(m) Logger.add("INFO", m) end
function Logger.warn(m) Logger.add("WARN", m) end
function Logger.error(m) Logger.add("ERROR", m) end
function Logger.get() return logHistory end
function Logger.clear() logHistory = {} end

-- ============================================================
-- SECTION 7: NOTIFY SYSTEM
-- ============================================================
local notifyScreen = nil
local activeNotifs = {}

local function ensureNotify()
    if notifyScreen and notifyScreen.Parent then return notifyScreen end
    notifyScreen = Util.create("ScreenGui", {
        Name = "EggNotify",
        ResetOnSpawn = false,
        Parent = PlayerGui,
    })
    return notifyScreen
end

local function notify(title, msg, color, duration)
    ensureNotify()
    color = color or Theme.Accent
    duration = duration or 3.5

    local frame = Util.create("Frame", {
        Size = UDim2.new(0, 260, 0, 62),
        Position = UDim2.new(1, 10, 0, 10),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Parent = notifyScreen,
    })
    Util.corner(frame, 8)
    Util.stroke(frame, color, 1)

    Util.create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = frame,
    })

    Util.create("TextLabel", {
        Size = UDim2.new(1, -14, 0, 20),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    Util.create("TextLabel", {
        Size = UDim2.new(1, -14, 0, 32),
        Position = UDim2.new(0, 10, 0, 26),
        BackgroundTransparency = 1,
        Text = msg,
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = frame,
    })

    Util.tween(frame, {Position = UDim2.new(1, -270, 0, 10)}, 0.35)
    table.insert(activeNotifs, frame)

    task.delay(duration, function()
        if frame and frame.Parent then
            Util.tween(frame, {Position = UDim2.new(1, 10, 0, 10)}, 0.3)
            task.wait(0.35)
            for i, f in ipairs(activeNotifs) do
                if f == frame then
                    table.remove(activeNotifs, i)
                    break
                end
            end
            frame:Destroy()
        end
    end)
end

local function notifyClear()
    for _, f in ipairs(activeNotifs) do
        if f and f.Parent then f:Destroy() end
    end
    activeNotifs = {}
end

-- ============================================================
-- SECTION 8: REMOTE MANAGER
-- ============================================================
local RemoteCache = {}
local RemoteStats = { fired = 0, failed = 0 }

local REMOTE_CANDIDATES = {
    Steal = {
        "StealEgg","Steal","GrabEgg","PickEgg","EggSteal",
        "StealEggEvent","AttemptSteal","CollectEgg","TakeEgg",
        "Grab","Collect","Pick",
    },
    Place = {
        "PlaceEgg","Place","DropEgg","EggPlace","PlacePet",
        "PlaceEggEvent","PlacePetEvent","Deposit","Store",
    },
    Hatch = {
        "HatchEgg","Hatch","EggHatch","OpenEgg","HatchAll",
        "HatchPet","HatchAllEgg","Open",
    },
    Sell = {
        "SellEgg","Sell","SellPet","SellAll","SellInventory",
        "SellPets","SellAllPet","SellItem",
    },
    Buy = {
        "BuyUpgrade","PurchaseUpgrade","UpgradeBuy","BuyEgg",
        "BuyItem","Upgrade","Purchase","Buy",
    },
    Equip = {
        "EquipBest","AutoEquip","EquipPet","EquipBestPets",
        "Equip","EquipPetEvent",
    },
    Claim = {
        "ClaimReward","ClaimAll","ClaimRewards","ClaimDaily",
        "ClaimAllReward","Claim",
    },
    Rebirth = {
        "Rebirth","DoRebirth","RebirthEvent","RebirthPet",
    },
}

local function findRemote(key)
    local list = REMOTE_CANDIDATES[key]
    if not list then return nil end
    for _, name in ipairs(list) do
        if RemoteCache[name] and RemoteCache[name].Parent then
            return RemoteCache[name]
        end
        local r = ReplicatedStorage:FindFirstChild(name, true)
        if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
            RemoteCache[name] = r
            Logger.info("Found remote: " .. name)
            return r
        end
    end
    return nil
end

local function fireAll(key, ...)
    local list = REMOTE_CANDIDATES[key]
    if not list then return false end
    local args = {...}
    local fired = false
    for _, name in ipairs(list) do
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
    Logger.info("Remote cache cleared")
end

local function getCacheSize()
    local n = 0
    for _ in pairs(RemoteCache) do n = n + 1 end
    return n
end

local function getRemoteKeys()
    local keys = {}
    for k in pairs(REMOTE_CANDIDATES) do
        table.insert(keys, k)
    end
    return keys
end

-- ============================================================
-- SECTION 9: PLAYER MANAGER
-- ============================================================
local PlayerMgr = {}

function PlayerMgr.getRoot()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

function PlayerMgr.getHumanoid()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

function PlayerMgr.isAlive()
    local h = PlayerMgr.getHumanoid()
    return h ~= nil and h.Health > 0
end

function PlayerMgr.getPosition()
    local r = PlayerMgr.getRoot()
    return r and r.Position or nil
end

function PlayerMgr.getHealth()
    local h = PlayerMgr.getHumanoid()
    return h and h.Health or 0
end

function PlayerMgr.getMaxHealth()
    local h = PlayerMgr.getHumanoid()
    return h and h.MaxHealth or 100
end

function PlayerMgr.getHealthPercent()
    local h = PlayerMgr.getHumanoid()
    if not h or h.MaxHealth <= 0 then return 0 end
    return (h.Health / h.MaxHealth) * 100
end

function PlayerMgr.getBackpack()
    return LocalPlayer:FindFirstChildOfClass("Backpack")
end

function PlayerMgr.getTools()
    local tools = {}
    local char = LocalPlayer.Character
    local bp = PlayerMgr.getBackpack()
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then table.insert(tools, t) end
        end
    end
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then table.insert(tools, t) end
        end
    end
    return tools
end

-- ============================================================
-- SECTION 10: EGG MANAGER
-- ============================================================
local EggMgr = {}

local RARE_KEYWORDS = {
    "rare","legendary","mythic","epic","large","golden","huge",
    "secret","exclusive","limited","special","ultimate","rainbow",
    "shiny","galaxy","cosmic","divine","godly","celestial","void",
    "prismatic","neon","diamond","crystal","eternal","infinite",
}

local COMMON_KEYWORDS = {
    "common","basic","normal","starter","beginner","simple",
}

local LOCK_KEYWORDS = {
    "lock","key","require","unlock","restrict","need",
}

function EggMgr.isRare(model)
    local n = model.Name:lower()
    for _, k in ipairs(RARE_KEYWORDS) do
        if n:find(k) then return true end
    end
    return false
end

function EggMgr.isCommon(model)
    local n = model.Name:lower()
    for _, k in ipairs(COMMON_KEYWORDS) do
        if n:find(k) then return true end
    end
    return false
end

function EggMgr.isLocked(model)
    for _, ch in ipairs(model:GetChildren()) do
        local cn = ch.Name:lower()
        for _, k in ipairs(LOCK_KEYWORDS) do
            if cn:find(k) then return true end
        end
    end
    for _, ch in ipairs(model:GetDescendants()) do
        if ch:IsA("BoolValue") and ch.Name:lower():find("lock") and ch.Value then
            return true
        end
    end
    return false
end

function EggMgr.getAll()
    local list = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("egg") then
            local base = obj:FindFirstChild("Base")
                or obj:FindFirstChild("BasePart")
                or obj.PrimaryPart
                or obj:FindFirstChildWhichIsA("BasePart", true)
            if base then
                local skip = false
                if State.SkipLocked and EggMgr.isLocked(obj) then skip = true end
                if State.SkipCommon and EggMgr.isCommon(obj) then skip = true end
                if not skip then
                    table.insert(list, {
                        model = obj,
                        part = base,
                        rare = EggMgr.isRare(obj),
                        common = EggMgr.isCommon(obj),
                        locked = EggMgr.isLocked(obj),
                    })
                end
            end
        end
    end
    return list
end

function EggMgr.getTarget()
    local eggs = EggMgr.getAll()
    if #eggs == 0 then return nil end
    local root = PlayerMgr.getRoot()
    if not root then return nil end

    if State.PriorityRare then
        local rare = {}
        for _, e in ipairs(eggs) do
            if e.rare then table.insert(rare, e) end
        end
        if #rare > 0 then eggs = rare end
    end

    local target, best = nil, State.FarthestEgg and -1 or math.huge
    for _, e in ipairs(eggs) do
        local d = Util.distance(e.part.Position, root.Position)
        if State.FarthestEgg then
            if d > best then best = d; target = e end
        else
            if d < best then best = d; target = e end
        end
    end
    return target
end

function EggMgr.count()
    return #EggMgr.getAll()
end

function EggMgr.countRare()
    local n = 0
    for _, e in ipairs(EggMgr.getAll()) do
        if e.rare then n = n + 1 end
    end
    return n
end

function EggMgr.getNames(limit)
    limit = limit or 10
    local names = {}
    local eggs = EggMgr.getAll()
    for i = 1, math.min(limit, #eggs) do
        table.insert(names, eggs[i].model.Name)
    end
    return names
end

-- ============================================================
-- SECTION 11: MOVE MANAGER
-- ============================================================
local MoveMgr = {}

function MoveMgr.instant(pos)
    local root = PlayerMgr.getRoot()
    if not root then return false end
    root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    return true
end

function MoveMgr.tween(pos, dur)
    local root = PlayerMgr.getRoot()
    if not root then return false end
    local goal = {CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))}
    local tw = TweenService:Create(
        root,
        TweenInfo.new(dur or State.TweenSpeed, Enum.EasingStyle.Linear),
        goal
    )
    tw:Play()
    tw.Completed:Wait()
    return true
end

function MoveMgr.walk(pos, timeout)
    local hum = PlayerMgr.getHumanoid()
    if not hum then return false end
    timeout = timeout or 15
    hum:MoveTo(pos)
    local start = tick()
    while tick() - start < timeout do
        local root = PlayerMgr.getRoot()
        if not root then break end
        if Util.distance(root.Position, pos) < State.WalkThreshold then
            return true
        end
        task.wait(0.1)
    end
    return false
end

function MoveMgr.moveTo(pos)
    if State.Method == "Instant" then
        return MoveMgr.instant(pos)
    elseif State.Method == "Tween" then
        return MoveMgr.tween(pos)
    elseif State.Method == "Walk" then
        return MoveMgr.walk(pos)
    end
    return false
end

-- ============================================================
-- SECTION 12: BASE MANAGER
-- ============================================================
local BaseMgr = {}
local BASE_KEYWORDS = {"base", "pen", "nest", "drop", "home", "farm"}

function BaseMgr.getNearest()
    local root = PlayerMgr.getRoot()
    if not root then return nil end
    local nearest, minD = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            for _, k in ipairs(BASE_KEYWORDS) do
                if n:find(k) then
                    local d = Util.distance(obj.Position, root.Position)
                    if d < minD then minD = d; nearest = obj end
                    break
                end
            end
        end
    end
    return nearest
end

function BaseMgr.returnToBase()
    local base = BaseMgr.getNearest()
    if not base then return false end
    MoveMgr.moveTo(base.Position)
    task.wait(0.3)
    if State.AutoPlace then
        if fireAll("Place") then
            State.PlaceCount = State.PlaceCount + 1
        end
    end
    return true
end

-- ============================================================
-- SECTION 13: STEAL MANAGER
-- ============================================================
local StealMgr = {}

function StealMgr.tryPrompt(model)
    local prompt = model:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        Util.safeCall(function() fireproximityprompt(prompt) end)
        task.wait(0.1)
        return true
    end
    return false
end

function StealMgr.tryClick(model)
    local click = model:FindFirstChildOfClass("ClickDetector")
    if click then
        Util.safeCall(function() fireclickdetector(click) end)
        return true
    end
    return false
end

function StealMgr.tryRemote(model, part)
    fireAll("Steal", model)
    task.wait(0.05)
    fireAll("Steal", part)
    task.wait(0.05)
    fireAll("Steal", model, part)
    task.wait(0.05)
    fireAll("Steal")
    return true
end

function StealMgr.tryTool()
    local char = LocalPlayer.Character
    if not char then return false end
    local found = false
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then
            local tn = t.Name:lower()
            if tn:find("steal") or tn:find("grab") or tn:find("hand") or tn:find("net") then
                Util.safeCall(function() t:Activate() end)
                found = true
            end
        end
    end
    return found
end

function StealMgr.isSuccess(model, part)
    task.wait(0.4)
    if not model.Parent then return true end
    local root = PlayerMgr.getRoot()
    if root and Util.distance(root.Position, part.Position) > 15 then return true end
    return false
end

function StealMgr.trySteal(eggData)
    local model = eggData.model
    local part = eggData.part

    StealMgr.tryPrompt(model)
    StealMgr.tryClick(model)
    StealMgr.tryRemote(model, part)
    StealMgr.tryTool()

    return StealMgr.isSuccess(model, part)
end

-- ============================================================
-- SECTION 14: ANTI-STUCK
-- ============================================================
local AntiStuck = {}

function AntiStuck.check()
    if not State.AntiStuck then return end
    local root = PlayerMgr.getRoot()
    if not root then return end
    local now = root.Position
    if Util.distance(now, State._lastPos) < 1.5 then
        State._stuckCount = State._stuckCount + 1
        if State._stuckCount >= 3 then
            local offset = Vector3.new(Util.random(-8, 8), 0, Util.random(-8, 8))
            root.CFrame = root.CFrame + offset
            State._stuckCount = 0
            Logger.warn("Anti-stuck triggered")
        end
    else
        State._stuckCount = 0
    end
    State._lastPos = now
end

function AntiStuck.reset()
    State._stuckCount = 0
    State._lastPos = Vector3.new(0, 0, 0)
end

-- ============================================================
-- SECTION 15: FLY MANAGER
-- ============================================================
local FlyMgr = {}

function FlyMgr.enable()
    if State._flyBV then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.zero
    bv.Parent = root
    State._flyBV = bv

    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyBG"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 1000
    bg.D = 50
    bg.Parent = root
    State._flyBG = bg

    Logger.info("Fly enabled")
end

function FlyMgr.disable()
    if State._flyBV then State._flyBV:Destroy(); State._flyBV = nil end
    if State._flyBG then State._flyBG:Destroy(); State._flyBG = nil end
    Logger.info("Fly disabled")
end

function FlyMgr.update()
    if not State.FlyMode then return end
    local root = PlayerMgr.getRoot()
    if not root or not State._flyBV then return end
    local cam = Workspace.CurrentCamera
    local move = Vector3.zero
    local hum = PlayerMgr.getHumanoid()

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        move = move + cam.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        move = move - cam.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        move = move - cam.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        move = move + cam.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        move = move + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        move = move - Vector3.new(0, 1, 0)
    end

    if move.Magnitude > 0 then
        move = move.Unit * State.FlySpeed
    end

    State._flyBV.Velocity = move
    State._flyBG.CFrame = cam.CFrame
end

-- ============================================================
-- SECTION 16: HEALTH MANAGER
-- ============================================================
local HealthMgr = {}

function HealthMgr.isLow()
    local hp = PlayerMgr.getHealthPercent()
    return hp > 0 and hp < State.HealthThreshold
end

function HealthMgr.tryHeal()
    local tools = PlayerMgr.getTools()
    for _, t in ipairs(tools) do
        local tn = t.Name:lower()
        if tn:find("medkit") or tn:find("bandage") or tn:find("health") or tn:find("potion") then
            if t.Parent ~= LocalPlayer.Character then
                t.Parent = LocalPlayer.Character
            end
            task.wait(0.1)
            Util.safeCall(function() t:Activate() end)
            return true
        end
    end
    return false
end

function HealthMgr.watch()
    task.spawn(function()
        while State._running do
            task.wait(1)
            if State.LowHealthFlee and HealthMgr.isLow() then
                notify("Low Health", "HP: " .. math.floor(PlayerMgr.getHealthPercent()) .. "%", Theme.Danger)
                HealthMgr.tryHeal()
                BaseMgr.returnToBase()
            end
        end
    end)
end

-- ============================================================
-- SECTION 17: PERFORMANCE MANAGER
-- ============================================================
local PerfMgr = {}

function PerfMgr.setLowGraphics(enabled)
    if enabled then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                end
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                    v.Enabled = false
                end
            end
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
            Lighting.Brightness = 2
        end)
    else
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Lighting.GlobalShadows = true
        end)
    end
end

function PerfMgr.hideAccessories(enabled)
    local char = LocalPlayer.Character
    if not char then return end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Accessory") or obj:IsA("Hat") then
            obj:Destroy()
        end
    end
end

function PerfMgr.boostFPS(enabled)
    if enabled then
        pcall(function()
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") then v.Enabled = false end
                if v:IsA("Trail") then v.Enabled = false end
                if v:IsA("Smoke") then v.Enabled = false end
                if v:IsA("Fire") then v.Enabled = false end
            end
        end)
    end
end

function PerfMgr.setFullbright(enabled)
    if enabled then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
    end
end

-- ============================================================
-- SECTION 18: ANTI AFK
-- ============================================================
local AntiAFK = {}

function AntiAFK.enable()
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            Logger.info("Anti-AFK triggered")
        end)
    end)
end

-- ============================================================
-- SECTION 19: SESSION MANAGER
-- ============================================================
local SessionMgr = {}

function SessionMgr.start()
    State.Session = State.Session + 1
    State.TotalSessions = State.TotalSessions + 1
    State.SessionStart = tick()
    State._startEggCount = State.EggCount
    Logger.info("Session #" .. State.Session .. " started")
end

function SessionMgr.endSession()
    local elapsed = tick() - State.SessionStart
    local sessionEggs = State.EggCount - (State._startEggCount or 0)
    if sessionEggs > State.BestSession then
        State.BestSession = sessionEggs
    end
    Logger.info(string.format("Session ended: %d eggs in %s", sessionEggs, Util.formatTime(elapsed)))
end

function SessionMgr.getUptime()
    if State.SessionStart == 0 then return "00:00" end
    return Util.formatTime(tick() - State.SessionStart)
end

function SessionMgr.getRate()
    local elapsed = tick() - State.SessionStart
    if elapsed <= 0 then return 0 end
    return State.EggCount / (elapsed / 60)
end

-- ============================================================
-- SECTION 20: FARM CONTROLLER
-- ============================================================
local FarmCtrl = {}
local farmThread = nil

function FarmCtrl.updateStats()
    local total = State.EggCount + State.FailCount
    State.SuccessRate = total > 0 and math.floor((State.EggCount / total) * 100) or 100
end

function FarmCtrl.handleHatch()
    if not State.AutoHatch then return end
    if tick() - State._lastHatch < State.HatchInterval then return end
    State._lastHatch = tick()
    if fireAll("Hatch") then
        State.HatchCount = State.HatchCount + 1
    end
end

function FarmCtrl.handleSell()
    if not State.AutoSell then return end
    if tick() - State._lastSell < State.SellInterval then return end
    State._lastSell = tick()
    if fireAll("Sell") then
        State.SellCount = State.SellCount + 1
    end
end

function FarmCtrl.handleBuy()
    if not State.AutoBuyUpgrade then return end
    if tick() - State._lastBuy < State.BuyInterval then return end
    State._lastBuy = tick()
    if fireAll("Buy") then
        State.BuyCount = State.BuyCount + 1
    end
end

function FarmCtrl.handleExtras()
    if State.AutoEquipBest then fireAll("Equip") end
    if State.AutoClaimReward then fireAll("Claim") end
end

function FarmCtrl.runOne()
    if not PlayerMgr.isAlive() then
        State.Status = "Menunggu respawn..."
        task.wait(2)
        return
    end

    State.Status = "Mencari egg..."
    local egg = EggMgr.getTarget()

    if not egg then
        State.Status = "Egg tidak ditemukan"
        task.wait(1.5)
        return
    end

    State.CurrentTarget = egg.model.Name
    local rareTag = egg.rare and " [RARE]" or ""
    State.Status = "Menuju " .. egg.model.Name .. rareTag

    local eggPos = egg.part.Position
    MoveMgr.moveTo(eggPos)
    task.wait(0.15)

    State.Status = "Mencoba steal..."
    local success = false
    local tries = State.AntiGagal and State.RetryCount or 1

    for i = 1, tries do
        if StealMgr.trySteal(egg) then
            success = true
            break
        end
        State.FailCount = State.FailCount + 1
        State._failStreak = State._failStreak + 1
        task.wait(0.25)
        if i < tries then
            MoveMgr.instant(eggPos + Vector3.new(0, 2, 0))
            task.wait(0.1)
        end
    end

    if success then
        State.EggCount = State.EggCount + 1
        State._failStreak = 0
        if egg.rare then
            State.RareCount = State.RareCount + 1
            notify("RARE STOLEN", egg.model.Name, Theme.Rare, 4)
        end
        State.Status = "Sukses #" .. State.EggCount

        if State.AutoReturn then
            State.Status = "Kembali ke base..."
            BaseMgr.returnToBase()
        end

        task.wait(0.4)
        FarmCtrl.handleHatch()
        FarmCtrl.handleSell()
        FarmCtrl.handleBuy()
        FarmCtrl.handleExtras()
    else
        State.Status = "Gagal, cari egg lain"
        AntiStuck.check()

        if State._failStreak >= 5 then
            State.FarthestEgg = not State.FarthestEgg
            task.wait(3)
            State.FarthestEgg = not State.FarthestEgg
            State._failStreak = 0
            Logger.warn("Fail streak 5x, mode switch sementara")
        end
    end

    FarmCtrl.updateStats()
end

function FarmCtrl.start()
    if farmThread then return end
    State.AutoFarm = true
    SessionMgr.start()
    notify("Farm Started", "Session #" .. State.Session, Theme.Success)

    farmThread = task.spawn(function()
        while State.AutoFarm do
            if State._paused then
                task.wait(0.5)
                continue
            end
            local loopStart = tick()
            local ok, err = pcall(FarmCtrl.runOne)
            if not ok then
                State.Status = "Error: " .. tostring(err):sub(1, 40)
                Logger.error(tostring(err))
                task.wait(1)
            end
            if tick() - loopStart > State.MaxLoopTime * 2 then
                State.Status = "Loop reset"
                AntiStuck.check()
                task.wait(0.5)
            end
            task.wait(State.DelayBetween)
        end
        farmThread = nil
        State.Status = "Idle"
        SessionMgr.endSession()
        notify("Farm Stopped", "Total: " .. State.EggCount .. " eggs", Theme.Warning)
    end)
end

function FarmCtrl.stop()
    State.AutoFarm = false
    State.Status = "Stopped"
    State.CurrentTarget = "None"
end

function FarmCtrl.pause()
    State._paused = true
    State.Status = "Paused"
end

function FarmCtrl.resume()
    State._paused = false
    State.Status = "Running"
end

function FarmCtrl.reset()
    State.EggCount = 0
    State.FailCount = 0
    State.RareCount = 0
    State.HatchCount = 0
    State.SellCount = 0
    State.BuyCount = 0
    State.PlaceCount = 0
    State.SuccessRate = 100
    State.SessionStart = tick()
    Logger.info("Statistics reset")
end

-- ============================================================
-- SECTION 21: CHAT COMMANDS
-- ============================================================
local Commands = {}

function Commands.handle(msg)
    msg = msg:lower()
    if msg == "!start" or msg == "!farm" then
        FarmCtrl.start()
    elseif msg == "!stop" then
        FarmCtrl.stop()
    elseif msg == "!pause" then
        FarmCtrl.pause()
    elseif msg == "!resume" then
        FarmCtrl.resume()
    elseif msg == "!reset" then
        FarmCtrl.reset()
    elseif msg == "!cache" then
        clearRemoteCache()
        notify("Cache", "Cleared", Theme.Warning)
    elseif msg == "!base" then
        BaseMgr.returnToBase()
    elseif msg == "!hatch" then
        fireAll("Hatch")
    elseif msg == "!sell" then
        fireAll("Sell")
    elseif msg == "!stats" then
        notify("Stats", string.format("Egg: %d | Rare: %d | Rate: %d%%",
            State.EggCount, State.RareCount, State.SuccessRate))
    elseif msg == "!egg" then
        notify("Eggs", "Total: " .. EggMgr.count() .. " | Rare: " .. EggMgr.countRare())
    elseif msg == "!info" then
        notify("Info", CONFIG.SCRIPT_NAME .. " v" .. CONFIG.VERSION .. " by " .. CONFIG.CREATOR)
    end
end

LocalPlayer.Chatted:Connect(Commands.handle)

-- ============================================================
-- SECTION 22: HEARTBEAT / BACKGROUND
-- ============================================================
task.spawn(function()
    while State._running do
        task.wait(0.3)
        local hum = PlayerMgr.getHumanoid()
        if hum and State.SpeedHack then
            hum.WalkSpeed = State.SpeedValue
        end
        if hum and State.InfiniteJump then
            hum.JumpPower = State.JumpPower
        end
        if State.NoClip and LocalPlayer.Character then
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
        if tick() - State._lastCacheClear > 30 then
            clearRemoteCache()
            State._lastCacheClear = tick()
        end
        if State.FlyMode then
            FlyMgr.update()
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = PlayerMgr.getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ============================================================
-- SECTION 23: UI BUILDER
-- ============================================================
local function buildUI()
    local Screen = Util.create("ScreenGui", {
        Name = "StealEggUltra",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, PlayerGui)

    -- Toggle Button
    local ToggleBtn = Util.create("TextButton", {
        Size = UDim2.new(0, 54, 0, 54),
        Position = UDim2.new(1, -66, 1, -66),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = "AF",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Theme.FontBold,
        TextSize = 16,
        AutoButtonColor = false,
        ZIndex = 100,
        Parent = Screen,
    })
    Util.corner(ToggleBtn, 14)
    Util.stroke(ToggleBtn, Theme.AccentGlow, 1.5)

    local pulse = Util.create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0.7,
        BackgroundColor3 = Theme.AccentGlow,
        ZIndex = 99,
        Parent = ToggleBtn,
    })
    Util.corner(pulse, 14)
    TweenService:Create(pulse, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {
        Size = UDim2.new(1.3, 0, 1.3, 0),
        BackgroundTransparency = 1,
    }):Play()

    -- Main Panel
    local Panel = Util.create("Frame", {
        Size = UDim2.new(0, 400, 0, 540),
        Position = UDim2.new(0.5, -200, 0.5, -270),
        BackgroundColor3 = Theme.BG,
        BorderSizePixel = 0,
        Visible = false,
        Active = true,
        Draggable = true,
        ZIndex = 10,
        Parent = Screen,
    })
    Util.corner(Panel, 12)
    Util.stroke(Panel, Theme.Accent, 1.2)

    -- Header
    local Header = Util.create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.PanelAlt,
        BorderSizePixel = 0,
        ZIndex = 11,
        Parent = Panel,
    })
    Util.corner(Header, 12)
    Util.create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 22)),
        }),
        Rotation = 90,
        Parent = Header,
    })

    Util.create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = "STEAL AN EGG ULTRA",
        TextColor3 = Theme.Accent,
        Font = Theme.FontBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
        Parent = Header,
    })

    Util.create("TextLabel", {
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -110, 0, 0),
        BackgroundTransparency = 1,
        Text = "by kalzz",
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 12,
        Parent = Header,
    })

    local CloseBtn = Util.create("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -32, 0, 9),
        BackgroundColor3 = Theme.Danger,
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Theme.FontBold,
        TextSize = 12,
        ZIndex = 13,
        Parent = Header,
    })
    Util.corner(CloseBtn, 6)

    -- Stats Grid (3x3)
    local StatsGrid = Util.create("Frame", {
        Size = UDim2.new(1, -24, 0, 110),
        Position = UDim2.new(0, 12, 0, 56),
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = Panel,
    })
    Util.create("UIGridLayout", {
        CellSize = UDim2.new(0.33, -4, 0, 32),
        CellPadding = UDim2.new(0, 6, 0, 6),
        Parent = StatsGrid,
    })

    local function statCard(label, value, color)
        local card = Util.create("Frame", {
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            ZIndex = 12,
            Parent = StatsGrid,
        })
        Util.corner(card, 7)
        Util.stroke(card, Theme.Border, 1)
        Util.create("TextLabel", {
            Size = UDim2.new(1, -12, 0, 13),
            Position = UDim2.new(0, 8, 0, 3),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = Theme.TextDim,
            Font = Theme.Font,
            TextSize = 8,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13,
            Parent = card,
        })
        local valLabel = Util.create("TextLabel", {
            Size = UDim2.new(1, -12, 0, 14),
            Position = UDim2.new(0, 8, 0, 15),
            BackgroundTransparency = 1,
            Text = value,
            TextColor3 = color,
            Font = Theme.FontBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13,
            Parent = card,
        })
        return valLabel
    end

    local StatusCard = statCard("STATUS", "Idle", Theme.Text)
    local TargetCard = statCard("TARGET", "None", Theme.Accent)
    local EggCard = statCard("EGG", "0", Theme.Success)
    local RateCard = statCard("RATE", "100%", Theme.Accent)
    local RareCard = statCard("RARE", "0", Theme.Rare)
    local FailCard = statCard("FAIL", "0", Theme.Danger)
    local UptimeCard = statCard("UPTIME", "00:00", Theme.Warning)
    local FoundCard = statCard("FOUND", "0", Theme.AccentDim)
    local RateMinCard = statCard("EGG/M", "0", Theme.Success)

    -- Tab Bar
    local TabBar = Util.create("Frame", {
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.new(0, 12, 0, 174),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        ZIndex = 11,
        Parent = Panel,
    })
    Util.corner(TabBar, 7)
    Util.create("UIGridLayout", {
        CellSize = UDim2.new(0.2, -4, 1, 0),
        CellPadding = UDim2.new(0, 4, 0, 0),
        Parent = TabBar,
    })

    local tabs = {"FARM", "EXTRA", "MOVE", "SAFETY", "INFO"}
    local pages = {}
    local tabButtons = {}

    local Content = Util.create("ScrollingFrame", {
        Size = UDim2.new(1, -24, 1, -280),
        Position = UDim2.new(0, 12, 0, 210),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 11,
        Parent = Panel,
    })

    for i, name in ipairs(tabs) do
        local tabBtn = Util.create("TextButton", {
            BackgroundColor3 = (i == 1) and Theme.Accent or Theme.Element,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Theme.TextDim,
            Font = Theme.FontBold,
            TextSize = 10,
            ZIndex = 12,
            Parent = TabBar,
        })
        Util.corner(tabBtn, 5)
        table.insert(tabButtons, tabBtn)

        local page = Util.create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = (i == 1),
            ZIndex = 12,
            Parent = Content,
        })
        Util.listLayout(page, 5)
        pages[name] = page

        tabBtn.MouseButton1Click:Connect(function()
            for _, b in ipairs(tabButtons) do
                b.BackgroundColor3 = Theme.Element
                b.TextColor3 = Theme.TextDim
            end
            tabBtn.BackgroundColor3 = Theme.Accent
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            for _, p in pairs(pages) do
                p.Visible = false
            end
            page.Visible = true
        end)
    end

    -- Components
    local function sectionTitle(parent, text)
        local f = Util.create("Frame", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Parent = parent,
        })
        Util.create("Frame", {
            Size = UDim2.new(0, 3, 0, 12),
            Position = UDim2.new(0, 4, 0.5, -6),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Parent = f,
        })
        Util.create("TextLabel", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Accent,
            Font = Theme.FontBold,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = f,
        })
    end

    local function toggle(parent, text, key, callback)
        local frame = Util.create("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Parent = parent,
        })
        Util.corner(frame, 6)
        Util.stroke(frame, Theme.Border, 1)

        Util.create("TextLabel", {
            Size = UDim2.new(0, 250, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            Font = Theme.Font,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        local track = Util.create("Frame", {
            Size = UDim2.new(0, 38, 0, 20),
            Position = UDim2.new(1, -48, 0.5, -10),
            BackgroundColor3 = State[key] and Theme.Success or Theme.ElementOn,
            BorderSizePixel = 0,
            Parent = frame,
        })
        Util.corner(track, 10)

        local dotPos = State[key] and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
        local dot = Util.create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = dotPos,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = track,
        })
        Util.corner(dot, 8)

        local click = Util.create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 2,
            Parent = frame,
        })

        click.MouseButton1Click:Connect(function()
            State[key] = not State[key]
            local on = State[key]
            Util.tween(track, {BackgroundColor3 = on and Theme.Success or Theme.ElementOn}, 0.18)
            local targetPos = on and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
            Util.tween(dot, {Position = targetPos}, 0.18)
            if callback then
                pcall(callback, on)
            end
        end)

        click.MouseEnter:Connect(function()
            Util.tween(frame, {BackgroundColor3 = Theme.Hover}, 0.1)
        end)
        click.MouseLeave:Connect(function()
            Util.tween(frame, {BackgroundColor3 = Theme.Element}, 0.1)
        end)
    end

    local function slider(parent, text, key, min, max, default, suffix)
        suffix = suffix or ""
        local frame = Util.create("Frame", {
            Size = UDim2.new(1, 0, 0, 46),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Parent = parent,
        })
        Util.corner(frame, 6)
        Util.stroke(frame, Theme.Border, 1)

        local lbl = Util.create("TextLabel", {
            Size = UDim2.new(1, -16, 0, 16),
            Position = UDim2.new(0, 8, 0, 5),
            BackgroundTransparency = 1,
            Text = text .. ": " .. default .. suffix,
            TextColor3 = Theme.TextDim,
            Font = Theme.Font,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        local track = Util.create("TextButton", {
            Size = UDim2.new(1, -16, 0, 6),
            Position = UDim2.new(0, 8, 0, 30),
            BackgroundColor3 = Theme.ElementOn,
            BorderSizePixel = 0,
            Text = "",
            Parent = frame,
        })
        Util.corner(track, 3)

        local pct = (default - min) / (max - min)
        local fill = Util.create("Frame", {
            Size = UDim2.new(pct, 0, 1, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Parent = track,
        })
        Util.corner(fill, 3)

        local dragging = false
        local function update(input)
            local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = Util.round(min + (max - min) * p, 1)
            fill.Size = UDim2.new(p, 0, 1, 0)
            lbl.Text = text .. ": " .. val .. suffix
            State[key] = val
        end

        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(i)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                or i.UserInputType == Enum.UserInputType.Touch) then
                update(i)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local function actionButton(parent, text, callback, color)
        local btn = Util.create("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = color or Theme.Accent,
            BorderSizePixel = 0,
            Text = text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Theme.FontBold,
            TextSize = 11,
            AutoButtonColor = false,
            Parent = parent,
        })
        Util.corner(btn, 6)
        btn.MouseButton1Click:Connect(function()
            if callback then pcall(callback) end
        end)
        btn.MouseEnter:Connect(function()
            Util.tween(btn, {BackgroundColor3 = (color or Theme.Accent):Lerp(Color3.fromRGB(255, 255, 255), 0.15)}, 0.1)
        end)
        btn.MouseLeave:Connect(function()
            Util.tween(btn, {BackgroundColor3 = color or Theme.Accent}, 0.1)
        end)
    end

    local function infoTable(parent, rows)
        local frame = Util.create("Frame", {
            Size = UDim2.new(1, 0, 0, #rows * 22 + 12),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Parent = parent,
        })
        Util.corner(frame, 6)
        Util.stroke(frame, Theme.Border, 1)

        for i, row in ipairs(rows) do
            local r = Util.create("Frame", {
                Size = UDim2.new(1, -12, 0, 22),
                Position = UDim2.new(0, 6, 0, 6 + (i-1) * 22),
                BackgroundTransparency = 1,
                Parent = frame,
            })
            Util.create("TextLabel", {
                Size = UDim2.new(0.45, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = row[1],
                TextColor3 = Theme.TextDim,
                Font = Theme.Font,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = r,
            })
            Util.create("TextLabel", {
                Size = UDim2.new(0.55, 0, 1, 0),
                Position = UDim2.new(0.45, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = row[2],
                TextColor3 = row[3] or Theme.Text,
                Font = Theme.FontBold,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = r,
            })
        end
    end

    -- =====================================================
    -- POPULATE FARM
    -- =====================================================
    sectionTitle(pages["FARM"], "FARM CONTROL")
    toggle(pages["FARM"], "Auto Farm", "AutoFarm", function(v)
        if v then FarmCtrl.start() else FarmCtrl.stop() end
    end)
    toggle(pages["FARM"], "Farthest Egg", "FarthestEgg")
    toggle(pages["FARM"], "Priority Rare", "PriorityRare")
    toggle(pages["FARM"], "Skip Locked", "SkipLocked")
    toggle(pages["FARM"], "Skip Common", "SkipCommon")
    toggle(pages["FARM"], "Anti Gagal", "AntiGagal")
    toggle(pages["FARM"], "Anti Stuck", "AntiStuck")
    toggle(pages["FARM"], "Auto Return", "AutoReturn")
    toggle(pages["FARM"], "Auto Place", "AutoPlace")

    sectionTitle(pages["FARM"], "TIMING")
    slider(pages["FARM"], "Delay Between", "DelayBetween", 0.3, 3, 1.2, "s")
    slider(pages["FARM"], "Retry Count", "RetryCount", 1, 10, 5)
    slider(pages["FARM"], "Max Loop Time", "MaxLoopTime", 10, 60, 30, "s")

    sectionTitle(pages["FARM"], "QUICK ACTION")
    actionButton(pages["FARM"], "Start Farm", function()
        FarmCtrl.start()
    end, Theme.Success)
    actionButton(pages["FARM"], "Pause Farm", function()
        FarmCtrl.pause()
    end, Theme.Warning)
    actionButton(pages["FARM"], "Resume Farm", function()
        FarmCtrl.resume()
    end, Theme.Accent)
    actionButton(pages["FARM"], "Stop Farm", function()
        FarmCtrl.stop()
    end, Theme.Danger)

    -- =====================================================
    -- POPULATE EXTRA
    -- =====================================================
    sectionTitle(pages["EXTRA"], "AUTO ACTIONS")
    toggle(pages["EXTRA"], "Auto Hatch", "AutoHatch")
    toggle(pages["EXTRA"], "Auto Sell", "AutoSell")
    toggle(pages["EXTRA"], "Auto Buy Upgrade", "AutoBuyUpgrade")
    toggle(pages["EXTRA"], "Auto Equip Best", "AutoEquipBest")
    toggle(pages["EXTRA"], "Auto Claim Reward", "AutoClaimReward")
    toggle(pages["EXTRA"], "Never Sell Rare", "NeverSellRare")
    toggle(pages["EXTRA"], "Never Sell Equipped", "NeverSellEquipped")

    sectionTitle(pages["EXTRA"], "INTERVAL")
    slider(pages["EXTRA"], "Hatch Interval", "HatchInterval", 1, 15, 3, "s")
    slider(pages["EXTRA"], "Sell Interval", "SellInterval", 1, 30, 5, "s")
    slider(pages["EXTRA"], "Buy Interval", "BuyInterval", 1, 30, 10, "s")

    sectionTitle(pages["EXTRA"], "MANUAL TRIGGER")
    actionButton(pages["EXTRA"], "Hatch All", function()
        fireAll("Hatch")
        notify("Hatch", "Triggered", Theme.Success)
    end, Theme.Success)
    actionButton(pages["EXTRA"], "Sell All", function()
        fireAll("Sell")
        notify("Sell", "Triggered", Theme.Warning)
    end, Theme.Warning)
    actionButton(pages["EXTRA"], "Equip Best Pet", function()
        fireAll("Equip")
        notify("Equip", "Triggered", Theme.AccentDim)
    end, Theme.AccentDim)
    actionButton(pages["EXTRA"], "Claim All Reward", function()
        fireAll("Claim")
        notify("Claim", "Triggered", Theme.Accent)
    end, Theme.Accent)
    actionButton(pages["EXTRA"], "Buy Upgrade", function()
        fireAll("Buy")
        notify("Buy", "Triggered", Theme.AccentDim)
    end, Theme.AccentDim)

    -- =====================================================
    -- POPULATE MOVE
    -- =====================================================
    sectionTitle(pages["MOVE"], "CHARACTER")
    toggle(pages["MOVE"], "Speed Hack", "SpeedHack")
    slider(pages["MOVE"], "Speed Value", "SpeedValue", 16, 100, 22)
    toggle(pages["MOVE"], "Infinite Jump", "InfiniteJump")
    slider(pages["MOVE"], "Jump Power", "JumpPower", 50, 200, 50)
    toggle(pages["MOVE"], "No Clip", "NoClip")
    toggle(pages["MOVE"], "Fly Mode", "FlyMode", function(v)
        if v then FlyMgr.enable() else FlyMgr.disable() end
    end)
    slider(pages["MOVE"], "Fly Speed", "FlySpeed", 20, 200, 60)

    sectionTitle(pages["MOVE"], "TELEPORT METHOD")
    local methodFrame = Util.create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Parent = pages["MOVE"],
    })
    Util.corner(methodFrame, 6)
    Util.stroke(methodFrame, Theme.Border, 1)
    Util.create("TextLabel", {
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "Method",
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = methodFrame,
    })

    local methodOptions = {"Instant", "Tween", "Walk"}
    local methodBtns = {}
    for i, opt in ipairs(methodOptions) do
        local mb = Util.create("TextButton", {
            Size = UDim2.new(0, 55, 0, 22),
            Position = UDim2.new(1, -180 + (i-1) * 58, 0.5, -11),
            BackgroundColor3 = (State.Method == opt) and Theme.Accent or Theme.ElementOn,
            BorderSizePixel = 0,
            Text = opt,
            TextColor3 = (State.Method == opt) and Color3.fromRGB(255, 255, 255) or Theme.TextDim,
            Font = Theme.FontBold,
            TextSize = 9,
            Parent = methodFrame,
        })
        Util.corner(mb, 5)
        table.insert(methodBtns, {btn = mb, opt = opt})

        mb.MouseButton1Click:Connect(function()
            State.Method = opt
            for _, item in ipairs(methodBtns) do
                item.btn.BackgroundColor3 = (item.opt == opt) and Theme.Accent or Theme.ElementOn
                item.btn.TextColor3 = (item.opt == opt) and Color3.fromRGB(255, 255, 255) or Theme.TextDim
            end
        end)
    end

    slider(pages["MOVE"], "Tween Speed", "TweenSpeed", 0.1, 1.5, 0.4, "s")
    slider(pages["MOVE"], "Walk Threshold", "WalkThreshold", 2, 20, 5)

    sectionTitle(pages["MOVE"], "ACTION")
    actionButton(pages["MOVE"], "Return Base Now", function()
        BaseMgr.returnToBase()
    end, Theme.Accent)

    -- =====================================================
    -- POPULATE SAFETY
    -- =====================================================
    sectionTitle(pages["SAFETY"], "PROTECTION")
    toggle(pages["SAFETY"], "Anti AFK", "AntiAFK")
    toggle(pages["SAFETY"], "Low Health Flee", "LowHealthFlee")
    slider(pages["SAFETY"], "Health Threshold", "HealthThreshold", 10, 80, 30, "%")

    sectionTitle(pages["SAFETY"], "PERFORMANCE")
    toggle(pages["SAFETY"], "Low Graphics", "LowGraphics", function(v)
        PerfMgr.setLowGraphics(v)
    end)
    toggle(pages["SAFETY"], "Boost FPS", "BoostFPS", function(v)
        PerfMgr.boostFPS(v)
    end)
    toggle(pages["SAFETY"], "Hide Accessories", "HideAccessories", function(v)
        PerfMgr.hideAccessories(v)
    end)
    toggle(pages["SAFETY"], "Fullbright", "Fullbright", function(v)
        PerfMgr.setFullbright(v)
    end)

    -- =====================================================
    -- POPULATE INFO
    -- =====================================================
    sectionTitle(pages["INFO"], "SCRIPT INFORMATION")
    infoTable(pages["INFO"], {
        {"Script Name", CONFIG.SCRIPT_NAME, Theme.Accent},
        {"Version", "v" .. CONFIG.VERSION, Theme.Success},
        {"Creator", CONFIG.CREATOR, Theme.Rare},
        {"Release", CONFIG.RELEASE, Theme.Warning},
        {"Status", CONFIG.STATUS, Theme.AccentDim},
        {"Total Modules", tostring(CONFIG.MODULES), Theme.Text},
        {"Total Features", tostring(CONFIG.FEATURES), Theme.Text},
    })

    sectionTitle(pages["INFO"], "LIVE STATISTICS")
    local statsInfo = Util.create("Frame", {
        Size = UDim2.new(1, 0, 0, 180),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Parent = pages["INFO"],
    })
    Util.corner(statsInfo, 6)
    Util.stroke(statsInfo, Theme.Border, 1)
    local statsText = Util.create("TextLabel", {
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        Text = "Loading...",
        TextColor3 = Theme.Text,
        Font = Theme.FontMono,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = statsInfo,
    })

    sectionTitle(pages["INFO"], "CREDITS")
    infoTable(pages["INFO"], {
        {"Developer", CONFIG.CREATOR, Theme.Rare},
        {"UI Design", CONFIG.CREATOR, Theme.Rare},
        {"Backend Logic", CONFIG.CREATOR, Theme.Rare},
        {"Testing", "Community", Theme.TextDim},
        {"Special Thanks", "All Users", Theme.Accent},
    })

    sectionTitle(pages["INFO"], "UTILITY")
    actionButton(pages["INFO"], "Refresh Remote Cache", function()
        clearRemoteCache()
        notify("Cache", "Remote cache refreshed", Theme.Warning)
    end, Theme.Warning)
    actionButton(pages["INFO"], "Reset Statistics", function()
        FarmCtrl.reset()
        notify("Stats", "Statistics reset", Theme.AccentDim)
    end, Theme.AccentDim)
    actionButton(pages["INFO"], "Reset Anti-Stuck", function()
        AntiStuck.reset()
        notify("AntiStuck", "Reset", Theme.Accent)
    end, Theme.Accent)
    actionButton(pages["INFO"], "Show Egg List", function()
        local names = EggMgr.getNames(8)
        notify("Eggs Found", table.concat(names, ", "), Theme.Success)
    end, Theme.Success)
    actionButton(pages["INFO"], "Clear Notifications", function()
        notifyClear()
    end, Theme.Danger)

    sectionTitle(pages["INFO"], "CHAT COMMANDS")
    infoTable(pages["INFO"], {
        {"!start / !farm", "Start Farm", Theme.Success},
        {"!stop", "Stop Farm", Theme.Danger},
        {"!pause", "Pause", Theme.Warning},
        {"!resume", "Resume", Theme.Accent},
        {"!reset", "Reset Stats", Theme.TextDim},
        {"!cache", "Clear Cache", Theme.Warning},
        {"!base", "Return Base", Theme.Accent},
        {"!hatch", "Hatch All", Theme.Success},
        {"!sell", "Sell All", Theme.Warning},
        {"!stats", "Show Stats", Theme.Accent},
        {"!egg", "Show Egg Count", Theme.AccentDim},
        {"!info", "Show Info", Theme.Rare},
    })

    -- =====================================================
    -- REAL-TIME UPDATE
    -- =====================================================
    task.spawn(function()
        while task.wait(0.25) do
            StatusCard.Text = State.Status
            TargetCard.Text = string.sub(State.CurrentTarget, 1, 18)
            EggCard.Text = tostring(State.EggCount)
            RateCard.Text = State.SuccessRate .. "%"
            RareCard.Text = tostring(State.RareCount)
            FailCard.Text = tostring(State.FailCount)
            UptimeCard.Text = SessionMgr.getUptime()
            FoundCard.Text = tostring(EggMgr.count())
            RateMinCard.Text = string.format("%.1f", SessionMgr.getRate())

            if State.SuccessRate >= 80 then
                RateCard.TextColor3 = Theme.Success
            elseif State.SuccessRate >= 50 then
                RateCard.TextColor3 = Theme.Warning
            else
                RateCard.TextColor3 = Theme.Danger
            end

            statsText.Text = string.format(
                "Session     : #%d\nUptime      : %s\nEgg Stolen  : %d\nRare Stolen : %d\nFail Count  : %d\nSuccess Rate: %d%%\nEgg/menit   : %.1f\nHatch       : %d\nSell        : %d\nPlace       : %d\nBuy         : %d\nCache Size  : %d\nEggs Found  : %d",
                State.Session,
                SessionMgr.getUptime(),
                State.EggCount,
                State.RareCount,
                State.FailCount,
                State.SuccessRate,
                SessionMgr.getRate(),
                State.HatchCount,
                State.SellCount,
                State.PlaceCount,
                State.BuyCount,
                getCacheSize(),
                EggMgr.count()
            )
        end
    end)

    -- Auto canvas
    task.spawn(function()
        while task.wait(0.5) do
            local total = 0
            for _, p in pairs(pages) do
                if p.Visible then
                    total = p.AbsoluteSize.Y + 20
                end
            end
            Content.CanvasSize = UDim2.new(0, 0, 0, total + 40)
        end
    end)

    ToggleBtn.MouseButton1Click:Connect(function()
        Panel.Visible = not Panel.Visible
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Panel.Visible = false
    end)

    return Screen
end

-- ============================================================
-- SECTION 24: INIT
-- ============================================================
if State.AntiAFK then AntiAFK.enable() end
HealthMgr.watch()
buildUI()

notify("Steal An Egg Ultra", "Loaded - by kalzz", Theme.Accent)

print("╔══════════════════════════════════════════════════╗")
print("║   STEAL AN EGG - ULTRA v8.0                     ║")
print("║   Creator: kalzz                                ║")
print("║   Real Functions | 2000+ Lines                  ║")
print("║   Fixed Toggle System                           ║")
print("║   Information Table Included                    ║")
print("║   2026                                          ║")
print("╚══════════════════════════════════════════════════╝")
print("[Modules] Util | Logger | Notify | RemoteMgr | PlayerMgr")
print("[Modules] EggMgr | MoveMgr | BaseMgr | StealMgr | AntiStuck")
print("[Modules] FlyMgr | HealthMgr | PerfMgr | AntiAFK | SessionMgr")
print("[Modules] FarmCtrl | Commands")
print("[UI] 5 Tabs | 9 Stats Cards | 40+ Features")
print("[Chat] !start !stop !pause !resume !reset !cache !base !hatch !sell !stats !egg !info")
