--[[ KALZZ HUB V7 FINAL | Orion UI Fixed | Auto Load | Silent Aim | Auto Parry ]]

-- ============================================================
-- AUTO LOAD CONFIG
-- ============================================================
local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "kalzz_cfg_v7.json"

local CFG = {
    tof_on = true, tof_fov = 500, tof_predict = 2.8, tof_maxdist = 2000, tof_show_fov = true,
    veil_on = true, veil_fov = 320, veil_predict = 3, veil_maxdist = 400, veil_show_fov = true,
    veil_show_tracker = true, veil_auto_predict = true,
    parry_on = true, parry_radius = 14, parry_sensitive = 200, parry_aggro = true, parry_show_circle = true,
    fast_vault = true,
    esp_k = true, esp_s = true, esp_item = true,
    esp_g = true, esp_gen_txt = true,
    esp_out = false,
    fov_lock = false, fov_value = 120,
    ambient = true, boost_fps = true,
    alert = true,
    stun_on = true,
    gene_on = false, gene_method = "PERFECT",
}

local function loadCfg()
    if not (readfile and isfile) then return end
    pcall(function()
        if isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            for k, v in pairs(data) do
                if CFG[k] ~= nil then CFG[k] = v end
            end
        end
    end)
end
loadCfg()
_G.KALZZ_CFG = CFG

local function saveCfg()
    if not writefile then return end
    pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(CFG)) end)
end
_G.KZ_SaveCfg = saveCfg

-- ============================================================
-- SERVICES
-- ============================================================
local Players    = game:GetService("Players")
local RS         = game:GetService("ReplicatedStorage")
local RSvc       = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Workspace  = game:GetService("Workspace")
local Lighting   = game:GetService("Lighting")
local TS         = game:GetService("TweenService")
local CoreGui    = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local Cam = Workspace.CurrentCamera

local IMG = "rbxassetid://134442738689157"
local INVITE = "discord.gg/dCYTep9cY"
local ACCENT = Color3.fromRGB(181, 1, 31)

-- ============================================================
-- KICK BYPASS
-- ============================================================
pcall(function()
    local o
    o = hookmetamethod(game, "__namecall", newcclosure(function(s, ...)
        if getnamecallmethod() == "Kick" and s == LP then return end
        return o(s, ...)
    end))
end)

-- ============================================================
-- HELPERS
-- ============================================================
local function rtp(m)
    if not m then return nil end
    return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m.PrimaryPart
end

local function isKiller(chOrPlr)
    local p
    if typeof(chOrPlr) == "Instance" then
        if chOrPlr:IsA("Player") then p = chOrPlr
        else p = Players:GetPlayerFromCharacter(chOrPlr) end
    end
    if not p then return false end
    local role = (p.Character and p.Character:GetAttribute("Role")) or p:GetAttribute("Role")
    if type(role) == "string" then
        local r = role:lower()
        if r:find("killer", 1, true) then return true end
        if r:find("survivor", 1, true) then return false end
    end
    if p.Team and p.Team.Name then
        local t = p.Team.Name:lower()
        if t:find("killer", 1, true) then return true end
        if t:find("survivor", 1, true) then return false end
    end
    return false
end

local function isLocalKiller()
    local ch = LP.Character
    if not ch then return false end
    local role = ch:GetAttribute("Role") or LP:GetAttribute("Role")
    if type(role) == "string" and role:lower():find("killer", 1, true) then return true end
    if LP.Team and LP.Team.Name and LP.Team.Name:lower():find("killer", 1, true) then return true end
    return false
end

local function GetRole()
    return isLocalKiller() and "Killer" or "Survivor"
end

-- ============================================================
-- SCHEDULER
-- ============================================================
local Scheduler = { tasks = {} }
function Scheduler:Add(name, fn, interval)
    self.tasks[name] = { fn = fn, interval = interval, last = 0 }
end
RSvc.Heartbeat:Connect(function()
    local now = os.clock()
    for _, t in pairs(Scheduler.tasks) do
        if now - t.last >= t.interval then
            t.last = now
            pcall(t.fn)
        end
    end
end)

-- ============================================================
-- REMOTE CACHE
-- ============================================================
local RC = { tof = nil, veil = nil, parry = nil, fastvault = nil }
pcall(function() RC.tof = RS.Remotes.Items["Twist of Fate"].Fire end)
pcall(function() RC.parry = RS.Remotes.Items["Parrying Dagger"].parry end)
pcall(function()
    local k = RS.Remotes:FindFirstChild("Killers")
    if k then local v = k:FindFirstChild("Veil"); if v then RC.veil = v:FindFirstChild("Spearthrow") end end
end)
pcall(function()
    local w = RS.Remotes:FindFirstChild("Window")
    if w then RC.fastvault = w:FindFirstChild("SurvivorFastVault") or w:FindFirstChild("fastvault") end
end)

-- ============================================================
-- AIM HELPERS (ToF)
-- ============================================================
local function getMuzzle()
    local ch = LP.Character
    if not ch then return Cam and Cam.CFrame.Position or Vector3.zero end
    local tool = ch:FindFirstChildOfClass("Tool")
    if tool then
        local h = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
        if h then return h.Position + h.CFrame.LookVector * 2 end
    end
    local r = rtp(ch)
    return r and (r.Position + Vector3.new(0, 1.5, 0)) or (Cam and Cam.CFrame.Position or Vector3.zero)
end

local function pickTarget(wantKiller, fovRadius, maxDist)
    if not Cam then Cam = Workspace.CurrentCamera end
    if not Cam then return nil end
    local ctr = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    local myRoot = rtp(LP.Character)
    local myPos = myRoot and myRoot.Position or Cam.CFrame.Position
    local best, bestScore = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local k = isKiller(p)
            if (wantKiller and k) or (not wantKiller and not k) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local root = rtp(p.Character)
                if hum and hum.Health > 0 and root then
                    local wd = (root.Position - myPos).Magnitude
                    if wd <= (maxDist or 2000) then
                        local score = math.huge
                        if wd <= 20 then score = wd * 0.5
                        else
                            local sp, on = Cam:WorldToViewportPoint(root.Position)
                            if on and sp.Z > 0 then
                                local sd = (Vector2.new(sp.X, sp.Y) - ctr).Magnitude
                                if sd <= (fovRadius or 500) then score = sd + wd * 0.1 end
                            end
                        end
                        if score < bestScore then bestScore = score; best = root end
                    end
                end
            end
        end
    end
    return best
end

_G.KZ_ToFAimDir = nil
_G.KZ_ToFStamp = 0
_G.KZ_ToFTarget = nil
local VeilState = { target = nil, lookVector = nil, velHistory = {} }
local VeilVisuals = {}

RSvc.Heartbeat:Connect(function()
    Cam = Workspace.CurrentCamera
    local now = os.clock()
    local localK = isLocalKiller()

    if CFG.tof_on and not localK then
        local t = pickTarget(true, CFG.tof_fov, CFG.tof_maxdist)
        if t and t.Parent then
            local o = getMuzzle()
            local vel = t.AssemblyLinearVelocity or Vector3.zero
            vel = Vector3.new(vel.X, 0, vel.Z)
            local dist = (t.Position - o).Magnitude
            local pm = CFG.tof_predict or 2.8
            if dist < 30 then pm = pm * 0.3 end
            local pred = t.Position + vel * math.clamp(dist / 260, 0.04, 0.7) * pm + Vector3.new(0, 0.9, 0)
            local dir = pred - o
            if dir.Magnitude > 0.2 then
                _G.KZ_ToFAimDir = dir.Unit
                _G.KZ_ToFStamp = now
                _G.KZ_ToFTarget = t
            end
        else _G.KZ_ToFTarget = nil end
    else _G.KZ_ToFTarget = nil end
    if _G.KZ_ToFAimDir and (now - _G.KZ_ToFStamp) > 0.5 then
        _G.KZ_ToFAimDir = nil; _G.KZ_ToFTarget = nil
    end
end)

-- ============================================================
-- FOV CIRCLE (ToF)
-- ============================================================
do
    local V = {}
    pcall(function()
        if typeof(Drawing) ~= "table" or not Drawing.new then return end
        V.tofO = Drawing.new("Circle"); V.tofO.Thickness=3; V.tofO.NumSides=90; V.tofO.Filled=false; V.tofO.Color=Color3.new(0,0,0); V.tofO.Transparency=0.5; V.tofO.Visible=false
        V.tof = Drawing.new("Circle"); V.tof.Thickness=1.8; V.tof.NumSides=90; V.tof.Filled=false; V.tof.Color=Color3.fromRGB(255,255,255); V.tof.Transparency=0.8; V.tof.Visible=false
        V.dot = Drawing.new("Circle"); V.dot.Thickness=1; V.dot.NumSides=16; V.dot.Filled=true; V.dot.Radius=4; V.dot.Visible=false
        V.dotO = Drawing.new("Circle"); V.dotO.Thickness=3; V.dotO.NumSides=16; V.dotO.Filled=false; V.dotO.Color=Color3.new(0,0,0); V.dotO.Radius=6; V.dotO.Visible=false
    end)
    RSvc.RenderStepped:Connect(function()
        if not V.tof then return end
        local cam = Workspace.CurrentCamera
        if not cam then
            V.tof.Visible=false; V.tofO.Visible=false; V.dot.Visible=false; V.dotO.Visible=false
            return
        end
        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        if CFG.tof_show_fov and CFG.tof_on and not isLocalKiller() then
            local r = CFG.tof_fov or 500
            local col = _G.KZ_ToFTarget and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,210)
            V.tofO.Position=center; V.tofO.Radius=r+2; V.tofO.Visible=true
            V.tof.Position=center; V.tof.Radius=r; V.tof.Color=col; V.tof.Visible=true
        else V.tof.Visible=false; V.tofO.Visible=false end
        local tgt = _G.KZ_ToFTarget
        if tgt and tgt.Parent then
            local sp, on = cam:WorldToViewportPoint(tgt.Position)
            if on and sp.Z > 0 then
                V.dot.Position=Vector2.new(sp.X, sp.Y); V.dot.Color=Color3.fromRGB(255,255,255); V.dot.Visible=true
                V.dotO.Position=Vector2.new(sp.X, sp.Y); V.dotO.Visible=true
            else V.dot.Visible=false; V.dotO.Visible=false end
        else V.dot.Visible=false; V.dotO.Visible=false end
    end)
end

-- ============================================================
-- PARRY CIRCLE
-- ============================================================
do
    local base = Instance.new("Part")
    base.Name = "KZ_ParryCircle"
    base.Size = Vector3.new(1, 0.05, 1)
    base.Anchored = true; base.CanCollide = false; base.CanQuery = false
    base.CanTouch = false; base.CastShadow = false
    base.Material = Enum.Material.SmoothPlastic
    base.Transparency = 1; base.Parent = Workspace

    local sg = Instance.new("SurfaceGui", base)
    sg.Face = Enum.NormalId.Top; sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    sg.PixelsPerStud = 40; sg.LightInfluence = 0; sg.ZOffset = 1

    local ring = Instance.new("Frame", sg)
    ring.AnchorPoint = Vector2.new(0.5, 0.5); ring.Position = UDim2.fromScale(0.5, 0.5); ring.Size = UDim2.fromScale(0.96, 0.96)
    ring.BackgroundTransparency = 1; ring.BorderSizePixel = 0
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    local s1 = Instance.new("UIStroke", ring)
    s1.Thickness = 4; s1.Color = Color3.fromRGB(255, 255, 255); s1.Transparency = 1
    s1.LineJoinMode = Enum.LineJoinMode.Round

    local ring2 = Instance.new("Frame", sg)
    ring2.AnchorPoint = Vector2.new(0.5, 0.5); ring2.Position = UDim2.fromScale(0.5, 0.5); ring2.Size = UDim2.fromScale(0.88, 0.88)
    ring2.BackgroundTransparency = 1; ring2.BorderSizePixel = 0
    Instance.new("UICorner", ring2).CornerRadius = UDim.new(1, 0)
    local s2 = Instance.new("UIStroke", ring2)
    s2.Thickness = 1.5; s2.Color = Color3.fromRGB(255, 255, 255); s2.Transparency = 1
    s2.LineJoinMode = Enum.LineJoinMode.Round

    local fill = Instance.new("Frame", sg)
    fill.AnchorPoint = Vector2.new(0.5, 0.5); fill.Position = UDim2.fromScale(0.5, 0.5); fill.Size = UDim2.fromScale(0.94, 0.94)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255); fill.BackgroundTransparency = 1; fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local fIn = 0; local prev = os.clock(); local pulse = 0
    RSvc.Heartbeat:Connect(function()
        local now = os.clock(); local dt = now - prev; prev = now
        pulse = pulse + dt
        local hrp = LP.Character and (LP.Character:FindFirstChild("HumanoidRootPart") or LP.Character.PrimaryPart)
        local act = CFG.parry_on and CFG.parry_show_circle and hrp
        if act then fIn = math.min(1, fIn + dt*5) else fIn = math.max(0, fIn - dt*5) end
        if fIn <= 0.001 then base.Transparency = 1 return end
        if act then
            local hasE = false
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP and pl.Character and isKiller(pl) then
                    local er = pl.Character:FindFirstChild("HumanoidRootPart")
                    if er then
                        local hu = pl.Character:FindFirstChildOfClass("Humanoid")
                        if hu and hu.Health > 0 and (er.Position - hrp.Position).Magnitude <= (CFG.parry_radius or 14) then hasE = true; break end
                    end
                end
            end
            local r = (CFG.parry_radius or 14) * 2
            base.Size = Vector3.new(r, 0.05, r)
            base.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2.95, 0))
            local p = math.sin(pulse * (hasE and 7 or 4)) * (hasE and 0.14 or 0.06)
            s1.Color = Color3.fromRGB(255,255,255); s2.Color = Color3.fromRGB(255,255,255)
            fill.BackgroundColor3 = Color3.fromRGB(255,255,255)
            s1.Transparency = math.clamp(1 - (fIn * ((hasE and 0.85 or 0.65) + p)), 0, 1)
            s2.Transparency = math.clamp(1 - (fIn * ((hasE and 0.6 or 0.4) + p*0.6)), 0, 1)
            fill.BackgroundTransparency = math.clamp(1 - (fIn * ((hasE and 0.10 or 0.05) + p*0.3)), 0, 1)
        else
            s1.Transparency = math.clamp(1 - (fIn * 0.65), 0, 1)
            s2.Transparency = math.clamp(1 - (fIn * 0.4), 0, 1)
            fill.BackgroundTransparency = math.clamp(1 - (fIn * 0.05), 0, 1)
        end
    end)
end

-- ============================================================
-- SILENT VEIL
-- ============================================================
local VD = {
    VeilShowTracker   = CFG.veil_show_tracker,
    VeilAutoPredict   = CFG.veil_auto_predict,
    VeilSpearSpeed    = 165,
    VeilAuraSpearSpeed= 165,
    VeilGravity       = 103,
    VeilAuraSpearGravity = 96.5,
    VeilLeadMultiplier= 1.4,
}

pcall(function()
    if typeof(Drawing) ~= "table" or not Drawing.new then return end
    local V = VeilVisuals
    local BLACK  = Color3.fromRGB(0, 0, 0)
    local WHITE  = Color3.fromRGB(255, 255, 255)
    V.FOVOuterRing = Drawing.new("Circle"); V.FOVOuterRing.Color = BLACK; V.FOVOuterRing.Thickness = 3; V.FOVOuterRing.Filled = false; V.FOVOuterRing.Transparency = 0.4; V.FOVOuterRing.Visible = false; V.FOVOuterRing.NumSides = 90
    V.FOVMainRing = Drawing.new("Circle"); V.FOVMainRing.Color = ACCENT; V.FOVMainRing.Thickness = 1.6; V.FOVMainRing.Filled = false; V.FOVMainRing.Transparency = 0.85; V.FOVMainRing.Visible = false; V.FOVMainRing.NumSides = 90
    V.FOVInnerRing = Drawing.new("Circle"); V.FOVInnerRing.Color = ACCENT; V.FOVInnerRing.Thickness = 1; V.FOVInnerRing.Filled = false; V.FOVInnerRing.Transparency = 0.35; V.FOVInnerRing.Visible = false; V.FOVInnerRing.NumSides = 90
    V.FOVCrossLines = {}
    for i = 1, 4 do
        local line = Drawing.new("Line"); line.Color = WHITE; line.Thickness = 1.5; line.Transparency = 0.9; line.Visible = false
        V.FOVCrossLines[i] = line
    end
    V.FOVTicks = {}
    for i = 1, 4 do
        local line = Drawing.new("Line"); line.Color = ACCENT; line.Thickness = 2.2; line.Transparency = 0.95; line.Visible = false
        V.FOVTicks[i] = line
    end
    V.TrackerOuterRing = Drawing.new("Circle"); V.TrackerOuterRing.Color = BLACK; V.TrackerOuterRing.Thickness = 3; V.TrackerOuterRing.Filled = false; V.TrackerOuterRing.Transparency = 0.3; V.TrackerOuterRing.NumSides = 40; V.TrackerOuterRing.Visible = false
    V.TrackerMainRing = Drawing.new("Circle"); V.TrackerMainRing.Color = ACCENT; V.TrackerMainRing.Thickness = 1.6; V.TrackerMainRing.Filled = false; V.TrackerMainRing.Transparency = 0.9; V.TrackerMainRing.NumSides = 40; V.TrackerMainRing.Visible = false
    V.TrackerDotFill = Drawing.new("Circle"); V.TrackerDotFill.Color = ACCENT; V.TrackerDotFill.Thickness = 1; V.TrackerDotFill.Filled = true; V.TrackerDotFill.Transparency = 0.9; V.TrackerDotFill.Radius = 3; V.TrackerDotFill.NumSides = 20; V.TrackerDotFill.Visible = false
    V.TrackerDotOutline = Drawing.new("Circle"); V.TrackerDotOutline.Color = BLACK; V.TrackerDotOutline.Thickness = 3; V.TrackerDotOutline.Filled = false; V.TrackerDotOutline.Transparency = 0.3; V.TrackerDotOutline.Radius = 6; V.TrackerDotOutline.NumSides = 20; V.TrackerDotOutline.Visible = false
    V.TrackerLine = Drawing.new("Line"); V.TrackerLine.Color = ACCENT; V.TrackerLine.Thickness = 1.5; V.TrackerLine.Transparency = 0.6; V.TrackerLine.Visible = false
end)

local function Veil_IsSurvivorVeil(p)
    if not p or not p.Team or not p.Team.Name then return false end
    return string.find(string.lower(p.Team.Name), "survivor", 1, true) ~= nil
end

local function Veil_solvePitch(p, d, dy)
    d = math.max(d, 0.1)
    local s2 = p.v0 * p.v0
    local root = s2 * s2 - p.g * (p.g * d * d + 2 * dy * s2)
    if root < 0 then root = 0 end
    local tanTheta = (s2 - math.sqrt(root)) / (p.g * d)
    local theta = math.atan(tanTheta)
    local t = d / (p.v0 * math.cos(theta))
    return theta, t
end

local function Veil_getCharacterVelocity(char)
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    if not root or not root:IsA("BasePart") then return Vector3.zero end
    local now = os.clock()
    local last = VeilState.velHistory[char]
    local measured = Vector3.zero
    if last and now - last.t > 0.02 then
        measured = (root.Position - last.pos) / (now - last.t)
        if measured.Magnitude > 150 then measured = last.smooth or Vector3.zero end
    end
    local smooth = last and last.smooth or measured
    smooth = smooth:Lerp(measured, 0.65)
    VeilState.velHistory[char] = { pos = root.Position, t = now, smooth = smooth }
    if smooth.Magnitude < 1 then return Vector3.zero end
    return Vector3.new(smooth.X, 0, smooth.Z)
end

Players.PlayerRemoving:Connect(function(p)
    if p.Character then VeilState.velHistory[p.Character] = nil end
end)

local function Veil_UpdateFOVVisuals(center)
    local V = VeilVisuals
    if not V.FOVOuterRing then return end
    local radius = CFG.veil_fov or 150
    local t = tick()
    local pulse = (math.sin(t * 3) + 1) * 0.5
    local slowPulse = (math.sin(t * 1.2) + 1) * 0.5
    V.FOVOuterRing.Position = center; V.FOVOuterRing.Radius = radius + 2; V.FOVOuterRing.Transparency = 0.3 + pulse * 0.15; V.FOVOuterRing.Visible = true
    V.FOVMainRing.Position = center; V.FOVMainRing.Radius = radius; V.FOVMainRing.Transparency = 0.7 + pulse * 0.25; V.FOVMainRing.Visible = true
    V.FOVInnerRing.Position = center; V.FOVInnerRing.Radius = radius - 10; V.FOVInnerRing.Transparency = 0.25 + slowPulse * 0.2; V.FOVInnerRing.Visible = true
    local gap, armLen = 4, 12
    V.FOVCrossLines[1].From = Vector2.new(center.X, center.Y - gap); V.FOVCrossLines[1].To = Vector2.new(center.X, center.Y - gap - armLen); V.FOVCrossLines[1].Visible = true
    V.FOVCrossLines[2].From = Vector2.new(center.X, center.Y + gap); V.FOVCrossLines[2].To = Vector2.new(center.X, center.Y + gap + armLen); V.FOVCrossLines[2].Visible = true
    V.FOVCrossLines[3].From = Vector2.new(center.X - gap, center.Y); V.FOVCrossLines[3].To = Vector2.new(center.X - gap - armLen, center.Y); V.FOVCrossLines[3].Visible = true
    V.FOVCrossLines[4].From = Vector2.new(center.X + gap, center.Y); V.FOVCrossLines[4].To = Vector2.new(center.X + gap + armLen, center.Y); V.FOVCrossLines[4].Visible = true
    local tickLen = 9
    for i = 1, 4 do
        local angle = (i - 1) * math.pi / 2
        local dirX, dirY = math.cos(angle), math.sin(angle)
        V.FOVTicks[i].From = Vector2.new(center.X + dirX * radius, center.Y + dirY * radius)
        V.FOVTicks[i].To = Vector2.new(center.X + dirX * (radius - tickLen), center.Y + dirY * (radius - tickLen))
        V.FOVTicks[i].Visible = true
    end
end

local function Veil_UpdateTrackerVisuals(pos, dist)
    local V = VeilVisuals
    if not V.TrackerOuterRing then return end
    local t = tick()
    local pulse = (math.sin(t * 4) + 1) * 0.5
    local r = math.clamp(1000 / math.max(dist, 1), 20, 48)
    V.TrackerOuterRing.Position = pos; V.TrackerOuterRing.Radius = r + 3; V.TrackerOuterRing.Transparency = 0.25 + pulse * 0.15; V.TrackerOuterRing.Visible = true
    V.TrackerMainRing.Position = pos; V.TrackerMainRing.Radius = r; V.TrackerMainRing.Transparency = 0.75 + pulse * 0.2; V.TrackerMainRing.Visible = true
    V.TrackerDotFill.Position = pos; V.TrackerDotFill.Radius = 2.5 + pulse * 1.2; V.TrackerDotFill.Transparency = 0.85 + pulse * 0.15; V.TrackerDotFill.Visible = true
    V.TrackerDotOutline.Position = pos; V.TrackerDotOutline.Radius = 5 + pulse * 1.5; V.TrackerDotOutline.Transparency = 0.35; V.TrackerDotOutline.Visible = true
end

local function Veil_UpdateAimbot()
    if GetRole() ~= "Killer" then
        VeilState.target = nil; VeilState.lookVector = nil
        local V = VeilVisuals
        if V.FOVOuterRing then V.FOVOuterRing.Visible = false end
        if V.FOVMainRing then V.FOVMainRing.Visible = false end
        if V.FOVInnerRing then V.FOVInnerRing.Visible = false end
        if V.FOVCrossLines then for _, s in ipairs(V.FOVCrossLines) do s.Visible = false end end
        if V.FOVTicks then for _, s in ipairs(V.FOVTicks) do s.Visible = false end end
        if V.TrackerOuterRing then V.TrackerOuterRing.Visible = false end
        if V.TrackerMainRing then V.TrackerMainRing.Visible = false end
        if V.TrackerDotFill then V.TrackerDotFill.Visible = false end
        if V.TrackerDotOutline then V.TrackerDotOutline.Visible = false end
        if V.TrackerLine then V.TrackerLine.Visible = false end
        return
    end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    if CFG.veil_show_fov and CFG.veil_on then Veil_UpdateFOVVisuals(center)
    else
        local V = VeilVisuals
        if V.FOVOuterRing then V.FOVOuterRing.Visible = false end
        if V.FOVMainRing then V.FOVMainRing.Visible = false end
        if V.FOVInnerRing then V.FOVInnerRing.Visible = false end
        if V.FOVCrossLines then for _, s in ipairs(V.FOVCrossLines) do s.Visible = false end end
        if V.FOVTicks then for _, s in ipairs(V.FOVTicks) do s.Visible = false end end
    end
    if not CFG.veil_on then
        VeilState.target = nil; VeilState.lookVector = nil
        local V = VeilVisuals
        if V.TrackerOuterRing then V.TrackerOuterRing.Visible = false end
        if V.TrackerMainRing then V.TrackerMainRing.Visible = false end
        if V.TrackerDotFill then V.TrackerDotFill.Visible = false end
        if V.TrackerDotOutline then V.TrackerDotOutline.Visible = false end
        if V.TrackerLine then V.TrackerLine.Visible = false end
        return
    end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local nearest, nearestPart = nil, nil
    local bestDist = CFG.veil_fov or 150
    local bestStudDist = CFG.veil_maxdist or 500
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and Veil_IsSurvivorVeil(p) and p.Character then
            local pc = p.Character
            local isDown = pc:GetAttribute("Knocked") == true or pc:GetAttribute("HookProgressDepleting") == true
            if not isDown then
                local hum = pc:FindFirstChildOfClass("Humanoid")
                local tp = pc:FindFirstChild("UpperTorso") or pc:FindFirstChild("Torso") or pc:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and tp then
                    local sp, on = cam:WorldToViewportPoint(tp.Position)
                    if on and sp.Z > 0 then
                        local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if sd < bestDist then
                            local studDist = (tp.Position - hrp.Position).Magnitude
                            if studDist <= bestStudDist then bestDist = sd; nearest = p; nearestPart = tp end
                        end
                    end
                end
            end
        end
    end
    if nearest and nearest.Character and nearestPart then
        local tp = nearestPart.Position
        local hand = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
        local origin = (hand and hand:IsA("BasePart")) and hand.Position or hrp.Position
        local dir = tp - origin
        local dist = dir.Magnitude
        if dist > 0.1 and dist <= (CFG.veil_maxdist or 500) then
            local isAura = char:GetAttribute("special") == true
            local prof
            if isAura then
                prof = { v0 = VD.VeilAuraSpearSpeed, g = VD.VeilAuraSpearGravity, windup = 0.10, latency = 0.04, maxlead = 25, scale = VD.VeilLeadMultiplier }
            else
                prof = { v0 = VD.VeilSpearSpeed, g = VD.VeilGravity, windup = 0.10, latency = 0.04, maxlead = 45, scale = VD.VeilLeadMultiplier }
            end
            local aimPoint = tp
            if VD.VeilAutoPredict then
                local vel = Veil_getCharacterVelocity(nearest.Character)
                if vel.Magnitude > 0.5 then
                    local h0 = Vector3.new(dir.X, 0, dir.Z)
                    local _, tFlight = Veil_solvePitch(prof, h0.Magnitude, dir.Y)
                    local ping = 0.08
                    pcall(function() ping = math.clamp(LP:GetNetworkPing(), 0, 0.35) end)
                    local delay = tFlight + prof.windup + ping + prof.latency
                    for _ = 1, 2 do
                        local lead = vel * delay * prof.scale
                        local maxLead = math.clamp(dist * 0.6, 3, prof.maxlead)
                        if lead.Magnitude > maxLead then lead = lead.Unit * maxLead end
                        aimPoint = tp + lead
                        local ad = aimPoint - origin
                        local ah = Vector3.new(ad.X, 0, ad.Z)
                        local _, t2 = Veil_solvePitch(prof, math.max(ah.Magnitude, 0.1), ad.Y)
                        delay = t2 + prof.windup + ping + prof.latency
                    end
                end
            end
            local adir = aimPoint - origin
            local ah = Vector3.new(adir.X, 0, adir.Z)
            local ahDist = ah.Magnitude
            local pitch = Veil_solvePitch(prof, ahDist, adir.Y)
            if ahDist > 0.001 then
                VeilState.lookVector = ah.Unit * math.cos(pitch) + Vector3.new(0, math.sin(pitch), 0)
            else
                VeilState.lookVector = adir.Unit
            end
            VeilState.target = nearest
            if VD.VeilShowTracker then
                local sp, vis = cam:WorldToViewportPoint(tp)
                if vis and sp.Z > 0 then
                    local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if screenDist <= (CFG.veil_fov or 150) + 100 then
                        Veil_UpdateTrackerVisuals(Vector2.new(sp.X, sp.Y), dist)
                        local bottomCenter = Vector2.new(center.X, cam.ViewportSize.Y)
                        local V = VeilVisuals
                        if V.TrackerLine then V.TrackerLine.From = bottomCenter; V.TrackerLine.To = Vector2.new(sp.X, sp.Y); V.TrackerLine.Visible = true end
                    else
                        local V = VeilVisuals
                        if V.TrackerOuterRing then V.TrackerOuterRing.Visible = false end
                        if V.TrackerMainRing then V.TrackerMainRing.Visible = false end
                        if V.TrackerDotFill then V.TrackerDotFill.Visible = false end
                        if V.TrackerDotOutline then V.TrackerDotOutline.Visible = false end
                        if V.TrackerLine then V.TrackerLine.Visible = false end
                    end
                end
            else
                local V = VeilVisuals
                if V.TrackerOuterRing then V.TrackerOuterRing.Visible = false end
                if V.TrackerMainRing then V.TrackerMainRing.Visible = false end
                if V.TrackerDotFill then V.TrackerDotFill.Visible = false end
                if V.TrackerDotOutline then V.TrackerDotOutline.Visible = false end
                if V.TrackerLine then V.TrackerLine.Visible = false end
            end
        end
    else
        VeilState.target = nil; VeilState.lookVector = nil
        local V = VeilVisuals
        if V.TrackerOuterRing then V.TrackerOuterRing.Visible = false end
        if V.TrackerMainRing then V.TrackerMainRing.Visible = false end
        if V.TrackerDotFill then V.TrackerDotFill.Visible = false end
        if V.TrackerDotOutline then V.TrackerDotOutline.Visible = false end
        if V.TrackerLine then V.TrackerLine.Visible = false end
    end
end

Scheduler:Add("VeilAim", Veil_UpdateAimbot, 0.033)

-- ============================================================
-- UNIFIED HOOK
-- ============================================================
do
    if type(hookmetamethod) == "function" and type(newcclosure) == "function" and type(getnamecallmethod) == "function" then
        local OLD
        OLD = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local m
            pcall(function() m = getnamecallmethod() end)
            if m == "Kick" and self == LP then return nil end
            if m ~= "FireServer" then return OLD(self, ...) end
            local tofDir = _G.KZ_ToFAimDir
            local veilDir = VeilState.lookVector
            local hasToF = CFG.tof_on and typeof(tofDir) == "Vector3"
            local hasVeil = CFG.veil_on and typeof(veilDir) == "Vector3" and GetRole() == "Killer"
            if not hasToF and not hasVeil then return OLD(self, ...) end
            if type(self) ~= "userdata" and type(self) ~= "table" then return OLD(self, ...) end
            local args = table.pack(...)
            local n = args.n
            if hasVeil then
                local sn = ""
                pcall(function() sn = tostring(self.Name or "") end)
                if sn == "Spearthrow" then
                    if typeof(args[1]) == "Vector3" then args[1] = veilDir end
                    return OLD(self, table.unpack(args, 1, n))
                end
            end
            if hasToF then
                local match = (RC.tof and self == RC.tof)
                if not match then
                    local sn = ""
                    pcall(function() sn = tostring(self.Name or "") end)
                    if sn == "Fire" or sn == "Shoot" then
                        local fn = ""
                        pcall(function() fn = self:GetFullName():lower() end)
                        if fn:find("twist") or fn:find("fate") or fn:find("tof") then match = true end
                    end
                end
                if match then
                    for i = 1, n do
                        local v = args[i]
                        if typeof(v) == "Vector3" and v.Magnitude <= 5 then
                            args[i] = tofDir
                            break
                        end
                    end
                    return OLD(self, table.unpack(args, 1, n))
                end
            end
            return OLD(self, table.unpack(args, 1, n))
        end))
    end
end

-- ============================================================
-- AUTO GEN
-- ============================================================
pcall(function()
    local SUCCESS_MIN, SUCCESS_MAX = 102, 116
    local NEUTRAL_MIN, NEUTRAL_MAX = 116, 159
    local TriggerDelay = 0.035
    local LastTrigger = 0
    local Busy = false
    local ScourgeActive = false
    local KingScourgeStart, KingScourgeEnd
    pcall(function()
        local KP = RS:WaitForChild("Remotes"):WaitForChild("KillerPerks"):WaitForChild("kingscourge")
        KingScourgeStart = KP:WaitForChild("KingScourgeStart")
        KingScourgeEnd = KP:WaitForChild("KingScourgeEnd")
    end)
    local Check, Line, Goal, Action
    local function RefreshRefs()
        pcall(function()
            local SG = PG:FindFirstChild("SkillCheckPromptGui")
            if SG then
                Check = SG:FindFirstChild("Check")
                if Check then Line = Check:FindFirstChild("Line"); Goal = Check:FindFirstChild("Goal") end
            end
            local SV = PG:FindFirstChild("Survivor-mob")
            if SV then local C = SV:FindFirstChild("Controls"); if C then Action = C:FindFirstChild("action") end end
        end)
    end
    RefreshRefs()
    task.spawn(function() while true do task.wait(0.5); RefreshRefs() end end)
    local function TriggerAction()
        if not Action then RefreshRefs() end
        if not Action then return false end
        local Now = os.clock()
        if Now - LastTrigger < TriggerDelay then return false end
        LastTrigger = Now
        pcall(function() if Action:IsA("GuiButton") then Action:Activate() end end)
        if typeof(firesignal) == "function" then pcall(function() firesignal(Action.MouseButton1Down) end) end
        return true
    end
    local function GetAngle()
        if not Line or not Goal then return nil end
        return tonumber(Line.Rotation) or 0, tonumber(Goal.Rotation) or 0
    end
    local function IsSuccess()
        local LR, GR = GetAngle()
        if not LR then return false end
        return LR >= GR + SUCCESS_MIN and LR <= GR + SUCCESS_MAX
    end
    local function IsNeutral()
        local LR, GR = GetAngle()
        if not LR then return false end
        return LR > GR + NEUTRAL_MIN and LR <= GR + NEUTRAL_MAX
    end
    local function InstantNormal()
        if not Check or not Line or not Goal then RefreshRefs() end
        if not Check or not Line or not Goal or not Check.Visible then return end
        Line.Rotation = (tonumber(Goal.Rotation) or 0) + 109
        TriggerAction()
    end
    local function InstantScourge()
        if not CFG.gene_on or not ScourgeActive then return end
        if not Line or not Goal then RefreshRefs() end
        if not Line or not Goal then return end
        Line.Rotation = (tonumber(Goal.Rotation) or 0) + 109
        TriggerAction()
    end
    if KingScourgeStart then
        KingScourgeStart.OnClientEvent:Connect(function()
            if not CFG.gene_on then return end
            ScourgeActive = true; Busy = false
            task.defer(function() if CFG.gene_on and CFG.gene_method == "INSTANT" then InstantScourge() end end)
        end)
    end
    if KingScourgeEnd then
        KingScourgeEnd.OnClientEvent:Connect(function() ScourgeActive = false; Busy = false end)
    end
    local PreviousVisible = false
    RSvc.RenderStepped:Connect(function()
        if not CFG.gene_on then PreviousVisible = false; return end
        if not Check then RefreshRefs() end
        if not Check then return end
        local Visible = Check.Visible
        local Mode = CFG.gene_method or "PERFECT"
        if Visible and not PreviousVisible then
            Busy = false
            if not ScourgeActive and Mode == "INSTANT" then InstantNormal() end
        end
        PreviousVisible = Visible
        if Visible and not ScourgeActive and not Busy then
            local ShouldTrigger = false
            if Mode == "PERFECT" then ShouldTrigger = IsSuccess()
            elseif Mode == "NEUTRAL" then ShouldTrigger = IsNeutral() end
            if ShouldTrigger then
                Busy = true; TriggerAction()
                task.delay(0.07, function() Busy = false end)
            end
        end
        if ScourgeActive and Visible then
            if Mode == "PERFECT" and not Busy and IsSuccess() then
                Busy = true; TriggerAction()
                task.delay(0.06, function() Busy = false end)
            elseif Mode == "NEUTRAL" and not Busy and IsNeutral() then
                Busy = true; TriggerAction()
                task.delay(0.06, function() Busy = false end)
            elseif Mode == "INSTANT" then
                local CG = tonumber(Goal.Rotation) or 0
                local CL = tonumber(Line.Rotation) or 0
                if math.abs(CL - CG) > 130 then Busy = false end
            end
        end
    end)
    LP.CharacterAdded:Connect(function()
        Busy = false; ScourgeActive = false; PreviousVisible = false
    end)
end)

-- ============================================================
-- AUTO PARRY
-- ============================================================
pcall(function()
    local VALID = {
        ["122812055447896"]=1,["133963973694098"]=1,["117042998468241"]=1,["135002183282873"]=1,
        ["121216847022485"]=1,["132817836308238"]=1,["129784271201071"]=1,["82666958311998"]=1,
        ["78432063483146"]=1,["118907603246885"]=1,["139369275981139"]=1,["110355011987939"]=1,
        ["111920872708571"]=1,["105374834496520"]=1,["138720291317243"]=1,["106871536134254"]=1,
        ["130593238885843"]=1,["115244153053858"]=1,["74968262036854"]=1,["113255068724446"]=1,
        ["98163597193511"]=1,["80411309607666"]=1,["101344487600812"]=1,
    }
    local lastP, Att = 0, {}
    local function doP()
        if not CFG.parry_on then return end
        local now = os.clock()
        if now - lastP < (CFG.parry_aggro and 0.04 or 0.11) then return end
        lastP = now
        if RC.parry then for _=1,8 do pcall(function() RC.parry:FireServer() end) end end
        pcall(function()
            local mob = PG:FindFirstChild("Survivor-mob")
            if mob then
                local ctrl = mob:FindFirstChild("Controls")
                if ctrl then
                    local btn = ctrl:FindFirstChild("action") or ctrl:FindFirstChildWhichIsA("ImageButton")
                    if btn and typeof(firesignal) == "function" then
                        firesignal(btn.MouseButton1Down); task.wait(0.005); firesignal(btn.MouseButton1Up)
                    end
                end
            end
        end)
    end
    _G.KZ_ManualParry = doP
    local function bind(m)
        if not m or Att[m] then return end
        Att[m] = true
        local hum = m:FindFirstChildOfClass("Humanoid")
        local anim = hum and hum:FindFirstChildOfClass("Animator")
        if not anim then return end
        anim.AnimationPlayed:Connect(function(track)
            if not CFG.parry_on or not track or not track.Animation then return end
            local id = tostring(track.Animation.AnimationId or ""):match("%d+") or ""
            if not VALID[id] then return end
            local my, en = rtp(LP.Character), rtp(m)
            if my and en and (my.Position - en.Position).Magnitude <= CFG.parry_radius + CFG.parry_sensitive * 0.01 then doP() end
        end)
    end
    task.spawn(function()
        while true do
            task.wait(1.2)
            for _, p in ipairs(Players:GetPlayers()) do if p.Character then bind(p.Character) end end
            for _, o in ipairs(Workspace:GetChildren()) do
                if o:IsA("Model") and o:FindFirstChildOfClass("Humanoid") then bind(o) end
            end
        end
    end)
    UIS.InputBegan:Connect(function(i, g) if g then return end if i.KeyCode == Enum.KeyCode.P then doP() end end)
end)

-- ============================================================
-- FAST VAULT
-- ============================================================
pcall(function()
    local last = 0
    local function trig()
        if os.clock() - last < 0.3 then return end
        last = os.clock()
        if RC.fastvault then pcall(function() RC.fastvault:FireServer() end) end
    end
    local function apply(ch)
        local hum = ch:FindFirstChildOfClass("Humanoid")
        local anim = hum and hum:FindFirstChildOfClass("Animator")
        if not anim then return end
        anim.AnimationPlayed:Connect(function(track)
            if not CFG.fast_vault then return end
            if not track or not track.Animation then return end
            local n = (track.Animation.Name or ""):lower()
            if n:find("vault") or n:find("window") or n:find("climb") or n:find("pallet") then trig() end
        end)
    end
    LP.CharacterAdded:Connect(function(c) task.wait(1.2) apply(c) end)
    if LP.Character then task.spawn(function() apply(LP.Character) end) end
end)

-- ============================================================
-- ESP (HIGHLIGHT ONLY)
-- ============================================================
pcall(function()
    local highlights = {}
    local genHL, trackedGens = {}, {}

    local function getCam() return workspace.CurrentCamera end

    local function updatePlayer(plr, cam)
        if plr == LP then return end
        local char = plr.Character
        local head = char and char:FindFirstChild("Head")
        if not char or not head then
            if highlights[plr] then
                highlights[plr].FillTransparency = 1
                highlights[plr].OutlineTransparency = 1
                highlights[plr].Adornee = nil
            end
            return
        end
        local team = plr.Team
        local isK = team and team.Name == "Killer"
        local isS = team and (team.Name == "Survivors" or team.Name == "Survivor")
        if not isK and not isS then
            local role = char:GetAttribute("Role") or plr:GetAttribute("Role")
            if type(role) == "string" then
                local r = role:lower()
                isK = r:find("killer") ~= nil
                isS = r:find("survivor") ~= nil
            end
        end
        if isK and not CFG.esp_k then
            if highlights[plr] then highlights[plr].Enabled = false end
            return
        end
        if isS and not CFG.esp_s then
            if highlights[plr] then highlights[plr].Enabled = false end
            return
        end
        if not isK and not isS then
            if highlights[plr] then highlights[plr].Enabled = false end
            return
        end
        local color = Color3.fromRGB(255, 255, 255)
        if isK then
            color = Color3.fromRGB(255, 80, 80)
        else
            local hum = char:FindFirstChildOfClass("Humanoid")
            if char:GetAttribute("IsHooked") then color = Color3.fromRGB(255, 110, 80)
            elseif char:GetAttribute("Knocked") then color = Color3.fromRGB(255, 170, 80)
            elseif hum and hum.Health < hum.MaxHealth then color = Color3.fromRGB(255, 255, 120)
            else color = Color3.fromRGB(100, 255, 100) end
        end
        if not highlights[plr] or not highlights[plr].Parent then
            local hl = Instance.new("Highlight")
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = cam
            highlights[plr] = hl
        end
        local hl = highlights[plr]
        if hl.Parent ~= cam then hl.Parent = cam end
        hl.Adornee = char
        hl.FillColor = color
        hl.OutlineColor = color
        hl.FillTransparency = CFG.esp_out and 1 or 0.35
        hl.OutlineTransparency = 0
        hl.Enabled = true
    end

    local function updateGen(obj)
        if not obj or not obj.Parent then return end
        if not CFG.esp_g then
            if genHL[obj] then genHL[obj].Enabled = false end
            return
        end
        local progress = obj:GetAttribute("RepairProgress")
        if progress == nil then return end
        local isFull = progress >= 100
        local cam = getCam()
        if not cam then return end
        if not genHL[obj] or not genHL[obj].Parent then
            local hl = Instance.new("Highlight")
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = cam
            genHL[obj] = hl
        end
        local hl = genHL[obj]
        if hl.Parent ~= cam then hl.Parent = cam end
        hl.Adornee = obj
        hl.Enabled = true
        if isFull then
            hl.FillColor = Color3.fromRGB(0, 255, 0)
            hl.OutlineColor = Color3.fromRGB(0, 255, 0)
            hl.FillTransparency = CFG.esp_out and 1 or 0.5
        else
            hl.FillColor = Color3.fromRGB(80, 220, 120)
            hl.OutlineColor = Color3.fromRGB(80, 220, 120)
            hl.FillTransparency = CFG.esp_out and 1 or 0.55
        end
        hl.OutlineTransparency = 0
    end

    local function scanGens()
        local map = workspace:FindFirstChild("Map") or workspace
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and obj:GetAttribute("RepairProgress") ~= nil then
                trackedGens[obj] = true
                updateGen(obj)
            end
        end
    end

    RSvc.Heartbeat:Connect(function()
        local cam = getCam()
        if not cam then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            pcall(updatePlayer, plr, cam)
        end
        for gen in pairs(trackedGens) do
            if gen and gen.Parent then pcall(updateGen, gen)
            else
                if genHL[gen] then genHL[gen]:Destroy() end
                genHL[gen], trackedGens[gen] = nil, nil
            end
        end
    end)

    task.spawn(function() task.wait(1); scanGens() end)
    local map = workspace:FindFirstChild("Map") or workspace
    map.DescendantAdded:Connect(function(child)
        task.defer(function()
            if child:IsA("Model") and child:GetAttribute("RepairProgress") ~= nil then
                trackedGens[child] = true
                updateGen(child)
            end
        end)
    end)
    Players.PlayerRemoving:Connect(function(plr)
        if highlights[plr] then highlights[plr]:Destroy() highlights[plr] = nil end
    end)
end)

-- ============================================================
-- STUN NOTIF
-- ============================================================
pcall(function()
    local stunHead, stunSpin = {}, 0
    local stunGui, stunCard, stunOn = nil, nil, false

    local function isStunned(ch)
        if not ch then return false end
        local h = ch:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then return false end
        if ch:GetAttribute("Stunned") == true or ch:GetAttribute("Stunned") == 1 then return true end
        if ch:GetAttribute("IsStunned") == true or ch:GetAttribute("stun") == true then return true end
        local ok, s = pcall(function() return h:GetState() end)
        if ok and s then
            if s == Enum.HumanoidStateType.FallingDown or s == Enum.HumanoidStateType.Ragdoll then return true end
        end
        return false
    end

    local function makeStunHead(root, cam)
        local bb = Instance.new("BillboardGui")
        bb.Name = "KZ_StunHead"
        bb.Size = UDim2.fromOffset(30, 30)
        bb.StudsOffset = Vector3.new(0, 3.4, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = root
        bb.Parent = cam
        local ring = Instance.new("Frame", bb)
        ring.Size = UDim2.fromScale(1, 1)
        ring.BackgroundTransparency = 1
        Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
        local st = Instance.new("UIStroke", ring)
        st.Color = Color3.fromRGB(200, 200, 210)
        st.Thickness = 2.5
        st.Transparency = 0.25
        local g = Instance.new("UIGradient", st)
        g.Name = "G"
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.35, 0.2),
            NumberSequenceKeypoint.new(0.7, 1),
            NumberSequenceKeypoint.new(1, 1),
        })
        return bb
    end

    local function killStunHead(p)
        if stunHead[p] then pcall(function() stunHead[p]:Destroy() end) end
        stunHead[p] = nil
    end

    local function wipeToast()
        for _, g in ipairs(PG:GetChildren()) do
            if g.Name == "KZ_StunToast" then pcall(function() g:Destroy() end) end
        end
        stunGui, stunCard, stunOn = nil, nil, false
    end

    local function showStunToast()
        if stunOn and stunGui and stunGui.Parent then return end
        wipeToast()
        stunGui = Instance.new("ScreenGui")
        stunGui.Name = "KZ_StunToast"
        stunGui.ResetOnSpawn = false
        stunGui.IgnoreGuiInset = true
        stunGui.DisplayOrder = 1000005
        stunGui.Parent = PG
        stunCard = Instance.new("Frame", stunGui)
        stunCard.AnchorPoint = Vector2.new(1, 1)
        stunCard.Position = UDim2.new(1, 24, 1, -18)
        stunCard.Size = UDim2.fromOffset(132, 34)
        stunCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        stunCard.BackgroundTransparency = 0.4
        stunCard.BorderSizePixel = 0
        Instance.new("UICorner", stunCard).CornerRadius = UDim.new(0, 9)
        local stroke = Instance.new("UIStroke", stunCard)
        stroke.Color = Color3.fromRGB(170, 170, 180)
        stroke.Thickness = 1
        stroke.Transparency = 0.45
        local title = Instance.new("TextLabel", stunCard)
        title.Size = UDim2.new(1, 0, 1, 0)
        title.BackgroundTransparency = 1
        title.Text = "STUN KILLER"
        title.TextColor3 = Color3.fromRGB(220, 220, 230)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 12
        title.TextXAlignment = Enum.TextXAlignment.Center
        stunOn = true
        TS:Create(stunCard, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -12, 1, -18)
        }):Play()
    end

    RSvc.RenderStepped:Connect(function(dt)
        stunSpin = stunSpin + dt * 280
        if not CFG.stun_on then
            for _, p in ipairs(Players:GetPlayers()) do killStunHead(p) end
            if stunOn or stunGui then wipeToast() end
            return
        end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local any = false
        for _, p in ipairs(Players:GetPlayers()) do
            if not isKiller(p) then killStunHead(p); continue end
            local ch = p.Character
            local root = ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart)
            if root and isStunned(ch) then
                any = true
                if not stunHead[p] or not stunHead[p].Parent then
                    stunHead[p] = makeStunHead(root, cam)
                end
                local bb = stunHead[p]
                if bb.Parent ~= cam then bb.Parent = cam end
                bb.Adornee = root
                local g = bb:FindFirstChild("G", true)
                if g then g.Rotation = stunSpin % 360 end
            else killStunHead(p) end
        end
        if any then showStunToast() else if stunOn or stunGui then wipeToast() end end
    end)

    Players.PlayerRemoving:Connect(function(p) killStunHead(p) end)
end)

-- ============================================================
-- FOV LOCK + AMBIENT + BOOST
-- ============================================================
pcall(function()
    local changing = false
    local conn
    local function bind()
        if conn then pcall(function() conn:Disconnect() end) end
        local c = Workspace.CurrentCamera
        if not c then return end
        conn = c:GetPropertyChangedSignal("FieldOfView"):Connect(function()
            if not CFG.fov_lock or changing then return end
            local tgt = tonumber(CFG.fov_value) or 120
            if math.abs(c.FieldOfView - tgt) > 0.5 then
                changing = true; c.FieldOfView = tgt; changing = false
            end
        end)
    end
    bind()
    Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() task.wait(0.2); bind() end)
    task.spawn(function()
        while true do
            task.wait(0.5)
            if CFG.fov_lock then
                local c = Workspace.CurrentCamera
                if c and math.abs(c.FieldOfView - (CFG.fov_value or 120)) > 0.5 then
                    changing = true; c.FieldOfView = CFG.fov_value or 120; changing = false
                end
            end
        end
    end)
end)

task.spawn(function()
    while true do
        task.wait(1)
        if CFG.ambient then
            pcall(function()
                Lighting.Ambient = Color3.fromRGB(180,180,180)
                Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
                Lighting.Brightness = 3
                Lighting.GlobalShadows = false
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
            end)
        end
        if CFG.boost_fps then pcall(function() if setfpscap then setfpscap(240) end end) end
    end
end)

-- ============================================================
-- PROXIMITY ALERT
-- ============================================================
pcall(function()
    local ag = Instance.new("ScreenGui")
    ag.Name = "KZ_Alert"; ag.ResetOnSpawn = false; ag.IgnoreGuiInset = true
    ag.DisplayOrder = 1000001; ag.Parent = PG
    local al = Instance.new("TextLabel", ag)
    al.Size = UDim2.fromOffset(300, 60); al.Position = UDim2.new(0.5, -150, 0.14, 0)
    al.BackgroundTransparency = 1; al.TextColor3 = Color3.fromRGB(255,255,255)
    al.Font = Enum.Font.GothamBlack; al.TextSize = 32
    al.TextStrokeTransparency = 0; al.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    al.Visible = false
    task.spawn(function()
        while true do
            task.wait(0.2)
            if not CFG.alert then al.Visible = false
            else
                local mr = rtp(LP.Character)
                if mr then
                    local cl = math.huge
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl ~= LP and pl.Character and isKiller(pl) then
                            local hrp = rtp(pl.Character)
                            if hrp then
                                local hu = pl.Character:FindFirstChildOfClass("Humanoid")
                                if hu and hu.Health > 0 then
                                    local d = (hrp.Position - mr.Position).Magnitude
                                    if d < cl then cl = d end
                                end
                            end
                        end
                    end
                    if cl < 26 then
                        local t
                        if cl <= 10 then t = "!!!"
                        elseif cl <= 17 then t = "!!"
                        else t = "!" end
                        al.Text = string.format("%s  (%.0f)", t, cl)
                        al.Visible = true
                    else al.Visible = false end
                else al.Visible = false end
            end
        end
    end)
end)

-- ============================================================
-- ORION UI (FIXED)
-- ============================================================
local Orion = {}

function Orion:CreateOrion(orionName)
    orionName = orionName or "Orion"
    local isClosed = false
    local UserInputService = UIS
    local TweenService = TS

    local ScreenGui = Instance.new("ScreenGui")
    local MainWhiteFrame = Instance.new("Frame")
    local mainCorner = Instance.new("UICorner")
    local MainWhiteFrame_2 = Instance.new("Frame")
    local mainCorner_2 = Instance.new("UICorner")
    local tabFrame = Instance.new("Frame")
    local header = Instance.new("Frame")
    local mainCorner_4 = Instance.new("UICorner")
    local libTitle = Instance.new("TextLabel")
    local closeLib = Instance.new("ImageButton")
    local elementContainer = Instance.new("Frame")
    local mainCorner_5 = Instance.new("UICorner")
    local pagesFolder = Instance.new("Folder")

    ScreenGui.Name = "OrionLib_" .. tostring(os.time())
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    local function getParent()
        if gethui then
            local ok, h = pcall(gethui)
            if ok and h then return h end
        end
        local ok, cg = pcall(function() return CoreGui end)
        if ok and cg then return cg end
        return PG
    end
    ScreenGui.Parent = getParent()

    local Camera = workspace:WaitForChild("Camera")

    MainWhiteFrame.Name = "MainWhiteFrame"
    MainWhiteFrame.Parent = ScreenGui
    MainWhiteFrame.BackgroundColor3 = Color3.fromRGB(139, 0, 23)
    MainWhiteFrame.BorderSizePixel = 0
    MainWhiteFrame.ClipsDescendants = true
    MainWhiteFrame.Position = UDim2.new(0.236969739, 0, 0.360436916, 0)
    MainWhiteFrame.Size = UDim2.new(0, 528, 0, 310)
    mainCorner.CornerRadius = UDim.new(0, 3)
    mainCorner.Parent = MainWhiteFrame

    MainWhiteFrame_2.Name = "MainWhiteFrame"
    MainWhiteFrame_2.Parent = MainWhiteFrame
    MainWhiteFrame_2.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainWhiteFrame_2.BorderSizePixel = 0
    MainWhiteFrame_2.ClipsDescendants = true
    MainWhiteFrame_2.Position = UDim2.new(0.0113636367, 0, 0, 0)
    MainWhiteFrame_2.Size = UDim2.new(0, 525, 0, 310)
    mainCorner_2.CornerRadius = UDim.new(0, 3)
    mainCorner_2.Parent = MainWhiteFrame_2

    tabFrame.Name = "tabFrame"
    tabFrame.Parent = MainWhiteFrame_2
    tabFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
    tabFrame.BorderColor3 = Color3.fromRGB(53, 53, 53)
    tabFrame.ClipsDescendants = true
    tabFrame.Size = UDim2.new(0, 100, 0, 309)

    local tabList = Instance.new("UIListLayout", tabFrame)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0, 2)
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabList.VerticalAlignment = Enum.VerticalAlignment.Top
    local tabPadd = Instance.new("UIPadding", tabFrame)
    tabPadd.PaddingTop = UDim.new(0, 5)
    tabPadd.PaddingRight = UDim.new(0, 2)

    header.Name = "header"
    header.Parent = MainWhiteFrame_2
    header.BackgroundColor3 = Color3.fromRGB(181, 1, 31)
    header.Position = UDim2.new(0.207619041, 0, 0.0258064512, 0)
    header.Size = UDim2.new(0, 408, 0, 43)
    mainCorner_4.CornerRadius = UDim.new(0, 3)
    mainCorner_4.Parent = header

    libTitle.Name = "libTitle"
    libTitle.Parent = header
    libTitle.BackgroundTransparency = 1
    libTitle.Position = UDim2.new(0.0294117648, 0, 0, 0)
    libTitle.Size = UDim2.new(0, 343, 0, 43)
    libTitle.Font = Enum.Font.GothamSemibold
    libTitle.Text = orionName
    libTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    libTitle.TextSize = 18
    libTitle.TextXAlignment = Enum.TextXAlignment.Left

    closeLib.Name = "closeLib"
    closeLib.Parent = header
    closeLib.BackgroundTransparency = 1
    closeLib.Position = UDim2.new(0.91911763, 0, 0.209302321, 0)
    closeLib.Size = UDim2.new(0, 25, 0, 25)
    closeLib.Image = "rbxassetid://4988112250"
    closeLib.MouseButton1Click:Connect(function()
        isClosed = not isClosed
        if isClosed then
            closeLib.Image = "rbxassetid://5165666242"
            TweenService:Create(closeLib, TweenInfo.new(0.10), {Rotation = 360}):Play()
            MainWhiteFrame:TweenSize(UDim2.new(0, 424, 0, 58), "In", "Linear", 0.12)
            TweenService:Create(MainWhiteFrame_2, TweenInfo.new(0.10), {BackgroundTransparency = 1}):Play()
            TweenService:Create(MainWhiteFrame, TweenInfo.new(0.10), {BackgroundTransparency = 1}):Play()
        else
            closeLib.Image = "rbxassetid://4988112250"
            TweenService:Create(closeLib, TweenInfo.new(0.10), {Rotation = 0}):Play()
            MainWhiteFrame:TweenSize(UDim2.new(0, 528, 0, 310), "In", "Linear", 0.12)
            TweenService:Create(MainWhiteFrame_2, TweenInfo.new(0.10), {BackgroundTransparency = 0}):Play()
            TweenService:Create(MainWhiteFrame, TweenInfo.new(0.10), {BackgroundTransparency = 0}):Play()
        end
    end)

    elementContainer.Name = "elementContainer"
    elementContainer.Parent = MainWhiteFrame_2
    elementContainer.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
    elementContainer.Position = UDim2.new(0.207619041, 0, 0.187096775, 0)
    elementContainer.Size = UDim2.new(0, 408, 0, 243)
    mainCorner_5.CornerRadius = UDim.new(0, 3)
    mainCorner_5.Parent = elementContainer

    pagesFolder.Parent = elementContainer

    local DragMousePosition, FramePosition, Draggable = nil, nil, false
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Draggable = true
            DragMousePosition = Vector2.new(input.Position.X, input.Position.Y)
            FramePosition = Vector2.new(MainWhiteFrame.Position.X.Scale, MainWhiteFrame.Position.Y.Scale)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Draggable then
            local NewPosition = FramePosition + ((Vector2.new(input.Position.X, input.Position.Y) - DragMousePosition) / Camera.ViewportSize)
            MainWhiteFrame.Position = UDim2.new(NewPosition.X, 0, NewPosition.Y, 0)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Draggable = false
        end
    end)

    local SectionHandler = {}

    function SectionHandler:CreateSection(secName)
        secName = secName or "Tab"

        local tabBtn = Instance.new("TextButton")
        local mainCorner_3 = Instance.new("UICorner")
        tabBtn.Name = "tabBtn"..secName
        tabBtn.Parent = tabFrame
        tabBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)
        tabBtn.BorderColor3 = Color3.fromRGB(53, 53, 53)
        tabBtn.Position = UDim2.new(0, 0, 0, 0)
        tabBtn.Size = UDim2.new(0, 90, 0, 32)
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.Text = secName
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.TextSize = 14
        tabBtn.AutoButtonColor = false
        mainCorner_3.CornerRadius = UDim.new(0, 3)
        mainCorner_3.Parent = tabBtn

        local newPage = Instance.new("ScrollingFrame")
        local pageItemList = Instance.new("UIListLayout")
        local UIPadding = Instance.new("UIPadding")
        newPage.Name = "newPage"..secName
        newPage.Parent = pagesFolder
        newPage.Active = true
        newPage.BackgroundTransparency = 1
        newPage.BorderSizePixel = 0
        newPage.Size = UDim2.new(1, 0, 1, 0)
        newPage.ScrollBarThickness = 5
        newPage.ScrollBarImageColor3 = Color3.fromRGB(255, 2, 40)
        newPage.Visible = false
        pageItemList.Parent = newPage
        pageItemList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pageItemList.SortOrder = Enum.SortOrder.LayoutOrder
        pageItemList.Padding = UDim.new(0, 3)
        UIPadding.Parent = newPage
        UIPadding.PaddingRight = UDim.new(0, 5)
        UIPadding.PaddingTop = UDim.new(0, 5)

        local function UpdateSize()
            local cS = pageItemList.AbsoluteContentSize
            TweenService:Create(newPage, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
                CanvasSize = UDim2.new(0, cS.X, 0, cS.Y + 10)
            }):Play()
        end
        newPage.ChildAdded:Connect(UpdateSize)
        newPage.ChildRemoved:Connect(UpdateSize)
        UpdateSize()

        tabBtn.MouseButton1Click:Connect(function()
            for _, v in next, pagesFolder:GetChildren() do v.Visible = false end
            newPage.Visible = true
            for _, v in next, tabFrame:GetChildren() do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(25,25,25)}):Play()
                end
            end
            TweenService:Create(tabBtn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(139, 0, 23)}):Play()
            UpdateSize()
        end)

        local ElementHandler = {}

        function ElementHandler:TextLabel(labelText)
            labelText = labelText or ""
            local labelFrame = Instance.new("Frame", newPage)
            labelFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            labelFrame.Size = UDim2.new(0, 394, 0, 42)
            Instance.new("UICorner", labelFrame).CornerRadius = UDim.new(0, 3)
            local txtLabel = Instance.new("TextLabel", labelFrame)
            txtLabel.BackgroundTransparency = 1
            txtLabel.Size = UDim2.new(1, 0, 1, 0)
            txtLabel.Font = Enum.Font.GothamSemibold
            txtLabel.Text = labelText
            txtLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            txtLabel.TextSize = 14
        end

        function ElementHandler:TextButton(buttonText, buttonInfo, callback)
            buttonText = buttonText or ""
            buttonInfo = buttonInfo or ""
            callback = callback or function() end
            local textButtonFrame = Instance.new("Frame", newPage)
            textButtonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            textButtonFrame.Size = UDim2.new(0, 394, 0, 42)
            Instance.new("UICorner", textButtonFrame).CornerRadius = UDim.new(0, 3)
            local TextButton = Instance.new("TextButton", textButtonFrame)
            TextButton.BackgroundColor3 = Color3.fromRGB(181, 1, 31)
            TextButton.Position = UDim2.new(0.017766498, 0, 0.166666672, 0)
            TextButton.Size = UDim2.new(0, 141, 0, 27)
            TextButton.Font = Enum.Font.GothamSemibold
            TextButton.Text = buttonText
            TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextButton.TextSize = 14
            Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 3)
            local info = Instance.new("TextLabel", textButtonFrame)
            info.BackgroundTransparency = 1
            info.Position = UDim2.new(0.395939082, 0, 0.0238095243, 0)
            info.Size = UDim2.new(0, 226, 0, 41)
            info.Font = Enum.Font.GothamSemibold
            info.Text = buttonInfo
            info.TextColor3 = Color3.fromRGB(198, 198, 198)
            info.TextSize = 14
            info.TextXAlignment = Enum.TextXAlignment.Right
            TextButton.MouseButton1Click:Connect(function() callback() end)
        end

        function ElementHandler:Toggle(togInfo, callback)
            togInfo = togInfo or ""
            callback = callback or function() end
            local toggleFrame = Instance.new("Frame", newPage)
            toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            toggleFrame.Size = UDim2.new(0, 394, 0, 42)
            Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 3)
            local toggleInfo = Instance.new("TextLabel", toggleFrame)
            toggleInfo.BackgroundTransparency = 1
            toggleInfo.Position = UDim2.new(0.395939082, 0, 0.0238095243, 0)
            toggleInfo.Size = UDim2.new(0, 226, 0, 41)
            toggleInfo.Font = Enum.Font.GothamSemibold
            toggleInfo.Text = togInfo
            toggleInfo.TextColor3 = Color3.fromRGB(198, 198, 198)
            toggleInfo.TextSize = 14
            toggleInfo.TextXAlignment = Enum.TextXAlignment.Right
            local toggleInerFrame = Instance.new("Frame", toggleFrame)
            toggleInerFrame.BackgroundColor3 = Color3.fromRGB(181, 1, 31)
            toggleInerFrame.Position = UDim2.new(0.0177664906, 0, 0.166666672, 0)
            toggleInerFrame.Size = UDim2.new(0, 27, 0, 27)
            Instance.new("UICorner", toggleInerFrame).CornerRadius = UDim.new(0, 3)
            local toggleInnerFrame1 = Instance.new("Frame", toggleInerFrame)
            toggleInnerFrame1.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            toggleInnerFrame1.Position = UDim2.new(0.0177664906, 0, -0.0185185075, 0)
            toggleInnerFrame1.Size = UDim2.new(0, 25, 0, 25)
            Instance.new("UICorner", toggleInnerFrame1).CornerRadius = UDim.new(0, 3)
            local toggleBtn = Instance.new("TextButton", toggleInnerFrame1)
            toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            toggleBtn.Position = UDim2.new(2.2399888, 0, -0.0185185149, 0)
            toggleBtn.Size = UDim2.new(0, 23, 0, 23)
            toggleBtn.Text = ""
            toggleBtn.AutoButtonColor = false
            Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 3)
            local toggled = false
            toggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                callback(toggled)
                if toggled then
                    TweenService:Create(toggleBtn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(181, 1, 31)}):Play()
                else
                    TweenService:Create(toggleBtn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(25,25,25)}):Play()
                end
                saveCfg()
            end)
        end

        function ElementHandler:Slider(sliderin, minvalue, maxvalue, callback)
            minvalue = minvalue or 0
            maxvalue = maxvalue or 500
            callback = callback or function() end
            sliderin = sliderin or "info ok"
            local sliderFrame = Instance.new("Frame", newPage)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            sliderFrame.Size = UDim2.new(0, 394, 0, 42)
            Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 3)
            local sliderInfo = Instance.new("TextLabel", sliderFrame)
            sliderInfo.BackgroundTransparency = 1
            sliderInfo.Position = UDim2.new(0.570575714, 0, 0.0238095243, 0)
            sliderInfo.Size = UDim2.new(0, 157, 0, 41)
            sliderInfo.Font = Enum.Font.GothamSemibold
            sliderInfo.Text = sliderin
            sliderInfo.TextColor3 = Color3.fromRGB(198, 198, 198)
            sliderInfo.TextSize = 14
            sliderInfo.TextXAlignment = Enum.TextXAlignment.Right
            local sliderValue = Instance.new("TextLabel", sliderFrame)
            sliderValue.BackgroundTransparency = 1
            sliderValue.Position = UDim2.new(0.395939082, 0, 0.285714298, 0)
            sliderValue.Size = UDim2.new(0, 68, 0, 17)
            sliderValue.Font = Enum.Font.GothamSemibold
            sliderValue.Text = minvalue.."/"..maxvalue
            sliderValue.TextColor3 = Color3.fromRGB(199, 0, 33)
            sliderValue.TextSize = 14
            sliderValue.TextXAlignment = Enum.TextXAlignment.Left
            local sliderBtn = Instance.new("TextButton", sliderFrame)
            sliderBtn.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
            sliderBtn.BorderSizePixel = 0
            sliderBtn.Position = UDim2.new(0.0179999992, 0, 0.381000012, 0)
            sliderBtn.Size = UDim2.new(0, 141, 0, 10)
            sliderBtn.AutoButtonColor = false
            sliderBtn.Text = ""
            Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(0, 3)
            local sliderMainFrm = Instance.new("Frame", sliderBtn)
            sliderMainFrm.BackgroundColor3 = Color3.fromRGB(181, 1, 31)
            sliderMainFrm.BorderSizePixel = 0
            sliderMainFrm.Size = UDim2.new(0, 0, 0, 10)
            Instance.new("UICorner", sliderMainFrm).CornerRadius = UDim.new(0, 5)
            local mouse = LP:GetMouse()
            local moveConn, releaseConn
            sliderBtn.MouseButton1Down:Connect(function()
                local function upd()
                    if not mouse then return end
                    local val = math.floor((((tonumber(maxvalue) - tonumber(minvalue)) / 141) * (mouse.X - sliderMainFrm.AbsolutePosition.X)) + tonumber(minvalue))
                    val = math.clamp(val, minvalue, maxvalue)
                    sliderValue.Text = val.."/"..maxvalue
                    sliderMainFrm.Size = UDim2.new(math.clamp((mouse.X - sliderMainFrm.AbsolutePosition.X) / 141, 0, 1), 0, 1, 0)
                    pcall(callback, val)
                end
                upd()
                if moveConn then moveConn:Disconnect() end
                if releaseConn then releaseConn:Disconnect() end
                if mouse then moveConn = mouse.Move:Connect(upd) end
                releaseConn = UserInputService.InputEnded:Connect(function(M)
                    if M.UserInputType == Enum.UserInputType.MouseButton1 or M.UserInputType == Enum.UserInputType.Touch then
                        upd()
                        if moveConn then moveConn:Disconnect() end
                        if releaseConn then releaseConn:Disconnect() end
                        saveCfg()
                    end
                end)
            end)
        end

        function ElementHandler:KeyBind(keInfo, firstt, callback)
            local oldKey = firstt and firstt.Name or "None"
            keInfo = keInfo or ""
            callback = callback or function() end
            local keybindFrame = Instance.new("Frame", newPage)
            keybindFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            keybindFrame.Size = UDim2.new(0, 394, 0, 42)
            Instance.new("UICorner", keybindFrame).CornerRadius = UDim.new(0, 3)
            local TextButton = Instance.new("TextButton", keybindFrame)
            TextButton.BackgroundColor3 = Color3.fromRGB(181, 1, 31)
            TextButton.Position = UDim2.new(0.017766498, 0, 0.166666672, 0)
            TextButton.Size = UDim2.new(0, 76, 0, 27)
            TextButton.Font = Enum.Font.GothamSemibold
            TextButton.Text = oldKey
            TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextButton.TextSize = 14
            Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 3)
            local keybindinfo = Instance.new("TextLabel", keybindFrame)
            keybindinfo.BackgroundTransparency = 1
            keybindinfo.Position = UDim2.new(0.395939082, 0, 0.0238095243, 0)
            keybindinfo.Size = UDim2.new(0, 226, 0, 41)
            keybindinfo.Font = Enum.Font.GothamSemibold
            keybindinfo.Text = keInfo
            keybindinfo.TextColor3 = Color3.fromRGB(198, 198, 198)
            keybindinfo.TextSize = 14
            keybindinfo.TextXAlignment = Enum.TextXAlignment.Right
            TextButton.MouseButton1Click:Connect(function()
                TextButton.Text = ". . ."
                local a = UserInputService.InputBegan:Wait()
                if a.KeyCode and a.KeyCode.Name ~= "Unknown" then
                    TextButton.Text = a.KeyCode.Name
                    oldKey = a.KeyCode.Name
                end
            end)
            UserInputService.InputBegan:Connect(function(cur, ok)
                if not ok and cur.KeyCode and cur.KeyCode.Name == oldKey then
                    callback()
                end
            end)
        end

        function ElementHandler:TextBox(textInfo, placeHolderText1, callback)
            textInfo = textInfo or ""
            placeHolderText1 = placeHolderText1 or ""
            callback = callback or function() end
            local textBoxFrame = Instance.new("Frame", newPage)
            textBoxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            textBoxFrame.Size = UDim2.new(0, 394, 0, 42)
            Instance.new("UICorner", textBoxFrame).CornerRadius = UDim.new(0, 3)
            local textboxInfo = Instance.new("TextLabel", textBoxFrame)
            textboxInfo.BackgroundTransparency = 1
            textboxInfo.Position = UDim2.new(0.395939082, 0, 0.0238095243, 0)
            textboxInfo.Size = UDim2.new(0, 226, 0, 41)
            textboxInfo.Font = Enum.Font.GothamSemibold
            textboxInfo.Text = textInfo
            textboxInfo.TextColor3 = Color3.fromRGB(198, 198, 198)
            textboxInfo.TextSize = 14
            textboxInfo.TextXAlignment = Enum.TextXAlignment.Right
            local texboxInner = Instance.new("Frame", textBoxFrame)
            texboxInner.BackgroundColor3 = Color3.fromRGB(181, 1, 31)
            texboxInner.Position = UDim2.new(0.017766498, 0, 0.166666672, 0)
            texboxInner.Size = UDim2.new(0, 141, 0, 27)
            Instance.new("UICorner", texboxInner).CornerRadius = UDim.new(0, 3)
            local textboxinneer = Instance.new("Frame", texboxInner)
            textboxinneer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            textboxinneer.ClipsDescendants = true
            textboxinneer.Position = UDim2.new(0.411347508, 0, 0.0370370373, 0)
            textboxinneer.Size = UDim2.new(0, 139, 0, 25)
            Instance.new("UICorner", textboxinneer).CornerRadius = UDim.new(0, 3)
            local TextBox = Instance.new("TextBox", textboxinneer)
            TextBox.BackgroundTransparency = 1
            TextBox.Size = UDim2.new(1, 0, 1, 0)
            TextBox.Font = Enum.Font.GothamSemibold
            TextBox.PlaceholderColor3 = Color3.fromRGB(115, 115, 115)
            TextBox.PlaceholderText = placeHolderText1
            TextBox.Text = ""
            TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.TextSize = 13
            TextBox.TextWrapped = true
            TextBox.FocusLost:Connect(function(EnterPressed)
                if not EnterPressed then return end
                callback(TextBox.Text)
                TextBox.Text = ""
            end)
        end

        function ElementHandler:Dropdown(dInfo, list, callback)
            dInfo = dInfo or ""
            list = list or {}
            callback = callback or function() end
            local isDropped = false
            local dropDownFrame = Instance.new("Frame", newPage)
            dropDownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            dropDownFrame.ClipsDescendants = true
            dropDownFrame.Size = UDim2.new(0, 394, 0, 42)
            Instance.new("UICorner", dropDownFrame).CornerRadius = UDim.new(0, 3)
            local dropdownmain = Instance.new("Frame", dropDownFrame)
            dropdownmain.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            dropdownmain.Size = UDim2.new(0, 394, 0, 42)
            Instance.new("UICorner", dropdownmain).CornerRadius = UDim.new(0, 3)
            local dropdownItem = Instance.new("TextLabel", dropdownmain)
            dropdownItem.BackgroundTransparency = 1
            dropdownItem.Position = UDim2.new(0.0223523453, 0, 0, 0)
            dropdownItem.Size = UDim2.new(0, 291, 0, 41)
            dropdownItem.Font = Enum.Font.GothamSemibold
            dropdownItem.Text = dInfo
            dropdownItem.TextColor3 = Color3.fromRGB(255, 1, 43)
            dropdownItem.TextSize = 14
            dropdownItem.TextXAlignment = Enum.TextXAlignment.Left
            local ImageButton = Instance.new("ImageButton", dropdownmain)
            ImageButton.BackgroundTransparency = 1
            ImageButton.Position = UDim2.new(0.89974618, 0, 0.238095239, 0)
            ImageButton.Size = UDim2.new(0, 27, 0, 21)
            ImageButton.Image = "rbxassetid://5165666242"
            ImageButton.ImageColor3 = Color3.fromRGB(181, 1, 31)
            local DropYSize = 42
            local listLayout = Instance.new("UIListLayout", dropDownFrame)
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 5)
            ImageButton.MouseButton1Click:Connect(function()
                if isDropped then
                    isDropped = false
                    dropDownFrame:TweenSize(UDim2.new(0, 394, 0, 42), "In", "Quint", 0.10)
                    TweenService:Create(ImageButton, TweenInfo.new(0.10), {Rotation = 0}):Play()
                    task.wait(0.10); UpdateSize()
                else
                    isDropped = true
                    dropDownFrame:TweenSize(UDim2.new(0, 394, 0, DropYSize), "In", "Quint", 0.10)
                    TweenService:Create(ImageButton, TweenInfo.new(0.10), {Rotation = 180}):Play()
                    task.wait(0.10); UpdateSize()
                end
            end)
            for _, v in next, list do
                local optionBtn = Instance.new("TextButton", dropDownFrame)
                optionBtn.BackgroundColor3 = Color3.fromRGB(118, 0, 20)
                optionBtn.Size = UDim2.new(0, 377, 0, 39)
                optionBtn.Font = Enum.Font.GothamSemibold
                optionBtn.Text = "   "..v
                optionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                optionBtn.TextSize = 14
                optionBtn.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", optionBtn).CornerRadius = UDim.new(0, 3)
                DropYSize = DropYSize + 48
                optionBtn.MouseButton1Click:Connect(function()
                    callback(v)
                    dropdownItem.Text = dInfo..": "..v
                    dropDownFrame:TweenSize(UDim2.new(0, 394, 0, 42), "In", "Quint", 0.10)
                    task.wait(0.10); UpdateSize()
                    TweenService:Create(ImageButton, TweenInfo.new(0.10), {Rotation = 0}):Play()
                    isDropped = false
                    saveCfg()
                end)
            end
        end

        return ElementHandler
    end
    return SectionHandler
end

-- ============================================================
-- BUILD UI
-- ============================================================
local UI = Orion:CreateOrion("KALZZ HUB")

local Home = UI:CreateSection("INFO")
local Surv = UI:CreateSection("SURVI")
local Kill = UI:CreateSection("KILLER")
local Esp  = UI:CreateSection("ESP")
local Misc = UI:CreateSection("MISC")

Home:TextLabel("Kalzz Hub V7")
Home:TextButton("Join Discord", INVITE, function()
    pcall(function() if setclipboard then setclipboard("https://"..INVITE) end end)
end)
Home:TextButton("Copy Invite", "Click", function()
    pcall(function() if setclipboard then setclipboard("https://"..INVITE) end end)
end)
Home:TextButton("Print Remotes", "Debug", function()
    print("[KZ] ToF:", RC.tof, "| Veil:", RC.veil, "| Parry:", RC.parry, "| FV:", RC.fastvault)
end)
Home:TextButton("Print Role", "Debug", function()
    print("[KZ] Role:", GetRole())
end)

Surv:TextLabel("Silent Aim ToF")
Surv:Toggle("Enable ToF", function(v) CFG.tof_on = v end)
Surv:Toggle("Show FOV", function(v) CFG.tof_show_fov = v end)
Surv:Slider("FOV", 1, 800, function(v) CFG.tof_fov = v end)
Surv:Slider("Predict", 10, 50, function(v) CFG.tof_predict = v / 10 end)
Surv:Slider("Max Dist", 100, 3000, function(v) CFG.tof_maxdist = v end)

Surv:TextLabel("Auto Generator")
Surv:Toggle("Enable Auto Gen", function(v) CFG.gene_on = v end)
Surv:Dropdown("Method", {"PERFECT","NEUTRAL","INSTANT"}, function(v) CFG.gene_method = v end)

Surv:TextLabel("Auto Parry")
Surv:Toggle("Enable Parry", function(v) CFG.parry_on = v end)
Surv:Toggle("Show Circle", function(v) CFG.parry_show_circle = v end)
Surv:Slider("Radius", 1, 30, function(v) CFG.parry_radius = v end)
Surv:Slider("Sensitive", 0, 500, function(v) CFG.parry_sensitive = v end)
Surv:Toggle("Aggressive", function(v) CFG.parry_aggro = v end)

Surv:TextLabel("Movement")
Surv:Toggle("Fast Vault", function(v) CFG.fast_vault = v end)

Kill:TextLabel("Silent Aim Veil")
Kill:Toggle("Enable Veil", function(v) CFG.veil_on = v end)
Kill:Toggle("Show FOV", function(v) CFG.veil_show_fov = v end)
Kill:Toggle("Show Tracker", function(v) VD.VeilShowTracker = v end)
Kill:Toggle("Auto Predict", function(v) VD.VeilAutoPredict = v end)
Kill:Slider("FOV", 1, 800, function(v) CFG.veil_fov = v end)
Kill:Slider("Predict", 10, 100, function(v) CFG.veil_predict = v / 10 end)
Kill:Slider("Distance", 100, 500, function(v) CFG.veil_maxdist = v end)

Esp:TextLabel("Player ESP")
Esp:Toggle("Survivor ESP", function(v) CFG.esp_s = v end)
Esp:Toggle("Killer ESP", function(v) CFG.esp_k = v end)
Esp:Toggle("Item ESP", function(v) CFG.esp_item = v end)

Esp:TextLabel("Generator ESP")
Esp:Toggle("Generator ESP", function(v) CFG.esp_g = v end)
Esp:Toggle("Show Progress", function(v) CFG.esp_gen_txt = v end)

Esp:TextLabel("Style")
Esp:Toggle("Outline Only", function(v) CFG.esp_out = v end)

Misc:TextLabel("Vision")
Misc:Toggle("FOV Lock", function(v) CFG.fov_lock = v end)
Misc:Slider("FOV Value", 60, 140, function(v) CFG.fov_value = v end)
Misc:Toggle("Bright Ambient", function(v) CFG.ambient = v end)
Misc:Toggle("Boost FPS", function(v)
    CFG.boost_fps = v
    pcall(function() if v then setfpscap(240) else setfpscap(0) end end)
end)

Misc:TextLabel("Notifications")
Misc:Toggle("Proximity Alert", function(v) CFG.alert = v end)
Misc:Toggle("Stun Killer Notif", function(v) CFG.stun_on = v end)

Misc:TextLabel("Hotkeys")
Misc:TextLabel("V = ToF | B = Veil | P = Parry | RightShift = Hide UI")

-- ============================================================
-- HOTKEYS
-- ============================================================
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.V then CFG.tof_on = not CFG.tof_on end
    if i.KeyCode == Enum.KeyCode.B then CFG.veil_on = not CFG.veil_on end
    if i.KeyCode == Enum.KeyCode.P then
        if _G.KZ_ManualParry then _G.KZ_ManualParry() end
    end
    if i.KeyCode == Enum.KeyCode.RightShift then
        local gui = CoreGui:FindFirstChild("OrionLib_" .. tostring(os.time()))
        for _, g2 in ipairs(CoreGui:GetChildren()) do
            if string.find(g2.Name, "OrionLib_") then
                g2.Enabled = not g2.Enabled
            end
        end
    end
end)

print("==========================================")
print("[KALZZ HUB V7] Loaded.")
print("Tabs   : INFO / SURVI / KILLER / ESP / MISC")
print("Auto Save : " .. (writefile and "ON" or "OFF"))
print("Hotkeys   : V | B | P | RightShift")
print("==========================================")
