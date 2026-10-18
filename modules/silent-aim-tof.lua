-- SILENT AIM ToF — Violence District | HRP ONLY | Max Precision + Clean Prediction
-- No Hook | Sticky | Advanced Multi-Sample Prediction | Updated Oct 2026
local S = _G.KZ
if not S then return end

local LP      = S.LP
local Players = S.Players
local RSvc    = S.RSvc
local CFG     = _G.KALZZ_CFG or {}

_G.KZ_ToFAimDir = nil

-- ====================== CONFIG (HRP Optimized) ======================
CFG.tof_on              = CFG.tof_on              ~= false
CFG.tof_fov             = CFG.tof_fov             or 360
CFG.tof_maxdist         = CFG.tof_maxdist         or 1000
CFG.tof_predict         = CFG.tof_predict         or 3.15      -- lebih agresif
CFG.tof_laser           = CFG.tof_laser           ~= false
CFG.tof_show_fov        = CFG.tof_show_fov        ~= false
CFG.tof_smooth          = CFG.tof_smooth          or 0.11      -- lebih responsif
CFG.tof_height_offset   = CFG.tof_height_offset   or 0.08      -- HRP center
CFG.tof_air_predict     = CFG.tof_air_predict     or 1.55
CFG.tof_close_mult      = CFG.tof_close_mult      or 0.14
CFG.tof_mid_mult        = CFG.tof_mid_mult        or 0.48
CFG.tof_sticky_time     = CFG.tof_sticky_time     or 0.68
CFG.tof_sample_count    = CFG.tof_sample_count    or 6         -- multi sample

-- ====================== STATE ======================
local velHist   = {}
local posHist   = {}
local hold, a0, a1, beam
local lastAimDir = nil
local lastTarget = nil
local lastLockTime = 0
local lastRootPos = nil

-- ====================== UTILS ======================
local function getRoot(c)
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
end

local function flat(v)
    return Vector3.new(v.X, 0, v.Z)
end

local function safeUnit(v)
    local m = v.Magnitude
    if m < 1e-4 then return Vector3.zero end
    return v / m
end

local function clampMag(v, max)
    local m = v.Magnitude
    if m > max and m > 0 then return v * (max / m) end
    return v
end

local function isKnock()
    local ch = LP.Character
    if not ch then return false end
    return ch:GetAttribute("Knocked")
        or ch:GetAttribute("Downed")
        or ch:GetAttribute("Carried")
        or ch:GetAttribute("IsCarried")
        or ch:GetAttribute("Stunned")
end

local function isValidChar(ch)
    if not ch then return false end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local root = getRoot(ch)
    return hum and root and hum.Health > 0 and hum.Parent
end

-- ====================== ORIGIN ======================
local function getOrigin()
    local ch = LP.Character
    local Cam = workspace.CurrentCamera
    if not Cam then return Vector3.zero end

    if isKnock() and ch then
        local order = {"RightHand","Right Arm","RightLowerArm","RightUpperArm","LeftHand","Left Arm","LeftLowerArm"}
        for _, n in ipairs(order) do
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

-- ====================== MULTI-SAMPLE MOTION (lebih cakep) ======================
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

    -- Multi-sample velocity (lebih stabil & akurat)
    if #ph >= 3 then
        local totalVel = Vector3.zero
        local count = 0
        for i = 2, #ph do
            local dt = ph[i].t - ph[i-1].t
            if dt > 0.008 and dt < 0.12 then
                totalVel = totalVel + (ph[i].pos - ph[i-1].pos) / dt
                count = count + 1
            end
        end
        if count > 0 then
            m = totalVel / count
        end
    end

    if h and (now - h.t) > 0.014 then
        local dt = now - h.t
        local instant = (root.Position - h.pos) / dt
        if instant.Magnitude < 170 then
            m = m:Lerp(instant, 0.35)
        end
    end

    -- Blend AssemblyLinearVelocity
    local asm = root.AssemblyLinearVelocity
    if typeof(asm) == "Vector3" then
        local flatAsm = Vector3.new(asm.X, 0, asm.Z)
        m = m:Lerp(flatAsm, 0.38)
        if math.abs(asm.Y) > 6.5 then isAir = true end

        -- Simple acceleration
        if h and h.s then
            accel = (m - h.s) / math.max(now - h.t, 0.016)
        end
    end

    -- Smooth final velocity
    local s = (h and h.s or m):Lerp(m, 0.62)

    -- Zigzag detection (lebih sensitif)
    local zig = 0
    if h and h.lastDir and h.lastDir.Magnitude > 0.5 and s.Magnitude > 1.8 then
        local dot = flat(s).Unit:Dot(flat(h.lastDir).Unit)
        if dot < 0.18 then zig = 1
        elseif dot < 0.38 then zig = 0.55
        elseif dot < 0.55 then zig = 0.25 end
    end

    velHist[ch] = {
        pos = root.Position,
        t = now,
        s = s,
        lastDir = s.Magnitude > 1.0 and s or (h and h.lastDir),
        accel = accel
    }

    return Vector3.new(s.X, 0, s.Z), zig, isAir, accel
end

-- ====================== ADVANCED PREDICTION (cakep + akurat) ======================
local function getAdvancedLead(ch, dist, ping, predMult)
    local root = getRoot(ch)
    if not root then return Vector3.zero end

    local vel, zig, isAir, accel = getMotion(ch)
    local t = math.clamp(dist / 248, 0.014, 0.68)
    local totalT = t + ping

    -- Base lead
    local lead = vel * totalT * predMult

    -- Acceleration compensation (bikin predict lebih "pintar")
    if accel and accel.Magnitude > 0.5 then
        lead = lead + (accel * totalT * totalT * 0.45)
    end

    -- Air boost
    if isAir then
        lead = lead * (CFG.tof_air_predict or 1.55)
    end

    -- Zigzag reduce (biar ga overshoot pas orang zigzag)
    if zig > 0 then
        lead = lead * (1 - (0.42 * zig))
    end

    -- Distance scaling (penting banget di VD)
    if dist < 9 then
        lead = lead * (CFG.tof_close_mult or 0.14)
    elseif dist < 20 then
        lead = lead * (CFG.tof_mid_mult or 0.48)
    elseif dist < 45 then
        lead = lead * 0.82
    elseif dist > 220 then
        lead = lead * 1.18
    end

    -- Max lead clamp (anti overshoot parah)
    local maxLead = math.clamp(dist * 0.36, 0.6, 36)
    lead = clampMag(lead, maxLead)

    return lead
end

-- ====================== TARGET (HRP ONLY + Sticky kuat) ======================
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

        local root = getRoot(ch) -- WAJIB HRP
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not root or not hum then continue end

        local studs = (root.Position - origin).Magnitude
        if studs > maxd then continue end

        local sp, onScreen = Cam:WorldToViewportPoint(root.Position)
        local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude

        -- Dynamic FOV (lebih longgar di close range)
        local useFov = fov
        if studs < 14 then useFov = math.max(fov, 1600)
        elseif studs < 28 then useFov = math.max(fov, 920)
        elseif studs < 55 then useFov = math.max(fov, 560)
        elseif studs < 95 then useFov = math.max(fov, 420) end

        local ok = true
        if studs >= 48 then
            if not onScreen or sp.Z <= 0 or sd > useFov then ok = false end
        else
            if onScreen and sp.Z > 0 and sd > useFov then ok = false end
        end
        if not ok then continue end

        local score = studs * 0.092 + (sp.Z > 0 and sd or 260)
        if studs < 12 then score = score * 0.14 end
        if studs < 7 then score = score * 0.35 end
        if hum.Health < 40 then score = score * 0.82 end

        -- Sticky kuat (biar ga ganti target pas lagi ngejar)
        if lastTarget == p and (os.clock() - lastLockTime) < (CFG.tof_sticky_time or 0.68) then
            score = score * 0.62
        end

        if score < bestS then
            bestS = score
            bestP = p
            bestR = root
        end
    end

    return bestP, bestR
end

-- ====================== LASER ======================
local function ensureLaser()
    if hold and hold.Parent then return end
    hold = Instance.new("Part")
    hold.Name = "KZ_ToFLaser"
    hold.Anchored = true
    hold.CanCollide = false
    hold.CanQuery = false
    hold.CanTouch = false
    hold.Transparency = 1
    hold.Size = Vector3.new(0.06, 0.06, 0.06)
    hold.Parent = workspace

    a0 = Instance.new("Attachment", hold)
    a1 = Instance.new("Attachment", hold)

    beam = Instance.new("Beam", hold)
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.Width0 = 0.055
    beam.Width1 = 0.02
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 45, 45))
    beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.06),
        NumberSequenceKeypoint.new(1, 0.42)
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

-- ====================== FOV CIRCLE ======================
local fovGui, fovFrame, fovStroke
local function ensureFov()
    if fovGui and fovGui.Parent then return end
    local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 4)
    if not pg then return end

    fovGui = Instance.new("ScreenGui")
    fovGui.Name = "KZ_ToF_FOV"
    fovGui.IgnoreGuiInset = true
    fovGui.ResetOnSpawn = false
    fovGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    fovGui.Parent = pg

    fovFrame = Instance.new("Frame", fovGui)
    fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fovFrame.Position = UDim2.fromScale(0.5, 0.5)
    fovFrame.BackgroundTransparency = 1

    fovStroke = Instance.new("UIStroke", fovFrame)
    fovStroke.Thickness = 1.5
    fovStroke.Color = Color3.fromRGB(255, 45, 45)
    fovStroke.Transparency = 0.18

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
    fovStroke.Color = locked and Color3.fromRGB(55, 255, 95) or Color3.fromRGB(255, 45, 45)
end

-- ====================== MAIN LOOP ======================
local function cleanupHist()
    for ch in pairs(velHist) do
        if not ch or not ch.Parent then
            velHist[ch] = nil
            posHist[ch] = nil
        end
    end
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

    -- ========== HRP ONLY ==========
    local aimPos = root.Position + Vector3.new(0, CFG.tof_height_offset or 0.08, 0)
    local dist = (aimPos - origin).Magnitude

    local ping = 0.035
    pcall(function()
        ping = math.clamp(LP:GetNetworkPing(), 0, 0.28)
    end)

    local pred = CFG.tof_predict or 3.15
    local lead = getAdvancedLead(killer.Character, dist, ping, pred)

    local finalPos = aimPos + lead
    local dir = finalPos - origin

    if dir.Magnitude < 0.03 then
        _G.KZ_ToFAimDir = nil
        setLaser(nil, nil, false)
        updateFovDraw(false)
        return
    end

    local unitDir = safeUnit(dir)

    -- Light smooth (tetap responsif)
    if CFG.tof_smooth and CFG.tof_smooth > 0 and lastAimDir then
        unitDir = lastAimDir:Lerp(unitDir, 1 - math.clamp(CFG.tof_smooth, 0, 0.35))
        unitDir = safeUnit(unitDir)
    end

    lastAimDir = unitDir
    _G.KZ_ToFAimDir = unitDir

    setLaser(origin, root.Position, true)
    updateFovDraw(true)

    if math.random() < 0.015 then cleanupHist() end
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.45)
    lastAimDir = nil
    _G.KZ_ToFAimDir = nil
end)

print("[KZ] Violence District Silent Aim ToF | HRP ONLY | Multi-Sample Prediction | Sticky Strong")
