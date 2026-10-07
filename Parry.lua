-- === Parry.lua ===
Register("Parry", function(S)
    local P, LP, PG = S.P, S.LP, S.PG
    local RS, WS, UIS = S.RS, S.WS, S.UIS
    local CFG, Sched = S.CFG, S.Sched
    local PID = S.PID
    local rtp, isKiller = S.rtp, S.isKiller
    local cR = S.cR

    pcall(function()
        -- ─── Remote ───
        local PR
        pcall(function()
            PR = RS.Remotes.Items["Parrying Dagger"].parry
        end)

        -- ─── State ───
        local lastParry = 0
        local busyAnim = false
        local AttachedP = {}

        -- ─── Busy watcher (vault/window/pallet/drop) ───
        local function setupBusy(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local anim = hum:FindFirstChildOfClass("Animator")
            if not anim then return end
            anim.AnimationPlayed:Connect(function(t)
                if not t or not t.Animation then return end
                local n = (t.Animation.Name or ""):lower()
                if n:find("vault") or n:find("window") or n:find("pallet") or n:find("drop") then
                    busyAnim = true
                    task.delay(0.85, function() busyAnim = false end)
                end
            end)
        end

        -- ─── Do parry ───
        local function doParry()
            if busyAnim then return end
            local now = os.clock()
            local cd = CFG.parry_aggro and 0.05 or 0.11
            if now - lastParry < cd then return end
            lastParry = now

            -- Fire remote multiple times
            if PR then
                for i = 1, 3 do
                    pcall(function() PR:FireServer() end)
                    if i < 3 then task.wait(0.005) end
                end
            end

            -- Mobile button fallback
            pcall(function()
                local mob = PG:FindFirstChild("Survivor-mob")
                if mob then
                    local controls = mob:FindFirstChild("Controls")
                    if controls then
                        local btn = controls:FindFirstChild("Gui-mob")
                            or controls:FindFirstChild("action")
                            or controls:FindFirstChildWhichIsA("ImageButton")
                        if btn and typeof(firesignal) == "function" then
                            firesignal(btn.MouseButton1Down)
                            task.wait(0.006)
                            firesignal(btn.MouseButton1Up)
                        end
                    end
                end
            end)
        end

        -- ─── Distance helper ───
        local function getDist(m)
            local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local en = m and m:FindFirstChild("HumanoidRootPart")
            if not my or not en then return 999 end
            return (my.Position - en.Position).Magnitude
        end

        -- ─── Bind animation listener ───
        local function bind(m)
            if not m or AttachedP[m] then return end
            AttachedP[m] = true

            local hum = m:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local anim = hum:FindFirstChildOfClass("Animator")
            if not anim then
                task.delay(0.35, function()
                    AttachedP[m] = nil
                    bind(m)
                end)
                return
            end

            anim.AnimationPlayed:Connect(function(t)
                if not CFG.parry_on or busyAnim then return end
                if not t or not t.Animation then return end
                local id = tostring(t.Animation.AnimationId or ""):match("%d+") or ""
                if not PID[id] then return end
                local d = getDist(m)
                local maxR = CFG.parry_radius or 14
                if d > 0 and d <= maxR + (CFG.parry_sensitive or 200) * 0.01 then
                    doParry()
                end
            end)
        end

        -- ─── Scan players ───
        local function scan()
            for _, plr in ipairs(P:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    bind(plr.Character)
                end
            end
        end
        scan()
        task.spawn(function()
            while true do
                task.wait(1.5)
                scan()
            end
        end)

        WS.DescendantAdded:Connect(function(o)
            if o:IsA("Model") and o ~= LP.Character then
                task.wait(0.25)
                bind(o)
            end
        end)

        -- ─── Multi-anim loop (GetPlayingAnimationTracks) ───
        Sched:Add("Parry_MultiAnim", function()
            if not CFG.parry_on then return end
            for _, plr in ipairs(P:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    local anim = hum and hum:FindFirstChildOfClass("Animator")
                    if anim then
                        local ok, tracks = pcall(function() return anim:GetPlayingAnimationTracks() end)
                        if ok and tracks then
                            for _, t in ipairs(tracks) do
                                if t and t.Animation then
                                    local id = tostring(t.Animation.AnimationId or ""):match("(%d+)") or ""
                                    if PID[id] then
                                        local d = getDist(plr.Character)
                                        if d > 0 and d <= (CFG.parry_radius or 12) + 2 then
                                            doParry()
                                            return
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end, 20)

        -- ─── Character respawn ───
        LP.CharacterAdded:Connect(function(c)
            task.wait(1)
            setupBusy(c)
        end)
        if LP.Character then
            task.spawn(function() setupBusy(LP.Character) end)
        end

        -- ─── Manual hotkey (P) ───
        UIS.InputBegan:Connect(function(i, g)
            if g then return end
            if i.KeyCode == Enum.KeyCode.P then doParry() end
        end)

        -- ─── Parry Circle (visual) ───
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
        base.Parent = WS

        local sg = Instance.new("SurfaceGui", base)
        sg.Face = Enum.NormalId.Top
        sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        sg.PixelsPerStud = 40
        sg.LightInfluence = 0
        sg.ZOffset = 1

        local fill = Instance.new("Frame", sg)
        fill.AnchorPoint = Vector2.new(0.5, 0.5)
        fill.Position = UDim2.fromScale(0.5, 0.5)
        fill.Size = UDim2.fromScale(0.94, 0.94)
        fill.BackgroundColor3 = Color3.fromRGB(100, 140, 230)
        fill.BackgroundTransparency = 1
        fill.BorderSizePixel = 0
        cR(fill, 999)

        local ring = Instance.new("Frame", sg)
        ring.AnchorPoint = Vector2.new(0.5, 0.5)
        ring.Position = UDim2.fromScale(0.5, 0.5)
        ring.Size = UDim2.fromScale(0.96, 0.96)
        ring.BackgroundTransparency = 1
        ring.BorderSizePixel = 0
        cR(ring, 999)

        local s1 = Instance.new("UIStroke", ring)
        s1.Thickness = 5
        s1.Color = Color3.fromRGB(100, 140, 230)
        s1.Transparency = 1
        s1.LineJoinMode = Enum.LineJoinMode.Round

        local ring2 = Instance.new("Frame", sg)
        ring2.AnchorPoint = Vector2.new(0.5, 0.5)
        ring2.Position = UDim2.fromScale(0.5, 0.5)
        ring2.Size = UDim2.fromScale(0.88, 0.88)
        ring2.BackgroundTransparency = 1
        ring2.BorderSizePixel = 0
        cR(ring2, 999)

        local s2 = Instance.new("UIStroke", ring2)
        s2.Thickness = 2
        s2.Color = Color3.fromRGB(180, 210, 255)
        s2.Transparency = 1
        s2.LineJoinMode = Enum.LineJoinMode.Round

        local SC = Color3.fromRGB(100, 140, 230)
        local DC = Color3.fromRGB(230, 90, 90)
        local curC, fIn, pl2 = SC, 0, 0

        local function getR(m)
            if not m then return nil end
            return m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
        end

        local prev = os.clock()
        Sched:Add("Parry_Circle", function()
            local now = os.clock()
            local dt = now - prev
            prev = now
            pl2 = pl2 + dt

            local hrp = LP.Character and getR(LP.Character)
            local act = CFG.parry_on and CFG.parry_circle and hrp
            if act then
                fIn = math.min(1, fIn + dt * 5)
            else
                fIn = math.max(0, fIn - dt * 5)
            end
            if fIn <= 0.001 then
                base.Transparency = 1
                return
            end

            if act then
                -- Check enemy nearby
                local hasE = false
                for _, pl in ipairs(P:GetPlayers()) do
                    if pl ~= LP and pl.Character and isKiller(pl.Character) then
                        local er = getR(pl.Character)
                        if er then
                            local hu = pl.Character:FindFirstChildOfClass("Humanoid")
                            if hu and hu.Health > 0 and (er.Position - hrp.Position).Magnitude <= CFG.parry_radius then
                                hasE = true
                                break
                            end
                        end
                    end
                end

                curC = curC:Lerp(hasE and DC or SC, math.min(1, dt * 8))
                local r = CFG.parry_radius * 2
                base.Size = Vector3.new(r, 0.05, r)
                base.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2.95, 0))

                local pa = hasE and 0.14 or 0.06
                local pf2 = hasE and 7 or 4
                local p = math.sin(pl2 * pf2) * pa

                s1.Color = curC
                s2.Color = curC:Lerp(Color3.fromRGB(255, 255, 255), 0.5)
                fill.BackgroundColor3 = curC

                s1.Transparency = math.clamp(1 - (fIn * ((hasE and 0.88 or 0.72) + p)), 0, 1)
                s2.Transparency = math.clamp(1 - (fIn * ((hasE and 0.65 or 0.42) + p * 0.6)), 0, 1)
                fill.BackgroundTransparency = math.clamp(1 - (fIn * ((hasE and 0.08 or 0.05) + p * 0.3)), 0, 1)
            else
                s1.Transparency = math.clamp(1 - (fIn * 0.72), 0, 1)
                s2.Transparency = math.clamp(1 - (fIn * 0.42), 0, 1)
                fill.BackgroundTransparency = math.clamp(1 - (fIn * 0.05), 0, 1)
            end
        end, 60)

    end)

    -- ─── API ───
    return {
        Parry = function() end,  -- manual trigger nanti
    }
end)
