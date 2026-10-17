-- SILENT AIM VEIL — NO HOOK
local S = _G.KZ
if not S then return end

local LP = S.LP
local CFG = _G.KALZZ_CFG or {}

local VD = {
    VeilFOV = 320, VeilMaxDist = 2000,
    VeilSpearSpeed = 165, VeilGravity = 103,
    VeilLeadMultiplier = 1.4,
}

_G.KZ_VeilState = _G.KZ_VeilState or { lookVector=nil, stamp=0, target=nil, velHistory={} }
local VeilState = _G.KZ_VeilState

local function solvePitch(v0, g, flatDist, dy, iters)
    iters = iters or 4
    flatDist = math.max(flatDist, 0.1)
    local s2 = v0 * v0
    local root = s2*s2 - g*(g*flatDist*flatDist + 2*dy*s2)
    if root < 0 then root = 0 end
    local theta = math.atan((s2 - math.sqrt(root)) / (g * flatDist))
    for _ = 1, iters do
        local cosT = math.cos(theta)
        if math.abs(cosT) < 1e-6 then break end
        local t = flatDist / (v0 * cosT)
        local predDY = v0*math.sin(theta)*t - 0.5*g*t*t
        theta = theta + (dy - predDY) * 0.1
    end
    return theta
end

local function getVel(char)
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    if not root or not root:IsA("BasePart") then return Vector3.zero end
    local now = os.clock()
    local last = VeilState.velHistory[char]
    local measured = Vector3.zero
    if last and now - last.t > 0.016 then
        measured = (root.Position - last.pos) / (now - last.t)
        if measured.Magnitude > 150 then measured = last.smooth or Vector3.zero end
    end
    local smooth = last and last.smooth or measured
    smooth = smooth:Lerp(measured, 0.7)
    VeilState.velHistory[char] = { pos=root.Position, t=now, smooth=smooth }
    if smooth.Magnitude < 0.5 then return Vector3.zero end
    return Vector3.new(smooth.X, 0, smooth.Z)
end

S.Players.PlayerRemoving:Connect(function(p)
    if p.Character then VeilState.velHistory[p.Character] = nil end
end)

local function computeLook(origin, targetPos, targetChar)
    local aimPoint = targetPos
    local vel = getVel(targetChar)
    if vel.Magnitude > 0.3 then
        local d0 = targetPos - origin
        local h0 = Vector3.new(d0.X, 0, d0.Z)
        local tFlight = h0.Magnitude / VD.VeilSpearSpeed
        local ping = 0.08
        pcall(function() ping = math.clamp(LP:GetNetworkPing(), 0, 0.4) end)
        local totalDelay = tFlight + 0.10 + ping + 0.04
        for _ = 1, 3 do
            local lead = vel * totalDelay * VD.VeilLeadMultiplier
            local maxL = math.clamp((targetPos - origin).Magnitude * 0.55, 2, 45)
            if lead.Magnitude > maxL then lead = lead.Unit * maxL end
            aimPoint = targetPos + lead
            local ad = aimPoint - origin
            local ah = Vector3.new(ad.X, 0, ad.Z)
            totalDelay = (ah.Magnitude / VD.VeilSpearSpeed) + 0.10 + ping + 0.04
        end
    end
    local adir = aimPoint - origin
    local ah = Vector3.new(adir.X, 0, adir.Z)
    local ahDist = ah.Magnitude
    local pitch = solvePitch(VD.VeilSpearSpeed, VD.VeilGravity, math.max(ahDist, 0.1), adir.Y)
    local lv
    if ahDist > 0.001 then
        lv = ah.Unit * math.cos(pitch) + Vector3.new(0, math.sin(pitch), 0)
    else
        lv = adir.Unit
    end
    return lv
end

local lastAim = 0
S.RSvc.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastAim < 0.033 then return end
    lastAim = now

    if not CFG.veil_on or not S.isLocalKiller() then
        VeilState.lookVector = nil; VeilState.target = nil; return
    end

    local cam = S.Workspace.CurrentCamera
    if not cam then return end
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)

    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local nearest, nearestPart = nil, nil
    local bestDist = VD.VeilFOV or 320
    local bestStudDist = VD.VeilMaxDist or 2000

    for _, p in ipairs(S.Players:GetPlayers()) do
        if p ~= LP and p.Character and not S.isKiller(p) then
            local pc = p.Character
            local isDown = pc:GetAttribute("Knocked")==true or pc:GetAttribute("HookProgressDepleting")==true
            if not isDown then
                local hum = pc:FindFirstChildOfClass("Humanoid")
                local tpart = pc:FindFirstChild("UpperTorso") or pc:FindFirstChild("Torso") or pc:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and tpart then
                    local sp, on = cam:WorldToViewportPoint(tpart.Position)
                    if on and sp.Z > 0 then
                        local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if sd < bestDist then
                            local studDist = (tpart.Position - hrp.Position).Magnitude
                            if studDist <= bestStudDist then
                                bestDist = sd; nearest = p; nearestPart = tpart
                            end
                        end
                    end
                end
            end
        end
    end

    if nearest and nearestPart then
        local tp = nearestPart.Position
        local hand = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
        local origin = (hand and hand:IsA("BasePart")) and hand.Position or hrp.Position
        local dist = (tp - origin).Magnitude
        if dist > 0.1 and dist <= (VD.VeilMaxDist or 2000) then
            VeilState.lookVector = computeLook(origin, tp, nearest.Character)
            VeilState.target = nearest
            VeilState.stamp = now
        end
    else
        VeilState.lookVector = nil; VeilState.target = nil
    end
end)

print("[KZ] silent-aim-veil loaded (no hook)")
