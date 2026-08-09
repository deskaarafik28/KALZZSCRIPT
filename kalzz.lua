--[[
╔══════════════════════════════════════╗
║   VIOLENCE DISTRICT CUSTOM SCRIPT   ║
║   Made for Delta Executor            ║
║   Features: ESP, Speed, AutoParry   ║
║             SkillCheck, InfJump     ║
╚══════════════════════════════════════╝
]]

-- ==============================
--          SERVICES
-- ==============================
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local LocalPlayer     = Players.LocalPlayer
local Camera          = workspace.CurrentCamera

-- ==============================
--          SETTINGS
-- ==============================
local Config = {
    -- Player Stats
    WalkSpeed       = 28,
    JumpPower       = 75,
    InfiniteJump    = true,
    
    -- Features  
    ESPEnabled      = true,  
    ESPTeamCheck    = false,
    AutoParry       = true,  
    SkillCheckAuto  = true,  
    AntiStun        = true,  
    
    -- ESP Colors  
    SurvivorColor   = Color3.fromRGB(0, 200, 255),  
    KillerColor     = Color3.fromRGB(255, 50, 50),  
    ESPTextSize     = 14,
}

-- ==============================
--       SPEED & JUMP
-- ==============================
local function applyStats()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Config.WalkSpeed
        hum.JumpPower = Config.JumpPower
    end
end

applyStats()
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(1.5)
    applyStats()
end)

-- ==============================
--       INFINITE JUMP
-- ==============================
if Config.InfiniteJump then
    UserInputService.JumpRequest:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- ==============================
--       ANTI STUN
-- ==============================
if Config.AntiStun then
    RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum:GetState() == Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end)
end

-- ==============================
--       AUTO SKILLCHECK
-- ==============================
if Config.SkillCheckAuto then
    local function handleSkillCheck(gui)
        local btn = gui:FindFirstChildWhichIsA("TextButton", true)
            or gui:FindFirstChildWhichIsA("ImageButton", true)
        if btn then
            wait(0.05)
            pcall(function()
                btn.MouseButton1Click:Fire()
            end)
            pcall(function()
                btn.Activated:Fire()
            end)
        end
    end
    
    local function watchGui(parent)
        parent.DescendantAdded:Connect(function(obj)
            if obj:IsA("ScreenGui") or obj:IsA("Frame") then
                local name = obj.Name:lower()
                if name:find("skill") or name:find("check") or name:find("qte") then
                    spawn(handleSkillCheck, obj)
                end
            end
        end)
    end
    
    watchGui(LocalPlayer.PlayerGui)
    pcall(function()
        watchGui(game:GetService("CoreGui"))
    end)
end

-- ==============================
--       AUTO PARRY
-- ==============================
if Config.AutoParry then
    local function tryParry(char)
        local backpack = LocalPlayer.Backpack
        local parryTool = backpack:FindFirstChild("Parry")
            or char:FindFirstChild("Parry")
        
        if parryTool then  
            local remote = parryTool:FindFirstChildWhichIsA("RemoteEvent")  
                or parryTool:FindFirstChildWhichIsA("RemoteFunction")  
            if remote then  
                remote:FireServer("Parry")  
            end  
        end  
    
        local RS = game:GetService("ReplicatedStorage")  
        local parryRemote = RS:FindFirstChild("Parry", true)  
            or RS:FindFirstChild("ParryAction", true)  
            or RS:FindFirstChild("Block", true)  
        if parryRemote and parryRemote:IsA("RemoteEvent") then  
            parryRemote:FireServer()  
        end  
    end  
    
    RunService.Heartbeat:Connect(function()  
        local char = LocalPlayer.Character  
        if not char then return end  
    
        for _, player in ipairs(Players:GetPlayers()) do  
            if player == LocalPlayer then continue end  
            local pChar = player.Character  
            if not pChar then continue end  
    
            local animator = pChar:FindFirstChildWhichIsA("Animator", true)  
            if not animator then continue end  
    
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do  
                local animName = track.Name:lower()  
                if animName:find("attack") or animName:find("swing")  
                or animName:find("hit") or animName:find("slash") then  
                    spawn(tryParry, char)  
                end  
            end  
        end  
    end)
end

-- ==============================
--       ESP PLAYERS
-- ==============================
local espFolder = Instance.new("Folder")
espFolder.Name = "VD_ESP"
espFolder.Parent = LocalPlayer.PlayerGui

local function removeESP(player)
    local old = espFolder:FindFirstChild(player.Name)
    if old then old:Destroy() end
end

local function createESP(player)
    if player == LocalPlayer then return end
    removeESP(player)
    
    local function buildESP(char)  
        if not char then return end  
        local head = char:WaitForChild("Head", 5)  
        if not head then return end  
    
        local container = Instance.new("Folder")  
        container.Name = player.Name  
        container.Parent = espFolder  
    
        local billboard = Instance.new("BillboardGui")  
        billboard.Name = "NameESP"  
        billboard.AlwaysOnTop = true  
        billboard.Size = UDim2.new(0, 140, 0, 50)  
        billboard.StudsOffset = Vector3.new(0, 3.5, 0)  
        billboard.Adornee = head  
        billboard.Parent = container  
    
        local nameLabel = Instance.new("TextLabel")  
        nameLabel.Size = UDim2.new(1, 0, 0.6, 0)  
        nameLabel.Position = UDim2.new(0, 0, 0, 0)  
        nameLabel.BackgroundTransparency = 1  
        nameLabel.TextStrokeTransparency = 0  
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)  
        nameLabel.TextScaled = true  
        nameLabel.Font = Enum.Font.SourceSansBold  
        nameLabel.Parent = billboard  
    
        local distLabel = Instance.new("TextLabel")  
        distLabel.Size = UDim2.new(1, 0, 0.4, 0)  
        distLabel.Position = UDim2.new(0, 0, 0.6, 0)  
        distLabel.BackgroundTransparency = 1  
        distLabel.TextStrokeTransparency = 0  
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)  
        distLabel.TextScaled = true  
        distLabel.Font = Enum.Font.SourceSans  
        distLabel.Parent = billboard  
    
        local highlight = Instance.new("SelectionBox")  
        highlight.LineThickness = 0.05  
        highlight.SurfaceTransparency = 0.6  
        highlight.Adornee = char  
        highlight.Parent = container  
    
        local conn  
        conn = RunService.RenderStepped:Connect(function()  
            if not char or not char.Parent then  
                conn:Disconnect()  
                container:Destroy()  
                return  
            end  
    
            local isKiller = false  
            local roleTag = char:FindFirstChild("IsKiller")  
                or LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("KillerTarget")  
            if roleTag then isKiller = true end  
    
            if player.Team and player.Team.Name:lower():find("killer") then  
                isKiller = true  
            end  
    
            local espColor = isKiller and Config.KillerColor or Config.SurvivorColor  
            nameLabel.TextColor3 = espColor  
            distLabel.TextColor3 = espColor  
            highlight.Color3 = espColor  
            highlight.SurfaceColor3 = espColor  
    
            local myRoot = LocalPlayer.Character and  
                LocalPlayer.Character:FindFirstChild("HumanoidRootPart")  
            local theirRoot = char:FindFirstChild("HumanoidRootPart")  
    
            nameLabel.Text = player.Name  
            if myRoot and theirRoot then  
                local dist = math.floor((myRoot.Position - theirRoot.Position).Magnitude)  
                distLabel.Text = dist .. " studs"  
            else  
                distLabel.Text = "? studs"  
            end  
        end)  
    end  
    
    buildESP(player.Character)  
    player.CharacterAdded:Connect(buildESP)
end

if Config.ESPEnabled then
    for _, player in ipairs(Players:GetPlayers()) do
        spawn(createESP, player)
    end
    Players.PlayerAdded:Connect(createESP)
    Players.PlayerRemoving:Connect(removeESP)
end

-- ==============================
--       WORLD ESP
-- ==============================
local worldESPTargets = {
    Generator = Color3.fromRGB(255, 220, 0),
    Hook      = Color3.fromRGB(255, 100, 0),
    Gate      = Color3.fromRGB(0, 255, 100),
    Pallet    = Color3.fromRGB(180, 100, 255),
    Window    = Color3.fromRGB(100, 200, 255),
    Chest     = Color3.fromRGB(255, 180, 50),
}

local function applyWorldESP()
    for objectName, color in pairs(worldESPTargets) do
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if name:find(objectName:lower()) and obj:IsA("BasePart") then
                if not obj:FindFirstChildWhichIsA("SelectionBox") then
                    local box = Instance.new("SelectionBox")
                    box.LineThickness = 0.04
                    box.SurfaceTransparency = 0.75
                    box.SurfaceColor3 = color
                    box.Color3 = color
                    box.Adornee = obj
                    box.Parent = espFolder
                    
                    local bb = Instance.new("BillboardGui")  
                    bb.AlwaysOnTop = true  
                    bb.Size = UDim2.new(0, 100, 0, 30)  
                    bb.StudsOffset = Vector3.new(0, 2.5, 0)  
                    bb.Adornee = obj  
                    bb.Parent = espFolder  
                    
                    local lbl = Instance.new("TextLabel")  
                    lbl.Size = UDim2.new(1, 0, 1, 0)  
                    lbl.BackgroundTransparency = 1  
                    lbl.TextColor3 = color  
                    lbl.TextStrokeTransparency = 0  
                    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)  
                    lbl.TextScaled = true  
                    lbl.Font = Enum.Font.SourceSansBold  
                    lbl.Text = objectName  
                    lbl.Parent = bb  
                end  
            end  
        end  
    end
end

applyWorldESP()
spawn(function()
    while wait(5) do
        applyWorldESP()
    end
end)

-- ==============================
--       SIMPLE GUI TOGGLE
-- ==============================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VD_Menu"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 280)
frame.Position = UDim2.new(0, 15, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Text = "VD Script"
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- Toggle Factory
local btnY = 50
local function createToggle(labelText, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, btnY)
    btn.BackgroundColor3 = default and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(180, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = (default and "[ON] " or "[OFF] ") .. labelText
    btn.BorderSizePixel = 0
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local state = default  
    btn.MouseButton1Click:Connect(function()  
        state = not state  
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(180, 50, 50)  
        btn.Text = (state and "[ON] " or "[OFF] ") .. labelText
        callback(state)  
    end)  
    
    btnY = btnY + 42  
    return btn
end

-- Toggles
createToggle("ESP Players", Config.ESPEnabled, function(v)
    Config.ESPEnabled = v
    if v then
        for _, p in ipairs(Players:GetPlayers()) do
            spawn(createESP, p)
        end
    else
        for _, obj in ipairs(espFolder:GetChildren()) do
            obj:Destroy()
        end
    end
end)

createToggle("Auto Parry", Config.AutoParry, function(v)
    Config.AutoParry = v
end)

createToggle("Auto SkillCheck", Config.SkillCheckAuto, function(v)
    Config.SkillCheckAuto = v
end)

createToggle("Infinite Jump", Config.InfiniteJump, function(v)
    Config.InfiniteJump = v
end)

createToggle("Anti Stun", Config.AntiStun, function(v)
    Config.AntiStun = v
end)

createToggle("World ESP", true, function(v)
    for _, obj in ipairs(espFolder:GetChildren()) do
        if not obj:IsA("Folder") then
            obj.Visible = v
        end
    end
end)

-- Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 25)
speedLabel.Position = UDim2.new(0.05, 0, 0, btnY)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.SourceSans
speedLabel.Text = "Speed: " .. Config.WalkSpeed
speedLabel.Parent = frame

btnY = btnY + 28

-- Speed Buttons
local speedMinus = Instance.new("TextButton")
speedMinus.Size = UDim2.new(0.42, 0, 0, 28)
speedMinus.Position = UDim2.new(0.05, 0, 0, btnY)
speedMinus.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
speedMinus.TextColor3 = Color3.fromRGB(255,255,255)
speedMinus.Text = "- Speed"
speedMinus.Font = Enum.Font.SourceSansBold
speedMinus.TextScaled = true
speedMinus.BorderSizePixel = 0
speedMinus.Parent = frame
Instance.new("UICorner", speedMinus).CornerRadius = UDim.new(0, 8)

local speedPlus = Instance.new("TextButton")
speedPlus.Size = UDim2.new(0.42, 0, 0, 28)
speedPlus.Position = UDim2.new(0.53, 0, 0, btnY)
speedPlus.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
speedPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
speedPlus.Text = "+ Speed"
speedPlus.Font = Enum.Font.SourceSansBold
speedPlus.TextScaled = true
speedPlus.BorderSizePixel = 0
speedPlus.Parent = frame
Instance.new("UICorner", speedPlus).CornerRadius = UDim.new(0, 8)

speedMinus.MouseButton1Click:Connect(function()
    Config.WalkSpeed = math.max(8, Config.WalkSpeed - 2)
    speedLabel.Text = "Speed: " .. Config.WalkSpeed
    applyStats()
end)

speedPlus.MouseButton1Click:Connect(function()
    Config.WalkSpeed = math.min(100, Config.WalkSpeed + 2)
    speedLabel.Text = "Speed: " .. Config.WalkSpeed
    applyStats()
end)

-- ==============================
--       HIDE/SHOW TOGGLE
-- ==============================
local guiVisible = true
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        frame.Visible = guiVisible
    end
end)

-- ==============================
--       INIT MESSAGE
-- ==============================
spawn(function()
    local msg = Instance.new("Message")
    msg.Text = "VD Script Loaded! | RightShift = Toggle Menu"
    msg.Parent = workspace
    wait(4)
    msg:Destroy()
end)

print("Violence District Script - Loaded!")
print("RightShift = Toggle Menu")
