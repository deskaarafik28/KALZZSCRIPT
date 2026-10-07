-- === Visuals.lua ===
Register("Visuals", function(S)
    local L, WS = S.L, S.WS
    local CG, PG = S.CG, S.PG
    local CFG, Sched = S.CFG, S.Sched

    pcall(function()
        -- ─── Bright values (cache) ───
        local BRIGHT = {
            Ambient          = Color3.fromRGB(200, 200, 200),
            Brightness       = 4,
            OutdoorAmbient   = Color3.fromRGB(180, 180, 180),
            GlobalShadows    = false,
            ClockTime        = 14,
        }

        -- ─── No Fog values (cache) ───
        local NO_FOG = {
            FogEnd   = 100000,
            FogStart = 100000,
        }

        -- ─── Apply helpers ───
        local function applyBright()
            pcall(function()
                L.Ambient        = BRIGHT.Ambient
                L.Brightness     = BRIGHT.Brightness
                L.OutdoorAmbient = BRIGHT.OutdoorAmbient
                L.GlobalShadows  = BRIGHT.GlobalShadows
                L.ClockTime      = BRIGHT.ClockTime
            end)
        end

        local function applyNoFog()
            pcall(function()
                L.FogEnd   = NO_FOG.FogEnd
                L.FogStart = NO_FOG.FogStart
            end)
        end

        -- ─── UI Persist helper ───
        local function persistUI()
            pcall(function()
                if S.GUI and not S.GUI.Parent then
                    if gethui then
                        S.GUI.Parent = gethui()
                    else
                        S.GUI.Parent = CG
                    end
                end
            end)
        end

        -- ─── Main loop (1 Hz) ───
        Sched:Add("Visuals_Apply", function()
            if CFG.bright then applyBright() end
            if CFG.fog    then applyNoFog()  end
            persistUI()
        end, 1)

        -- ─── Watchdog (faster — 5 Hz) for lighting changes ───
        Sched:Add("Visuals_Watchdog", function()
            if CFG.bright then
                local c = WS.CurrentCamera
                -- Cek kalau nilainya ke-reset game
                if math.abs(L.Brightness - BRIGHT.Brightness) > 0.01 then
                    applyBright()
                end
            end
            if CFG.fog then
                if L.FogEnd ~= NO_FOG.FogEnd then
                    applyNoFog()
                end
            end
        end, 5)

        -- ─── React to toggle changes (instant apply) ───
        -- Terpanggil dari UI callback: CFG.bright / CFG.fog
        -- Kita poll tiap 0.5s untuk handle toggle
        local lastBright, lastFog = CFG.bright, CFG.fog
        task.spawn(function()
            while true do
                task.wait(0.5)
                if CFG.bright ~= lastBright then
                    lastBright = CFG.bright
                    if CFG.bright then applyBright() end
                end
                if CFG.fog ~= lastFog then
                    lastFog = CFG.fog
                    if CFG.fog then applyNoFog() end
                end
            end
        end)

        -- ─── Apply initial (kalau toggle ON saat load) ───
        if CFG.bright then applyBright() end
        if CFG.fog    then applyNoFog()  end

        -- ─── Anti-respawn wipe ───
        S.LP.CharacterAdded:Connect(function()
            task.wait(0.5)
            if CFG.bright then applyBright() end
            if CFG.fog    then applyNoFog()  end
        end)

    end)

    -- ─── API ───
    return {
        ApplyBright = function() end,
        ApplyNoFog  = function() end,
    }
end)
