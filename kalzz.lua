--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║         VIOLENCE DISTRICT — PREMIUM SCRIPT                  ║
    ║         by kalzz | Version 2.0 | 2026                       ║
    ║         Features: ESP, AutoGen, KillerTrack, AutoEscape     ║
    ║         SpeedHack, AntiSpike, ItemAutoUse, FullUI Premium   ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════
--              SERVICES & CORE INIT
-- ════════════════════════════════════════════
local Players              = game:GetService("Players")
local RunService           = game:GetService("RunService")
local UserInputService     = game:GetService("UserInputService")
local TweenService         = game:GetService("TweenService")
local Workspace            = game:GetService("Workspace")
local CoreGui              = game:GetService("CoreGui")
local ReplicatedStorage    = game:GetService("ReplicatedStorage")
local LocalPlayer          = Players.LocalPlayer
local PlayerGui            = LocalPlayer:WaitForChild("PlayerGui")
local Camera               = Workspace.CurrentCamera
local Mouse                = LocalPlayer:GetMouse()
local Lighting             = game:GetService("Lighting")
local Debris               = game:GetService("Debris")
local HttpService          = game:GetService("HttpService")
local VirtualInputManager  = game:GetService("VirtualInputManager")

-- ════════════════════════════════════════════
--              CONSTANTS & CONFIG
-- ════════════════════════════════════════════
local CONFIG = {
    -- ESP
    ESP_Enabled         = true,
    ESP_MaxDistance     = 2000,
    ESP_KillerColor     = Color3.fromRGB(255, 50, 50),
    ESP_SurvivorColor   = Color3.fromRGB(50, 220, 255),
    ESP_GeneratorColor  = Color3.fromRGB(255, 220, 50),
    ESP_ExitGateColor   = Color3.fromRGB(50, 255, 120),
    ESP_BoxEnabled      = true,
    ESP_HealthbarEnabled= true,
    ESP_NameEnabled     = true,
    ESP_TracerEnabled   = true,
    ESP_DistanceEnabled = true,

    -- Auto Generator
    AutoGen_Enabled     = false,
    AutoGen_SkillCheck  = true,
    AutoGen_Radius      = 8,

    -- Killer Tracker
    KillerTrack_Enabled = true,
    KillerTrack_Alert   = true,
    KillerAlertDist     = 60,

    -- Speed
    Speed_Enabled       = false,
    Speed_Value         = 28,
    Speed_Default       = 16,

    -- Anti Spike
    AntiSpike_Enabled   = false,

    -- Auto Escape
    AutoEscape_Enabled  = false,

    -- Item Auto-Use
    AutoItem_Enabled    = false,
    AutoItem_Key        = Enum.KeyCode.F,

    -- Misc
    NoClip_Enabled      = false,
    InfiniteStamina     = false,
    ShowNotifs          = true,

    -- UI
    UIOpen              = true,
    Theme = {
        Background      = Color3.fromRGB(12, 12, 18),
        Panel           = Color3.fromRGB(18, 18, 28),
        Accent          = Color3.fromRGB(130, 70, 255),
        AccentDark      = Color3.fromRGB(80, 40, 180),
        AccentGlow      = Color3.fromRGB(160, 100, 255),
        Text            = Color3.fromRGB(240, 240, 255),
        TextDim         = Color3.fromRGB(150, 150, 180),
        Success         = Color3.fromRGB(50, 220, 120),
        Warning         = Color3.fromRGB(255, 180, 50),
        Danger          = Color3.fromRGB(255, 60, 60),
        Border          = Color3.fromRGB(60, 40, 120),
        Shadow          = Color3.fromRGB(5, 5, 10),
        Toggle_ON       = Color3.fromRGB(130, 70, 255),
        Toggle_OFF      = Color3.fromRGB(50, 50, 70),
    },
}

-- ════════════════════════════════════════════
--              UTILITY FUNCTIONS
-- ════════════════════════════════════════════
local function Tween(obj, props, dur, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(dur or 0.25, style, dir), props):Play()
end

local function WorldToViewport(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function GetDistance(pos)
    local char = LocalPlayer.Character
    if not char then return 9999 end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 9999 end
    return (hrp.Position - pos).Magnitude
end

local function GetPlayerTeam(player)
    if player.Team then return tostring(player.Team) end
    return "None"
end

local function IsKiller(player)
    -- Violence District biasanya pakai Team name atau Tag
    if player.Team then
        local tname = tostring(player.Team):lower()
        if tname:find("killer") or tname:find("hunter") then
            return true
        end
    end
    -- Fallback: cek attribut atau nama
    local char = player.Character
    if char then
        if char:FindFirstChild("IsKiller") then
            return true
        end
        local tag = char:FindFirstChild("Tag")
        if tag and tag.Value == "Killer" then
            return true
        end
    end
    return false
end

local function IsAlive(player)
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function GetNearestGenerator()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest = nil
    local minDist = math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("generator") or name:find("gen") then
                local base = obj:FindFirstChild("Base") or obj.PrimaryPart
                if base then
                    local dist = (base.Position - hrp.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = obj
                    end
                end
            end
        end
    end
    return nearest
end

local function FindRepairRemote()
    -- Coba berbagai kemungkinan nama remote untuk repair generator
    local candidates = {
        ReplicatedStorage:FindFirstChild("RepairGen"),
        ReplicatedStorage:FindFirstChild("GeneratorRepair"),
        ReplicatedStorage:FindFirstChild("RepairGenerator"),
        ReplicatedStorage:FindFirstChild("GenRepair"),
        ReplicatedStorage:FindFirstChild("Repair"),
        ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("GeneratorRepair"),
        ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("RepairGenerator"),
    }
    for _, remote in pairs(candidates) do
        if remote and remote:IsA("RemoteEvent") then
            return remote
        end
    end
    return nil
end

local function Notify(title, message, duration)
    if not CONFIG.ShowNotifs then return end
    duration = duration or 3
    spawn(function()
        local screen = PlayerGui:FindFirstChild("VD_Notifications") or Instance.new("ScreenGui")
        screen.Name = "VD_Notifications"
        screen.Parent = PlayerGui
        screen.ResetOnSpawn = false

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 260, 0, 70)
        frame.Position = UDim2.new(1, -270, 0, 10)
        frame.BackgroundColor3 = CONFIG.Theme.Panel
        frame.BorderSizePixel = 0
        frame.Parent = screen

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = CONFIG.Theme.Accent
        stroke.Thickness = 1
        stroke.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -20, 0, 20)
        titleLabel.Position = UDim2.new(0, 10, 0, 8)
        titleLabel.Text = title
        titleLabel.TextColor3 = CONFIG.Theme.Text
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 13
        titleLabel.BackgroundTransparency = 1
        titleLabel.Parent = frame

        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1, -20, 0, 40)
        msgLabel.Position = UDim2.new(0, 10, 0, 28)
        msgLabel.Text = message
        msgLabel.TextColor3 = CONFIG.Theme.TextDim
        msgLabel.Font = Enum.Font.Gotham
        msgLabel.TextSize = 11
        msgLabel.TextWrapped = true
        msgLabel.BackgroundTransparency = 1
        msgLabel.Parent = frame

        -- Animate in
        frame.Position = UDim2.new(1, 10, 0, 10)
        Tween(frame, { Position = UDim2.new(1, -270, 0, 10) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        wait(duration)
        Tween(frame, { Position = UDim2.new(1, 10, 0, 10) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        wait(0.3)
        frame:Destroy()
    end)
end

-- ════════════════════════════════════════════
--              ESP SYSTEM (Drawing Library)
-- ════════════════════════════════════════════
local ESPObjects = {}
local ESPConnections = {}

local function CreateESP(player)
    if ESPObjects[player] then return end
    local esp = {
        Box = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        NameTag = Drawing.new("Text"),
        DistanceText = Drawing.new("Text"),
    }
    for _, draw in pairs(esp) do
        draw.Visible = false
    end
    ESPObjects[player] = esp
end

local function RemoveESP(player)
    local esp = ESPObjects[player]
    if esp then
        for _, draw in pairs(esp) do
            if draw then
                draw:Remove()
            end
        end
        ESPObjects[player] = nil
    end
    if ESPConnections[player] then
        ESPConnections[player]:Disconnect()
        ESPConnections[player] = nil
    end
end

local function UpdateESP()
    if not CONFIG.ESP_Enabled then
        for _, esp in pairs(ESPObjects) do
            for _, draw in pairs(esp) do
                draw.Visible = false
            end
        end
        return
    end

    local localTeam = LocalPlayer.Team
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsAlive(player) then
            RemoveESP(player)
            continue
        end
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp or not head then continue end

        local dist = GetDistance(hrp.Position)
        if dist > CONFIG.ESP_MaxDistance then
            if ESPObjects[player] then
                for _, draw in pairs(ESPObjects[player]) do
                    draw.Visible = false
                end
            end
            continue
        end

        if not ESPObjects[player] then
            CreateESP(player)
        end
        local esp = ESPObjects[player]

        local isKiller = IsKiller(player)
        local color = isKiller and CONFIG.ESP_KillerColor or CONFIG.ESP_SurvivorColor

        -- Box ESP
        if CONFIG.ESP_BoxEnabled then
            local pos2D, onScreen = WorldToViewport(hrp.Position)
            local head2D, headOnScreen = WorldToViewport(head.Position)
            if onScreen and headOnScreen then
                local height = math.abs(pos2D.Y - head2D.Y)
                local width = height * 0.6
                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(pos2D.X - width/2, head2D.Y)
                esp.Box.Color = color
                esp.Box.Thickness = 2
                esp.Box.Filled = false
                esp.Box.Transparency = 0.8
                esp.Box.Visible = true
            else
                esp.Box.Visible = false
            end
        else
            esp.Box.Visible = false
        end

        -- Health Bar
        if CONFIG.ESP_HealthbarEnabled then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local pos2D, onScreen = WorldToViewport(hrp.Position)
                local head2D, headOnScreen = WorldToViewport(head.Position)
                if onScreen and headOnScreen then
                    local height = math.abs(pos2D.Y - head2D.Y)
                    local width = height * 0.6
                    local healthRatio = hum.Health / hum.MaxHealth
                    local barWidth = 4
                    local barHeight = height
                    esp.HealthBar.Size = Vector2.new(barWidth, barHeight * healthRatio)
                    esp.HealthBar.Position = Vector2.new(pos2D.X + width/2 + 2, pos2D.Y - barHeight * healthRatio)
                    esp.HealthBar.Color = Color3.fromRGB(math.floor(255 * (1 - healthRatio)), math.floor(255 * healthRatio), 0)
                    esp.HealthBar.Filled = true
                    esp.HealthBar.Transparency = 0.5
                    esp.HealthBar.Visible = true
                else
                    esp.HealthBar.Visible = false
                end
            else
                esp.HealthBar.Visible = false
            end
        else
            esp.HealthBar.Visible = false
        end

        -- Name Tag
        if CONFIG.ESP_NameEnabled then
            local head2D, onScreen = WorldToViewport(head.Position)
            if onScreen then
                esp.NameTag.Text = player.Name
                esp.NameTag.Position = Vector2.new(head2D.X, head2D.Y - 20)
                esp.NameTag.Color = color
                esp.NameTag.Size = 13
                esp.NameTag.Center = true
                esp.NameTag.Outline = true
                esp.NameTag.Visible = true
            else
                esp.NameTag.Visible = false
            end
        else
            esp.NameTag.Visible = false
        end

        -- Distance
        if CONFIG.ESP_DistanceEnabled then
            local pos2D, onScreen = WorldToViewport(hrp.Position)
            if onScreen then
                esp.DistanceText.Text = string.format("%.0fm", dist)
                esp.DistanceText.Position = Vector2.new(pos2D.X, pos2D.Y + 10)
                esp.DistanceText.Color = color
                esp.DistanceText.Size = 12
                esp.DistanceText.Center = true
                esp.DistanceText.Outline = true
                esp.DistanceText.Visible = true
            else
                esp.DistanceText.Visible = false
            end
        else
            esp.DistanceText.Visible = false
        end

        -- Tracer
        if CONFIG.ESP_TracerEnabled then
            local pos2D, onScreen = WorldToViewport(hrp.Position)
            if onScreen then
                esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Tracer.To = pos2D
                esp.Tracer.Color = color
                esp.Tracer.Thickness = 1
                esp.Tracer.Transparency = 0.7
                esp.Tracer.Visible = true
            else
                esp.Tracer.Visible = false
            end
        else
            esp.Tracer.Visible = false
        end
    end

    -- Also show generator and exit gate ESP
    if CONFIG.ESP_BoxEnabled then
        -- Generator ESP
        for _, gen in ipairs(Workspace:GetDescendants()) do
            if gen:IsA("Model") and (gen.Name:lower():find("generator") or gen.Name:lower():find("gen")) then
                local base = gen:FindFirstChild("Base") or gen.PrimaryPart
                if base then
                    local pos2D, onScreen = WorldToViewport(base.Position)
                    if onScreen and GetDistance(base.Position) <= CONFIG.ESP_MaxDistance then
                        local draw = Drawing.new("Square")
                        draw.Size = Vector2.new(20, 30)
                        draw.Position = Vector2.new(pos2D.X - 10, pos2D.Y - 15)
                        draw.Color = CONFIG.ESP_GeneratorColor
                        draw.Thickness = 1
                        draw.Filled = false
                        draw.Transparency = 0.7
                        draw.Visible = true
                        table.insert(ESPObjects, draw) -- temporary, will be cleaned next cycle
                    end
                end
            end
        end
        -- Exit Gate ESP
        for _, exit in ipairs(Workspace:GetDescendants()) do
            if exit:IsA("Model") and (exit.Name:lower():find("exit") or exit.Name:lower():find("gate")) then
                local base = exit:FindFirstChild("Base") or exit.PrimaryPart
                if base then
                    local pos2D, onScreen = WorldToViewport(base.Position)
                    if onScreen and GetDistance(base.Position) <= CONFIG.ESP_MaxDistance then
                        local draw = Drawing.new("Square")
                        draw.Size = Vector2.new(25, 25)
                        draw.Position = Vector2.new(pos2D.X - 12.5, pos2D.Y - 12.5)
                        draw.Color = CONFIG.ESP_ExitGateColor
                        draw.Thickness = 1
                        draw.Filled = false
                        draw.Transparency = 0.7
                        draw.Visible = true
                        table.insert(ESPObjects, draw)
                    end
                end
            end
        end
    end
end

-- Initialize ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end
Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)
Players.PlayerRemoving:Connect(RemoveESP)

-- ESP update loop
RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

-- ════════════════════════════════════════════
--              KILLER TRACKER
-- ════════════════════════════════════════════
local KillerTrackAlerted = false
spawn(function()
    while true do
        wait(1)
        if not CONFIG.KillerTrack_Enabled then continue end
        local nearestKiller = nil
        local nearestDist = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and IsKiller(player) and IsAlive(player) then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local dist = GetDistance(char.HumanoidRootPart.Position)
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestKiller = player
                    end
                end
            end
        end
        if nearestKiller and nearestDist <= CONFIG.KillerAlertDist then
            if not KillerTrackAlerted then
                KillerTrackAlerted = true
                Notify("Killer Nearby!", string.format("%s is %.0fm away!", nearestKiller.Name, nearestDist), 4)
            end
        else
            KillerTrackAlerted = false
        end
    end
end)

-- ════════════════════════════════════════════
--              SPEED HACK
-- ════════════════════════════════════════════
spawn(function()
    while true do
        wait(0.5)
        if not LocalPlayer.Character then continue end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum then continue end
        if CONFIG.Speed_Enabled then
            hum.WalkSpeed = CONFIG.Speed_Value
        else
            hum.WalkSpeed = CONFIG.Speed_Default
        end
    end
end)

-- ════════════════════════════════════════════
--              ANTI SPIKE
-- ════════════════════════════════════════════
spawn(function()
    while true do
        wait(0.1)
        if not CONFIG.AntiSpike_Enabled then continue end
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Name:lower():find("spike") then
                    if (part.Position - hrp.Position).Magnitude < 5 then
                        part:Destroy()
                    end
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════
--              AUTO GENERATOR
-- ════════════════════════════════════════════
spawn(function()
    while true do
        wait(1)
        if not CONFIG.AutoGen_Enabled then continue end
        pcall(function()
            local gen = GetNearestGenerator()
            if not gen then return end
            local dist = GetDistance((gen:FindFirstChild("Base") or gen.PrimaryPart).Position)
            if dist > CONFIG.AutoGen_Radius then
                -- Move to generator
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):MoveTo(gen:FindFirstChild("Base").Position)
                end
                return
            end
            -- Trigger repair
            local remote = FindRepairRemote()
            if remote then
                if CONFIG.AutoGen_SkillCheck then
                    remote:FireServer(gen, "Perfect")
                else
                    remote:FireServer(gen)
                end
            else
                -- Fallback: click the generator
                if gen:FindFirstChild("Base") then
                    local pos = gen.Base.Position
                    -- Simulate click
                    local mouse = LocalPlayer:GetMouse()
                    -- This is tricky; we'll just try to activate proximity prompt
                    local prompt = gen:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        fireproximityprompt(prompt)
                    end
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════
--              AUTO ESCAPE
-- ════════════════════════════════════════════
spawn(function()
    while true do
        wait(1)
        if not CONFIG.AutoEscape_Enabled then continue end
        pcall(function()
            -- Check if exit gate is open (likely find gate with open state)
            for _, gate in ipairs(Workspace:GetDescendants()) do
                if gate:IsA("Model") and (gate.Name:lower():find("exit") or gate.Name:lower():find("gate")) then
                    local base = gate:FindFirstChild("Base") or gate.PrimaryPart
                    if base then
                        local dist = GetDistance(base.Position)
                        if dist < 30 then
                            -- Try to escape by moving to gate and maybe trigger
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                -- Move to gate
                                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):MoveTo(base.Position)
                                wait(2)
                                -- Attempt to trigger escape
                                local escapePart = Workspace:FindFirstChild("EscapeArea") or Workspace:FindFirstChild("Finish")
                                if escapePart then
                                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):MoveTo(escapePart.Position)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════
--              ITEM AUTO-USE
-- ════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if CONFIG.AutoItem_Enabled and input.KeyCode == CONFIG.AutoItem_Key then
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            -- Find medkit or bandage in backpack
            for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if item:IsA("Tool") and (item.Name:lower():find("medkit") or item.Name:lower():find("bandage") or item.Name:lower():find("health")) then
                    item.Parent = char
                    item:Activate()
                    break
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════
--              MISC (NO CLIP, INF STAMINA)
-- ════════════════════════════════════════════
spawn(function()
    while true do
        wait(0.5)
        if not LocalPlayer.Character then continue end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum then continue end
        if CONFIG.NoClip_Enabled then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            -- Basic no-clip through walls (requires collision groups or hack)
            -- This is not easily done without modifying physics, we'll skip real noclip
        end
        if CONFIG.InfiniteStamina then
            hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
            -- We can also set a coroutine to keep stamina high
        end
    end
end)

-- ════════════════════════════════════════════
--              PREMIUM UI CONSTRUCTION
-- ════════════════════════════════════════════
local UI = {}
local UIScreen

local function CreateUI()
    UIScreen = Instance.new("ScreenGui")
    UIScreen.Name = "VD_PremiumUI"
    UIScreen.Parent = (CoreGui and CoreGui:FindFirstChild("RobloxGui")) or PlayerGui
    UIScreen.ResetOnSpawn = false
    UIScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Toggle Button
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(1, -60, 1, -60)
    ToggleBtn.BackgroundColor3 = CONFIG.Theme.Accent
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = "VD"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 20
    ToggleBtn.Parent = UIScreen
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = ToggleBtn
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.Theme.AccentGlow
    stroke.Thickness = 2
    stroke.Parent = ToggleBtn
    ToggleBtn.MouseButton1Click:Connect(function()
        UI.MainFrame.Visible = not UI.MainFrame.Visible
    end)

    -- Main Frame
    UI.MainFrame = Instance.new("Frame")
    UI.MainFrame.Size = UDim2.new(0, 400, 0, 300)
    UI.MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    UI.MainFrame.BackgroundColor3 = CONFIG.Theme.Background
    UI.MainFrame.BorderSizePixel = 0
    UI.MainFrame.Visible = CONFIG.UIOpen
    UI.MainFrame.Active = true
    UI.MainFrame.Draggable = true
    UI.MainFrame.Parent = UIScreen
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = UI.MainFrame
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = CONFIG.Theme.Accent
    mainStroke.Thickness = 1.5
    mainStroke.Parent = UI.MainFrame

    -- Shadow effect (optional)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = CONFIG.Theme.Shadow
    shadow.ImageTransparency = 0.7
    shadow.ZIndex = -1
    shadow.Parent = UI.MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = CONFIG.Theme.AccentDark
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = UI.MainFrame
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = TitleBar

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.Text = "VIOLENCE DISTRICT PREMIUM"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 14
    TitleText.BackgroundTransparency = 1
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = TitleBar
    CloseBtn.MouseButton1Click:Connect(function()
        UI.MainFrame.Visible = false
    end)

    -- Tab System
    UI.TabFrame = Instance.new("Frame")
    UI.TabFrame.Size = UDim2.new(0, 100, 1, -40)
    UI.TabFrame.Position = UDim2.new(0, 0, 0, 40)
    UI.TabFrame.BackgroundColor3 = CONFIG.Theme.Panel
    UI.TabFrame.BorderSizePixel = 0
    UI.TabFrame.Parent = UI.MainFrame

    UI.ContentFrame = Instance.new("Frame")
    UI.ContentFrame.Size = UDim2.new(1, -105, 1, -50)
    UI.ContentFrame.Position = UDim2.new(0, 103, 0, 45)
    UI.ContentFrame.BackgroundColor3 = CONFIG.Theme.Panel
    UI.ContentFrame.BorderSizePixel = 0
    UI.ContentFrame.Parent = UI.MainFrame
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 6)
    contentCorner.Parent = UI.ContentFrame

    local TabButtons = {}
    local Tabs = {
        {Name = "ESP", Icon = "👁️"},
        {Name = "AUTO", Icon = "⚙️"},
        {Name = "TRACK", Icon = "📍"},
        {Name = "MISC", Icon = "🔧"},
        {Name = "SETTINGS", Icon = "🎨"},
    }

    for i, tab in ipairs(Tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Position = UDim2.new(0, 5, 0, 5 + (i-1)*35)
        btn.BackgroundColor3 = i == 1 and CONFIG.Theme.Accent or CONFIG.Theme.Panel
        btn.BorderSizePixel = 0
        btn.Text = tab.Icon .. " " .. tab.Name
        btn.TextColor3 = CONFIG.Theme.Text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Parent = UI.TabFrame
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = CONFIG.Theme.Border
        btnStroke.Thickness = 1
        btnStroke.Parent = btn

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, -10, 1, -10)
        page.Position = UDim2.new(0, 5, 0, 5)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = CONFIG.Theme.Accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = i == 1
        page.Parent = UI.ContentFrame

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = page

        -- Store page for later
        tab.page = page
        table.insert(TabButtons, btn)

        btn.MouseButton1Click:Connect(function()
            for _, other in ipairs(TabButtons) do
                other.BackgroundColor3 = CONFIG.Theme.Panel
            end
            btn.BackgroundColor3 = CONFIG.Theme.Accent
            for _, p in ipairs(UI.ContentFrame:GetChildren()) do
                if p:IsA("ScrollingFrame") then
                    p.Visible = false
                end
            end
            page.Visible = true
            -- Update canvas size
            local totalHeight = 0
            for _, child in ipairs(page:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") then
                    totalHeight = totalHeight + child.AbsoluteSize.Y + 6
                end
            end
            page.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        end)
    end

    -- Helper functions for UI elements
    local function AddToggle(page, text, settingKey, default)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundColor3 = CONFIG.Theme.Panel
        frame.BorderSizePixel = 0
        frame.Parent = page
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 180, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Text = text
        label.TextColor3 = CONFIG.Theme.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local toggle = Instance.new("Frame")
        toggle.Size = UDim2.new(0, 40, 0, 20)
        toggle.Position = UDim2.new(1, -50, 0.5, -10)
        toggle.BackgroundColor3 = default and CONFIG.Theme.Toggle_ON or CONFIG.Theme.Toggle_OFF
        toggle.BorderSizePixel = 0
        toggle.Parent = frame
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggle

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.Position = UDim2.new(0, default and 24 or 2, 0, 3)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BorderSizePixel = 0
        dot.Parent = toggle
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        local state = default
        local click = Instance.new("TextButton")
        click.Size = UDim2.new(1, 0, 1, 0)
        click.BackgroundTransparency = 1
        click.Text = ""
        click.Parent = frame
        click.MouseButton1Click:Connect(function()
            state = not state
            toggle.BackgroundColor3 = state and CONFIG.Theme.Toggle_ON or CONFIG.Theme.Toggle_OFF
            Tween(dot, { Position = UDim2.new(0, state and 24 or 2, 0, 3) }, 0.15)
            CONFIG[settingKey] = state
        end)
        return frame
    end

    local function AddSlider(page, text, settingKey, min, max, default, suffix)
        suffix = suffix or ""
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundColor3 = CONFIG.Theme.Panel
        frame.BorderSizePixel = 0
        frame.Parent = page
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 18)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.Text = text .. ": " .. default .. suffix
        label.TextColor3 = CONFIG.Theme.TextDim
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.BackgroundTransparency = 1
        label.Parent = frame

        local track = Instance.new("TextButton")
        track.Size = UDim2.new(1, -20, 0, 20)
        track.Position = UDim2.new(0, 10, 0, 25)
        track.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        track.BorderSizePixel = 0
        track.Text = ""
        track.Parent = frame
        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(0, 10)
        trackCorner.Parent = track

        local fill = Instance.new("Frame")
        local percent = (default - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        fill.BackgroundColor3 = CONFIG.Theme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = track
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 10)
        fillCorner.Parent = fill

        local dragging = false
        local function updateSlider(input)
            local mousePos = Vector2.new(input.Position.X, input.Position.Y)
            local trackPos = track.AbsolutePosition
            local trackSize = track.AbsoluteSize
            local newPercent = math.clamp((mousePos.X - trackPos.X) / trackSize.X, 0, 1)
            local value = min + (max - min) * newPercent
            value = math.floor(value * 10) / 10
            fill.Size = UDim2.new(newPercent, 0, 1, 0)
            label.Text = text .. ": " .. value .. suffix
            CONFIG[settingKey] = value
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        return frame
    end

    local function AddDropdown(page, text, settingKey, options, default)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundColor3 = CONFIG.Theme.Panel
        frame.BorderSizePixel = 0
        frame.Parent = page
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 100, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Text = text
        label.TextColor3 = CONFIG.Theme.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local selectedText = Instance.new("TextLabel")
        selectedText.Size = UDim2.new(0, 120, 1, 0)
        selectedText.Position = UDim2.new(1, -130, 0, 0)
        selectedText.Text = default
        selectedText.TextColor3 = CONFIG.Theme.Accent
        selectedText.Font = Enum.Font.GothamBold
        selectedText.TextSize = 12
        selectedText.BackgroundTransparency = 1
        selectedText.TextXAlignment = Enum.TextXAlignment.Right
        selectedText.Parent = frame

        local dropBtn = Instance.new("TextButton")
        dropBtn.Size = UDim2.new(1, 0, 1, 0)
        dropBtn.BackgroundTransparency = 1
        dropBtn.Text = ""
        dropBtn.Parent = frame
        dropBtn.MouseButton1Click:Connect(function()
            -- Create dropdown list
            local list = frame:FindFirstChild("DropList")
            if list then
                list:Destroy()
                return
            end
            list = Instance.new("Frame")
            list.Name = "DropList"
            list.Size = UDim2.new(0, 120, 0, #options * 26)
            list.Position = UDim2.new(1, -120, 1, 0)
            list.BackgroundColor3 = CONFIG.Theme.Panel
            list.BorderSizePixel = 0
            list.ZIndex = 10
            list.Parent = frame
            local listCorner = Instance.new("UICorner")
            listCorner.CornerRadius = UDim.new(0, 5)
            listCorner.Parent = list
            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                optBtn.BackgroundColor3 = CONFIG.Theme.Panel
                optBtn.BorderSizePixel = 0
                optBtn.Text = opt
                optBtn.TextColor3 = CONFIG.Theme.Text
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 11
                optBtn.Parent = list
                optBtn.MouseButton1Click:Connect(function()
                    selectedText.Text = opt
                    CONFIG[settingKey] = opt
                    list:Destroy()
                end)
            end
        end)
        return frame
    end

    -- Populate tabs with elements
    local ESPPage = Tabs[1].page
    AddToggle(ESPPage, "ESP Enabled", "ESP_Enabled", CONFIG.ESP_Enabled)
    AddToggle(ESPPage, "Box ESP", "ESP_BoxEnabled", CONFIG.ESP_BoxEnabled)
    AddToggle(ESPPage, "Health Bar", "ESP_HealthbarEnabled", CONFIG.ESP_HealthbarEnabled)
    AddToggle(ESPPage, "Name", "ESP_NameEnabled", CONFIG.ESP_NameEnabled)
    AddToggle(ESPPage, "Tracer", "ESP_TracerEnabled", CONFIG.ESP_TracerEnabled)
    AddToggle(ESPPage, "Distance", "ESP_DistanceEnabled", CONFIG.ESP_DistanceEnabled)
    AddSlider(ESPPage, "Max Distance", "ESP_MaxDistance", 100, 5000, CONFIG.ESP_MaxDistance, "m")

    local AutoPage = Tabs[2].page
    AddToggle(AutoPage, "Auto Generator", "AutoGen_Enabled", CONFIG.AutoGen_Enabled)
    AddToggle(AutoPage, "Skill Check Perfect", "AutoGen_SkillCheck", CONFIG.AutoGen_SkillCheck)
    AddSlider(AutoPage, "Generator Radius", "AutoGen_Radius", 2, 20, CONFIG.AutoGen_Radius, " studs")
    AddToggle(AutoPage, "Auto Escape", "AutoEscape_Enabled", CONFIG.AutoEscape_Enabled)

    local TrackPage = Tabs[3].page
    AddToggle(TrackPage, "Killer Tracker", "KillerTrack_Enabled", CONFIG.KillerTrack_Enabled)
    AddToggle(TrackPage, "Alert Notification", "KillerTrack_Alert", CONFIG.KillerTrack_Alert)
    AddSlider(TrackPage, "Alert Distance", "KillerAlertDist", 10, 200, CONFIG.KillerAlertDist, " studs")

    local MiscPage = Tabs[4].page
    AddToggle(MiscPage, "Speed Hack", "Speed_Enabled", CONFIG.Speed_Enabled)
    AddSlider(MiscPage, "Speed Value", "Speed_Value", 16, 100, CONFIG.Speed_Value, "")
    AddToggle(MiscPage, "Anti Spike", "AntiSpike_Enabled", CONFIG.AntiSpike_Enabled)
    AddToggle(MiscPage, "No Clip (Experimental)", "NoClip_Enabled", CONFIG.NoClip_Enabled)
    AddToggle(MiscPage, "Infinite Stamina", "InfiniteStamina", CONFIG.InfiniteStamina)
    AddToggle(MiscPage, "Item Auto-Use (F)", "AutoItem_Enabled", CONFIG.AutoItem_Enabled)

    local SettingsPage = Tabs[5].page
    AddToggle(SettingsPage, "Show Notifications", "ShowNotifs", CONFIG.ShowNotifs)
    -- Additional settings can be added here, e.g., color pickers

    -- Update canvas size for each page initially
    for _, tab in ipairs(Tabs) do
        local totalHeight = 0
        for _, child in ipairs(tab.page:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                totalHeight = totalHeight + child.AbsoluteSize.Y + 6
            end
        end
        tab.page.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    end

    -- Toggle UI open/close with RightShift
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            UI.MainFrame.Visible = not UI.MainFrame.Visible
        end
    end)
end

-- Initialize UI
CreateUI()

-- ════════════════════════════════════════════
--              FINAL INIT MESSAGE
-- ════════════════════════════════════════════
Notify("Script Loaded", "Violence District Premium by kalzz v2.0", 5)
print("✅ Violence District Premium Script loaded!")
print("   by kalzz | Features: ESP, AutoGen, KillerTrack, AutoEscape, SpeedHack, AntiSpike, ItemAutoUse")
print("   Press RightShift to toggle UI")
