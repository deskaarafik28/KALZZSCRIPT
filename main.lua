--[[
    KALZZSCRIPT
    main.lua - core + loader
]]

local BASE_URL = "https://raw.githubusercontent.com/deskaarafik28/KALZZSCRIPT/refs/heads/main/modules/"
local AUTOLOAD = true

local S = {
    Players   = game:GetService("Players"),
    RS        = game:GetService("ReplicatedStorage"),
    RSvc      = game:GetService("RunService"),
    UIS       = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    Lighting  = game:GetService("Lighting"),
    TS        = game:GetService("TweenService"),
    CoreGui   = game:GetService("CoreGui"),
}
S.LP = S.Players.LocalPlayer
S.PG = S.LP:WaitForChild("PlayerGui")
S.Cam = S.Workspace.CurrentCamera
S.INVITE = "discord.gg/dCYTep9cY"
S.IMG = "rbxassetid://134442738689157"
S.BASE_URL = BASE_URL

S.CFG = _G.KALZZ_CFG or {
    tof_on=true, tof_fov=500, tof_predict=2.8, tof_maxdist=2000, tof_show_fov=true,
    veil_on=true, veil_fov=320, veil_predict=2.8, veil_maxdist=2000, veil_show_fov=true,
    parry_on=true, parry_radius=6000, parry_aggro=true, parry_show_circle=false,
    fast_vault=true,
    esp_k=true, esp_s=true, esp_g=true, esp_gen_txt=true, esp_item=true, esp_out=false,
    fov_lock=false, fov_value=120,
    ambient=true, boost_fps=true, alert=true, stun_on=true,
    gene_on=false, gene_method="SUCCESS",
}
_G.KALZZ_CFG = S.CFG

_G.KZ_ToFAimDir = nil
_G.KZ_ToFStamp = 0
_G.KZ_ToFTarget = nil
_G.KZ_VeilState = _G.KZ_VeilState or { lookVector=nil, stamp=0, target=nil }

S.RC = { tof=nil, veil=nil, parry=nil, fastvault=nil }
pcall(function() S.RC.tof = S.RS.Remotes.Items["Twist of Fate"].Fire end)
pcall(function() S.RC.parry = S.RS.Remotes.Items["Parrying Dagger"].parry end)
pcall(function()
    local k = S.RS.Remotes:FindFirstChild("Killers")
    if k then local v=k:FindFirstChild("Veil"); if v then S.RC.veil=v:FindFirstChild("Spearthrow") end end
end)
pcall(function()
    local w = S.RS.Remotes:FindFirstChild("Window")
    if w then S.RC.fastvault = w:FindFirstChild("SurvivorFastVault") or w:FindFirstChild("fastvault") end
end)
task.delay(3, function()
    for _,o in ipairs(S.RS:GetDescendants()) do
        if o:IsA("RemoteEvent") then
            local nl = o.Name:lower()
            if not S.RC.tof and nl == "fire" then
                local f=""; pcall(function() f=o:GetFullName():lower() end)
                if f:find("twist") or f:find("fate") then S.RC.tof = o end
            end
            if not S.RC.veil and nl == "spearthrow" then S.RC.veil = o end
            if not S.RC.parry and nl:find("parry") then S.RC.parry = o end
        end
    end
end)

S.rtp = function(m)
    if not m then return nil end
    return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m.PrimaryPart
end

S.isKiller = function(c)
    local p
    if typeof(c)=="Instance" then
        if c:IsA("Player") then p=c else p=S.Players:GetPlayerFromCharacter(c) end
    end
    if not p then return false end
    local r = (p.Character and p.Character:GetAttribute("Role")) or p:GetAttribute("Role")
    if type(r)=="string" then
        local rl=r:lower()
        if rl:find("killer",1,true) then return true end
        if rl:find("survivor",1,true) then return false end
    end
    if p.Team and p.Team.Name then
        local t=p.Team.Name:lower()
        if t:find("killer",1,true) then return true end
        if t:find("survivor",1,true) then return false end
    end
    return false
end

S.isLocalKiller = function()
    local ch = S.LP.Character; if not ch then return false end
    local r = ch:GetAttribute("Role") or S.LP:GetAttribute("Role")
    if type(r)=="string" and r:lower():find("killer",1,true) then return true end
    if S.LP.Team and S.LP.Team.Name and S.LP.Team.Name:lower():find("killer",1,true) then return true end
    return false
end

S.Hooks = { list = {}, installed = false }
function S.Hooks:Add(name, prio, fn)
    table.insert(self.list, { name=name, prio=prio or 50, fn=fn })
    table.sort(self.list, function(a,b) return a.prio < b.prio end)
    print("[KZ] handler:", name, "prio:", prio)
end
function S.Hooks:Install()
    if self.installed then return end
    if typeof(hookmetamethod)~="function"
        or typeof(newcclosure)~="function"
        or typeof(getnamecallmethod)~="function"
    then warn("[KZ] executor no hook support") return end
    self.installed = true
    local OLD
    OLD = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local m; pcall(function() m = getnamecallmethod() end)
        local args = table.pack(...); local n = args.n
        for _, h in ipairs(S.Hooks.list) do
            local ok, res = pcall(h.fn, self, m, args, n)
            if ok then
                if res == true then return nil end
                if type(res)=="table" and res.n then
                    return OLD(self, table.unpack(res, 1, res.n))
                end
            end
        end
        return OLD(self, table.unpack(args, 1, n))
    end))
end
S.Hooks:Install()

S.Hooks:Add("KickBypass", 10, function(self, method, args, n)
    if method == "Kick" and self == S.LP then return true end
    return false
end)

S.Hooks:Add("Veil", 20, function(self, method, args, n)
    if method ~= "FireServer" then return false end
    if not S.CFG.veil_on then return false end
    local sn = ""; pcall(function() sn = tostring(self.Name or "") end)
    if sn ~= "Spearthrow" then return false end
    local dir = _G.KZ_VeilState.lookVector
    if typeof(dir) ~= "Vector3" then return false end
    if typeof(args[1]) == "Vector3" then
        args[1] = dir; return args
    end
    return false
end)

S.Hooks:Add("ToF", 30, function(self, method, args, n)
    if method ~= "FireServer" then return false end
    if not S.CFG.tof_on then return false end
    local dir = _G.KZ_ToFAimDir
    if typeof(dir) ~= "Vector3" then return false end
    local match = (S.RC.tof and self == S.RC.tof)
    if not match then
        local sn, fn = "", ""
        pcall(function() sn = tostring(self.Name or "") end)
        pcall(function() fn = self:GetFullName():lower() end)
        if sn == "Fire" or sn == "Shoot" then
            if fn:find("twist") or fn:find("fate") or fn:find("tof") then match = true end
        end
    end
    if not match then return false end
    for i = 1, n do
        local v = args[i]
        if typeof(v) == "Vector3" and v.Magnitude <= 5 then
            args[i] = dir; break
        end
    end
    return args
end)

local function getMuzzle()
    local ch = S.LP.Character
    if not ch then return S.Cam and S.Cam.CFrame.Position or Vector3.zero end
    local tool = ch:FindFirstChildOfClass("Tool")
    if tool then
        local h = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
        if h then return h.Position + h.CFrame.LookVector * 2 end
    end
    local r = S.rtp(ch)
    return r and (r.Position + Vector3.new(0, 1.5, 0)) or (S.Cam and S.Cam.CFrame.Position or Vector3.zero)
end

local function pickTarget(wantK, fovR, maxD)
    local Cam = S.Workspace.CurrentCamera
    if not Cam then return nil end
    local ctr = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    local myRoot = S.rtp(S.LP.Character)
    local myPos = myRoot and myRoot.Position or Cam.CFrame.Position
    local best, bestScore = nil, math.huge
    for _, p in ipairs(S.Players:GetPlayers()) do
        if p ~= S.LP and p.Character then
            local k = S.isKiller(p)
            if (wantK and k) or (not wantK and not k) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local root = S.rtp(p.Character)
                if hum and hum.Health > 0 and root then
                    local wd = (root.Position - myPos).Magnitude
                    if wd <= (maxD or 2000) then
                        local sc = math.huge
                        if wd <= 20 then sc = wd * 0.5
                        else
                            local sp, on = Cam:WorldToViewportPoint(root.Position)
                            if on and sp.Z > 0 then
                                local sd = (Vector2.new(sp.X, sp.Y) - ctr).Magnitude
                                if sd <= (fovR or 500) then sc = sd + wd * 0.1 end
                            end
                        end
                        if sc < bestScore then bestScore = sc; best = root end
                    end
                end
            end
        end
    end
    return best
end

S.RSvc.Heartbeat:Connect(function()
    S.Cam = S.Workspace.CurrentCamera
    local now = os.clock()
    local localK = S.isLocalKiller()

    if S.CFG.tof_on and not localK then
        local t = pickTarget(true, S.CFG.tof_fov, S.CFG.tof_maxdist)
        if t and t.Parent then
            local o = getMuzzle()
            local vel = t.AssemblyLinearVelocity or Vector3.zero
            vel = Vector3.new(vel.X, 0, vel.Z)
            local dist = (t.Position - o).Magnitude
            local pm = S.CFG.tof_predict or 2.8
            if dist < 30 then pm = pm * 0.3 end
            local pred = t.Position + vel * math.clamp(dist/260, 0.04, 0.7) * pm + Vector3.new(0, 0.9, 0)
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

    if S.CFG.veil_on and localK then
        local t = pickTarget(false, S.CFG.veil_fov, S.CFG.veil_maxdist)
        local my = S.rtp(S.LP.Character)
        if t and t.Parent and my then
            local o = my.Position
            local hand = S.LP.Character and (S.LP.Character:FindFirstChild("RightHand") or S.LP.Character:FindFirstChild("Right Arm"))
            if hand and hand:IsA("BasePart") then o = hand.Position end
            local vel = t.AssemblyLinearVelocity or Vector3.zero
            vel = Vector3.new(vel.X, 0, vel.Z)
            local dist = (t.Position - o).Magnitude
            local pm = S.CFG.veil_predict or 2.8
            if dist < 30 then pm = pm * 0.3 end
            local pred = t.Position + vel * math.clamp(dist/200, 0.05, 0.6) * pm
            if dist > 40 then
                pred = pred + Vector3.new(0, math.clamp(dist * 0.05, 2, 14), 0)
            end
            local dir = pred - o
            if dir.Magnitude > 0.2 then
                _G.KZ_VeilState.lookVector = dir.Unit
                _G.KZ_VeilState.stamp = now
                _G.KZ_VeilState.target = t
            end
        else _G.KZ_VeilState.target = nil end
    else _G.KZ_VeilState.target = nil end
    if _G.KZ_VeilState.lookVector and (now - _G.KZ_VeilState.stamp) > 0.5 then
        _G.KZ_VeilState.lookVector = nil; _G.KZ_VeilState.target = nil
    end
end)

local FOVC = {}
pcall(function()
    if typeof(Drawing) ~= "table" or not Drawing.new then return end
    FOVC.tofO = Drawing.new("Circle"); FOVC.tofO.Thickness=3; FOVC.tofO.NumSides=90; FOVC.tofO.Filled=false; FOVC.tofO.Color=Color3.new(0,0,0); FOVC.tofO.Transparency=0.5; FOVC.tofO.Visible=false
    FOVC.tof  = Drawing.new("Circle"); FOVC.tof.Thickness=1.8; FOVC.tof.NumSides=90; FOVC.tof.Filled=false; FOVC.tof.Color=Color3.fromRGB(255,255,255); FOVC.tof.Transparency=0.8; FOVC.tof.Visible=false
    FOVC.veilO = Drawing.new("Circle"); FOVC.veilO.Thickness=3; FOVC.veilO.NumSides=90; FOVC.veilO.Filled=false; FOVC.veilO.Color=Color3.new(0,0,0); FOVC.veilO.Transparency=0.5; FOVC.veilO.Visible=false
    FOVC.veil  = Drawing.new("Circle"); FOVC.veil.Thickness=1.8; FOVC.veil.NumSides=90; FOVC.veil.Filled=false; FOVC.veil.Color=Color3.fromRGB(255,255,255); FOVC.veil.Transparency=0.8; FOVC.veil.Visible=false
end)
S.RSvc.RenderStepped:Connect(function()
    if not FOVC.tof then return end
    local cam = S.Workspace.CurrentCamera
    if not cam then
        FOVC.tof.Visible=false; FOVC.tofO.Visible=false; FOVC.veil.Visible=false; FOVC.veilO.Visible=false
        return
    end
    local ctr = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local localK = S.isLocalKiller()
    if S.CFG.tof_show_fov and S.CFG.tof_on and not localK then
        local r = S.CFG.tof_fov or 500
        local col = _G.KZ_ToFTarget and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,210)
        FOVC.tofO.Position=ctr; FOVC.tofO.Radius=r+2; FOVC.tofO.Visible=true
        FOVC.tof.Position=ctr; FOVC.tof.Radius=r; FOVC.tof.Color=col; FOVC.tof.Visible=true
    else FOVC.tof.Visible=false; FOVC.tofO.Visible=false end
    if S.CFG.veil_show_fov and S.CFG.veil_on and localK then
        local r = S.CFG.veil_fov or 320
        local col = _G.KZ_VeilState.target and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,210)
        FOVC.veilO.Position=ctr; FOVC.veilO.Radius=r+2; FOVC.veilO.Visible=true
        FOVC.veil.Position=ctr; FOVC.veil.Radius=r; FOVC.veil.Color=col; FOVC.veil.Visible=true
    else FOVC.veil.Visible=false; FOVC.veilO.Visible=false end
end)

do
    local base = Instance.new("Part")
    base.Name = "KZ_ParryCircle"; base.Size = Vector3.new(1, 0.05, 1)
    base.Anchored = true; base.CanCollide = false; base.CanQuery = false
    base.CanTouch = false; base.CastShadow = false
    base.Material = Enum.Material.SmoothPlastic; base.Transparency = 1
    base.Parent = S.Workspace
    local sg = Instance.new("SurfaceGui", base)
    sg.Face = Enum.NormalId.Top; sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    sg.PixelsPerStud = 40; sg.LightInfluence = 0; sg.ZOffset = 1
    local ring = Instance.new("Frame", sg)
    ring.AnchorPoint = Vector2.new(0.5,0.5); ring.Position = UDim2.fromScale(0.5,0.5); ring.Size = UDim2.fromScale(0.96,0.96)
    ring.BackgroundTransparency = 1; ring.BorderSizePixel = 0
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1,0)
    local s1 = Instance.new("UIStroke", ring); s1.Thickness = 4; s1.Color = Color3.fromRGB(255,255,255); s1.Transparency = 1
    s1.LineJoinMode = Enum.LineJoinMode.Round
    local ring2 = Instance.new("Frame", sg)
    ring2.AnchorPoint = Vector2.new(0.5,0.5); ring2.Position = UDim2.fromScale(0.5,0.5); ring2.Size = UDim2.fromScale(0.88,0.88)
    ring2.BackgroundTransparency = 1; ring2.BorderSizePixel = 0
    Instance.new("UICorner", ring2).CornerRadius = UDim.new(1,0)
    local s2 = Instance.new("UIStroke", ring2); s2.Thickness = 1.5; s2.Color = Color3.fromRGB(255,255,255); s2.Transparency = 1
    s2.LineJoinMode = Enum.LineJoinMode.Round
    local fill = Instance.new("Frame", sg)
    fill.AnchorPoint = Vector2.new(0.5,0.5); fill.Position = UDim2.fromScale(0.5,0.5); fill.Size = UDim2.fromScale(0.94,0.94)
    fill.BackgroundColor3 = Color3.fromRGB(255,255,255); fill.BackgroundTransparency = 1; fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local fIn = 0; local prev = os.clock(); local pulse = 0
    S.RSvc.Heartbeat:Connect(function()
        local now = os.clock(); local dt = now - prev; prev = now
        pulse = pulse + dt
        local hrp = S.LP.Character and (S.LP.Character:FindFirstChild("HumanoidRootPart") or S.LP.Character.PrimaryPart)
        local act = S.CFG.parry_on and S.CFG.parry_show_circle and hrp
        if act then fIn = math.min(1, fIn + dt*5) else fIn = math.max(0, fIn - dt*5) end
        if fIn <= 0.001 then base.Transparency = 1 return end
        if act then
            local hasE = false
            for _, pl in ipairs(S.Players:GetPlayers()) do
                if pl ~= S.LP and pl.Character and S.isKiller(pl) then
                    local er = pl.Character:FindFirstChild("HumanoidRootPart")
                    if er then
                        local hu = pl.Character:FindFirstChildOfClass("Humanoid")
                        if hu and hu.Health > 0 and (er.Position - hrp.Position).Magnitude <= 20 then hasE = true; break end
                    end
                end
            end
            local r = 20 * 2
            base.Size = Vector3.new(r, 0.05, r)
            base.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2.95, 0))
            local p = math.sin(pulse * (hasE and 7 or 4)) * (hasE and 0.14 or 0.06)
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

pcall(function()
    local VALID = {
        ["122812055447896"]=1,["133963973694098"]=1,["117042998468241"]=1,
        ["135002183282873"]=1,["121216847022485"]=1,["132817836308238"]=1,
        ["129784271201071"]=1,["82666958311998"]=1,["78432063483146"]=1,
        ["118907603246885"]=1,["139369275981139"]=1,["110355011987939"]=1,
        ["111920872708571"]=1,["105374834496520"]=1,["138720291317243"]=1,
        ["106871536134254"]=1,["130593238885843"]=1,["115244153053858"]=1,
        ["74968262036854"]=1,["113255068724446"]=1,["98163597193511"]=1,
        ["80411309607666"]=1,["101344487600812"]=1,
    }
    local function root(m) return m and (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart) end
    local function isKillerModel(m)
        local plr = S.Players:GetPlayerFromCharacter(m)
        if plr then
            if plr == S.LP then return false end
            if plr.Team and plr.Team.Name == "Killer" then return true end
            local r = m:GetAttribute("Role") or plr:GetAttribute("Role")
            if type(r)=="string" and r:lower():find("killer") then return true end
            if plr.Team and plr.Team.Name and plr.Team.Name:lower():find("killer") then return true end
            return false
        end
        local r = m:GetAttribute("Role")
        return type(r)=="string" and r:lower():find("killer")~=nil
    end
    local function busy()
        local ch = S.LP.Character
        if not ch then return true end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return true end
        for _, a in ipairs({"Knocked","Downed","Hooked","Carried"}) do
            local v = ch:GetAttribute(a)
            if v==true or v==1 then return true end
        end
        return false
    end
    local PR = S.RC.parry
    local lastFire = 0
    local function doP()
        if not S.CFG.parry_on then return end
        if busy() then return end
        local n = os.clock()
        if n - lastFire < 0.015 then return end
        lastFire = n
        if PR then
            pcall(function() PR:FireServer() end)
            pcall(function() PR:FireServer(2) end)
        end
        pcall(function()
            local sv = S.PG:FindFirstChild("Survivor-mob")
            if not sv then return end
            local c = sv:FindFirstChild("Controls")
            if not c then return end
            local b = c:FindFirstChild("Gui-mob") or c:FindFirstChildWhichIsA("ImageButton")
            if b and typeof(firesignal)=="function" then
                firesignal(b.MouseButton1Down); firesignal(b.MouseButton1Up)
            end
        end)
    end
    _G.KZ_ManualParry = doP

    local function distTo(m)
        local a = root(S.LP.Character); local b = root(m)
        if not a or not b then return 99999 end
        return (a.Position-b.Position).Magnitude
    end

    local Attached = {}
    local function bindParry(m)
        if not m or Attached[m] then return end
        if not isKillerModel(m) then return end
        if not m:FindFirstChildOfClass("Humanoid") then return end
        Attached[m] = true
        local h = m:FindFirstChildOfClass("Humanoid")
        local an = h:FindFirstChildOfClass("Animator")
        if not an then
            for _=1,30 do
                task.wait(0.1); an = h:FindFirstChildOfClass("Animator")
                if an or not m.Parent then break end
            end
        end
        if not an then return end
        an.AnimationPlayed:Connect(function(t)
            if not S.CFG.parry_on or not t or not t.Animation then return end
            local id = tostring(t.Animation.AnimationId or ""):match("%d+") or ""
            if not VALID[id] then return end
            doP()
            local conn
            conn = S.RSvc.Heartbeat:Connect(function()
                if not S.CFG.parry_on or not t.IsPlaying then
                    if conn then conn:Disconnect() end
                    return
                end
                local d = distTo(m)
                if d > 0 and d <= (S.CFG.parry_radius or 6000) then doP() end
            end)
            t.Stopped:Connect(function() if conn then conn:Disconnect() end end)
            task.delay(3, function() if conn then pcall(function() conn:Disconnect() end) end end)
        end)
    end
    local function scanAll()
        for _, o in ipairs(S.Workspace:GetDescendants()) do
            if o:IsA("Model") and o:FindFirstChildOfClass("Humanoid") then pcall(bindParry, o) end
        end
    end
    scanAll()
    local bound = {}
    local function bindPlayer(p)
        if bound[p] then return end
        bound[p] = true
        p.CharacterAdded:Connect(function(c)
            Attached[c] = nil; task.wait(0.3)
            if isKillerModel(c) then bindParry(c) end
        end)
    end
    for _, p in ipairs(S.Players:GetPlayers()) do if p ~= S.LP then bindPlayer(p) end end
    S.Players.PlayerAdded:Connect(function(p)
        bindPlayer(p); task.wait(1)
        if p.Character then bindParry(p.Character) end
    end)
    task.spawn(function()
        while S.LP.Parent do task.wait(0.4); scanAll() end
    end)
    S.UIS.InputBegan:Connect(function(i,g)
        if g then return end
        if i.KeyCode == Enum.KeyCode.P then doP() end
    end)
end)

pcall(function()
    local last = 0
    local function trig()
        if os.clock() - last < 0.3 then return end
        last = os.clock()
        if S.RC.fastvault then pcall(function() S.RC.fastvault:FireServer() end) end
    end
    local function apply(ch)
        local hum = ch:FindFirstChildOfClass("Humanoid")
        local anim = hum and hum:FindFirstChildOfClass("Animator")
        if not anim then return end
        anim.AnimationPlayed:Connect(function(track)
            if not S.CFG.fast_vault then return end
            if not track or not track.Animation then return end
            local n = (track.Animation.Name or ""):lower()
            if n:find("vault") or n:find("window") or n:find("climb") or n:find("pallet") then trig() end
        end)
    end
    S.LP.CharacterAdded:Connect(function(c) task.wait(1.2) apply(c) end)
    if S.LP.Character then task.spawn(function() apply(S.LP.Character) end) end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if S.CFG.ambient then
            pcall(function()
                S.Lighting.Ambient = Color3.fromRGB(180,180,180)
                S.Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
                S.Lighting.Brightness = 3
                S.Lighting.GlobalShadows = false
                S.Lighting.ClockTime = 14
                S.Lighting.FogEnd = 100000
            end)
        end
        if S.CFG.boost_fps then pcall(function() if setfpscap then setfpscap(240) end end) end
    end
end)
task.spawn(function()
    while true do
        task.wait(0.5)
        if S.CFG.fov_lock then
            local c = S.Workspace.CurrentCamera
            if c and math.abs(c.FieldOfView - (S.CFG.fov_value or 120)) > 0.5 then
                pcall(function() c.FieldOfView = S.CFG.fov_value or 120 end)
            end
        end
    end
end)

pcall(function()
    local stunHead, stunSpin = {}, 0
    local stunGui, stunCard, stunOn = nil, nil, false
    local function isStunned(ch)
        if not ch then return false end
        local h = ch:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then return false end
        if ch:GetAttribute("Stunned")==true or ch:GetAttribute("Stunned")==1 then return true end
        if ch:GetAttribute("IsStunned")==true or ch:GetAttribute("stun")==true then return true end
        local ok, s = pcall(function() return h:GetState() end)
        if ok and s then
            if s==Enum.HumanoidStateType.FallingDown or s==Enum.HumanoidStateType.Ragdoll then return true end
        end
        return false
    end
    local function makeH(root, cam)
        local bb = Instance.new("BillboardGui")
        bb.Name = "KZ_StunHead"; bb.Size = UDim2.fromOffset(30,30)
        bb.StudsOffset = Vector3.new(0,3.4,0); bb.AlwaysOnTop = true
        bb.Adornee = root; bb.Parent = cam
        local ring = Instance.new("Frame", bb)
        ring.Size = UDim2.fromScale(1,1); ring.BackgroundTransparency = 1
        Instance.new("UICorner", ring).CornerRadius = UDim.new(1,0)
        local st = Instance.new("UIStroke", ring)
        st.Color = Color3.fromRGB(200,200,210); st.Thickness = 2.5; st.Transparency = 0.25
        local g = Instance.new("UIGradient", st); g.Name = "G"
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(0.35,0.2),
            NumberSequenceKeypoint.new(0.7,1), NumberSequenceKeypoint.new(1,1),
        })
        return bb
    end
    local function killH(p) if stunHead[p] then pcall(function() stunHead[p]:Destroy() end) end stunHead[p]=nil end
    local function wipe()
        for _,g in ipairs(S.PG:GetChildren()) do
            if g.Name == "KZ_StunToast" then pcall(function() g:Destroy() end) end
        end
        stunGui, stunCard, stunOn = nil, nil, false
    end
    local function show()
        if stunOn and stunGui and stunGui.Parent then return end
        wipe()
        stunGui = Instance.new("ScreenGui"); stunGui.Name = "KZ_StunToast"
        stunGui.ResetOnSpawn = false; stunGui.IgnoreGuiInset = true
        stunGui.DisplayOrder = 1000005; stunGui.Parent = S.PG
        stunCard = Instance.new("Frame", stunGui)
        stunCard.AnchorPoint = Vector2.new(1,1)
        stunCard.Position = UDim2.new(1,24,1,-18)
        stunCard.Size = UDim2.fromOffset(132,34)
        stunCard.BackgroundColor3 = Color3.fromRGB(35,35,40)
        stunCard.BackgroundTransparency = 0.4; stunCard.BorderSizePixel = 0
        Instance.new("UICorner", stunCard).CornerRadius = UDim.new(0,9)
        local s = Instance.new("UIStroke", stunCard)
        s.Color = Color3.fromRGB(170,170,180); s.Thickness = 1; s.Transparency = 0.45
        local t = Instance.new("TextLabel", stunCard)
        t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1
        t.Text = "STUN KILLER"; t.TextColor3 = Color3.fromRGB(220,220,230)
        t.Font = Enum.Font.GothamBold; t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Center
        stunOn = true
        S.TS:Create(stunCard, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(1,-12,1,-18)
        }):Play()
    end
    S.RSvc.RenderStepped:Connect(function(dt)
        stunSpin = stunSpin + dt * 280
        if not S.CFG.stun_on then
            for _,p in ipairs(S.Players:GetPlayers()) do killH(p) end
            if stunOn or stunGui then wipe() end
            return
        end
        local cam = S.Workspace.CurrentCamera
        if not cam then return end
        local any = false
        for _,p in ipairs(S.Players:GetPlayers()) do
            if not S.isKiller(p) then killH(p); continue end
            local ch = p.Character
            local root = ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart)
            if root and isStunned(ch) then
                any = true
                if not stunHead[p] or not stunHead[p].Parent then stunHead[p] = makeH(root, cam) end
                local bb = stunHead[p]
                if bb.Parent ~= cam then bb.Parent = cam end
                bb.Adornee = root
                local g = bb:FindFirstChild("G", true)
                if g then g.Rotation = stunSpin % 360 end
            else killH(p) end
        end
        if any then show() else if stunOn or stunGui then wipe() end end
    end)
    S.Players.PlayerRemoving:Connect(function(p) killH(p) end)
end)

pcall(function()
    local ag = Instance.new("ScreenGui")
    ag.Name = "KZ_Alert"; ag.ResetOnSpawn = false; ag.IgnoreGuiInset = true
    ag.DisplayOrder = 1000001; ag.Parent = S.PG
    local al = Instance.new("TextLabel", ag)
    al.Size = UDim2.fromOffset(300,60); al.Position = UDim2.new(0.5,-150,0.14,0)
    al.BackgroundTransparency = 1; al.TextColor3 = Color3.fromRGB(255,255,255)
    al.Font = Enum.Font.GothamBlack; al.TextSize = 32
    al.TextStrokeTransparency = 0; al.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    al.Visible = false
    task.spawn(function()
        while true do
            task.wait(0.2)
            if not S.CFG.alert then al.Visible = false
            else
                local mr = S.rtp(S.LP.Character)
                if mr then
                    local cl = math.huge
                    for _,pl in ipairs(S.Players:GetPlayers()) do
                        if pl ~= S.LP and pl.Character and S.isKiller(pl) then
                            local hrp = S.rtp(pl.Character)
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

_G.KZ = S

local function loadModule(name)
    if not AUTOLOAD then return end
    local url = BASE_URL .. name .. ".lua"
    local ok, src = pcall(game.HttpGet, game, url)
    if not ok or not src or src == "" then
        warn("[KZ] gagal load module: " .. name)
        return
    end
    local fn, err = loadstring(src)
    if not fn then warn("[KZ] syntax error di " .. name .. ": " .. tostring(err)) return end
    local ok2, err2 = pcall(fn)
    if not ok2 then warn("[KZ] runtime error di " .. name .. ": " .. tostring(err2)) end
end

if AUTOLOAD then
    task.spawn(function()
        task.wait(0.5)
        loadModule("esp")
        loadModule("ui")
    end)
end

print("[KZ] main.lua loaded")
