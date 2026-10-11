--[[ KALZZ HUB V7 | Orion Dark UI | Auto Load | Silent Aim | Auto Parry ]]

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
-- AIM HELPERS
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
-- FOV CIRCLE
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

local function Veil_HideAllVisuals()
    local V = VeilVisuals
    local OFF = Vector2.new(-9999, -9999)
    if V.FOVOuterRing then V.FOVOuterRing.Visible=false; V.FOVOuterRing.Position=OFF; V.FOVOuterRing.Radius=0 end
    if V.FOVMainRing then V.FOVMainRing.Visible=false; V.FOVMainRing.Position=OFF; V.FOVMainRing.Radius=0 end
    if V.FOVInnerRing then V.FOVInnerRing.Visible=false; V.FOVInnerRing.Position=OFF; V.FOVInnerRing.Radius=0 end
    if V.FOVCrossLines then for _, s in ipairs(V.FOVCrossLines) do s.Visible=false; s.From=OFF; s.To=OFF end end
    if V.FOVTicks then for _, s in ipairs(V.FOVTicks) do s.Visible=false; s.From=OFF; s.To=OFF end end
    if V.TrackerOuterRing then V.TrackerOuterRing.Visible=false; V.TrackerOuterRing.Position=OFF; V.TrackerOuterRing.Radius=0 end
    if V.TrackerMainRing then V.TrackerMainRing.Visible=false; V.TrackerMainRing.Position=OFF; V.TrackerMainRing.Radius=0 end
    if V.TrackerDotFill then V.TrackerDotFill.Visible=false; V.TrackerDotFill.Position=OFF; V.TrackerDotFill.Radius=0 end
    if V.TrackerDotOutline then V.TrackerDotOutline.Visible=false; V.TrackerDotOutline.Position=OFF; V.TrackerDotOutline.Radius=0 end
    if V.TrackerLine then V.TrackerLine.Visible=false; V.TrackerLine.From=OFF; V.TrackerLine.To=OFF end
end

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
        Veil_HideAllVisuals(); return
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

print("[KALZZ V7] Part 1 loaded. Ketik 'lanjut' untuk Part 2 (AutoGen + Parry + ESP + Stun + UI).")
