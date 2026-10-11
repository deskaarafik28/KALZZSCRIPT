--[[ KALZZ HUB V9 FINAL | Scale 1.00 | UI + Full Features ]]

-- ============================================================
-- SERVICES
-- ============================================================
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RSvc = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local Cam = Workspace.CurrentCamera
local INVITE = "discord.gg/dCYTep9cY"

-- ============================================================
-- CONFIG
-- ============================================================
local CONFIG_FILE = "kalzz_v9.json"
local CFG = {
    tof_on = true, tof_fov = 500, tof_predict = 2.8, tof_maxdist = 2000, tof_show_fov = true,
    veil_on = true, veil_fov = 320, veil_predict = 3, veil_maxdist = 400, veil_show_fov = true,
    veil_show_tracker = true, veil_auto_predict = true,
    parry_on = true, parry_radius = 14, parry_sensitive = 200, parry_aggro = true, parry_show_circle = true,
    fast_vault = true,
    esp_k = true, esp_s = true, esp_item = true,
    esp_g = true, esp_gen_txt = true, esp_out = false,
    fov_lock = false, fov_value = 120,
    ambient = true, boost_fps = true, alert = true, stun_on = true,
    gene_on = false, gene_method = "PERFECT",
}
local function loadCfg()
    if not (readfile and isfile) then return end
    pcall(function()
        if isfile(CONFIG_FILE) then
            local d = HttpService:JSONDecode(readfile(CONFIG_FILE))
            for k, v in pairs(d) do if CFG[k] ~= nil then CFG[k] = v end end
        end
    end)
end
loadCfg()
local function saveCfg()
    if not writefile then return end
    pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(CFG)) end)
end

-- ============================================================
-- THEME
-- ============================================================
local T = {
    Bg        = Color3.fromRGB(11, 11, 14),
    BgAlt     = Color3.fromRGB(16, 16, 20),
    Sidebar   = Color3.fromRGB(14, 14, 18),
    Panel     = Color3.fromRGB(20, 20, 25),
    Element   = Color3.fromRGB(26, 26, 32),
    ElemHover = Color3.fromRGB(36, 36, 44),
    ElemPress = Color3.fromRGB(44, 44, 54),
    Border    = Color3.fromRGB(38, 38, 48),
    BorderHi  = Color3.fromRGB(58, 58, 72),
    Text      = Color3.fromRGB(242, 242, 248),
    TextSec   = Color3.fromRGB(158, 158, 172),
    TextDim   = Color3.fromRGB(100, 100, 115),
    Accent    = Color3.fromRGB(150, 105, 255),
    AccentAlt = Color3.fromRGB(95, 155, 255),
    AccentGlow= Color3.fromRGB(180, 140, 255),
    Success   = Color3.fromRGB(80, 215, 135),
    Warn      = Color3.fromRGB(255, 180, 70),
    Danger    = Color3.fromRGB(240, 90, 100),
    Off       = Color3.fromRGB(52, 52, 64),
    Overlay   = Color3.fromRGB(0, 0, 0),
}
local F = {
    Reg = Enum.Font.Gotham, Med = Enum.Font.GothamMedium,
    Bold = Enum.Font.GothamBold, Semi = Enum.Font.GothamSemibold,
}
local E_QUICK  = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local E_SMOOTH = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local E_ENTER  = TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local E_EXIT   = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
local E_GLIDE  = TweenInfo.new(0.42, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local E_BOUNCE = TweenInfo.new(0.45, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)

local function Corner(p, r)
    local c = Instance.new("UICorner", p); c.CornerRadius = UDim.new(0, r or 6); return c
end
local function Stroke(p, col, th, tr)
    local s = Instance.new("UIStroke", p)
    s.Color = col or T.Border; s.Thickness = th or 1; s.Transparency = tr or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end
local function Pad(p, t, b, l, r)
    local u = Instance.new("UIPadding", p)
    u.PaddingTop = UDim.new(0, t or 0); u.PaddingBottom = UDim.new(0, b or 0)
    u.PaddingLeft = UDim.new(0, l or 0); u.PaddingRight = UDim.new(0, r or 0)
    return u
end
local function New(class, props)
    local i = Instance.new(class)
    if props then for k, v in pairs(props) do i[k] = v end end
    return i
end
local function GetParentGui()
    if gethui then
        local ok, h = pcall(gethui); if ok and h then return h end
    end
    local ok, cg = pcall(function() return CoreGui end)
    if ok and cg then return cg end
    return PG
end
local function PulseColor(inst, prop, from, to, time)
    local t = 0
    local conn
    conn = RSvc.RenderStepped:Connect(function(dt)
        t = t + dt
        local a = math.clamp(t / time, 0, 1)
        local a2 = a < 0.5 and a * 2 or (1 - a) * 2
        inst[prop] = from:Lerp(to, a2)
        if a >= 1 then conn:Disconnect(); inst[prop] = from end
    end)
end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
local NotifHolder
local NotifOrder = 0
local function EnsureNotif()
    if NotifHolder and NotifHolder.Parent then return end
    local gui = New("ScreenGui", { Name = "KZ_Notif", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 2147483646, Parent = GetParentGui() })
    NotifHolder = New("Frame", { Parent = gui, BackgroundTransparency = 1, Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(1, -316, 0, 40) })
    New("UIListLayout", { Parent = NotifHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Top, HorizontalAlignment = Enum.HorizontalAlignment.Right })
end
local function Notify(title, content, duration, kind)
    EnsureNotif()
    NotifOrder = NotifOrder + 1
    duration = duration or 4
    kind = kind or "info"
    local accent = T.Accent
    if kind == "success" then accent = T.Success end
    if kind == "warn" then accent = T.Warn end
    if kind == "error" then accent = T.Danger end
    local card = New("Frame", { Parent = NotifHolder, BackgroundColor3 = T.Panel, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 66), Position = UDim2.new(1, 60, 0, 0), BackgroundTransparency = 0.02, LayoutOrder = -NotifOrder })
    Corner(card, 10); Stroke(card, T.BorderHi, 1, 0.35)
    local bar = New("Frame", { Parent = card, BackgroundColor3 = accent, BorderSizePixel = 0, Size = UDim2.new(0, 3, 1, -16), Position = UDim2.new(0, 8, 0, 8) })
    Corner(bar, 2)
    New("TextLabel", { Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, -34, 0, 20), Position = UDim2.new(0, 22, 0, 10), Font = F.Bold, Text = title or "Notification", TextColor3 = T.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    New("TextLabel", { Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, -34, 0, 28), Position = UDim2.new(0, 22, 0, 30), Font = F.Reg, Text = content or "", TextColor3 = T.TextSec, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true })
    local progBg = New("Frame", { Parent = card, BackgroundColor3 = T.Off, BorderSizePixel = 0, Size = UDim2.new(1, -32, 0, 2), Position = UDim2.new(0, 16, 1, -6), BackgroundTransparency = 0.4 })
    Corner(progBg, 1)
    local prog = New("Frame", { Parent = progBg, BackgroundColor3 = accent, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0) })
    Corner(prog, 1)
    TS:Create(card, E_ENTER, { Position = UDim2.new(0, 0, 0, 0) }):Play()
    TS:Create(prog, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) }):Play()
    task.delay(duration, function()
        if card and card.Parent then
            local tw = TS:Create(card, E_EXIT, { Position = UDim2.new(1, 60, 0, 0), BackgroundTransparency = 1 })
            tw:Play(); tw.Completed:Connect(function() card:Destroy() end)
        end
    end)
end

-- ============================================================
-- GAME HELPERS
-- ============================================================
local function rtp(m)
    if not m then return nil end
    return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m.PrimaryPart
end
local function isKiller(c)
    local p
    if typeof(c) == "Instance" then
        if c:IsA("Player") then p = c else p = Players:GetPlayerFromCharacter(c) end
    end
    if not p then return false end
    local r = (p.Character and p.Character:GetAttribute("Role")) or p:GetAttribute("Role")
    if type(r) == "string" then
        if r:lower():find("killer", 1, true) then return true end
        if r:lower():find("survivor", 1, true) then return false end
    end
    if p.Team and p.Team.Name then
        if p.Team.Name:lower():find("killer", 1, true) then return true end
        if p.Team.Name:lower():find("survivor", 1, true) then return false end
    end
    return false
end
local function isLocalKiller()
    local ch = LP.Character
    if not ch then return false end
    local r = ch:GetAttribute("Role") or LP:GetAttribute("Role")
    if type(r) == "string" and r:lower():find("killer", 1, true) then return true end
    if LP.Team and LP.Team.Name and LP.Team.Name:lower():find("killer", 1, true) then return true end
    return false
end

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

_G.KZ_ToFAimDir = nil
_G.KZ_ToFStamp = 0
_G.KZ_ToFTarget = nil
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
local function pickTarget(wantK, fovR, maxD)
    if not Cam then Cam = Workspace.CurrentCamera end
    if not Cam then return nil end
    local ctr = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    local myR = rtp(LP.Character)
    local myP = myR and myR.Position or Cam.CFrame.Position
    local best, bestS = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local k = isKiller(p)
            if (wantK and k) or (not wantK and not k) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local root = rtp(p.Character)
                if hum and hum.Health > 0 and root then
                    local wd = (root.Position - myP).Magnitude
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
                        if sc < bestS then bestS = sc; best = root end
                    end
                end
            end
        end
    end
    return best
end

RSvc.Heartbeat:Connect(function()
    Cam = Workspace.CurrentCamera
    local now = os.clock()
    if CFG.tof_on and not isLocalKiller() then
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
                _G.KZ_ToFAimDir = dir.Unit; _G.KZ_ToFStamp = now; _G.KZ_ToFTarget = t
            end
        else _G.KZ_ToFTarget = nil end
    else _G.KZ_ToFTarget = nil end
    if _G.KZ_ToFAimDir and (now - _G.KZ_ToFStamp) > 0.5 then
        _G.KZ_ToFAimDir = nil; _G.KZ_ToFTarget = nil
    end
end)

-- FOV CIRCLE
do
    local V = {}
    pcall(function()
        if typeof(Drawing) ~= "table" or not Drawing.new then return end
        V.o = Drawing.new("Circle"); V.o.Thickness=3; V.o.NumSides=90; V.o.Filled=false; V.o.Color=Color3.new(0,0,0); V.o.Transparency=0.5; V.o.Visible=false
        V.c = Drawing.new("Circle"); V.c.Thickness=1.8; V.c.NumSides=90; V.c.Filled=false; V.c.Color=Color3.fromRGB(255,255,255); V.c.Transparency=0.8; V.c.Visible=false
        V.d = Drawing.new("Circle"); V.d.Thickness=1; V.d.NumSides=16; V.d.Filled=true; V.d.Radius=4; V.d.Visible=false
        V.do2 = Drawing.new("Circle"); V.do2.Thickness=3; V.do2.NumSides=16; V.do2.Filled=false; V.do2.Color=Color3.new(0,0,0); V.do2.Radius=6; V.do2.Visible=false
    end)
    RSvc.RenderStepped:Connect(function()
        if not V.c then return end
        local cam = Workspace.CurrentCamera
        if not cam then
            V.c.Visible=false; V.o.Visible=false; V.d.Visible=false; V.do2.Visible=false
            return
        end
        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        if CFG.tof_show_fov and CFG.tof_on and not isLocalKiller() then
            local r = CFG.tof_fov or 500
            V.o.Position=center; V.o.Radius=r+2; V.o.Visible=true
            V.c.Position=center; V.c.Radius=r; V.c.Visible=true
        else V.c.Visible=false; V.o.Visible=false end
        if _G.KZ_ToFTarget and _G.KZ_ToFTarget.Parent then
            local sp, on = cam:WorldToViewportPoint(_G.KZ_ToFTarget.Position)
            if on and sp.Z > 0 then
                V.d.Position=Vector2.new(sp.X, sp.Y); V.d.Visible=true
                V.do2.Position=Vector2.new(sp.X, sp.Y); V.do2.Visible=true
            else V.d.Visible=false; V.do2.Visible=false end
        else V.d.Visible=false; V.do2.Visible=false end
    end)
end

-- UNIFIED HOOK
do
    if type(hookmetamethod) == "function" and type(newcclosure) == "function" and type(getnamecallmethod) == "function" then
        local OLD
        OLD = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local m
            pcall(function() m = getnamecallmethod() end)
            if m == "Kick" and self == LP then return nil end
            if m ~= "FireServer" then return OLD(self, ...) end
            local tofDir = _G.KZ_ToFAimDir
            local hasToF = CFG.tof_on and typeof(tofDir) == "Vector3"
            if not hasToF then return OLD(self, ...) end
            if type(self) ~= "userdata" and type(self) ~= "table" then return OLD(self, ...) end
            local args = table.pack(...)
            local n = args.n
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
                    if typeof(args[i]) == "Vector3" and args[i].Magnitude <= 5 then
                        args[i] = tofDir
                        break
                    end
                end
                return OLD(self, table.unpack(args, 1, n))
            end
            return OLD(self, table.unpack(args, 1, n))
        end))
    end
end

-- AUTO PARRY
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

-- FAST VAULT
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

-- ESP
pcall(function()
    local hl, genHL, tracked = {}, {}, {}
    local function upd(plr, cam)
        if plr == LP then return end
        local char = plr.Character
        local head = char and char:FindFirstChild("Head")
        if not char or not head then
            if hl[plr] then hl[plr].FillTransparency = 1; hl[plr].OutlineTransparency = 1; hl[plr].Adornee = nil end
            return
        end
        local team = plr.Team
        local isK = team and team.Name == "Killer"
        local isS = team and (team.Name == "Survivors" or team.Name == "Survivor")
        if not isK and not isS then
            local r = char:GetAttribute("Role") or plr:GetAttribute("Role")
            if type(r) == "string" then
                isK = r:lower():find("killer") ~= nil
                isS = r:lower():find("survivor") ~= nil
            end
        end
        if isK and not CFG.esp_k then if hl[plr] then hl[plr].Enabled = false end return end
        if isS and not CFG.esp_s then if hl[plr] then hl[plr].Enabled = false end return end
        if not isK and not isS then if hl[plr] then hl[plr].Enabled = false end return end
        local col = Color3.fromRGB(255, 255, 255)
        if isK then col = Color3.fromRGB(255, 80, 80)
        else
            local hum = char:FindFirstChildOfClass("Humanoid")
            if char:GetAttribute("IsHooked") then col = Color3.fromRGB(255, 110, 80)
            elseif char:GetAttribute("Knocked") then col = Color3.fromRGB(255, 170, 80)
            elseif hum and hum.Health < hum.MaxHealth then col = Color3.fromRGB(255, 255, 120)
            else col = Color3.fromRGB(100, 255, 100) end
        end
        if not hl[plr] or not hl[plr].Parent then
            local h = Instance.new("Highlight"); h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.Parent = cam; hl[plr] = h
        end
        local h = hl[plr]
        if h.Parent ~= cam then h.Parent = cam end
        h.Adornee = char; h.FillColor = col; h.OutlineColor = col
        h.FillTransparency = CFG.esp_out and 1 or 0.35
        h.OutlineTransparency = 0; h.Enabled = true
    end
    local function updG(obj)
        if not obj or not obj.Parent then return end
        if not CFG.esp_g then if genHL[obj] then genHL[obj].Enabled = false end return end
        local prog = obj:GetAttribute("RepairProgress")
        if prog == nil then return end
        local full = prog >= 100
        local cam = workspace.CurrentCamera
        if not cam then return end
        if not genHL[obj] or not genHL[obj].Parent then
            local h = Instance.new("Highlight"); h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.Parent = cam; genHL[obj] = h
        end
        local h = genHL[obj]
        if h.Parent ~= cam then h.Parent = cam end
        h.Adornee = obj; h.Enabled = true
        if full then h.FillColor = Color3.fromRGB(0, 255, 0); h.OutlineColor = Color3.fromRGB(0, 255, 0)
        else h.FillColor = Color3.fromRGB(80, 220, 120); h.OutlineColor = Color3.fromRGB(80, 220, 120) end
        h.FillTransparency = CFG.esp_out and 1 or 0.5
        h.OutlineTransparency = 0
    end
    RSvc.Heartbeat:Connect(function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        for _, p in ipairs(Players:GetPlayers()) do pcall(upd, p, cam) end
        for g in pairs(tracked) do
            if g and g.Parent then pcall(updG, g)
            else if genHL[g] then genHL[g]:Destroy() end genHL[g], tracked[g] = nil, nil end
        end
    end)
    task.spawn(function()
        task.wait(1)
        local map = workspace:FindFirstChild("Map") or workspace
        for _, o in ipairs(map:GetDescendants()) do
            if o:IsA("Model") and o:GetAttribute("RepairProgress") ~= nil then tracked[o] = true; updG(o) end
        end
    end)
    Players.PlayerRemoving:Connect(function(p) if hl[p] then hl[p]:Destroy(); hl[p] = nil end end)
end)

-- STUN NOTIF
pcall(function()
    local stunH, spin = {}, 0
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
    local function makeH(root, cam)
        local bb = Instance.new("BillboardGui")
        bb.Name = "KZ_StunHead"; bb.Size = UDim2.fromOffset(30, 30); bb.StudsOffset = Vector3.new(0, 3.4, 0)
        bb.AlwaysOnTop = true; bb.Adornee = root; bb.Parent = cam
        local ring = Instance.new("Frame", bb); ring.Size = UDim2.fromScale(1, 1); ring.BackgroundTransparency = 1
        Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
        local st = Instance.new("UIStroke", ring); st.Color = Color3.fromRGB(200, 200, 210); st.Thickness = 2.5; st.Transparency = 0.25
        local g = Instance.new("UIGradient", st); g.Name = "G"
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.35, 0.2),
            NumberSequenceKeypoint.new(0.7, 1), NumberSequenceKeypoint.new(1, 1),
        })
        return bb
    end
    local function killH(p) if stunH[p] then pcall(function() stunH[p]:Destroy() end) end stunH[p] = nil end
    local function wipe()
        for _, g in ipairs(PG:GetChildren()) do if g.Name == "KZ_StunToast" then pcall(function() g:Destroy() end) end end
        stunGui, stunCard, stunOn = nil, nil, false
    end
    local function show()
        if stunOn and stunGui and stunGui.Parent then return end
        wipe()
        stunGui = Instance.new("ScreenGui"); stunGui.Name = "KZ_StunToast"; stunGui.ResetOnSpawn = false
        stunGui.IgnoreGuiInset = true; stunGui.DisplayOrder = 1000005; stunGui.Parent = PG
        stunCard = Instance.new("Frame", stunGui); stunCard.AnchorPoint = Vector2.new(1, 1)
        stunCard.Position = UDim2.new(1, 24, 1, -18); stunCard.Size = UDim2.fromOffset(132, 34)
        stunCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40); stunCard.BackgroundTransparency = 0.4
        stunCard.BorderSizePixel = 0
        Instance.new("UICorner", stunCard).CornerRadius = UDim.new(0, 9)
        local s = Instance.new("UIStroke", stunCard); s.Color = Color3.fromRGB(170, 170, 180); s.Thickness = 1; s.Transparency = 0.45
        local t = Instance.new("TextLabel", stunCard); t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1
        t.Text = "STUN KILLER"; t.TextColor3 = Color3.fromRGB(220, 220, 230); t.Font = Enum.Font.GothamBold; t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Center
        stunOn = true
        TS:Create(stunCard, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(1, -12, 1, -18) }):Play()
    end
    RSvc.RenderStepped:Connect(function(dt)
        spin = spin + dt * 280
        if not CFG.stun_on then
            for _, p in ipairs(Players:GetPlayers()) do killH(p) end
            if stunOn or stunGui then wipe() end
            return
        end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local any = false
        for _, p in ipairs(Players:GetPlayers()) do
            if not isKiller(p) then killH(p); continue end
            local ch = p.Character
            local root = ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart)
            if root and isStunned(ch) then
                any = true
                if not stunH[p] or not stunH[p].Parent then stunH[p] = makeH(root, cam) end
                local bb = stunH[p]
                if bb.Parent ~= cam then bb.Parent = cam end
                bb.Adornee = root
                local g = bb:FindFirstChild("G", true)
                if g then g.Rotation = spin % 360 end
            else killH(p) end
        end
        if any then show() else if stunOn or stunGui then wipe() end end
    end)
    Players.PlayerRemoving:Connect(function(p) killH(p) end)
end)

-- VISION LOOPS
task.spawn(function()
    while true do
        task.wait(1)
        if CFG.ambient then
            pcall(function()
                Lighting.Ambient = Color3.fromRGB(180,180,180)
                Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
                Lighting.Brightness = 3; Lighting.GlobalShadows = false
                Lighting.ClockTime = 14; Lighting.FogEnd = 100000
            end)
        end
        if CFG.boost_fps then pcall(function() if setfpscap then setfpscap(240) end end) end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if CFG.fov_lock then
            local c = Workspace.CurrentCamera
            if c and math.abs(c.FieldOfView - (CFG.fov_value or 120)) > 0.5 then
                pcall(function() c.FieldOfView = CFG.fov_value or 120 end)
            end
        end
    end
end)

-- ============================================================
-- CONFIRM DIALOG
-- ============================================================
local function CreateConfirm(parentGui, title, message, onConfirm, onCancel)
    local overlay = New("Frame", { Parent = parentGui, BackgroundColor3 = T.Overlay, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2000000 })
    local dialog = New("Frame", { Parent = overlay, BackgroundColor3 = T.Panel, BorderSizePixel = 0, Size = UDim2.fromOffset(0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), ZIndex = 2000002 })
    Corner(dialog, 12); Stroke(dialog, T.BorderHi, 1, 0.4)
    New("Frame", { Parent = dialog, BackgroundColor3 = T.Danger, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 0, 0), ZIndex = 2000003 })
    New("TextLabel", { Parent = dialog, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 26), Position = UDim2.new(0, 20, 0, 18), Font = F.Bold, Text = title, TextColor3 = T.Text, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2000003 })
    New("TextLabel", { Parent = dialog, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 44), Position = UDim2.new(0, 20, 0, 48), Font = F.Reg, Text = message, TextColor3 = T.TextSec, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, ZIndex = 2000003 })
    local function makeBtn(x, col, txt, cb)
        local b = New("TextButton", { Parent = dialog, BackgroundColor3 = col, BorderSizePixel = 0, Size = UDim2.fromOffset(140, 34), Position = UDim2.new(1, x, 1, -46), Text = "", AutoButtonColor = false, ZIndex = 2000003 })
        Corner(b, 8)
        New("TextLabel", { Parent = b, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = F.Semi, Text = txt, TextColor3 = Color3.fromRGB(255,255,255), TextSize = 12, ZIndex = 2000004 })
        b.MouseEnter:Connect(function() TS:Create(b, E_QUICK, { BackgroundTransparency = -0.15 }):Play() end)
        b.MouseLeave:Connect(function() TS:Create(b, E_QUICK, { BackgroundTransparency = 0 }):Play() end)
        b.MouseButton1Click:Connect(function()
            TS:Create(dialog, E_EXIT, { Size = UDim2.fromOffset(0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()
            TS:Create(overlay, E_EXIT, { BackgroundTransparency = 1 }):Play()
            task.delay(0.25, function() overlay:Destroy() end)
            if cb then task.defer(cb) end
        end)
    end
    makeBtn(-160, T.Off, "Batal", onCancel)
    makeBtn(-14, T.Danger, "Ya, Tutup", onConfirm)
    TS:Create(overlay, E_SMOOTH, { BackgroundTransparency = 0.5 }):Play()
    TS:Create(dialog, E_BOUNCE, { Size = UDim2.fromOffset(340, 160), Position = UDim2.new(0.5, -170, 0.5, -80) }):Play()
end

-- ============================================================
-- WINDOW
-- ============================================================
local Window = {}
Window.__index = Window

function Window.Make(opts)
    opts = opts or {}
    local win = setmetatable({}, Window)
    win.Tabs = {}; win.CurrentTab = nil; win.Minimized = false; win.Closed = false

    local gui = New("ScreenGui", { Name = "KZ_UI_" .. tostring(math.random(1, 999999)), ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999999, Parent = GetParentGui() })
    win.Gui = gui

    -- SCALE 1.00
    local scaleObj = New("UIScale", { Parent = gui })
    scaleObj.Scale = 1.00
    win.Scale = scaleObj

    local baseW, baseH = 660, 480
    local shadow = New("Frame", { Parent = gui, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.65, BorderSizePixel = 0, Size = UDim2.fromOffset(baseW + 8, baseH + 8), Position = UDim2.new(0.5, -baseW/2 - 4, 0.5, -baseH/2 - 2) })
    Corner(shadow, 18)
    local main = New("Frame", { Parent = gui, BackgroundColor3 = T.Bg, BorderSizePixel = 0, Size = UDim2.fromOffset(baseW, baseH), Position = UDim2.new(0.5, -baseW/2, 0.5, -baseH/2), ClipsDescendants = true })
    Corner(main, 16); Stroke(main, T.BorderHi, 1, 0.4)
    win.Main = main; win.Shadow = shadow

    local accentLine = New("Frame", { Parent = main, BackgroundColor3 = T.Accent, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 0, 0), ZIndex = 50 })
    local grad = New("UIGradient", { Parent = accentLine })
    grad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(0.3, T.AccentGlow), ColorSequenceKeypoint.new(0.6, T.AccentAlt), ColorSequenceKeypoint.new(1, T.Accent) })
    task.spawn(function()
        while accentLine.Parent do grad.Rotation = (grad.Rotation + 0.6) % 360; task.wait(0.02) end
    end)

    local header = New("Frame", { Parent = main, BackgroundColor3 = T.BgAlt, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 54) })
    Corner(header, 16)
    New("Frame", { Parent = header, BackgroundColor3 = T.BgAlt, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 1, -18) })
    New("TextLabel", { Parent = header, BackgroundTransparency = 1, Size = UDim2.new(1, -140, 0, 22), Position = UDim2.new(0, 22, 0, 10), Font = F.Bold, Text = opts.Name or "KALZZ HUB", TextColor3 = T.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left })
    New("TextLabel", { Parent = header, BackgroundTransparency = 1, Size = UDim2.new(1, -140, 0, 14), Position = UDim2.new(0, 22, 0, 32), Font = F.Reg, Text = opts.Subtitle or "", TextColor3 = T.TextDim, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left })

    local minBtn = New("TextButton", { Parent = header, BackgroundColor3 = T.Element, BorderSizePixel = 0, Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -70, 0.5, -14), Text = "", AutoButtonColor = false })
    Corner(minBtn, 7)
    local mLine = New("Frame", { Parent = minBtn, BackgroundColor3 = T.TextSec, BorderSizePixel = 0, Size = UDim2.fromOffset(12, 2), Position = UDim2.new(0.5, -6, 0.5, -1) })
    Corner(mLine, 1)

    local closeBtn = New("TextButton", { Parent = header, BackgroundColor3 = T.Element, BorderSizePixel = 0, Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -38, 0.5, -14), Text = "", AutoButtonColor = false })
    Corner(closeBtn, 7)
    local x1 = New("Frame", { Parent = closeBtn, BackgroundColor3 = T.Danger, BorderSizePixel = 0, Size = UDim2.fromOffset(12, 2), Position = UDim2.new(0.5, -6, 0.5, -1), Rotation = 45 })
    Corner(x1, 1)
    local x2 = New("Frame", { Parent = closeBtn, BackgroundColor3 = T.Danger, BorderSizePixel = 0, Size = UDim2.fromOffset(12, 2), Position = UDim2.new(0.5, -6, 0.5, -1), Rotation = -45 })
    Corner(x2, 1)

    local sidebar = New("Frame", { Parent = main, BackgroundColor3 = T.Sidebar, BorderSizePixel = 0, Size = UDim2.new(0, 168, 1, -94), Position = UDim2.fromOffset(10, 64) })
    Corner(sidebar, 12); Stroke(sidebar, T.Border, 1, 0.65)
    local sideList = New("ScrollingFrame", { Parent = sidebar, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.fromOffset(5, 5), ScrollBarThickness = 3, ScrollBarImageColor3 = T.Border, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y })
    New("UIListLayout", { Parent = sideList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) })
    Pad(sideList, 4, 4, 0, 0)
    win.Sidebar = sideList

    local content = New("Frame", { Parent = main, BackgroundColor3 = T.Bg, BorderSizePixel = 0, Size = UDim2.new(1, -190, 1, -94), Position = UDim2.fromOffset(186, 64) })
    win.Pages = New("Folder", { Parent = content })

    local footer = New("Frame", { Parent = main, BackgroundColor3 = T.Sidebar, BorderSizePixel = 0, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 1, -40) })
    Corner(footer, 10); Stroke(footer, T.Border, 1, 0.7)
    local avatar = New("ImageLabel", { Parent = footer, BackgroundColor3 = T.Element, BorderSizePixel = 0, Size = UDim2.fromOffset(22, 22), Position = UDim2.fromOffset(6, 4), Image = "" })
    Corner(avatar, 11)
    task.spawn(function() pcall(function() avatar.Image = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60) end) end)
    New("TextLabel", { Parent = footer, BackgroundTransparency = 1, Size = UDim2.new(0, 120, 1, 0), Position = UDim2.fromOffset(34, 0), Font = F.Semi, Text = LP.DisplayName or LP.Name, TextColor3 = T.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
    local fpsLbl = New("TextLabel", { Parent = footer, BackgroundTransparency = 1, Size = UDim2.new(0, 120, 1, 0), Position = UDim2.new(1, -130, 0, 0), Font = F.Reg, Text = "FPS: --", TextColor3 = T.TextDim, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right })
    task.spawn(function()
        local frames = 0; local lastT = tick()
        while gui.Parent do
            frames = frames + 1
            if tick() - lastT >= 1 then fpsLbl.Text = string.format("FPS: %d", frames); frames = 0; lastT = tick() end
            task.wait()
        end
    end)

    local drag, ds, sp
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = i.Position; sp = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
            shadow.Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset - 4, main.Position.Y.Scale, main.Position.Y.Offset - 2)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)

    for _, b in ipairs({minBtn, closeBtn}) do
        b.MouseEnter:Connect(function() TS:Create(b, E_QUICK, { BackgroundColor3 = T.ElemHover }):Play() end)
        b.MouseLeave:Connect(function() TS:Create(b, E_QUICK, { BackgroundColor3 = T.Element }):Play() end)
    end

    local origSize = UDim2.fromOffset(baseW, baseH)

    minBtn.MouseButton1Click:Connect(function()
        win.Minimized = not win.Minimized
        if win.Minimized then
            TS:Create(main, E_GLIDE, { Size = UDim2.fromOffset(baseW, 54) }):Play()
            TS:Create(shadow, E_GLIDE, { Size = UDim2.fromOffset(baseW + 8, 62) }):Play()
            for _, c in ipairs(main:GetChildren()) do
                if c ~= header and c:IsA("Frame") then TS:Create(c, E_SMOOTH, { BackgroundTransparency = 1 }):Play() end
            end
        else
            TS:Create(main, E_BOUNCE, { Size = origSize }):Play()
            TS:Create(shadow, E_GLIDE, { Size = UDim2.fromOffset(baseW + 8, baseH + 8) }):Play()
            for _, c in ipairs(main:GetChildren()) do
                if c:IsA("Frame") then TS:Create(c, E_SMOOTH, { BackgroundTransparency = 0 }):Play() end
            end
        end
    end)

    local floatGui = New("ScreenGui", { Name = "KZ_Float", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 2147483647, Parent = GetParentGui() })
    local floatBtn = New("TextButton", { Parent = floatGui, BackgroundColor3 = T.Accent, BackgroundTransparency = 0.55, BorderSizePixel = 0, Size = UDim2.fromOffset(58, 58), Position = UDim2.new(0, 20, 0.5, -29), Text = "KZ", TextColor3 = Color3.fromRGB(255,255,255), Font = F.Bold, TextSize = 20, AutoButtonColor = false, Visible = false })
    Corner(floatBtn, 29)
    local floatStroke = Stroke(floatBtn, T.AccentGlow, 2, 0.4)
    floatBtn.TextStrokeTransparency = 0.3
    floatBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    task.spawn(function()
        while floatBtn.Parent do
            if floatBtn.Visible then
                local t = tick()
                local s = 1 + math.sin(t * 3) * 0.04
                floatBtn.Size = UDim2.fromOffset(58 * s, 58 * s)
                floatBtn.Position = UDim2.new(0, 20 - (58 * s - 58) / 2, 0.5, -29 - (58 * s - 58) / 2)
                floatStroke.Transparency = 0.4 + math.abs(math.sin(t * 2)) * 0.2
                task.wait(0.03)
            else task.wait(0.2) end
        end
    end)

    local fDrag, fStart, fPos, fMoved
    floatBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            fDrag = true; fMoved = false; fStart = i.Position; fPos = floatBtn.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if fDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - fStart
            if d.Magnitude > 6 then
                fMoved = true
                floatBtn.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + d.X, fPos.Y.Scale, fPos.Y.Offset + d.Y)
            end
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if fDrag and not fMoved then
                win.Closed = false
                main.Visible = true; shadow.Visible = true
                main.Size = UDim2.fromOffset(0, 0); main.Position = UDim2.new(0.5, 0, 0.5, 0); main.BackgroundTransparency = 0
                shadow.BackgroundTransparency = 1
                TS:Create(main, E_ENTER, { Size = origSize, Position = UDim2.new(0.5, -baseW/2, 0.5, -baseH/2) }):Play()
                TS:Create(shadow, E_GLIDE, { BackgroundTransparency = 0.65, Size = UDim2.fromOffset(baseW + 8, baseH + 8), Position = UDim2.new(0.5, -baseW/2 - 4, 0.5, -baseH/2 - 2) }):Play()
                floatBtn.Visible = false
                Notify("KALZZ HUB", "UI dibuka kembali", 2, "success")
            end
            fDrag = false
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        CreateConfirm(gui, "Konfirmasi Tutup", "Apakah lu yakin ingin tutup UI ini?", function()
            win.Closed = true
            TS:Create(main, E_EXIT, { Size = UDim2.fromOffset(baseW, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1 }):Play()
            TS:Create(shadow, E_EXIT, { BackgroundTransparency = 1 }):Play()
            task.delay(0.3, function()
                main.Visible = false; shadow.Visible = false
                floatBtn.Visible = true
                Notify("KALZZ HUB", "UI ditutup. Klik KZ untuk buka lagi.", 3, "warn")
            end)
        end, function()
            Notify("KALZZ HUB", "Dibatalkan", 2, "info")
        end)
    end)

    if opts.IntroEnabled ~= false then
        main.Size = UDim2.fromOffset(0, 0); main.Position = UDim2.new(0.5, 0, 0.5, 0)
        main.BackgroundTransparency = 1; shadow.BackgroundTransparency = 1
        TS:Create(main, E_ENTER, { Size = origSize, Position = UDim2.new(0.5, -baseW/2, 0.5, -baseH/2), BackgroundTransparency = 0 }):Play()
        TS:Create(shadow, E_GLIDE, { BackgroundTransparency = 0.65 }):Play()
    end

    task.spawn(function()
        while gui.Parent do
            task.wait(1.5)
            if not win.Closed and not main.Visible and main.Parent then main.Visible = true end
            if gui.Parent ~= GetParentGui() then pcall(function() gui.Parent = GetParentGui() end) end
            pcall(function() gui.Enabled = true end)
        end
    end)

    return win
end

local Tab = {}
Tab.__index = Tab

function Window:MakeTab(opts)
    opts = opts or {}
    local tab = setmetatable({}, Tab)
    tab.Name = opts.Name or "Tab"; tab.Window = self; tab.ElementOrder = 0

    local btn = New("TextButton", { Parent = self.Sidebar, BackgroundColor3 = T.Sidebar, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36), Text = "", AutoButtonColor = false })
    Corner(btn, 8)
    local icon = New("ImageLabel", { Parent = btn, BackgroundTransparency = 1, Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(12, 10), Image = opts.Icon or "rbxassetid://6031091004", ImageColor3 = T.TextSec })
    local lbl = New("TextLabel", { Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(1, -38, 1, 0), Position = UDim2.fromOffset(36, 0), Font = F.Med, Text = tab.Name, TextColor3 = T.TextSec, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
    tab.Button = btn; tab.Icon = icon; tab.Label = lbl

    btn.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then TS:Create(btn, E_QUICK, { BackgroundColor3 = T.ElemHover }):Play() end
    end)
    btn.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then TS:Create(btn, E_QUICK, { BackgroundColor3 = T.Sidebar }):Play() end
    end)

    local page = New("ScrollingFrame", { Parent = self.Pages, Name = "Page_" .. tab.Name, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ScrollBarThickness = 3, ScrollBarImageColor3 = T.Border, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false })
    New("UIListLayout", { Parent = page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })
    Pad(page, 4, 8, 4, 6)
    tab.Page = page

    btn.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
    table.insert(self.Tabs, tab)
    if not self.CurrentTab then self:SelectTab(tab) end
    return tab
end

function Window:SelectTab(tab)
    self.CurrentTab = tab
    for _, t in ipairs(self.Tabs) do
        t.Page.Visible = (t == tab)
        if t == tab then t.Page.Position = UDim2.new(0, 0, 0, 0) end
        local on = (t == tab)
        TS:Create(t.Button, E_SMOOTH, { BackgroundColor3 = on and T.Element or T.Sidebar }):Play()
        TS:Create(t.Label, E_SMOOTH, { TextColor3 = on and T.Text or T.TextSec }):Play()
        TS:Create(t.Icon, E_SMOOTH, { ImageColor3 = on and T.Accent or T.TextSec }):Play()
    end
end

function Tab:AddSection(opts)
    opts = opts or {}
    self.ElementOrder = self.ElementOrder + 1
    local sec = {}
    sec.Name = opts.Name or "Section"; sec.Tab = self; sec.Order = self.ElementOrder
    New("TextLabel", { Parent = self.Page, BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 24), Font = F.Bold, Text = string.upper(sec.Name), TextColor3 = T.TextDim, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = sec.Order })
    function sec:AddButton(o) self.Tab.ElementOrder = self.Tab.ElementOrder + 1; return Tab.AddButton(self.Tab, o, self.Tab.ElementOrder) end
    function sec:AddToggle(o) self.Tab.ElementOrder = self.Tab.ElementOrder + 1; return Tab.AddToggle(self.Tab, o, self.Tab.ElementOrder) end
    function sec:AddSlider(o) self.Tab.ElementOrder = self.Tab.ElementOrder + 1; return Tab.AddSlider(self.Tab, o, self.Tab.ElementOrder) end
    function sec:AddDropdown(o) self.Tab.ElementOrder = self.Tab.ElementOrder + 1; return Tab.AddDropdown(self.Tab, o, self.Tab.ElementOrder) end
    function sec:AddBind(o) self.Tab.ElementOrder = self.Tab.ElementOrder + 1; return Tab.AddBind(self.Tab, o, self.Tab.ElementOrder) end
    function sec:AddTextbox(o) self.Tab.ElementOrder = self.Tab.ElementOrder + 1; return Tab.AddTextbox(self.Tab, o, self.Tab.ElementOrder) end
    function sec:AddLabel(t) self.Tab.ElementOrder = self.Tab.ElementOrder + 1; return Tab.AddLabel(self.Tab, t, self.Tab.ElementOrder) end
    function sec:AddParagraph(t, c) self.Tab.ElementOrder = self.Tab.ElementOrder + 1; return Tab.AddParagraph(self.Tab, t, c, self.Tab.ElementOrder) end
    return sec
end

local function MakeBaseRow(page, height, order)
    local row = New("Frame", { Parent = page, BackgroundColor3 = T.Element, BorderSizePixel = 0, Size = UDim2.new(1, -4, 0, height or 40), LayoutOrder = order or 0 })
    Corner(row, 9)
    local s = Stroke(row, T.Border, 1, 0.6)
    row.MouseEnter:Connect(function()
        TS:Create(row, E_SMOOTH, { BackgroundColor3 = T.ElemHover }):Play()
        TS:Create(s, E_SMOOTH, { Transparency = 0.3 }):Play()
    end)
    row.MouseLeave:Connect(function()
        TS:Create(row, E_SMOOTH, { BackgroundColor3 = T.Element }):Play()
        TS:Create(s, E_SMOOTH, { Transparency = 0.6 }):Play()
    end)
    return row
end

function Tab:AddButton(opts, order)
    opts = opts or {}
    if not order then self.ElementOrder = self.ElementOrder + 1; order = self.ElementOrder end
    local row = MakeBaseRow(self.Page, 42, order)
    local btn = New("TextButton", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", AutoButtonColor = false })
    local lbl = New("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, -70, 1, 0), Position = UDim2.fromOffset(16, 0), Font = F.Med, Text = opts.Name or "Button", TextColor3 = T.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
    local arrow = New("ImageLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, -28, 0.5, -7), Image = "rbxassetid://6031094678", ImageColor3 = T.TextDim })
    btn.MouseButton1Down:Connect(function() TS:Create(row, E_QUICK, { BackgroundColor3 = T.ElemPress }):Play() end)
    btn.MouseButton1Up:Connect(function() TS:Create(row, E_SMOOTH, { BackgroundColor3 = T.ElemHover }):Play() end)
    btn.MouseButton1Click:Connect(function()
        if opts.Callback then
            pcall(opts.Callback)
            local orig = arrow.Position
            arrow.Position = UDim2.new(1, -22, 0.5, -7)
            TS:Create(arrow, E_QUICK, { Position = orig, ImageColor3 = T.Accent }):Play()
            task.delay(0.2, function() TS:Create(arrow, E_SMOOTH, { ImageColor3 = T.TextDim }):Play() end)
        end
    end)
    return { Set = function(_, n) lbl.Text = n end }
end

function Tab:AddLabel(text, order)
    if not order then self.ElementOrder = self.ElementOrder + 1; order = self.ElementOrder end
    local l = New("TextLabel", { Parent = self.Page, BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 22), Font = F.Med, Text = text or "", TextColor3 = T.TextSec, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = order })
    Pad(l, 4, 0, 6, 0)
    return { Set = function(_, v) l.Text = v end }
end

function Tab:AddParagraph(title, content, order)
    if not order then self.ElementOrder = self.ElementOrder + 1; order = self.ElementOrder end
    local f = New("Frame", { Parent = self.Page, BackgroundColor3 = T.Element, BorderSizePixel = 0, Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order })
    Corner(f, 9); Stroke(f, T.Border, 1, 0.6)
    Pad(f, 12, 12, 14, 14)
    New("UIListLayout", { Parent = f, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })
    local titleL = New("TextLabel", { Parent = f, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Font = F.Bold, Text = title or "Title", TextColor3 = T.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1 })
    local contentL = New("TextLabel", { Parent = f, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = F.Reg, Text = content or "", TextColor3 = T.TextSec, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, LayoutOrder = 2 })
    return { Set = function(_, t, c) if t then titleL.Text = t end if c then contentL.Text = c end end }
end

function Tab:AddToggle(opts, order)
    opts = opts or {}
    if not order then self.ElementOrder = self.ElementOrder + 1; order = self.ElementOrder end
    local row = MakeBaseRow(self.Page, 42, order)
    New("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, -90, 1, 0), Position = UDim2.fromOffset(16, 0), Font = F.Med, Text = opts.Name or "Toggle", TextColor3 = T.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
    local state = opts.Default or false
    local switch = New("Frame", { Parent = row, BackgroundColor3 = state and T.Accent or T.Off, BorderSizePixel = 0, Size = UDim2.fromOffset(42, 22), Position = UDim2.new(1, -58, 0.5, -11) })
    Corner(switch, 11)
    local knob = New("Frame", { Parent = switch, BackgroundColor3 = state and T.Bg or T.Text, BorderSizePixel = 0, Size = UDim2.fromOffset(18, 18), Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9) })
    Corner(knob, 9)
    local click = New("TextButton", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", AutoButtonColor = false })
    local function set(v, fire)
        state = v
        TS:Create(knob, E_ENTER, { Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = state and T.Bg or T.Text }):Play()
        TS:Create(switch, E_SMOOTH, { BackgroundColor3 = state and T.Accent or T.Off }):Play()
        if state then PulseColor(switch, "BackgroundColor3", T.Accent, T.AccentGlow, 0.35) end
        if fire and opts.Callback then pcall(opts.Callback, state) end
    end
    click.MouseButton1Click:Connect(function() set(not state, true); saveCfg() end)
    if opts.Callback then task.defer(function() pcall(opts.Callback, state) end) end
    return { Set = function(_, v) set(v, true) end, Get = function() return state end }
end

function Tab:AddSlider(opts, order)
    opts = opts or {}
    if not order then self.ElementOrder = self.ElementOrder + 1; order = self.ElementOrder end
    local row = MakeBaseRow(self.Page, 56, order)
    New("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, -90, 0, 20), Position = UDim2.fromOffset(16, 8), Font = F.Med, Text = opts.Name or "Slider", TextColor3 = T.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
    local minv, maxv = opts.Min or 0, opts.Max or 100
    local inc = opts.Increment or 1
    local val = opts.Default or minv
    local valLbl = New("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.fromOffset(60, 20), Position = UDim2.new(1, -78, 0, 8), Font = F.Bold, Text = tostring(val), TextColor3 = T.Accent, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right })
    local barBg = New("TextButton", { Parent = row, BackgroundColor3 = T.Off, BorderSizePixel = 0, Size = UDim2.new(1, -32, 0, 5), Position = UDim2.new(0, 16, 1, -18), Text = "", AutoButtonColor = false })
    Corner(barBg, 3)
    local pct = (val - minv) / (maxv - minv)
    local fill = New("Frame", { Parent = barBg, BackgroundColor3 = T.Accent, BorderSizePixel = 0, Size = UDim2.new(pct, 0, 1, 0) })
    Corner(fill, 3)
    local knob = New("Frame", { Parent = barBg, BackgroundColor3 = T.Text, BorderSizePixel = 0, Size = UDim2.fromOffset(14, 14), Position = UDim2.new(pct, -7, 0.5, -7) })
    Corner(knob, 7); Stroke(knob, T.BorderHi, 1, 0.4)
    local dragging = false
    local function updateFromX(x)
        local a = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local raw = minv + (maxv - minv) * a
        local snapped = math.floor(raw / inc + 0.5) * inc
        snapped = math.clamp(snapped, minv, maxv)
        val = snapped
        valLbl.Text = tostring(math.floor(snapped * 1000 + 0.5) / 1000)
        local np = (val - minv) / (maxv - minv)
        fill.Size = UDim2.new(np, 0, 1, 0)
        knob.Position = UDim2.new(np, -7, 0.5, -7)
        if opts.Callback then pcall(opts.Callback, val) end
    end
    barBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            TS:Create(knob, E_QUICK, { Size = UDim2.fromOffset(20, 20) }):Play()
            updateFromX(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateFromX(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                saveCfg()
                local p = (val - minv) / (maxv - minv)
                TS:Create(knob, E_ENTER, { Size = UDim2.fromOffset(14, 14), Position = UDim2.new(p, -7, 0.5, -7) }):Play()
            end
        end
    end)
    if opts.Callback then task.defer(function() pcall(opts.Callback, val) end) end
    return {
        Set = function(_, v)
            val = math.clamp(v, minv, maxv)
            valLbl.Text = tostring(val)
            local p = (val - minv) / (maxv - minv)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -7, 0.5, -7)
            if opts.Callback then pcall(opts.Callback, val) end
        end,
        Get = function() return val end,
    }
end

function Tab:AddDropdown(opts, order)
    opts = opts or {}
    if not order then self.ElementOrder = self.ElementOrder + 1; order = self.ElementOrder end
    local options = opts.Options or opts.Values or {}
    local current = opts.Default or options[1] or ""
    local container = New("Frame", { Parent = self.Page, BackgroundColor3 = T.Element, BorderSizePixel = 0, Size = UDim2.new(1, -4, 0, 42), ClipsDescendants = true, LayoutOrder = order })
    Corner(container, 9); Stroke(container, T.Border, 1, 0.6)
    local head = New("TextButton", { Parent = container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), Text = "", AutoButtonColor = false })
    local lbl = New("TextLabel", { Parent = head, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromOffset(16, 0), Font = F.Med, Text = (opts.Name or "Dropdown") .. " : " .. tostring(current), TextColor3 = T.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
    local arrow = New("ImageLabel", { Parent = head, BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, -28, 0.5, -7), Image = "rbxassetid://6031094678", ImageColor3 = T.TextDim, Rotation = 90 })
    local list = New("Frame", { Parent = container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 42) })
    New("UIListLayout", { Parent = list, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) })
    Pad(list, 4, 8, 8, 8)
    local opened = false
    local targetH = 42
    for _, opt in ipairs(options) do
        local ob = New("TextButton", { Parent = list, BackgroundColor3 = T.BgAlt, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), Text = "", AutoButtonColor = false })
        Corner(ob, 6)
        New("TextLabel", { Parent = ob, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(12, 0), Font = F.Reg, Text = tostring(opt), TextColor3 = T.TextSec, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
        ob.MouseEnter:Connect(function() TS:Create(ob, E_QUICK, { BackgroundColor3 = T.ElemHover }):Play() end)
        ob.MouseLeave:Connect(function() TS:Create(ob, E_QUICK, { BackgroundColor3 = T.BgAlt }):Play() end)
        ob.MouseButton1Click:Connect(function()
            current = opt
            lbl.Text = (opts.Name or "Dropdown") .. " : " .. tostring(opt)
            if opts.Callback then pcall(opts.Callback, opt) end
            opened = false
            container.Size = UDim2.new(1, -4, 0, 42)
            TS:Create(arrow, E_SMOOTH, { Rotation = 90 }):Play()
            PulseColor(lbl, "TextColor3", T.Text, T.Accent, 0.4)
            saveCfg()
        end)
        targetH = targetH + 33
    end
    head.MouseButton1Click:Connect(function()
        opened = not opened
        container.Size = UDim2.new(1, -4, 0, opened and targetH or 42)
        TS:Create(arrow, E_SMOOTH, { Rotation = opened and -90 or 90 }):Play()
    end)
    if opts.Callback then task.defer(function() pcall(opts.Callback, current) end) end
    return {
        Set = function(_, v)
            current = v
            lbl.Text = (opts.Name or "Dropdown") .. " : " .. tostring(v)
            if opts.Callback then pcall(opts.Callback, v) end
        end,
        Get = function() return current end,
    }
end

function Tab:AddBind(opts, order)
    opts = opts or {}
    if not order then self.ElementOrder = self.ElementOrder + 1; order = self.ElementOrder end
    local row = MakeBaseRow(self.Page, 42, order)
    New("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, -120, 1, 0), Position = UDim2.fromOffset(16, 0), Font = F.Med, Text = opts.Name or "Keybind", TextColor3 = T.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
    local current = opts.Default or Enum.KeyCode.Unknown
    local btn = New("TextButton", { Parent = row, BackgroundColor3 = T.Off, BorderSizePixel = 0, Size = UDim2.fromOffset(90, 26), Position = UDim2.new(1, -102, 0.5, -13), Font = F.Semi, Text = (current and current.Name) or "None", TextColor3 = T.Text, TextSize = 11, AutoButtonColor = false })
    Corner(btn, 6)
    local listening = false
    local suppressNext = false
    btn.MouseButton1Click:Connect(function()
        listening = true; suppressNext = true
        btn.Text = "..."
        TS:Create(btn, E_SMOOTH, { BackgroundColor3 = T.Accent }):Play()
    end)
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                current = input.KeyCode
                btn.Text = current.Name
                listening = false; suppressNext = true
                TS:Create(btn, E_SMOOTH, { BackgroundColor3 = T.Off }):Play()
                PulseColor(btn, "BackgroundColor3", T.Off, T.AccentGlow, 0.4)
                if opts.Callback then pcall(opts.Callback, current) end
            end
            return
        end
        if suppressNext then suppressNext = false; return end
        if current and input.KeyCode == current and not opts.Hold then
            if opts.Callback then pcall(opts.Callback) end
        end
    end)
    return { Set = function(_, key) current = key; btn.Text = key and key.Name or "None" end, Get = function() return current end }
end

function Tab:AddTextbox(opts, order)
    opts = opts or {}
    if not order then self.ElementOrder = self.ElementOrder + 1; order = self.ElementOrder end
    local row = MakeBaseRow(self.Page, 42, order)
    New("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.fromOffset(16, 0), Font = F.Med, Text = opts.Name or "Textbox", TextColor3 = T.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
    local box = New("TextBox", { Parent = row, BackgroundColor3 = T.BgAlt, BorderSizePixel = 0, Size = UDim2.new(0.5, -16, 0, 28), Position = UDim2.new(1, -16, 0.5, -14), AnchorPoint = Vector2.new(1, 0), Font = F.Reg, PlaceholderColor3 = T.TextDim, PlaceholderText = opts.PlaceholderText or "Type...", Text = opts.Default or "", TextColor3 = T.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false })
    Corner(box, 7); Pad(box, 0, 0, 10, 10)
    local bs = Stroke(box, T.Border, 1, 0.6)
    box.Focused:Connect(function() TS:Create(bs, E_QUICK, { Color = T.Accent, Transparency = 0 }):Play() end)
    box.FocusLost:Connect(function(enter)
        TS:Create(bs, E_QUICK, { Color = T.Border, Transparency = 0.6 }):Play()
        if opts.Callback then pcall(opts.Callback, box.Text, enter) end
    end)
    return { Set = function(_, v) box.Text = v end, Get = function() return box.Text end }
end

-- ============================================================
-- BUILD UI
-- ============================================================
local W = Window.Make({ Name = "KALZZ HUB", Subtitle = "v9 • " .. INVITE, IntroEnabled = true })

local TabHome = W:MakeTab({ Name = "Home", Icon = "rbxassetid://6031075931" })
local TabSurv = W:MakeTab({ Name = "Survivor", Icon = "rbxassetid://6031091004" })
local TabKill = W:MakeTab({ Name = "Killer", Icon = "rbxassetid://6031178143" })
local TabEsp  = W:MakeTab({ Name = "ESP", Icon = "rbxassetid://6031280882" })
local TabMisc = W:MakeTab({ Name = "Misc", Icon = "rbxassetid://6031091004" })

local sHome = TabHome:AddSection({ Name = "Welcome" })
sHome:AddParagraph("KALZZ HUB", "UI anti ilang aktif. Klik X untuk konfirmasi. Klik KZ floating untuk buka lagi.")
sHome:AddButton({ Name = "Copy Discord Invite", Callback = function()
    pcall(function() if setclipboard then setclipboard("https://" .. INVITE) end end)
    Notify("KALZZ HUB", "Invite tersalin!", 2, "success")
end})
sHome:AddButton({ Name = "Print Remotes", Callback = function()
    print("[KZ] ToF:", RC.tof, "| Parry:", RC.parry, "| FV:", RC.fastvault)
end})

local sToF = TabSurv:AddSection({ Name = "Silent Aim ToF" })
sToF:AddToggle({ Name = "Enable ToF", Default = CFG.tof_on, Callback = function(v) CFG.tof_on = v end })
sToF:AddToggle({ Name = "Show FOV", Default = CFG.tof_show_fov, Callback = function(v) CFG.tof_show_fov = v end })
sToF:AddSlider({ Name = "FOV", Min = 1, Max = 800, Default = CFG.tof_fov, Increment = 1, Callback = function(v) CFG.tof_fov = v end })
sToF:AddSlider({ Name = "Predict x10", Min = 10, Max = 50, Default = math.floor(CFG.tof_predict * 10), Increment = 1, Callback = function(v) CFG.tof_predict = v / 10 end })

local sGen = TabSurv:AddSection({ Name = "Auto Generator" })
sGen:AddToggle({ Name = "Enable Auto Gen", Default = CFG.gene_on, Callback = function(v) CFG.gene_on = v end })
sGen:AddDropdown({ Name = "Method", Options = {"PERFECT", "NEUTRAL", "INSTANT"}, Default = CFG.gene_method, Callback = function(v) CFG.gene_method = v end })

local sParry = TabSurv:AddSection({ Name = "Auto Parry" })
sParry:AddToggle({ Name = "Enable Parry", Default = CFG.parry_on, Callback = function(v) CFG.parry_on = v end })
sParry:AddSlider({ Name = "Radius", Min = 1, Max = 30, Default = CFG.parry_radius, Increment = 1, Callback = function(v) CFG.parry_radius = v end })
sParry:AddToggle({ Name = "Aggressive", Default = CFG.parry_aggro, Callback = function(v) CFG.parry_aggro = v end })
sParry:AddToggle({ Name = "Fast Vault", Default = CFG.fast_vault, Callback = function(v) CFG.fast_vault = v end })

local sVeil = TabKill:AddSection({ Name = "Silent Aim Veil" })
sVeil:AddToggle({ Name = "Enable Veil", Default = CFG.veil_on, Callback = function(v) CFG.veil_on = v end })
sVeil:AddToggle({ Name = "Show FOV", Default = CFG.veil_show_fov, Callback = function(v) CFG.veil_show_fov = v end })
sVeil:AddSlider({ Name = "FOV", Min = 1, Max = 800, Default = CFG.veil_fov, Increment = 1, Callback = function(v) CFG.veil_fov = v end })
sVeil:AddSlider({ Name = "Distance", Min = 100, Max = 500, Default = math.clamp(CFG.veil_maxdist, 100, 500), Increment = 10, Callback = function(v) CFG.veil_maxdist = v end })

local sEspP = TabEsp:AddSection({ Name = "Player ESP" })
sEspP:AddToggle({ Name = "Survivor ESP", Default = CFG.esp_s, Callback = function(v) CFG.esp_s = v end })
sEspP:AddToggle({ Name = "Killer ESP", Default = CFG.esp_k, Callback = function(v) CFG.esp_k = v end })
sEspP:AddToggle({ Name = "Item ESP", Default = CFG.esp_item, Callback = function(v) CFG.esp_item = v end })

local sEspG = TabEsp:AddSection({ Name = "Generator ESP" })
sEspG:AddToggle({ Name = "Generator ESP", Default = CFG.esp_g, Callback = function(v) CFG.esp_g = v end })
sEspG:AddToggle({ Name = "Show Progress", Default = CFG.esp_gen_txt, Callback = function(v) CFG.esp_gen_txt = v end })
sEspG:AddToggle({ Name = "Outline Only", Default = CFG.esp_out, Callback = function(v) CFG.esp_out = v end })

local sVision = TabMisc:AddSection({ Name = "Vision" })
sVision:AddToggle({ Name = "FOV Lock", Default = CFG.fov_lock, Callback = function(v) CFG.fov_lock = v end })
sVision:AddSlider({ Name = "FOV Value", Min = 60, Max = 140, Default = CFG.fov_value, Increment = 1, Callback = function(v) CFG.fov_value = v end })
sVision:AddToggle({ Name = "Bright Ambient", Default = CFG.ambient, Callback = function(v) CFG.ambient = v end })
sVision:AddToggle({ Name = "Boost FPS", Default = CFG.boost_fps, Callback = function(v) CFG.boost_fps = v end })

local sNotif = TabMisc:AddSection({ Name = "Notifications" })
sNotif:AddToggle({ Name = "Proximity Alert", Default = CFG.alert, Callback = function(v) CFG.alert = v end })
sNotif:AddToggle({ Name = "Stun Killer Notif", Default = CFG.stun_on, Callback = function(v) CFG.stun_on = v end })

local sKeys = TabMisc:AddSection({ Name = "Keybinds" })
sKeys:AddBind({ Name = "Hide UI", Default = Enum.KeyCode.RightShift, Callback = function()
    for _, gui in ipairs(GetParentGui():GetChildren()) do
        if gui.Name:find("KZ_UI_") then gui.Enabled = not gui.Enabled end
    end
end })
sKeys:AddLabel("V = ToF | B = Veil | P = Parry | RightShift = Hide")

-- HOTKEYS
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.V then CFG.tof_on = not CFG.tof_on end
    if i.KeyCode == Enum.KeyCode.B then CFG.veil_on = not CFG.veil_on end
    if i.KeyCode == Enum.KeyCode.P then
        if _G.KZ_ManualParry then _G.KZ_ManualParry() end
    end
end)

Notify("KALZZ HUB", "UI loaded. Anti ilang aktif.", 4, "success")
print("[KALZZ HUB V9] loaded successfully | Scale 1.00")
