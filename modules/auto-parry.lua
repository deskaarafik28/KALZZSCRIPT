-- ======================
-- PERFECT DAGGER + PARRY CIRCLE (ALL-IN-ONE)
-- window sempit • 1 frame ahead • 1 parry per swing
-- visual lingkaran anti-lag • realtime config
-- ======================
local Players    = game:GetService("Players")
local RS         = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ⭐ REALTIME CONFIG
local CFG = _G.KALZZ_CFG or {}
if CFG.parry_on == nil then CFG.parry_on = true end
CFG.parry_radius = CFG.parry_radius or 15
if CFG.parry_aggro == nil then CFG.parry_aggro = true end
if CFG.parry_antifake == nil then CFG.parry_antifake = true end
if CFG.parry_show_circle == nil then CFG.parry_show_circle = true end
_G.KALZZ_CFG = CFG

-- ============================================================
-- BAGIAN 1: PARRY RADIUS VISUAL (OPTIMIZED)
-- ============================================================
local oldBase = workspace:FindFirstChild("KZ_ParryCircle_Base")
if oldBase then oldBase:Destroy() end

local base = Instance.new("Part")
base.Name = "KZ_ParryCircle_Base"
base.Size = Vector3.new(1, 0.05, 1)
base.Anchored = true
base.CanCollide = false
base.CanQuery = false
base.CanTouch = false
base.CastShadow = false
base.Material = Enum.Material.SmoothPlastic
base.Transparency = 1
base.Parent = workspace

local sg = Instance.new("SurfaceGui", base)
sg.Face = Enum.NormalId.Top
sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
sg.PixelsPerStud = 40
sg.LightInfluence = 0
sg.ZOffset = 1

local ring = Instance.new("Frame", sg)
ring.AnchorPoint = Vector2.new(0.5, 0.5)
ring.Position = UDim2.fromScale(0.5, 0.5)
ring.Size = UDim2.fromScale(0.96, 0.96)
ring.BackgroundTransparency = 1
ring.BorderSizePixel = 0
Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke", ring)
stroke.Thickness = 3
stroke.Color = Color3.fromRGB(80, 255, 120)
stroke.Transparency = 0.2

local fill = Instance.new("Frame", sg)
fill.AnchorPoint = Vector2.new(0.5, 0.5)
fill.Position = UDim2.fromScale(0.5, 0.5)
fill.Size = UDim2.fromScale(0.94, 0.94)
fill.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
fill.BackgroundTransparency = 0.85
fill.BorderSizePixel = 0
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

local function getRoot()
    local ch = LP.Character
    return ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart)
end

local function anyKillerInRadius(radius, myPos)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP or not p.Character then continue end
        local role = p.Character:GetAttribute("Role") or p:GetAttribute("Role")
        local team = p.Team and p.Team.Name
        local killer = false
        if type(role) == "string" and role:lower():find("killer") then killer = true end
        if team and team:lower():find("killer") then killer = true end
        if not killer then continue end
        local r = p.Character:FindFirstChild("HumanoidRootPart") or p.Character.PrimaryPart
        if r and (r.Position - myPos).Magnitude <= radius + 1.5 then
            return true
        end
    end
    return false
end

local SAFE_COLOR = Color3.fromRGB(80, 255, 120)
local DANGER_COLOR = Color3.fromRGB(255, 70, 70)

local lastVisualUpdate = 0
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastVisualUpdate < 0.033 then return end
    lastVisualUpdate = now

    if not CFG.parry_show_circle or not CFG.parry_on then
        base.Transparency = 1
        return
    end

    local root = getRoot()
    if not root then
        base.Transparency = 1
        return
    end

    local radius = CFG.parry_radius or 15
    local origin = root.Position
    local threat = anyKillerInRadius(radius, origin)
    
    local currentColor = threat and DANGER_COLOR or SAFE_COLOR

    base.Size = Vector3.new(radius * 2, 0.05, radius * 2)
    base.CFrame = CFrame.new(origin - Vector3.new(0, 2.95, 0))
    base.Transparency = 0

    stroke.Color = currentColor
    fill.BackgroundColor3 = currentColor
end)

-- ============================================================
-- BAGIAN 2: PERFECT DAGGER LOGIC
-- ============================================================
local VALID = {
    ["122812055447896"]="lunge",["133963973694098"]="basic",["117042998468241"]="lunge",
    ["135002183282873"]="lunge",["121216847022485"]="basic",["132817836308238"]="basic",
    ["129784271201071"]="lunge",["82666958311998"]="frenzy",["78432063483146"]="basic",
    ["118907603246885"]="lunge",["139369275981139"]="basic",["110355011987939"]="lunge",
    ["111920872708571"]="basic",["105374834496520"]="lunge",["138720291317243"]="basic",
    ["106871536134254"]="basic",["130593238885843"]="basic",["115244153053858"]="lunge",
    ["74968262036854"]="basic",["113255068724446"]="lunge",["98163597193511"]="special",
    ["80411309607666"]="special",["101344487600812"]="special",
}

-- PERFECT window (sempit = timing presisi)
local WIN = {
    lunge   = {0.22, 0.48},
    basic   = {0.24, 0.52},
    frenzy  = {0.18, 0.50},
    special = {0.22, 0.50},
    default = {0.22, 0.50},
}

local function root(m)
    return m and (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart)
end
local function flat(v) return Vector3.new(v.X, 0, v.Z) end

local function isKiller(p)
    if not p or p == LP or not p.Character then return false end
    if p.Team and p.Team.Name == "Killer" then return true end
    local r = p.Character:GetAttribute("Role") or p:GetAttribute("Role")
    if type(r) == "string" and r:lower():find("killer") then return true end
    return p.Team and p.Team.Name and p.Team.Name:lower():find("killer") ~= nil
end

local function busy()
    local ch = LP.Character
    if not ch then return true end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return true end
    for _, a in ipairs({"Knocked","Downed","Hooked","Carried"}) do
        if ch:GetAttribute(a) == true then return true end
    end
    return false
end

local PR
pcall(function() PR = RS.Remotes.Items["Parrying Dagger"].parry end)

local lastParry = 0
local firedFor = {} -- 1 swing = 1 parry
local attached = {}

local function doP(trackKey)
    if not CFG.parry_on or busy() then return end
    if trackKey and firedFor[trackKey] then return end

    local now = os.clock()
    local cd = CFG.parry_aggro and 0.03 or 0.08
    if now - lastParry < cd then return end
    lastParry = now
    
    if trackKey then firedFor[trackKey] = true end

    if PR then
        pcall(function() PR:FireServer() end)
        pcall(function() PR:FireServer(2) end)
    end

    pcall(function()
        local sv = PG:FindFirstChild("Survivor-mob")
        if not sv then return end
        local c = sv:FindFirstChild("Controls")
        if not c then return end
        local b = c:FindFirstChild("Gui-mob") or c:FindFirstChildWhichIsA("ImageButton")
        if b and typeof(firesignal) == "function" then
            firesignal(b.MouseButton1Down)
            task.wait()
            firesignal(b.MouseButton1Up)
        end
    end)
end

local function distTo(m)
    local a, b = root(LP.Character), root(m)
    if not a or not b then return 9999 end
    return (a.Position - b.Position).Magnitude
end

local function inPerfect(t, kind, m)
    if not t or not t.IsPlaying then return false end
    if distTo(m) > (CFG.parry_radius or 15) + 1.2 then return false end

    local len = t.Length
    if not len or len <= 0.05 then return false end

    local a = ((t.TimePosition or 0) + 0.016) / len
    local w = WIN[kind] or WIN.default
    if a < w[1] or a > w[2] then return false end

    if CFG.parry_antifake then
        local kr, mr = root(m), root(LP.Character)
        if kr and mr then
            local to = flat(mr.Position - kr.Position)
            if to.Magnitude > 0.3 then
                local look = flat(kr.CFrame.LookVector)
                if look.Magnitude > 0.05 and look.Unit:Dot(to.Unit) < -0.2 then
                    return false
                end
            end
        end
    end
    return true
end

local function watch(t, kind, m)
    local key = tostring(t)
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not CFG.parry_on or not t.IsPlaying then
            firedFor[key] = nil
            if conn then conn:Disconnect() end
            return
        end
        if inPerfect(t, kind, m) then
            doP(key)
            if conn then conn:Disconnect() end 
        end
    end)
    
    t.Stopped:Connect(function()
        firedFor[key] = nil
        if conn then conn:Disconnect() end
    end)
    
    task.delay(2.0, function()
        firedFor[key] = nil
        if conn then pcall(function() conn:Disconnect() end) end
    end)
end

local function bind(m)
    if not m or attached[m] then return end
    local plr = Players:GetPlayerFromCharacter(m)
    
    if plr and not isKiller(plr) then return end
    if not plr then
        local r = m:GetAttribute("Role")
        if type(r) ~= "string" or not r:lower():find("killer") then return end
    end
    attached[m] = true

    task.spawn(function()
        local hum = m:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local an = hum:FindFirstChildOfClass("Animator")
        if not an then return end

        an.AnimationPlayed:Connect(function(t)
            if not CFG.parry_on or not t or not t.Animation then return end
            local id = tostring(t.Animation.AnimationId or ""):match("%d+") or ""
            local kind = VALID[id]
            if kind then watch(t, kind, m) end
        end)
    end)
end

local function scan()
    for _, p in ipairs(Players:GetPlayers()) do
        if isKiller(p) and p.Character then bind(p.Character) end
    end
end
scan()

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        attached[c] = nil
        task.wait(0.25)
        if isKiller(p) then bind(c) end
    end)
end)

for _, p in ipairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function(c)
        attached[c] = nil
        task.wait(0.25)
        if isKiller(p) then bind(c) end
    end)
end

task.spawn(function()
    while task.wait(1) do scan() end
end)

-- Manual Parry (Tombol P)
UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.P then doP() end
end)

print("[KZ] Perfect Dagger + Parry Circle (All-in-one Optimized)")
