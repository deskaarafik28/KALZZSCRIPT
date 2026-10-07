-- === Alert.lua ===
Register("Alert", function(S)
    local P, LP, PG = S.P, S.LP, S.PG
    local WS = S.WS
    local CFG, Sched = S.CFG, S.Sched
    local rtp, isKiller = S.rtp, S.isKiller

    pcall(function()
        -- ─── ScreenGui ───
        local ag = Instance.new("ScreenGui")
        ag.Name = "KZ_Alert"
        ag.ResetOnSpawn = false
        ag.IgnoreGuiInset = true
        ag.DisplayOrder = 1000001
        ag.Parent = PG

        -- ─── Big warning text ───
        local al = Instance.new("TextLabel", ag)
        al.Size = UDim2.fromOffset(260, 60)
        al.Position = UDim2.new(0.5, -130, 0.14, 0)
        al.BackgroundTransparency = 1
        al.Text = ""
        al.TextColor3 = Color3.fromRGB(240, 210, 140)
        al.Font = Enum.Font.GothamBlack
        al.TextSize = 34
        al.TextStrokeTransparency = 0
        al.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        al.Visible = false
        al.ZIndex = 10

        -- ─── Sub text (distance) ───
        local as = Instance.new("TextLabel", ag)
        as.Size = UDim2.fromOffset(260, 16)
        as.Position = UDim2.new(0.5, -130, 0.14, 58)
        as.BackgroundTransparency = 1
        as.Text = ""
        as.TextColor3 = Color3.fromRGB(230, 230, 240)
        as.Font = Enum.Font.GothamBold
        as.TextSize = 11
        as.TextStrokeTransparency = 0.3
        as.Visible = false
        as.ZIndex = 10

        -- ─── Alert loop (5 Hz) ───
        Sched:Add("Alert", function()
            if not CFG.alert then
                al.Visible = false
                as.Visible = false
                return
            end

            local mr = rtp(LP.Character)
            if not mr then
                al.Visible = false
                as.Visible = false
                return
            end

            -- Find closest killer
            local cl = math.huge
            for _, pl in ipairs(P:GetPlayers()) do
                if pl ~= LP and pl.Character then
                    local ch = pl.Character
                    local hrp = rtp(ch)
                    if hrp and isKiller(ch) then
                        local hu = ch:FindFirstChildOfClass("Humanoid")
                        if hu and hu.Health > 0 then
                            local d = (hrp.Position - mr.Position).Magnitude
                            if d < cl then cl = d end
                        end
                    end
                end
            end

            if cl < math.huge then
                local t, c
                if cl <= 10 then
                    t = "!!!"
                    c = Color3.fromRGB(255, 90, 90)
                elseif cl <= 17 then
                    t = "!!"
                    c = Color3.fromRGB(255, 160, 100)
                elseif cl <= 25 then
                    t = "!"
                    c = Color3.fromRGB(255, 220, 130)
                else
                    al.Visible = false
                    as.Visible = false
                    return
                end

                al.Text = t
                al.TextColor3 = c
                al.Visible = true

                as.Text = string.format("KILLER %.1f studs", cl)
                as.Visible = true
            else
                al.Visible = false
                as.Visible = false
            end
        end, 5)

    end)

    -- ─── API ───
    return {
        -- kosong
    }
end)
