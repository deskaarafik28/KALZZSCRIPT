--[[ KALZZ HUB v22 FINAL | Auto Gen Function-Only | No VD_AutoGenerator | Hub UI Tetap ]]

-- Anti-Kick hook
pcall(function()
    local o
    o = hookmetamethod(game, "__namecall", newcclosure(function(s, ...)
        if getnamecallmethod() == "Kick" and s == game:GetService("Players").LocalPlayer then return end
        return o(s, ...)
    end))
end)

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

-- ============================================================
-- CONFIG
-- ============================================================
local CFG = _G.KALZZ_CFG or {
    tof_on = true, tof_fov = 500, tof_predict = 2.8, tof_maxdist = 2000,
    veil_on = true, veil_fov = 320, veil_predict = 2.8, veil_maxdist = 2000,
    parry_on = true, parry_radius = 14, parry_sensitive = 200, parry_aggro = true,
    fast_vault = true,
    esp_k = true, esp_s = true, esp_g = true, esp_out = false, esp_range = 5000,
    fov_lock = false, fov_value = 120,
    ambient = true, boost_fps = true,
    alert = true,
    -- Auto Gen (function-only)
    gene_on = false, gene_method = "SUCCESS",
}
_G.KALZZ_CFG = CFG

_G.KZ_ToFAimDir = nil
_G.KZ_ToFStamp = 0
_G.KZ_VeilState = _G.KZ_VeilState or {}
_G.KZ_VeilState.lookVector = _G.KZ_VeilState.lookVector or nil
_G.KZ_VeilState.stamp = _G.KZ_VeilState.stamp or 0

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

-- ============================================================
-- REMOTE CACHE
-- ============================================================
local RC = { tof = nil, veil = nil, parry = nil, fastvault = nil }
pcall(function() RC.tof = RS.Remotes.Items["Twist of Fate"].Fire end)
pcall(function() RC.parry = RS.Remotes.Items["Parrying Dagger"].parry end)
pcall(function()
    local k = RS.Remotes:FindFirstChild("Killers")
    if k then
        local v = k:FindFirstChild("Veil")
        if v then RC.veil = v:FindFirstChild("Spearthrow") end
    end
end)
pcall(function()
    local w = RS.Remotes:FindFirstChild("Window")
    if w then RC.fastvault = w:FindFirstChild("SurvivorFastVault") or w:FindFirstChild("fastvault") end
end)
task.delay(3, function()
    for _, o in ipairs(RS:GetDescendants()) do
        if o:IsA("RemoteEvent") then
            local nl = o.Name:lower()
            if not RC.tof and nl == "fire" then
                local f = ""
                pcall(function() f = o:GetFullName():lower() end)
                if f:find("twist") or f:find("fate") then RC.tof = o end
            end
            if not RC.veil and nl == "spearthrow" then RC.veil = o end
        end
    end
    print("[KZ] RC: ToF="..tostring(RC.tof~=nil).." Veil="..tostring(RC.veil~=nil).." Parry="..tostring(RC.parry~=nil).." FV="..tostring(RC.fastvault~=nil))
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

local function getClosest(wantKiller, fov, maxDist)
    if not Cam then Cam = Workspace.CurrentCamera end
    if not Cam then return nil end
    local ctr = Cam.ViewportSize / 2
    local myRoot = rtp(LP.Character)
    local myPos = myRoot and myRoot.Position or Cam.CFrame.Position
    local best, bestD = nil, fov or 500
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local k = isKiller(p)
            if (wantKiller and k) or (not wantKiller and not k) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local root = rtp(p.Character)
                if hum and hum.Health > 0 and root then
                    local wd = (root.Position - myPos).Magnitude
                    if wd <= (maxDist or 2000) then
                        local sp, on = Cam:WorldToViewportPoint(root.Position)
                        if on and sp.Z > 0 then
                            local d = (Vector2.new(sp.X, sp.Y) - ctr).Magnitude
                            if d < bestD then bestD = d; best = root end
                        end
                    end
                end
            end
        end
    end
    return best
end

-- ============================================================
-- AIM LOOP (ToF + Veil)
-- ============================================================
RSvc.Heartbeat:Connect(function()
    Cam = Workspace.CurrentCamera
    local now = os.clock()
    local localK = isLocalKiller()

    if CFG.tof_on and not localK then
        local t = getClosest(true, CFG.tof_fov, CFG.tof_maxdist)
        if t and t.Parent then
            local o = getMuzzle()
            local vel = t.AssemblyLinearVelocity or Vector3.zero
            vel = Vector3.new(vel.X, 0, vel.Z)
            local dist = (t.Position - o).Magnitude
            local pred = t.Position + vel * math.clamp(dist / 260, 0.04, 0.7) * CFG.tof_predict + Vector3.new(0, 0.9, 0)
            local dir = pred - o
            if dir.Magnitude > 0.2 then
                _G.KZ_ToFAimDir = dir.Unit
                _G.KZ_ToFStamp = now
            end
        end
    end
    if _G.KZ_ToFAimDir and (now - _G.KZ_ToFStamp) > 0.5 then _G.KZ_ToFAimDir = nil end

    if CFG.veil_on and localK then
        local t = getClosest(false, CFG.veil_fov, CFG.veil_maxdist)
        local my = rtp(LP.Character)
        if t and t.Parent and my then
            local o = my.Position
            local hand = LP.Character and (LP.Character:FindFirstChild("RightHand") or LP.Character:FindFirstChild("Right Arm"))
            if hand and hand:IsA("BasePart") then o = hand.Position end
            local vel = t.AssemblyLinearVelocity or Vector3.zero
            vel = Vector3.new(vel.X, 0, vel.Z)
            local dist = (t.Position - o).Magnitude
            local pred = t.Position + vel * math.clamp(dist / 200, 0.05, 0.6) * CFG.veil_predict
            pred = pred + Vector3.new(0, math.clamp(dist * 0.05, 2, 14), 0)
            local dir = pred - o
            if dir.Magnitude > 0.2 then
                _G.KZ_VeilState.lookVector = dir.Unit
                _G.KZ_VeilState.stamp = now
            end
        end
    end
    if _G.KZ_VeilState.lookVector and (now - _G.KZ_VeilState.stamp) > 0.5 then _G.KZ_VeilState.lookVector = nil end
end)

-- ============================================================
-- UNIFIED HOOK
-- ============================================================
do
    if type(hookmetamethod) == "function" and type(newcclosure) == "function" and type(getnamecallmethod) == "function" then
        local OLD
        OLD = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local m
            pcall(function() m = getnamecallmethod() end)
            if m == "Kick" then
                if self == LP then return nil end
                return OLD(self, ...)
            end
            if m ~= "FireServer" then return OLD(self, ...) end

            local tofDir = _G.KZ_ToFAimDir
            local veilDir = _G.KZ_VeilState.lookVector
            local hasToF = CFG.tof_on and typeof(tofDir) == "Vector3"
            local hasVeil = CFG.veil_on and typeof(veilDir) == "Vector3"
            if not hasToF and not hasVeil then return OLD(self, ...) end
            if type(self) ~= "userdata" and type(self) ~= "table" then return OLD(self, ...) end

            local args = table.pack(...)
            local n = args.n

            if hasVeil then
                local match = (RC.veil and self == RC.veil)
                if not match then
                    local sn = ""
                    pcall(function() sn = tostring(self.Name or "") end)
                    if sn == "Spearthrow" then match = true end
                end
                if match and typeof(args[1]) == "Vector3" and args[1].Magnitude <= 5 then
                    args[1] = veilDir
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
        print("[KZ] unified hook installed")
    end
end

-- ============================================================
-- AUTO GENERATOR v3 — FUNCTION ONLY (NO UI STANDALONE)
-- Control via CFG.gene_on + CFG.gene_method dari hub UI
-- ============================================================
pcall(function()
    local SUCCESS_MIN, SUCCESS_MAX = 102, 116
    local NEUTRAL_MIN, NEUTRAL_MAX = 116, 159
    local TriggerDelay = 0.035
    local LastTrigger = 0
    local Busy = false
    local ScourgeActive = false
    local ScourgeRound = 0

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
                if Check then
                    Line = Check:FindFirstChild("Line")
                    Goal = Check:FindFirstChild("Goal")
                end
            end
            local SV = PG:FindFirstChild("Survivor-mob")
            if SV then
                local C = SV:FindFirstChild("Controls")
                if C then Action = C:FindFirstChild("action") end
            end
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
        ScourgeRound = ScourgeRound + 1
    end

    if KingScourgeStart then
        KingScourgeStart.OnClientEvent:Connect(function(p1, p2, p3)
            if not CFG.gene_on then return end
            ScourgeActive = true; ScourgeRound = 0; Busy = false
            task.defer(function()
                if CFG.gene_on and CFG.gene_method == "INSTANT" then InstantScourge() end
            end)
        end)
    end
    if KingScourgeEnd then
        KingScourgeEnd.OnClientEvent:Connect(function(p)
            ScourgeActive = false; Busy = false
        end)
    end

    local PreviousVisible = false

    RSvc.RenderStepped:Connect(function()
        if not CFG.gene_on then PreviousVisible = false; return end
        if not Check then RefreshRefs() end
        if not Check then return end
        local Visible = Check.Visible
        local Mode = CFG.gene_method or "SUCCESS"

        if Visible and not PreviousVisible then
            Busy = false
            if not ScourgeActive and Mode == "INSTANT" then InstantNormal() end
        end
        PreviousVisible = Visible

        if Visible and not ScourgeActive and not Busy then
            local ShouldTrigger = false
            if Mode == "SUCCESS" then ShouldTrigger = IsSuccess()
            elseif Mode == "NEUTRAL" then ShouldTrigger = IsNeutral() end
            if ShouldTrigger then
                Busy = true; TriggerAction()
                task.delay(0.07, function() Busy = false end)
            end
        end

        if ScourgeActive and Visible then
            if Mode == "SUCCESS" and not Busy and IsSuccess() then
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

    task.spawn(function()
        local LastGoal = nil
        while true do
            task.wait(0.005)
            if CFG.gene_on and ScourgeActive and (CFG.gene_method or "") == "INSTANT" then
                RefreshRefs()
                if Check and Check.Visible and Goal and Line then
                    local CG = tonumber(Goal.Rotation) or 0
                    if LastGoal == nil then
                        LastGoal = CG; InstantScourge()
                    elseif math.abs(CG - LastGoal) > 1 then
                        LastGoal = CG; InstantScourge()
                    end
                end
            else LastGoal = nil end
        end
    end)

    LP.CharacterAdded:Connect(function()
        Busy = false; ScourgeActive = false; PreviousVisible = false
        task.wait(1); RefreshRefs()
    end)

    print("[KZ] Auto Generator v3 function-only loaded (no UI)")
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
            if my and en and (my.Position - en.Position).Magnitude <= CFG.parry_radius + CFG.parry_sensitive * 0.01 then
                doP()
            end
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
-- ESP
-- ============================================================
pcall(function()
    local cache = {}
    local genCache, genT = {}, 0
    task.spawn(function()
        while true do
            task.wait(0.2)
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP and pl.Character then
                    local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local k = isKiller(pl)
                        local en = (k and CFG.esp_k) or (not k and CFG.esp_s)
                        if en then
                            if not cache[pl] then
                                local hl = Instance.new("Highlight")
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = PG
                                cache[pl] = hl
                            end
                            local hl = cache[pl]
                            hl.Adornee = pl.Character
                            hl.FillColor = k and Color3.fromRGB(230,80,80) or Color3.fromRGB(80,160,230)
                            hl.OutlineColor = hl.FillColor
                            hl.FillTransparency = CFG.esp_out and 1 or 0.55
                            hl.Enabled = true
                        elseif cache[pl] then
                            cache[pl].Enabled = false
                        end
                    elseif cache[pl] then
                        cache[pl].Enabled = false
                    end
                elseif cache[pl] then
                    cache[pl]:Destroy(); cache[pl] = nil
                end
            end
            if CFG.esp_g then
                local now = os.clock()
                if now - genT > 4 then
                    genCache = {}
                    for _, o in ipairs(Workspace:GetDescendants()) do
                        if (o:IsA("Model") or o:IsA("BasePart")) and o.Parent then
                            local n = o.Name:lower()
                            if (n:find("generator") or n:find("fuse")) and n ~= "gen" then
                                table.insert(genCache, o)
                            end
                        end
                    end
                    genT = now
                end
                for _, o in ipairs(genCache) do
                    if not o.Parent then
                        if cache[o] then cache[o]:Destroy(); cache[o]=nil end
                    else
                        local done = false
                        local prog = o:GetAttribute("Progress") or o:GetAttribute("progress")
                        if typeof(prog)=="number" and prog >= 99.5 then done = true end
                        if o:GetAttribute("Completed") or o:GetAttribute("Finished") then done = true end
                        if not done then
                            if not cache[o] then
                                local hl = Instance.new("Highlight")
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = PG
                                cache[o] = hl
                            end
                            local hl = cache[o]
                            hl.Adornee = o
                            hl.FillColor = Color3.fromRGB(80,220,120)
                            hl.OutlineColor = Color3.fromRGB(80,220,120)
                            hl.FillTransparency = CFG.esp_out and 1 or 0.6
                            hl.Enabled = true
                        elseif cache[o] then
                            cache[o]:Destroy(); cache[o] = nil
                        end
                    end
                end
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(pl)
        if cache[pl] then cache[pl]:Destroy(); cache[pl] = nil end
    end)
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
    al.BackgroundTransparency = 1; al.TextColor3 = Color3.fromRGB(240,210,140)
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
                        local t, c
                        if cl <= 10 then t="!!!"; c=Color3.fromRGB(255,90,90)
                        elseif cl <= 17 then t="!!"; c=Color3.fromRGB(255,160,100)
                        else t="!"; c=Color3.fromRGB(255,220,130) end
                        al.Text = string.format("%s  (%.0f)", t, cl)
                        al.TextColor3 = c
                        al.Visible = true
                    else al.Visible = false end
                else al.Visible = false end
            end
        end
    end)
end)

-- ============================================================
-- CUSTOM UI HUB
-- ============================================================
local COL = {
    bg = Color3.fromRGB(15,15,18),
    panel = Color3.fromRGB(20,20,24),
    side = Color3.fromRGB(17,17,21),
    card = Color3.fromRGB(26,26,32),
    tabOn = Color3.fromRGB(38,38,46),
    brd = Color3.fromRGB(48,48,56),
    brdS = Color3.fromRGB(38,38,46),
    tx = Color3.fromRGB(240,240,245),
    txD = Color3.fromRGB(160,160,175),
    txF = Color3.fromRGB(110,110,125),
    acc = Color3.fromRGB(100,140,230),
    off = Color3.fromRGB(52,52,62),
    red = Color3.fromRGB(220,80,80),
}

local function getParentTarget()
    if gethui then local ok, h = pcall(gethui); if ok and h then return h end end
    return CoreGui
end

local function cR(o, r) local c = Instance.new("UICorner", o); c.CornerRadius = UDim.new(0, r or 8); return c end
local function cS(o, col, t, tr)
    local s = Instance.new("UIStroke", o)
    s.Color = col or COL.brd; s.Thickness = t or 1; s.Transparency = tr or 0.4
    return s
end

local GUI = Instance.new("ScreenGui")
GUI.Name = "KalzzHub_"..tostring(os.time())
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 999998
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Enabled = true
pcall(function() GUI.Parent = getParentTarget() end)
if not GUI.Parent then GUI.Parent = PG end
Instance.new("UIScale", GUI).Scale = 0.80

local Main = Instance.new("Frame", GUI)
Main.Name = "KZ_Main"
Main.Size = UDim2.fromOffset(580, 480)
Main.Position = UDim2.new(0.5, -290, 0.5, -240)
Main.BackgroundColor3 = COL.bg
Main.BackgroundTransparency = 0.30
Main.BorderSizePixel = 0
Main.ZIndex = 10
cR(Main, 10); cS(Main, COL.brd, 1, 0.4)

local Hdr = Instance.new("Frame", Main)
Hdr.Size = UDim2.new(1, 0, 0, 48)
Hdr.BackgroundColor3 = COL.panel
Hdr.BackgroundTransparency = 0.3
Hdr.BorderSizePixel = 0
Hdr.ZIndex = 11
cR(Hdr, 10)

local Title = Instance.new("TextLabel", Hdr)
Title.Size = UDim2.new(1, -140, 0, 20); Title.Position = UDim2.fromOffset(18, 8)
Title.BackgroundTransparency = 1; Title.Text = "KALZZ HUB v22"
Title.TextColor3 = COL.tx; Title.Font = Enum.Font.GothamBold; Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left; Title.ZIndex = 12

local Sub = Instance.new("TextLabel", Hdr)
Sub.Size = UDim2.new(1, -140, 0, 14); Sub.Position = UDim2.fromOffset(18, 28)
Sub.BackgroundTransparency = 1; Sub.Text = INVITE
Sub.TextColor3 = COL.txF; Sub.Font = Enum.Font.Gotham; Sub.TextSize = 10
Sub.TextXAlignment = Enum.TextXAlignment.Left; Sub.ZIndex = 12

local function mkBtn(x, col, txt)
    local b = Instance.new("TextButton", Hdr)
    b.Size = UDim2.fromOffset(26, 26); b.Position = UDim2.new(1, x, 0.5, -13)
    b.BackgroundColor3 = col; b.BackgroundTransparency = 0.25
    b.Text = txt or ""; b.TextColor3 = Color3.fromRGB(240,240,240)
    b.Font = Enum.Font.GothamBold; b.TextSize = 14
    b.BorderSizePixel = 0; b.AutoButtonColor = false; b.ZIndex = 12
    cR(b, 6)
    return b
end
local MinBtn = mkBtn(-68, Color3.fromRGB(60,60,75), "–")
local ClsBtn = mkBtn(-36, COL.red, "×")

local drg, ds, sp
Hdr.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drg = true; ds = i.Position; sp = Main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - ds
        Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drg = false end
end)

local Side = Instance.new("Frame", Main)
Side.Size = UDim2.new(0, 150, 1, -58); Side.Position = UDim2.fromOffset(8, 54)
Side.BackgroundColor3 = COL.side; Side.BackgroundTransparency = 0.3
Side.BorderSizePixel = 0; Side.ZIndex = 11; cR(Side, 8)

local SideL = Instance.new("ScrollingFrame", Side)
SideL.Size = UDim2.new(1, -8, 1, -8); SideL.Position = UDim2.fromOffset(4, 4)
SideL.BackgroundTransparency = 1; SideL.BorderSizePixel = 0
SideL.ScrollBarThickness = 2; SideL.ScrollBarImageColor3 = COL.brd
SideL.CanvasSize = UDim2.new(0, 0, 0, 300); SideL.ZIndex = 12

local Cont = Instance.new("Frame", Main)
Cont.Size = UDim2.new(1, -172, 1, -58); Cont.Position = UDim2.fromOffset(162, 54)
Cont.BackgroundColor3 = COL.bg; Cont.BackgroundTransparency = 0.3
Cont.BorderSizePixel = 0; Cont.ZIndex = 11; cR(Cont, 8)

local CT = Instance.new("TextLabel", Cont)
CT.Size = UDim2.new(1, -32, 0, 22); CT.Position = UDim2.fromOffset(16, 14)
CT.BackgroundTransparency = 1; CT.Text = ""
CT.TextColor3 = COL.tx; CT.Font = Enum.Font.GothamBold; CT.TextSize = 16
CT.TextXAlignment = Enum.TextXAlignment.Left; CT.ZIndex = 12

local CSL = Instance.new("ScrollingFrame", Cont)
CSL.Size = UDim2.new(1, -16, 1, -50); CSL.Position = UDim2.fromOffset(8, 44)
CSL.BackgroundTransparency = 1; CSL.BorderSizePixel = 0
CSL.ScrollBarThickness = 3; CSL.ScrollBarImageColor3 = COL.brd
CSL.CanvasSize = UDim2.new(0, 0, 0, 2000); CSL.ZIndex = 12

local W = {T={}, TB={}, Cur=nil, Cnt=0}
function W:Show(n)
    for k, p in pairs(self.T) do p.P.Visible = (k == n) end
    for k, b in pairs(self.TB) do
        local a = (k == n)
        TS:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = a and COL.tabOn or COL.side,
            BackgroundTransparency = a and 0 or 1
        }):Play()
        local l = b:FindFirstChild("Lbl")
        if l then TS:Create(l, TweenInfo.new(0.15), {TextColor3 = a and COL.tx or COL.txD}):Play() end
    end
    self.Cur = n
    CT.Text = n
end

function W:AddTab(cfg)
    local n = cfg.Title
    self.Cnt = self.Cnt + 1
    local i = self.Cnt - 1
    local b = Instance.new("TextButton", SideL)
    b.Size = UDim2.new(1, -4, 0, 34)
    b.Position = UDim2.new(0, 2, 0, i * 38 + 2)
    b.BackgroundColor3 = COL.side; b.BackgroundTransparency = 1
    b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false; b.ZIndex = 13
    cR(b, 6)
    local l = Instance.new("TextLabel", b)
    l.Name = "Lbl"; l.Size = UDim2.new(1, -20, 1, 0); l.Position = UDim2.fromOffset(14, 0)
    l.BackgroundTransparency = 1; l.Text = n
    l.TextColor3 = COL.txD; l.Font = Enum.Font.GothamMedium; l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 14
    b.MouseButton1Click:Connect(function() W:Show(n) end)
    local p = Instance.new("Frame", CSL)
    p.Size = UDim2.new(1, 0, 0, 2000)
    p.BackgroundTransparency = 1; p.Visible = false; p.ZIndex = 13
    local t = {P=p, Y=4}

    function t:Sec(s)
        local x = Instance.new("TextLabel", p)
        x.Size = UDim2.new(1, -8, 0, 24); x.Position = UDim2.fromOffset(4, self.Y)
        x.BackgroundTransparency = 1; x.Text = string.upper(s)
        x.TextColor3 = COL.txF; x.Font = Enum.Font.GothamBold; x.TextSize = 11
        x.TextXAlignment = Enum.TextXAlignment.Left; x.ZIndex = 14
        self.Y = self.Y + 28
        return self
    end

    function t:Banner(c)
        local bc = Instance.new("Frame", p)
        bc.Size = UDim2.new(1, -8, 0, 120); bc.Position = UDim2.fromOffset(4, self.Y)
        bc.BackgroundColor3 = COL.card; bc.BackgroundTransparency = 0.4
        bc.BorderSizePixel = 0; bc.ZIndex = 14
        cR(bc, 8); cS(bc, COL.brdS, 1, 0.4)
        local img = Instance.new("ImageLabel", bc)
        img.Size = UDim2.new(1, -12, 1, -12); img.Position = UDim2.fromOffset(6, 6)
        img.BackgroundTransparency = 1; img.Image = c.Image or IMG
        img.ScaleType = Enum.ScaleType.Crop; img.ZIndex = 15; cR(img, 6)
        self.Y = self.Y + 132
        return self
    end

    function t:Btn(c)
        local b2 = Instance.new("TextButton", p)
        b2.Size = UDim2.new(1, -8, 0, 38); b2.Position = UDim2.fromOffset(4, self.Y)
        b2.BackgroundColor3 = COL.card; b2.BackgroundTransparency = 0.5
        b2.BorderSizePixel = 0; b2.Text = ""; b2.AutoButtonColor = false; b2.ZIndex = 14
        cR(b2, 8); cS(b2, COL.brdS, 1, 0.5)
        local l2 = Instance.new("TextLabel", b2)
        l2.Size = UDim2.new(1, -20, 1, 0); l2.Position = UDim2.fromOffset(14, 0)
        l2.BackgroundTransparency = 1; l2.Text = c.Title
        l2.TextColor3 = COL.tx; l2.Font = Enum.Font.GothamMedium; l2.TextSize = 12
        l2.TextXAlignment = Enum.TextXAlignment.Left; l2.ZIndex = 15
        b2.MouseButton1Click:Connect(function() if c.Callback then pcall(c.Callback) end end)
        self.Y = self.Y + 44
        return self
    end

    function t:Tog(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1, -8, 0, 42); row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.card; row.BackgroundTransparency = 0.5
        row.BorderSizePixel = 0; row.ZIndex = 14
        cR(row, 8); cS(row, COL.brdS, 1, 0.5)
        local l2 = Instance.new("TextLabel", row)
        l2.Size = UDim2.new(1, -80, 1, 0); l2.Position = UDim2.fromOffset(14, 0)
        l2.BackgroundTransparency = 1; l2.Text = c.Title or id
        l2.TextColor3 = COL.tx; l2.Font = Enum.Font.GothamMedium; l2.TextSize = 12
        l2.TextXAlignment = Enum.TextXAlignment.Left; l2.ZIndex = 15
        local st = c.Default or false
        local tr = Instance.new("Frame", row)
        tr.Size = UDim2.fromOffset(40, 22); tr.Position = UDim2.new(1, -54, 0.5, -11)
        tr.BackgroundColor3 = st and COL.acc or COL.off
        tr.BackgroundTransparency = 0.1; tr.BorderSizePixel = 0; tr.ZIndex = 15; cR(tr, 11)
        local k = Instance.new("Frame", tr)
        k.Size = UDim2.fromOffset(16, 16)
        k.Position = st and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        k.BackgroundColor3 = Color3.fromRGB(255,255,255); k.BorderSizePixel = 0; k.ZIndex = 16; cR(k, 8)
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 17
        btn.MouseButton1Click:Connect(function()
            st = not st
            TS:Create(k, TweenInfo.new(0.2), {Position = st and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
            TS:Create(tr, TweenInfo.new(0.2), {BackgroundColor3 = st and COL.acc or COL.off}):Play()
            if c.Callback then pcall(c.Callback, st) end
        end)
        self.Y = self.Y + 48
        return self
    end

    function t:Sl(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1, -8, 0, 56); row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.card; row.BackgroundTransparency = 0.5
        row.BorderSizePixel = 0; row.ZIndex = 14
        cR(row, 8); cS(row, COL.brdS, 1, 0.5)
        local l2 = Instance.new("TextLabel", row)
        l2.Size = UDim2.new(1, -80, 0, 18); l2.Position = UDim2.fromOffset(14, 9)
        l2.BackgroundTransparency = 1; l2.Text = c.Title or id
        l2.TextColor3 = COL.tx; l2.Font = Enum.Font.GothamMedium; l2.TextSize = 12
        l2.TextXAlignment = Enum.TextXAlignment.Left; l2.ZIndex = 15
        local vL = Instance.new("TextLabel", row)
        vL.Size = UDim2.fromOffset(56, 18); vL.Position = UDim2.new(1, -70, 0, 9)
        vL.BackgroundTransparency = 1; vL.Text = tostring(c.Default or c.Min or 0)
        vL.TextColor3 = COL.acc; vL.Font = Enum.Font.GothamBold; vL.TextSize = 12
        vL.TextXAlignment = Enum.TextXAlignment.Right; vL.ZIndex = 15
        local tr = Instance.new("Frame", row)
        tr.Size = UDim2.new(1, -28, 0, 4); tr.Position = UDim2.new(0, 14, 1, -16)
        tr.BackgroundColor3 = COL.off; tr.BackgroundTransparency = 0.1
        tr.BorderSizePixel = 0; tr.ZIndex = 15; cR(tr, 2)
        local mn, mx = c.Min or 0, c.Max or 100
        local pct = ((c.Default or mn) - mn) / (mx - mn)
        local f = Instance.new("Frame", tr)
        f.Size = UDim2.new(pct, 0, 1, 0); f.BackgroundColor3 = COL.acc
        f.BorderSizePixel = 0; f.ZIndex = 16; cR(f, 2)
        local k = Instance.new("Frame", tr)
        k.Size = UDim2.fromOffset(14, 14); k.Position = UDim2.new(pct, -7, 0.5, -7)
        k.BackgroundColor3 = Color3.fromRGB(255,255,255); k.BorderSizePixel = 0; k.ZIndex = 17; cR(k, 7)
        local dg = false
        local function upd(x)
            local a = math.clamp((x - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
            local v = math.floor(mn + (mx - mn) * a + 0.5)
            f.Size = UDim2.new(a, 0, 1, 0); k.Position = UDim2.new(a, -7, 0.5, -7)
            vL.Text = tostring(v)
            if c.Callback then pcall(c.Callback, v) end
        end
        local hb = Instance.new("TextButton", row)
        hb.Size = UDim2.new(1, -20, 0, 26); hb.Position = UDim2.new(0, 10, 1, -30)
        hb.BackgroundTransparency = 1; hb.Text = ""; hb.ZIndex = 18
        hb.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dg = true; upd(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = false end
        end)
        self.Y = self.Y + 62
        return self
    end

    function t:Drop(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1, -8, 0, 42); row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.card; row.BackgroundTransparency = 0.5
        row.BorderSizePixel = 0; row.ZIndex = 14
        cR(row, 8); cS(row, COL.brdS, 1, 0.5)
        local l2 = Instance.new("TextLabel", row)
        l2.Size = UDim2.new(1, -140, 1, 0); l2.Position = UDim2.fromOffset(14, 0)
        l2.BackgroundTransparency = 1; l2.Text = c.Title or id
        l2.TextColor3 = COL.tx; l2.Font = Enum.Font.GothamMedium; l2.TextSize = 12
        l2.TextXAlignment = Enum.TextXAlignment.Left; l2.ZIndex = 15
        local vs = c.Values or {}
        local cur = c.Default or vs[1] or "?"
        local vL = Instance.new("TextLabel", row)
        vL.Size = UDim2.new(0, 110, 1, 0); vL.Position = UDim2.new(1, -122, 0, 0)
        vL.BackgroundTransparency = 1; vL.Text = cur
        vL.TextColor3 = COL.acc; vL.Font = Enum.Font.GothamBold; vL.TextSize = 11
        vL.TextXAlignment = Enum.TextXAlignment.Right; vL.ZIndex = 15
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 16
        local hd = Instance.new("Frame", p)
        hd.Size = UDim2.new(1, -8, 0, 0); hd.Position = UDim2.fromOffset(4, self.Y + 46)
        hd.BackgroundColor3 = COL.card; hd.BackgroundTransparency = 0.1
        hd.BorderSizePixel = 0; hd.ClipsDescendants = true; hd.Visible = false; hd.ZIndex = 20
        cR(hd, 8); cS(hd, COL.brd, 1, 0.4)
        for i, v in ipairs(vs) do
            local opt = Instance.new("TextButton", hd)
            opt.Size = UDim2.new(1, -8, 0, 28); opt.Position = UDim2.fromOffset(4, (i - 1) * 30 + 4)
            opt.BackgroundColor3 = COL.card; opt.BackgroundTransparency = 1
            opt.BorderSizePixel = 0; opt.Text = ""; opt.AutoButtonColor = false; opt.ZIndex = 22
            cR(opt, 5)
            local oL = Instance.new("TextLabel", opt)
            oL.Size = UDim2.new(1, -16, 1, 0); oL.Position = UDim2.fromOffset(12, 0)
            oL.BackgroundTransparency = 1; oL.Text = v
            oL.TextColor3 = COL.txD; oL.Font = Enum.Font.GothamMedium; oL.TextSize = 11
            oL.TextXAlignment = Enum.TextXAlignment.Left; oL.ZIndex = 23
            opt.MouseButton1Click:Connect(function()
                cur = v; vL.Text = v
                TS:Create(hd, TweenInfo.new(0.2), {Size = UDim2.new(1, -8, 0, 0)}):Play()
                task.delay(0.2, function() hd.Visible = false end)
                if c.Callback then pcall(c.Callback, v) end
            end)
        end
        local hH = math.min(#vs * 30 + 8, 150)
        btn.MouseButton1Click:Connect(function()
            if hd.Visible then
                TS:Create(hd, TweenInfo.new(0.2), {Size = UDim2.new(1, -8, 0, 0)}):Play()
                task.delay(0.2, function() hd.Visible = false end)
            else
                hd.Visible = true
                TS:Create(hd, TweenInfo.new(0.2), {Size = UDim2.new(1, -8, 0, hH)}):Play()
            end
        end)
        self.Y = self.Y + 48
        return self
    end

    self.T[n] = t
    self.TB[n] = b
    SideL.CanvasSize = UDim2.new(0, 0, 0, self.Cnt * 38 + 8)
    if not self.Cur then self:Show(n) end
    return t
end

-- ============================================================
-- TABS
-- ============================================================
local TInfo = W:AddTab({Title = "Info"})
local TSurv = W:AddTab({Title = "Survivor"})
local TKil  = W:AddTab({Title = "Killer"})
local TEsp  = W:AddTab({Title = "ESP"})
local TMisc = W:AddTab({Title = "Misc"})

TInfo:Banner({Image = IMG})
TInfo:Sec("KALZZ HUB v22")
TInfo:Btn({Title = "Copy Discord Invite", Callback = function()
    pcall(function() if setclipboard then setclipboard("https://"..INVITE) end end)
end})
TInfo:Btn({Title = "Print Remote Cache", Callback = function()
    print("[KZ] ToF:", RC.tof, "| Veil:", RC.veil, "| Parry:", RC.parry, "| FV:", RC.fastvault)
end})
TInfo:Btn({Title = "Print Aim State", Callback = function()
    print("[KZ] ToFAimDir:", _G.KZ_ToFAimDir)
    print("[KZ] VeilLook:", _G.KZ_VeilState.lookVector)
    print("[KZ] Role:", isLocalKiller() and "Killer" or "Survivor")
end})

TSurv:Sec("Silent Aim (ToF)")
TSurv:Tog("tof_on", {Title = "Enable ToF", Default = CFG.tof_on, Callback = function(v) CFG.tof_on = v end})
TSurv:Sl("tof_fov", {Title = "FOV", Min = 1, Max = 600, Default = CFG.tof_fov, Callback = function(v) CFG.tof_fov = v end})
TSurv:Sl("tof_predict", {Title = "Predict x10", Min = 10, Max = 50, Default = math.floor(CFG.tof_predict * 10), Callback = function(v) CFG.tof_predict = v / 10 end})
TSurv:Sl("tof_maxdist", {Title = "Max Distance", Min = 100, Max = 3000, Default = CFG.tof_maxdist, Callback = function(v) CFG.tof_maxdist = v end})

TSurv:Sec("Auto Generator")
TSurv:Tog("gene_on", {Title = "Enable Auto Gen", Default = CFG.gene_on, Callback = function(v) CFG.gene_on = v end})
TSurv:Drop("gene_method", {Title = "Method", Values = {"SUCCESS", "NEUTRAL", "INSTANT"}, Default = CFG.gene_method, Callback = function(v) CFG.gene_method = v end})

TSurv:Sec("Auto Parry")
TSurv:Tog("parry_on", {Title = "Enable Parry", Default = CFG.parry_on, Callback = function(v) CFG.parry_on = v end})
TSurv:Sl("parry_radius", {Title = "Radius", Min = 1, Max = 30, Default = CFG.parry_radius, Callback = function(v) CFG.parry_radius = v end})
TSurv:Sl("parry_sensitive", {Title = "Sensitive", Min = 0, Max = 500, Default = CFG.parry_sensitive, Callback = function(v) CFG.parry_sensitive = v end})
TSurv:Tog("parry_aggro", {Title = "Aggressive", Default = CFG.parry_aggro, Callback = function(v) CFG.parry_aggro = v end})

TSurv:Sec("Movement")
TSurv:Tog("fast_vault", {Title = "Fast Vault", Default = CFG.fast_vault, Callback = function(v) CFG.fast_vault = v end})

TKil:Sec("Silent Aim (Veil)")
TKil:Tog("veil_on", {Title = "Enable Veil", Default = CFG.veil_on, Callback = function(v) CFG.veil_on = v end})
TKil:Sl("veil_fov", {Title = "FOV", Min = 1, Max = 600, Default = CFG.veil_fov, Callback = function(v) CFG.veil_fov = v end})
TKil:Sl("veil_predict", {Title = "Predict x10", Min = 10, Max = 50, Default = math.floor(CFG.veil_predict * 10), Callback = function(v) CFG.veil_predict = v / 10 end})
TKil:Sl("veil_maxdist", {Title = "Max Distance", Min = 100, Max = 3000, Default = CFG.veil_maxdist, Callback = function(v) CFG.veil_maxdist = v end})

TEsp:Sec("ESP Targets")
TEsp:Tog("esp_k", {Title = "Killer ESP", Default = CFG.esp_k, Callback = function(v) CFG.esp_k = v end})
TEsp:Tog("esp_s", {Title = "Survivor ESP", Default = CFG.esp_s, Callback = function(v) CFG.esp_s = v end})
TEsp:Tog("esp_g", {Title = "Generator ESP", Default = CFG.esp_g, Callback = function(v) CFG.esp_g = v end})
TEsp:Tog("esp_out", {Title = "Outline Only", Default = CFG.esp_out, Callback = function(v) CFG.esp_out = v end})

TMisc:Sec("Vision")
TMisc:Tog("fov_lock", {Title = "FOV Lock", Default = CFG.fov_lock, Callback = function(v) CFG.fov_lock = v end})
TMisc:Sl("fov_value", {Title = "FOV Value", Min = 60, Max = 140, Default = CFG.fov_value, Callback = function(v) CFG.fov_value = v end})
TMisc:Tog("ambient", {Title = "Bright Ambient", Default = CFG.ambient, Callback = function(v) CFG.ambient = v end})
TMisc:Tog("boost_fps", {Title = "Boost FPS", Default = CFG.boost_fps, Callback = function(v)
    CFG.boost_fps = v
    pcall(function() if v then setfpscap(240) else setfpscap(0) end end)
end})

TMisc:Sec("Alerts")
TMisc:Tog("alert", {Title = "Proximity Alert", Default = CFG.alert, Callback = function(v) CFG.alert = v end})

TMisc:Sec("UI")
TMisc:Btn({Title = "Hide UI (Float Mode)", Callback = function()
    if _G.KZ_ToggleUI then _G.KZ_ToggleUI() end
end})

W:Show("Info")

-- ============================================================
-- FLOAT BUTTON KZ
-- ============================================================
pcall(function()
    local FG = Instance.new("ScreenGui")
    FG.Name = "KZ_Float_"..tostring(os.time())
    FG.ResetOnSpawn = false
    FG.IgnoreGuiInset = true
    FG.DisplayOrder = 2147483647
    pcall(function() FG.Parent = getParentTarget() end)
    if not FG.Parent then FG.Parent = PG end

    local FB = Instance.new("TextButton", FG)
    FB.Size = UDim2.fromOffset(70, 70)
    FB.Position = UDim2.new(0, 20, 0.5, -35)
    FB.BackgroundTransparency = 1
    FB.Text = "KZ"
    FB.TextColor3 = Color3.fromRGB(240, 240, 250)
    FB.TextStrokeTransparency = 0.15
    FB.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    FB.Font = Enum.Font.GothamBlack
    FB.TextSize = 32
    FB.AutoButtonColor = false
    FB.Active = true
    FB.Visible = false
    FB.ZIndex = 2147483647

    local bgCircle = Instance.new("Frame", FB)
    bgCircle.Size = UDim2.fromOffset(54, 54)
    bgCircle.Position = UDim2.new(0.5, -27, 0.5, -27)
    bgCircle.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    bgCircle.BackgroundTransparency = 0.25
    bgCircle.BorderSizePixel = 0
    bgCircle.ZIndex = -1
    cR(bgCircle, 27)
    local bgStroke = Instance.new("UIStroke", bgCircle)
    bgStroke.Color = COL.acc
    bgStroke.Thickness = 2
    bgStroke.Transparency = 0.35

    _G.KZ_FloatButton = FB

    local fD, fStart, fPos, fMoved = false, nil, nil, false
    FB.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            fD = true; fMoved = false; fStart = i.Position; fPos = FB.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if fD and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - fStart
            if d.Magnitude > 8 then
                fMoved = true
                FB.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + d.X, fPos.Y.Scale, fPos.Y.Offset + d.Y)
            end
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if fD and not fMoved then
                if _G.KZ_ToggleUI then _G.KZ_ToggleUI() end
            end
            fD = false
            task.delay(0.1, function() fMoved = false end)
        end
    end)

    _G.KZ_ShowFloat = function(state) FB.Visible = state end
end)

-- ============================================================
-- TOGGLE UI
-- ============================================================
_G.KZ_ToggleUI = function()
    if Main.Visible then
        Main.Visible = false
        if _G.KZ_ShowFloat then _G.KZ_ShowFloat(true) end
    else
        Main.Visible = true
        if _G.KZ_ShowFloat then _G.KZ_ShowFloat(false) end
    end
end

MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    if _G.KZ_ShowFloat then _G.KZ_ShowFloat(true) end
end)
ClsBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    if _G.KZ_ShowFloat then _G.KZ_ShowFloat(true) end
end)

-- UI watchdog
task.spawn(function()
    while true do
        task.wait(2)
        if not GUI.Parent then
            pcall(function() GUI.Parent = getParentTarget() end)
            if not GUI.Parent then GUI.Parent = PG end
        end
        if not GUI.Enabled then GUI.Enabled = true end
        if Main and not Main.Parent then Main.Parent = GUI end
    end
end)

-- ============================================================
-- KEYBINDS
-- ============================================================
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.V then CFG.tof_on = not CFG.tof_on end
    if i.KeyCode == Enum.KeyCode.B then CFG.veil_on = not CFG.veil_on end
    if i.KeyCode == Enum.KeyCode.P then
        if _G.KZ_ManualParry then _G.KZ_ManualParry() end
    end
    if i.KeyCode == Enum.KeyCode.RightShift then
        if _G.KZ_ToggleUI then _G.KZ_ToggleUI() end
    end
end)

print("==========================================")
print("[KALZZ HUB v22] FINAL")
print("Auto Gen: FUNCTION-ONLY (no VD_AutoGenerator UI)")
print("Hook    : 1x unified (AntiKick + ToF + Veil)")
print("Keybind : V=ToF | B=Veil | P=Parry | RShift=UI")
print("==========================================")
