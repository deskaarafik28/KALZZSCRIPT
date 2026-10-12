--[[ KALZZSCRIPT | auto-parry.lua ]]

local S = _G.KZ
if not S then return end

-- Parry Circle
do
    local base = Instance.new("Part")
    base.Name = "KZ_ParryCircle"
    base.Size = Vector3.new(1, 0.05, 1)
    base.Anchored = true
    base.CanCollide = false
    base.CanQuery = false
    base.CanTouch = false
    base.CastShadow = false
    base.Material = Enum.Material.SmoothPlastic
    base.Transparency = 1
    base.Parent = S.Workspace

    local sg = Instance.new("SurfaceGui", base)
    sg.Face = Enum.NormalId.Top
    sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    sg.PixelsPerStud = 40
    sg.LightInfluence = 0
    sg.ZOffset = 1

    local ring = Instance.new("Frame", sg)
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.fromScale(0.5, 0.5)
    ring.Size = UDim2.fromScale(0.96, 0.96)
    ring.BackgroundTransparency = 1
    ring.BorderSizePixel = 0
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    local s1 = Instance.new("UIStroke", ring)
    s1.Thickness = 4
    s1.Color = Color3.fromRGB(255, 255, 255)
    s1.Transparency = 1
    s1.LineJoinMode = Enum.LineJoinMode.Round

    local ring2 = Instance.new("Frame", sg)
    ring2.AnchorPoint = Vector2.new(0.5, 0.5)
    ring2.Position = UDim2.fromScale(0.5, 0.5)
    ring2.Size = UDim2.fromScale(0.88, 0.88)
    ring2.BackgroundTransparency = 1
    ring2.BorderSizePixel = 0
    Instance.new("UICorner", ring2).CornerRadius = UDim.new(1, 0)
    local s2 = Instance.new("UIStroke", ring2)
    s2.Thickness = 1.5
    s2.Color = Color3.fromRGB(255, 255, 255)
    s2.Transparency = 1
    s2.LineJoinMode = Enum.LineJoinMode.Round

    local fill = Instance.new("Frame", sg)
    fill.AnchorPoint = Vector2.new(0.5, 0.5)
    fill.Position = UDim2.fromScale(0.5, 0.5)
    fill.Size = UDim2.fromScale(0.94, 0.94)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BackgroundTransparency = 1
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local fIn = 0
    local prev = os.clock()
    local pulse = 0

    S.RSvc.Heartbeat:Connect(function()
        local now = os.clock()
        local dt = now - prev
        prev = now
        pulse = pulse + dt

        local hrp = S.LP.Character and (S.LP.Character:FindFirstChild("HumanoidRootPart") or S.LP.Character.PrimaryPart)
        local act = S.CFG.parry_on and S.CFG.parry_show_circle and hrp
        if act then
            fIn = math.min(1, fIn + dt * 5)
        else
            fIn = math.max(0, fIn - dt * 5)
        end
        if fIn <= 0.001 then base.Transparency = 1 return end

        if act then
            local hasE = false
            for _, pl in ipairs(S.Players:GetPlayers()) do
                if pl ~= S.LP and pl.Character and S.isKiller(pl) then
                    local er = pl.Character:FindFirstChild("HumanoidRootPart")
                    if er then
                        local hu = pl.Character:FindFirstChildOfClass("Humanoid")
                        if hu and hu.Health > 0 and (er.Position - hrp.Position).Magnitude <= 20 then
                            hasE = true
                            break
                        end
                    end
                end
            end
            local r = 20 * 2
            base.Size = Vector3.new(r, 0.05, r)
            base.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2.95, 0))
            local p = math.sin(pulse * (hasE and 7 or 4)) * (hasE and 0.14 or 0.06)
            s1.Transparency = math.clamp(1 - (fIn * ((hasE and 0.85 or 0.65) + p)), 0, 1)
            s2.Transparency = math.clamp(1 - (fIn * ((hasE and 0.6 or 0.4) + p * 0.6)), 0, 1)
            fill.BackgroundTransparency = math.clamp(1 - (fIn * ((hasE and 0.10 or 0.05) + p * 0.3)), 0, 1)
        else
            s1.Transparency = math.clamp(1 - (fIn * 0.65), 0, 1)
            s2.Transparency = math.clamp(1 - (fIn * 0.4), 0, 1)
            fill.BackgroundTransparency = math.clamp(1 - (fIn * 0.05), 0, 1)
        end
    end)
end

-- Parry Logic
pcall(function()
    local VALID = {
        ["122812055447896"] = 1, ["133963973694098"] = 1, ["117042998468241"] = 1,
        ["135002183282873"] = 1, ["121216847022485"] = 1, ["132817836308238"] = 1,
        ["129784271201071"] = 1, ["82666958311998"]  = 1, ["78432063483146"]  = 1,
        ["118907603246885"] = 1, ["139369275981139"] = 1, ["110355011987939"] = 1,
        ["111920872708571"] = 1, ["105374834496520"] = 1, ["138720291317243"] = 1,
        ["106871536134254"] = 1, ["130593238885843"] = 1, ["115244153053858"] = 1,
        ["74968262036854"]  = 1, ["113255068724446"] = 1, ["98163597193511"]  = 1,
        ["80411309607666"]  = 1, ["101344487600812"] = 1,
    }

    local function root(m)
        return m and (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart)
    end

    local function isKillerModel(m)
        local plr = S.Players:GetPlayerFromCharacter(m)
        if plr then
            if plr == S.LP then return false end
            if plr.Team and plr.Team.Name == "Killer" then return true end
            local r = m:GetAttribute("Role") or plr:GetAttribute("Role")
            if type(r) == "string" and r:lower():find("killer") then return true end
            if plr.Team and plr.Team.Name and plr.Team.Name:lower():find("killer") then return true end
            return false
        end
        local r = m:GetAttribute("Role")
        return type(r) == "string" and r:lower():find("killer") ~= nil
    end

    local function busy()
        local ch = S.LP.Character
        if not ch then return true end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return true end
        for _, a in ipairs({"Knocked", "Downed", "Hooked", "Carried"}) do
            local v = ch:GetAttribute(a)
            if v == true or v == 1 then return true end
        end
        return false
    end

    local PR = S.RC.parry
    local lastFire = 0

    local function doP()
        if not S.CFG.parry_on then return end
        if busy() then return end
        local n = os.clock()
        if n - lastFire < 0.015 then return end
        lastFire = n

        if PR then
            pcall(function() PR:FireServer() end)
            pcall(function() PR:FireServer(2) end)
        end

        pcall(function()
            local sv = S.PG:FindFirstChild("Survivor-mob")
            if not sv then return end
            local c = sv:FindFirstChild("Controls")
            if not c then return end
            local b = c:FindFirstChild("Gui-mob") or c:FindFirstChildWhichIsA("ImageButton")
            if b and typeof(firesignal) == "function" then
                firesignal(b.MouseButton1Down)
                firesignal(b.MouseButton1Up)
            end
        end)
    end
    _G.KZ_ManualParry = doP

    local function distTo(m)
        local a = root(S.LP.Character)
        local b = root(m)
        if not a or not b then return 99999 end
        return (a.Position - b.Position).Magnitude
    end

    local Attached = {}

    local function bindParry(m)
        if not m or Attached[m] then return end
        if not isKillerModel(m) then return end
        if not m:FindFirstChildOfClass("Humanoid") then return end
        Attached[m] = true

        local h = m:FindFirstChildOfClass("Humanoid")
        local an = h:FindFirstChildOfClass("Animator")
        if not an then
            for _ = 1, 30 do
                task.wait(0.1)
                an = h:FindFirstChildOfClass("Animator")
                if an or not m.Parent then break end
            end
        end
        if not an then return end

        an.AnimationPlayed:Connect(function(t)
            if not S.CFG.parry_on or not t or not t.Animation then return end
            local id = tostring(t.Animation.AnimationId or ""):match("%d+") or ""
            if not VALID[id] then return end

            doP()

            local conn
            conn = S.RSvc.Heartbeat:Connect(function()
                if not S.CFG.parry_on or not t.IsPlaying then
                    if conn then conn:Disconnect() end
                    return
                end
                local d = distTo(m)
                if d > 0 and d <= (S.CFG.parry_radius or 6000) then
                    doP()
                end
            end)
            t.Stopped:Connect(function()
                if conn then conn:Disconnect() end
            end)
            task.delay(3, function()
                if conn then pcall(function() conn:Disconnect() end) end
            end)
        end)
    end

    local function scanAll()
        for _, o in ipairs(S.Workspace:GetDescendants()) do
            if o:IsA("Model") and o:FindFirstChildOfClass("Humanoid") then
                pcall(bindParry, o)
            end
        end
    end

    scanAll()

    local bound = {}
    local function bindPlayer(p)
        if bound[p] then return end
        bound[p] = true
        p.CharacterAdded:Connect(function(c)
            Attached[c] = nil
            task.wait(0.3)
            if isKillerModel(c) then bindParry(c) end
        end)
    end

    for _, p in ipairs(S.Players:GetPlayers()) do
        if p ~= S.LP then bindPlayer(p) end
    end
    S.Players.PlayerAdded:Connect(function(p)
        bindPlayer(p)
        task.wait(1)
        if p.Character then bindParry(p.Character) end
    end)

    task.spawn(function()
        while S.LP.Parent do
            task.wait(0.4)
            scanAll()
        end
    end)

    S.UIS.InputBegan:Connect(function(i, g)
        if g then return end
        if i.KeyCode == Enum.KeyCode.P then doP() end
    end)
end)

print("[KZ] auto-parry loaded")
