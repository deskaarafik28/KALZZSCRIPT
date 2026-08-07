--[[
    CYBER-AI 2046 - VIOLENCE DISTRICT
    UI SIMPLE MODERN BY YUKI
--]]

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- // CONFIG
local Config = {
    Main = {
        AutoParry = false,
        ParryRange = 5.0,
        Moonwalk = false,
        Optimal = false
    },
    ESP = {
        PlayerESP = false,
        PlayerColor = Color3.fromRGB(0, 255, 100),
        KillerESP = false,
        KillerColor = Color3.fromRGB(255, 50, 50),
        GeneratorESP = false,
        GeneratorColor = Color3.fromRGB(255, 255, 0)
    },
    Survival = {
        AutoGenerator = false,
        GenMethod = "Instant"
    }
}

-- // UI CREATE
local function CreateUI()
    -- Main ScreenGui
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "CyberAI"
    Gui.Parent = (CoreGui:FindFirstChild("RobloxGui") or LocalPlayer.PlayerGui)
    Gui.ResetOnSpawn = false
    
    -- MAIN CONTAINER
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 400, 0, 300)
    Main.Position = UDim2.new(0.5, -200, 0.5, -150)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Visible = true
    Main.Parent = Gui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = Main
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(60, 60, 80)
    MainStroke.Thickness = 1
    MainStroke.Parent = Main
    
    -- TITLE BAR
    local Title = Instance.new("Frame")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    Title.BorderSizePixel = 0
    Title.Parent = Main
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -50, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.Text = "CYBER-AI"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 16
    TitleText.Font = Enum.Font.GothamBold
    TitleText.BackgroundTransparency = 1
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = Title
    
    local TitleLine = Instance.new("Frame")
    TitleLine.Size = UDim2.new(1, 0, 0, 1)
    TitleLine.Position = UDim2.new(0, 0, 1, 0)
    TitleLine.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    TitleLine.BorderSizePixel = 0
    TitleLine.Parent = Title
    
    -- CLOSE BUTTON
    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 30, 0, 30)
    Close.Position = UDim2.new(1, -40, 0, 5)
    Close.Text = "✕"
    Close.TextColor3 = Color3.fromRGB(180, 180, 180)
    Close.TextSize = 16
    Close.Font = Enum.Font.GothamBold
    Close.BackgroundTransparency = 1
    Close.Parent = Title
    
    Close.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)
    
    Close.MouseEnter:Connect(function()
        Close.TextColor3 = Color3.fromRGB(255, 80, 80)
    end)
    Close.MouseLeave:Connect(function()
        Close.TextColor3 = Color3.fromRGB(180, 180, 180)
    end)
    
    -- TAB BUTTONS
    local TabHolder = Instance.new("Frame")
    TabHolder.Size = UDim2.new(0, 80, 1, -40)
    TabHolder.Position = UDim2.new(0, 0, 0, 40)
    TabHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabHolder.BorderSizePixel = 0
    TabHolder.Parent = Main
    
    -- CONTENT
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -85, 1, -45)
    Content.Position = UDim2.new(0, 82, 0, 42)
    Content.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Content.BorderSizePixel = 0
    Content.ClipsDescendants = true
    Content.Parent = Main
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = Content
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -10, 1, -10)
    Scroll.Position = UDim2.new(0, 5, 0, 5)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.Parent = Content
    
    local ScrollList = Instance.new("UIListLayout")
    ScrollList.Padding = UDim.new(0, 4)
    ScrollList.SortOrder = Enum.SortOrder.LayoutOrder
    ScrollList.Parent = Scroll
    
    local ScrollPad = Instance.new("UIPadding")
    ScrollPad.PaddingLeft = UDim.new(0, 4)
    ScrollPad.PaddingRight = UDim.new(0, 4)
    ScrollPad.PaddingTop = UDim.new(0, 4)
    ScrollPad.Parent = Scroll
    
    -- TAB SYSTEM
    local Tabs = {
        {Name = "INFO", Icon = "ℹ️"},
        {Name = "MAIN", Icon = "⚡"},
        {Name = "ESP", Icon = "👁️"},
        {Name = "SURVI", Icon = "🔧"},
        {Name = "DEV", Icon = "💻"}
    }
    
    local CurrentTab = nil
    local TabContent = {}
    
    for i, tab in ipairs(Tabs) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -10, 0, 36)
        TabBtn.Position = UDim2.new(0, 5, 0, (i-1) * 40 + 8)
        TabBtn.Text = tab.Icon .. " " .. tab.Name
        TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabBtn.TextSize = 11
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        TabBtn.BorderSizePixel = 0
        TabBtn.Parent = TabHolder
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabBtn
        
        -- Content page
        local Page = Instance.new("Frame")
        Page.Size = UDim2.new(1, 0, 0, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.Parent = Scroll
        
        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 5)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Parent = Page
        
        TabContent[tab.Name] = Page
        
        if not CurrentTab then
            CurrentTab = tab.Name
            TabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Page.Visible = true
        end
        
        TabBtn.MouseButton1Click:Connect(function()
            for n, p in pairs(TabContent) do p.Visible = false end
            Page.Visible = true
            CurrentTab = tab.Name
            
            for _, btn in ipairs(TabHolder:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                end
            end
            TabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
    end
    
    -- // HELPER FUNCTIONS
    local function CreateLabel(page, text)
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 22)
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = page
        return Label
    end
    
    local function CreateTitle(page, text)
        local TitleFrame = Instance.new("Frame")
        TitleFrame.Size = UDim2.new(1, 0, 0, 26)
        TitleFrame.BackgroundTransparency = 1
        TitleFrame.Parent = page
        
        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(0, 3, 1, 0)
        Line.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        Line.BorderSizePixel = 0
        Line.Parent = TitleFrame
        
        local LineCorner = Instance.new("UICorner")
        LineCorner.CornerRadius = UDim.new(1, 0)
        LineCorner.Parent = Line
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -10, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(0, 200, 255)
        Label.TextSize = 13
        Label.Font = Enum.Font.GothamBold
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = TitleFrame
    end
    
    local function CreateToggle(page, text, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = page
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 5)
        ToggleCorner.Parent = ToggleFrame
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0, 200, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(230, 230, 230)
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        -- Toggle button di kanan
        local Btn = Instance.new("Frame")
        Btn.Size = UDim2.new(0, 42, 0, 22)
        Btn.Position = UDim2.new(1, -55, 0.5, -11)
        Btn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(80, 80, 90)
        Btn.BorderSizePixel = 0
        Btn.Parent = ToggleFrame
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(1, 0)
        BtnCorner.Parent = Btn
        
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 16, 0, 16)
        Dot.Position = default and UDim2.new(0, 24, 0, 3) or UDim2.new(0, 2, 0, 3)
        Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Dot.BorderSizePixel = 0
        Dot.Parent = Btn
        
        local DotCorner = Instance.new("UICorner")
        DotCorner.CornerRadius = UDim.new(1, 0)
        DotCorner.Parent = Dot
        
        local toggled = default
        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.Parent = ToggleFrame
        
        ClickBtn.MouseButton1Click:Connect(function()
            toggled = not toggled
            Btn.BackgroundColor3 = toggled and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(80, 80, 90)
            local tween = TweenService:Create(Dot, TweenInfo.new(0.15), {
                Position = toggled and UDim2.new(0, 24, 0, 3) or UDim2.new(0, 2, 0, 3)
            })
            tween:Play()
            callback(toggled)
        end)
        
        return ToggleFrame
    end
    
    local function CreateSlider(page, text, min, max, default, callback, suffix)
        suffix = suffix or ""
        
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 68)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = page
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 5)
        SliderCorner.Parent = SliderFrame
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 0, 20)
        Label.Position = UDim2.new(0, 10, 0, 6)
        Label.Text = text .. ": " .. default .. suffix
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.TextSize = 11
        Label.Font = Enum.Font.Gotham
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderFrame
        
        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, -20, 0, 6)
        Track.Position = UDim2.new(0, 10, 0, 38)
        Track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        Track.BorderSizePixel = 0
        Track.Parent = SliderFrame
        
        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track
        
        local percent = (default - min) / (max - min)
        
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        Fill.BorderSizePixel = 0
        Fill.Parent = Track
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill
        
        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 14, 0, 14)
        Knob.Position = UDim2.new(percent, -7, 0.5, -7)
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.BorderSizePixel = 0
        Knob.Parent = Track
        
        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = Knob
        
        local dragging = false
        
        local function update(input)
            local pos = Track.AbsolutePosition
            local size = Track.AbsoluteSize
            local pct = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
            local val = math.floor((min + (max - min) * pct) * 10) / 10
            
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            Knob.Position = UDim2.new(pct, -7, 0.5, -7)
            Label.Text = text .. ": " .. val .. suffix
            callback(val)
        end
        
        Track.InputBegan:Connect(function(i)
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
        
        return SliderFrame
    end
    
    local function CreateDropdown(page, text, options, default, callback)
        local DropFrame = Instance.new("Frame")
        DropFrame.Size = UDim2.new(1, 0, 0, 36)
        DropFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
        DropFrame.BorderSizePixel = 0
        DropFrame.Parent = page
        
        local DropCorner = Instance.new("UICorner")
        DropCorner.CornerRadius = UDim.new(0, 5)
        DropCorner.Parent = DropFrame
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0, 120, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(230, 230, 230)
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = DropFrame
        
        local Selected = Instance.new("TextLabel")
        Selected.Size = UDim2.new(0, 140, 1, 0)
        Selected.Position = UDim2.new(1, -155, 0, 0)
        Selected.Text = default
        Selected.TextColor3 = Color3.fromRGB(0, 200, 255)
        Selected.TextSize = 11
        Selected.Font = Enum.Font.GothamBold
        Selected.BackgroundTransparency = 1
        Selected.TextXAlignment = Enum.TextXAlignment.Right
        Selected.Parent = DropFrame
        
        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 20, 1, 0)
        Arrow.Position = UDim2.new(1, -20, 0, 0)
        Arrow.Text = "▼"
        Arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
        Arrow.TextSize = 10
        Arrow.Font = Enum.Font.Gotham
        Arrow.BackgroundTransparency = 1
        Arrow.Parent = DropFrame
        
        local DropList = nil
        
        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.Parent = DropFrame
        
        ClickBtn.MouseButton1Click:Connect(function()
            if DropList and DropList.Parent then
                DropList:Destroy()
                return
            end
            
            DropList = Instance.new("Frame")
            DropList.Size = UDim2.new(0, 140, 0, #options * 28)
            DropList.Position = UDim2.new(1, -140, 1, 0)
            DropList.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            DropList.BorderSizePixel = 0
            DropList.ZIndex = 10
            DropList.Parent = DropFrame
            
            local ListCorner = Instance.new("UICorner")
            ListCorner.CornerRadius = UDim.new(0, 5)
            ListCorner.Parent = DropList
            
            local ListStroke = Instance.new("UIStroke")
            ListStroke.Color = Color3.fromRGB(60, 60, 80)
            ListStroke.Thickness = 1
            ListStroke.Parent = DropList
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = DropList
            
            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 28)
                OptBtn.Text = opt
                OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                OptBtn.TextSize = 11
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                OptBtn.BorderSizePixel = 0
                OptBtn.ZIndex = 11
                OptBtn.Parent = DropList
                
                OptBtn.MouseButton1Click:Connect(function()
                    Selected.Text = opt
                    callback(opt)
                    DropList:Destroy()
                end)
                
                OptBtn.MouseEnter:Connect(function()
                    OptBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
                    OptBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
                end)
                OptBtn.MouseLeave:Connect(function()
                    OptBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                    OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                end)
            end
        end)
        
        return DropFrame
    end
    
    local function CreateColorPicker(page, text, default, callback)
        local ColorFrame = Instance.new("Frame")
        ColorFrame.Size = UDim2.new(1, 0, 0, 36)
        ColorFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
        ColorFrame.BorderSizePixel = 0
        ColorFrame.Parent = page
        
        local ColorCorner = Instance.new("UICorner")
        ColorCorner.CornerRadius = UDim.new(0, 5)
        ColorCorner.Parent = ColorFrame
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0, 200, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(230, 230, 230)
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ColorFrame
        
        local ColorPreview = Instance.new("Frame")
        ColorPreview.Size = UDim2.new(0, 24, 0, 24)
        ColorPreview.Position = UDim2.new(1, -38, 0.5, -12)
        ColorPreview.BackgroundColor3 = default
        ColorPreview.BorderSizePixel = 0
        ColorPreview.Parent = ColorFrame
        
        local PreviewCorner = Instance.new("UICorner")
        PreviewCorner.CornerRadius = UDim.new(0, 4)
        PreviewCorner.Parent = ColorPreview
        
        local PreviewStroke = Instance.new("UIStroke")
        PreviewStroke.Color = Color3.fromRGB(255, 255, 255)
        PreviewStroke.Thickness = 1
        PreviewStroke.Parent = ColorPreview
        
        local currentColor = default
        
        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.Parent = ColorFrame
        
        ClickBtn.MouseButton1Click:Connect(function()
            local colors = {
                {name = "Red", color = Color3.fromRGB(255, 50, 50)},
                {name = "Green", color = Color3.fromRGB(0, 255, 100)},
                {name = "Blue", color = Color3.fromRGB(50, 100, 255)},
                {name = "Yellow", color = Color3.fromRGB(255, 255, 0)},
                {name = "Purple", color = Color3.fromRGB(180, 50, 255)},
                {name = "Cyan", color = Color3.fromRGB(0, 200, 255)},
                {name = "Orange", color = Color3.fromRGB(255, 150, 0)},
                {name = "White", color = Color3.fromRGB(255, 255, 255)},
                {name = "Pink", color = Color3.fromRGB(255, 100, 200)}
            }
            
            -- Remove existing picker
            if ColorFrame:FindFirstChild("PickerList") then
                ColorFrame.PickerList:Destroy()
                return
            end
            
            local PickerList = Instance.new("Frame")
            PickerList.Name = "PickerList"
            PickerList.Size = UDim2.new(0, 140, 0, #colors * 24)
            PickerList.Position = UDim2.new(1, -140, 1, 0)
            PickerList.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            PickerList.BorderSizePixel = 0
            PickerList.ZIndex = 10
            PickerList.Parent = ColorFrame
            
            local PickerCorner = Instance.new("UICorner")
            PickerCorner.CornerRadius = UDim.new(0, 5)
            PickerCorner.Parent = PickerList
            
            local PickerStroke = Instance.new("UIStroke")
            PickerStroke.Color = Color3.fromRGB(60, 60, 80)
            PickerStroke.Thickness = 1
            PickerStroke.Parent = PickerList
            
            local PickerLayout = Instance.new("UIListLayout")
            PickerLayout.Parent = PickerList
            
            for _, c in ipairs(colors) do
                local ColorOpt = Instance.new("TextButton")
                ColorOpt.Size = UDim2.new(1, 0, 0, 24)
                ColorOpt.Text = c.name
                ColorOpt.TextColor3 = c.color
                ColorOpt.TextSize = 11
                ColorOpt.Font = Enum.Font.GothamBold
                ColorOpt.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                ColorOpt.BorderSizePixel = 0
                ColorOpt.ZIndex = 11
                ColorOpt.Parent = PickerList
                
                ColorOpt.MouseButton1Click:Connect(function()
                    currentColor = c.color
                    ColorPreview.BackgroundColor3 = c.color
                    callback(c.color)
                    PickerList:Destroy()
                end)
                
                ColorOpt.MouseEnter:Connect(function()
                    ColorOpt.BackgroundColor3 = c.color
                    ColorOpt.TextColor3 = Color3.fromRGB(0, 0, 0)
                end)
                ColorOpt.MouseLeave:Connect(function()
                    ColorOpt.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                    ColorOpt.TextColor3 = c.color
                end)
            end
        end)
        
        return ColorFrame
    end
    
    -- // ==========================================
    -- // INFO TAB
    -- // ==========================================
    local InfoPage = TabContent["INFO"]
    
    CreateTitle(InfoPage, "📋 SCRIPT INFO")
    CreateLabel(InfoPage, "CYBER-AI 2046 v3.0")
    CreateLabel(InfoPage, "Map: Violence District")
    CreateLabel(InfoPage, "Role: Survivor + Killer")
    
    CreateTitle(InfoPage, "👨🏼‍💻 DEVELOPER")
    CreateLabel(InfoPage, "Created by: YUKI")
    CreateLabel(InfoPage, "Version: 3.0 Modern")
    CreateLabel(InfoPage, "Last Update: 2046")
    
    CreateTitle(InfoPage, "⌨️ KEYBINDS")
    CreateLabel(InfoPage, "Toggle UI: Right Ctrl")
    CreateLabel(InfoPage, "Moonwalk: Auto")
    CreateLabel(InfoPage, "Parry Key: F (Auto)")
    
    CreateTitle(InfoPage, "📌 NOTES")
    CreateLabel(InfoPage, "✓ All features realtime 100%")
    CreateLabel(InfoPage, "✓ Clean optimized code")
    CreateLabel(InfoPage, "✓ No lag, low CPU usage")
    
    -- // ==========================================
    -- // MAIN TAB
    -- // ==========================================
    local MainPage = TabContent["MAIN"]
    
    CreateTitle(MainPage, "⚡ AUTO PARRY")
    CreateToggle(MainPage, "Auto Parry", false, function(v)
        Config.Main.AutoParry = v
    end)
    CreateSlider(MainPage, "Parry Range", 1, 30, 5.0, function(v)
        Config.Main.ParryRange = v
    end, " studs")
    
    CreateTitle(MainPage, "🌙 MOONWALK")
    CreateToggle(MainPage, "Moonwalk", false, function(v)
        Config.Main.Moonwalk = v
    end)
    
    CreateTitle(MainPage, "⚙️ OPTIMAL")
    CreateToggle(MainPage, "Optimal Mode", false, function(v)
        Config.Main.Optimal = v
    end)
    CreateLabel(MainPage, "Optimalkan semua fitur realtime 100%")
    
    -- // ==========================================
    -- // ESP TAB
    -- // ==========================================
    local ESPPage = TabContent["ESP"]
    
    CreateTitle(ESPPage, "👤 ESP PLAYER")
    CreateToggle(ESPPage, "ESP Player", false, function(v)
        Config.ESP.PlayerESP = v
    end)
    CreateColorPicker(ESPPage, "Player Color", Config.ESP.PlayerColor, function(c)
        Config.ESP.PlayerColor = c
    end)
    
    CreateTitle(ESPPage, "💀 ESP KILLER")
    CreateToggle(ESPPage, "ESP Killer (Merah)", false, function(v)
        Config.ESP.KillerESP = v
    end)
    
    CreateTitle(ESPPage, "⚡ ESP GENERATOR")
    CreateToggle(ESPPage, "ESP Generator", false, function(v)
        Config.ESP.GeneratorESP = v
    end)
    CreateColorPicker(ESPPage, "Generator Color", Config.ESP.GeneratorColor, function(c)
        Config.ESP.GeneratorColor = c
    end)
    
    -- // ==========================================
    -- // SURVI TAB
    -- // ==========================================
    local SurviPage = TabContent["SURVI"]
    
    CreateTitle(SurviPage, "🔧 AUTO GENERATOR")
    CreateToggle(SurviPage, "Auto Generator", false, function(v)
        Config.Survival.AutoGenerator = v
    end)
    CreateDropdown(SurviPage, "Method", {"Instant", "Normal", "Perfect"}, "Instant", function(v)
        Config.Survival.GenMethod = v
    end)
    
    CreateTitle(SurviPage, "📝 LAINNYA")
    CreateLabel(SurviPage, "• Auto Heal (Coming Soon)")
    CreateLabel(SurviPage, "• Auto Exit (Coming Soon)")
    CreateLabel(SurviPage, "• Anti Trap (Coming Soon)")
    
    -- // ==========================================
    -- // DEV TAB
    -- // ==========================================
    local DevPage = TabContent["DEV"]
    
    CreateTitle(DevPage, "💻 DEVELOPER INFO")
    CreateLabel(DevPage, "Creator: YUKI")
    CreateLabel(DevPage, "Engine: Luau / Roblox")
    CreateLabel(DevPage, "UI Framework: Custom")
    
    CreateTitle(DevPage, "🔧 TECHNICAL")
    CreateLabel(DevPage, "• Custom UI Library")
    CreateLabel(DevPage, "• Optimized Render")
    CreateLabel(DevPage, "• Low Memory Usage")
    CreateLabel(DevPage, "• Fast Execution")
    CreateLabel(DevPage, "• No Lag Spikes")
    
    CreateTitle(DevPage, "📦 CHANGELOG")
    CreateLabel(DevPage, "v3.0 - Modern Clean UI")
    CreateLabel(DevPage, "v3.0 - Color Picker Added")
    CreateLabel(DevPage, "v3.0 - Optimized Codebase")
    
    -- // ==========================================
    -- // ESP SYSTEM
    -- // ==========================================
    local espDrawings = {}
    
    spawn(function()
        while task.wait(0.001) do
            pcall(function()
                -- Hide all first
                for _, d in pairs(espDrawings) do
                    d.Visible = false
                end
                
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                
                -- ESP Player
                if Config.ESP.PlayerESP then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player == LocalPlayer then continue end
                        local char = player.Character
                        if not char then continue end
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        local head = char:FindFirstChild("Head")
                        local hum = char:FindFirstChild("Humanoid")
                        if not hrp or not head or not hum or hum.Health <= 0 then continue end
                        
                        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if not onScreen then continue end
                        
                        local isKiller = player.Team and (player.Team.Name == "Killer" or player.Team.Name == "Hunter")
                        
                        -- Skip killer if killer ESP off, skip survivor if player ESP off
                        if isKiller and not Config.ESP.KillerESP then continue end
                        
                        local color = isKiller and Config.ESP.KillerColor or Config.ESP.PlayerColor
                        
                        -- Box
                        local box = espDrawings[player.Name .. "_box"] or Drawing.new("Square")
                        box.Visible = true
                        box.Color = color
                        box.Thickness = 1
                        box.Filled = false
                        box.Transparency = 0.5
                        
                        local headPos = Camera:WorldToViewportPoint(head.Position)
                        local h = (pos.Y - headPos.Y) * 1.4
                        local w = h * 0.5
                        box.Size = Vector2.new(w, h)
                        box.Position = Vector2.new(pos.X - w/2, headPos.Y - h)
                        espDrawings[player.Name .. "_box"] = box
                        
                        -- Distance
                        local dist = (hrp.Position - root.Position).Magnitude
                        local distText = espDrawings[player.Name .. "_dist"] or Drawing.new("Text")
                        distText.Visible = true
                        distText.Color = color
                        distText.Size = 12
                        distText.Center = true
                        distText.Text = math.floor(dist) .. "m"
                        distText.Position = Vector2.new(pos.X, pos.Y + 10)
                        espDrawings[player.Name .. "_dist"] = distText
                    end
                end
                
                -- ESP Generator
                if Config.ESP.GeneratorESP then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("generator") or obj.Name:lower():find("gen")) then
                            local genPos = obj:FindFirstChild("Base") or obj.PrimaryPart
                            if genPos then
                                local pos, onScreen = Camera:WorldToViewportPoint(genPos.Position)
                                if onScreen then
                                    local dist = (genPos.Position - root.Position).Magnitude
                                    local genText = espDrawings["gen_" .. obj.Name] or Drawing.new("Text")
                                    genText.Visible = true
                                    genText.Color = Config.ESP.GeneratorColor
                                    genText.Size = 12
                                    genText.Center = true
                                    genText.Outline = true
                                    genText.Text = obj.Name .. " [" .. math.floor(dist) .. "m]"
                                    genText.Position = Vector2.new(pos.X, pos.Y)
                                    espDrawings["gen_" .. obj.Name] = genText
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
    
    -- // ==========================================
    -- // AUTO PARRY SYSTEM
    -- // ==========================================
    spawn(function()
        while task.wait(0.001) do
            if not Config.Main.AutoParry then continue end
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Team and 
                       (player.Team.Name == "Killer" or player.Team.Name == "Hunter") then
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if not hrp then continue end
                            local dist = (char.HumanoidRootPart.Position - hrp.Position).Magnitude
                            if dist <= Config.Main.ParryRange then
                                local hum = char:FindFirstChild("Humanoid")
                                if hum then
                                    local animator = hum:FindFirstChild("Animator")
                                    if animator then
                                        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                                            if track.Animation.AnimationId:lower():find("attack") then
                                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
                                                task.wait(0.05)
                                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
    
    -- // ==========================================
    -- // MOONWALK SYSTEM
    -- // ==========================================
    spawn(function()
        while task.wait(0.001) do
            if not Config.Main.Moonwalk then continue end
            pcall(function()
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                    humanoid.WalkSpeed = -24
                end
            end)
        end
    end)
    
    -- // ==========================================
    -- // OPTIMAL MODE
    // // ==========================================
    spawn(function()
        while task.wait(1) do
            if Config.Main.Optimal then
                -- Force all systems to max efficiency
                Config.Main.AutoParry = true
                Config.Main.Moonwalk = false
                Config.ESP.PlayerESP = true
                Config.ESP.KillerESP = true
                Config.ESP.GeneratorESP = true
                Config.Survival.AutoGenerator = true
                Config.Survival.GenMethod = "Instant"
                Config.Main.ParryRange = 30
            end
        end
    end)
    
    -- // ==========================================
    -- // AUTO GENERATOR SYSTEM
    -- // ==========================================
    spawn(function()
        while task.wait(0.1) do
            if not Config.Survival.AutoGenerator then continue end
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
                    if Config.Survival.GenMethod == "Instant" then
                        local remote = ReplicatedStorage:FindFirstChild("RepairGen") or
                                      ReplicatedStorage.Events:FindFirstChild("GeneratorRepair")
                        if remote then
                            for i = 1, 5 do
                                remote:FireServer(nearestGen)
                                task.wait(0.01)
                            end
                        end
                    elseif Config.Survival.GenMethod == "Perfect" then
                        -- Perfect skill check simulation
                        local remote = ReplicatedStorage:FindFirstChild("RepairGen") or
                                      ReplicatedStorage.Events:FindFirstChild("GeneratorRepair")
                        if remote then
                            remote:FireServer(nearestGen, "Perfect")
                        end
                    end
                end
            end)
        end
    end)
    
    -- // ==========================================
    -- // KEYBIND TOGGLE UI
    -- // ==========================================
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
        end
    end)
    
    print("CYBER-AI 2046 v3.0 LOADED | VIOLENCE DISTRICT")
end

-- // INITIALIZE
CreateUI()
