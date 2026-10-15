-- ======================
-- SILENT AIM ToF • FULL (CLEAN)
-- direction • predict • zigzag • FOV • laser • rootpart
-- knock/carry = origin tangan
-- ======================
local S = _G.KZ
if not S then
    warn("[KZ ToF] _G.KZ missing")
    return
end

local LP      = S.LP      or game:GetService("Players").LocalPlayer
local Players = S.Players or game:GetService("Players")
local RSvc    = S.RSvc    or game:GetService("RunService")
local CFG     = S.CFG     or {}

_G.KZ_ToFAimDir = nil

-- remote
pcall(function()
    S.RC = S.RC or {}
    if not S.RC.tof then
        S.RC.tof = game:GetService("ReplicatedStorage")
            .Remotes.Items["Twist of Fate"].Fire
    end
end)

local velHist = {} -- [char] = { pos, t, s, lastDir }
local hold, a0, a1, beam

local function getRoot(c)
    return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
end

local function flat(v)
    return Vector3.new(v.X, 0, v.Z)
end

local function isKnock()
    local ch = LP.Character
    if not ch then return false end
    return ch:GetAttribute("Knocked")
        or ch:GetAttribute("Downed")
        or ch:GetAttribute("Carried")
        or ch:GetAttribute("IsCarried")
end

-- origin: normal = tool/head | knock = TANGAN
local function getOrigin()
    local ch = LP.Character
    local Cam = workspace.CurrentCamera
    if isKnock() and ch then
        for _, n in ipairs({
            "RightHand", "Right Arm", "RightLowerArm", "RightUpperArm",
            "LeftHand", "Left Arm", "LeftLowerArm",
        }) do
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
    return Cam and Cam.CFrame.Position or Vector3.zero
end

-- velocity + zigzag detect
local function getMotion(ch)
    local root = getRoot(ch)
    if not root then
        return Vector3.zero, 0
    end
    local now = os.clock()
    local h = velHist[ch]
    local m = Vector3.zero
    if h and now - h.t > 0.02 then
        m = (root.Position - h.pos) / (now - h.t)
        if m.Magnitude > 140 then
            m = h.s or Vector3.zero
        end
    end
    local asm = root.AssemblyLinearVelocity
    if typeof(asm) == "Vector3" then
        m = m:Lerp(Vector3.new(asm.X, 0, asm.Z), 0.45)
    end
    local s = (h and h.s or m):Lerp(m, 0.55)

    local zig = 0
    if h and h.lastDir and h.lastDir.Magnitude > 0.5 and s.Magnitude > 2 then
        local d = flat(s).Unit:Dot(flat(h.lastDir).Unit)
        if d < 0.25 then
            zig = 1
        end
    end

    velHist[ch] = {
        pos = root.Position,
        t = now,
        s = s,
        lastDir = s.Magnitude > 1 and s or (h and h.lastDir),
    }
    return Vector3.new(s.X, 0, s.Z), zig
end

-- target = ROOTPART only, FOV + close range priority
local function getTarget()
    local Cam = workspace.CurrentCamera
    if not Cam then return nil, nil end
    local center = Cam.ViewportSize / 2
    local origin = getOrigin()
    local bestP, bestR, bestS = nil, nil, math.huge
    local fov = CFG.tof_fov or 320
    local maxd = CFG.tof_maxdist or 800

    for _, p in ipairs(Players:GetPlayers()) do
        if not S.isKiller(p) then continue end
        local ch = p.Character
        local root = getRoot(ch)
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end

        local studs = (root.Position - origin).Magnitude
        if studs > maxd then continue end

        local sp, on = Cam:WorldToViewportPoint(root.Position)
        local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude

        local useFov = fov
        if studs < 20 then
            useFov = math.max(fov, 1200)
        elseif studs < 40 then
            useFov = math.max(fov, 700)
        elseif studs < 70 then
            useFov = math.max(fov, 480)
        end

        local ok = true
        if studs >= 50 then
            if not on or sp.Z <= 0 or sd > useFov then ok = false end
        else
            if on and sp.Z > 0 and sd > useFov then ok = false end
        end
        if not ok then continue end

        local score = studs * 0.12 + (sp.Z > 0 and sd or 220)
        if studs < 18 then score = score * 0.22 end
        if studs < 10 then score = score * 0.5 end

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
    hold.Transparency = 1
    hold.Size = Vector3.new(0.1, 0.1, 0.1)
    hold.Parent = workspace
    a0 = Instance.new("Attachment", hold)
    a1 = Instance.new("Attachment", hold)
    beam = Instance.new("Beam", hold)
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.Width0 = 0.07
    beam.Width1 = 0.03
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 70, 70))
    beam.Transparency = NumberSequence.new(0.12)
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

-- FOV circle
local fovGui, fovFrame, fovStroke
local function ensureFov()
    if fovGui and fovGui.Parent then return end
    local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
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
    fovStroke.Color = Color3.fromRGB(255, 70, 70)
    fovStroke.Transparency = 0.25
    Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1, 0)
end

local function updateFovDraw(locked)
    if not CFG.tof_show_fov then
        if fovGui then fovGui.Enabled = false end
        return
    end
    ensureFov()
    fovGui.Enabled = CFG.tof_on
    local r = CFG.tof_fov or 320
    fovFrame.Size = UDim2.fromOffset(r * 2, r * 2)
    fovStroke.Color = locked and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 70, 70)
end

-- DIRECTION update tiap frame
RSvc.RenderStepped:Connect(function()
    if not CFG.tof_on then
        _G.KZ_ToFAimDir = nil
        setLaser(nil, nil, false)
        updateFovDraw(false)
        return
    end

    local killer, root = getTarget()
    local origin = getOrigin()

    if not killer or not root then
        _G.KZ_ToFAimDir = nil
        setLaser(nil, nil, false)
        updateFovDraw(false)
        return
    end

    local aim = root.Position
    local dist = (aim - origin).Magnitude
    local vel, zig = getMotion(killer.Character)

    local t = math.clamp(dist / 220, 0.02, 0.55)
    local ping = 0.05
    pcall(function()
        ping = math.clamp(LP:GetNetworkPing(), 0, 0.28)
    end)

    local pred = CFG.tof_predict or 2.5
    if zig > 0 then
        pred = pred * 0.65
    end

    local lead = vel * (t + ping) * pred
    local maxLead = math.clamp(dist * 0.42, 1, 28)
    if lead.Magnitude > maxLead then
        lead = lead.Unit * maxLead
    end

    if dist < 12 then
        lead = lead * 0.15
    elseif dist < 22 then
        lead = lead * 0.45
    end

    local dir = (aim + lead) - origin
    if dir.Magnitude < 0.05 then
        _G.KZ_ToFAimDir = nil
        setLaser(nil, nil, false)
        updateFovDraw(false)
        return
    end

    _G.KZ_ToFAimDir = dir.Unit
    setLaser(origin, root.Position, true)
    updateFovDraw(true)
end)

-- HOOK: setiap FireServer ToF
if S.NewHook then
    S.NewHook(function(self, method, OLD, ...)
        if method ~= "FireServer" then
            return OLD(self, ...)
        end
        if not CFG or not CFG.tof_on then
            return OLD(self, ...)
        end
        local dir = _G.KZ_ToFAimDir
        if typeof(dir) ~= "Vector3" then
            return OLD(self, ...)
        end

        local match = (S.RC and S.RC.tof and self == S.RC.tof)
        if not match then
            local sn, fn = "", ""
            pcall(function() sn = tostring(self.Name or ""):lower() end)
            pcall(function() fn = self:GetFullName():lower() end)
            if fn:find("twist", 1, true)
                or fn:find("fate", 1, true)
                or (sn == "fire" and fn:find("item", 1, true)) then
                match = true
            end
        end
        if not match then
            return OLD(self, ...)
        end

        local args = table.pack(...)
        local changed = false
        for i = 1, args.n do
            if typeof(args[i]) == "Vector3" and args[i].Magnitude <= 5 then
                args[i] = dir
                changed = true
                break
            end
        end
        if not changed and typeof(args[1]) == "Vector3" then
            args[1] = dir
        end
        return OLD(self, table.unpack(args, 1, args.n))
    end)
end

print("[KZ] ToF FULL • dir+predict+zigzag+fov+laser+root")
