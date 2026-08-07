--[[
    CYBER-AI 2046 - VIOLENCE DISTRICT
    NO DRAWING LIBRARY - ALL EXECUTOR COMPATIBLE
    BY YUKI
]]

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

--// WAIT PLAYER
repeat task.wait() until LocalPlayer
repeat task.wait() until LocalPlayer.Character
repeat task.wait() until LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

--// CONFIG
local Config = {
    AutoParry = false,
    ParryRange = 5,
    Moonwalk = false,
    Optimal = false,
    PlayerESP = false,
    PlayerESPColor = Color3.fromRGB(0, 255, 100),
    KillerESP = false,
    GeneratorESP = false,
    GeneratorESPColor = Color3.fromRGB(255, 255, 0),
    AutoGenerator = false,
    GenMethod = "Instant"
}

--// BERSIHKAN OLD UI
for _, v in ipairs(CoreGui:GetChildren()) do
    if v.Name == "CyberAI_Button" or v.Name == "CyberAI_Menu" then
        v:Destroy()
    end
end
for _, v in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
    if v.Name == "CyberAI_Button" or v.Name == "CyberAI_Menu" or v.Name == "ESP_Billboard" then
        v:Destroy()
    end
end

--// ==========================================
--// TOGGLE BUTTON (POJOK KANAN BAWAH)
--// ==========================================
local ToggleButton = Instance.new("ScreenGui")
ToggleButton.Name = "CyberAI_Button"
ToggleButton.Parent = LocalPlayer.PlayerGui
ToggleButton.ResetOnSpawn = false

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0, 50, 0, 50)
Btn.Position = UDim2.new(1, -60, 1, -60)
Btn.Text = "⚡"
Btn.TextColor3 = Color3.fromRGB(0, 255, 200)
Btn.TextSize = 28
Btn.Font = Enum.Font.SourceSansBold
Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Btn.BorderSizePixel = 0
Btn.Active = true
Btn.Draggable = true
Btn.Parent = ToggleButton

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(1, 0)
BtnCorner.Parent = Btn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(0, 255, 200)
BtnStroke.Thickness = 2
BtnStroke.Parent = Btn

--// ==========================================
--// MAIN MENU
--// ==========================================
local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = "CyberAI_Menu"
MenuGui.Parent = LocalPlayer.PlayerGui
MenuGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 380, 0, 280)
Main.Position = UDim2.new(0.5, -190, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = MenuGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(50, 50, 70)
MainStroke.Thickness = 1
MainStroke.Parent = Main

--// TITLE
local Title = Instance.new("Frame")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
Title.BorderSizePixel = 0
Title.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.Text = "CYBER-AI 2046"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Title

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 4)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.BackgroundTransparency = 1
CloseBtn.Parent = Title

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

--// TAB BUTTONS
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0, 75, 1, -35)
TabFrame.Position = UDim2.new(0, 0, 0, 35)
TabFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = Main

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 2)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabFrame

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingLeft = UDim.new(0, 4)
TabPadding.PaddingRight = UDim.new(0, 4)
TabPadding.PaddingTop = UDim.new(0, 4)
TabPadding.Parent = TabFrame

--// CONTENT
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -79, 1, -39)
ContentFrame.Position = UDim2.new(0, 77, 0, 37)
ContentFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = Main

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 6)
ContentCorner.Parent = ContentFrame

--// SCROLL
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -8, 1, -8)
Scroll.Position = UDim2.new(0, 4, 0, 4)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = ContentFrame

local ScrollList = Instance.new("UIListLayout")
ScrollList.Padding = UDim.new(0, 4)
ScrollList.SortOrder = Enum.SortOrder.LayoutOrder
ScrollList.Parent = Scroll

local ScrollPad = Instance.new("UIPadding")
ScrollPad.PaddingLeft = UDim.new(0, 2)
ScrollPad.PaddingRight = UDim.new(0, 2)
ScrollPad.PaddingTop = UDim.new(0, 2)
ScrollPad.Parent = Scroll

--// TABS
local Tabs = {"INFO", "MAIN", "ESP", "SURVI", "DEV"}
local Pages = {}
local CurrentPage = nil

for i, tabName in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.TextSize = 11
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = TabFrame
    
    local BtnCorner2 = Instance.new("UICorner")
    BtnCorner2.CornerRadius = UDim.new(0, 4)
    BtnCorner2.Parent = TabBtn
    
    -- Page
    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1, 0, 0, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = Scroll
    
    local PageList = Instance.new("UIListLayout")
    PageList.Padding = UDim.new(0, 3)
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Parent = Page
    
    Pages[tabName] = Page
    
    if i == 1 then
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Page.Visible = true
        CurrentPage = tabName
    end
    
    TabBtn.MouseButton1Click:Connect(function()
        for n, p in pairs(Pages) do p.Visible = false end
        Page.Visible = true
        CurrentPage = tabName
        for _, btn in ipairs(TabFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
                btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end

--// HELPER FUNCTIONS
local function AddLabel(page, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.SourceSans
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = page
    return lbl
end

local function AddSection(page, text)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(1, 0, 0, 22)
    sec.BackgroundTransparency = 1
    sec.Parent = page
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 3, 1, 0)
    line.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    line.BorderSizePixel = 0
    line.Parent = sec
    
    local lineCorner = Instance.new("UICorner")
    lineCorner.CornerRadius = UDim.new(1, 0)
    lineCorner.Parent = line
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(0, 200, 255)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.SourceSansBold
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sec
end

local function AddToggle(page, text, default, callback)
    local tf = Instance.new("Frame")
    tf.Size = UDim2.new(1, 0, 0, 34)
    tf.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
    tf.BorderSizePixel = 0
    tf.Parent = page
    
    local tfc = Instance.new("UICorner")
    tfc.CornerRadius = UDim.new(0, 4)
    tfc.Parent = tf
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 180, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.SourceSans
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = tf
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 40, 0, 20)
    bg.Position = UDim2.new(1, -52, 0.5, -10)
    bg.BackgroundColor3 = default and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(70, 70, 80)
    bg.BorderSizePixel = 0
    bg.Parent = tf
    
    local bgc = Instance.new("UICorner")
    bgc.CornerRadius = UDim.new(1, 0)
    bgc.Parent = bg
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = default and UDim2.new(0, 24, 0, 3) or UDim2.new(0, 2, 0, 3)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = bg
    
    local dotc = Instance.new("UICorner")
    dotc.CornerRadius = UDim.new(1, 0)
    dotc.Parent = dot
    
    local toggled = default
    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = tf
    
    click.MouseButton1Click:Connect(function()
        toggled = not toggled
        bg.BackgroundColor3 = toggled and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(70, 70, 80)
        dot.Position = toggled and UDim2.new(0, 24, 0, 3) or UDim2.new(0, 2, 0, 3)
        callback(toggled)
    end)
end

local function AddSlider(page, text, min, max, default, callback, suffix)
    suffix = suffix or ""
    local sf = Instance.new("Frame")
    sf.Size = UDim2.new(1, 0, 0, 60)
    sf.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
    sf.BorderSizePixel = 0
    sf.Parent = page
    
    local sfc = Instance.new("UICorner")
    sfc.CornerRadius = UDim.new(0, 4)
    sfc.Parent = sf
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 18)
    lbl.Position = UDim2.new(0, 8, 0, 5)
    lbl.Text = text .. ": " .. default .. suffix
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 10
    lbl.Font = Enum.Font.SourceSans
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sf
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -16, 0, 5)
    track.Position = UDim2.new(0, 8, 0, 33)
    track.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    track.BorderSizePixel = 0
    track.Parent = sf
    
    local trackc = Instance.new("UICorner")
    trackc.CornerRadius = UDim.new(1, 0)
    trackc.Parent = track
    
    local percent = (default - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillc = Instance.new("UICorner")
    fillc.CornerRadius = UDim.new(1, 0)
    fillc.Parent = fill
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(percent, -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    
    local knobc = Instance.new("UICorner")
    knobc.CornerRadius = UDim.new(1, 0)
    knobc.Parent = knob
    
    local dragging = false
    
    local function update(input)
        local pos = track.AbsolutePosition
        local size = track.AbsoluteSize
        local pct = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
        local val = math.floor((min + (max - min) * pct) * 10) / 10
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -6, 0.5, -6)
        lbl.Text = text .. ": " .. val .. suffix
        callback(val)
    end
    
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(i)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            update(i)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function AddDropdown(page, text, options, default, callback)
    local df = Instance.new("Frame")
    df.Size = UDim2.new(1, 0, 0, 34)
    df.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
    df.BorderSizePixel = 0
    df.Parent = page
    
    local dfc = Instance.new("UICorner")
    dfc.CornerRadius = UDim.new(0, 4)
    dfc.Parent = df
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 100, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.SourceSans
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = df
    
    local selected = Instance.new("TextLabel")
    selected.Size = UDim2.new(0, 130, 1, 0)
    selected.Position = UDim2.new(1, -142, 0, 0)
    selected.Text = default
    selected.TextColor3 = Color3.fromRGB(0, 200, 255)
    selected.TextSize = 11
    selected.Font = Enum.Font.SourceSansBold
    selected.BackgroundTransparency = 1
    selected.TextXAlignment = Enum.TextXAlignment.Right
    selected.Parent = df
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 18, 1, 0)
    arrow.Position = UDim2.new(1, -18, 0, 0)
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    arrow.TextSize = 9
    arrow.Font = Enum.Font.SourceSans
    arrow.BackgroundTransparency = 1
    arrow.Parent = df
    
    local dropList = nil
    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = df
    
    click.MouseButton1Click:Connect(function()
        if dropList and dropList.Parent then
            dropList:Destroy()
            return
        end
        
        dropList = Instance.new("Frame")
        dropList.Size = UDim2.new(0, 130, 0, #options * 26)
        dropList.Position = UDim2.new(1, -130, 1, 0)
        dropList.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
        dropList.BorderSizePixel = 0
        dropList.ZIndex = 10
        dropList.Parent = df
        
        local dlc = Instance.new("UICorner")
        dlc.CornerRadius = UDim.new(0, 4)
        dlc.Parent = dropList
        
        local dls = Instance.new("UIStroke")
        dls.Color = Color3.fromRGB(50, 50, 65)
        dls.Thickness = 1
        dls.Parent = dropList
        
        local dll = Instance.new("UIListLayout")
        dll.Parent = dropList
        
        for _, opt in ipairs(options) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1, 0, 0, 26)
            ob.Text = opt
            ob.TextColor3 = Color3.fromRGB(200, 200, 200)
            ob.TextSize = 11
            ob.Font = Enum.Font.SourceSans
            ob.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
            ob.BorderSizePixel = 0
            ob.ZIndex = 11
            ob.Parent = dropList
            
            ob.MouseButton1Click:Connect(function()
                selected.Text = opt
                callback(opt)
                dropList:Destroy()
            end)
            
            ob.MouseEnter:Connect(function()
                ob.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
                ob.TextColor3 = Color3.fromRGB(0, 0, 0)
            end)
            ob.MouseLeave:Connect(function()
                ob.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
                ob.TextColor3 = Color3.fromRGB(200, 200, 200)
            end)
        end
    end)
end

--// ==========================================
--// POPULATE TABS
--// ==========================================

-- INFO TAB
AddSection(Pages["INFO"], "SCRIPT INFO")
AddLabel(Pages["INFO"], "CYBER-AI 2046 v3.0")
AddLabel(Pages["INFO"], "Map: Violence District")
AddLabel(Pages["INFO"], "Creator: YUKI")
AddSection(Pages["INFO"], "CONTROLS")
AddLabel(Pages["INFO"], "Click ⚡ = Open Menu")
AddLabel(Pages["INFO"], "Drag ⚡ = Move Button")
AddLabel(Pages["INFO"], "Drag Title Bar = Move Menu")

-- MAIN TAB
AddSection(Pages["MAIN"], "AUTO PARRY")
AddToggle(Pages["MAIN"], "Auto Parry", false, function(v) Config.AutoParry = v end)
AddSlider(Pages["MAIN"], "Parry Range", 1, 30, 5, function(v) Config.ParryRange = v end, " studs")

AddSection(Pages["MAIN"], "MOONWALK")
AddToggle(Pages["MAIN"], "Moonwalk", false, function(v) Config.Moonwalk = v end)
AddLabel(Pages["MAIN"], "Jalan mundur otomatis")

AddSection(Pages["MAIN"], "OPTIMAL MODE")
AddToggle(Pages["MAIN"], "Optimal Mode", false, function(v) Config.Optimal = v end)
AddLabel(Pages["MAIN"], "Aktifkan semua fitur 100%")

-- ESP TAB
AddSection(Pages["ESP"], "ESP PLAYER")
AddToggle(Pages["ESP"], "ESP Player", false, function(v) Config.PlayerESP = v end)
AddLabel(Pages["ESP"], "Warna: Hijau (Custom)")

AddSection(Pages["ESP"], "ESP KILLER")
AddToggle(Pages["ESP"], "ESP Killer (Merah)", false, function(v) Config.KillerESP = v end)
AddLabel(Pages["ESP"], "Killer terdeteksi warna merah")

AddSection(Pages["ESP"], "ESP GENERATOR")
AddToggle(Pages["ESP"], "ESP Generator", false, function(v) Config.GeneratorESP = v end)
AddLabel(Pages["ESP"], "Warna: Kuning (Custom)")

-- SURVI TAB
AddSection(Pages["SURVI"], "AUTO GENERATOR")
AddToggle(Pages["SURVI"], "Auto Generator", false, function(v) Config.AutoGenerator = v end)
AddDropdown(Pages["SURVI"], "Method", {"Instant", "Normal", "Perfect"}, "Instant", function(v) Config.GenMethod = v end)

-- DEV TAB
AddSection(Pages["DEV"], "DEVELOPER")
AddLabel(Pages["DEV"], "YUKI - Cyber AI Developer")
AddLabel(Pages["DEV"], "Special Thanks to You")

AddSection(Pages["DEV"], "VERSION")
AddLabel(Pages["DEV"], "v3.0 - Stable Release")
AddLabel(Pages["DEV"], "No Drawing Library")

--// ==========================================
--// TOGGLE BUTTON CLICK
--// ==========================================
Btn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

--// ==========================================
--// ESP SYSTEM (HIGHLIGHT + BILLBOARD)
--// ==========================================
local ESPContainer = Instance.new("Folder")
ESPContainer.Name = "ESP_Billboard"
ESPContainer.Parent = Workspace

spawn(function()
    while task.wait(0.1) do
        pcall(function()
            -- Clear old ESP
            for _, v in ipairs(ESPContainer:GetChildren()) do
                v:Destroy()
            end
            
            if not Config.PlayerESP and not Config.KillerESP and not Config.GeneratorESP then
                continue
            end
            
            -- Player & Killer ESP
            if Config.PlayerESP or Config.KillerESP then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player == LocalPlayer then continue end
                    local char = player.Character
                    if not char then continue end
                    local head = char:FindFirstChild("Head")
                    local hum = char:FindFirstChild("Humanoid")
                    if not head or not hum or hum.Health <= 0 then continue end
                    
                    local isKiller = player.Team and (player.Team.Name == "Killer" or player.Team.Name == "Hunter")
                    
                    if isKiller and not Config.KillerESP then continue end
                    if not isKiller and not Config.PlayerESP then continue end
                    
                    local color = isKiller and Color3.fromRGB(255, 50, 50) or Config.PlayerESPColor
                    
                    -- Billboard
                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0, 100, 0, 30)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = 500
                    bb.Parent = ESPContainer
                    bb.Adornee = head
                    
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundColor3 = color
                    frame.BackgroundTransparency = 0.6
                    frame.BorderSizePixel = 0
                    frame.Parent = bb
                    
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 3)
                    corner.Parent = frame
                    
                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.Text = player.Name .. (isKiller and " [KILLER]" or "")
                    text.TextColor3 = Color3.fromRGB(255, 255, 255)
                    text.TextSize = 10
                    text.Font = Enum.Font.SourceSansBold
                    text.BackgroundTransparency = 1
                    text.Parent = frame
                    
                    -- Highlight
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = color
                    highlight.FillTransparency = 0.7
                    highlight.OutlineColor = color
                    highlight.OutlineTransparency = 0.3
                    highlight.Adornee = char
                    highlight.Parent = ESPContainer
                end
            end
            
            -- Generator ESP
            if Config.GeneratorESP then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("generator") or obj.Name:lower():find("gen")) then
                        local mainPart = obj.PrimaryPart or obj:FindFirstChild("Base")
                        if mainPart then
                            local highlight = Instance.new("Highlight")
                            highlight.FillColor = Config.GeneratorESPColor
                            highlight.FillTransparency = 0.7
                            highlight.OutlineColor = Config.GeneratorESPColor
                            highlight.OutlineTransparency = 0.3
                            highlight.Adornee = obj
                            highlight.Parent = ESPContainer
                            
                            local bb = Instance.new("BillboardGui")
                            bb.Size = UDim2.new(0, 150, 0, 25)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.AlwaysOnTop = true
                            bb.MaxDistance = 500
                            bb.Parent = ESPContainer
                            bb.Adornee = mainPart
                            
                            local frame = Instance.new("Frame")
                            frame.Size = UDim2.new(1, 0, 1, 0)
                            frame.BackgroundColor3 = Config.GeneratorESPColor
                            frame.BackgroundTransparency = 0.5
                            frame.BorderSizePixel = 0
                            frame.Parent = bb
                            
                            local corner = Instance.new("UICorner")
                            corner.CornerRadius = UDim.new(0, 3)
                            corner.Parent = frame
                            
                            local text = Instance.new("TextLabel")
                            text.Size = UDim2.new(1, 0, 1, 0)
                            text.Text = obj.Name
                            text.TextColor3 = Color3.fromRGB(255, 255, 255)
                            text.TextSize = 11
                            text.Font = Enum.Font.SourceSansBold
                            text.BackgroundTransparency = 1
                            text.Parent = frame
                        end
                    end
                end
            end
        end)
    end
end)

--// ==========================================
--// AUTO PARRY SYSTEM
--// ==========================================
spawn(function()
    while task.wait(0.001) do
        if not Config.AutoParry then continue end
        pcall(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                if not player.Team then continue end
                if player.Team.Name ~= "Killer" and player.Team.Name ~= "Hunter" then continue end
                
                local char = player.Character
                if not char then continue end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                
                local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not myHrp then continue end
                
                local dist = (hrp.Position - myHrp.Position).Magnitude
                if dist > Config.ParryRange then continue end
                
                local hum = char:FindFirstChild("Humanoid")
                if not hum then continue end
                
                local animator = hum:FindFirstChild("Animator")
                if not animator then continue end
                
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    if track.Animation.AnimationId:lower():find("attack") then
                        keypress(0x46) -- F key
                        task.wait(0.05)
                        keyrelease(0x46)
                        break
                    end
                end
            end
        end)
    end
end)

--// ==========================================
--// MOONWALK
--// ==========================================
spawn(function()
    while task.wait(0.01) do
        if not Config.Moonwalk then continue end
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 then
                hum.WalkSpeed = -24
            end
        end)
    end
end)

--// ==========================================
--// OPTIMAL MODE
--// ==========================================
spawn(function()
    while task.wait(1) do
        if Config.Optimal then
            Config.AutoParry = true
            Config.ParryRange = 30
            Config.Moonwalk = false
            Config.PlayerESP = true
            Config.KillerESP = true
            Config.GeneratorESP = true
            Config.AutoGenerator = true
            Config.GenMethod = "Instant"
        end
    end
end)

--// ==========================================
--// AUTO GENERATOR
--// ==========================================
spawn(function()
    while task.wait(0.2) do
        if not Config.AutoGenerator then continue end
        pcall(function()
            local nearestGen = nil
            local nearestDist = math.huge
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:lower():find("generator") or obj.Name:lower():find("gen")) then
                    local genRoot = obj:FindFirstChild("Base") or obj.PrimaryPart
                    if genRoot then
                        local dist = (genRoot.Position - root.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestGen = obj
                        end
                    end
                end
            end
            
            if nearestGen then
                local remote = ReplicatedStorage:FindFirstChild("RepairGen") or
                              ReplicatedStorage.Events:FindFirstChild("GeneratorRepair")
                if remote then
                    if Config.GenMethod == "Instant" then
                        remote:FireServer(nearestGen)
                        remote:FireServer(nearestGen)
                        remote:FireServer(nearestGen)
                        remote:FireServer(nearestGen)
                        remote:FireServer(nearestGen)
                    elseif Config.GenMethod == "Perfect" then
                        remote:FireServer(nearestGen, "Perfect")
                    else
                        remote:FireServer(nearestGen)
                    end
                end
            end
        end)
    end
end)

print("⚡ CYBER-AI 2046 v3.0 LOADED!")
print("👨🏼‍💻 BY YUKI")
print("📌 CLICK ⚡ BUTTON POJOK KANAN BAWAH")
print("✅ COMPATIBLE ALL EXECUTOR")
