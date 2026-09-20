--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║   VIOLENCE DISTRICT - FULL HUB FINAL                                 ║
    ║   Base: Denoting2 HUB (Kidtayod/Idv/main.lua - verified readable)    ║
    ║   Extra: Silent Aim Veil, Pistol, Auto Gen, Auto Parry, Outline ESP  ║
    ║   Device: Mobile (Delta) | Total: 1100+ lines | No Error             ║
    ║   by kalzz | 2026                                                    ║
    ╚══════════════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════════════════
-- [01] SERVICES
-- ═══════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

-- ═══════════════════════════════════════════════════════════════════════
-- [02] CONFIG
-- ═══════════════════════════════════════════════════════════════════════
local CFG = {
    NAME = "VD Full Hub",
    VERSION = "4.0",
    CREATOR = "kalzz",
    BASE = "Denoting2 HUB (verified)",
    GAME = "Violence District",
}

local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local IS_TABLET = UserInputService.TouchEnabled and UserInputService.MouseEnabled
local SCALE = IS_MOBILE and 0.9 or (IS_TABLET and 0.85 or 1)
local MAIN_W = math.floor(600 * SCALE)
local MAIN_H = math.floor(430 * SCALE)

-- ═══════════════════════════════════════════════════════════════════════
-- [03] STATE (dari Denoting2 + tambahan)
-- ═══════════════════════════════════════════════════════════════════════
local S = {
    -- ESP (Denoting2 asli)
    ESP_ON = false,
    ESPTransparency = 1,           -- Outline only
    ESPOutlineTransparency = 0.1,
    ESPRange = 500,
    
    -- Tracer (Denoting2 asli)
    TRACER_ON = false,
    TracerThickness = 2,
    
    -- Fullbright (Denoting2 asli)
    FULLBRIGHT_ON = false,
    
    -- Killer Alert (Denoting2 asli)
    ALERT_ON = false,
    
    -- Speed (Denoting2 asli)
    SpeedBoost = false,
    SpeedValue = 19,
    DefaultSpeed = 16,
    
    -- Silent Aim Veil
    VEIL_ON = false,
    VeilFOV = 500,
    VeilPredict = 100,
    SpearSpeed = 200,
    SpearGravity = 100,
    GravityComp = true,
    VeilTarget = "Survivor",
    
    -- Silent Aim Pistol
    SILENT_ON = false,
    SilentTarget = "Killer",
    SilentFOV = 500,
    SilentPredict = 0.15,
    
    -- Auto Generator
    GEN_ON = false,
    GenMode = "Perfect",
    GenRange = 100,
    
    -- Auto Parry
    PARRY_ON = false,
    ParryRange = 20,
    ParryDelay = 0.25,
    
    -- Auto Actions
    AutoEscape = false,
    AutoHeal = false,
    AutoCollect = false,
    AutoVault = false,
    
    -- Movement
    NoClip = false,
    Fly = false,
    FlySpeed = 60,
    InfiniteJump = false,
    
    -- Misc
    AntiAFK = true,
    
    -- Internal
    _lastAlert = 0,
    _lastGen = 0,
    _lastParry = 0,
    _lastHeal = 0,
    _lastVault = 0,
    _originalWalk = 16,
    _flyBV = nil,
    _flyBG = nil,
    _hookActive = false,
    _oldNamecall = nil,
    _counts = { gen = 0, parry = 0, veil = 0, aim = 0, vault = 0, heal = 0 },
}

-- ═══════════════════════════════════════════════════════════════════════
-- [04] THEME
-- ═══════════════════════════════════════════════════════════════════════
local C = {
    BG2 = Color3.fromRGB(18, 18, 28),
    BG3 = Color3.fromRGB(32, 32, 50),
    BG4 = Color3.fromRGB(50, 50, 80),
    BG5 = Color3.fromRGB(70, 70, 100),
    White = Color3.new(1, 1, 1),
    OffWhite = Color3.fromRGB(230, 230, 235),
    Gray1 = Color3.fromRGB(180, 180, 190),
    Gray2 = Color3.fromRGB(130, 130, 145),
    Gray3 = Color3.fromRGB(90, 90, 105),
    Gray4 = Color3.fromRGB(60, 60, 72),
    Cyan = Color3.fromRGB(0, 200, 255),
    CyanGlow = Color3.fromRGB(120, 120, 255),
    Green = Color3.fromRGB(0, 255, 180),
    GreenDim = Color3.fromRGB(30, 130, 90),
    Red = Color3.fromRGB(255, 60, 60),
    RedDim = Color3.fromRGB(160, 40, 40),
    Yellow = Color3.fromRGB(255, 200, 80),
    Purple = Color3.fromRGB(170, 120, 255),
    Orange = Color3.fromRGB(255, 150, 70),
    Blue = Color3.fromRGB(100, 100, 255),
    Lime = Color3.fromRGB(180, 255, 100),
}

local F = {
    Bold = Enum.Font.GothamBold,
    Med = Enum.Font.GothamMedium,
    Norm = Enum.Font.Gotham,
    Black = Enum.Font.GothamBlack,
}

-- ═══════════════════════════════════════════════════════════════════════
-- [05] UTILITY
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
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border 
    }, o) 
end
function U.ls(o, s, d) 
    return U.mk("UIListLayout", { 
        Padding = UDim.new(0, s or 6), 
        SortOrder = Enum.SortOrder.LayoutOrder, 
        FillDirection = d or Enum.FillDirection.Vertical 
    }, o) 
end
function U.tw(o, p, d, s) 
    TweenService:Create(o, TweenInfo.new(d or 0.2, s or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), p):Play() 
end
function U.dist(a, b) return (a - b).Magnitude end
function U.clamp(v, mn, mx) 
    if v < mn then return mn end 
    if v > mx then return mx end 
    return v 
end

-- ═══════════════════════════════════════════════════════════════════════
-- [06] PLAYER HELPERS
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
local function isAlive() 
    local h = getHum() 
    return h and h.Health > 0 
end
local function getPos() 
    local r = getRoot() 
    return r and r.Position or Vector3.zero 
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
local function isKiller(plr) return getTeamOf(plr):find("killer") ~= nil end
local function isSurvivor(plr) 
    local n = getTeamOf(plr) 
    return n:find("surv") ~= nil or n:find("runner") ~= nil 
end
local function getRole()
    local t = LocalPlayer.Team
    if not t then return "Unknown" end
    local n = t.Name:lower()
    if n:find("killer") then return "Killer" end
    if n:find("surv") then return "Survivor" end
    return "Unknown"
end

-- ═══════════════════════════════════════════════════════════════════════
-- [07] REMOTE MANAGER
-- ═══════════════════════════════════════════════════════════════════════
local RC = {}
local RG = {
    Generator = { "ActivateGenerator", "RepairGenerator", "FixGenerator", "Generator", "DoGenerator", "CompleteGenerator", "SkillCheck", "CompleteCheck" },
    Attack    = { "Attack", "Hit", "Damage", "Strike", "Swing", "PerformAttack" },
    Parry     = { "Parry", "Block", "Counter", "DoParry" },
    Vault     = { "Vault", "DoVault", "FastVault", "VaultEvent" },
    Heal      = { "Heal", "HealSelf", "UseMedkit" },
    Escape    = { "Escape", "Exit", "Leave", "EscapeEvent" },
    AimUpdate = { "UpdateAim", "SetAim", "AimUpdate", "SendAim", "UpdateMousePos", "MouseUpdate" },
    Collect   = { "Collect", "Pickup", "Grab", "Take" },
}

local function scanRemotes()
    local n = 0
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            for _, list in pairs(RG) do
                for _, name in ipairs(list) do
                    if obj.Name == name then 
                        RC[name] = obj 
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
    for _, name in ipairs(RG[group] or {}) do
        local r = RC[name] or ReplicatedStorage:FindFirstChild(name, true)
        if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
            RC[name] = r
            pcall(function()
                if r:IsA("RemoteEvent") then 
                    r:FireServer(unpack(args))
                else 
                    r:InvokeServer(unpack(args)) 
                end
            end)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- [08] ESP - OUTLINE ONLY (dari Denoting2 HUB, dioptimasi)
-- ═══════════════════════════════════════════════════════════════════════
local highlights = {}

local function AddESP(plr)
    if plr == LocalPlayer then return end
    
    local function Setup(char)
        if highlights[plr] then 
            highlights[plr]:Destroy() 
        end
        
        local h = Instance.new("Highlight")
        h.Parent = CoreGui
        h.Adornee = char
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        
        -- Team color (dari Denoting2 asli)
        if plr.Team == LocalPlayer.Team then
            h.FillColor = C.Green
            h.OutlineColor = C.Green
        else
            h.FillColor = C.Red
            h.OutlineColor = C.Red
        end
        
        -- ⚠️ OUTLINE ONLY (biar ringan)
        h.FillTransparency = 1
        h.OutlineTransparency = 0.1
        
        highlights[plr] = h
    end
    
    if plr.Character then Setup(plr.Character) end
    plr.CharacterAdded:Connect(Setup)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [09] TRACER (dari Denoting2 HUB, verbatim)
-- ═══════════════════════════════════════════════════════════════════════
local tracers = {}

RunService.RenderStepped:Connect(function()
    if not S.TRACER_ON then return end
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
                    tracers[plr].Color = C.Green
                else
                    tracers[plr].Color = C.Red
                end
            else
                tracers[plr].Visible = false
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [10] KILLER ALERT (dari Denoting2 HUB, verbatim)
-- ═══════════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not S.ALERT_ON then return end
    if tick() - S._lastAlert < 4 then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team 
            and plr.Character and LocalPlayer.Character then
            local enemy = plr.Character:FindFirstChild("HumanoidRootPart")
            local me = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if enemy and me then
                local dist = (enemy.Position - me.Position).Magnitude
                if dist <= 14 then
                    S._lastAlert = tick()
                    pcall(function()
                        StarterGui:SetCore("SendNotification", {
                            Title = "Killer Nearby",
                            Text = plr.Name .. " - " .. math.floor(dist) .. "m",
                            Duration = 2,
                        })
                    end)
                    break
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [11] TARGET FINDER
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
        if filter == "Killer" and isKiller(plr) then shouldTarget = true end
        if filter == "Survivor" and isSurvivor(plr) then shouldTarget = true end
        if filter == "All" then shouldTarget = true end
        if not shouldTarget then continue end
        
        local d = U.dist(myPos, hrp.Position)
        if d < bestDist and d <= S.VeilFOV then
            local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then 
                best = plr 
                bestDist = d 
            end
        end
    end
    return best
end

-- ═══════════════════════════════════════════════════════════════════════
-- [12] SILENT AIM VEIL
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.05)
        if not S.VEIL_ON then continue end
        
        local target = getClosestTarget(S.VeilTarget)
        if not target or not target.Character then continue end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local ping = LocalPlayer:GetNetworkPing() * 1000
        local predictTime = (ping / 1000) + (S.VeilPredict / 100)
        local predictedPos = hrp.Position + (hrp.Velocity * predictTime)
        
        if S.GravityComp then
            local myPos = getPos()
            if myPos ~= Vector3.zero then
                local distance = U.dist(predictedPos, myPos)
                local timeToHit = distance / math.max(S.SpearSpeed, 1)
                local drop = 0.5 * Workspace.Gravity * (timeToHit ^ 2) * (S.SpearGravity / 100)
                predictedPos = predictedPos + Vector3.new(0, drop, 0)
            end
        end
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("spear") then
                if not obj:FindFirstChild("VD_BV") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "VD_BV"
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Parent = obj
                    
                    local bg = Instance.new("BodyGyro")
                    bg.Name = "VD_BG"
                    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bg.P = 1000
                    bg.D = 50
                    bg.Parent = obj
                end
                
                local dir = (predictedPos - obj.Position).Unit
                if obj:FindFirstChild("VD_BV") then
                    obj.VD_BV.Velocity = dir * S.SpearSpeed
                end
                if obj:FindFirstChild("VD_BG") then
                    obj.VD_BG.CFrame = CFrame.new(obj.Position, predictedPos)
                end
                S._counts.veil = S._counts.veil + 1
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [13] SILENT AIM PISTOL (FireServer Hook)
-- ═══════════════════════════════════════════════════════════════════════
local function isAimRemote(name)
    name = name:lower()
    local keys = { "aim", "mouse", "shoot", "gun", "fire", "bullet", "shot", "revolver", "pistol" }
    for _, kw in ipairs(keys) do
        if name:find(kw) then return true end
    end
    return false
end

local function installHook()
    if S._hookActive then return end
    local mt = getrawmetatable(game)
    if not mt then return end
    setreadonly(mt, false)
    S._oldNamecall = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and S.SILENT_ON and isAimRemote(self.Name) then
            local target = getClosestTarget(S.SilentTarget)
            if target and target.Character then
                local part = target.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local ping = LocalPlayer:GetNetworkPing() * 1000
                    local predictTime = (ping / 1000) + S.SilentPredict
                    local predictedPos = part.Position + (part.Velocity * predictTime)
                    local args = {...}
                    for i, arg in ipairs(args) do
                        local t = typeof(arg)
                        if t == "Vector3" then 
                            args[i] = predictedPos
                        elseif t == "CFrame" then 
                            args[i] = CFrame.new(predictedPos) 
                        end
                    end
                    S._counts.aim = S._counts.aim + 1
                    return S._oldNamecall(self, unpack(args))
                end
            end
        end
        return S._oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
    S._hookActive = true
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
end

RunService.Heartbeat:Connect(function()
    if S.SILENT_ON and not S._hookActive then 
        installHook()
    elseif not S.SILENT_ON and S._hookActive then 
        removeHook() 
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [14] AUTO GENERATOR
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.15)
        if not S.GEN_ON or not isAlive() then continue end
        if tick() - S._lastGen < 0.15 then continue end
        S._lastGen = tick()
        
        local myPos = getPos()
        if myPos == Vector3.zero then continue end
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("generator") then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part and U.dist(myPos, part.Position) < S.GenRange then
                    fire("Generator", obj)
                    S._counts.gen = S._counts.gen + 1
                    if S.GenMode == "Perfect" then
                        task.wait(0.3)
                        fire("SkillCheck", 1)
                    end
                    break
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [15] AUTO PARRY
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.1)
        if not S.PARRY_ON or not isAlive() then continue end
        if tick() - S._lastParry < S.ParryDelay then continue end
        
        local enemy = getClosestTarget("Killer")
        if not enemy or not enemy.Character then continue end
        
        local hrp = enemy.Character:FindFirstChild("HumanoidRootPart")
        if hrp and U.dist(getPos(), hrp.Position) <= S.ParryRange then
            S._lastParry = tick()
            fire("Parry")
            S._counts.parry = S._counts.parry + 1
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [16] AUTO VAULT
-- ═══════════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not S.AutoVault then return end
    if input.KeyCode ~= Enum.KeyCode.Space then return end
    if tick() - S._lastVault < 0.4 then return end
    
    local char = getChar()
    if not char then return end
    local hum = getHum()
    if not hum or not hum.RootPart then return end
    
    local ray = Ray.new(hum.RootPart.Position, hum.RootPart.CFrame.LookVector * 8)
    local hit = Workspace:FindPartOnRay(ray, char)
    
    if hit then
        local n = hit.Name:lower()
        if n:find("window") or n:find("pallet") or n:find("vault") or n:find("ledge") then
            S._lastVault = tick()
            S._counts.vault = S._counts.vault + 1
            for i = 1, 2 do
                fire("Vault", hit)
                task.wait(0.03)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [17] AUTO ACTIONS
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoEscape and isAlive() then fire("Escape") end
        if S.AutoCollect and isAlive() then fire("Collect") end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if S.AutoHeal and isAlive() and healthPct() < 60 and tick() - S._lastHeal > 1 then
            S._lastHeal = tick()
            fire("Heal")
            S._counts.heal = S._counts.heal + 1
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [18] MOVEMENT
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
    if S._flyBV then 
        S._flyBV:Destroy() 
        S._flyBV = nil 
    end
    if S._flyBG then 
        S._flyBG:Destroy() 
        S._flyBG = nil 
    end
end

RunService.Heartbeat:Connect(function()
    local h = getHum()
    if h then
        if S.SpeedBoost then 
            h.WalkSpeed = S.SpeedValue
        else 
            h.WalkSpeed = S._originalWalk 
        end
    end
    
    if S.Fly and S._flyBV then
        local mv = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then mv = mv - Vector3.new(0, 1, 0) end
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
        if h then 
            h:ChangeState(Enum.HumanoidStateType.Jumping) 
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [19] ANTI-AFK
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

-- ═══════════════════════════════════════════════════════════════════════
-- [20] UI (dari Denoting2 HUB, upgraded)
-- ═══════════════════════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Parent = CoreGui
gui.Name = "VDFullHub"
gui.ResetOnSpawn = false

-- Open Button (dari Denoting2)
local openBtn = Instance.new("TextButton")
openBtn.Parent = gui
openBtn.Size = UDim2.new(0, 55, 0, 55)
openBtn.Position = UDim2.new(0, 15, 0.5, -27)
openBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
openBtn.Text = "☰"
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 24
openBtn.Active = true
openBtn.Draggable = true
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke", openBtn)
stroke.Color = Color3.fromRGB(120, 120, 255)
stroke.Thickness = 2

-- Main Frame
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
frame.Position = UDim2.new(0.5, -MAIN_W/2, 0.5, -MAIN_H/2)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
frame.Visible = false
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Color = Color3.fromRGB(90, 90, 255)
frameStroke.Thickness = 2

local grad = Instance.new("UIGradient", frame)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 60))
}

-- Title
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "🎮 VD FULL HUB"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBlack
title.TextSize = 20

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = frame
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0, 8)
closeBtn.BackgroundColor3 = C.RedDim
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Parent = frame
tabBar.Size = UDim2.new(1, -20, 0, 32)
tabBar.Position = UDim2.new(0, 10, 0, 50)
tabBar.BackgroundColor3 = C.BG3
tabBar.BorderSizePixel = 0
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.Padding = UDim.new(0, 4)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local contentFrame = Instance.new("Frame")
contentFrame.Parent = frame
contentFrame.Size = UDim2.new(1, -20, 1, -95)
contentFrame.Position = UDim2.new(0, 10, 0, 88)
contentFrame.BackgroundTransparency = 1

-- Page creator
local pages = {}
local function createPage(name)
    local p = Instance.new("ScrollingFrame")
    p.Parent = contentFrame
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = C.Blue
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.Visible = false
    
    local l = Instance.new("UIListLayout", p)
    l.Padding = UDim.new(0, 6)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    p.ChildAdded:Connect(function()
        task.wait(0.05)
        p.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 20)
    end)
    p.ChildRemoved:Connect(function()
        task.wait(0.05)
        p.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 20)
    end)
    
    pages[name] = p
    return p
end

local pageSurv = createPage("SURVIVOR")
local pageKiller = createPage("KILLER")
local pageVisual = createPage("VISUAL")
local pageMisc = createPage("MISC")

pages["SURVIVOR"].Visible = true

-- Tab buttons
local tabNames = { "SURVIVOR", "KILLER", "VISUAL", "MISC" }
local tabBtns = {}

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Parent = tabBar
    btn.Size = UDim2.new(0, 75, 0, 26)
    btn.BackgroundColor3 = (i == 1) and C.Blue or C.BG4
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    table.insert(tabBtns, btn)
    
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(tabBtns) do
            TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = C.BG4 }):Play()
        end
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = C.Blue }):Play()
        for n, p in pairs(pages) do 
            p.Visible = false 
        end
        pages[name].Visible = true
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [21] UI COMPONENTS
-- ═══════════════════════════════════════════════════════════════════════
local function makeToggle(parent, label, key, callback)
    local h = U.mk("Frame", {
        Size = UDim2.new(0.95, 0, 0, 40),
        BackgroundColor3 = C.BG3,
        BorderSizePixel = 0,
        Parent = parent,
    })
    U.rc(h, 8)
    U.st(h, C.BG5, 1, 0.3)
    
    U.mk("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.White,
        Font = F.Med,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = h,
    })
    
    local tr = U.mk("Frame", {
        Size = UDim2.new(0, 42, 0, 22),
        Position = UDim2.new(1, -50, 0.5, -11),
        BackgroundColor3 = S[key] and C.Green or C.BG5,
        BorderSizePixel = 0,
        Parent = h,
    })
    U.rc(tr, 11)
    
    local dot = U.mk("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = S[key] and UDim2.new(1, -18, 0, 3) or UDim2.new(0, 3, 0, 3),
        BackgroundColor3 = C.White,
        BorderSizePixel = 0,
        Parent = tr,
    })
    U.rc(dot, 8)
    
    local clk = U.mk("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = h,
    })
    
    clk.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        local on = S[key]
        U.tw(tr, { BackgroundColor3 = on and C.Green or C.BG5 }, 0.15)
        U.tw(dot, { Position = on and UDim2.new(1, -18, 0, 3) or UDim2.new(0, 3, 0, 3) }, 0.15)
        if callback then pcall(callback, on) end
    end)
    
    clk.MouseEnter:Connect(function() U.tw(h, { BackgroundColor3 = C.BG4 }, 0.1) end)
    clk.MouseLeave:Connect(function() U.tw(h, { BackgroundColor3 = C.BG3 }, 0.1) end)
end

local function makeSlider(parent, label, key, mn, mx, df, sfx)
    sfx = sfx or ""
    local h = U.mk("Frame", {
        Size = UDim2.new(0.95, 0, 0, 55),
        BackgroundColor3 = C.BG3,
        BorderSizePixel = 0,
        Parent = parent,
    })
    U.rc(h, 8)
    U.st(h, C.BG5, 1, 0.3)
    
    U.mk("TextLabel", {
        Size = UDim2.new(0.5, 0, 0, 16),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.Gray1,
        Font = F.Med,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = h,
    })
    
    local vl = U.mk("TextLabel", {
        Size = UDim2.new(0.5, -12, 0, 16),
        Position = UDim2.new(0.5, 0, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(df) .. sfx,
        TextColor3 = C.Cyan,
        Font = F.Bold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = h,
    })
    
    local tr = U.mk("TextButton", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 36),
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
        BackgroundColor3 = C.Cyan,
        BorderSizePixel = 0,
        Parent = tr,
    })
    U.rc(fl, 3)
    
    local kn = U.mk("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(pct, -6, 0.5, -6),
        BackgroundColor3 = C.White,
        BorderSizePixel = 0,
        Parent = tr,
    })
    U.rc(kn, 6)
    
    local drag = false
    local function upd(i)
        local p = U.clamp((i.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + (mx - mn) * p + 0.5)
        fl.Size = UDim2.new(p, 0, 1, 0)
        kn.Position = UDim2.new(p, -6, 0.5, -6)
        vl.Text = tostring(v) .. sfx
        S[key] = v
    end
    tr.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true 
            upd(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

local function makeButton(parent, label, color, callback)
    color = color or C.Blue
    local b = U.mk("TextButton", {
        Size = UDim2.new(0.95, 0, 0, 38),
        BackgroundColor3 = C.BG3,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = parent,
    })
    U.rc(b, 8)
    U.st(b, color, 1, 0.5)
    
    U.mk("Frame", {
        Size = UDim2.new(0, 3, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = b,
    })
    
    U.mk("TextLabel", {
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.White,
        Font = F.Bold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = b,
    })
    
    b.MouseButton1Click:Connect(function()
        U.tw(b, { BackgroundColor3 = color }, 0.1)
        task.wait(0.08)
        U.tw(b, { BackgroundColor3 = C.BG3 }, 0.15)
        if callback then pcall(callback) end
    end)
    b.MouseEnter:Connect(function() U.tw(b, { BackgroundColor3 = C.BG4 }, 0.1) end)
    b.MouseLeave:Connect(function() U.tw(b, { BackgroundColor3 = C.BG3 }, 0.1) end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [22] PAGE CONTENT
-- ═══════════════════════════════════════════════════════════════════════

-- SURVIVOR PAGE
makeToggle(pageSurv, "Auto Generator", "GEN_ON")
makeSlider(pageSurv, "Gen Range", "GenRange", 20, 300, 100)
makeToggle(pageSurv, "Auto Parry", "PARRY_ON")
makeSlider(pageSurv, "Parry Range", "ParryRange", 5, 50, 20)
makeSlider(pageSurv, "Parry Delay", "ParryDelay", 0.1, 1, 0.25, "s")
makeToggle(pageSurv, "Auto Vault", "AutoVault")
makeToggle(pageSurv, "Auto Escape", "AutoEscape")
makeToggle(pageSurv, "Auto Heal", "AutoHeal")
makeToggle(pageSurv, "Auto Collect", "AutoCollect")

-- KILLER PAGE
makeToggle(pageKiller, "Silent Aim Veil", "VEIL_ON")
makeSlider(pageKiller, "Veil FOV", "VeilFOV", 50, 1000, 500, "px")
makeSlider(pageKiller, "Veil Predict", "VeilPredict", 1, 200, 100)
makeSlider(pageKiller, "Spear Speed", "SpearSpeed", 100, 500, 200)
makeSlider(pageKiller, "Spear Gravity", "SpearGravity", 50, 500, 100)
makeToggle(pageKiller, "Gravity Comp", "GravityComp")
makeToggle(pageKiller, "Silent Aim Pistol", "SILENT_ON")
makeSlider(pageKiller, "Silent FOV", "SilentFOV", 50, 1000, 500, "px")
makeSlider(pageKiller, "Silent Predict", "SilentPredict", 0.01, 1, 0.15)

-- VISUAL PAGE
makeToggle(pageVisual, "ESP Player", "ESP_ON", function(v)
    if v then
        for _, plr in ipairs(Players:GetPlayers()) do
            AddESP(plr)
        end
    else
        for _, h in pairs(highlights) do 
            h:Destroy() 
        end
        highlights = {}
    end
end)
makeToggle(pageVisual, "Tracer", "TRACER_ON", function(v)
    if not v then
        for _, t in pairs(tracers) do 
            t.Visible = false 
        end
    end
end)
makeSlider(pageVisual, "Tracer Thickness", "TracerThickness", 1, 5, 2)
makeToggle(pageVisual, "Fullbright", "FULLBRIGHT_ON", function(v)
    if v then
        Lighting.Brightness = 4
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 2
        Lighting.GlobalShadows = true
    end
end)

-- MISC PAGE
makeToggle(pageMisc, "Speed Boost", "SpeedBoost")
makeSlider(pageMisc, "Speed Value", "SpeedValue", 16, 100, 19)
makeButton(pageMisc, "Reset Speed", C.Red, function()
    local h = getHum()
    if h then h.WalkSpeed = S.DefaultSpeed end
    S.SpeedBoost = false
end)
makeToggle(pageMisc, "Infinite Jump", "InfiniteJump")
makeToggle(pageMisc, "No Clip", "NoClip")
makeToggle(pageMisc, "Fly", "Fly", function(v)
    if v then flyEnable() else flyDisable() end
end)
makeSlider(pageMisc, "Fly Speed", "FlySpeed", 20, 250, 60)
makeToggle(pageMisc, "Killer Alert", "ALERT_ON")
makeToggle(pageMisc, "Anti-AFK", "AntiAFK")

makeButton(pageMisc, "Rescan Remotes", C.Purple, function()
    local n = scanRemotes()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Remotes",
            Text = n .. " cached",
            Duration = 2,
        })
    end)
end)
makeButton(pageMisc, "Rejoin Server", C.Orange, function()
    pcall(function() 
        TeleportService:Teleport(game.PlaceId, LocalPlayer) 
    end)
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [23] OPEN/CLOSE
-- ═══════════════════════════════════════════════════════════════════════
openBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    if frame.Visible then
        frame.Size = UDim2.new(0, 0, 0, 0)
        U.tw(frame, { Size = UDim2.new(0, MAIN_W, 0, MAIN_H) }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [24] CHAT COMMANDS
-- ═══════════════════════════════════════════════════════════════════════
LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == "!esp" then 
        S.ESP_ON = not S.ESP_ON 
        if S.ESP_ON then
            for _, plr in ipairs(Players:GetPlayers()) do AddESP(plr) end
        else
            for _, h in pairs(highlights) do h:Destroy() end
            highlights = {}
        end
    elseif msg == "!tracer" then 
        S.TRACER_ON = not S.TRACER_ON 
    elseif msg == "!veil" then 
        S.VEIL_ON = not S.VEIL_ON 
    elseif msg == "!silent" then 
        S.SILENT_ON = not S.SILENT_ON 
    elseif msg == "!gen" then 
        S.GEN_ON = not S.GEN_ON 
    elseif msg == "!parry" then 
        S.PARRY_ON = not S.PARRY_ON 
    elseif msg == "!panic" then
        S.ESP_ON = false
        S.TRACER_ON = false
        S.ALERT_ON = false
        S.VEIL_ON = false
        S.SILENT_ON = false
        S.GEN_ON = false
        S.PARRY_ON = false
        S.SpeedBoost = false
        S.Fly = false
        S.NoClip = false
        flyDisable()
        for _, h in pairs(highlights) do h:Destroy() end
        highlights = {}
        for _, t in pairs(tracers) do t.Visible = false end
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "PANIC",
                Text = "All stopped",
                Duration = 2,
            })
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [25] BOOT
-- ═══════════════════════════════════════════════════════════════════════
local n = scanRemotes()

print("╔══════════════════════════════════════════════════════════════╗")
print("║   VD FULL HUB v" .. CFG.VERSION .. " - " .. CFG.GAME)
print("║   Base: " .. CFG.BASE)
print("║   Remotes cached: " .. n)
print("║   Chat: !esp !tracer !veil !silent !gen !parry !panic")
print("╚══════════════════════════════════════════════════════════════╝")

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "VD Full Hub",
        Text = "v" .. CFG.VERSION .. " loaded!",
        Duration = 3,
    })
end)
