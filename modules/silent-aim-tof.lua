local S = _G.KZ
if not S then return end

if S.NewHook then
    S.NewHook(function(self, method, OLD, ...)
        if method ~= "FireServer" then return OLD(self, ...) end
        if not S.CFG.tof_on then return OLD(self, ...) end
        local dir = _G.KZ_ToFAimDir
        if typeof(dir) ~= "Vector3" then return OLD(self, ...) end
        local match = (S.RC.tof and self == S.RC.tof)
        if not match then
            local sn, fn = "", ""
            pcall(function() sn = tostring(self.Name or ""):lower() end)
            pcall(function() fn = self:GetFullName():lower() end)
            if fn:find("twist") or fn:find("fate") or (sn == "fire" and fn:find("item")) then match = true end
        end
        if not match then return OLD(self, ...) end
        local args = table.pack(...)
        for i = 1, args.n do
            if typeof(args[i]) == "Vector3" and args[i].Magnitude <= 5 then
                args[i] = dir; break
            end
        end
        return OLD(self, table.unpack(args, 1, args.n))
    end)
end

local LP = S.LP
local velHist = {}
local hold, a0, a1, beam

local function getRoot(c) return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart) end

local function isKnock()
    local ch = LP.Character
    if not ch then return false end
    return ch:GetAttribute("Knocked") or ch:GetAttribute("Downed") or ch:GetAttribute("Carried")
end

local function getOrigin()
    local ch = LP.Character
    local Cam = workspace.CurrentCamera
    if isKnock() then
        for _, n in ipairs({"RightHand", "Right Arm", "RightLowerArm", "LeftHand"}) do
            local p = ch and ch:FindFirstChild(n)
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

local function getVel(ch)
    local root = getRoot(ch)
    if not root then return Vector3.zero end
    local now = os.clock()
    local h = velHist[ch]
    local m = Vector3.zero
    if h and now - h.t > 0.02 then
        m = (root.Position - h.pos) / (now - h.t)
        if m.Magnitude > 130 then m = h.s or Vector3.zero end
    end
    local asm = root.AssemblyLinearVelocity
    if typeof(asm) == "Vector3" then
        m = m:Lerp(Vector3.new(asm.X, 0, asm.Z), 0.4)
    end
    local s = (h and h.s or m):Lerp(m, 0.55)
    velHist[ch] = { pos = root.Position, t = now, s = s }
    return Vector3.new(s.X, 0, s.Z)
end

local function getTarget()
    local Cam = workspace.CurrentCamera
    if not Cam then return nil, nil end
    local center = Cam.ViewportSize / 2
    local origin = getOrigin()
    local bestP, bestR, bestS = nil, nil, math.huge
    local fov = S.CFG.tof_fov or 320
    for _, p in ipairs(S.Players:GetPlayers()) do
        if S.isKiller(p) then
            local ch = p.Character
            local root = getRoot(ch)
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local studs = (root.Position - origin).Magnitude
                if studs <= (S.CFG.tof_maxdist or 800) then
                    local sp, on = Cam:WorldToViewportPoint(root.Position)
                    local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    local useFov = fov
                    if studs < 25 then useFov = math.max(fov, 900)
                    elseif studs < 50 then useFov = math.max(fov, 500) end
                    local ok = true
                    if studs >= 50 and (not on or sp.Z <= 0 or sd > useFov) then ok = false end
                    if studs < 50 and on and sp.Z > 0 and sd > useFov then ok = false end
                    if ok then
                        local score = studs * 0.1 + (sp.Z > 0 and sd or 200)
                        if studs < 18 then score = score * 0.25 end
                        if score < bestS then bestS, bestP, bestR = score, p, root end
                    end
                end
            end
        end
    end
    return bestP, bestR
end

local function ensureLaser()
    if hold and hold.Parent then return end
    hold = Instance.new("Part")
    hold.Name = "KZ_ToFLaser"
    hold.Anchored = true; hold.CanCollide = false; hold.CanQuery = false
    hold.Transparency = 1
    hold.Size = Vector3.new(0.1, 0.1, 0.1)
    hold.Parent = workspace
    a0 = Instance.new("Attachment", hold)
    a1 = Instance.new("Attachment", hold)
    beam = Instance.new("Beam", hold)
    beam.Attachment0, beam.Attachment1 = a0, a1
    beam.Width0, beam.Width1 = 0.06, 0.03
    beam.LightEmission = 1; beam.LightInfluence = 0
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 70, 70))
    beam.Transparency = NumberSequence.new(0.15)
    beam.FaceCamera = true
    beam.Enabled = false
end

local function setLaser(from, to, on)
    ensureLaser()
    if not on or not S.CFG.tof_laser or not S.CFG.tof_on then
        beam.Enabled = false
        return
    end
    hold.CFrame = CFrame.new(from)
    a0.WorldPosition = from
    a1.WorldPosition = to
    beam.Enabled = true
end

S.RSvc.RenderStepped:Connect(function()
    if not S.CFG.tof_on then
        _G.KZ_ToFAimDir = nil
        setLaser(nil, nil, false)
        return
    end
    local killer, root = getTarget()
    local origin = getOrigin()
    if not killer or not root then
        _G.KZ_ToFAimDir = nil
        setLaser(nil, nil, false)
        return
    end
    local aim = root.Position
    local dist = (aim - origin).Magnitude
    local vel = getVel(killer.Character)
    local t = math.clamp(dist / 220, 0.02, 0.5)
    local ping = 0.05
    pcall(function() ping = math.clamp(LP:GetNetworkPing(), 0, 0.25) end)
    local lead = vel * (t + ping) * (S.CFG.tof_predict or 2.5)
    local maxL = math.clamp(dist * 0.4, 1, 24)
    if lead.Magnitude > maxL then lead = lead.Unit * maxL end
    local dir = (aim + lead) - origin
    if dir.Magnitude < 0.05 then
        _G.KZ_ToFAimDir = nil
        setLaser(nil, nil, false)
        return
    end
    _G.KZ_ToFAimDir = dir.Unit
    setLaser(origin, root.Position, true)
end)

print("[KZ] silent-aim-tof loaded")
