--[[ KALZZSCRIPT | vision.lua ]]

local S = _G.KZ
if not S then return end

pcall(function()
    local changing = false
    local conn
    local function bind()
        if conn then pcall(function() conn:Disconnect() end) end
        local c = S.Workspace.CurrentCamera
        if not c then return end
        conn = c:GetPropertyChangedSignal("FieldOfView"):Connect(function()
            if not S.CFG.fov_lock or changing then return end
            local tgt = tonumber(S.CFG.fov_value) or 120
            if math.abs(c.FieldOfView - tgt) > 0.5 then
                changing = true
                c.FieldOfView = tgt
                changing = false
            end
        end)
    end
    bind()
    S.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        task.wait(0.2)
        bind()
    end)
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if S.CFG.fov_lock then
            local c = S.Workspace.CurrentCamera
            if c and math.abs(c.FieldOfView - (S.CFG.fov_value or 120)) > 0.5 then
                pcall(function() c.FieldOfView = S.CFG.fov_value or 120 end)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if S.CFG.ambient then
            pcall(function()
                S.Lighting.Ambient = Color3.fromRGB(180, 180, 180)
                S.Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
                S.Lighting.Brightness = 3
                S.Lighting.GlobalShadows = false
                S.Lighting.ClockTime = 14
                S.Lighting.FogEnd = 100000
            end)
        end
        if S.CFG.boost_fps then
            pcall(function()
                if setfpscap then setfpscap(240) end
            end)
        end
    end
end)

print("[KZ] vision loaded")
