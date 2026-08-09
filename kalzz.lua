--[[
    ╔══════════════════════════════════════════╗
    ║   VIOLENCE DISTRICT - SUPER SCRIPT      ║
    ║   Fitur Super Lengkap | UI/UX Modern    ║
    ║   Delta Executor | Mobile Friendly      ║
    ╚══════════════════════════════════════════╝
]]

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- ====================== CONFIG ======================
local Config = {
    -- Player
    AutoParry = false,
    ParryFOV = 30,              -- 10-90
    SpeedBoost = 28,            -- 16-100
    JumpPower = 75,             -- 50-200
    InfiniteJump = false,
    Moonwalk = false,
    AntiStun = false,
    NoFallDamage = false,
    
    -- ESP
    PlayerESP = false,          -- Survivor (hijau)
    KillerESP = false,          -- Killer (merah/biru)
    KillerColor = "Merah",
    GeneratorESP = false,
    ChestESP = false,
    ExitESP = false,
    
    -- Survival
    AutoGen = false,
    GenMethod = "Instant",      -- Instant, Perfect, Normal
    AutoHeal = false,
    AutoExit = false,
    
    -- Killer
    Aimbot = false,
    AimbotFOV = 100,            -- 50-300
    AimbotKey = "MouseButton2", -- right click
    AimbotPart = "Head",        -- Head, UpperTorso, HumanoidRootPart
    KillerESP_Survivor = false, -- ESP untuk killer
    
    -- World
    Fullbright = false,
    AntiTrap = false,
}

-- ====================== CLEAN OLD UI ======================
for _, v in ipairs(PlayerGui:GetChildren()) do
    if v.Name == "VD_SuperUI" then v:Destroy() end
end

-- ====================== CREATE SCREEN ======================
local Screen = Instance.new("ScreenGui")
Screen.Name = "VD_SuperUI"
Screen.Parent = PlayerGui
Screen.ResetOnSpawn = false
Screen.IgnoreGuiInset = true

-- ====================== TOGGLE BUTTON ======================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 54, 0, 54)
ToggleBtn.Position = UDim2.new(1, -64, 1, -64)
ToggleBtn.Text = ""
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.BorderSizePixel = 0
ToggleBtn.ZIndex = 15
ToggleBtn.Parent = Screen

local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(0, 14)

local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(0, 220, 220)
ToggleStroke.Thickness = 2

local ToggleIcon = Instance.new("TextLabel", ToggleBtn)
ToggleIcon.Size = UDim2.new(1, 0, 1, 0)
ToggleIcon.Text = "VD"
ToggleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleIcon.TextSize = 22
ToggleIcon.Font = Enum.Font.GothamBold
ToggleIcon.BackgroundTransparency = 1

-- ====================== MAIN MENU ======================
local Menu = Instance.new("Frame")
Menu.Size = UDim2.new(0, 360, 0, 280)
Menu.Position = UDim2.new(0.5, -180, 0.5, -140)
Menu.BackgroundColor3 = Color3.fromRGB(16, 16, 26)
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.Active = true
Menu.Draggable = true
Menu.ZIndex = 10
Menu.Parent = Screen

local MenuCorner = Instance.new("UICorner", Menu)
MenuCorner.CornerRadius = UDim.new(0, 14)

local MenuStroke = Instance.new("UIStroke", Menu)
MenuStroke.Color = Color3.fromRGB(0, 220, 200)
MenuStroke.Thickness = 1.5

-- Title
local TitleBar = Instance.new("Frame", Menu)
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.Text = "⚡ VD SUPER SCRIPT"
TitleText.TextColor3 = Color3.fromRGB(0, 255, 200)
TitleText.TextSize = 15
TitleText.Font = Enum.Font.GothamBold
TitleText.BackgroundTransparency = 1
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 5)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function()
    Menu.Visible = false
end)

-- Tab System
local TabHolder = Instance.new("Frame", Menu)
TabHolder.Size = UDim2.new(0, 85, 1, -42)
TabHolder.Position = UDim2.new(0, 0, 0, 42)
TabHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
TabHolder.BorderSizePixel = 0
local TabPad = Instance.new("UIPadding", TabHolder)
TabPad.PaddingTop = UDim.new(0, 8)
TabPad.PaddingLeft = UDim.new(0, 6)
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.Padding = UDim.new(0, 6)

local Content = Instance.new("Frame", Menu)
Content.Size = UDim2.new(1, -90, 1, -50)
Content.Position = UDim2.new(0, 87, 0, 46)
Content.BackgroundColor3 = Color3.fromRGB(24, 24, 38)
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 10)

local Scroll = Instance.new("ScrollingFrame", Content)
Scroll.Size = UDim2.new(1, -8, 1, -8)
Scroll.Position = UDim2.new(0, 4, 0, 4)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 220, 200)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local ScrollLayout = Instance.new("UIListLayout", Scroll)
ScrollLayout.Padding = UDim.new(0, 6)

local Tabs = {"PLAYER", "ESP", "SURVIVAL", "KILLER", "WORLD"}
local Pages = {}
for i, tabName in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton", TabHolder)
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 11
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.BackgroundColor3 = i == 1 and Color3.fromRGB(0, 200, 200) or Color3.fromRGB(34, 34, 48)
    TabBtn.BorderSizePixel = 0
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 7)
    
    local Page = Instance.new("Frame", Scroll)
    Page.Size = UDim2.new(1, 0, 0, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = (i == 1)
    Pages[tabName] = Page
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Page.Visible = true
        for _, btn in ipairs(TabHolder:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(34, 34, 48)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
        TabBtn.TextColor3 = Color3.fromRGB(20, 20, 30)
    end)
end

-- UI Components
local function Section(parent, title)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    local dot = Instance.new("Frame", f)
    dot.Size = UDim2.new(0, 4, 0, 4)
    dot.Position = UDim2.new(0, 0, 0.5, -2)
    dot.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(0, 255, 200)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function Toggle(parent, text, default, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundColor3 = Color3.fromRGB(34, 34, 46)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0, 155, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local bg = Instance.new("Frame", f)
    bg.Size = UDim2.new(0, 40, 0, 20)
    bg.Position = UDim2.new(1, -52, 0.5, -10)
    bg.BackgroundColor3 = default and Color3.fromRGB(0, 200, 140) or Color3.fromRGB(80, 80, 90)
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local dot = Instance.new("Frame", bg)
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = default and UDim2.new(0, 24, 0, 3) or UDim2.new(0, 2, 0, 3)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local state = default
    local click = Instance.new("TextButton", f)
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.MouseButton1Click:Connect(function()
        state = not state
        bg.BackgroundColor3 = state and Color3.fromRGB(0, 200, 140) or Color3.fromRGB(80, 80, 90)
        TweenService:Create(dot, TweenInfo.new(0.15), {
            Position = state and UDim2.new(0, 24, 0, 3) or UDim2.new(0, 2, 0, 3)
        }):Play()
        callback(state)
    end)
end

local function Slider(parent, text, min, max, default, callback, suffix)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 56)
    f.BackgroundColor3 = Color3.fromRGB(34, 34, 46)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -12, 0, 16)
    lbl.Position = UDim2.new(0, 6, 0, 4)
    lbl.Text = text .. ": " .. default .. (suffix or "")
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local track = Instance.new("TextButton", f)
    track.Size = UDim2.new(1, -12, 0, 20)
    track.Position = UDim2.new(0, 6, 0, 27)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    track.BorderSizePixel = 0
    track.Text = ""
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)
    local pct = (default - min) / (max - min)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
    local function upd(inputX)
        local pos = track.AbsolutePosition.X
        local sz = track.AbsoluteSize.X
        local pc = math.clamp((inputX - pos) / sz, 0, 1)
        local val = math.floor((min + (max - min) * pc) * 10) / 10
        fill.Size = UDim2.new(pc, 0, 1, 0)
        lbl.Text = text .. ": " .. val .. (suffix or "")
        callback(val)
    end
    track.MouseButton1Down:Connect(function()
        local mouse = UserInputService:GetMouseLocation()
        upd(mouse.X)
        local conn
        conn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                upd(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                conn:Disconnect()
            end
        end)
    end)
end

local function Dropdown(parent, text, options, default, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundColor3 = Color3.fromRGB(34, 34, 46)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0, 100, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local sel = Instance.new("TextLabel", f)
    sel.Size = UDim2.new(0, 120, 1, 0)
    sel.Position = UDim2.new(1, -135, 0, 0)
    sel.Text = default
    sel.TextColor3 = Color3.fromRGB(0, 220, 200)
    sel.TextSize = 12
    sel.Font = Enum.Font.GothamBold
    sel.BackgroundTransparency = 1
    sel.TextXAlignment = Enum.TextXAlignment.Right
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.MouseButton1Click:Connect(function()
        local old = f:FindFirstChild("DropList")
        if old then old:Destroy() return end
        local dl = Instance.new("Frame", f)
        dl.Name = "DropList"
        dl.Size = UDim2.new(0, 120, 0, #options * 26)
        dl.Position = UDim2.new(1, -120, 1, 0)
        dl.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
        dl.BorderSizePixel = 0
        dl.ZIndex = 10
        Instance.new("UICorner", dl).CornerRadius = UDim.new(0, 5)
        for _, opt in ipairs(options) do
            local ob = Instance.new("TextButton", dl)
            ob.Size = UDim2.new(1, 0, 0, 26)
            ob.Text = opt
            ob.TextColor3 = Color3.fromRGB(200, 200, 200)
            ob.TextSize = 11
            ob.Font = Enum.Font.Gotham
            ob.BackgroundColor3 = Color3.fromRGB(35, 35, 47)
            ob.BorderSizePixel = 0
            ob.ZIndex = 11
            ob.MouseButton1Click:Connect(function()
                sel.Text = opt
                callback(opt)
                dl:Destroy()
            end)
        end
    end)
end

-- ====================== POPULATE TABS ======================
-- PLAYER
Section(Pages["PLAYER"], "AUTO PARRY")
Toggle(Pages["PLAYER"], "Auto Parry", false, function(v) Config.AutoParry = v end)
Slider(Pages["PLAYER"], "FOV", 10, 90, 30, function(v) Config.ParryFOV = v end, " studs")

Section(Pages["PLAYER"], "MOVEMENT")
Toggle(Pages["PLAYER"], "Moonwalk", false, function(v) Config.Moonwalk = v end)
Slider(Pages["PLAYER"], "Speed", 16, 100, 28, function(v) Config.SpeedBoost = v end, "")
Slider(Pages["PLAYER"], "Jump", 50, 200, 75, function(v) Config.JumpPower = v end, "")
Toggle(Pages["PLAYER"], "Infinite Jump", false, function(v) Config.InfiniteJump = v end)

Section(Pages["PLAYER"], "DEFENSE")
Toggle(Pages["PLAYER"], "Anti Stun", false, function(v) Config.AntiStun = v end)
Toggle(Pages["PLAYER"], "No Fall Damage", false, function(v) Config.NoFallDamage = v end)

-- ESP
Section(Pages["ESP"], "SURVIVOR ESP")
Toggle(Pages["ESP"], "Player ESP (Hijau)", false, function(v) Config.PlayerESP = v end)
Toggle(Pages["ESP"], "Killer ESP", false, function(v) Config.KillerESP = v end)
Dropdown(Pages["ESP"], "Warna", {"Merah", "Biru"}, "Merah", function(v) Config.KillerColor = v end)

Section(Pages["ESP"], "WORLD ESP")
Toggle(Pages["ESP"], "Generator", false, function(v) Config.GeneratorESP = v end)
Toggle(Pages["ESP"], "Chest / Item", false, function(v) Config.ChestESP = v end)
Toggle(Pages["ESP"], "Exit Gate", false, function(v) Config.ExitESP = v end)

-- SURVIVAL
Section(Pages["SURVIVAL"], "GENERATOR")
Toggle(Pages["SURVIVAL"], "Auto Generator", false, function(v) Config.AutoGen = v end)
Dropdown(Pages["SURVIVAL"], "Metode", {"Instant", "Perfect", "Normal"}, "Instant", function(v) Config.GenMethod = v end)

Section(Pages["SURVIVAL"], "HEAL & ESCAPE")
Toggle(Pages["SURVIVAL"], "Auto Heal", false, function(v) Config.AutoHeal = v end)
Toggle(Pages["SURVIVAL"], "Auto Exit Gate", false, function(v) Config.AutoExit = v end)

-- KILLER
Section(Pages["KILLER"], "AIMBOT")
Toggle(Pages["KILLER"], "Aimbot", false, function(v) Config.Aimbot = v end)
Slider(Pages["KILLER"], "FOV", 50, 300, 100, function(v) Config.AimbotFOV = v end, " px")
Dropdown(Pages["KILLER"], "Target", {"Head", "UpperTorso", "HumanoidRootPart"}, "Head", function(v) Config.AimbotPart = v end)

Section(Pages["KILLER"], "ESP KILLER")
Toggle(Pages["KILLER"], "Survivor ESP", false, function(v) Config.KillerESP_Survivor = v end)

-- WORLD
Section(Pages["WORLD"], "VISUAL")
Toggle(Pages["WORLD"], "Fullbright", false, function(v) Config.Fullbright = v end)
Toggle(Pages["WORLD"], "Anti Trap", false, function(v) Config.AntiTrap = v end)

-- ====================== TOGGLE MENU ======================
ToggleBtn.MouseButton1Click:Connect(function()
    Menu.Visible = not Menu.Visible
    if Menu.Visible then
        Menu.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(Menu, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 360, 0, 280)
        }):Play()
    end
end)

-- ====================== ESP SYSTEM ======================
local ESPFolder = Instance.new("Folder", Workspace)
ESPFolder.Name = "VD_ESP"

spawn(function()
    while wait(0.3) do
        pcall(function()
            for _, v in ipairs(ESPFolder:GetChildren()) do v:Destroy() end

            -- Player & Killer
            if Config.PlayerESP or Config.KillerESP or Config.KillerESP_Survivor then
                local isKillerRole = LocalPlayer.Team and (LocalPlayer.Team.Name == "Killer" or LocalPlayer.Team.Name == "Hunter")
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl == LocalPlayer then continue end
                    local char = pl.Character
                    if not char then continue end
                    local hum = char:FindFirstChild("Humanoid")
                    if not hum or hum.Health <= 0 then continue end
                    local isKillerTarget = pl.Team and (pl.Team.Name == "Killer" or pl.Team.Name == "Hunter")
                    local show = false
                    local color
                    if isKillerRole then
                        -- Local player is Killer, show Survivors
                        if Config.KillerESP_Survivor and not isKillerTarget then
                            show = true
                            color = Color3.fromRGB(0, 255, 100) -- hijau
                        end
                    else
                        -- Local player is Survivor
                        if isKillerTarget and Config.KillerESP then
                            show = true
                            color = Config.KillerColor == "Merah" and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 100, 255)
                        elseif not isKillerTarget and Config.PlayerESP then
                            show = true
                            color = Color3.fromRGB(0, 255, 100)
                        end
                    end
                    if show then
                        local h = Instance.new("Highlight", ESPFolder)
                        h.FillColor = color
                        h.FillTransparency = 0.75
                        h.OutlineColor = color
                        h.Adornee = char
                    end
                end
            end

            -- Generator, Chest, Exit
            local espMap = {
                Generator = { cfg = Config.GeneratorESP, col = Color3.fromRGB(255, 255, 0) },
                Chest = { cfg = Config.ChestESP, col = Color3.fromRGB(255, 180, 50) },
                Exit = { cfg = Config.ExitESP, col = Color3.fromRGB(0, 150, 255) },
            }
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") then
                    local name = obj.Name:lower()
                    for tag, data in pairs(espMap) do
                        if name:find(tag:lower()) and data.cfg then
                            local h = Instance.new("Highlight", ESPFolder)
                            h.FillColor = data.col
                            h.FillTransparency = 0.7
                            h.OutlineColor = data.col
                            h.Adornee = obj
                            break
                        end
                    end
                end
            end
        end)
    end
end)

-- ====================== FULLBRIGHT ======================
if Config.Fullbright then
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end

-- ====================== AUTO PARRY ======================
spawn(function()
    while wait(0.01) do
        if not Config.AutoParry then continue end
        pcall(function()
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then continue end
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl == LocalPlayer or not pl.Team then continue end
                if pl.Team.Name ~= "Killer" and pl.Team.Name ~= "Hunter" then continue end
                local char = pl.Character
                if not char then continue end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                if (hrp.Position - myRoot.Position).Magnitude > Config.ParryFOV then continue end
                local hum = char:FindFirstChild("Humanoid")
                if not hum then continue end
                local animator = hum:FindFirstChild("Animator")
                if not animator then continue end
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    if track.Animation.AnimationId:lower():find("attack") then
                        VIM:SendKeyEvent(true, "F", false, nil)
                        wait(0.03)
                        VIM:SendKeyEvent(false, "F", false, nil)
                        break
                    end
                end
            end
        end)
    end
end)

-- ====================== MOVEMENT ======================
spawn(function()
    while wait(0.2) do
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if not hum then continue end
            if Config.Moonwalk and hum.MoveDirection.Magnitude > 0 then
                hum.WalkSpeed = -Config.SpeedBoost
            elseif not Config.Moonwalk then
                hum.WalkSpeed = Config.SpeedBoost
            end
            hum.JumpPower = Config.JumpPower
        end)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Anti Stun
RunService.Heartbeat:Connect(function()
    if Config.AntiStun then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and hum:GetState() == Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end)

-- No Fall Damage
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(1)
    local hum = char:FindFirstChild("Humanoid")
    if hum and Config.NoFallDamage then
        hum.FallenDown = false
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end
end)

-- ====================== AUTO GENERATOR ======================
spawn(function()
    while wait(0.5) do
        if not Config.AutoGen then continue end
        pcall(function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            local nearest = nil
            local best = 9999
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:lower():find("generator") or obj.Name:lower():find("gen")) then
                    local base = obj:FindFirstChild("Base") or obj.PrimaryPart
                    if base then
                        local d = (base.Position - root.Position).Magnitude
                        if d < best then best = d; nearest = obj end
                    end
                end
            end
            if nearest then
                local remote = ReplicatedStorage:FindFirstChild("RepairGen") or
                               ReplicatedStorage.Events:FindFirstChild("GeneratorRepair")
                if remote then
                    if Config.GenMethod == "Instant" then
                        remote:FireServer(nearest)
                        remote:FireServer(nearest)
                        remote:FireServer(nearest)
                    elseif Config.GenMethod == "Perfect" then
                        remote:FireServer(nearest, "Perfect")
                    else
                        remote:FireServer(nearest)
                    end
                end
            end
        end)
    end
end)

-- ====================== AUTO HEAL ======================
spawn(function()
    while wait(1) do
        if not Config.AutoHeal then continue end
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if not hum or hum.Health >= hum.MaxHealth then continue end
            local healItem = LocalPlayer.Backpack:FindFirstChild("Medkit") or
                            LocalPlayer.Character:FindFirstChild("Medkit") or
                            LocalPlayer.Backpack:FindFirstChild("Bandage") or
                            LocalPlayer.Character:FindFirstChild("Bandage")
            if healItem then
                healItem.Parent = LocalPlayer.Character
                healItem:Activate()
            end
        end)
    end
end)

-- ====================== AUTO EXIT ======================
spawn(function()
    while wait(0.5) do
        if not Config.AutoExit then continue end
        pcall(function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:lower():find("exit") or obj.Name:lower():find("gate")) then
                    local switch = obj:FindFirstChild("Switch") or obj:FindFirstChild("Lever")
                    if switch then
                        local d = (switch.Position - root.Position).Magnitude
                        if d < 15 then
                            local remote = ReplicatedStorage:FindFirstChild("OpenGate") or
                                           ReplicatedStorage.Events:FindFirstChild("ExitGate")
                            if remote then
                                remote:FireServer(obj)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ====================== KILLER AIMBOT ======================
spawn(function()
    while wait(0.05) do
        if not Config.Aimbot then continue end
        pcall(function()
            local isKiller = LocalPlayer.Team and (LocalPlayer.Team.Name == "Killer" or LocalPlayer.Team.Name == "Hunter")
            if not isKiller then continue end
            local isPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            if not isPressed then continue end
            
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then continue end
            local bestTarget = nil
            local bestDist = Config.AimbotFOV
            
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl == LocalPlayer then continue end
                local char = pl.Character
                if not char then continue end
                local targetPart = char:FindFirstChild(Config.AimbotPart)
                if not targetPart then continue end
                local hum = char:FindFirstChild("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if not onScreen then continue end
                local mousePos = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestTarget = targetPart
                end
            end
            
            if bestTarget then
                -- Move mouse to target (silent aim via virtual input)
                VIM:SendMouseMoveEvent(bestTarget.Position.X, bestTarget.Position.Y)
                -- Auto attack
                VIM:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
                wait(0.05)
                VIM:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
            end
        end)
    end
end)

-- ====================== ANTI TRAP ======================
spawn(function()
    while wait(0.3) do
        if not Config.AntiTrap then continue end
        pcall(function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            for _, trap in ipairs(Workspace:GetDescendants()) do
                if trap:IsA("BasePart") and (trap.Name:lower():find("trap") or trap.Name:lower():find("bear")) then
                    if (trap.Position - root.Position).Magnitude < 5 then
                        trap:Destroy()
                    end
                end
            end
        end)
    end
end)

print("⚡ VD Super Script Loaded - Full Features")
