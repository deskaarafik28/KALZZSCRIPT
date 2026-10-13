local S = _G.KZ
if not S then return end

pcall(function()
    local highlights = {}
    local labels = {}
    local genHL, genLbl, trackedGens = {}, {}, {}
    local function getCam() return S.Workspace.CurrentCamera end
    local function updatePlayer(plr, cam)
        if plr == S.LP then return end
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
        if isK and not S.CFG.esp_k then
            if highlights[plr] then highlights[plr].Enabled = false end
            if labels[plr] and labels[plr].Parent then labels[plr].Parent.Adornee = nil end
            return
        end
        if isS and not S.CFG.esp_s then
            if highlights[plr] then highlights[plr].Enabled = false end
            if labels[plr] and labels[plr].Parent then labels[plr].Parent.Adornee = nil end
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
            if char:GetAttribute("IsHooked") then color = Color3.fromRGB(255, 110, 80)
            elseif char:GetAttribute("Knocked") then color = Color3.fromRGB(255, 170, 80)
            elseif hum and hum.Health < hum.MaxHealth then color = Color3.fromRGB(255, 255, 120)
            else color = Color3.fromRGB(100, 255, 100) end
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
        hl.FillTransparency = S.CFG.esp_out and 1 or 0.35
        hl.OutlineTransparency = 0
        hl.Enabled = true
        local itemTxt = ""
        if isS and S.CFG.esp_item then
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
        if not S.CFG.esp_g then
            if genHL[obj] then genHL[obj].Enabled = false end
            if genLbl[obj] and genLbl[obj].Parent then genLbl[obj].Parent:Destroy() end
            genLbl[obj] = nil
            return
        end
        local prog = obj:GetAttribute("RepairProgress")
        if prog == nil then return end
        local isFull = prog >= 100
        local cam = getCam()
        if not cam then return end
        if not genHL[obj] or not genHL[obj].Parent then
            local h = Instance.new("Highlight")
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = cam
            genHL[obj] = h
        end
        local h = genHL[obj]
        if h.Parent ~= cam then h.Parent = cam end
        h.Adornee = obj
        h.Enabled = true
        if isFull then
            h.FillColor = Color3.fromRGB(0, 255, 0); h.OutlineColor = Color3.fromRGB(0, 255, 0)
        else
            h.FillColor = Color3.fromRGB(80, 220, 120); h.OutlineColor = Color3.fromRGB(80, 220, 120)
        end
        h.FillTransparency = S.CFG.esp_out and 1 or 0.5
        h.OutlineTransparency = 0
    end
    S.RSvc.Heartbeat:Connect(function()
        local cam = getCam()
        if not cam then return end
        for _, plr in ipairs(S.Players:GetPlayers()) do pcall(updatePlayer, plr, cam) end
        for gen in pairs(trackedGens) do
            if gen and gen.Parent then pcall(updateGen, gen)
            else
                if genHL[gen] then genHL[gen]:Destroy() end
                if genLbl[gen] and genLbl[gen].Parent then genLbl[gen].Parent:Destroy() end
                genHL[gen], genLbl[gen], trackedGens[gen] = nil, nil, nil
            end
        end
    end)
    task.spawn(function()
        task.wait(1)
        local map = S.Workspace:FindFirstChild("Map") or S.Workspace
        for _, o in ipairs(map:GetDescendants()) do
            if o:IsA("Model") and o:GetAttribute("RepairProgress") ~= nil then
                trackedGens[o] = true
                updateGen(o)
            end
        end
    end)
    S.Players.PlayerRemoving:Connect(function(plr)
        if highlights[plr] then highlights[plr]:Destroy() highlights[plr] = nil end
        if labels[plr] and labels[plr].Parent then labels[plr].Parent:Destroy() labels[plr] = nil end
    end)
end)

print("[KZ] esp loaded")
