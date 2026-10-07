-- === StunIndicator.lua ===
Register("StunIndicator", function(S)
    local P, LP, PG = S.P, S.LP, S.PG
    local CFG, Sched = S.CFG, S.Sched
    local rtp, isKiller = S.rtp, S.isKiller
    local cR = S.cR

    pcall(function()
        -- ─── Storage ───
        local stunBB = {}

        -- ─── Stun detection (multi-fallback) ───
        local function isStunned(hum, char)
            if not hum then return false end

            -- 1. WalkSpeed sangat rendah (bukan duduk)
            if hum.WalkSpeed <= 4 and not hum.Sit then return true end

            -- 2. Humanoid state
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Stunned
                or st == Enum.HumanoidStateType.FallingDown
                or st == Enum.HumanoidStateType.Ragdoll then
                return true
            end

            -- 3. Attribute stun (kalau game pakai)
            if char:GetAttribute("Stunned") then return true end
            if char:GetAttribute("stun") then return true end
            if char:GetAttribute("IsStunned") then return true end

            -- 4. Check via Humanoid.PlatformStand (ragdoll indicator)
            if hum.PlatformStand == true then return true end

            return false
        end

        -- ─── Billboard creator ───
        local function createBB(root)
            local bb = Instance.new("BillboardGui")
            bb.Name = "KZ_Stun"
            bb.Size = UDim2.fromOffset(100, 28)
            bb.StudsOffset = Vector3.new(0, 4.2, 0)
            bb.AlwaysOnTop = true
            bb.Adornee = root
            bb.Parent = PG
            bb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

            local bg = Instance.new("Frame", bb)
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            bg.BackgroundTransparency = 0.25
            bg.BorderSizePixel = 0
            cR(bg, 6)

            local stroke = Instance.new("UIStroke", bg)
            stroke.Color = Color3.fromRGB(255, 220, 40)
            stroke.Thickness = 1
            stroke.Transparency = 0.5

            local lbl = Instance.new("TextLabel", bg)
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = "STUNNED"
            lbl.TextColor3 = Color3.fromRGB(255, 220, 40)
            lbl.TextStrokeTransparency = 0.3
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 13

            local barBG = Instance.new("Frame", bg)
            barBG.Size = UDim2.new(0.8, 0, 0, 3)
            barBG.Position = UDim2.new(0.1, 0, 1, -6)
            barBG.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            barBG.BorderSizePixel = 0
            cR(barBG, 999)

            local bar = Instance.new("Frame", barBG)
            bar.Name = "Bar"
            bar.Size = UDim2.new(1, 0, 1, 0)
            bar.BackgroundColor3 = Color3.fromRGB(255, 200, 40)
            bar.BorderSizePixel = 0
            cR(bar, 999)

            return bb
        end

        -- ─── Update loop (10 Hz) ───
        Sched:Add("Stun_Update", function()
            -- Toggle OFF → cleanup all
            if not CFG.stun_indicator then
                for plr, bb in pairs(stunBB) do
                    pcall(function() bb:Destroy() end)
                    stunBB[plr] = nil
                end
                return
            end

            for _, plr in ipairs(P:GetPlayers()) do
                -- Skip: local player / no char / bukan killer
                if plr == LP or not plr.Character or not isKiller(plr.Character) then
                    if stunBB[plr] then
                        pcall(function() stunBB[plr]:Destroy() end)
                        stunBB[plr] = nil
                    end
                else
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")

                    if hum and root then
                        if isStunned(hum, plr.Character) then
                            -- Create if missing
                            if not stunBB[plr] then
                                stunBB[plr] = createBB(root)
                            end

                            -- Animate bar (fake loading)
                            local bar = stunBB[plr]:FindFirstChild("Bar", true)
                            if bar then
                                local t = (os.clock() % 1.2) / 1.2
                                bar.Size = UDim2.new(1 - t, 0, 1, 0)
                            end
                        else
                            -- Remove if no longer stunned
                            if stunBB[plr] then
                                pcall(function() stunBB[plr]:Destroy() end)
                                stunBB[plr] = nil
                            end
                        end
                    end
                end
            end
        end, 10)

        -- ─── Cleanup on leave ───
        P.PlayerRemoving:Connect(function(plr)
            if stunBB[plr] then
                pcall(function() stunBB[plr]:Destroy() end)
                stunBB[plr] = nil
            end
        end)

    end)

    -- ─── API ───
    return {
        -- kosong
    }
end)
