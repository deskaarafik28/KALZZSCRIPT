local S = _G.KZ
if not S then return end

-- HOOK sendiri (chain)
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
            if fn:find("twist") or fn:find("fate") or (sn == "fire" and fn:find("item")) then
                match = true
            end
        end
        if not match then return OLD(self, ...) end

        local args = table.pack(...)
        for i = 1, args.n do
            if typeof(args[i]) == "Vector3" and args[i].Magnitude <= 5 then
                args[i] = dir
                break
            end
        end
        return OLD(self, table.unpack(args, 1, args.n))
    end)
end

local velHist = {}
local hold, a0, a1, beam

local function getRoot(ch) return ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart) end

local function isKnockOrCarry()
    local ch = S.LP.Character
    if not ch then return false end
    if ch:GetAttribute("Knocked")==true or ch:GetAttribute("Downed")==true then return true end
    if ch:GetAttribute("IsDowned")==true then return true end
    if ch:GetAttribute("Carried")==true or ch:GetAttribute("IsCarried")==true then return true end
    if ch:GetAttribute("BeingCarried")==true then return true end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if hum then
        local ok, st = pcall(function() return hum:GetState() end)
        if ok and (st==Enum.HumanoidStateType.FallingDown or st==Enum.HumanoidStateType.Ragdoll) then return true end
    end
    return false
end

local function getHand(ch)
    if not ch then return nil end
    for _, n in ipairs({"RightHand","Right Arm","RightLowerArm","RightUpperArm","LeftHand","Left Arm","LeftLowerArm"}) do
        local p = ch:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    local tool = ch:FindFirstChildOfClass("Tool")
    if tool then return tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart") end
    return nil
end

local function getOrigin()
    local ch = S.LP.Character
    local Cam = S.Workspace.CurrentCamera
    if isKnockOrCarry() then
        local hand = getHand(ch)
        if hand then return hand.Position end
        local head = ch and ch:FindFirstChild("Head")
        if head then return head.Position end
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

local function getKillerRoot()
    local Cam = S.Workspace.CurrentCamera
    if not Cam then return nil, nil end
    local center = Cam.ViewportSize / 2
    local origin = getOrigin()
    local best, bestRoot, bestScore = nil, nil, math.huge
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
                        if score < bestScore then bestScore, best, bestRoot = score, p, root end
                    end
                end
            end
        end
    end
    return best, bestRoot
end

local function ensureLaser()
    if hold and hold.Parent then return end
    hold = Instance.new("Part")
    hold.Name = "KZ_ToFLaser"
    hold.Anchored = true; hold.CanCollide = false; hold.CanQuery = false
    hold.Transparency = 1
    hold.Size = Vector3.new(0.1, 0.1, 0.1)
    hold.Parent = S.Workspace
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
    if not S.CFG.tof_on or S.isLocalKiller() then
        _G.KZ_ToFAimDir = nil
        setLaser(nil, nil, false)
        return
    end
    local killer, root = getKillerRoot()
    local origin = getOrigin()
    if not killer or not root then
        _G.KZ_ToFAimDir = nil
        setLaser(nil, nil, false)
        return
    end
    local aimPos = root.Position
    local dist = (aimPos - origin).Magnitude
    local vel = getVel(killer.Character)
    local t = math.clamp(dist / 220, 0.02, 0.5)
    local ping = 0.05
    pcall(function() ping = math.clamp(S.LP:GetNetworkPing(), 0, 0.25) end)
    local lead = vel * (t + ping) * (S.CFG.tof_predict or 2.5)
    local maxLead = math.clamp(dist * 0.4, 1, 24)
    if lead.Magnitude > maxLead then lead = lead.Unit * maxLead end
    local dir = (aimPos + lead) - origin
    if dir.Magnitude < 0.05 then
        _G.KZ_ToFAimDir = nil
        setLaser(nil, nil, false)
        return
    end
    _G.KZ_ToFAimDir = dir.Unit
    _G.KZ_ToFTarget = root
    setLaser(origin, root.Position, true)
end)

local V = {}
pcall(function()
    if typeof(Drawing) ~= "table" or not Drawing.new then return end
    V.o = Drawing.new("Circle"); V.o.Thickness=3; V.o.NumSides=90; V.o.Filled=false; V.o.Color=Color3.new(0,0,0); V.o.Transparency=0.5; V.o.Visible=false
    V.c = Drawing.new("Circle"); V.c.Thickness=1.8; V.c.NumSides=90; V.c.Filled=false; V.c.Color=Color3.fromRGB(255,255,255); V.c.Transparency=0.8; V.c.Visible=false
end)
S.RSvc.RenderStepped:Connect(function()
    if not V.c then return end
    local cam = S.Workspace.CurrentCamera
    if not cam then V.c.Visible=false; V.o.Visible=false; return end
    if S.CFG.tof_show_fov and S.CFG.tof_on and not S.isLocalKiller() then
        local r = S.CFG.tof_fov or 320
        local col = _G.KZ_ToFTarget and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,210)
        local ctr = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        V.o.Position=ctr; V.o.Radius=r+2; V.o.Visible=true
        V.c.Position=ctr; V.c.Radius=r; V.c.Color=col; V.c.Visible=true
    else V.c.Visible=false; V.o.Visible=false end
end)

print("[KZ] silent-aim-tof loaded")
