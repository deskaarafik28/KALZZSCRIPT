--[[
    KALZZSCRIPT
    modules/auto-parry.lua
]]

local S = _G.KZ
if not S then return end

local LP = S.LP
local PG = S.PG
local CFG = S.CFG

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
    lunge={0.14,0.65}, basic={0.16,0.68}, frenzy={0.10,0.72},
    special={0.14,0.68}, default={0.14,0.68},
}

local function root(m) return m and (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart) end
local function flat(v) return Vector3.new(v.X,0,v.Z) end

local function isKiller(p)
    if not p or p==LP or not p.Character then return false end
    if p.Team and p.Team.Name=="Killer" then return true end
    local r = p.Character:GetAttribute("Role") or p:GetAttribute("Role")
    if type(r)=="string" and r:lower():find("killer") then return true end
    return p.Team and p.Team.Name and p.Team.Name:lower():find("killer") ~= nil
end

local PR
pcall(function() PR = S.RS.Remotes.Items["Parrying Dagger"].parry end)

local last, attached = 0, {}

local function busy()
    local ch = LP.Character
    if not ch then return true end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return true end
    for _, a in ipairs({"Knocked","Downed","Hooked","Carried"}) do
        if ch:GetAttribute(a) == true then return true end
    end
    local an = hum:FindFirstChildOfClass("Animator")
    if an then
        local ok, tr = pcall(function() return an:GetPlayingAnimationTracks() end)
        if ok and tr then
            for _, t in ipairs(tr) do
                local n = ((t.Animation and t.Animation.Name) or ""):lower()
                if n:find("vault") or n:find("window") or n:find("pallet") then return true end
            end
        end
    end
    return false
end

local function doP()
    if not CFG.parry_on or busy() then return end
    local n = os.clock()
    if n - last < (CFG.parry_aggro and 0.028 or 0.08) then return end
    last = n
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
        if b and firesignal then
            firesignal(b.MouseButton1Down)
            task.wait()
            firesignal(b.MouseButton1Up)
        end
    end)
end
_G.KZ_ManualParry = doP

local function gD(m)
    local a, b = root(LP.Character), root(m)
    return (a and b) and (a.Position - b.Position).Magnitude or 9999
end

local function inHit(t, kind, m)
    if not t.IsPlaying or gD(m) > (CFG.parry_radius or 15) + 1.8 then return false end
    local len = t.Length
    if len and len > 0.05 then
        local a = ((t.TimePosition or 0) + 0.016) / len
        local w = WIN[kind] or WIN.default
        if a < w[1] or a > w[2] then return false end
    end
    if CFG.parry_antifake then
        local kr, mr = root(m), root(LP.Character)
        if kr and mr then
            local to = flat(mr.Position - kr.Position)
            if to.Magnitude > 0.25 then
                local look = flat(kr.CFrame.LookVector)
                if look.Magnitude > 0.05 and look.Unit:Dot(to.Unit) < -0.2 then return false end
            end
        end
    end
    return true
end

local function bind(m)
    if not m or attached[m] then return end
    local plr = S.Players:GetPlayerFromCharacter(m)
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
        for _ = 1, 20 do
            if an then break end
            task.wait(0.15)
            an = hum:FindFirstChildOfClass("Animator")
        end
        if not an then return end
        an.AnimationPlayed:Connect(function(t)
            if not CFG.parry_on or not t or not t.Animation then return end
            local id = tostring(t.Animation.AnimationId or ""):match("%d+") or ""
            local kind = VALID[id]
            if not kind then return end
            local conn
            conn = S.RSvc.Heartbeat:Connect(function()
                if not CFG.parry_on or not t.IsPlaying then
                    if conn then conn:Disconnect() end
                    return
                end
                if inHit(t, kind, m) then
                    doP()
                    if not CFG.parry_aggro and conn then conn:Disconnect() end
                end
            end)
            t.Stopped:Connect(function()
                if conn then conn:Disconnect() end
            end)
        end)
        while m.Parent do
            S.RSvc.Heartbeat:Wait()
            if not CFG.parry_on then continue end
            local ok, tr = pcall(function() return an:GetPlayingAnimationTracks() end)
            if ok and tr then
                for _, t in ipairs(tr) do
                    local id = tostring(t.Animation and t.Animation.AnimationId or ""):match("%d+") or ""
                    local kind = VALID[id]
                    if kind and t.IsPlaying and inHit(t, kind, m) then doP() end
                end
            end
        end
    end)
end

local function scan()
    for _, p in ipairs(S.Players:GetPlayers()) do
        if isKiller(p) and p.Character then bind(p.Character) end
    end
end

scan()

S.Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        attached[c] = nil
        task.wait(0.3)
        if isKiller(p) then bind(c) end
    end)
end)

for _, p in ipairs(S.Players:GetPlayers()) do
    p.CharacterAdded:Connect(function(c)
        attached[c] = nil
        task.wait(0.3)
        if isKiller(p) then bind(c) end
    end)
end

task.spawn(function()
    while task.wait(0.8) do scan() end
end)

S.UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.P then doP() end
end)

print("[KZ] auto-parry loaded")
