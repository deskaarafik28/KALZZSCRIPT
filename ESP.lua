-- === ESP.lua ===
Register("ESP", function(S)
    local P, LP, WS = S.P, S.LP, S.WS
    local CFG, Sched = S.CFG, S.Sched
    local rtp, isKiller = S.rtp, S.isKiller
    local CK, CS, CGr = S.CK, S.CS, S.CGr

    pcall(function()
        -- ─── Storage ───
        local eD = {}   -- player ESP dict
        local eG = {}   -- generator ESP dict

        -- ─── Get ESP GUI parent ───
        -- Priority: gethui > CoreGui > PlayerGui
        local ep
        pcall(function()
            if gethui then ep = gethui() end
        end)
        if not ep then
            ep = game:GetService("CoreGui")
            if not pcall(function() return ep.Name end) then
                ep = S.PG
            end
        end

        -- ─── Cleanup player ESP ───
        local function dESP(pl)
            local d = eD[pl]
            if not d then return end
            pcall(function()
                if d.hl then d.hl:Destroy() end
            end)
            eD[pl] = nil
        end

        -- ─── Generator checks ───
        local function isGD(o)
            local p = o:FindFirstChild("Progress") or o:GetAttribute("Progress")
            if typeof(p) == "number" and p >= 100 then return true end
            if o:GetAttribute("Completed") or o:GetAttribute("Finished") then return true end
            return false
        end

        local function isG(o)
            if not o or not o.Parent then return false end
            if not (o:IsA("Model") or o:IsA("BasePart")) then return false end
            local n = o.Name:lower()
            return n:find("generator") or n:find("fuse")
        end

        -- ─── Player ESP loop ───
        Sched:Add("ESP_Players", function()
            local mr = rtp(LP.Character)
            local mp = mr and mr.Position or WS.CurrentCamera.CFrame.Position

            for _, pl in ipairs(P:GetPlayers()) do
                if pl ~= LP and pl.Character then
                    local ch = pl.Character
                    local hrp = rtp(ch)
                    local hum = ch:FindFirstChildOfClass("Humanoid")

                    if hrp and hum and hum.Health > 0 then
                        local isK = isKiller(ch)
                        local en = (isK and CFG.esp_k) or (not isK and CFG.esp_s)

                        if en and (hrp.Position - mp).Magnitude <= CFG.esp_range then
                            if not eD[pl] then
                                local hl = Instance.new("Highlight")
                                hl.Name = "KZ_HL"
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = ep
                                eD[pl] = { hl = hl }
                            end

                            local d = eD[pl]
                            local cl = isK and CK or CS

                            d.hl.Adornee = ch
                            d.hl.FillColor = cl
                            d.hl.OutlineColor = cl
                            d.hl.FillTransparency = CFG.esp_out and 1 or 0.55
                            d.hl.OutlineTransparency = 0
                            d.hl.Enabled = true
                        else
                            if eD[pl] and eD[pl].hl then
                                eD[pl].hl.Enabled = false
                            end
                        end
                    else
                        dESP(pl)
                    end
                elseif eD[pl] then
                    dESP(pl)
                end
            end
        end, 5)

        -- ─── Generator ESP (cached scan) ───
        local genCache, genT = {}, 0

        Sched:Add("ESP_Gen", function()
            local now = os.clock()

            -- Refresh cache tiap 5 detik
            if now - genT > 5 then
                genCache = {}
                for _, o in ipairs(WS:GetDescendants()) do
                    if isG(o) then
                        table.insert(genCache, o)
                    end
                end
                genT = now
            end

            if CFG.esp_g then
                -- Ensure highlight exists
                for _, o in ipairs(genCache) do
                    if o.Parent then
                        if isGD(o) then
                            if eG[o] then
                                pcall(function() eG[o]:Destroy() end)
                                eG[o] = nil
                            end
                        elseif not eG[o] then
                            local hl = Instance.new("Highlight")
                            hl.Name = "KZ_GEN"
                            hl.Adornee = o
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.FillColor = CGr
                            hl.FillTransparency = CFG.esp_out and 1 or 0.6
                            hl.OutlineColor = CGr
                            hl.OutlineTransparency = 0
                            hl.Parent = ep
                            eG[o] = hl
                        end
                    end
                end

                -- Cleanup completed/destroyed
                for o, hl in pairs(eG) do
                    if not o.Parent or isGD(o) then
                        pcall(function() hl:Destroy() end)
                        eG[o] = nil
                    end
                end
            else
                -- Toggle off → destroy all
                for _, hl in pairs(eG) do
                    pcall(function() hl:Destroy() end)
                end
                eG = {}
            end
        end, 2)

        -- ─── Cleanup on player leave ───
        P.PlayerRemoving:Connect(function(p) dESP(p) end)

        -- ─── Cleanup on respawn ───
        LP.CharacterRemoving:Connect(function()
            for pl, d in pairs(eD) do
                pcall(function()
                    if d.hl then d.hl:Destroy() end
                end)
            end
            eD = {}
        end)

    end)

    -- ─── API ───
    return {
        -- kosong (loop-based)
    }
end)
