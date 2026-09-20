--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║   STEAL AN EGG - MIDNIGHT ULTRA                             ║
    ║   Black Aesthetic UI (500+) + Working Farm (1500+)          ║
    ║   Mobile Optimized | Delta Ready                            ║
    ║   Creator: kalzz | 2026                                     ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- ════════════════════════════════════════════════════════════
-- [PART 1] SERVICES
-- ════════════════════════════════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting          = game:GetService("Lighting")
local VirtualUser       = game:GetService("VirtualUser")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")

-- ════════════════════════════════════════════════════════════
-- [PART 2] CONFIG
-- ════════════════════════════════════════════════════════════
local CONFIG = {
    NAME = "Steal An Egg Midnight Ultra",
    VERSION = "12.0",
    CREATOR = "kalzz",
    YEAR = "2026",
}

-- ════════════════════════════════════════════════════════════
-- [PART 3] DEVICE DETECTION
-- ════════════════════════════════════════════════════════════
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local IS_TABLET = UserInputService.TouchEnabled and UserInputService.MouseEnabled
local IS_PC = not UserInputService.TouchEnabled

local UI_SCALE = IS_MOBILE and 0.95 or (IS_TABLET and 0.9 or 1)
local PANEL_W = math.floor(360 * UI_SCALE)
local PANEL_H = math.floor(520 * UI_SCALE)
local BTN_SIZE = IS_MOBILE and 60 or 54

-- ════════════════════════════════════════════════════════════
-- [PART 4] STATE
-- ════════════════════════════════════════════════════════════
local State = {
    -- Farm
    AutoFarm        = false,
    PriorityLimited = true,
    PriorityRare    = true,
    FarthestEgg     = true,
    SkipLocked      = true,
    SkipCommon      = false,
    AntiGagal       = true,
    AutoReturn      = true,
    AutoPlace       = true,
    AutoHatch       = false,
    AutoSell        = false,
    AutoBuy         = false,
    AutoEquip       = false,
    AutoClaim       = false,

    -- Movement
    SpeedHack       = false,
    InfiniteJump    = false,
    NoClip          = false,
    Fly             = false,
    SpeedValue      = 22,
    JumpPower       = 50,
    FlySpeed        = 60,
    Method          = "Instant",

    -- Safety
    AntiAFK         = true,
    LowHealthFlee   = false,
    HealthThreshold = 30,

    -- Visual
    Fullbright      = false,
    LowGraphics     = false,

    -- Timing
    RetryCount      = 5,
    DelayBetween    = 1.2,
    HatchInterval   = 3,
    SellInterval    = 5,

    -- Stats
    EggCount        = 0,
    FailCount       = 0,
    LimitedCount    = 0,
    RareCount       = 0,
    HatchCount      = 0,
    SellCount       = 0,
    PlaceCount      = 0,
    SuccessRate     = 100,
    Status          = "Idle",
    CurrentTarget   = "None",
    Session         = 0,
    SessionStart    = 0,
    BestSession     = 0,

    -- Internal
    _lastPos        = Vector3.new(0, 0, 0),
    _stuckCount     = 0,
    _failStreak     = 0,
    _lastHatch      = 0,
    _lastSell       = 0,
    _lastCacheClear = 0,
    _startEggCount  = 0,
    _flyBV          = nil,
    _flyBG          = nil,
    _paused         = false,
}

-- ════════════════════════════════════════════════════════════
-- [PART 5] THEME (Black Aesthetic)
-- ════════════════════════════════════════════════════════════
local Palette = {
    Black0     = Color3.fromRGB(0, 0, 0),
    Black1     = Color3.fromRGB(8, 8, 10),
    Black2     = Color3.fromRGB(14, 14, 18),
    Black3     = Color3.fromRGB(20, 20, 26),
    Black4     = Color3.fromRGB(28, 28, 36),
    Black5     = Color3.fromRGB(38, 38, 48),

    White      = Color3.fromRGB(255, 255, 255),
    OffWhite   = Color3.fromRGB(235, 235, 240),
    Gray1      = Color3.fromRGB(180, 180, 190),
    Gray2      = Color3.fromRGB(120, 120, 135),
    Gray3      = Color3.fromRGB(80, 80, 95),

    Cyan       = Color3.fromRGB(0, 220, 255),
    CyanDim    = Color3.fromRGB(0, 140, 180),
    Green      = Color3.fromRGB(0, 220, 130),
    GreenDim   = Color3.fromRGB(0, 140, 80),
    Red        = Color3.fromRGB(255, 70, 90),
    RedDim     = Color3.fromRGB(180, 40, 60),
    Yellow     = Color3.fromRGB(255, 200, 70),
    Purple     = Color3.fromRGB(160, 110, 255),
    Pink       = Color3.fromRGB(255, 110, 200),
    Gold       = Color3.fromRGB(255, 215, 0),
}

local Font = {
    Bold   = Enum.Font.GothamBold,
    Medium = Enum.Font.GothamMedium,
    Normal = Enum.Font.Gotham,
    Mono   = Enum.Font.Code,
}

local Size = {
    H1 = 18, H2 = 15, H3 = 13,
    Body = 12, Small = 10, Tiny = 9,
}

-- ════════════════════════════════════════════════════════════
-- [PART 6] UTILITY
-- ════════════════════════════════════════════════════════════
local Util = {}

function Util.mk(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

function Util.rounded(obj, r)
    return Util.mk("UICorner", {CornerRadius = UDim.new(0, r or 8)}, obj)
end

function Util.border(obj, color, th)
    return Util.mk("UIStroke", {
        Color = color or Palette.Black5,
        Thickness = th or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, obj)
end

function Util.grad(obj, colors, rot)
    return Util.mk("UIGradient", {
        Color = ColorSequence.new(colors),
        Rotation = rot or 90,
    }, obj)
end

function Util.pad(obj, t, b, l, r)
    return Util.mk("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
    }, obj)
end

function Util.list(obj, spacing, order)
    return Util.mk("UIListLayout", {
        Padding = UDim.new(0, spacing or 6),
        SortOrder = order or Enum.SortOrder.LayoutOrder,
    }, obj)
end

function Util.grid(obj, cell, padding)
    return Util.mk("UIGridLayout", {
        CellSize = cell,
        CellPadding = padding or UDim2.new(0, 6, 0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, obj)
end

function Util.anim(obj, props, dur, style, dir)
    TweenService:Create(
        obj,
        TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

function Util.dist(a, b)
    return (a - b).Magnitude
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

function Util.safe(fn, ...)
    local ok, r = pcall(fn, ...)
    return ok and r or nil
end

-- ════════════════════════════════════════════════════════════
-- [PART 7] LOGGER
-- ════════════════════════════════════════════════════════════
local Logger = {}
local logHistory = {}

function Logger.add(level, msg)
    local entry = {time = os.date("%H:%M:%S"), level = level, msg = msg}
    table.insert(logHistory, entry)
    if #logHistory > 200 then table.remove(logHistory, 1) end
    print(string.format("[%s][%s] %s", entry.time, level, msg))
end

function Logger.info(m) Logger.add("INFO", m) end
function Logger.warn(m) Logger.add("WARN", m) end
function Logger.error(m) Logger.add("ERROR", m) end

-- ════════════════════════════════════════════════════════════
-- [PART 8] NOTIFY SYSTEM
-- ════════════════════════════════════════════════════════════
local notifyGui = nil
local activeNotifs = {}

local function ensureNotify()
    if notifyGui and notifyGui.Parent then return notifyGui end
    notifyGui = Util.mk("ScreenGui", {
        Name = "EggNotify",
        ResetOnSpawn = false,
        Parent = PlayerGui,
    })
    return notifyGui
end

local function notify(title, msg, color, dur)
    ensureNotify()
    color = color or Palette.Cyan
    dur = dur or 3

    local f = Util.mk("Frame", {
        Size = UDim2.new(0, 250, 0, 58),
        Position = UDim2.new(1, 12, 0, 12),
        BackgroundColor3 = Palette.Black2,
        BorderSizePixel = 0,
        Parent = notifyGui,
    })
    Util.rounded(f, 10)
    local st = Util.border(f, color, 1)
    st.Transparency = 0.4

    Util.mk("Frame", {
        Size = UDim2.new(0, 3, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = f,
    })

    Util.mk("TextLabel", {
        Size = UDim2.new(1, -22, 0, 18),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Palette.White,
        Font = Font.Bold,
        TextSize = Size.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f,
    })

    Util.mk("TextLabel", {
        Size = UDim2.new(1, -22, 0, 24),
        Position = UDim2.new(0, 14, 0, 28),
        BackgroundTransparency = 1,
        Text = msg,
        TextColor3 = Palette.Gray2,
        Font = Font.Normal,
        TextSize = Size.Small,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = f,
    })

    Util.anim(f, {Position = UDim2.new(1, -262, 0, 12)}, 0.4, Enum.EasingStyle.Back)
    table.insert(activeNotifs, f)

    task.delay(dur, function()
        if f and f.Parent then
            Util.anim(f, {Position = UDim2.new(1, 12, 0, 12)}, 0.3)
            task.wait(0.35)
            for i, n in ipairs(activeNotifs) do
                if n == f then table.remove(activeNotifs, i); break end
            end
            f:Destroy()
        end
    end)
end

local function notifyClear()
    for _, f in ipairs(activeNotifs) do
        if f and f.Parent then f:Destroy() end
    end
    activeNotifs = {}
end

-- ════════════════════════════════════════════════════════════
-- [PART 9] REMOTE MANAGER
-- ════════════════════════════════════════════════════════════
local RemoteCache = {}
local RemoteStats = {fired = 0, failed = 0}

local REMOTES = {
    Steal = {"StealEgg","Steal","GrabEgg","PickEgg","EggSteal","CollectEgg","TakeEgg","Grab","Collect"},
    Place = {"PlaceEgg","Place","DropEgg","EggPlace","PlacePet","Deposit","Store"},
    Hatch = {"HatchEgg","Hatch","EggHatch","OpenEgg","HatchAll","HatchPet"},
    Sell  = {"SellEgg","Sell","SellPet","SellAll","SellInventory","SellPets"},
    Buy   = {"BuyUpgrade","PurchaseUpgrade","BuyEgg","BuyItem","Upgrade","Purchase"},
    Equip = {"EquipBest","AutoEquip","EquipPet","Equip"},
    Claim = {"ClaimReward","ClaimAll","ClaimDaily","ClaimAllReward"},
    Rebirth = {"Rebirth","DoRebirth","RebirthEvent"},
}

local function findRemote(key)
    local list = REMOTES[key]
    if not list then return nil end
    for _, name in ipairs(list) do
        if RemoteCache[name] and RemoteCache[name].Parent then
            return RemoteCache[name]
        end
        local r = ReplicatedStorage:FindFirstChild(name, true)
        if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
            RemoteCache[name] = r
            Logger.info("Remote found: " .. name)
            return r
        end
    end
    return nil
end

local function fireAll(key, ...)
    local list = REMOTES[key]
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
end

local function cacheSize()
    local n = 0
    for _ in pairs(RemoteCache) do n = n + 1 end
    return n
end

-- ════════════════════════════════════════════════════════════
-- [PART 10] PLAYER MANAGER
-- ════════════════════════════════════════════════════════════
local function getRoot()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function isAlive()
    local h = getHum()
    return h ~= nil and h.Health > 0
end

local function healthPct()
    local h = getHum()
    if not h or h.MaxHealth <= 0 then return 0 end
    return (h.Health / h.MaxHealth) * 100
end

local function getTools()
    local tools = {}
    local c = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if c then
        for _, t in ipairs(c:GetChildren()) do
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

-- ════════════════════════════════════════════════════════════
-- [PART 11] EGG MANAGER (Tier Detection)
-- ════════════════════════════════════════════════════════════
local LIMITED_KW = {
    "limited","event","exclusive","seasonal","collab","special",
    "secret","hidden","bundle","mythical",
}
local RARE_KW = {
    "rare","epic","legendary","mythic","huge","large","golden",
    "galaxy","cosmic","divine","rainbow","shiny","crystalline",
    "void","celestial","godly","prismatic",
}
local COMMON_KW = {
    "common","basic","normal","starter","beginner","simple",
}
local LOCK_KW = {"lock","key","require","unlock","need","restrict"}

local function matchKW(name, list)
    local n = name:lower()
    for _, k in ipairs(list) do
        if n:find(k) then return true end
    end
    return false
end

local function getTier(model)
    if model:GetAttribute("Limited") == true then return "LIMITED" end
    if model:GetAttribute("IsLimited") == true then return "LIMITED" end
    if model:GetAttribute("Rare") == true then return "RARE" end

    for _, c in ipairs(model:GetChildren()) do
        if c:IsA("BoolValue") and c.Value then
            local cn = c.Name:lower()
            if cn:find("limited") or cn:find("event") or cn:find("exclusive") then
                return "LIMITED"
            end
            if cn:find("rare") or cn:find("epic") then
                return "RARE"
            end
        end
    end

    if matchKW(model.Name, LIMITED_KW) then return "LIMITED" end
    if matchKW(model.Name, RARE_KW) then return "RARE" end
    if matchKW(model.Name, COMMON_KW) then return "COMMON" end
    return "NORMAL"
end

local function isLocked(model)
    for _, ch in ipairs(model:GetChildren()) do
        local cn = ch.Name:lower()
        for _, k in ipairs(LOCK_KW) do
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

local function getAllEggs()
    local list = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("egg") then
            local base = obj:FindFirstChild("Base")
                or obj:FindFirstChild("BasePart")
                or obj.PrimaryPart
                or obj:FindFirstChildWhichIsA("BasePart", true)
            if base then
                local locked = isLocked(obj)
                local tier = getTier(obj)
                local skip = false
                if State.SkipLocked and locked then skip = true end
                if State.SkipCommon and tier == "COMMON" then skip = true end
                if not skip then
                    table.insert(list, {
                        model = obj,
                        part = base,
                        tier = tier,
                        locked = locked,
                    })
                end
            end
        end
    end
    return list
end

local function getTarget()
    local eggs = getAllEggs()
    if #eggs == 0 then return nil end
    local root = getRoot()
    if not root then return nil end

    local rank = {LIMITED = 1, RARE = 2, NORMAL = 3, COMMON = 4}

    table.sort(eggs, function(a, b)
        local ra = rank[a.tier] or 99
        local rb = rank[b.tier] or 99

        if not State.PriorityLimited and a.tier == "LIMITED" then ra = 99 end
        if not State.PriorityLimited and b.tier == "LIMITED" then rb = 99 end
        if not State.PriorityRare and a.tier == "RARE" then ra = 99 end
        if not State.PriorityRare and b.tier == "RARE" then rb = 99 end

        if ra ~= rb then return ra < rb end

        local da = Util.dist(a.part.Position, root.Position)
        local db = Util.dist(b.part.Position, root.Position)

        if State.FarthestEgg then
            return da > db
        else
            return da < db
        end
    end)

    return eggs[1]
end

local function eggCount()
    return #getAllEggs()
end

local function eggCountTier(tier)
    local n = 0
    for _, e in ipairs(getAllEggs()) do
        if e.tier == tier then n = n + 1 end
    end
    return n
end

-- ════════════════════════════════════════════════════════════
-- [PART 12] MOVEMENT MANAGER
-- ════════════════════════════════════════════════════════════
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

local function moveWalk(pos, timeout)
    local hum = getHum()
    if not hum then return false end
    timeout = timeout or 15
    hum:MoveTo(pos)
    local start = tick()
    while tick() - start < timeout do
        local root = getRoot()
        if not root then break end
        if Util.dist(root.Position, pos) < 5 then return true end
        task.wait(0.1)
    end
    return false
end

local function moveTo(pos)
    if State.Method == "Instant" then return moveInstant(pos)
    elseif State.Method == "Tween" then return moveTween(pos)
    elseif State.Method == "Walk" then return moveWalk(pos)
    end
    return false
end

-- ════════════════════════════════════════════════════════════
-- [PART 13] FLY MANAGER
-- ════════════════════════════════════════════════════════════
local function flyEnable()
    if State._flyBV then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "EggFlyBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.zero
    bv.Parent = root
    State._flyBV = bv

    local bg = Instance.new("BodyGyro")
    bg.Name = "EggFlyBG"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 1000
    bg.D = 50
    bg.Parent = root
    State._flyBG = bg

    Logger.info("Fly enabled")
end

local function flyDisable()
    if State._flyBV then State._flyBV:Destroy(); State._flyBV = nil end
    if State._flyBG then State._flyBG:Destroy(); State._flyBG = nil end
    Logger.info("Fly disabled")
end

local function flyUpdate()
    if not State.Fly then return end
    local root = getRoot()
    if not root or not State._flyBV then return end
    local cam = Workspace.CurrentCamera
    local move = Vector3.zero

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end

    if move.Magnitude > 0 then move = move.Unit * State.FlySpeed end
    State._flyBV.Velocity = move
    State._flyBG.CFrame = cam.CFrame
end

-- ════════════════════════════════════════════════════════════
-- [PART 14] BASE MANAGER
-- ════════════════════════════════════════════════════════════
local BASE_KW = {"base", "pen", "nest", "drop", "home", "farm"}

local function getBase()
    local root = getRoot()
    if not root then return nil end
    local nearest, minD = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            for _, k in ipairs(BASE_KW) do
                if n:find(k) then
                    local d = Util.dist(obj.Position, root.Position)
                    if d < minD then minD = d; nearest = obj end
                    break
                end
            end
        end
    end
    return nearest
end

local function returnToBase()
    local b = getBase()
    if not b then return false end
    moveTo(b.Position)
    task.wait(0.3)
    if State.AutoPlace then
        if fireAll("Place") then
            State.PlaceCount = State.PlaceCount + 1
        end
    end
    return true
end

-- ════════════════════════════════════════════════════════════
-- [PART 15] STEAL MANAGER
-- ════════════════════════════════════════════════════════════
local function tryPrompt(model)
    local prompt = model:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        Util.safe(function() fireproximityprompt(prompt) end)
        task.wait(0.1)
        return true
    end
    return false
end

local function tryClick(model)
    local click = model:FindFirstChildOfClass("ClickDetector")
    if click then
        Util.safe(function() fireclickdetector(click) end)
        return true
    end
    return false
end

local function tryRemote(model, part)
    fireAll("Steal", model); task.wait(0.05)
    fireAll("Steal", part); task.wait(0.05)
    fireAll("Steal", model, part); task.wait(0.05)
    fireAll("Steal")
    return true
end

local function tryTool()
    local char = LocalPlayer.Character
    if not char then return false end
    local found = false
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then
            local tn = t.Name:lower()
            if tn:find("steal") or tn:find("grab") or tn:find("hand") or tn:find("net") then
                Util.safe(function() t:Activate() end)
                found = true
            end
        end
    end
    return found
end

local function trySteal(eggData)
    local model = eggData.model
    local part = eggData.part

    tryPrompt(model)
    tryClick(model)
    tryRemote(model, part)
    tryTool()

    task.wait(0.4)
    if not model.Parent then return true end
    local root = getRoot()
    if root and Util.dist(root.Position, part.Position) > 15 then return true end
    return false
end

-- ════════════════════════════════════════════════════════════
-- [PART 16] ANTI STUCK
-- ════════════════════════════════════════════════════════════
local function antiStuck()
    local root = getRoot()
    if not root then return end
    local now = root.Position
    if Util.dist(now, State._lastPos) < 1.5 then
        State._stuckCount = State._stuckCount + 1
        if State._stuckCount >= 3 then
            local offset = Vector3.new(math.random(-8, 8), 0, math.random(-8, 8))
            root.CFrame = root.CFrame + offset
            State._stuckCount = 0
            Logger.warn("Anti-stuck triggered")
        end
    else
        State._stuckCount = 0
    end
    State._lastPos = now
end

-- ════════════════════════════════════════════════════════════
-- [PART 17] HEALTH MANAGER
-- ════════════════════════════════════════════════════════════
local function tryHeal()
    local tools = getTools()
    for _, t in ipairs(tools) do
        local tn = t.Name:lower()
        if tn:find("medkit") or tn:find("bandage") or tn:find("health") or tn:find("potion") then
            if t.Parent ~= LocalPlayer.Character then
                t.Parent = LocalPlayer.Character
            end
            task.wait(0.1)
            Util.safe(function() t:Activate() end)
            return true
        end
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(1)
        if State.LowHealthFlee and healthPct() > 0 and healthPct() < State.HealthThreshold then
            notify("Low Health", math.floor(healthPct()) .. "%", Palette.Red)
            tryHeal()
            returnToBase()
        end
    end
end)

-- ════════════════════════════════════════════════════════════
-- [PART 18] PERFORMANCE MANAGER
-- ════════════════════════════════════════════════════════════
local function setLowGraphics(enabled)
    if enabled then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
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

local function setFullbright(enabled)
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

-- ════════════════════════════════════════════════════════════
-- [PART 19] ANTI AFK
-- ════════════════════════════════════════════════════════════
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        Logger.info("Anti-AFK triggered")
    end)
end)

-- ════════════════════════════════════════════════════════════
-- [PART 20] FARM CONTROLLER (MAIN LOOP)
-- ════════════════════════════════════════════════════════════
local farmThread = nil

local function updateStats()
    local total = State.EggCount + State.FailCount
    State.SuccessRate = total > 0 and math.floor((State.EggCount / total) * 100) or 100
end

local function handleHatch()
    if not State.AutoHatch then return end
    if tick() - State._lastHatch < State.HatchInterval then return end
    State._lastHatch = tick()
    if fireAll("Hatch") then
        State.HatchCount = State.HatchCount + 1
    end
end

local function handleSell()
    if not State.AutoSell then return end
    if tick() - State._lastSell < State.SellInterval then return end
    State._lastSell = tick()
    if fireAll("Sell") then
        State.SellCount = State.SellCount + 1
    end
end

local function handleExtras()
    if State.AutoEquip then fireAll("Equip") end
    if State.AutoClaim then fireAll("Claim") end
    if State.AutoBuy then fireAll("Buy") end
end

local function runOne()
    if not isAlive() then
        State.Status = "Waiting respawn"
        task.wait(2)
        return
    end

    State.Status = "Searching egg"
    local egg = getTarget()

    if not egg then
        State.Status = "No egg found"
        task.wait(1.5)
        return
    end

    State.CurrentTarget = egg.model.Name
    State.Status = "To " .. egg.model.Name .. " [" .. egg.tier .. "]"

    local eggPos = egg.part.Position
    moveTo(eggPos)
    task.wait(0.15)

    State.Status = "Stealing"
    local success = false
    local tries = State.AntiGagal and State.RetryCount or 1

    for i = 1, tries do
        if trySteal(egg) then
            success = true
            break
        end
        State.FailCount = State.FailCount + 1
        State._failStreak = State._failStreak + 1
        task.wait(0.25)
        if i < tries then
            moveInstant(eggPos + Vector3.new(0, 2, 0))
            task.wait(0.1)
        end
    end

    if success then
        State.EggCount = State.EggCount + 1
        State._failStreak = 0

        if egg.tier == "LIMITED" then
            State.LimitedCount = State.LimitedCount + 1
            notify("LIMITED STOLEN", egg.model.Name, Palette.Gold, 4)
        elseif egg.tier == "RARE" then
            State.RareCount = State.RareCount + 1
            notify("RARE STOLEN", egg.model.Name, Palette.Pink, 3)
        end

        State.Status = "Success #" .. State.EggCount

        if State.AutoReturn then
            State.Status = "Returning base"
            returnToBase()
        end

        task.wait(0.4)
        handleHatch()
        handleSell()
        handleExtras()
    else
        State.Status = "Failed, next egg"
        antiStuck()

        if State._failStreak >= 5 then
            State.FarthestEgg = not State.FarthestEgg
            task.wait(3)
            State.FarthestEgg = not State.FarthestEgg
            State._failStreak = 0
            Logger.warn("Fail streak 5x, mode switch")
        end
    end

    updateStats()
end

local function startFarm()
    if farmThread then return end
    State.AutoFarm = true
    State.Session = State.Session + 1
    State.SessionStart = tick()
    State._startEggCount = State.EggCount
    notify("Farm Started", "Session #" .. State.Session, Palette.Green)
    Logger.info("Farm started, session #" .. State.Session)

    farmThread = task.spawn(function()
        while State.AutoFarm do
            if State._paused then
                task.wait(0.5)
                continue
            end
            local ok, err = pcall(runOne)
            if not ok then
                State.Status = "Error"
                Logger.error(tostring(err))
                task.wait(1)
            end
            task.wait(State.DelayBetween)
        end
        farmThread = nil
        State.Status = "Idle"
        local sessionEggs = State.EggCount - (State._startEggCount or 0)
        if sessionEggs > State.BestSession then
            State.BestSession = sessionEggs
        end
        notify("Farm Stopped", "Total: " .. State.EggCount .. " eggs", Palette.Yellow)
    end)
end

local function stopFarm()
    State.AutoFarm = false
    State.Status = "Stopped"
    State.CurrentTarget = "None"
end

local function pauseFarm()
    State._paused = true
    State.Status = "Paused"
end

local function resumeFarm()
    State._paused = false
    State.Status = "Running"
end

local function resetStats()
    State.EggCount = 0
    State.FailCount = 0
    State.LimitedCount = 0
    State.RareCount = 0
    State.HatchCount = 0
    State.SellCount = 0
    State.PlaceCount = 0
    State.SuccessRate = 100
    State.SessionStart = tick()
    Logger.info("Stats reset")
end

-- ════════════════════════════════════════════════════════════
-- [PART 21] CHAT COMMANDS
-- ════════════════════════════════════════════════════════════
LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == "!start" or msg == "!farm" then startFarm()
    elseif msg == "!stop" then stopFarm()
    elseif msg == "!pause" then pauseFarm()
    elseif msg == "!resume" then resumeFarm()
    elseif msg == "!reset" then resetStats()
    elseif msg == "!cache" then clearRemoteCache(); notify("Cache", "Cleared", Palette.Yellow)
    elseif msg == "!base" then returnToBase()
    elseif msg == "!hatch" then fireAll("Hatch")
    elseif msg == "!sell" then fireAll("Sell")
    elseif msg == "!stats" then
        notify("Stats", string.format("Egg: %d | Limited: %d | Rare: %d | Rate: %d%%",
            State.EggCount, State.LimitedCount, State.RareCount, State.SuccessRate))
    elseif msg == "!egg" then
        notify("Eggs", "Total: " .. eggCount() ..
            " | Limited: " .. eggCountTier("LIMITED") ..
            " | Rare: " .. eggCountTier("RARE"))
    end
end)

-- ════════════════════════════════════════════════════════════
-- [PART 22] HEARTBEAT
-- ════════════════════════════════════════════════════════════
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
        if tick() - State._lastCacheClear > 30 then
            clearRemoteCache()
            State._lastCacheClear = tick()
        end
        if State.Fly then flyUpdate() end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ════════════════════════════════════════════════════════════
-- [PART 23] UI BUILDER (500+ lines)
-- ════════════════════════════════════════════════════════════
local function buildUI()
    -- ═══════════════════════════════════════
    -- SCREEN
    -- ═══════════════════════════════════════
    local Screen = Util.mk("ScreenGui", {
        Name = "MidnightUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    }, PlayerGui)

    -- ═══════════════════════════════════════
    -- FLOATING BUTTON
    -- ═══════════════════════════════════════
    local FAB = Util.mk("Frame", {
        Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE),
        Position = UDim2.new(1, -(BTN_SIZE + 16), 1, -(BTN_SIZE + 16)),
        BackgroundColor3 = Palette.Black2,
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 100,
    }, Screen)
    Util.rounded(FAB, math.floor(BTN_SIZE / 2))
    Util.border(FAB, Palette.Cyan, 2)

    -- Outer ring
    local ring1 = Util.mk("Frame", {
        Size = UDim2.new(1, 8, 1, 8),
        Position = UDim2.new(0, -4, 0, -4),
        BackgroundTransparency = 1,
        ZIndex = 99,
    }, FAB)
    Util.rounded(ring1, math.floor((BTN_SIZE + 8) / 2))
    local ring1St = Util.border(ring1, Palette.Cyan, 1.5)
    ring1St.Transparency = 0.6

    -- Pulse ring
    local ring2 = Util.mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 98,
    }, FAB)
    Util.rounded(ring2, math.floor(BTN_SIZE / 2))
    local ring2St = Util.border(ring2, Palette.Cyan, 1)
    ring2St.Transparency = 0.8

    task.spawn(function()
        while FAB.Parent do
            ring2.Size = UDim2.new(1, 0, 1, 0)
            ring2.Position = UDim2.new(0, 0, 0, 0)
            ring2St.Transparency = 0.8
            task.wait(0.3)
            TweenService:Create(ring2, TweenInfo.new(2, Enum.EasingStyle.Linear), {
                Size = UDim2.new(1, 24, 1, 24),
                Position = UDim2.new(0, -12, 0, -12),
            }):Play()
            TweenService:Create(ring2St, TweenInfo.new(2, Enum.EasingStyle.Linear), {
                Transparency = 1,
            }):Play()
            task.wait(1.7)
        end
    end)

    local fabIcon = Util.mk("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "SE",
        TextColor3 = Palette.Cyan,
        Font = Font.Bold,
        TextSize = math.floor(BTN_SIZE * 0.3),
        ZIndex = 101,
    }, FAB)

    -- ═══════════════════════════════════════
    -- MAIN PANEL
    -- ═══════════════════════════════════════
    local Panel = Util.mk("Frame", {
        Size = UDim2.new(0, PANEL_W, 0, PANEL_H),
        Position = UDim2.new(0.5, -PANEL_W / 2, 0.5, -PANEL_H / 2),
        BackgroundColor3 = Palette.Black1,
        BorderSizePixel = 0,
        Visible = false,
        Active = true,
        Draggable = true,
        ZIndex = 50,
    }, Screen)
    Util.rounded(Panel, 16)
    Util.border(Panel, Palette.Black4, 1.5)

    -- Ambient glow
    local ambient = Util.mk("Frame", {
        Size = UDim2.new(1, 6, 1, 6),
        Position = UDim2.new(0, -3, 0, -3),
        BackgroundColor3 = Palette.Cyan,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        ZIndex = 49,
    }, Screen)
    Util.rounded(ambient, 18)

    -- Top gradient
    local topGrad = Util.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 120),
        BackgroundColor3 = Palette.Black2,
        BorderSizePixel = 0,
        ZIndex = 51,
    }, Panel)
    Util.rounded(topGrad, 16)
    Util.grad(topGrad, {
        ColorSequenceKeypoint.new(0, Palette.Black3),
        ColorSequenceKeypoint.new(1, Palette.Black1),
    }, 90)

    -- ═══════════════════════════════════════
    -- HEADER
    -- ═══════════════════════════════════════
    local logoDot = Util.mk("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0, 18, 0, 22),
        BackgroundColor3 = Palette.Cyan,
        BorderSizePixel = 0,
        ZIndex = 53,
    }, Panel)
    Util.rounded(logoDot, 4)

    Util.mk("TextLabel", {
        Size = UDim2.new(1, -90, 0, 20),
        Position = UDim2.new(0, 32, 0, 16),
        BackgroundTransparency = 1,
        Text = "STEAL AN EGG",
        TextColor3 = Palette.White,
        Font = Font.Bold,
        TextSize = Size.H2,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 53,
    }, Panel)

    Util.mk("TextLabel", {
        Size = UDim2.new(1, -90, 0, 14),
        Position = UDim2.new(0, 32, 0, 32),
        BackgroundTransparency = 1,
        Text = "MIDNIGHT ULTRA  |  by " .. CONFIG.CREATOR,
        TextColor3 = Palette.Gray2,
        Font = Font.Normal,
        TextSize = Size.Tiny,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 53,
    }, Panel)

    local closeBtn = Util.mk("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -44, 0, 12),
        BackgroundColor3 = Palette.Black3,
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = Palette.Red,
        Font = Font.Bold,
        TextSize = Size.H3,
        AutoButtonColor = false,
        ZIndex = 54,
    }, Panel)
    Util.rounded(closeBtn, 8)
    Util.border(closeBtn, Palette.Black4, 1)

    closeBtn.MouseButton1Click:Connect(function()
        Util.anim(Panel, {Size = UDim2.new(0, 0, 0, 0)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.2)
        Panel.Visible = false
        Panel.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
    end)
    closeBtn.MouseEnter:Connect(function()
        Util.anim(closeBtn, {BackgroundColor3 = Palette.RedDim}, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        Util.anim(closeBtn, {BackgroundColor3 = Palette.Black3}, 0.15)
    end)

    -- Divider
    Util.mk("Frame", {
        Size = UDim2.new(1, -32, 0, 1),
        Position = UDim2.new(0, 16, 0, 52),
        BackgroundColor3 = Palette.Black4,
        BorderSizePixel = 0,
        ZIndex = 52,
    }, Panel)

    -- ═══════════════════════════════════════
    -- STATS GRID (9 cards)
    -- ═══════════════════════════════════════
    local StatsRow = Util.mk("Frame", {
        Size = UDim2.new(1, -24, 0, 108),
        Position = UDim2.new(0, 12, 0, 62),
        BackgroundTransparency = 1,
        ZIndex = 52,
    }, Panel)
    Util.grid(StatsRow, UDim2.new(0.33, -6, 0, 32), UDim2.new(0, 6, 0, 6))

    local function statCard(label, value, color)
        local card = Util.mk("Frame", {
            BackgroundColor3 = Palette.Black3,
            BorderSizePixel = 0,
            ZIndex = 53,
        }, StatsRow)
        Util.rounded(card, 8)
        Util.border(card, Palette.Black5, 1)

        Util.mk("Frame", {
            Size = UDim2.new(0, 2, 1, -12),
            Position = UDim2.new(0, 0, 0, 6),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            ZIndex = 54,
        }, card)

        Util.mk("TextLabel", {
            Size = UDim2.new(1, -12, 0, 12),
            Position = UDim2.new(0, 8, 0, 3),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = Palette.Gray2,
            Font = Font.Medium,
            TextSize = Size.Tiny,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 54,
        }, card)

        local valLbl = Util.mk("TextLabel", {
            Size = UDim2.new(1, -12, 0, 15),
            Position = UDim2.new(0, 8, 0, 15),
            BackgroundTransparency = 1,
            Text = value,
            TextColor3 = color,
            Font = Font.Bold,
            TextSize = Size.H3,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 54,
        }, card)

        return valLbl
    end

    local StatEgg     = statCard("EGG", "0", Palette.Green)
    local StatLimited = statCard("LIMITED", "0", Palette.Gold)
    local StatRare    = statCard("RARE", "0", Palette.Pink)
    local StatFail    = statCard("FAIL", "0", Palette.Red)
    local StatRate    = statCard("RATE", "100%", Palette.Cyan)
    local StatStatus  = statCard("STATUS", "Idle", Palette.White)
    local StatUptime  = statCard("UPTIME", "00:00", Palette.Yellow)
    local StatFound   = statCard("FOUND", "0", Palette.Purple)
    local StatCache   = statCard("CACHE", "0", Palette.CyanDim)

    -- ═══════════════════════════════════════
    -- TAB BAR
    -- ═══════════════════════════════════════
    local TabBar = Util.mk("Frame", {
        Size = UDim2.new(1, -24, 0, 34),
        Position = UDim2.new(0, 12, 0, 178),
        BackgroundColor3 = Palette.Black2,
        BorderSizePixel = 0,
        ZIndex = 52,
    }, Panel)
    Util.rounded(TabBar, 10)
    Util.border(TabBar, Palette.Black4, 1)

    local TabInner = Util.mk("Frame", {
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0, 3, 0, 3),
        BackgroundTransparency = 1,
        ZIndex = 53,
    }, TabBar)

    local tabs = {"FARM", "EXTRA", "MOVE", "INFO"}
    Util.grid(TabInner, UDim2.new(0.25, -3, 1, 0), UDim2.new(0, 3, 0, 0))

    local pages = {}
    local tabBtns = {}

    local Content = Util.mk("ScrollingFrame", {
        Name = "Content",
        Size = UDim2.new(1, -24, 1, -228),
        Position = UDim2.new(0, 12, 0, 220),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Palette.Cyan,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 52,
    }, Panel)

    for i, name in ipairs(tabs) do
        local btn = Util.mk("TextButton", {
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = (i == 1) and Palette.White or Palette.Gray2,
            Font = Font.Bold,
            TextSize = Size.Small,
            AutoButtonColor = false,
            ZIndex = 55,
        }, TabInner)
        table.insert(tabBtns, btn)

        local page = Util.mk("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = (i == 1),
            ZIndex = 53,
        }, Content)
        Util.list(page, 6)
        pages[name] = page

        btn.MouseButton1Click:Connect(function()
            for _, o in ipairs(tabBtns) do
                Util.anim(o, {TextColor3 = Palette.Gray2}, 0.15)
            end
            Util.anim(btn, {TextColor3 = Palette.White}, 0.15)
            for n, p in pairs(pages) do p.Visible = false end
            page.Visible = true
        end)
    end

    -- ═══════════════════════════════════════
    -- COMPONENTS
    -- ═══════════════════════════════════════
    local function section(parent, text)
        local holder = Util.mk("Frame", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            ZIndex = 53,
        }, parent)
        Util.mk("Frame", {
            Size = UDim2.new(0, 3, 0, 12),
            Position = UDim2.new(0, 0, 0.5, -6),
            BackgroundColor3 = Palette.Cyan,
            BorderSizePixel = 0,
            ZIndex = 54,
        }, holder)
        Util.mk("TextLabel", {
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Palette.Cyan,
            Font = Font.Bold,
            TextSize = Size.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 54,
        }, holder)
    end

    local function toggle(parent, text, key, callback)
        local holder = Util.mk("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Palette.Black3,
            BorderSizePixel = 0,
            ZIndex = 53,
        }, parent)
        Util.rounded(holder, 8)
        Util.border(holder, Palette.Black5, 1)

        Util.mk("TextLabel", {
            Size = UDim2.new(1, -70, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Palette.OffWhite,
            Font = Font.Medium,
            TextSize = Size.Body,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 54,
        }, holder)

        local track = Util.mk("Frame", {
            Size = UDim2.new(0, 42, 0, 22),
            Position = UDim2.new(1, -54, 0.5, -11),
            BackgroundColor3 = State[key] and Palette.GreenDim or Palette.Black5,
            BorderSizePixel = 0,
            ZIndex = 54,
        }, holder)
        Util.rounded(track, 11)

        local dot = Util.mk("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = State[key] and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = Palette.White,
            BorderSizePixel = 0,
            ZIndex = 55,
        }, track)
        Util.rounded(dot, 9)

        local click = Util.mk("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 56,
        }, holder)

        click.MouseButton1Click:Connect(function()
            State[key] = not State[key]
            local on = State[key]
            Util.anim(track, {BackgroundColor3 = on and Palette.GreenDim or Palette.Black5}, 0.2)
            Util.anim(dot, {Position = on and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.2)
            if callback then pcall(callback, on) end
        end)

        click.MouseEnter:Connect(function()
            Util.anim(holder, {BackgroundColor3 = Palette.Black4}, 0.1)
        end)
        click.MouseLeave:Connect(function()
            Util.anim(holder, {BackgroundColor3 = Palette.Black3}, 0.1)
        end)
    end

    local function slider(parent, text, key, min, max, default, suffix)
        suffix = suffix or ""
        local holder = Util.mk("Frame", {
            Size = UDim2.new(1, 0, 0, 56),
            BackgroundColor3 = Palette.Black3,
            BorderSizePixel = 0,
            ZIndex = 53,
        }, parent)
        Util.rounded(holder, 8)
        Util.border(holder, Palette.Black5, 1)

        Util.mk("TextLabel", {
            Size = UDim2.new(1, -80, 0, 18),
            Position = UDim2.new(0, 12, 0, 6),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Palette.Gray1,
            Font = Font.Medium,
            TextSize = Size.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 54,
        }, holder)

        local valLbl = Util.mk("TextLabel", {
            Size = UDim2.new(0, 70, 0, 18),
            Position = UDim2.new(1, -82, 0, 6),
            BackgroundTransparency = 1,
            Text = tostring(default) .. suffix,
            TextColor3 = Palette.Cyan,
            Font = Font.Bold,
            TextSize = Size.Small,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 54,
        }, holder)

        local track = Util.mk("TextButton", {
            Size = UDim2.new(1, -24, 0, 8),
            Position = UDim2.new(0, 12, 0, 36),
            BackgroundColor3 = Palette.Black5,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 54,
        }, holder)
        Util.rounded(track, 4)

        local pct = (default - min) / (max - min)
        local fill = Util.mk("Frame", {
            Size = UDim2.new(pct, 0, 1, 0),
            BackgroundColor3 = Palette.Cyan,
            BorderSizePixel = 0,
            ZIndex = 55,
        }, track)
        Util.rounded(fill, 4)

        local knob = Util.mk("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(pct, -8, 0.5, -8),
            BackgroundColor3 = Palette.White,
            BorderSizePixel = 0,
            ZIndex = 56,
        }, track)
        Util.rounded(knob, 8)
        Util.border(knob, Palette.Cyan, 2)

        local dragging = false
        local function update(input)
            local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = Util.round(min + (max - min) * p, 1)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -8, 0.5, -8)
            valLbl.Text = tostring(v) .. suffix
            State[key] = v
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

    local function button(parent, text, color, callback)
        color = color or Palette.Cyan
        local btn = Util.mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Palette.Black3,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 53,
        }, parent)
        Util.rounded(btn, 8)
        Util.border(btn, color, 1)

        Util.mk("Frame", {
            Size = UDim2.new(0, 3, 0, 18),
            Position = UDim2.new(0, 10, 0.5, -9),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            ZIndex = 54,
        }, btn)

        Util.mk("TextLabel", {
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 22, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Palette.OffWhite,
            Font = Font.Bold,
            TextSize = Size.Body,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 54,
        }, btn)

        btn.MouseButton1Click:Connect(function()
            Util.anim(btn, {BackgroundColor3 = color}, 0.1)
            task.wait(0.1)
            Util.anim(btn, {BackgroundColor3 = Palette.Black3}, 0.15)
            if callback then pcall(callback) end
        end)
        btn.MouseEnter:Connect(function()
            Util.anim(btn, {BackgroundColor3 = Palette.Black4}, 0.12)
        end)
        btn.MouseLeave:Connect(function()
            Util.anim(btn, {BackgroundColor3 = Palette.Black3}, 0.12)
        end)
    end

    local function infoRow(parent, label, value, valColor)
        local row = Util.mk("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            ZIndex = 53,
        }, parent)
        Util.mk("TextLabel", {
            Size = UDim2.new(0.5, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = Palette.Gray2,
            Font = Font.Medium,
            TextSize = Size.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 54,
        }, row)
        local v = Util.mk("TextLabel", {
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = value,
            TextColor3 = valColor or Palette.OffWhite,
            Font = Font.Bold,
            TextSize = Size.Small,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 54,
        }, row)
        return v
    end

    -- ═══════════════════════════════════════
    -- POPULATE FARM
    -- ═══════════════════════════════════════
    section(pages["FARM"], "FARM CONTROL")
    toggle(pages["FARM"], "Auto Farm", "AutoFarm", function(v)
        if v then startFarm() else stopFarm() end
    end)
    toggle(pages["FARM"], "Priority Limited", "PriorityLimited")
    toggle(pages["FARM"], "Priority Rare", "PriorityRare")
    toggle(pages["FARM"], "Farthest Egg", "FarthestEgg")
    toggle(pages["FARM"], "Skip Locked", "SkipLocked")
    toggle(pages["FARM"], "Skip Common", "SkipCommon")
    toggle(pages["FARM"], "Anti Gagal", "AntiGagal")
    toggle(pages["FARM"], "Auto Return Base", "AutoReturn")
    toggle(pages["FARM"], "Auto Place", "AutoPlace")

    section(pages["FARM"], "TIMING")
    slider(pages["FARM"], "Delay Between", "DelayBetween", 0.3, 3, 1.2, "s")
    slider(pages["FARM"], "Retry Count", "RetryCount", 1, 10, 5)

    section(pages["FARM"], "QUICK ACTION")
    button(pages["FARM"], "Start Farm", Palette.Green, function()
        State.AutoFarm = true
        startFarm()
    end)
    button(pages["FARM"], "Pause Farm", Palette.Yellow, function() pauseFarm() end)
    button(pages["FARM"], "Resume Farm", Palette.Cyan, function() resumeFarm() end)
    button(pages["FARM"], "Stop Farm", Palette.Red, function() stopFarm() end)

    -- ═══════════════════════════════════════
    -- POPULATE EXTRA
    -- ═══════════════════════════════════════
    section(pages["EXTRA"], "AUTO ACTIONS")
    toggle(pages["EXTRA"], "Auto Hatch", "AutoHatch")
    toggle(pages["EXTRA"], "Auto Sell", "AutoSell")
    toggle(pages["EXTRA"], "Auto Buy Upgrade", "AutoBuy")
    toggle(pages["EXTRA"], "Auto Equip Best", "AutoEquip")
    toggle(pages["EXTRA"], "Auto Claim Reward", "AutoClaim")

    section(pages["EXTRA"], "INTERVAL")
    slider(pages["EXTRA"], "Hatch Interval", "HatchInterval", 1, 15, 3, "s")
    slider(pages["EXTRA"], "Sell Interval", "SellInterval", 1, 30, 5, "s")

    section(pages["EXTRA"], "MANUAL TRIGGER")
    button(pages["EXTRA"], "Hatch All", Palette.Green, function()
        fireAll("Hatch")
        notify("Hatch", "Triggered", Palette.Green)
    end)
    button(pages["EXTRA"], "Sell All", Palette.Yellow, function()
        fireAll("Sell")
        notify("Sell", "Triggered", Palette.Yellow)
    end)
    button(pages["EXTRA"], "Equip Best Pet", Palette.Cyan, function()
        fireAll("Equip")
        notify("Equip", "Triggered", Palette.Cyan)
    end)
    button(pages["EXTRA"], "Claim All Reward", Palette.Purple, function()
        fireAll("Claim")
        notify("Claim", "Triggered", Palette.Purple)
    end)
    button(pages["EXTRA"], "Buy Upgrade", Palette.Pink, function()
        fireAll("Buy")
        notify("Buy", "Triggered", Palette.Pink)
    end)

    -- ═══════════════════════════════════════
    -- POPULATE MOVE
    -- ═══════════════════════════════════════
    section(pages["MOVE"], "CHARACTER")
    toggle(pages["MOVE"], "Speed Hack", "SpeedHack")
    slider(pages["MOVE"], "Speed Value", "SpeedValue", 16, 100, 22)
    toggle(pages["MOVE"], "Infinite Jump", "InfiniteJump")
    slider(pages["MOVE"], "Jump Power", "JumpPower", 50, 200, 50)
    toggle(pages["MOVE"], "No Clip", "NoClip")
    toggle(pages["MOVE"], "Fly Mode", "Fly", function(v)
        if v then flyEnable() else flyDisable() end
    end)
    slider(pages["MOVE"], "Fly Speed", "FlySpeed", 20, 200, 60)

    section(pages["MOVE"], "TELEPORT METHOD")
    local mFrame = Util.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Palette.Black3,
        BorderSizePixel = 0,
        ZIndex = 53,
    }, pages["MOVE"])
    Util.rounded(mFrame, 8)
    Util.border(mFrame, Palette.Black5, 1)

    local mOpts = {"Instant", "Tween", "Walk"}
    local mBtns = {}
    for i, opt in ipairs(mOpts) do
        local mb = Util.mk("TextButton", {
            Size = UDim2.new(0, 68, 0, 26),
            Position = UDim2.new(1, -228 + (i - 1) * 74, 0.5, -13),
            BackgroundColor3 = (State.Method == opt) and Palette.Cyan or Palette.Black4,
            BorderSizePixel = 0,
            Text = opt,
            TextColor3 = (State.Method == opt) and Palette.White or Palette.Gray2,
            Font = Font.Bold,
            TextSize = Size.Small,
            ZIndex = 54,
        }, mFrame)
        Util.rounded(mb, 6)
        table.insert(mBtns, {btn = mb, opt = opt})

        mb.MouseButton1Click:Connect(function()
            State.Method = opt
            for _, item in ipairs(mBtns) do
                Util.anim(item.btn, {
                    BackgroundColor3 = (item.opt == opt) and Palette.Cyan or Palette.Black4,
                    TextColor3 = (item.opt == opt) and Palette.White or Palette.Gray2,
                }, 0.15)
            end
        end)
    end

    section(pages["MOVE"], "ACTION")
    button(pages["MOVE"], "Return Base Now", Palette.Cyan, function()
        returnToBase()
    end)

    -- ═══════════════════════════════════════
    -- POPULATE INFO
    -- ═══════════════════════════════════════
    section(pages["INFO"], "SCRIPT INFO")
    local infoBox = Util.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 120),
        BackgroundColor3 = Palette.Black3,
        BorderSizePixel = 0,
        ZIndex = 53,
    }, pages["INFO"])
    Util.rounded(infoBox, 8)
    Util.border(infoBox, Palette.Black5, 1)

    local infoInner = Util.mk("Frame", {
        Size = UDim2.new(1, -24, 1, -16),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        ZIndex = 54,
    }, infoBox)
    Util.list(infoInner, 2)

    infoRow(infoInner, "Name", CONFIG.NAME, Palette.Cyan)
    infoRow(infoInner, "Version", "v" .. CONFIG.VERSION, Palette.Green)
    infoRow(infoInner, "Creator", CONFIG.CREATOR, Palette.Pink)
    infoRow(infoInner, "Year", CONFIG.YEAR, Palette.Gold)
    infoRow(infoInner, "Device", IS_MOBILE and "Mobile" or (IS_TABLET and "Tablet" or "PC"), Palette.Purple)

    section(pages["INFO"], "LIVE STATS")
    local liveBox = Util.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 120),
        BackgroundColor3 = Palette.Black3,
        BorderSizePixel = 0,
        ZIndex = 53,
    }, pages["INFO"])
    Util.rounded(liveBox, 8)
    Util.border(liveBox, Palette.Black5, 1)

    local liveInner = Util.mk("Frame", {
        Size = UDim2.new(1, -24, 1, -16),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        ZIndex = 54,
    }, liveBox)
    Util.list(liveInner, 2)

    local LiveEgg   = infoRow(liveInner, "Egg Stolen", "0", Palette.Green)
    local LiveLim   = infoRow(liveInner, "Limited", "0", Palette.Gold)
    local LiveRare  = infoRow(liveInner, "Rare", "0", Palette.Pink)
    local LiveFail  = infoRow(liveInner, "Fail Count", "0", Palette.Red)

    section(pages["INFO"], "EGG IN WORLD")
    local worldBox = Util.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 110),
        BackgroundColor3 = Palette.Black3,
        BorderSizePixel = 0,
        ZIndex = 53,
    }, pages["INFO"])
    Util.rounded(worldBox, 8)
    Util.border(worldBox, Palette.Black5, 1)

    local worldInner = Util.mk("Frame", {
        Size = UDim2.new(1, -24, 1, -16),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        ZIndex = 54,
    }, worldBox)
    Util.list(worldInner, 2)

    local WorldTotal   = infoRow(worldInner, "Total", "0", Palette.White)
    local WorldLimited = infoRow(worldInner, "Limited", "0", Palette.Gold)
    local WorldRare    = infoRow(worldInner, "Rare", "0", Palette.Pink)
    local WorldNormal  = infoRow(worldInner, "Normal", "0", Palette.Cyan)

    section(pages["INFO"], "UTILITY")
    button(pages["INFO"], "Refresh Remote Cache", Palette.Yellow, function()
        clearRemoteCache()
        notify("Cache", "Refreshed", Palette.Yellow)
    end)
    button(pages["INFO"], "Reset Statistics", Palette.Red, function()
        resetStats()
        notify("Stats", "Reset", Palette.Red)
    end)
    button(pages["INFO"], "Clear Notifications", Palette.Cyan, function()
        notifyClear()
    end)

    -- ═══════════════════════════════════════
    -- TOGGLE PANEL
    -- ═══════════════════════════════════════
    local fabClick = Util.mk("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 102,
    }, FAB)

    fabClick.MouseButton1Click:Connect(function()
        Panel.Visible = not Panel.Visible
        if Panel.Visible then
            Panel.Size = UDim2.new(0, 0, 0, 0)
            ambient.Size = UDim2.new(0, 0, 0, 0)
            Util.anim(Panel, {Size = UDim2.new(0, PANEL_W, 0, PANEL_H)}, 0.25,
                Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            Util.anim(ambient, {Size = UDim2.new(1, 6, 1, 6)}, 0.25,
                Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
        Util.anim(fabIcon, {TextColor3 = Palette.White}, 0.15)
        task.wait(0.15)
        Util.anim(fabIcon, {TextColor3 = Palette.Cyan}, 0.15)
    end)

    -- ═══════════════════════════════════════
    -- REAL-TIME UPDATE LOOP
    -- ═══════════════════════════════════════
    task.spawn(function()
        while true do
            task.wait(0.25)

            -- Top stats
            StatEgg.Text = tostring(State.EggCount)
            StatLimited.Text = tostring(State.LimitedCount)
            StatRare.Text = tostring(State.RareCount)
            StatFail.Text = tostring(State.FailCount)
            StatRate.Text = State.SuccessRate .. "%"
            StatStatus.Text = string.sub(State.Status, 1, 12)
            StatUptime.Text = State.SessionStart > 0 and Util.formatTime(tick() - State.SessionStart) or "00:00"
            StatFound.Text = tostring(eggCount())
            StatCache.Text = tostring(cacheSize())

            -- Rate color
            if State.SuccessRate >= 80 then
                StatRate.TextColor3 = Palette.Green
            elseif State.SuccessRate >= 50 then
                StatRate.TextColor3 = Palette.Yellow
            else
                StatRate.TextColor3 = Palette.Red
            end

            -- Live stats
            LiveEgg.Text = tostring(State.EggCount)
            LiveLim.Text = tostring(State.LimitedCount)
            LiveRare.Text = tostring(State.RareCount)
            LiveFail.Text = tostring(State.FailCount)

            -- World eggs
            WorldTotal.Text = tostring(eggCount())
            WorldLimited.Text = tostring(eggCountTier("LIMITED"))
            WorldRare.Text = tostring(eggCountTier("RARE"))
            WorldNormal.Text = tostring(eggCountTier("NORMAL"))
        end
    end)

    -- Auto canvas
    task.spawn(function()
        while task.wait(0.5) do
            for _, page in pairs(pages) do
                if page.Visible then
                    Content.CanvasSize = UDim2.new(0, 0, 0, page.AbsoluteSize.Y + 30)
                end
            end
        end
    end)

    return Screen
end

-- ════════════════════════════════════════════════════════════
-- [PART 24] INIT
-- ════════════════════════════════════════════════════════════
buildUI()
notify("Midnight Ultra", "Loaded - by kalzz", Palette.Cyan, 4)

print("╔══════════════════════════════════════════════════╗")
print("║   STEAL AN EGG - MIDNIGHT ULTRA v12             ║")
print("║   Creator: kalzz                                ║")
print("║   UI: 500+ lines | Farm: 1500+ lines            ║")
print("║   Device: " .. (IS_MOBILE and "Mobile" or IS_TABLET and "Tablet" or "PC") .. "                                 ║")
print("║   2026                                          ║")
print("╚══════════════════════════════════════════════════╝")
print("[Chat] !start !stop !pause !resume !reset !cache !base !hatch !sell !stats !egg")
