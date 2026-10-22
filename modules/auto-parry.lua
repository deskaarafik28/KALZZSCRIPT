-- ======================
-- AUTO PARRY • GANAS + BYPASS HOOK
-- vault/pallet/gene/hook = tidak dagger
-- ======================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local CFG = _G.KALZZ_CFG or {}
if CFG.parry_on == nil then CFG.parry_on = true end
CFG.parry_radius = CFG.parry_radius or 16
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

local WIN = {
    lunge   = {0.02, 0.88},
    basic   = {0.03, 0.90},
    frenzy  = {0.01, 0.90},
    special = {0.02, 0.88},
    default = {0.02, 0.90},
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
        local r = m:GetAttribute("Role") or plr:GetAttribute("Role")
        if type(r) == "string" then
            local rl = r:lower()
            if rl:find("killer") then return true end
            if rl:find("survivor") then return false end
        end
        if plr.Team and plr.Team.Name then
            local t = plr.Team.Name:lower()
            if t:find("killer") then return true end
            if t:find("survivor") then return false end
        end
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

    for _, a in ipairs({
        "Knocked","Downed","Hooked","Carried","IsCarried","OnHook",
        "Repairing","Healing","OpeningGate","Interacting",
        "Vaulting","OnWindow","OnPallet","DroppingPallet",
    }) do
        local v = ch:GetAttribute(a)
        if v == true or v == 1 then return true end
    end

    if hum:GetState() == Enum.HumanoidStateType.Climbing then return true end

    local an = hum:FindFirstChildOfClass("Animator")
    if an then
        local ok, tracks = pcall(function() return an:GetPlayingAnimationTracks() end)
        if ok and tracks then
            for _, t in ipairs(tracks) do
                local n = ((t.Animation and t.Animation.Name) or ""):lower()
                if n:find("vault") or n:find("window") or n:find("pallet")
                    or n:find("generator") or n:find("repair") or n:find("gate")
                    or n:find("open") or n:find("heal") or n:find("medkit")
                    or n:find("drop") or n:find("hook") or n:find("sacrifice")
                    or n:find("carry") or n:find("pickup") then
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
    local cd = CFG.parry_aggro and 0.008 or 0.025
    if now - lastParry < cd then return end
    if key and fired[key] and (now - fired[key]) < 0.28 then return end

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
            task.defer(function()
                pcall(function() firesignal(b.MouseButton1Up) end)
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
    if busy() then return false end

    local d = distTo(m)
    local rad = (CFG.parry_radius or 16) + (CFG.parry_aggro and 2.8 or 1.5)
    if d > rad then return false end

    local len = t.Length
    if len and len > 0.04 then
        local look = CFG.parry_aggro and 0.045 or 0.028
        if kind == "lunge" or kind == "frenzy" then look = look + 0.012 end
        local a = ((t.TimePosition or 0) + look) / len
        local w = WIN[kind] or WIN.default
        if a < w[1] or a > w[2] then return false end
    end

    if CFG.parry_antifake then
        local kr, mr = root(m), root(LP.Character)
        if kr and mr then
            local to = flat(mr.Position - kr.Position)
            if to.Magnitude > 0.35 then
                local look = flat(kr.CFrame.LookVector)
                if look.Magnitude > 0.05 and look.Unit:Dot(to.Unit) < -0.55 then
                    if d > 6 then return false end
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

    if shouldParry(t, kind, m) then
        doP(key)
    end

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
        for _ = 1, 25 do
            if an then break end
            task.wait(0.08)
            an = hum:FindFirstChildOfClass("Animator")
            if not m.Parent then return end
        end
        if not an then attached[m] = nil return end

        an.AnimationPlayed:Connect(function(t)
            onAnim(t, m)
        end)

        task.spawn(function()
            while m.Parent and attached[m] do
                if CFG.parry_on and not busy() then
                    local ok, tracks = pcall(function() return an:GetPlayingAnimationTracks() end)
                    if ok and tracks then
                        for _, t in ipairs(tracks) do
                            if t.IsPlaying and t.Animation then
                                local id = tostring(t.Animation.AnimationId or ""):match("%d+") or ""
                                if VALID[id] then
                                    onAnim(t, m)
                                end
                            end
                        end
                    end
                end
                task.wait(CFG.parry_aggro and 0.04 or 0.07)
            end
        end)
    end)
end

local function scan()
    for _, p in ipairs(Players:GetPlayers()) do
        -- ⭐ FIX TYPO: Hapus backslash
        if p ~= LP and p.Character and isKillerModel(p.Character) then
            bind(p.Character)
        end
    end
end

scan()
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        attached[c] = nil
        task.wait(0.12)
        if isKillerModel(c) then bind(c) end
    end)
end)
for _, p in ipairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function(c)
        attached[c] = nil
        task.wait(0.12)
        if isKillerModel(c) then bind(c) end
    end)
end

task.spawn(function()
    while task.wait(0.35) do scan() end
end)

task.spawn(function()
    while task.wait(1.2) do
        local now = os.clock()
        for k, t in pairs(fired) do
            if now - t > 1.2 then fired[k] = nil end
        end
    end
end)

UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.P then doP() end
end)

-- RADIUS CIRCLE
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

local lastVis = 0
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastVis < 0.033 then return end
    lastVis = now

    if not CFG.parry_show_circle or not CFG.parry_on then
        base.Transparency = 1
        return
    end
    local my = root(LP.Character)
    if not my then base.Transparency = 1 return end

    local radius = CFG.parry_radius or 16
    local threat = killerInRange(radius)
    stroke.Color = threat and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(70, 255, 130)
    base.Size = Vector3.new(radius * 2, 0.05, radius * 2)
    base.CFrame = CFrame.new(my.Position - Vector3.new(0, 2.95, 0))
    base.Transparency = 0
end)

print("[KZ] Auto Parry • bypass hook/vault/pallet • ganas")
