-- SILENT AIM ToF — CLOSE + FAR FIXED
-- dekat: zero/minim lead • jauh: multi-sample predict
local S = _G.KZ
if not S then return end

local LP      = S.LP
local Players = S.Players
local RSvc    = S.RSvc
local CFG     = _G.KALZZ_CFG or {}

_G.KZ_ToFAimDir = nil

-- ⭐ FIX TYPO: Hapus backslash
CFG.tof_on            = CFG.tof_on            ~= false
CFG.tof_fov           = CFG.tof_fov           or 360
CFG.tof_maxdist       = CFG.tof_maxdist       or 1000
CFG.tof_predict       = CFG.tof_predict       or 3.15
CFG.tof_laser         = CFG.tof_laser         ~= false
CFG.tof_show_fov      = CFG.tof_show_fov      ~= false
CFG.tof_smooth        = CFG.tof_smooth        or 0.08
CFG.tof_height_offset = CFG.tof_height_offset or 0.12
CFG.tof_air_predict   = CFG.tof_air_predict   or 1.45
CFG.tof_sticky_time   = CFG.tof_sticky_time   or 0.55
CFG.tof_sample_count  = CFG.tof_sample_count  or 6
_G.KALZZ_CFG = CFG

local velHist, posHist = {}, {}
local hold, a0, a1, beam
local lastAimDir, lastTarget, lastLockTime = nil, nil, 0

local function getRoot(c)
    return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
end
local function flat(v) return Vector3.new(v.X, 0, v.Z) end
local function safeUnit(v)
    local m = v.Magnitude
    return m < 1e-4 and Vector3.zero or v / m
end
local function clampMag(v, max)
    local m = v.Magnitude
    return (m > max and m > 0) and v * (max / m) or v
end

local function isKnock()
    local ch = LP.Character
    if not ch then return false end
    return ch:GetAttribute("Knocked") or ch:GetAttribute("Downed")
        or ch:GetAttribute("Carried") or ch:GetAttribute("IsCarried")
end

local function isValidChar(ch)
    if not ch then return false end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local root = getRoot(ch)
    return hum and root and hum.Health > 0
end

local function getOrigin()
    local ch = LP.Character
    local Cam = workspace.CurrentCamera
    if not Cam then return Vector3.zero end
    if isKnock() and ch then
        for _, n in ipairs({"RightHand","Right Arm","RightLowerArm","RightUpperArm","LeftHand","Left Arm"}) do
            local p = ch:FindFirstChild(n)
            if p and p:IsA("BasePart") then return p.Position end
        end
    end
    if ch then
        local tool = ch:FindFirstChildOfClass("Tool")
        if tool then
            local h = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
            if h then return h.Position end
        end
        local head = ch:FindFirstChild("Head")
        if head then return head.Position end
        local r = getRoot(ch)
        if r then return r.Position end
    end
    return Cam.CFrame.Position
end

local function getMotion(ch)
    local root = getRoot(ch)
    if not root then return Vector3.zero, 0, false, Vector3.zero end
    local now = os.clock()
    local h = velHist[ch]
    local m = Vector3.zero
    local isAir = false
    local accel = Vector3.zero

    if not posHist[ch] then posHist[ch] = {} end
    local ph = posHist[ch]
    table.insert(ph, {pos = root.Position, t = now})
    while #ph > (CFG.tof_sample_count or 6) + 2 do table.remove(ph, 1) end

    if #ph >= 3 then
        local total, count = Vector3.zero, 0
        for i = 2, #ph do
            local dt = ph[i].t - ph[i-1].t
            if dt > 0.008 and dt < 0.12 then
                total = total + (ph[i].pos - ph[i-1].pos) / dt
                count = count + 1
            end
        end
        if count > 0 then m = total / count end
    end

    if h and (now - h.t) > 0.014 then
        local instant = (root.Position - h.pos) / (now - h.t)
        if instant.Magnitude < 170 then m = m:Lerp(instant, 0.35) end
    end

    local asm = root.AssemblyLinearVelocity
    if typeof(asm) == "Vector3" then
        m = m:Lerp(Vector3.new(asm.X, 0, asm.Z), 0.4)
        if math.abs(asm.Y) > 6.5 then isAir = true end
        if h and h.s then accel = (m - h.s) / math.max(now - h.t, 0.016) end
    end

    local s = (h and h.s or m):Lerp(m, 0.65)
    local zig = 0
    if h and h.lastDir and h.lastDir.Magnitude > 0.5 and s.Magnitude > 1.8 then
        local dot = flat(s).Unit:Dot(flat(h.lastDir).Unit)
        if dot < 0.18 then zig = 1
        elseif dot < 0.38 then zig = 0.55
        elseif dot < 0.55 then zig = 0.25 end
    end

    velHist[ch] = {
        pos = root.Position, t = now, s = s,
        lastDir = s.Magnitude > 1 and s or (h and h.lastDir),
        accel = accel
    }
    return Vector3.new(s.X, 0, s.Z), zig, isAir, accel
end

-- ===== LEAD: DEKAT = HAMPIR 0 • JAUH = PENUH =====
local function getLead(ch, dist, ping, predMult)
    -- DEKAT BANGET: tembak lurus ke HRP (ini yang bikin 5 stud kena)
    if dist <= 8 then
        return Vector3.zero
    end
    if dist <= 14 then
        -- sangat sedikit lead
        local vel = select(1, getMotion(ch))
        local t = (dist / 248) + ping
        return clampMag(vel * t * predMult * 0.08, 1.2)
    end
    if dist <= 22 then
        local vel, zig, isAir, accel = getMotion(ch)
        local t = math.clamp(dist / 248, 0.02, 0.5) + ping
        local lead = vel * t * predMult * 0.32
        if isAir then lead = lead * 1.2 end
        if zig > 0 then lead = lead * (1 - 0.5 * zig) end
        return clampMag(lead, dist * 0.12)
    end

    -- JARAK MENENGAH / JAUH
    local vel, zig, isAir, accel = getMotion(ch)
    local t = math.clamp(dist / 248, 0.014, 0.68)
    local totalT = t + ping
    local lead = vel * totalT * predMult

    if accel and accel.Magnitude > 0.5 then
        lead = lead + accel * totalT * totalT * 0.4
    end
    if isAir then lead = lead * (CFG.tof_air_predict or 1.45) end
    if zig > 0 then lead = lead * (1 - 0.4 * zig) end

    if dist < 45 then
        lead = lead * 0.75
    elseif dist > 200 then
        lead = lead * 1.15
    end

    return clampMag(lead, math.clamp(dist * 0.34, 1, 34))
end

local function getTarget()
    local Cam = workspace.CurrentCamera
    if not Cam then return nil, nil end
    local center = Cam.ViewportSize / 2
    local origin = getOrigin()
    local bestP, bestR, bestS = nil, nil, math.huge
    local fov = CFG.tof_fov or 360
    local maxd = CFG.tof_maxdist or 1000

    for _, p in ipairs(Players:GetPlayers()) do
        if not S.isKiller(p) then continue end
        local ch = p.Character
        if not isValidChar(ch) then continue end
        local root = getRoot(ch)
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not root or not hum then continue end

        local studs = (root.Position - origin).Magnitude
        if studs > maxd then continue end

        local sp, onScreen = Cam:WorldToViewportPoint(root.Position)
        local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude

        -- FOV longgar dekat (biar 5 stud kanan tetap lock)
        local useFov = fov
        if studs < 12 then useFov = 9999
        elseif studs < 25 then useFov = math.max(fov, 1200)
        elseif studs < 50 then useFov = math.max(fov, 600)
        elseif studs < 90 then useFov = math.max(fov, 420) end

        if studs >= 40 then
            if not onScreen or sp.Z <= 0 or sd > useFov then continue end
        else
            -- dekat: boleh sedikit offscreen asal dist oke
            if onScreen and sp.Z > 0 and sd > useFov then continue end
        end

        local score = studs * 0.08 + (sp.Z > 0 and sd or 200)
        if studs < 15 then score = score * 0.12 end   -- prioritaskan dekat
        if studs < 8 then score = score * 0.25 end
        if lastTarget == p and (os.clock() - lastLockTime) < (CFG.tof_sticky_time or 0.55) then
            score = score * 0.55
        end
        if score < bestS then
            bestS, bestP, bestR = score, p, root
        end
    end
    return bestP, bestR
end

local function ensureLaser()
    if hold and hold.Parent then return end
    hold = Instance.new("Part")
    hold.Name = "KZ_ToFLaser"
    hold.Anchored = true
    hold.CanCollide = false
    hold.CanQuery = false
    hold.CanTouch = false
    hold.Transparency = 1
    hold.Size = Vector3.new(0.05, 0.05, 0.05)
    hold.Parent = workspace
    a0 = Instance.new("Attachment", hold)
    a1 = Instance.new("Attachment", hold)
    beam = Instance.new("Beam", hold)
    beam.Attachment0, beam.Attachment1 = a0, a1
    beam.Width0, beam.Width1 = 0.05, 0.02
    beam.LightEmission = 1
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 50, 50))
    
    -- ⭐ FIX TYPO: NumberSequence harus pake Keypoints
    beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.08),
        NumberSequenceKeypoint.new(1, 0.4)
    })
    
    beam.FaceCamera = true
    beam.Enabled = false
end

local function setLaser(from, to, on)
    ensureLaser()
    if not on or not CFG.tof_laser or not CFG.tof_on then
        if beam then beam.Enabled = false end
        return
    end
    hold.CFrame = CFrame.new(from)
    a0.WorldPosition = from
    a1.WorldPosition = to
    beam.Enabled = true
end

local fovGui, fovFrame, fovStroke
local function ensureFov()
    if fovGui and fovGui.Parent then return end
    local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 3)
    if not pg then return end
    fovGui = Instance.new("ScreenGui")
    fovGui.Name = "KZ_ToF_FOV"
    fovGui.IgnoreGuiInset = true
    fovGui.ResetOnSpawn = false
    fovGui.Parent = pg
    fovFrame = Instance.new("Frame", fovGui)
    fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fovFrame.Position = UDim2.fromScale(0.5, 0.5)
    fovFrame.BackgroundTransparency = 1
    fovStroke = Instance.new("UIStroke", fovFrame)
    fovStroke.Thickness = 1.5
    fovStroke.Color = Color3.fromRGB(255, 50, 50)
    Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1, 0)
end

local function updateFovDraw(locked)
    if not CFG.tof_show_fov then
        if fovGui then fovGui.Enabled = false end
        return
    end
    ensureFov()
    if not fovGui then return end
    fovGui.Enabled = CFG.tof_on
    local r = CFG.tof_fov or 360
    fovFrame.Size = UDim2.fromOffset(r * 2, r * 2)
    fovStroke.Color = locked and Color3.fromRGB(50, 255, 90) or Color3.fromRGB(255, 50, 50)
end

RSvc.RenderStepped:Connect(function()
    if not CFG.tof_on then
        _G.KZ_ToFAimDir = nil
        lastAimDir = nil
        setLaser(nil, nil, false)
        updateFovDraw(false)
        return
    end

    local killer, root = getTarget()
    local origin = getOrigin()

    if not killer or not root or not isValidChar(killer.Character) then
        _G.KZ_ToFAimDir = nil
        lastAimDir = nil
        setLaser(nil, nil, false)
        updateFovDraw(false)
        lastTarget = nil
        return
    end

    lastTarget = killer
    lastLockTime = os.clock()

    local aimPos = root.Position + Vector3.new(0, CFG.tof_height_offset or 0.12, 0)
    local dist = (aimPos - origin).Magnitude

    local ping = 0.035
    pcall(function() ping = math.clamp(LP:GetNetworkPing(), 0, 0.25) end)

    local lead = getLead(killer.Character, dist, ping, CFG.tof_predict or 3.15)
    local finalPos = aimPos + lead
    local dir = finalPos - origin
    if dir.Magnitude < 0.02 then
        _G.KZ_ToFAimDir = nil
        setLaser(nil, nil, false)
        return
    end

    local unitDir = safeUnit(dir)

    -- dekat: JANGAN smooth (biar tidak meleset ke kanan/kiri)
    if dist > 18 and CFG.tof_smooth and CFG.tof_smooth > 0 and lastAimDir then
        unitDir = safeUnit(lastAimDir:Lerp(unitDir, 1 - math.clamp(CFG.tof_smooth, 0, 0.3)))
    end

    lastAimDir = unitDir
    _G.KZ_ToFAimDir = unitDir
    setLaser(origin, aimPos, true)  -- laser ke HRP asli
    updateFovDraw(true)
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.4)
    lastAimDir = nil
    _G.KZ_ToFAimDir = nil
end)

print("[KZ] ToF CLOSE+FAR | ≤8stud pure HRP | jauh predict penuh")
