-- ======================
-- AUTO PARRY REALTIME (FIXED & OPTIMIZED)
-- anim detect → dagger instantly
-- lunge faster than basic
-- radius circle clean
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
    ["122812055447896"] = "lunge", ["133963973694098"] = "basic",
    ["117042998468241"] = "lunge", ["135002183282873"] = "lunge",
    ["121216847022485"] = "basic", ["132817836308238"] = "basic",
    ["129784271201071"] = "lunge", ["82666958311998"]  = "frenzy",
    ["78432063483146"]  = "basic", ["118907603246885"] = "lunge",
    ["139369275981139"] = "basic", ["110355011987939"] = "lunge",
    ["111920872708571"] = "basic", ["105374834496520"] = "lunge",
    ["138720291317243"] = "basic", ["106871536134254"] = "basic",
    ["130593238885843"] = "basic", ["115244153053858"] = "lunge",
    ["74968262036854"]  = "basic", ["113255068724446"] = "lunge",
    ["98163597193511"]  = "special", ["80411309607666"]  = "special",
    ["101344487600812"] = "special",
}

-- lunge = commit lebih awal (attack cepat)
local WIN = {
    lunge   = {0.08, 0.70},
    basic   = {0.12, 0.72},
    frenzy  = {0.06, 0.75},
    special = {0.10, 0.70},
    default = {0.10, 0.72},
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
    -- ⭐ FIX TYPO: Hapus backslash
    return type(r) == "string" and r:lower():find("killer") ~= nil
end

local function busy()
    local ch = LP.Character
    if not ch then return true end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return true end
    for _, a in ipairs({"Knocked", "Downed", "Hooked", "Carried"}) do
        if ch:GetAttribute(a) == true then return true end
    end
    local an = hum:FindFirstChildOfClass("Animator")
    if an then
        local ok, tr = pcall(function() return an:GetPlayingAnimationTracks() end)
        if ok and tr then
            for _, t in ipairs(tr) do
                local n = ((t.Animation and t.Animation.Name) or ""):lower()
                if n:find("vault") or n:find("window") or n:find("pallet") then
                    return true
                end
            end
        end
    end
    return false
end

local PR
pcall(function()
    PR = RS.Remotes.Items["Parrying Dagger"].parry
end)

local lastParry = 0
local fired = {}
local attached = {}

local function doP(key)
    if not CFG.parry_on or busy() then return end
    if key and fired[key] then return end

    local now = os.clock()
    local cd = CFG.parry_aggro and 0.015 or 0.04
    if now - lastParry < cd then return end
    lastParry = now
    if key then fired[key] = true end

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
            task.defer(function()
                firesignal(b.MouseButton1Up)
            end)
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
    if distTo(m) > (CFG.parry_radius or 15) + 1.8 then return false end

    local len = t.Length
    if len and len > 0.05 then
        local look = (kind == "lunge" or kind == "frenzy") and 0.028 or 0.016
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
                if look.Magnitude > 0.05 and look.Unit:Dot(to.Unit) < -0.35 then
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
            if not CFG.parry_aggro and conn then
                conn:Disconnect()
            end
        end
    end)

    t.Stopped:Connect(function()
        fired[key] = nil
        if conn then conn:Disconnect() end
    end)
    task.delay(2.2, function()
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
        
        -- Tunggu animator muncul (maks 3 detik)
        for _ = 1, 30 do
            if an then break end
            task.wait(0.1)
            an = hum:FindFirstChildOfClass("Animator")
            if not m.Parent then return end
        end
        if not an then attached[m] = nil return end

        -- ⭐ CUKUP PAKAI EVENT (Hapus while loop yang bikin lag)
        an.AnimationPlayed:Connect(function(t)
            onAnim(t, m)
        end)
    end)
end

local function scan()
    for _, p in ipairs(Players:GetPlayers()) do
        -- ⭐ FIX TYPO: Hapus backslash di ~=
        if p ~= LP and p.Character and isKillerModel(p.Character) then
            bind(p.Character)
        end
    end
end

scan()
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        attached[c] = nil
        task.wait(0.2)
        if isKillerModel(c) then bind(c) end
    end)
end)
for _, p in ipairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function(c)
        attached[c] = nil
        task.wait(0.2)
        if isKillerModel(c) then bind(c) end
    end)
end

-- rescan agresif biar tidak lepas sepanjang game
task.spawn(function()
    while task.wait(0.45) do scan() end
end)

UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.P then doP() end
end)

-- ======================
-- RADIUS CIRCLE BERSIH
-- ======================
local folder = workspace:FindFirstChild("KZ_ParryRing") or Instance.new("Folder")
folder.Name = "KZ_ParryRing"
folder.Parent = workspace

local segs = {}
local N = 64
for i = 1, N do
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.Material = Enum.Material.Neon
    p.Size = Vector3.new(0.4, 0.06, 0.22)
    p.Transparency = 1
    p.Parent = folder
    segs[i] = p
end

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

RunService.RenderStepped:Connect(function()
    if not CFG.parry_show_circle or not CFG.parry_on then
        for _, p in ipairs(segs) do p.Transparency = 1 end
        return
    end
    local my = root(LP.Character)
    if not my then
        for _, p in ipairs(segs) do p.Transparency = 1 end
        return
    end

    local radius = CFG.parry_radius or 15
    local threat = killerInRange(radius)
    local col = threat and Color3.fromRGB(255, 55, 55) or Color3.fromRGB(70, 255, 130)
    local o = my.Position

    for i = 1, N do
        local a0 = (i - 1) / N * math.pi * 2
        local a1 = i / N * math.pi * 2
        local x0, z0 = math.cos(a0) * radius, math.sin(a0) * radius
        local x1, z1 = math.cos(a1) * radius, math.sin(a1) * radius
        local mid = Vector3.new((x0 + x1) * 0.5, 0.04, (z0 + z1) * 0.5)
        local len = (Vector3.new(x1 - x0, 0, z1 - z0)).Magnitude + 0.02
        local p = segs[i]
        p.Size = Vector3.new(len, 0.06, 0.2)
        p.CFrame = CFrame.new(o + mid, o + Vector3.new(x1, 0.04, z1))
        p.Color = col
        p.Transparency = 0.15
    end
end)

print("[KZ] Auto Parry REALTIME • lunge cepat • ring bersih • full game")
