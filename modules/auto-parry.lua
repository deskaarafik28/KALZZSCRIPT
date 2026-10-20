-- ======================
-- AUTO PARRY • AGRESIF + BYPASS (FIXED & OPTIMIZED)
-- detect kencang • CD habis = langsung bisa lagi
-- skip vault / pallet / gen / gate
-- ======================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local CFG = _G.KALZZ_CFG or {}
if CFG.parry_on == nil then CFG.parry_on = true end
CFG.parry_radius = CFG.parry_radius or 15
if CFG.parry_aggro == nil then CFG.parry_aggro = true end
if CFG.parry_antifake == nil then CFG.parry_antifake = true end
if CFG.parry_show_circle == nil then CFG.parry_show_circle = true end
_G.KALZZ_CFG = CFG

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

-- window LEBAR + commit AWAL (agresif)
local WIN = {
    lunge   = {0.05, 0.78},
    basic   = {0.08, 0.80},
    frenzy  = {0.04, 0.82},
    special = {0.06, 0.78},
    default = {0.06, 0.80},
}

local function root(m)
    return m and (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart)
end
local function flat(v) return Vector3.new(v.X, 0, v.Z) end

local function isKillerModel(m)
    if not m then return false end
    local plr = Players:GetPlayerFromCharacter(m)
    if plr then
        if plr == LP then return false end
        if plr.Team and plr.Team.Name == "Killer" then return true end
        local r = m:GetAttribute("Role") or plr:GetAttribute("Role")
        if type(r) == "string" and r:lower():find("killer") then return true end
        if plr.Team and plr.Team.Name and plr.Team.Name:lower():find("killer") then return true end
        return false
    end
    local r = m:GetAttribute("Role")
    -- ⭐ FIX TYPO BACKSLASH
    return type(r) == "string" and r:lower():find("killer") ~= nil
end

-- BYPASS: vault / window / pallet / gen / gate / down
local function busy()
    local ch = LP.Character
    if not ch then return true end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return true end

    for _, a in ipairs({
        "Knocked","Downed","Hooked","Carried","IsCarried",
        "Repairing","Healing","OpeningGate","Interacting",
        "Vaulting","OnWindow","OnPallet",
    }) do
        local v = ch:GetAttribute(a)
        if v == true or v == 1 then return true end
    end

    local st = hum:GetState()
    if st == Enum.HumanoidStateType.Climbing then return true end

    local an = hum:FindFirstChildOfClass("Animator")
    if an then
        local ok, tr = pcall(function() return an:GetPlayingAnimationTracks() end)
        if ok and tr then
            for _, t in ipairs(tr) do
                local n = ((t.Animation and t.Animation.Name) or ""):lower()
                if n:find("vault") or n:find("window") or n:find("pallet")
                    or n:find("generator") or n:find("repair") or n:find("gate")
                    or n:find("open") or n:find("heal") or n:find("medkit") then
                    return true
                end
            end
        end
    end
    return false
end

local PR
pcall(function() PR = RS.Remotes.Items["Parrying Dagger"].parry end)

local lastParry = 0
local fired = {}
local attached = {}

local function doP(key)
    if not CFG.parry_on or busy() then return end
    local now = os.clock()
    local cd = CFG.parry_aggro and 0.01 or 0.03
    if now - lastParry < cd then return end
    if key and fired[key] and (now - fired[key]) < 0.35 then return end

    lastParry = now
    if key then fired[key] = now end

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
            task.defer(function() firesignal(b.MouseButton1Up) end)
        end
    end)
end

local function distTo(m)
    local a, b = root(LP.Character), root(m)
    if not a or not b then return 9999 end
    return (a.Position - b.Position).Magnitude
end

local function shouldParry(t, kind, m)
    if not t or not t.IsPlaying then return false end
    if busy() then return false end
    if distTo(m) > (CFG.parry_radius or 15) + 2.2 then return false end

    local len = t.Length
    if len and len > 0.05 then
        local look = (kind == "lunge" or kind == "frenzy") and 0.035 or 0.022
        local a = ((t.TimePosition or 0) + look) / len
        local w = WIN[kind] or WIN.default
        if a < w[1] or a > w[2] then return false end
    end

    if CFG.parry_antifake then
        local kr, mr = root(m), root(LP.Character)
        if kr and mr then
            local to = flat(mr.Position - kr.Position)
            if to.Magnitude > 0.3 then
                local look = flat(kr.CFrame.LookVector)
                if look.Magnitude > 0.05 and look.Unit:Dot(to.Unit) < -0.4 then
                    return false
                end
            end
        end
    end
    return true
end

local function onAnim(t, m)
    if not CFG.parry_on or not t or not t.Animation then return end
    local id = tostring(t.Animation.AnimationId or ""):match("%d+") or ""
    local kind = VALID[id]
    if not kind then return end

    local key = tostring(t) .. "_" .. id
    fired[key] = nil

    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not CFG.parry_on or not t.IsPlaying then
            if conn then conn:Disconnect() end
            return
        end
        if shouldParry(t, kind, m) then
            doP(key)
        end
    end)

    t.Stopped:Connect(function()
        fired[key] = nil
        if conn then conn:Disconnect() end
    end)
    task.delay(2.5, function()
        fired[key] = nil
        if conn then pcall(function() conn:Disconnect() end) end
    end)
end

local function bind(m)
    if not m or attached[m] then return end
    if not isKillerModel(m) then return end
    attached[m] = true

    task.spawn(function()
        local hum = m:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local an = hum:FindFirstChildOfClass("Animator")
        for _ = 1, 30 do
            if an then break end
            task.wait(0.1)
            an = hum:FindFirstChildOfClass("Animator")
            if not m.Parent then return end
        end
        if not an then attached[m] = nil return end

        -- ⭐ FIX: Hapus loop while Heartbeat (Penyebab Utama Lag)
        an.AnimationPlayed:Connect(function(t)
            onAnim(t, m)
        end)
    end)
end

local function scan()
    for _, p in ipairs(Players:GetPlayers()) do
        -- ⭐ FIX TYPO BACKSLASH
        if p ~= LP and p.Character and isKillerModel(p.Character) then
            bind(p.Character)
        end
    end
end

scan()
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        attached[c] = nil
        task.wait(0.15)
        if isKillerModel(c) then bind(c) end
    end)
end)
for _, p in ipairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function(c)
        attached[c] = nil
        task.wait(0.15)
        if isKillerModel(c) then bind(c) end
    end)
end

task.spawn(function()
    while task.wait(0.4) do scan() end
end)

task.spawn(function()
    while task.wait(1) do
        local now = os.clock()
        for k, t in pairs(fired) do
            if now - t > 1.5 then fired[k] = nil end
        end
    end
end)

UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.P then doP() end
end)

-- ======================
-- RADIUS CIRCLE (OPTIMIZED 1 PART)
-- ======================
local oldBase = workspace:FindFirstChild("KZ_ParryRing_Base")
if oldBase then oldBase:Destroy() end

local base = Instance.new("Part")
base.Name = "KZ_ParryRing_Base"
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

local function killerInRange(radius)
    local my = root(LP.Character)
    if not my then return false end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP or not p.Character then continue end
        if not isKillerModel(p.Character) then continue end
        local r = root(p.Character)
        if r and (r.Position - my.Position).Magnitude <= radius + 1.5 then
            return true
        end
    end
    return false
end

-- Update visual pakai Heartbeat biar gak berat
local lastVisUpdate = 0
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastVisUpdate < 0.033 then return end
    lastVisUpdate = now

    if not CFG.parry_show_circle or not CFG.parry_on then
        base.Transparency = 1
        return
    end
    local my = root(LP.Character)
    if not my then
        base.Transparency = 1
        return
    end

    local radius = CFG.parry_radius or 15
    local threat = killerInRange(radius)
    local col = threat and Color3.fromRGB(255, 55, 55) or Color3.fromRGB(70, 255, 130)
    
    base.Size = Vector3.new(radius * 2, 0.05, radius * 2)
    base.CFrame = CFrame.new(my.Position - Vector3.new(0, 2.95, 0))
    base.Transparency = 0
    stroke.Color = col
end)

print("[KZ] Auto Parry AGRESIF • FIXED • bypass vault/pallet • Optimized Ring")
