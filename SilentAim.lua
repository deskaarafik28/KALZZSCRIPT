-- === SilentAim.lua ===
Register("SilentAim", function(S)
    local P, LP, WS, UIS = S.P, S.LP, S.WS, S.UIS
    local CFG, Sched = S.CFG, S.Sched
    local CGr, CK = S.CGr, S.CK

    pcall(function()
        -- ─── State ───
        local tof_predict = 2.5
        local aimDir = nil
        _G.KZ_ToFAimDir = nil

        -- ─── Killer check (role/team) ───
        local function isKillerToF(p)
            if not p or p == LP or not p.Character then return false end
            local role = p.Character:GetAttribute("Role") or p:GetAttribute("Role")
            if type(role) == "string" then
                local r = role:lower()
                if r:find("killer") then return true end
                if r:find("survivor") then return false end
            end
            if p.Team and p.Team.Name then
                local t = p.Team.Name:lower()
                if t:find("killer") then return true end
                if t:find("survivor") then return false end
            end
            return false
        end

        -- ─── Muzzle position ───
        local function getMuzzle()
            local char = LP.Character
            if not char then
                return WS.CurrentCamera.CFrame.Position, WS.CurrentCamera.CFrame.LookVector
            end
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                local handle = tool:FindFirstChild("Handle")
                    or tool:FindFirstChild("Gun")
                    or tool:FindFirstChildWhichIsA("BasePart")
                if handle then
                    return handle.Position + handle.CFrame.LookVector * 2, handle.CFrame.LookVector
                end
            end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                return root.Position + Vector3.new(0, 1.4, 0), WS.CurrentCamera.CFrame.LookVector
            end
            return WS.CurrentCamera.CFrame.Position, WS.CurrentCamera.CFrame.LookVector
        end

        -- ─── Select best killer (closest to screen center) ───
        local function getBestRoot()
            local cam = WS.CurrentCamera
            if not cam then return nil end
            local center = cam.ViewportSize / 2
            local best, bestD = nil, CFG.tof_fov or 380

            for _, p in ipairs(P:GetPlayers()) do
                if isKillerToF(p) then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and root then
                        local sp, on = cam:WorldToViewportPoint(root.Position)
                        if on and sp.Z > 0 then
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d < bestD then
                                bestD = d
                                best = root
                            end
                        end
                    end
                end
            end
            return best
        end

        -- ─── Aim loop ───
        Sched:Add("ToF_Aim", function()
            if not CFG.tof_on then
                aimDir = nil
                _G.KZ_ToFAimDir = nil
                return
            end

            local target = getBestRoot()
            if not target then
                aimDir = nil
                _G.KZ_ToFAimDir = nil
                return
            end

            local muzzlePos = getMuzzle()
            local vel = target.AssemblyLinearVelocity or Vector3.zero
            vel = Vector3.new(vel.X, 0, vel.Z)
            local dist = (target.Position - muzzlePos).Magnitude
            local t = math.clamp(dist / 300, 0.03, 0.35)
            local pred = target.Position + vel * t * tof_predict
            local dir = pred - muzzlePos

            if dir.Magnitude > 0.25 then
                aimDir = dir.Unit
            else
                aimDir = nil
            end
            _G.KZ_ToFAimDir = aimDir
        end, 60)

        -- ─── FOV circle visual ───
        local fovCircle, fovOutline
        pcall(function()
            if typeof(Drawing) ~= "table" or not Drawing.new then return end
            fovOutline = Drawing.new("Circle")
            fovOutline.Thickness = 3
            fovOutline.NumSides = 64
            fovOutline.Filled = false
            fovOutline.Color = Color3.new(0, 0, 0)
            fovOutline.Visible = false

            fovCircle = Drawing.new("Circle")
            fovCircle.Thickness = 1.5
            fovCircle.NumSides = 64
            fovCircle.Filled = false
            fovCircle.Visible = false
        end)

        Sched:Add("ToF_Vis", function()
            if not fovCircle then return end
            local cam = WS.CurrentCamera
            if not cam then
                fovCircle.Visible = false
                fovOutline.Visible = false
                return
            end

            if CFG.tof_on then
                local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                local col = aimDir and CGr or CK
                fovCircle.Position = center
                fovCircle.Radius = CFG.tof_fov or 380
                fovCircle.Color = col
                fovCircle.Transparency = 0.75
                fovCircle.Visible = true

                fovOutline.Position = center
                fovOutline.Radius = (CFG.tof_fov or 380) + 1.5
                fovOutline.Transparency = 0.4
                fovOutline.Visible = true
            else
                fovCircle.Visible = false
                fovOutline.Visible = false
            end
        end, 30)

        -- ─── Hotkey toggle (V) ───
        UIS.InputBegan:Connect(function(i, g)
            if g then return end
            if i.KeyCode == Enum.KeyCode.V then
                CFG.tof_on = not CFG.tof_on
                if S.SaveConfig then S.SaveConfig() end
            end
        end)

        -- ─── Reset on respawn ───
        LP.CharacterAdded:Connect(function()
            aimDir = nil
            _G.KZ_ToFAimDir = nil
        end)

        -- Note: hook intercept ada di Unified Hook (main.lua / standalone hook module)
    end)

    -- ─── API ───
    return {
        GetAimDir = function() return _G.KZ_ToFAimDir end,
        SetPredict = function(v) tof_predict = v end,
    }
end)
