--[[
    KALZZSCRIPT
    modules/esp.lua - Highlight ESP + Generator
]]

local S = _G.KZ
if not S then warn("[ESP] main.lua belum di-load"); return end

local Players = S.Players
local RSvc = S.RSvc
local Workspace = S.Workspace
local LP = S.LP
local CFG = S.CFG

local highlights = {}
local labels = {}
local genHL, genLbl, trackedGens = {}, {}, {}

local function getCam() return Workspace.CurrentCamera end

local function updatePlayer(plr, cam)
    if plr == LP then return end
    local char = plr.Character
    local head = char and char:FindFirstChild("Head")

    if not char or not head then
        if highlights[plr] then
            highlights[plr].FillTransparency = 1
            highlights[plr].OutlineTransparency = 1
            highlights[plr].Adornee = nil
        end
        if labels[plr] then
            labels[plr].Text = ""
            if labels[plr].Parent then labels[plr].Parent.Adornee = nil end
        end
        return
    end

    local team = plr.Team
    local isK = team and team.Name == "Killer"
    local isS = team and (team.Name == "Survivors" or team.Name == "Survivor")

    if not isK and not isS then
        local role = char:GetAttribute("Role") or plr:GetAttribute("Role")
        if type(role) == "string" then
            local r = role:lower()
            isK = r:find("killer") ~= nil
            isS = r:find("survivor") ~= nil
        end
    end

    if isK and not CFG.esp_k then
        if highlights[plr] then highlights[plr].Enabled = false end
        return
    end
    if isS and not CFG.esp_s then
        if highlights[plr] then highlights[plr].Enabled = false end
        return
    end
    if not isK and not isS then
        if highlights[plr] then highlights[plr].Enabled = false end
        return
    end

    local color = Color3.fromRGB(255, 255, 255)
    if isK then
        color = Color3.fromRGB(255, 80, 80)
    else
        local hum = char:FindFirstChildOfClass("Humanoid")
        if char:GetAttribute("IsHooked") then
            color = Color3.fromRGB(255, 110, 80)
        elseif char:GetAttribute("Knocked") then
            color = Color3.fromRGB(255, 170, 80)
        elseif hum and hum.Health < hum.MaxHealth then
            color = Color3.fromRGB(255, 255, 120)
        else
            color = Color3.fromRGB(100, 255, 100)
        end
    end

    if not highlights[plr] or not highlights[plr].Parent then
        local hl = Instance.new("Highlight")
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = cam
        highlights[plr] = hl
    end

    local hl = highlights[plr]
    if hl.Parent ~= cam then hl.Parent = cam end
    hl.Adornee = char
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = CFG.esp_out and 1 or 0.35
    hl.OutlineTransparency = 0
    hl.Enabled = true

    local itemTxt = ""
    if isS and CFG.esp_item then
        local item = plr:GetAttribute("EquippedItem")
        if item and item ~= "" and item ~= "None" then
            itemTxt = "[" .. tostring(item) .. "]"
        end
    end

    if itemTxt == "" then
        if labels[plr] then
            labels[plr].Text = ""
            if labels[plr].Parent then labels[plr].Parent.Adornee = nil end
        end
    else
        if not labels[plr] or not labels[plr].Parent then
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0, 220, 0, 40)
            bill.StudsOffset = Vector3.new(0, 3.2, 0)
            bill.AlwaysOnTop = true
            bill.Parent = cam
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Font = Enum.Font.SourceSansSemibold
            txt.TextSize = 14
            txt.TextStrokeTransparency = 0.3
            txt.TextStrokeColor3 = Color3.new(0, 0, 0)
            txt.Parent = bill
            labels[plr] = txt
        end
        local txt = labels[plr]
        local bill = txt.Parent
        if bill and bill.Parent ~= cam then bill.Parent = cam end
        if bill then bill.Adornee = head end
        txt.Text = itemTxt
        txt.TextColor3 = color
    end
end

local function updateGen(obj)
    if not obj or not obj.Parent then return end

    if not CFG.esp_g then
        if genHL[obj] then genHL[obj].Enabled = false end
        if genLbl[obj] and genLbl[obj].Parent then genLbl[obj].Parent:Destroy() end
        genLbl[obj] = nil
        return
    end

    local progress = obj:GetAttribute("RepairProgress")
    if progress == nil then return end
    local repairing = obj:GetAttribute("PlayersRepairingCount") or 0
    local isFull = progress >= 100

    local cam = getCam()
    if not cam then return end

    if not genHL[obj] or not genHL[obj].Parent then
        local hl = Instance.new("Highlight")
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = cam
        genHL[obj] = hl
    end

    local hl = genHL[obj]
    if hl.Parent ~= cam then hl.Parent = cam end
    hl.Adornee = obj
    hl.Enabled = true

    if isFull then
        hl.FillColor = Color3.fromRGB(0, 255, 0)
        hl.OutlineColor = Color3.fromRGB(0, 255, 0)
        hl.FillTransparency = CFG.esp_out and 1 or 0.5
    else
        hl.FillColor = Color3.fromRGB(80, 220, 120)
        hl.OutlineColor = Color3.fromRGB(80, 220, 120)
        hl.FillTransparency = CFG.esp_out and 1 or 0.55
    end
    hl.OutlineTransparency = 0

    local attach = obj:FindFirstChild("defaultMaterial")
        or obj.PrimaryPart
        or obj:FindFirstChildWhichIsA("BasePart")
    if not attach then return end

    if CFG.esp_gen_txt then
        if not genLbl[obj] or not genLbl[obj].Parent then
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0, 170, 0, 38)
            bill.StudsOffset = Vector3.new(0, 4, 0)
            bill.AlwaysOnTop = true
            bill.Parent = cam
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextSize = 14
            txt.Font = Enum.Font.SourceSansSemibold
            txt.TextStrokeTransparency = 0.4
            txt.Parent = bill
            genLbl[obj] = txt
        end
        local txt = genLbl[obj]
        local bill = txt.Parent
        if bill then
            if bill.Parent ~= cam then bill.Parent = cam end
            bill.Adornee = attach
        end
        if isFull then
            txt.Text = "Generator\n100%"
            txt.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            if repairing > 0 then
                txt.Text = string.format("Generator\n%.1f%% [%d]", progress, repairing)
            else
                txt.Text = string.format("Generator\n%.1f%%", progress)
            end
            local g = math.clamp(progress / 100, 0, 1)
            txt.TextColor3 = Color3.new(1 - g * 0.7, 1, 1 - g * 0.7)
        end
    else
        if genLbl[obj] then
            if genLbl[obj].Parent then genLbl[obj].Parent:Destroy() end
            genLbl[obj] = nil
        end
    end
end

local function scanGens()
    local map = Workspace:FindFirstChild("Map") or Workspace
    for _, obj in ipairs(map:GetDescendants()) do
        if obj:IsA("Model") and obj:GetAttribute("RepairProgress") ~= nil then
            trackedGens[obj] = true
            updateGen(obj)
        end
    end
end

RSvc.Heartbeat:Connect(function()
    local cam = getCam()
    if not cam then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        pcall(updatePlayer, plr, cam)
    end
    for gen in pairs(trackedGens) do
        if gen and gen.Parent then
            pcall(updateGen, gen)
        else
            if genHL[gen] then genHL[gen]:Destroy() end
            if genLbl[gen] and genLbl[gen].Parent then genLbl[gen].Parent:Destroy() end
            genHL[gen], genLbl[gen], trackedGens[gen] = nil, nil, nil
        end
    end
end)

task.spawn(function()
    task.wait(1)
    scanGens()
end)

local map = Workspace:FindFirstChild("Map") or Workspace
map.DescendantAdded:Connect(function(child)
    task.defer(function()
        if child:IsA("Model") and child:GetAttribute("RepairProgress") ~= nil then
            trackedGens[child] = true
            updateGen(child)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if highlights[plr] then highlights[plr]:Destroy() highlights[plr] = nil end
    if labels[plr] and labels[plr].Parent then labels[plr].Parent:Destroy() labels[plr] = nil end
end)

print("[KZ] ESP module loaded")
