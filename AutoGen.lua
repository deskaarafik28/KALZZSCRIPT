-- === AutoGen.lua ===
Register("AutoGen", function(S)
    local P, LP, PG, RS = S.P, S.LP, S.PG, S.RS
    local CFG, Sched = S.CFG, S.Sched

    pcall(function()
        -- ─── Killer Perks remotes ───
        local KS, KE
        local KP = RS:WaitForChild("Remotes", 5)
        if KP then KP = KP:WaitForChild("KillerPerks", 5) end
        if KP then KP = KP:WaitForChild("kingscourge", 5) end
        if KP then
            KS = KP:FindFirstChild("KingScourgeStart")
            KE = KP:FindFirstChild("KingScourgeEnd")
        end

        -- ─── State ───
        local G = { last = 0, busy = false, sa = false, pv = false, lg = nil }
        local R = {}  -- refs cache

        -- ─── Find UI refs ───
        local function rf()
            local sg = PG:FindFirstChild("SkillCheckPromptGui")
            if sg then
                R.Check = sg:FindFirstChild("Check")
                if R.Check then
                    R.Line = R.Check:FindFirstChild("Line")
                    R.Goal = R.Check:FindFirstChild("Goal")
                end
            end
            local sv = PG:FindFirstChild("Survivor-mob")
            if sv then
                local c = sv:FindFirstChild("Controls")
                if c then R.Action = c:FindFirstChild("action") end
            end
        end
        rf()

        -- ─── Trigger skill check ───
        local function tr()
            if not R.Action then rf() end
            if not R.Action then return end
            local n = os.clock()
            if n - G.last < 0.035 then return end
            G.last = n

            pcall(function()
                if R.Action:IsA("GuiButton") then R.Action:Activate() end
            end)

            if typeof(firesignal) == "function" then
                pcall(function()
                    firesignal(R.Action.MouseButton1Down)
                end)
            end
        end

        -- ─── Perfect check ───
        local function pf()
            if not R.Line or not R.Goal then return false end
            local l = tonumber(R.Line.Rotation) or 0
            local g = tonumber(R.Goal.Rotation) or 0
            return l >= g + 102 and l <= g + 116
        end

        -- ─── Instant trigger ───
        local function iN()
            if not R.Check or not R.Line or not R.Goal then rf() end
            if not R.Check or not R.Line or not R.Goal or not R.Check.Visible then return end
            R.Line.Rotation = (tonumber(R.Goal.Rotation) or 0) + 109
            tr()
        end

        -- ─── King Scourge events ───
        if KS then
            KS.OnClientEvent:Connect(function()
                if not CFG.gene_on then return end
                G.sa = true
                G.busy = false
                task.defer(function()
                    if CFG.gene_on and CFG.gene_method == "INSTANT" and R.Line and R.Goal then
                        R.Line.Rotation = (tonumber(R.Goal.Rotation) or 0) + 109
                        tr()
                    end
                end)
            end)
        end
        if KE then
            KE.OnClientEvent:Connect(function()
                G.sa = false
                G.busy = false
            end)
        end

        -- ─── Periodic UI refresh ───
        task.spawn(function()
            while true do
                task.wait(0.5)
                rf()
            end
        end)

        -- ─── Main skill-check loop ───
        Sched:Add("AutoGen", function()
            if not CFG.gene_on then
                G.pv = false
                return
            end

            if not R.Check then rf() end
            if not R.Check then return end

            local v = R.Check.Visible
            if v and not G.pv then
                G.busy = false
                if not G.sa and CFG.gene_method == "INSTANT" then
                    iN()
                end
            end
            G.pv = v

            if v and not G.sa and not G.busy and
                (CFG.gene_method == "PERFECT" or CFG.gene_method == "NORMAL") then
                if pf() then
                    G.busy = true
                    tr()
                    task.delay(0.07, function() G.busy = false end)
                end
            end
        end, 60)

        -- ─── Instant continuous loop (King Scourge INSTANT mode) ───
        task.spawn(function()
            while true do
                task.wait(0.01)
                if CFG.gene_on and G.sa and CFG.gene_method == "INSTANT" then
                    rf()
                    if R.Check and R.Check.Visible and R.Goal and R.Line then
                        local c = tonumber(R.Goal.Rotation) or 0
                        if G.lg == nil then
                            G.lg = c
                            R.Line.Rotation = c + 109
                            tr()
                        elseif math.abs(c - G.lg) > 1 then
                            G.lg = c
                            R.Line.Rotation = c + 109
                            tr()
                        end
                    end
                else
                    G.lg = nil
                end
            end
        end)

    end)

    -- ─── API ───
    return {
        -- kosong (event driven)
    }
end)
