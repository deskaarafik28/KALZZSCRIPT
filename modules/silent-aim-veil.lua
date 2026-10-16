-- ======================
-- SILENT AIM VEIL SPEAR • CLEAN (NO HOOK)
-- Cuma hitung direction + set _G.KZ_VeilState.lookVector
-- Hook FireServer di-handle unified hook di main.lua
-- ======================
local S = _G.KZ
if not S then return end

local VD = {
    VeilEnabled=true, VeilShowFOV=true, VeilShowTracker=true, VeilAutoPredict=true,
    VeilFOV=320, VeilMaxDist=2000,
    VeilSpearSpeed=165, VeilAuraSpearSpeed=165,
    VeilGravity=103, VeilAuraSpearGravity=96.5,
    VeilLeadMultiplier=1.4,
}

S.RSvc.RenderStepped:Connect(function()
    if not S.CFG then return end
    VD.VeilEnabled    = S.CFG.veil_on
    VD.VeilShowFOV    = S.CFG.veil_show_fov
    VD.VeilFOV        = S.CFG.veil_fov or 320
    VD.VeilMaxDist    = S.CFG.veil_maxdist or 2000
end)

local ACCENT = Color3.fromRGB(150, 105, 255)
local BLACK  = Color3.fromRGB(0,0,0)
local WHITE  = Color3.fromRGB(255,255,255)
local LP     = S.LP

-- Pakai _G.KZ_VeilState (shared dengan main.lua) biar unified hook bisa baca
_G.KZ_VeilState = _G.KZ_VeilState or { lookVector=nil, stamp=0, target=nil }
_G.KZ_VeilState.velHistory = _G.KZ_VeilState.velHistory or {}

local VeilState = _G.KZ_VeilState
local VeilVisuals = {}

pcall(function()
    if typeof(Drawing) ~= "table" or not Drawing.new then return end
    local V = VeilVisuals
    V.FOVOuterRing = Drawing.new("Circle"); V.FOVOuterRing.Color=BLACK; V.FOVOuterRing.Thickness=3; V.FOVOuterRing.Filled=false; V.FOVOuterRing.Transparency=0.4; V.FOVOuterRing.Visible=false; V.FOVOuterRing.NumSides=90
    V.FOVMainRing = Drawing.new("Circle"); V.FOVMainRing.Color=ACCENT; V.FOVMainRing.Thickness=1.6; V.FOVMainRing.Filled=false; V.FOVMainRing.Transparency=0.85; V.FOVMainRing.Visible=false; V.FOVMainRing.NumSides=90
    V.FOVInnerRing = Drawing.new("Circle"); V.FOVInnerRing.Color=ACCENT; V.FOVInnerRing.Thickness=1; V.FOVInnerRing.Filled=false; V.FOVInnerRing.Transparency=0.35; V.FOVInnerRing.Visible=false; V.FOVInnerRing.NumSides=90
    V.FOVCrossLines = {}; for i=1,4 do local l=Drawing.new("Line"); l.Color=WHITE; l.Thickness=1.5; l.Transparency=0.9; l.Visible=false; V.FOVCrossLines[i]=l end
    V.FOVTicks = {}; for i=1,4 do local l=Drawing.new("Line"); l.Color=ACCENT; l.Thickness=2.2; l.Transparency=0.95; l.Visible=false; V.FOVTicks[i]=l end
    V.TrackerOuterRing = Drawing.new("Circle"); V.TrackerOuterRing.Color=BLACK; V.TrackerOuterRing.Thickness=3; V.TrackerOuterRing.Filled=false; V.TrackerOuterRing.Transparency=0.3; V.TrackerOuterRing.NumSides=40; V.TrackerOuterRing.Visible=false
    V.TrackerMainRing = Drawing.new("Circle"); V.TrackerMainRing.Color=ACCENT; V.TrackerMainRing.Thickness=1.6; V.TrackerMainRing.Filled=false; V.TrackerMainRing.Transparency=0.9; V.TrackerMainRing.NumSides=40; V.TrackerMainRing.Visible=false
    V.TrackerDotFill = Drawing.new("Circle"); V.TrackerDotFill.Color=ACCENT; V.TrackerDotFill.Thickness=1; V.TrackerDotFill.Filled=true; V.TrackerDotFill.Transparency=0.9; V.TrackerDotFill.Radius=3; V.TrackerDotFill.NumSides=20; V.TrackerDotFill.Visible=false
    V.TrackerDotOutline = Drawing.new("Circle"); V.TrackerDotOutline.Color=BLACK; V.TrackerDotOutline.Thickness=3; V.TrackerDotOutline.Filled=false; V.TrackerDotOutline.Transparency=0.3; V.TrackerDotOutline.Radius=6; V.TrackerDotOutline.NumSides=20; V.TrackerDotOutline.Visible=false
    V.TrackerLine = Drawing.new("Line"); V.TrackerLine.Color=ACCENT; V.TrackerLine.Thickness=1.5; V.TrackerLine.Transparency=0.6; V.TrackerLine.Visible=false
end)

-- ─── Ballistic Solver ─────────────────────────────────────────────────────
local function solvePitchIterative(v0, g, flatDist, dy, iters)
    iters = iters or 4
    flatDist = math.max(flatDist, 0.1)
    local s2 = v0 * v0
    local root = s2*s2 - g*(g*flatDist*flatDist + 2*dy*s2)
    if root < 0 then root = 0 end
    local tanTheta = (s2 - math.sqrt(root)) / (g * flatDist)
    local theta = math.atan(tanTheta)
    for _ = 1, iters do
        local cosT = math.cos(theta)
        if math.abs(cosT) < 1e-6 then break end
        local t = flatDist / (v0 * cosT)
        local predictedDY = v0*math.sin(theta)*t - 0.5*g*t*t
        local err = dy - predictedDY
        theta = theta + err * 0.1
    end
    local cosT = math.max(math.abs(math.cos(theta)), 1e-6)
    local tFlight = flatDist / (v0 * cosT)
    return theta, tFlight
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

-- ─── Compute lookVector ───────────────────────────────────────────────────
local function computeLook(origin, targetPos, targetChar, prof)
    local aimPoint = targetPos
    if VD.VeilAutoPredict then
        local vel = getVel(targetChar)
        if vel.Magnitude > 0.3 then
            local dir0 = targetPos - origin
            local h0 = Vector3.new(dir0.X, 0, dir0.Z)
            local _, tFlight = solvePitchIterative(prof.v0, prof.g, h0.Magnitude, dir0.Y)
            local ping = 0.08
            pcall(function() ping = math.clamp(LP:GetNetworkPing(), 0, 0.4) end)
            local totalDelay = tFlight + prof.windup + ping + prof.latency

            for _ = 1, 3 do
                local lead = vel * totalDelay * prof.scale
                local maxL = math.clamp((targetPos - origin).Magnitude * 0.55, 2, prof.maxlead)
                if lead.Magnitude > maxL then lead = lead.Unit * maxL end
                aimPoint = targetPos + lead
                local ad = aimPoint - origin
                local ah = Vector3.new(ad.X, 0, ad.Z)
                local _, t2 = solvePitchIterative(prof.v0, prof.g, math.max(ah.Magnitude, 0.1), ad.Y)
                totalDelay = t2 + prof.windup + ping + prof.latency
            end
        end
    end

    local adir = aimPoint - origin
    local ah = Vector3.new(adir.X, 0, adir.Z)
    local ahDist = ah.Magnitude
    local pitch, _ = solvePitchIterative(prof.v0, prof.g, math.max(ahDist, 0.1), adir.Y)

    local lv
    if ahDist > 0.001 then
        lv = ah.Unit * math.cos(pitch) + Vector3.new(0, math.sin(pitch), 0)
    else
        lv = adir.Unit
    end
    return lv, aimPoint
end

-- ─── Visuals ──────────────────────────────────────────────────────────────
local function hideFOV()
    local V = VeilVisuals; local OFF = Vector2.new(-9999,-9999)
    if V.FOVOuterRing then V.FOVOuterRing.Visible=false; V.FOVOuterRing.Position=OFF; V.FOVOuterRing.Radius=0 end
    if V.FOVMainRing then V.FOVMainRing.Visible=false; V.FOVMainRing.Position=OFF; V.FOVMainRing.Radius=0 end
    if V.FOVInnerRing then V.FOVInnerRing.Visible=false; V.FOVInnerRing.Position=OFF; V.FOVInnerRing.Radius=0 end
    if V.FOVCrossLines then for _,s in ipairs(V.FOVCrossLines) do s.Visible=false; s.From=OFF; s.To=OFF end end
    if V.FOVTicks then for _,s in ipairs(V.FOVTicks) do s.Visible=false; s.From=OFF; s.To=OFF end end
end

local function hideTracker()
    local V = VeilVisuals; local OFF = Vector2.new(-9999,-9999)
    if V.TrackerOuterRing then V.TrackerOuterRing.Visible=false; V.TrackerOuterRing.Position=OFF; V.TrackerOuterRing.Radius=0 end
    if V.TrackerMainRing then V.TrackerMainRing.Visible=false; V.TrackerMainRing.Position=OFF; V.TrackerMainRing.Radius=0 end
    if V.TrackerDotFill then V.TrackerDotFill.Visible=false; V.TrackerDotFill.Position=OFF; V.TrackerDotFill.Radius=0 end
    if V.TrackerDotOutline then V.TrackerDotOutline.Visible=false; V.TrackerDotOutline.Position=OFF; V.TrackerDotOutline.Radius=0 end
    if V.TrackerLine then V.TrackerLine.Visible=false; V.TrackerLine.From=OFF; V.TrackerLine.To=OFF end
end

local function hideAll() hideFOV(); hideTracker() end

local function updateFOV(c)
    local V = VeilVisuals
    if not V.FOVOuterRing then return end
    local r = VD.VeilFOV or 320
    local t = tick()
    local pulse = (math.sin(t*3)+1)*0.5
    local slow = (math.sin(t*1.2)+1)*0.5
    V.FOVOuterRing.Position=c; V.FOVOuterRing.Radius=r+2; V.FOVOuterRing.Transparency=0.3+pulse*0.15; V.FOVOuterRing.Visible=true
    V.FOVMainRing.Position=c; V.FOVMainRing.Radius=r; V.FOVMainRing.Transparency=0.7+pulse*0.25; V.FOVMainRing.Visible=true
    V.FOVInnerRing.Position=c; V.FOVInnerRing.Radius=r-10; V.FOVInnerRing.Transparency=0.25+slow*0.2; V.FOVInnerRing.Visible=true
    local gap, arm = 4, 12
    V.FOVCrossLines[1].From=Vector2.new(c.X,c.Y-gap); V.FOVCrossLines[1].To=Vector2.new(c.X,c.Y-gap-arm); V.FOVCrossLines[1].Visible=true
    V.FOVCrossLines[2].From=Vector2.new(c.X,c.Y+gap); V.FOVCrossLines[2].To=Vector2.new(c.X,c.Y+gap+arm); V.FOVCrossLines[2].Visible=true
    V.FOVCrossLines[3].From=Vector2.new(c.X-gap,c.Y); V.FOVCrossLines[3].To=Vector2.new(c.X-gap-arm,c.Y); V.FOVCrossLines[3].Visible=true
    V.FOVCrossLines[4].From=Vector2.new(c.X+gap,c.Y); V.FOVCrossLines[4].To=Vector2.new(c.X+gap+arm,c.Y); V.FOVCrossLines[4].Visible=true
    for i=1,4 do
        local a=(i-1)*math.pi/2; local dx,dy=math.cos(a),math.sin(a)
        V.FOVTicks[i].From=Vector2.new(c.X+dx*r,c.Y+dy*r)
        V.FOVTicks[i].To=Vector2.new(c.X+dx*(r-9),c.Y+dy*(r-9))
        V.FOVTicks[i].Visible=true
    end
end

local function updateTracker(pos, dist)
    local V = VeilVisuals
    if not V.TrackerOuterRing then return end
    local t = tick()
    local pulse = (math.sin(t*4)+1)*0.5
    local br = math.clamp(1000/math.max(dist,1), 20, 48)
    V.TrackerOuterRing.Position=pos; V.TrackerOuterRing.Radius=br+3; V.TrackerOuterRing.Transparency=0.25+pulse*0.15; V.TrackerOuterRing.Visible=true
    V.TrackerMainRing.Position=pos; V.TrackerMainRing.Radius=br; V.TrackerMainRing.Transparency=0.75+pulse*0.2; V.TrackerMainRing.Visible=true
    V.TrackerDotFill.Position=pos; V.TrackerDotFill.Radius=2.5+pulse*1.2; V.TrackerDotFill.Transparency=0.85+pulse*0.15; V.TrackerDotFill.Visible=true
    V.TrackerDotOutline.Position=pos; V.TrackerDotOutline.Radius=5+pulse*1.5; V.TrackerDotOutline.Transparency=0.35; V.TrackerDotOutline.Visible=true
end

-- ─── Aimbot Loop ──────────────────────────────────────────────────────────
local function updateAimbot()
    if not S.isLocalKiller() then
        VeilState.target=nil; VeilState.lookVector=nil; VeilState.stamp=0; hideAll(); return
    end
    local cam = S.Workspace.CurrentCamera
    if not cam then return end
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    if VD.VeilShowFOV and VD.VeilEnabled then updateFOV(center) else hideFOV() end
    if not VD.VeilEnabled then
        VeilState.target=nil; VeilState.lookVector=nil; VeilState.stamp=0; hideTracker(); return
    end
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
            local isAura = char:GetAttribute("special") == true
            local prof
            if isAura then
                prof = { v0=VD.VeilAuraSpearSpeed, g=VD.VeilAuraSpearGravity, windup=0.10, latency=0.04, maxlead=25, scale=VD.VeilLeadMultiplier }
            else
                prof = { v0=VD.VeilSpearSpeed, g=VD.VeilGravity, windup=0.10, latency=0.04, maxlead=45, scale=VD.VeilLeadMultiplier }
            end

            local lv, _ = computeLook(origin, tp, nearest.Character, prof)
            VeilState.lookVector = lv
            VeilState.target = nearest
            VeilState.stamp = os.clock()

            if VD.VeilShowTracker then
                local sp, vis = cam:WorldToViewportPoint(tp)
                if vis and sp.Z > 0 then
                    local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if sd <= (VD.VeilFOV or 320) + 100 then
                        updateTracker(Vector2.new(sp.X, sp.Y), dist)
                        local bc = Vector2.new(center.X, cam.ViewportSize.Y)
                        local V = VeilVisuals
                        if V.TrackerLine then V.TrackerLine.From=bc; V.TrackerLine.To=Vector2.new(sp.X, sp.Y); V.TrackerLine.Visible=true end
                    else hideTracker() end
                end
            else hideTracker() end
        end
    else
        VeilState.target=nil; VeilState.lookVector=nil; VeilState.stamp=0; hideTracker()
    end
end

local lastAim = 0
S.RSvc.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastAim >= 0.033 then
        lastAim = now
        pcall(updateAimbot)
    end
end)

-- ============================================================
-- EXPOSE FRESH RECOMPUTE untuk unified hook
-- Unified hook panggil ini tepat sebelum FireServer
-- ============================================================
S.RecomputeVeil = function()
    if not S.CFG or not S.CFG.veil_on then return nil end
    if not S.isLocalKiller() then return nil end
    if not VeilState.target or not VeilState.target.Character then
        return VeilState.lookVector
    end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return VeilState.lookVector end

    local tc = VeilState.target.Character
    local tpart = tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso") or tc:FindFirstChild("HumanoidRootPart")
    if not tpart then return VeilState.lookVector end

    local hand = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
    local origin = (hand and hand:IsA("BasePart")) and hand.Position or hrp.Position
    local dist = (tpart.Position - origin).Magnitude
    if dist <= 0.1 or dist > (VD.VeilMaxDist or 2000) then
        return VeilState.lookVector
    end

    local isAura = char:GetAttribute("special") == true
    local prof
    if isAura then
        prof = { v0=VD.VeilAuraSpearSpeed, g=VD.VeilAuraSpearGravity, windup=0.0, latency=0.03, maxlead=25, scale=VD.VeilLeadMultiplier }
    else
        prof = { v0=VD.VeilSpearSpeed, g=VD.VeilGravity, windup=0.0, latency=0.03, maxlead=45, scale=VD.VeilLeadMultiplier }
    end

    local lv = computeLook(origin, tpart.Position, tc, prof)
    return lv
end

print("[KZ] Veil aim direction loaded (hook handled by main.lua)")
