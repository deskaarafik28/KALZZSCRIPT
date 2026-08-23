--[[
    VIOLENCE DISTRICT - SILENT AIM GUN & VEIL
    GUI Modern dengan Toggle On/Off
    Ringan, Real-time, Tanpa Emoji
    by kalzz
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==================== CONFIG ====================
local Config = {
    GunAim = true,      -- Silent aim untuk gun (survivor)
    VeilAim = true,     -- Silent aim untuk veil/tombak (killer)
    Range = 250,        -- Jarak maksimum target
}

-- ==================== UTIL ====================
local function findRemote(...)
    local names = {...}
    for _, name in ipairs(names) do
        local remote = ReplicatedStorage:FindFirstChild(name, true)
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            return remote
        end
    end
    return nil
end

local function isKiller(player)
    if not player.Team then return false end
    local teamName = tostring(player.Team):lower()
    return teamName:find("killer") ~= nil or teamName:find("hunter") ~= nil
end

local function getNearestEnemy()
    local localChar = LocalPlayer.Character
    if not localChar then return nil end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end

    local localTeam = LocalPlayer.Team
    local nearest = nil
    local nearestDist = Config.Range

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        -- Filter musuh
        local enemy = false
        if localTeam then
            if player.Team ~= localTeam then enemy = true end
        else
            enemy = true
        end
        if not enemy then continue end

        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = (root.Position - localRoot.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = player
            end
        end
    end
    return nearest
end

-- ==================== SILENT AIM CORE ====================
local function processActivation(tool)
    local toolName = tool.Name:lower()
    local isGun = toolName:find("gun") or toolName:find("pistol") or toolName:find("rifle") or toolName:find("shotgun") or toolName:find("revolver")
    local isVeil = toolName:find("veil") or toolName:find("tombak") or toolName:find("spear") or toolName:find("javelin") or toolName:find("trident")

    if not (isGun or isVeil) then return end

    -- Cek toggle
    if isGun and not Config.GunAim then return end
    if isVeil and not Config.VeilAim then return end

    local target = getNearestEnemy()
    if not target then return end

    local targetChar = target.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    -- Kirim damage / hit
    local damageRemotes = {"Damage", "TakeDamage", "Hit", "DealDamage", "DamageEvent", "HitEvent"}
    local dmgRemote = findRemote(unpack(damageRemotes))
    if dmgRemote then
        pcall(function()
            dmgRemote:FireServer(targetChar, targetRoot.Position, 100)
            dmgRemote:FireServer(target, 100)
            dmgRemote:FireServer(targetRoot.Position, 100)
        end)
    end

    -- Kirim argumen posisi untuk senjata tertentu
    if isGun then
        local shootRemote = findRemote("Shoot", "Fire", "FireServer", "GunShoot", "ShootGun", "FireGun")
        if shootRemote then
            pcall(function()
                shootRemote:FireServer(targetRoot.Position)
                shootRemote:FireServer(targetChar)
            end)
        end
    elseif isVeil then
        local veilRemote = findRemote("VeilAttack", "TombakAttack", "SpearThrow", "JavelinThrow", "ThrowSpear", "VeilThrow")
        if veilRemote then
            pcall(function()
                veilRemote:FireServer(targetRoot.Position)
                veilRemote:FireServer(targetChar)
            end)
        end
    end
end

-- Hook semua tool
local function hookTool(tool)
    if tool:IsA("Tool") then
        tool.Activated:Connect(function()
            processActivation(tool)
        end)
    end
end

local function scanTools()
    if LocalPlayer.Character then
        for _, obj in ipairs(LocalPlayer.Character:GetChildren()) do
            hookTool(obj)
        end
    end
    if LocalPlayer.Backpack then
        for _, obj in ipairs(LocalPlayer.Backpack:GetChildren()) do
            hookTool(obj)
        end
    end
end

-- Re-scan saat tool berubah
if LocalPlayer.Character then
    LocalPlayer.Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then hookTool(child) end
    end)
end
if LocalPlayer.Backpack then
    LocalPlayer.Backpack.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then hookTool(child) end
    end)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then hookTool(child) end
    end)
end)

-- Jalankan scan pertama
scanTools()

-- ==================== GUI MODERN ====================
local Screen = Instance.new("ScreenGui")
Screen.Name = "SilentAimGUI"
Screen.Parent = PlayerGui
Screen.ResetOnSpawn = false
Screen.IgnoreGuiInset = true

-- Panel utama
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 180, 0, 100)
Panel.Position = UDim2.new(1, -190, 1, -110)
Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Draggable = true
Panel.Parent = Screen

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 12)
PanelCorner.Parent = Panel

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(80, 50, 160)
PanelStroke.Thickness = 1.5
PanelStroke.Parent = Panel

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(80, 50, 160)
Header.BorderSizePixel = 0
Header.Parent = Panel
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "SILENT AIM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Toggle 1: Gun
local GunToggle = Instance.new("Frame")
GunToggle.Size = UDim2.new(1, -20, 0, 28)
GunToggle.Position = UDim2.new(0, 10, 0, 38)
GunToggle.BackgroundColor3 = Config.GunAim and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(60, 60, 80)
GunToggle.BorderSizePixel = 0
GunToggle.Parent = Panel
Instance.new("UICorner", GunToggle).CornerRadius = UDim.new(0, 8)

local GunLabel = Instance.new("TextLabel")
GunLabel.Size = UDim2.new(1, -40, 1, 0)
GunLabel.Position = UDim2.new(0, 10, 0, 0)
GunLabel.Text = "Gun Silent Aim"
GunLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
GunLabel.Font = Enum.Font.Gotham
GunLabel.TextSize = 12
GunLabel.BackgroundTransparency = 1
GunLabel.TextXAlignment = Enum.TextXAlignment.Left
GunLabel.Parent = GunToggle

local GunDot = Instance.new("Frame")
GunDot.Size = UDim2.new(0, 18, 0, 18)
GunDot.Position = UDim2.new(1, -28, 0.5, -9)
GunDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GunDot.BorderSizePixel = 0
GunDot.Parent = GunToggle
Instance.new("UICorner", GunDot).CornerRadius = UDim.new(1, 0)

-- Toggle 2: Veil
local VeilToggle = Instance.new("Frame")
VeilToggle.Size = UDim2.new(1, -20, 0, 28)
VeilToggle.Position = UDim2.new(0, 10, 0, 70)
VeilToggle.BackgroundColor3 = Config.VeilAim and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(60, 60, 80)
VeilToggle.BorderSizePixel = 0
VeilToggle.Parent = Panel
Instance.new("UICorner", VeilToggle).CornerRadius = UDim.new(0, 8)

local VeilLabel = Instance.new("TextLabel")
VeilLabel.Size = UDim2.new(1, -40, 1, 0)
VeilLabel.Position = UDim2.new(0, 10, 0, 0)
VeilLabel.Text = "Veil Silent Aim"
VeilLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
VeilLabel.Font = Enum.Font.Gotham
VeilLabel.TextSize = 12
VeilLabel.BackgroundTransparency = 1
VeilLabel.TextXAlignment = Enum.TextXAlignment.Left
VeilLabel.Parent = VeilToggle

local VeilDot = Instance.new("Frame")
VeilDot.Size = UDim2.new(0, 18, 0, 18)
VeilDot.Position = UDim2.new(1, -28, 0.5, -9)
VeilDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
VeilDot.BorderSizePixel = 0
VeilDot.Parent = VeilToggle
Instance.new("UICorner", VeilDot).CornerRadius = UDim.new(1, 0)

-- Fungsi untuk toggle animation
local function toggleSwitch(frame, dot, state)
    local targetColor = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(60, 60, 80)
    local targetPos = state and UDim2.new(1, -28, 0.5, -9) or UDim2.new(0, 5, 0.5, -9)
    TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
    TweenService:Create(dot, TweenInfo.new(0.15), {Position = targetPos}):Play()
end

local gunState = Config.GunAim
GunToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        gunState = not gunState
        Config.GunAim = gunState
        toggleSwitch(GunToggle, GunDot, gunState)
    end
end)

local veilState = Config.VeilAim
VeilToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        veilState = not veilState
        Config.VeilAim = veilState
        toggleSwitch(VeilToggle, VeilDot, veilState)
    end
end)

print("Silent Aim System Loaded")
print("Gun: Survivor auto lock killer")
print("Veil: Killer auto lock survivor")
print("GUI di pojok kanan bawah, drag untuk pindah")
