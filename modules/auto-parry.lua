-- ======================
-- AUTO PARRY • OPTIMIZED & FIXED
-- Real-time CFG • Anti-Lag • Anti-Fake
-- ======================
local Players    = game:GetService("Players")
local RS         = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ⭐ AMBIL CFG REALTIME
local CFG = _G.KALZZ_CFG or {}

-- Defaults (kalau di UI belum di-set)
CFG.parry_on       = CFG.parry_on ~= false
CFG.parry_radius   = CFG.parry_radius or 15
CFG.parry_aggro    = CFG.parry_aggro ~= false
CFG.parry_antifake = CFG.parry_antifake ~= false

local VALID = {
    ["122812055447896"] = "lunge",
    ["133963973694098"] = "basic",
    ["117042998468241"] = "lunge",
    ["135002183282873"] = "lunge",
    ["121216847022485"] = "basic",
    ["132817836308238"] = "basic",
    ["129784271201071"] = "lunge",
    ["82666958311998"]  = "frenzy",
    ["78432063483146"]  = "basic",
    ["118907603246885"] = "lunge",
    ["139369275981139"] = "basic",
    ["110355011987939"] = "lunge",
    ["111920872708571"] = "basic",
    ["105374834496520"] = "lunge",
    ["138720291317243"] = "basic",
    ["106871536134254"] = "basic",
    ["130593238885843"] = "basic",
    ["115244153053858"] = "lunge",
    ["74968262036854"]  = "basic",
    ["113255068724446"] = "lunge",
    ["98163597193511"]  = "special",
    ["80411309607666"]  = "special",
    ["101344487600812"] = "special",
}

-- Window hit (persentase waktu animasi)
local WIN = {
    lunge   = {0.16, 0.58},
    basic   = {0.18, 0.62},
    frenzy  = {0.12, 0.66},
    special = {0.16, 0.60},
    default = {0.16, 0.60},
}

local function root(m)
    return m and (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart)
end

local function flat(v)
    return Vector3.new(v.X, 0, v.Z)
end

local function isKiller(p)
    if not p or p == LP or not p.Character then return false end
    if p.Team and p.Team.Name == "Killer" then return true end
    local r = p.Character:GetAttribute("Role") or p:GetAttribute("Role")
    if type(r) == "string" and r:lower():find("killer") then return true end
    if p.Team and p.Team.Name and p.Team.Name:lower():find("killer") then return true end
    return false
end

local function busy()
    local ch = LP.Character
    if not ch then return true end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return true end
    for _, a in ipairs({"Knocked", "Downed", "Hooked", "Carried"}) do
        if ch:GetAttribute(a) == true or ch:GetAttribute(a) == 1 then return true end
    end
    return false
end

local PR
pcall(function()
    PR = RS.Remotes.Items["Parrying Dagger"].parry
end)

local lastParry = 0
local attached = {}

local function doP()
    if not CFG.parry_on or busy() then return end
    local now = os.clock()
    local cd = CFG.parry_aggro and 0.025 or 0.07
    if now - lastParry < cd then return end
    lastParry = now

    -- Fire remote
    if PR then
        pcall(function() PR:FireServer() end)
        pcall(function() PR:FireServer(2) end)
    end

    -- Mobile / HP Click
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

local function inHit(t, kind, m)
    if not t.IsPlaying then return false end
    -- Cek jarak dari UI realtime
    if distTo(m) > (CFG.parry_radius or 15) + 1.5 then return false end

    local len = t.Length
    if len and len > 0.05 then
        local a = ((t.TimePosition or 0) + 0.016) / len
        local w = WIN[kind] or WIN.default
        if a < w[1] or a > w[2] then return false end
    end

    -- Anti Fake (cek arah hadap)
    if CFG.parry_antifake then
        local kr, mr = root(m), root(LP.Character)
        if kr and mr then
            local to = flat(mr.Position - kr.Position)
            if to.Magnitude > 0.3 then
                local look = flat(kr.CFrame.LookVector)
                if look.Magnitude > 0.05 and look.Unit:Dot(to.Unit) < -0.25 then
                    return false
                end
            end
        end
    end
    return true
end

-- ⭐ LEBIH RINGAN (Cuma nempel ke Heartbeat pas animasi jalan)
local function watch(t, kind, m)
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not CFG.parry_on or not t.IsPlaying then
            if conn then conn:Disconnect() end
            return
        end
        if inHit(t, kind, m) then
            doP()
            if not CFG.parry_aggro and conn then
                conn:Disconnect()
            end
        end
    end)
    
    t.Stopped:Connect(function()
        if conn then conn:Disconnect() end
    end)
    
    task.delay(2, function()
        if conn then pcall(function() conn:Disconnect() end) end
    end)
end

local function bind(m)
    if not m or attached[m] then return end
    local plr = Players:GetPlayerFromCharacter(m)
    
    if plr and not isKiller(plr) then return end
    if not plr then
        local r = m:GetAttribute("Role")
        -- ⭐ FIX TYPO DI SINI (Hapus backslash)
        if type(r) ~= "string" or not r:lower():find("killer") then return end
    end
    
    attached[m] = true

    task.spawn(function()
        local hum = m:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local an = hum:FindFirstChildOfClass("Animator")
        if not an then return end

        -- Nangkep animasi via Event (Jauh lebih ringan dari polling)
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
        if isKiller(p) and p.Character then
            bind(p.Character)
        end
    end
end

-- Event Pas Player Baru Join / Respawn
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        attached[c] = nil
        task.wait(0.25)
        if isKiller(p) then bind(c) end
    end)
end)

-- Untuk player yang udah ada di game
for _, p in ipairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function(c)
        attached[c] = nil
        task.wait(0.25)
        if isKiller(p) then bind(c) end
    end)
end

-- Scan berkala buat jaga-jaga
task.spawn(function()
    while task.wait(1) do scan() end
end)

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.P then doP() end
end)

print("[KZ] Auto Parry loaded (Optimized & Fixed)")
