--[[
    VIOLENCE DISTRICT - UI/UX ENHANCED SCRIPT
    Delta Executor | Mobile Friendly
    Menerapkan prinsip: UIListLayout, UICorner, UIStroke, UIPadding,
    konsistensi tema, reusable component, spacing 8px
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ====================== THEME ======================
local Theme = {
    Background = Color3.fromRGB(18, 18, 28),
    Surface = Color3.fromRGB(30, 30, 40),
    Element = Color3.fromRGB(40, 40, 52),
    Accent = Color3.fromRGB(0, 220, 200),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    Danger = Color3.fromRGB(255, 80, 80),
    Success = Color3.fromRGB(0, 200, 140),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    TextSize = 13,
    HeaderSize = 16,
    CornerRadius = UDim.new(0, 8),
    StrokeThickness = 1.5
}

-- ====================== CONFIG ======================
local Config = {
    AutoParry = false,
    ParryRange = 30,
    Speed = 28,
    Jump = 75,
    InfJump = false,
    Moonwalk = false,
    AntiStun = false,
    PlayerESP = false,
    KillerESP = false,
    KillerColor = "Merah",
    GenESP = false,
    ChestESP = false,
    ExitESP = false,
    AutoGen = false,
    GenMode = "Instant",
    AutoHeal = false,
    AutoExit = false,
    Aimbot = false,
    AimbotFOV = 100,
    AimbotPart = "Head"
}

-- ====================== CLEANUP ======================
for _, v in ipairs(PlayerGui:GetChildren()) do
    if v.Name == "VD_Modern" then v:Destroy() end
end

-- ====================== MAIN GUI ======================
local Screen = Instance.new("ScreenGui")
Screen.Name = "VD_Modern"
Screen.Parent = PlayerGui
Screen.ResetOnSpawn = false

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 52, 0, 52)
ToggleBtn.Position = UDim2.new(1, -62, 1, -62)
ToggleBtn.BackgroundColor3 = Theme.Surface
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "VD"
ToggleBtn.TextColor3 = Theme.TextPrimary
ToggleBtn.TextSize = Theme.HeaderSize
ToggleBtn.Font = Theme.FontBold
ToggleBtn.Parent = Screen
local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(0, 14)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Theme.Accent
ToggleStroke.Thickness = Theme.StrokeThickness

-- Menu Container
local Menu = Instance.new("Frame")
Menu.Size = UDim2.new(0, 360, 0, 270)
Menu.Position = UDim2.new(0.5, -180, 0.5, -135)
Menu.BackgroundColor3 = Theme.Background
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.Active = true
Menu.Draggable = true
Menu.Parent = Screen
Instance.new("UICorner", Menu).CornerRadius = Theme.CornerRadius
Instance.new("UIStroke", Menu).Color = Theme.Accent
Instance.new("UIStroke", Menu).Thickness = Theme.StrokeThickness

-- Title Bar
local TitleBar = Instance.new("Frame", Menu)
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = Theme.CornerRadius

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 16, 0, 0)
TitleText.Text = "VD SUPER SCRIPT"
TitleText.TextColor3 = Theme.Accent
TitleText.TextSize = Theme.HeaderSize
TitleText.Font = Theme.FontBold
TitleText.BackgroundTransparency = 1
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -36, 0, 6)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Danger
CloseBtn.TextSize = Theme.HeaderSize
CloseBtn.Font = Theme.FontBold
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() Menu.Visible = false end)

-- Tab System (UIGridLayout untuk tab)
local TabContainer = Instance.new("Frame", Menu)
TabContainer.Size = UDim2.new(0, 90, 1, -44)
TabContainer.Position = UDim2.new(0, 0, 0, 44)
TabContainer.BackgroundColor3 = Theme.Surface
TabContainer.BorderSizePixel = 0
local TabGrid = Instance.new("UIGridLayout", TabContainer)
TabGrid.CellSize = UDim2.new(1, -12, 0, 34)
TabGrid.CellPadding = UDim2.new(0, 4, 0, 4)
TabGrid.StartCorner = Enum.StartCorner.TopLeft
TabGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ContentArea = Instance.new("Frame", Menu)
ContentArea.Size = UDim2.new(1, -96, 1, -52)
ContentArea.Position = UDim2.new(0, 94, 0, 48)
ContentArea.BackgroundColor3 = Color3.fromRGB(24, 24, 35)
ContentArea.BorderSizePixel = 0
ContentArea.ClipsDescendants = true
Instance.new("UICorner", ContentArea).CornerRadius = Theme.CornerRadius

-- Reusable Component Functions
local function createElement(parent, className)
    return Instance.new(className, parent)
end

local function applyCorner(element, radius)
    local corner = Instance.new("UICorner", element)
    corner.CornerRadius = radius or Theme.CornerRadius
    return corner
end

local function applyStroke(element, color, thickness)
    local stroke = Instance.new("UIStroke", element)
    stroke.Color = color or Theme.Accent
    stroke.Thickness = thickness or Theme.StrokeThickness
    return stroke
end

local function createSection(parent, title)
    local frame = createElement(parent, "Frame")
    frame.Size = UDim2.new(1, 0, 0, 26)
    frame.BackgroundTransparency = 1
    
    local dot = createElement(frame, "Frame")
    dot.Size = UDim2.new(0, 5, 0, 5)
    dot.Position = UDim2.new(0, 0, 0.5, -2)
    dot.BackgroundColor3 = Theme.Accent
    applyCorner(dot, UDim.new(1, 0))
    
    local label = createElement(frame, "TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = title
    label.TextColor3 = Theme.Accent
    label.TextSize = Theme.TextSize
    label.Font = Theme.FontBold
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    return frame
end

local function createToggle(parent, text, default, callback)
    local frame = createElement(parent, "Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Theme.Element
    applyCorner(frame)
    
    local label = createElement(frame, "TextLabel")
    label.Size = UDim2.new(0, 160, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = text
    label.TextColor3 = Theme.TextPrimary
    label.TextSize = Theme.TextSize
    label.Font = Theme.Font
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local bg = createElement(frame, "Frame")
    bg.Size = UDim2.new(0, 44, 0, 22)
    bg.Position = UDim2.new(1, -56, 0.5, -11)
    bg.BackgroundColor3 = default and Theme.Success or Color3.fromRGB(80, 80, 90)
    applyCorner(bg, UDim.new(1, 0))
    
    local dot = createElement(bg, "Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = default and UDim2.new(0, 26, 0, 3) or UDim2.new(0, 2, 0, 3)
    dot.BackgroundColor3 = Theme.TextPrimary
    applyCorner(dot, UDim.new(1, 0))
    
    local state = default
    local btn = createElement(frame, "TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.MouseButton1Click:Connect(function()
        state = not state
        bg.BackgroundColor3 = state and Theme.Success or Color3.fromRGB(80, 80, 90)
        TweenService:Create(dot, TweenInfo.new(0.15), {
            Position = state and UDim2.new(0, 26, 0, 3) or UDim2.new(0, 2, 0, 3)
        }):Play()
        callback(state)
    end)
    return frame
end

local function createSlider(parent, text, min, max, step, default, callback)
    local frame = createElement(parent, "Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = Theme.Element
    applyCorner(frame)
    
    local label = createElement(frame, "TextLabel")
    label.Size = UDim2.new(1, -80, 0, 22)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.Text = text .. ": " .. default
    label.TextColor3 = Theme.TextSecondary
    label.TextSize = Theme.TextSize
    label.Font = Theme.Font
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local minus = createElement(frame, "TextButton")
    minus.Size = UDim2.new(0, 32, 0, 28)
    minus.Position = UDim2.new(1, -72, 0, 12)
    minus.Text = "−"
    minus.TextColor3 = Theme.TextPrimary
    minus.TextSize = 20
    minus.Font = Theme.FontBold
    minus.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    applyCorner(minus)
    minus.MouseButton1Click:Connect(function()
        default = math.clamp(default - step, min, max)
        label.Text = text .. ": " .. default
        callback(default)
    end)
    
    local plus = createElement(frame, "TextButton")
    plus.Size = UDim2.new(0, 32, 0, 28)
    plus.Position = UDim2.new(1, -36, 0, 12)
    plus.Text = "+"
    plus.TextColor3 = Theme.TextPrimary
    plus.TextSize = 20
    plus.Font = Theme.FontBold
    plus.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
    applyCorner(plus)
    plus.MouseButton1Click:Connect(function()
        default = math.clamp(default + step, min, max)
        label.Text = text .. ": " .. default
        callback(default)
    end)
    return frame
end

local function createDropdown(parent, text, options, default, callback)
    local frame = createElement(parent, "Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Theme.Element
    applyCorner(frame)
    
    local label = createElement(frame, "TextLabel")
    label.Size = UDim2.new(0, 100, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = text
    label.TextColor3 = Theme.TextPrimary
    label.TextSize = Theme.TextSize
    label.Font = Theme.Font
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local selected = createElement(frame, "TextLabel")
    selected.Size = UDim2.new(0, 120, 1, 0)
    selected.Position = UDim2.new(1, -135, 0, 0)
    selected.Text = default
    selected.TextColor3 = Theme.Accent
    selected.TextSize = Theme.TextSize
    selected.Font = Theme.FontBold
    selected.BackgroundTransparency = 1
    selected.TextXAlignment = Enum.TextXAlignment.Right
    
    local btn = createElement(frame, "TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.MouseButton1Click:Connect(function()
        local old = frame:FindFirstChild("DropList")
        if old then old:Destroy() return end
        local dl = createElement(frame, "Frame")
        dl.Name = "DropList"
        dl.Size = UDim2.new(0, 120, 0, #options * 28)
        dl.Position = UDim2.new(1, -120, 1, 0)
        dl.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        dl.BorderSizePixel = 0
        dl.ZIndex = 10
        applyCorner(dl)
        for _, opt in ipairs(options) do
            local ob = createElement(dl, "TextButton")
            ob.Size = UDim2.new(1, 0, 0, 28)
            ob.Text = opt
            ob.TextColor3 = Theme.TextSecondary
            ob.TextSize = Theme.TextSize
            ob.Font = Theme.Font
            ob.BackgroundColor3 = Theme.Element
            ob.BorderSizePixel = 0
            ob.ZIndex = 11
            ob.MouseButton1Click:Connect(function()
                selected.Text = opt
                callback(opt)
                dl:Destroy()
            end)
        end
    end)
    return frame
end

-- ====================== TAB SETUP ======================
local tabs = {"PLAYER","ESP","SURV","KILLER"}
local TabPages = {}

for i, name in ipairs(tabs) do
    local tabBtn = createElement(TabContainer, "TextButton")
    tabBtn.Size = UDim2.new(1, -12, 0, 32) -- Grid akan atur posisi
    tabBtn.Text = name
    tabBtn.TextColor3 = Theme.TextSecondary
    tabBtn.TextSize = Theme.TextSize
    tabBtn.Font = Theme.FontBold
    tabBtn.BackgroundColor3 = Theme.Element
    tabBtn.BorderSizePixel = 0
    applyCorner(tabBtn)
    
    local page = createElement(ContentArea, "Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundColor3 = Color3.fromRGB(24, 24, 35)
    page.Visible = (i == 1)
    applyCorner(page)
    
    local scroll = createElement(page, "ScrollingFrame")
    scroll.Size = UDim2.new(1, -8, 1, -8)
    scroll.Position = UDim2.new(0, 4, 0, 4)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    local list = createElement(scroll, "UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    
    TabPages[name] = page
    
    tabBtn.MouseButton1Click:Connect(function()
        for n, p in pairs(TabPages) do p.Visible = false end
        page.Visible = true
        for _, btn in ipairs(TabContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Theme.Element
                btn.TextColor3 = Theme.TextSecondary
            end
        end
        tabBtn.BackgroundColor3 = Theme.Accent
        tabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)
end

-- ====================== ISI TAB ======================
-- PLAYER
createSection(TabPages["PLAYER"].ScrollingFrame, "AUTO PARRY")
createToggle(TabPages["PLAYER"].ScrollingFrame, "Auto Parry", false, function(v) Config.AutoParry = v end)
createSlider(TabPages["PLAYER"].ScrollingFrame, "Range", 10, 90, 5, 30, function(v) Config.ParryRange = v end)

createSection(TabPages["PLAYER"].ScrollingFrame, "MOVEMENT")
createSlider(TabPages["PLAYER"].ScrollingFrame, "Speed", 16, 100, 2, 28, function(v) Config.Speed = v end)
createSlider(TabPages["PLAYER"].ScrollingFrame, "Jump", 50, 200, 5, 75, function(v) Config.Jump = v end)
createToggle(TabPages["PLAYER"].ScrollingFrame, "Infinite Jump", false, function(v) Config.InfJump = v end)
createToggle(TabPages["PLAYER"].ScrollingFrame, "Moonwalk", false, function(v) Config.Moonwalk = v end)
createToggle(TabPages["PLAYER"].ScrollingFrame, "Anti Stun", false, function(v) Config.AntiStun = v end)

-- ESP
createSection(TabPages["ESP"].ScrollingFrame, "PLAYER ESP")
createToggle(TabPages["ESP"].ScrollingFrame, "Player ESP", false, function(v) Config.PlayerESP = v end)
createToggle(TabPages["ESP"].ScrollingFrame, "Killer ESP", false, function(v) Config.KillerESP = v end)
createDropdown(TabPages["ESP"].ScrollingFrame, "Warna", {"Merah","Biru"}, "Merah", function(v) Config.KillerColor = v end)

createSection(TabPages["ESP"].ScrollingFrame, "WORLD ESP")
createToggle(TabPages["ESP"].ScrollingFrame, "Generator", false, function(v) Config.GenESP = v end)
createToggle(TabPages["ESP"].ScrollingFrame, "Chest", false, function(v) Config.ChestESP = v end)
createToggle(TabPages["ESP"].ScrollingFrame, "Exit", false, function(v) Config.ExitESP = v end)

-- SURV
createSection(TabPages["SURV"].ScrollingFrame, "GENERATOR")
createToggle(TabPages["SURV"].ScrollingFrame, "Auto Generator", false, function(v) Config.AutoGen = v end)
createDropdown(TabPages["SURV"].ScrollingFrame, "Mode", {"Instant","Perfect","Normal"}, "Instant", function(v) Config.GenMode = v end)
createToggle(TabPages["SURV"].ScrollingFrame, "Auto Heal", false, function(v) Config.AutoHeal = v end)
createToggle(TabPages["SURV"].ScrollingFrame, "Auto Exit", false, function(v) Config.AutoExit = v end)

-- KILLER
createSection(TabPages["KILLER"].ScrollingFrame, "AIMBOT")
createToggle(TabPages["KILLER"].ScrollingFrame, "Aimbot", false, function(v) Config.Aimbot = v end)
createSlider(TabPages["KILLER"].ScrollingFrame, "FOV", 50, 300, 10, 100, function(v) Config.AimbotFOV = v end)
createDropdown(TabPages["KILLER"].ScrollingFrame, "Target", {"Head","UpperTorso","HumanoidRootPart"}, "Head", function(v) Config.AimbotPart = v end)

-- ====================== TOGGLE MENU ======================
ToggleBtn.MouseButton1Click:Connect(function()
    Menu.Visible = not Menu.Visible
end)

-- ====================== SYSTEMS (unchanged, but using Config) ======================
local ESPFolder = Instance.new("Folder", Workspace)
ESPFolder.Name = "VD_ESP"

spawn(function()
    while wait(0.3) do
        pcall(function()
            for _, v in ipairs(ESPFolder:GetChildren()) do v:Destroy() end
            local isKiller = LocalPlayer.Team and (LocalPlayer.Team.Name == "Killer" or LocalPlayer.Team.Name == "Hunter")
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl == LocalPlayer then continue end
                local char = pl.Character
                if not char then continue end
                local hum = char:FindFirstChild("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local isTargetKiller = pl.Team and (pl.Team.Name == "Killer" or pl.Team.Name == "Hunter")
                local show = false
                local col
                if isKiller then
                    if Config.KillerESP then show = true; col = Color3.fromRGB(0,255,100) end
                else
                    if isTargetKiller and Config.KillerESP then
                        show = true
                        col = Config.KillerColor == "Merah" and Color3.fromRGB(255,60,60) or Color3.fromRGB(60,100,255)
                    elseif not isTargetKiller and Config.PlayerESP then
                        show = true; col = Color3.fromRGB(0,255,100)
                    end
                end
                if show then
                    local h = Instance.new("Highlight", ESPFolder)
                    h.FillColor = col
                    h.FillTransparency = 0.75
                    h.OutlineColor = col
                    h.Adornee = char
                end
            end
            if Config.GenESP then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("generator") or obj.Name:lower():find("gen")) then
                        local h = Instance.new("Highlight", ESPFolder)
                        h.FillColor = Color3.fromRGB(255,255,0)
                        h.FillTransparency = 0.7
                        h.OutlineColor = Color3.fromRGB(255,255,0)
                        h.Adornee = obj
                    end
                end
            end
            if Config.ChestESP then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("chest") or obj.Name:lower():find("crate")) then
                        local h = Instance.new("Highlight", ESPFolder)
                        h.FillColor = Color3.fromRGB(255,180,50)
                        h.FillTransparency = 0.7
                        h.OutlineColor = Color3.fromRGB(255,180,50)
                        h.Adornee = obj
                    end
                end
            end
            if Config.ExitESP then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("exit") or obj.Name:lower():find("gate")) then
                        local h = Instance.new("Highlight", ESPFolder)
                        h.FillColor = Color3.fromRGB(0,150,255)
                        h.FillTransparency = 0.7
                        h.OutlineColor = Color3.fromRGB(0,150,255)
                        h.Adornee = obj
                    end
                end
            end
        end)
    end
end)

-- Auto Parry, Movement, Auto Gen, Heal, Exit, Aimbot (same as before, just using Config)
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
                if (hrp.Position - myRoot.Position).Magnitude > Config.ParryRange then continue end
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

spawn(function()
    while wait(0.2) do
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if not hum then continue end
            if Config.Moonwalk and hum.MoveDirection.Magnitude > 0 then
                hum.WalkSpeed = -Config.Speed
            elseif not Config.Moonwalk then
                hum.WalkSpeed = Config.Speed
            end
            hum.JumpPower = Config.Jump
        end)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.AntiStun then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and hum:GetState() == Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end)

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
                local remote = ReplicatedStorage:FindFirstChild("RepairGen") or ReplicatedStorage.Events:FindFirstChild("GeneratorRepair")
                if remote then
                    if Config.GenMode == "Instant" then
                        remote:FireServer(nearest) remote:FireServer(nearest) remote:FireServer(nearest)
                    elseif Config.GenMode == "Perfect" then
                        remote:FireServer(nearest, "Perfect")
                    else
                        remote:FireServer(nearest)
                    end
                end
            end
        end)
    end
end)

spawn(function()
    while wait(1) do
        if not Config.AutoHeal then continue end
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if not hum or hum.Health >= hum.MaxHealth then continue end
            local item = LocalPlayer.Backpack:FindFirstChild("Medkit") or LocalPlayer.Character:FindFirstChild("Medkit")
            if item then
                item.Parent = LocalPlayer.Character
                item:Activate()
            end
        end)
    end
end)

spawn(function()
    while wait(0.5) do
        if not Config.AutoExit then continue end
        pcall(function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:lower():find("exit") or obj.Name:lower():find("gate")) then
                    local switch = obj:FindFirstChild("Switch") or obj:FindFirstChild("Lever")
                    if switch and (switch.Position - root.Position).Magnitude < 15 then
                        local remote = ReplicatedStorage:FindFirstChild("OpenGate") or ReplicatedStorage.Events:FindFirstChild("ExitGate")
                        if remote then remote:FireServer(obj) end
                    end
                end
            end
        end)
    end
end)

spawn(function()
    while wait(0.05) do
        if not Config.Aimbot then continue end
        pcall(function()
            if not (LocalPlayer.Team and (LocalPlayer.Team.Name == "Killer" or LocalPlayer.Team.Name == "Hunter")) then return end
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            local best = nil
            local bestDist = Config.AimbotFOV
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl == LocalPlayer then continue end
                local char = pl.Character
                if not char then continue end
                local part = char:FindFirstChild(Config.AimbotPart)
                if not part then continue end
                local hum = char:FindFirstChild("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if not onScreen then continue end
                local mousePos = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < bestDist then bestDist = dist; best = part end
            end
            if best then
                VIM:SendMouseMoveEvent(best.Position.X, best.Position.Y)
                VIM:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
                wait(0.05)
                VIM:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
            end
        end)
    end
end)

print("VD Script Enhanced UI Loaded")
