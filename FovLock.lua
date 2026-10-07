-- === FOVLock.lua ===
Register("FOVLock", function(S)
    local WS = S.WS
    local CFG, Sched = S.CFG, S.Sched

    pcall(function()
        -- ─── Core FOV apply function ───
        local function applyFOV()
            pcall(function()
                if not CFG.cam then return end
                local c = WS.CurrentCamera
                if not c or not c.Parent then return end
                local target = CFG.camv or 90
                -- Precision 0.01 → update tiap kali ada drift
                if math.abs(c.FieldOfView - target) > 0.01 then
                    c.FieldOfView = target
                end
            end)
        end

        -- ─── Main loop (30 Hz via Sched) ───
        Sched:Add("FOV_Lock", applyFOV, 30)

        -- ─── Watch camera change (respawn/cutscene/load) ───
        WS:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            task.wait(0.05)
            applyFOV()
        end)

        -- ─── Watch FieldOfView change ───
        -- Kalau game ubah FOV (cutscene/zoom), paksa balik ke target
        task.spawn(function()
            local attached = {}
            while true do
                task.wait(0.5)
                local c = WS.CurrentCamera
                if c and not attached[c] then
                    attached[c] = true
                    pcall(function()
                        c:GetPropertyChangedSignal("FieldOfView"):Connect(function()
                            if not CFG.cam then return end
                            local target = CFG.camv or 90
                            if math.abs(c.FieldOfView - target) > 0.01 then
                                c.FieldOfView = target
                            end
                        end)
                    end)
                end
            end
        end)

        -- ─── Apply on respawn (multiple tries) ───
        S.LP.CharacterAdded:Connect(function()
            task.wait(0.3); applyFOV()
            task.wait(0.7); applyFOV()
            task.wait(1.5); applyFOV()
            task.wait(3.0); applyFOV()
        end)

        -- ─── Apply on initial ───
        if S.LP.Character then
            task.spawn(function()
                task.wait(0.3); applyFOV()
                task.wait(0.7); applyFOV()
            end)
        end

        -- ─── Apply on any game load event ───
        -- Cek tiap 2 detik — kalau camera baru & FOV beda, paksa
        Sched:Add("FOV_Watchdog", function()
            if not CFG.cam then return end
            local c = WS.CurrentCamera
            if not c then return end
            local target = CFG.camv or 90
            if math.abs(c.FieldOfView - target) > 0.5 then
                c.FieldOfView = target
            end
        end, 0.5)

    end)

    -- ─── API ───
    return {
        Apply = function() end,  -- expose jika perlu
    }
end)
