-- CYBER-AI 2046 VIOLENCE DISTRICT DELTA HP FIX
-- BY YUKI

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- TUNGGU CHARACTER
repeat wait() until LocalPlayer
repeat wait() until LocalPlayer.Character
repeat wait() until LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local Config = {
    AutoParry = false,
    ParryRange = 5,
    Moonwalk = false,
    Optimal = false,
    PlayerESP = false,
    KillerESP = false,
    GeneratorESP = false,
    AutoGen = false,
    GenMethod = "Instant"
}

-- BERSIHKAN
for _, v in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
    if v.Name == "CAI_UI" then v:Destroy() end
end

-- BUAT UI SCREEN
local Screen = Instance.new("ScreenGui")
Screen.Name = "CAI_UI"
Screen.Parent = LocalPlayer.PlayerGui
Screen.ResetOnSpawn = false

-- TOMBOL BUKA MENU
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(1, -70, 1, -70)
OpenBtn.Text = "CAI"
OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
OpenBtn.TextSize = 16
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
OpenBtn.BorderSizePixel = 0
OpenBtn.BackgroundTransparency = 0.3
OpenBtn.ZIndex = 100
OpenBtn.Parent = Screen

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 12)
BtnCorner.Parent = OpenBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(0, 255, 200)
BtnStroke.Thickness = 3
BtnStroke.Parent = OpenBtn

-- MENU UTAMA
local Menu = Instance.new("Frame")
Menu.Name = "Menu"
Menu.Size = UDim2.new(0, 320, 0, 240)
Menu.Position = UDim2.new(0.5, -160, 0.5, -120)
Menu.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.ZIndex = 99
Menu.Active = true
Menu.Draggable = true
Menu.Parent = Screen

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = Menu

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = Color3.fromRGB(0, 255, 200)
MenuStroke.Thickness = 2
MenuStroke.Parent = Menu

-- JUDUL
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
Title.Text = "CYBER-AI 2046"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BorderSizePixel = 0
Title.Parent = Menu
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -32, 0, 3)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.BackgroundTransparency = 1
CloseBtn.Parent = Title
CloseBtn.MouseButton1Click:Connect(function()
    Menu.Visible = false
end)

-- SCROLL CONTENT
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -45)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Menu

local ScrollList = Instance.new("UIListLayout")
ScrollList.Padding = UDim.new(0, 4)
ScrollList.SortOrder = Enum.SortOrder.LayoutOrder
ScrollList.Parent = Scroll

-- FUNGSI BUAT TOGGLE
local function MakeToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 180, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 12
    Label.Font = Enum.Font.SourceSansBold
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(0, 44, 0, 22)
    ToggleBg.Position = UDim2.new(1, -54, 0.5, -11)
    ToggleBg.BackgroundColor3 = default and Color3.fromRGB(0, 220, 150) or Color3.fromRGB(80, 80, 90)
    ToggleBg.BorderSizePixel = 0
    ToggleBg.Parent = Frame
    Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = default and UDim2.new(0, 26, 0, 3) or UDim2.new(0, 2, 0, 3)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.BorderSizePixel = 0
    Dot.Parent = ToggleBg
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    
    local state = default
    local ClickDetector = Instance.new("TextButton")
    ClickDetector.Size = UDim2.new(1, 0, 1, 0)
    ClickDetector.BackgroundTransparency = 1
    ClickDetector.Text = ""
    ClickDetector.Parent = Frame
    
    ClickDetector.MouseButton1Click:Connect(function()
        state = not state
        ToggleBg.BackgroundColor3 = state and Color3.fromRGB(0, 220, 150) or Color3.fromRGB(80, 80, 90)
        Dot.Position = state and UDim2.new(0, 26, 0, 3) or UDim2.new(0, 2, 0, 3)
        callback(state)
    end)
end

-- FUNGSI SLIDER
local function MakeSlider(parent, text, min, max, default, callback, suffix)
    suffix = suffix or ""
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 60)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -16, 0, 18)
    Label.Position = UDim2.new(0, 8, 0, 5)
    Label.Text = text .. ": " .. default .. suffix
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 11
    Label.Font = Enum.Font.SourceSansBold
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(1, -16, 0, 22)
    Track.Position = UDim2.new(0, 8, 0, 30)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Track.BorderSizePixel = 0
    Track.Text = ""
    Track.Parent = Frame
    Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 4)
    
    local percent = (default - min) / (max - min)
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(percent, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 4)
    
    local function update(inputX)
        local trackPos = Track.AbsolutePosition.X
        local trackSize = Track.AbsoluteSize.X
        local pct = math.clamp((inputX - trackPos) / trackSize, 0, 1)
        local val = math.floor((min + (max - min) * pct) * 10) / 10
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        Label.Text = text .. ": " .. val .. suffix
        callback(val)
    end
    
    Track.MouseButton1Down:Connect(function()
        local mouse = game:GetService("UserInputService"):GetMouseLocation()
        update(mouse.X)
        
        local connection
        connection = game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                update(input.Position.X)
            end
        end)
        
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end)
end

-- FUNGSI DROPDOWN
local function MakeDropdown(parent, text, options, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 100, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 12
    Label.Font = Enum.Font.SourceSansBold
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Selected = Instance.new("TextLabel")
    Selected.Size = UDim2.new(0, 120, 1, 0)
    Selected.Position = UDim2.new(1, -130, 0, 0)
    Selected.Text = default
    Selected.TextColor3 = Color3.fromRGB(0, 255, 200)
    Selected.TextSize = 12
    Selected.Font = Enum.Font.SourceSansBold
    Selected.BackgroundTransparency = 1
    Selected.TextXAlignment = Enum.TextXAlignment.Right
    Selected.Parent = Frame
    
    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(1, 0, 1, 0)
    DropBtn.BackgroundTransparency = 1
    DropBtn.Text = ""
    DropBtn.Parent = Frame
    
    local dropdownOpen = false
    local DropList = nil
    
    DropBtn.MouseButton1Click:Connect(function()
        if DropList and DropList.Parent then
            DropList:Destroy()
            return
        end
        
        DropList = Instance.new("Frame")
        DropList.Size = UDim2.new(0, 120, 0, #options * 28)
        DropList.Position = UDim2.new(1, -120, 1, 2)
        DropList.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
        DropList.BorderSizePixel = 0
        DropList.ZIndex = 10
        DropList.Parent = Frame
        
        Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 5)
        Instance.new("UIStroke", DropList).Color = Color3.fromRGB(0, 255, 200)
        
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Parent = DropList
        
        for _, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 28)
            OptBtn.Text = opt
            OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            OptBtn.TextSize = 12
            OptBtn.Font = Enum.Font.SourceSansBold
            OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
            OptBtn.BorderSizePixel = 0
            OptBtn.ZIndex = 11
            OptBtn.Parent = DropList
            
            OptBtn.MouseButton1Click:Connect(function()
                Selected.Text = opt
                callback(opt)
                DropList:Destroy()
            end)
        end
    end)
end

-- FUNGSI LABEL
local function MakeLabel(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.TextSize = 11
    Label.Font = Enum.Font.SourceSansBold
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
end

-- FUNGSI SECTION
local function MakeSection(parent, text)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 22)
    Section.BackgroundTransparency = 1
    Section.Parent = parent
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 3, 1, 0)
    Line.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    Line.BorderSizePixel = 0
    Line.Parent = Section
    Instance.new("UICorner", Line).CornerRadius = UDim.new(1, 0)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -8, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(0, 255, 200)
    Label.TextSize = 12
    Label.Font = Enum.Font.SourceSansBold
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Section
end

-- ISI MENU
MakeSection(Scroll, "AUTO PARRY")
MakeToggle(Scroll, "Auto Parry", false, function(v) Config.AutoParry = v end)
MakeSlider(Scroll, "Range", 1, 30, 5, function(v) Config.ParryRange = v end, " studs")

MakeSection(Scroll, "MOONWALK")
MakeToggle(Scroll, "Moonwalk", false, function(v) Config.Moonwalk = v end)
MakeLabel(Scroll, "Jalan mundur otomatis")

MakeSection(Scroll, "OPTIMAL MODE")
MakeToggle(Scroll, "Optimal Mode", false, function(v) Config.Optimal = v end)
MakeLabel(Scroll, "Semua fitur ON max setting")

MakeSection(Scroll, "ESP PLAYER")
MakeToggle(Scroll, "Player ESP", false, function(v) Config.PlayerESP = v end)

MakeSection(Scroll, "ESP KILLER")
MakeToggle(Scroll, "Killer ESP", false, function(v) Config.KillerESP = v end)

MakeSection(Scroll, "ESP GENERATOR")
MakeToggle(Scroll, "Generator ESP", false, function(v) Config.GeneratorESP = v end)

MakeSection(Scroll, "AUTO GENERATOR")
MakeToggle(Scroll, "Auto Generator", false, function(v) Config.AutoGen = v end)
MakeDropdown(Scroll, "Method", {"Instant", "Normal", "Perfect"}, "Instant", function(v) Config.GenMethod = v end)

-- TOMBOL BUKA MENU
OpenBtn.MouseButton1Click:Connect(function()
    Menu.Visible = not Menu.Visible
end)

-- UPDATE CANVAS
Scroll.CanvasSize = UDim2.new(0, 0, 0, ScrollList.AbsoluteContentSize.Y + 10)

-- ESP SYSTEM
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "CAI_ESP"
ESPFolder.Parent = Workspace

spawn(function()
    while wait(0.3) do
        pcall(function()
            for _, v in ipairs(ESPFolder:GetChildren()) do v:Destroy() end
            
            if Config.PlayerESP or Config.KillerESP then
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl == LocalPlayer then continue end
                    local char = pl.Character
                    if not char then continue end
                    local hum = char:FindFirstChild("Humanoid")
                    if not hum or hum.Health <= 0 then continue end
                    
                    local isKiller = pl.Team and (pl.Team.Name == "Killer" or pl.Team.Name == "Hunter")
                    if isKiller and not Config.KillerESP then continue end
                    if not isKiller and not Config.PlayerESP then continue end
                    
                    local color = isKiller and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 100)
                    local h = Instance.new("Highlight")
                    h.FillColor = color
                    h.FillTransparency = 0.7
                    h.OutlineColor = color
                    h.Adornee = char
                    h.Parent = ESPFolder
                end
            end
            
            if Config.GeneratorESP then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("generator") or obj.Name:lower():find("gen")) then
                        local h = Instance.new("Highlight")
                        h.FillColor = Color3.fromRGB(255, 255, 0)
                        h.FillTransparency = 0.7
                        h.OutlineColor = Color3.fromRGB(255, 255, 0)
                        h.Adornee = obj
                        h.Parent = ESPFolder
                    end
                end
            end
        end)
    end
end)

-- AUTO PARRY
spawn(function()
    while wait(0.05) do
        if not Config.AutoParry then continue end
        pcall(function()
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl == LocalPlayer or not pl.Team then continue end
                if pl.Team.Name ~= "Killer" and pl.Team.Name ~= "Hunter" then continue end
                local char = pl.Character
                if not char then continue end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not hrp or not myHrp then continue end
                if (hrp.Position - myHrp.Position).Magnitude > Config.ParryRange then continue end
                
                local hum = char:FindFirstChild("Humanoid")
                if not hum then continue end
                local animator = hum:FindFirstChild("Animator")
                if not animator then continue end
                
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    if track.Animation.AnimationId:lower():find("attack") then
                        VIM:SendKeyEvent(true, "F", false, nil)
                        wait(0.05)
                        VIM:SendKeyEvent(false, "F", false, nil)
                        break
                    end
                end
            end
        end)
    end
end)

-- MOONWALK
spawn(function()
    while wait(0.05) do
        if not Config.Moonwalk then continue end
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 then
                hum.WalkSpeed = -24
            end
        end)
    end
end)

-- OPTIMAL
spawn(function()
    while wait(1) do
        if Config.Optimal then
            Config.AutoParry = true
            Config.ParryRange = 30
            Config.Moonwalk = false
            Config.PlayerESP = true
            Config.KillerESP = true
            Config.GeneratorESP = true
            Config.AutoGen = true
            Config.GenMethod = "Instant"
        end
    end
end)

-- AUTO GENERATOR
spawn(function()
    while wait(0.5) do
        if not Config.AutoGen then continue end
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

print("CYBER-AI 2046 LOADED - HP VERSION")
print("CLICK TOMBOL CAI POJOK KANAN BAWAH")
