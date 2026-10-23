-- ============================================================
-- CAMERA EDGE LOGIC (DARI SCRIPT LU)
-- ============================================================
local curOffset = Vector3.zero

RunService.RenderStepped:Connect(function(dt)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    if not hum or not cam then return end

    -- Cek apakah fitur "Mentok Tepi" di-ON-in dari UI
    if CFG.cam_edge then
        -- Paksa FOV & Zoom
        if math.abs(cam.FieldOfView - (CFG.fov_value or 110)) > 0.3 then
            cam.FieldOfView = CFG.fov_value or 110
        end
        if LP.CameraMaxZoomDistance < (CFG.zoom_max or 22) then
            LP.CameraMaxZoomDistance = CFG.zoom_max or 22
        end

        -- Logika Geser Karakter
        local move = hum.MoveDirection
        local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
        local side = 0
        if right.Magnitude > 0.01 and move.Magnitude > 0.04 then
            side = move:Dot(right.Unit)
        end

        local target = Vector3.new(
            side * (CFG.edge_x or 3.8),
            CFG.edge_y or -2.6,
            0
        )
        local a = math.clamp((CFG.edge_smooth or 0.18) * 60 * dt, 0.08, 0.55)
        curOffset = curOffset:Lerp(target, a)
        hum.CameraOffset = curOffset
    else
        -- Kalau di-Off-in, balikin kamera ke tengah perlahan
        if curOffset.Magnitude > 0.01 then
            curOffset = curOffset:Lerp(Vector3.zero, 0.1)
            hum.CameraOffset = curOffset
        end
    end
end)
