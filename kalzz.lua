--[[ KALZZ HUB v2 | Crash-Proof Unified Hook | No AutoCrouch | Folded ToF/Veil ]]

local P    = game:GetService("Players")
local RS   = game:GetService("ReplicatedStorage")
local RSvc = game:GetService("RunService")
local UIS  = game:GetService("UserInputService")
local WS   = game:GetService("Workspace")
local L    = game:GetService("Lighting")
local TS   = game:GetService("TweenService")
local CG   = game:GetService("CoreGui")
local HS   = game:GetService("HttpService")
local LP   = P.LocalPlayer
local PG   = LP:WaitForChild("PlayerGui")
local Cam  = WS.CurrentCamera

local INV = "dCYTep9cY"
local URL = "https://discord.gg/"..INV
local IMG = "rbxassetid://134442738689157"

pcall(function()
    if setfpscap then setfpscap(600) end
    local s = settings()
    if s then
        pcall(function() s.Rendering.FrameRateCap = 600 end)
        pcall(function() s.Rendering.GraphicsQuality = 1 end)
        pcall(function() s.Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        pcall(function() s.Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04 end)
        pcall(function() s.Rendering.ShowBoundingBoxes = false end)
        pcall(function() s.Rendering.ShowWelds = false end)
        pcall(function() s.Network.IncomingReplicationLag = 0 end)
    end
end)

pcall(function()
    for _,pr in ipairs({CG,PG}) do
        for _,g in ipairs(pr:GetChildren()) do
            if g.Name:find("Kalzz") or g.Name:find("KZ_") then pcall(function() g:Destroy() end) end
        end
    end
    for _,o in ipairs(WS:GetChildren()) do if o.Name:sub(1,3)=="KZ_" then pcall(function() o:Destroy() end) end end
end)

-- ====================================================
-- REMOTE CACHE (scan sekali, akurat)
-- ====================================================
local RC = { tof=nil, veil=nil, parry=nil, fastvault=nil }

local function scanRemotes()
    local function scan(parent, depth)
        if depth > 4 or not parent then return end
        for _, o in ipairs(parent:GetChildren()) do
            if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
                local n = o.Name:lower()
                local full = ""
                pcall(function() full = o:GetFullName():lower() end)

                if not RC.tof and (full:find("twist") or full:find("fate") or (n=="fire" and full:find("tof"))) then
                    RC.tof = o
                end
                if not RC.veil and (n == "spearthrow" or full:find("spearthrow")) then
                    RC.veil = o
                end
                if not RC.parry and (n == "parry" or full:find("parrying")) then
                    RC.parry = o
                end
                if not RC.fastvault and (n == "fastvault" or n == "survivorfastvault") then
                    RC.fastvault = o
                end
            elseif o:IsA("Folder") or o:IsA("Model") then
                scan(o, depth + 1)
            end
        end
    end
    scan(RS, 0)
    print(string.format("[KZ] Remotes: ToF=%s Veil=%s Parry=%s FV=%s",
        tostring(RC.tof ~= nil), tostring(RC.veil ~= nil),
        tostring(RC.parry ~= nil), tostring(RC.fastvault ~= nil)))
end
scanRemotes()
task.delay(5, scanRemotes)

-- ====================================================
-- CONFIG
-- ====================================================
local DEF = {
    gene_on=true, gene_method="PERFECT",
    fast_vault=true,
    tof_on=true, tof_fov=380,
    tof_predict=3.0, tof_smooth=0.55, tof_maxdist=900,
    tof_show_fov=true, tof_show_tracer=true,
    veil_on=true, veil_fov=280,
    veil_maxdist=500, veil_predict=1.4, veil_lead=1.4,
    veil_speed=165, veil_grav=103,
    veil_aura_speed=165, veil_aura_grav=96.5,
    veil_show_fov=true, veil_show_tracker=true,
    parry_on=true, parry_radius=12, parry_circle=true, parry_aggro=true, parry_sensitive=200,
    esp_k=true, esp_s=true, esp_g=true, esp_out=false, esp_range=5000,
    stun_indicator=true, fog=false, bright=true, cam=true, camv=90, alert=true,
}
local CF = "kalzz_v2.json"
local CFS = (type(writefile)=="function") and (type(readfile)=="function") and (type(isfile)=="function")
local CFG = {}
if CFS then pcall(function()
    if isfile(CF) then
        local d = HS:JSONDecode(readfile(CF))
        if type(d)=="table" then for k,v in pairs(d) do if DEF[k]~=nil then CFG[k]=v end end end
    end
end) end
for k,v in pairs(DEF) do if CFG[k]==nil then CFG[k]=v end end
_G.KALZZ_CFG = CFG
local dirty = false
task.spawn(function()
    while true do task.wait(3)
        if dirty then dirty=false pcall(function() writefile(CF,HS:JSONEncode(CFG)) end) end
    end
end)
pcall(function() game:BindToClose(function() if CFS then pcall(function() writefile(CF,HS:JSONEncode(CFG)) end) end end) end)
_G.KZ_SaveConfig = function() dirty = true end

-- ====================================================
-- HELPERS
-- ====================================================
local PID = {
    ["122812055447896"]=1,["133963973694098"]=1,["117042998468241"]=1,["135002183282873"]=1,
    ["121216847022485"]=1,["132817836308238"]=1,["129784271201071"]=1,["82666958311998"]=1,
    ["78432063483146"]=1,["118907603246885"]=1,["139369275981139"]=1,["110355011987939"]=1,
    ["111920872708571"]=1,["105374834496520"]=1,["138720291317243"]=1,["106871536134254"]=1,
    ["130593238885843"]=1,["115244153053858"]=1,["74968262036854"]=1,["113255068724446"]=1,
    ["98163597193511"]=1,["80411309607666"]=1,
}
local CK, CS, CGr = Color3.fromRGB(230,80,80), Color3.fromRGB(80,160,230), Color3.fromRGB(80,220,120)

local function rtp(m) if not m then return nil end return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("RootPart") or m:FindFirstChildWhichIsA("BasePart") end
local KKW = {"jason","killer","stalker","masked","hidden","abyss","veil","cure","hunter","slasher","mori","maniac","demon","jeff","mayers"}
local function hK(s,l) if not s then return false end s=s:lower() for _,k in ipairs(l) do if s:find(k,1,true) then return true end end return false end
local function isKiller(ch)
    if not ch or not ch.Parent then return false end
    local pl = P:GetPlayerFromCharacter(ch)
    if not pl then return false end
    for _,a in ipairs({"Role","role","Team","team","Type","type"}) do
        local v = pl:GetAttribute(a) or ch:GetAttribute(a)
        if type(v)=="string" then local lv=v:lower() if lv:find("killer") then return true end if lv:find("survivor") then return false end end
    end
    if pl.Team then local tn=pl.Team.Name:lower() if tn:find("killer") then return true end if tn:find("survivor") then return false end end
    local tl = ch:FindFirstChildOfClass("Tool")
    if tl then local n=tl.Name:lower() if n:find("knife") or n:find("sword") or n:find("weapon") then return true end end
    if hK(pl.Name,KKW) or hK(pl.DisplayName,KKW) or hK(ch.Name,KKW) then return true end
    return false
end
_G.KZ_isKiller = isKiller
_G.KZ_root = rtp

local Sched = { _t = {} }
function Sched:Add(name, fn, hz) self._t[name] = { fn = fn, interval = 1/(hz or 30), last = 0 } end
RSvc.Heartbeat:Connect(function()
    local now = os.clock()
    for _, t in pairs(Sched._t) do
        if now - t.last >= t.interval then t.last = now; pcall(t.fn) end
    end
end)
_G.KZ_Sched = Sched

local COL = {
    bg=Color3.fromRGB(15,15,18), panel=Color3.fromRGB(20,20,24), side=Color3.fromRGB(17,17,21),
    card=Color3.fromRGB(26,26,32), tabOn=Color3.fromRGB(38,38,46), brd=Color3.fromRGB(48,48,56),
    brdS=Color3.fromRGB(38,38,46), tx=Color3.fromRGB(240,240,245), txD=Color3.fromRGB(160,160,175),
    txF=Color3.fromRGB(110,110,125), acc=Color3.fromRGB(100,140,230), off=Color3.fromRGB(52,52,62),
}
local TR, TRP, TRC = 0.30, 0.30, 0.50

local GUI = Instance.new("ScreenGui")
GUI.Name = "KalzzHub"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 999999
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() if gethui then GUI.Parent = gethui() else GUI.Parent = CG end end)
if not GUI.Parent then GUI.Parent = PG end
Instance.new("UIScale", GUI).Scale = 0.80

local function cR(o,r) local c=Instance.new("UICorner",o) c.CornerRadius=UDim.new(0,r or 8) return c end
local function cS(o,c,t,tr) local s=Instance.new("UIStroke",o) s.Color=c or COL.brd s.Thickness=t or 1 s.Transparency=tr or 0.4 return s end

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.fromOffset(580, 480)
Main.Position = UDim2.new(0.5,-290,0.5,-240)
Main.BackgroundColor3 = COL.bg
Main.BackgroundTransparency = TR
Main.BorderSizePixel = 0; Main.ZIndex = 10
cR(Main,10); cS(Main,COL.brd,1,0.4)

local Hdr = Instance.new("Frame", Main)
Hdr.Size = UDim2.new(1,0,0,48)
Hdr.BackgroundColor3 = COL.panel
Hdr.BackgroundTransparency = TRP
Hdr.BorderSizePixel = 0; Hdr.ZIndex = 11; cR(Hdr,10)
local HF = Instance.new("Frame", Hdr)
HF.Size = UDim2.new(1,0,0,12)
HF.Position = UDim2.new(0,0,1,-12)
HF.BackgroundColor3 = COL.panel
HF.BackgroundTransparency = TRP
HF.BorderSizePixel = 0; HF.ZIndex = 11

local Title = Instance.new("TextLabel", Hdr)
Title.Size = UDim2.new(1,-140,0,20)
Title.Position = UDim2.fromOffset(18,8)
Title.BackgroundTransparency = 1; Title.Text = "KALZZ HUB v2"
Title.TextColor3 = COL.tx; Title.Font = Enum.Font.GothamBold; Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left; Title.ZIndex = 12

local Sub = Instance.new("TextLabel", Hdr)
Sub.Size = UDim2.new(1,-140,0,14)
Sub.Position = UDim2.fromOffset(18,28)
Sub.BackgroundTransparency = 1; Sub.Text = "discord.gg/"..INV
Sub.TextColor3 = COL.txF; Sub.Font = Enum.Font.Gotham; Sub.TextSize = 10
Sub.TextXAlignment = Enum.TextXAlignment.Left; Sub.ZIndex = 12

local function mkX(x)
    local b = Instance.new("TextButton", Hdr)
    b.Size = UDim2.fromOffset(26,26)
    b.Position = UDim2.new(1,x,0.5,-13)
    b.BackgroundColor3 = Color3.fromRGB(220,80,80)
    b.BackgroundTransparency = 0.25
    b.Text = ""; b.BorderSizePixel = 0; b.AutoButtonColor = false; b.ZIndex = 12; cR(b,6)
    for _, rot in ipairs({45,-45}) do
        local l = Instance.new("Frame", b)
        l.Size = UDim2.fromOffset(12,2)
        l.Position = UDim2.new(0.5,-6,0.5,-1)
        l.BackgroundColor3 = Color3.fromRGB(255,255,255)
        l.BorderSizePixel = 0; l.ZIndex = 13; cR(l,1); l.Rotation = rot
    end
    return b
end
local function mkM(x)
    local b = Instance.new("TextButton", Hdr)
    b.Size = UDim2.fromOffset(26,26)
    b.Position = UDim2.new(1,x,0.5,-13)
    b.BackgroundColor3 = Color3.fromRGB(60,60,75)
    b.BackgroundTransparency = 0.25
    b.Text = ""; b.BorderSizePixel = 0; b.AutoButtonColor = false; b.ZIndex = 12; cR(b,6)
    local l = Instance.new("Frame", b)
    l.Size = UDim2.fromOffset(12,2)
    l.Position = UDim2.new(0.5,-6,0.5,-1)
    l.BackgroundColor3 = Color3.fromRGB(255,255,255)
    l.BorderSizePixel = 0; l.ZIndex = 13; cR(l,1)
    return b
end
local MinB = mkM(-68)
local ClsB = mkX(-36)

local drg, ds, sp
Hdr.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drg = true; ds = i.Position; sp = Main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d = i.Position - ds
        Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=false end
end)

local Side = Instance.new("Frame", Main)
Side.Size = UDim2.new(0,150,1,-58)
Side.Position = UDim2.fromOffset(8,54)
Side.BackgroundColor3 = COL.side
Side.BackgroundTransparency = TRP
Side.BorderSizePixel = 0; Side.ZIndex = 11; cR(Side,8)

local SideL = Instance.new("ScrollingFrame", Side)
SideL.Size = UDim2.new(1,-8,1,-8)
SideL.Position = UDim2.fromOffset(4,4)
SideL.BackgroundTransparency = 1; SideL.BorderSizePixel = 0
SideL.ScrollBarThickness = 2; SideL.ScrollBarImageColor3 = COL.brd
SideL.CanvasSize = UDim2.new(0,0,0,300); SideL.ZIndex = 12

local Cont = Instance.new("Frame", Main)
Cont.Size = UDim2.new(1,-172,1,-58)
Cont.Position = UDim2.fromOffset(162,54)
Cont.BackgroundColor3 = COL.bg
Cont.BackgroundTransparency = TRP
Cont.BorderSizePixel = 0; Cont.ZIndex = 11; cR(Cont,8)

local CT = Instance.new("TextLabel", Cont)
CT.Size = UDim2.new(1,-32,0,22)
CT.Position = UDim2.fromOffset(16,14)
CT.BackgroundTransparency = 1; CT.Text = ""
CT.TextColor3 = COL.tx; CT.Font = Enum.Font.GothamBold; CT.TextSize = 16
CT.TextXAlignment = Enum.TextXAlignment.Left; CT.ZIndex = 12

local CSL = Instance.new("ScrollingFrame", Cont)
CSL.Size = UDim2.new(1,-16,1,-50)
CSL.Position = UDim2.fromOffset(8,44)
CSL.BackgroundTransparency = 1; CSL.BorderSizePixel = 0
CSL.ScrollBarThickness = 3; CSL.ScrollBarImageColor3 = COL.brd
CSL.CanvasSize = UDim2.new(0,0,0,2000); CSL.ZIndex = 12

local W = {T={},TB={},Cur=nil,Cnt=0}
function W:Show(n)
    for k,p in pairs(self.T) do p.P.Visible = (k==n) end
    for k,b in pairs(self.TB) do
        local a = (k==n)
        TS:Create(b,TweenInfo.new(0.15),{BackgroundColor3=a and COL.tabOn or COL.side,BackgroundTransparency=a and 0 or 1}):Play()
        local l = b:FindFirstChild("Lbl")
        if l then TS:Create(l,TweenInfo.new(0.15),{TextColor3=a and COL.tx or COL.txD}):Play() end
    end
    self.Cur = n
    CT.Text = n
end

function W:AddTab(cfg)
    local n = cfg.Title
    self.Cnt = self.Cnt + 1
    local i = self.Cnt - 1
    local b = Instance.new("TextButton", SideL)
    b.Size = UDim2.new(1,-4,0,34)
    b.Position = UDim2.new(0,2,0,i*38+2)
    b.BackgroundColor3 = COL.side
    b.BackgroundTransparency = 1; b.BorderSizePixel = 0
    b.Text = ""; b.AutoButtonColor = false; b.ZIndex = 13; cR(b,6)
    local l = Instance.new("TextLabel", b)
    l.Name = "Lbl"
    l.Size = UDim2.new(1,-20,1,0)
    l.Position = UDim2.fromOffset(14,0)
    l.BackgroundTransparency = 1; l.Text = n
    l.TextColor3 = COL.txD; l.Font = Enum.Font.GothamMedium; l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 14
    b.MouseButton1Click:Connect(function() W:Show(n) end)
    local p = Instance.new("Frame", CSL)
    p.Size = UDim2.new(1,0,0,2000)
    p.BackgroundTransparency = 1; p.Visible = false; p.ZIndex = 13
    local t = {P=p, Y=4, _foldList={}}

    function t:_applyFolds()
        if #self._foldList == 0 then return end
        local kids = p:GetChildren()
        for _, f in ipairs(self._foldList) do
            local open = f.hdr:GetAttribute("KZ_Open")
            local startIdx
            for i, k in ipairs(kids) do
                if k == f.hdr then startIdx = i; break end
            end
            if startIdx then
                for i = startIdx + 1, #kids do
                    local k = kids[i]
                    if k:GetAttribute("KZ_Fold") or k:GetAttribute("KZ_Sec") then break end
                    k.Visible = open
                end
            end
        end
    end

    function t:Sec(s)
        local x = Instance.new("TextLabel", p)
        x.Size = UDim2.new(1,-8,0,24)
        x.Position = UDim2.fromOffset(4, self.Y)
        x.BackgroundTransparency = 1
        x.Text = string.upper(s)
        x.TextColor3 = COL.txF; x.Font = Enum.Font.GothamBold; x.TextSize = 11
        x.TextXAlignment = Enum.TextXAlignment.Left; x.ZIndex = 14
        x:SetAttribute("KZ_Sec", true)
        self.Y = self.Y + 28
        self:_applyFolds()
        return self
    end

    function t:Fold(c)
        local state = (c.Default ~= false)
        local hdr = Instance.new("TextButton", p)
        hdr.Size = UDim2.new(1,-8,0,36)
        hdr.Position = UDim2.fromOffset(4, self.Y)
        hdr.BackgroundColor3 = COL.card
        hdr.BackgroundTransparency = TRC - 0.15
        hdr.BorderSizePixel = 0; hdr.Text = ""; hdr.AutoButtonColor = false; hdr.ZIndex = 15
        cR(hdr,8); cS(hdr,COL.brd,1,0.3)
        hdr:SetAttribute("KZ_Fold", true)
        hdr:SetAttribute("KZ_Open", state)
        local bar = Instance.new("Frame", hdr)
        bar.Size = UDim2.new(0,3,1,-10)
        bar.Position = UDim2.fromOffset(6,5)
        bar.BackgroundColor3 = COL.acc; bar.BorderSizePixel = 0; bar.ZIndex = 16; cR(bar,2)
        local arrow = Instance.new("TextLabel", hdr)
        arrow.Size = UDim2.fromOffset(16,36)
        arrow.Position = UDim2.fromOffset(14,0)
        arrow.BackgroundTransparency = 1
        arrow.Text = state and "v" or ">"
        arrow.TextColor3 = COL.acc; arrow.Font = Enum.Font.GothamBlack; arrow.TextSize = 12; arrow.ZIndex = 16
        local lbl = Instance.new("TextLabel", hdr)
        lbl.Size = UDim2.new(1,-40,1,0)
        lbl.Position = UDim2.fromOffset(34,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = c.Title or "Folder"
        lbl.TextColor3 = COL.tx; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 16
        self.Y = self.Y + 40
        table.insert(self._foldList, {hdr = hdr, arrow = arrow})
        hdr.MouseButton1Click:Connect(function()
            local open = not hdr:GetAttribute("KZ_Open")
            hdr:SetAttribute("KZ_Open", open)
            arrow.Text = open and "v" or ">"
            self:_applyFolds()
        end)
        self:_applyFolds()
        return self
    end

    function t:Banner(c)
        local bc = Instance.new("Frame", p)
        bc.Size = UDim2.new(1,-8,0,140)
        bc.Position = UDim2.fromOffset(4, self.Y)
        bc.BackgroundColor3 = COL.card
        bc.BackgroundTransparency = TRC
        bc.BorderSizePixel = 0; bc.ZIndex = 14
        cR(bc,8); cS(bc,COL.brdS,1,0.5)
        local img = Instance.new("ImageLabel", bc)
        img.Size = UDim2.new(1,-12,1,-12)
        img.Position = UDim2.fromOffset(6,6)
        img.BackgroundTransparency = 1
        img.Image = c.Image or IMG
        img.ScaleType = Enum.ScaleType.Crop
        img.ZIndex = 15; cR(img,6)
        self.Y = self.Y + 152
        self:_applyFolds()
        return self
    end
    function t:Btn(c)
        local b = Instance.new("TextButton", p)
        b.Size = UDim2.new(1,-8,0,38)
        b.Position = UDim2.fromOffset(4, self.Y)
        b.BackgroundColor3 = COL.card
        b.BackgroundTransparency = TRC
        b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false; b.ZIndex = 14
        cR(b,8); cS(b,COL.brdS,1,0.5)
        local l = Instance.new("TextLabel", b)
        l.Size = UDim2.new(1,-20,1,0)
        l.Position = UDim2.fromOffset(14,0)
        l.BackgroundTransparency = 1
        l.Text = c.Title
        l.TextColor3 = COL.tx; l.Font = Enum.Font.GothamMedium; l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 15
        b.MouseButton1Click:Connect(function() if c.Callback then pcall(c.Callback) end end)
        self.Y = self.Y + 44
        self:_applyFolds()
        return self
    end
    function t:Par(c)
        local cc = Instance.new("Frame", p)
        cc.Size = UDim2.new(1,-8,0,60)
        cc.Position = UDim2.fromOffset(4, self.Y)
        cc.BackgroundColor3 = COL.card
        cc.BackgroundTransparency = TRC
        cc.BorderSizePixel = 0; cc.ZIndex = 14
        cR(cc,8); cS(cc,COL.brdS,1,0.5)
        local tt = Instance.new("TextLabel", cc)
        tt.Size = UDim2.new(1,-24,0,18)
        tt.Position = UDim2.fromOffset(14,10)
        tt.BackgroundTransparency = 1
        tt.Text = c.Title or ""
        tt.TextColor3 = COL.tx; tt.Font = Enum.Font.GothamBold; tt.TextSize = 13
        tt.TextXAlignment = Enum.TextXAlignment.Left; tt.ZIndex = 15
        local dd = Instance.new("TextLabel", cc)
        dd.Size = UDim2.new(1,-24,0,28)
        dd.Position = UDim2.fromOffset(14,28)
        dd.BackgroundTransparency = 1
        dd.Text = c.Content or ""
        dd.TextColor3 = COL.txD; dd.Font = Enum.Font.Gotham; dd.TextSize = 11
        dd.TextXAlignment = Enum.TextXAlignment.Left
        dd.TextYAlignment = Enum.TextYAlignment.Top
        dd.TextWrapped = true; dd.ZIndex = 15
        self.Y = self.Y + 66
        self:_applyFolds()
        return self
    end
    function t:Tog(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1,-8,0,42)
        row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.card
        row.BackgroundTransparency = TRC
        row.BorderSizePixel = 0; row.ZIndex = 14
        cR(row,8); cS(row,COL.brdS,1,0.5)
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(1,-80,1,0)
        l.Position = UDim2.fromOffset(14,0)
        l.BackgroundTransparency = 1
        l.Text = c.Title or id
        l.TextColor3 = COL.tx; l.Font = Enum.Font.GothamMedium; l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 15
        local st = c.Default or false
        local tr = Instance.new("Frame", row)
        tr.Size = UDim2.fromOffset(40,22)
        tr.Position = UDim2.new(1,-54,0.5,-11)
        tr.BackgroundColor3 = st and COL.acc or COL.off
        tr.BackgroundTransparency = 0.1
        tr.BorderSizePixel = 0; tr.ZIndex = 15; cR(tr,11)
        local k = Instance.new("Frame", tr)
        k.Size = UDim2.fromOffset(16,16)
        k.Position = st and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,3,0.5,-8)
        k.BackgroundColor3 = Color3.fromRGB(255,255,255)
        k.BorderSizePixel = 0; k.ZIndex = 16; cR(k,8)
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 17
        btn.MouseButton1Click:Connect(function()
            st = not st
            TS:Create(k,TweenInfo.new(0.2),{Position=st and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
            TS:Create(tr,TweenInfo.new(0.2),{BackgroundColor3=st and COL.acc or COL.off}):Play()
            if c.Callback then pcall(c.Callback, st) end
            if _G.KZ_SaveConfig then _G.KZ_SaveConfig() end
        end)
        self.Y = self.Y + 48
        self:_applyFolds()
        return self
    end
    function t:Sl(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1,-8,0,56)
        row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.card
        row.BackgroundTransparency = TRC
        row.BorderSizePixel = 0; row.ZIndex = 14
        cR(row,8); cS(row,COL.brdS,1,0.5)
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(1,-80,0,18)
        l.Position = UDim2.fromOffset(14,9)
        l.BackgroundTransparency = 1
        l.Text = c.Title or id
        l.TextColor3 = COL.tx; l.Font = Enum.Font.GothamMedium; l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 15
        local vL = Instance.new("TextLabel", row)
        vL.Size = UDim2.fromOffset(56,18)
        vL.Position = UDim2.new(1,-70,0,9)
        vL.BackgroundTransparency = 1
        vL.Text = tostring(c.Default or c.Min or 0)
        vL.TextColor3 = COL.acc; vL.Font = Enum.Font.GothamBold; vL.TextSize = 12
        vL.TextXAlignment = Enum.TextXAlignment.Right; vL.ZIndex = 15
        local tr = Instance.new("Frame", row)
        tr.Size = UDim2.new(1,-28,0,4)
        tr.Position = UDim2.new(0,14,1,-16)
        tr.BackgroundColor3 = COL.off
        tr.BackgroundTransparency = 0.1
        tr.BorderSizePixel = 0; tr.ZIndex = 15; cR(tr,2)
        local mn, mx = c.Min or 0, c.Max or 100
        local pct = ((c.Default or mn)-mn)/(mx-mn)
        local f = Instance.new("Frame", tr)
        f.Size = UDim2.new(pct,0,1,0)
        f.BackgroundColor3 = COL.acc
        f.BorderSizePixel = 0; f.ZIndex = 16; cR(f,2)
        local k = Instance.new("Frame", tr)
        k.Size = UDim2.fromOffset(14,14)
        k.Position = UDim2.new(pct,-7,0.5,-7)
        k.BackgroundColor3 = Color3.fromRGB(255,255,255)
        k.BorderSizePixel = 0; k.ZIndex = 17; cR(k,7)
        local dg = false
        local function upd(x)
            local a = math.clamp((x-tr.AbsolutePosition.X)/tr.AbsoluteSize.X, 0, 1)
            local v = math.floor(mn+(mx-mn)*a+0.5)
            f.Size = UDim2.new(a,0,1,0)
            k.Position = UDim2.new(a,-7,0.5,-7)
            vL.Text = tostring(v)
            if c.Callback then pcall(c.Callback, v) end
            if _G.KZ_SaveConfig then _G.KZ_SaveConfig() end
        end
        local hb = Instance.new("TextButton", row)
        hb.Size = UDim2.new(1,-20,0,26)
        hb.Position = UDim2.new(0,10,1,-30)
        hb.BackgroundTransparency = 1; hb.Text = ""; hb.ZIndex = 18
        hb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true upd(i.Position.X) end end)
        UIS.InputChanged:Connect(function(i) if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end end)
        self.Y = self.Y + 62
        self:_applyFolds()
        return self
    end
    function t:Drop(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1,-8,0,42)
        row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.card
        row.BackgroundTransparency = TRC
        row.BorderSizePixel = 0; row.ZIndex = 14
        cR(row,8); cS(row,COL.brdS,1,0.5)
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(1,-140,1,0)
        l.Position = UDim2.fromOffset(14,0)
        l.BackgroundTransparency = 1
        l.Text = c.Title or id
        l.TextColor3 = COL.tx; l.Font = Enum.Font.GothamMedium; l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 15
        local vs = c.Values or {}
        local cur = c.Default or vs[1] or "?"
        local vL = Instance.new("TextLabel", row)
        vL.Size = UDim2.new(0,110,1,0)
        vL.Position = UDim2.new(1,-122,0,0)
        vL.BackgroundTransparency = 1
        vL.Text = cur
        vL.TextColor3 = COL.txD; vL.Font = Enum.Font.GothamMedium; vL.TextSize = 11
        vL.TextXAlignment = Enum.TextXAlignment.Right; vL.ZIndex = 15
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 16
        local hd = Instance.new("Frame", p)
        hd.Size = UDim2.new(1,-8,0,0)
        hd.Position = UDim2.fromOffset(4, self.Y + 46)
        hd.BackgroundColor3 = COL.card
        hd.BackgroundTransparency = 0.1
        hd.BorderSizePixel = 0; hd.ClipsDescendants = true; hd.Visible = false; hd.ZIndex = 20
        cR(hd,8); cS(hd,COL.brd,1,0.4)
        for i,v in ipairs(vs) do
            local opt = Instance.new("TextButton", hd)
            opt.Size = UDim2.new(1,-8,0,28)
            opt.Position = UDim2.fromOffset(4,(i-1)*30+4)
            opt.BackgroundColor3 = COL.card
            opt.BackgroundTransparency = 1
            opt.BorderSizePixel = 0; opt.Text = ""; opt.AutoButtonColor = false; opt.ZIndex = 22; cR(opt,5)
            local oL = Instance.new("TextLabel", opt)
            oL.Size = UDim2.new(1,-16,1,0)
            oL.Position = UDim2.fromOffset(12,0)
            oL.BackgroundTransparency = 1
            oL.Text = v
            oL.TextColor3 = COL.txD; oL.Font = Enum.Font.GothamMedium; oL.TextSize = 11
            oL.TextXAlignment = Enum.TextXAlignment.Left; oL.ZIndex = 23
            opt.MouseButton1Click:Connect(function()
                cur = v; vL.Text = v
                TS:Create(hd,TweenInfo.new(0.2),{Size=UDim2.new(1,-8,0,0)}):Play()
                task.delay(0.2, function() hd.Visible = false end)
                if c.Callback then pcall(c.Callback, v) end
                if _G.KZ_SaveConfig then _G.KZ_SaveConfig() end
            end)
        end
        local hH = math.min(#vs*30+8, 150)
        btn.MouseButton1Click:Connect(function()
            if hd.Visible then
                TS:Create(hd,TweenInfo.new(0.2),{Size=UDim2.new(1,-8,0,0)}):Play()
                task.delay(0.2, function() hd.Visible = false end)
            else
                hd.Visible = true
                TS:Create(hd,TweenInfo.new(0.2),{Size=UDim2.new(1,-8,0,hH)}):Play()
            end
        end)
        self.Y = self.Y + 48
        self:_applyFolds()
        return self
    end
    self.T[n] = t
    self.TB[n] = b
    SideL.CanvasSize = UDim2.new(0,0,0, self.Cnt*38+8)
    if not self.Cur then self:Show(n) end
    return t
end

-- ====================================================
-- TABS
-- ====================================================
local TI  = W:AddTab({Title="Information"})
local TSv = W:AddTab({Title="Survivor"})
local TA  = W:AddTab({Title="Aim"})
local TP  = W:AddTab({Title="Parry"})
local TE  = W:AddTab({Title="ESP"})
local TM  = W:AddTab({Title="Misc"})

TI:Banner({Image=IMG})
TI:Par({Title="KALZZ HUB v2", Content="Discord: discord.gg/"..INV})
TI:Btn({Title="Copy Discord Invite", Callback=function() pcall(function() if setclipboard then setclipboard(URL) end end) end})
TI:Btn({Title="Reset Config", Callback=function() pcall(function() if delfile and isfile(CF) then delfile(CF) end end) end})
TI:Btn({Title="Print Remote Cache", Callback=function()
    print("[KZ] Remotes:",
        "ToF="..tostring(RC.tof ~= nil),
        "Veil="..tostring(RC.veil ~= nil),
        "Parry="..tostring(RC.parry ~= nil),
        "FV="..tostring(RC.fastvault ~= nil))
end})

TSv:Sec("Auto Generator")
TSv:Tog("gene_on", {Title="Enable Auto Gen", Default=CFG.gene_on, Callback=function(v) CFG.gene_on=v end})
TSv:Drop("gene_method", {Title="Method", Values={"PERFECT","NORMAL","INSTANT"}, Default=CFG.gene_method, Callback=function(v) CFG.gene_method=v end})
TSv:Sec("Movement")
TSv:Tog("fv", {Title="Always Fast Vault", Default=CFG.fast_vault, Callback=function(v) CFG.fast_vault=v end})

TA:Fold({Title="Silent Aim (ToF)", Default=true})
TA:Tog("tof_on",           {Title="Enable ToF",         Default=CFG.tof_on,           Callback=function(v) CFG.tof_on=v end})
TA:Sl ("tof_fov",          {Title="ToF FOV",            Min=50, Max=800,  Default=CFG.tof_fov,     Callback=function(v) CFG.tof_fov=v end})
TA:Sl ("tof_predict",      {Title="Predict Multiplier", Min=1,  Max=6,    Default=CFG.tof_predict, Callback=function(v) CFG.tof_predict=v end})
TA:Sl ("tof_smooth",       {Title="Smoothing x100",     Min=10, Max=100,  Default=math.floor(CFG.tof_smooth*100), Callback=function(v) CFG.tof_smooth=v/100 end})
TA:Sl ("tof_maxdist",      {Title="Max Distance",       Min=100,Max=2000, Default=CFG.tof_maxdist, Callback=function(v) CFG.tof_maxdist=v end})
TA:Tog("tof_show_fov",     {Title="Show FOV Circle",    Default=CFG.tof_show_fov,     Callback=function(v) CFG.tof_show_fov=v end})
TA:Tog("tof_show_tracer",  {Title="Show Tracer",        Default=CFG.tof_show_tracer,  Callback=function(v) CFG.tof_show_tracer=v end})

TA:Fold({Title="Silent Aim (Veil)", Default=true})
TA:Tog("veil_on",          {Title="Enable Veil",        Default=CFG.veil_on,          Callback=function(v) CFG.veil_on=v end})
TA:Sl ("veil_fov",         {Title="Veil FOV",           Min=50, Max=700,  Default=CFG.veil_fov,      Callback=function(v) CFG.veil_fov=v end})
TA:Sl ("veil_maxdist",     {Title="Max Distance",       Min=100,Max=1500, Default=CFG.veil_maxdist,  Callback=function(v) CFG.veil_maxdist=v end})
TA:Tog("veil_predict",     {Title="Auto Predict",       Default=CFG.veil_predict>0,   Callback=function(v) CFG.veil_predict = v and 1.4 or 0 end})
TA:Sl ("veil_lead",        {Title="Lead Multiplier x10",Min=5,Max=30,    Default=math.floor(CFG.veil_lead*10), Callback=function(v) CFG.veil_lead=v/10 end})
TA:Sl ("veil_speed",       {Title="Spear Speed",        Min=80, Max=400,  Default=CFG.veil_speed,    Callback=function(v) CFG.veil_speed=v end})
TA:Sl ("veil_grav",        {Title="Spear Gravity",      Min=50, Max=250,  Default=CFG.veil_grav,     Callback=function(v) CFG.veil_grav=v end})
TA:Sl ("veil_aura_speed",  {Title="Aura Spear Speed",   Min=80, Max=400,  Default=CFG.veil_aura_speed, Callback=function(v) CFG.veil_aura_speed=v end})
TA:Sl ("veil_aura_grav",   {Title="Aura Spear Gravity", Min=50, Max=250,  Default=CFG.veil_aura_grav,  Callback=function(v) CFG.veil_aura_grav=v end})
TA:Tog("veil_show_fov",    {Title="Show FOV Ring",      Default=CFG.veil_show_fov,    Callback=function(v) CFG.veil_show_fov=v end})
TA:Tog("veil_show_tracker",{Title="Show Tracker",       Default=CFG.veil_show_tracker,Callback=function(v) CFG.veil_show_tracker=v end})

TP:Sec("Auto Parry")
TP:Tog("po", {Title="Enable Auto Parry", Default=CFG.parry_on, Callback=function(v) CFG.parry_on=v end})
TP:Sl("pr", {Title="Radius", Min=1, Max=20, Default=CFG.parry_radius, Callback=function(v) CFG.parry_radius=v end})
TP:Sl("ps", {Title="Sensitivity", Min=0, Max=500, Default=CFG.parry_sensitive, Callback=function(v) CFG.parry_sensitive=v end})
TP:Tog("pc", {Title="Show Circle", Default=CFG.parry_circle, Callback=function(v) CFG.parry_circle=v end})
TP:Tog("pa", {Title="Aggressive", Default=CFG.parry_aggro, Callback=function(v) CFG.parry_aggro=v end})

TE:Sec("ESP Targets")
TE:Tog("ek", {Title="Killer ESP", Default=CFG.esp_k, Callback=function(v) CFG.esp_k=v end})
TE:Tog("es", {Title="Survivor ESP", Default=CFG.esp_s, Callback=function(v) CFG.esp_s=v end})
TE:Tog("eg", {Title="Generator ESP", Default=CFG.esp_g, Callback=function(v) CFG.esp_g=v end})
TE:Sec("Display")
TE:Tog("eo", {Title="Outline Only", Default=CFG.esp_out, Callback=function(v) CFG.esp_out=v end})
TE:Sl("er", {Title="Max Range", Min=100, Max=5000, Default=CFG.esp_range, Callback=function(v) CFG.esp_range=v end})
TE:Sec("Status")
TE:Tog("stun_indicator", {Title="Stun Indicator", Default=CFG.stun_indicator, Callback=function(v) CFG.stun_indicator=v end})

TM:Sec("Visual")
TM:Tog("fog", {Title="No Fog", Default=CFG.fog, Callback=function(v) CFG.fog=v if v then L.FogEnd=100000; L.FogStart=100000 end end})
TM:Tog("br", {Title="Bright Light", Default=CFG.bright, Callback=function(v) CFG.bright=v if v then L.Ambient=Color3.fromRGB(200,200,200); L.Brightness=4; L.OutdoorAmbient=Color3.fromRGB(180,180,180); L.GlobalShadows=false; L.ClockTime=14 end end})
TM:Sec("Camera")
TM:Tog("cam", {Title="FOV Lock", Default=CFG.cam, Callback=function(v) CFG.cam=v end})
TM:Sl("camv", {Title="FOV Value", Min=30, Max=140, Default=CFG.camv, Callback=function(v) CFG.camv=v end})
TM:Sec("Alert")
TM:Tog("alert", {Title="Proximity Alert", Default=CFG.alert, Callback=function(v) CFG.alert=v end})
TM:Sec("Debug")
TM:Btn({Title="Print State (_G)", Callback=function()
    print("ToFAim:", _G.KZ_ToFAimDir)
    print("VeilLook:", _G.KZ_VeilState and _G.KZ_VeilState.lookVector)
end})
TM:Btn({Title="Print Active Loops", Callback=function()
    local out = {}
    for name, t in pairs(Sched._t) do table.insert(out, name.."="..string.format("%.3fs", t.interval)) end
    print("[KZ] Loops: "..table.concat(out, ", "))
end})

W:Show("Information")

-- ====================================================
-- FLOAT BUTTON
-- ====================================================
local FG = Instance.new("ScreenGui")
FG.Name = "KZ_Float"
FG.ResetOnSpawn = false
FG.IgnoreGuiInset = true
FG.DisplayOrder = 2147483647
pcall(function() if gethui then FG.Parent = gethui() else FG.Parent = CG end end)
local FB = Instance.new("TextButton", FG)
FB.Size = UDim2.fromOffset(80,80)
FB.Position = UDim2.new(0,20,0.5,-40)
FB.BackgroundTransparency = 1
FB.Text = "KZ"
FB.TextColor3 = Color3.fromRGB(240,240,250)
FB.TextStrokeTransparency = 0.15
FB.TextStrokeColor3 = Color3.fromRGB(0,0,0)
FB.Font = Enum.Font.GothamBlack
FB.TextSize = 36
FB.AutoButtonColor = false
FB.Active = true
FB.Visible = false
FB.ZIndex = 2147483647
local function TogUI() if Main.Visible then Main.Visible=false else Main.Visible=true; FB.Visible=false end end
MinB.MouseButton1Click:Connect(function() Main.Visible=false; FB.Visible=true end)
ClsB.MouseButton1Click:Connect(function() Main.Visible=false; FB.Visible=true end)
local fD, fS, fP, fM = false, nil, nil, false
FB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then fD=true; fM=false; fS=i.Position; fP=FB.Position end end)
UIS.InputChanged:Connect(function(i) if fD and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-fS if d.Magnitude>8 then fM=true; FB.Position=UDim2.new(fP.X.Scale,fP.X.Offset+d.X,fP.Y.Scale,fP.Y.Offset+d.Y) end end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then if fD and not fM then TogUI() end; fD=false; task.delay(0.1, function() fM=false end) end end)
UIS.InputBegan:Connect(function(i,g) if g then return end if i.KeyCode==Enum.KeyCode.RightShift then TogUI() end end)

-- ====================================================
-- FAST VAULT
-- ====================================================
pcall(function()
    local lastFV = 0
    local FV_ANIM_ID = "79965656177566"
    local function onAnim(t)
        if not CFG.fast_vault or not t or not t.Animation then return end
        local n = (t.Animation.Name or ""):lower()
        local id = tostring(t.Animation.AnimationId or "")
        if n:find("vault") or n:find("window") or n:find("pallet") or n:find("climb") or id:find(FV_ANIM_ID) then
            local now = os.clock()
            if now - lastFV < 0.1 then return end
            lastFV = now
            pcall(function() t:AdjustSpeed(1.7) end)
            if RC.fastvault then pcall(function() RC.fastvault:FireServer() end) end
        end
    end
    LP.CharacterAdded:Connect(function(c)
        task.wait(1)
        local hum = c:FindFirstChildOfClass("Humanoid")
        local anim = hum and hum:FindFirstChildOfClass("Animator")
        if anim then anim.AnimationPlayed:Connect(onAnim) end
    end)
    if LP.Character then task.spawn(function()
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        local anim = hum and hum:FindFirstChildOfClass("Animator")
        if anim then anim.AnimationPlayed:Connect(onAnim) end
    end) end
end)

-- ====================================================
-- AUTO GENERATOR (UI-based)
-- ====================================================
pcall(function()
    local G = { last = 0, prevCheck = false }

    local function getCheck()
        local sg = PG:FindFirstChild("SkillCheckPromptGui")
        if not sg then return nil end
        local chk = sg:FindFirstChild("Check")
        if not chk then return nil end
        return { Check=chk, Line=chk:FindFirstChild("Line"), Goal=chk:FindFirstChild("Goal") }
    end

    local function getAction()
        local mob = PG:FindFirstChild("Survivor-mob")
        if not mob then return nil end
        local ctrl = mob:FindFirstChild("Controls")
        if not ctrl then return nil end
        return ctrl:FindFirstChild("action") or ctrl:FindFirstChildWhichIsA("ImageButton")
    end

    local function pressAction()
        local a = getAction()
        if not a then return end
        local now = os.clock()
        if now - G.last < 0.033 then return end
        G.last = now
        pcall(function() if a:IsA("GuiButton") then a:Activate() end end)
        if typeof(firesignal)=="function" then
            pcall(function() firesignal(a.MouseButton1Down) end)
        end
    end

    local function forcePerfect()
        local c = getCheck()
        if not c or not c.Check.Visible or not c.Line or not c.Goal then return end
        c.Line.Rotation = (tonumber(c.Goal.Rotation) or 0) + 109
        pressAction()
    end

    Sched:Add("AutoGen", function()
        if not CFG.gene_on then G.prevCheck = false; return end
        local c = getCheck()
        if not c then G.prevCheck = false; return end
        local vis = c.Check.Visible

        if vis and not G.prevCheck and CFG.gene_method == "INSTANT" then
            forcePerfect()
        end
        G.prevCheck = vis

        if vis and c.Line and c.Goal then
            local lineRot = tonumber(c.Line.Rotation) or 0
            local goalRot = tonumber(c.Goal.Rotation) or 0
            local diff = lineRot - goalRot
            if diff >= 102 and diff <= 116 then
                if CFG.gene_method == "PERFECT" or CFG.gene_method == "NORMAL" then
                    pressAction()
                end
            end
        end
    end, 90)
end)

-- ====================================================
-- SILENT AIM ToF (state only)
-- ====================================================
pcall(function()
    local S = { lookVector=nil, target=nil, targetPart=nil, velHistory={}, locked=false }
    _G.KZ_ToFAimDir = nil
    _G.KZ_ToFState = S

    local function getRoot(c)
        if not c then return nil end
        return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or c.PrimaryPart
    end
    local function getHum(c) return c and c:FindFirstChildOfClass("Humanoid") end
    local function getVel(char)
        local root = getRoot(char)
        if not root then return Vector3.zero end
        local now = os.clock()
        local last = S.velHistory[char]
        local measured = Vector3.zero
        if last and (now - last.t) > 0.02 then
            measured = (root.Position - last.pos) / (now - last.t)
            if measured.Magnitude > 150 then measured = last.smooth or Vector3.zero end
        end
        local smooth = last and last.smooth or measured
        smooth = smooth:Lerp(measured, CFG.tof_smooth or 0.55)
        S.velHistory[char] = { pos=root.Position, t=now, smooth=smooth }
        return Vector3.new(smooth.X, 0, smooth.Z)
    end
    P.PlayerRemoving:Connect(function(p) if p.Character then S.velHistory[p.Character]=nil end end)

    local function getBestTarget()
        if not Cam then Cam = WS.CurrentCamera end
        if not Cam then return nil end
        local center = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
        local best, bestScore = nil, CFG.tof_fov or 380
        local myRoot = getRoot(LP.Character)
        if not myRoot then return nil end
        for _, plr in ipairs(P:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local ch = plr.Character
                local hum = getHum(ch)
                if hum and hum.Health > 0 and isKiller(ch) then
                    local part = getRoot(ch)
                    if part then
                        local sp, on = Cam:WorldToViewportPoint(part.Position)
                        if on and sp.Z > 0 then
                            local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            local wd = (part.Position - myRoot.Position).Magnitude
                            if wd <= (CFG.tof_maxdist or 900) and sd < bestScore then
                                bestScore = sd
                                best = { part=part, plr=plr, char=ch }
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    local function updateAim()
        if not CFG.tof_on then S.lookVector=nil; S.locked=false; _G.KZ_ToFAimDir=nil; return end
        local myRoot = getRoot(LP.Character)
        if not myRoot then S.lookVector=nil; _G.KZ_ToFAimDir=nil; return end
        local t = getBestTarget()
        if not t then S.lookVector=nil; S.locked=false; _G.KZ_ToFAimDir=nil; return end
        local origin = myRoot.Position + Vector3.new(0, 1.5, 0)
        local vel = getVel(t.char)
        local dist = (t.part.Position - origin).Magnitude
        local ft = math.clamp(dist / 200, 0.03, 0.4)
        local predicted = t.part.Position + (vel * ft * (CFG.tof_predict or 3.0))
        local dir = predicted - origin
        if dir.Magnitude > 0.5 then
            S.lookVector = dir.Unit
            S.target = t.plr
            S.targetPart = t.part
            S.locked = true
            _G.KZ_ToFAimDir = S.lookVector
        else S.lookVector=nil; S.locked=false; _G.KZ_ToFAimDir=nil end
    end

    local V = {}
    pcall(function()
        if typeof(Drawing) ~= "table" or not Drawing.new then return end
        V.fov = Drawing.new("Circle"); V.fov.Thickness=1.5; V.fov.NumSides=64; V.fov.Filled=false; V.fov.Visible=false
        V.fovO = Drawing.new("Circle"); V.fovO.Thickness=3; V.fovO.NumSides=64; V.fovO.Filled=false; V.fovO.Color=Color3.new(0,0,0); V.fovO.Visible=false
        V.tracer = Drawing.new("Line"); V.tracer.Thickness=1.4; V.tracer.Visible=false
        V.dot = Drawing.new("Circle"); V.dot.Thickness=1; V.dot.NumSides=16; V.dot.Filled=true; V.dot.Radius=4; V.dot.Visible=false
    end)
    local function updateVis()
        if not V.fov then return end
        local cam = WS.CurrentCamera; if not cam then return end
        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        local radius = CFG.tof_fov or 380
        if CFG.tof_show_fov and CFG.tof_on then
            local col = S.locked and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,70,70)
            V.fov.Position=center; V.fov.Radius=radius; V.fov.Color=col; V.fov.Transparency=0.75; V.fov.Visible=true
            V.fovO.Position=center; V.fovO.Radius=radius+1.5; V.fovO.Transparency=0.4; V.fovO.Visible=true
        else V.fov.Visible=false; V.fovO.Visible=false end
        if CFG.tof_show_tracer and S.locked and S.targetPart then
            local sp, on = cam:WorldToViewportPoint(S.targetPart.Position)
            if on and sp.Z > 0 then
                V.tracer.From=center; V.tracer.To=Vector2.new(sp.X, sp.Y); V.tracer.Color=Color3.fromRGB(80,255,140); V.tracer.Transparency=0.55; V.tracer.Visible=true
                V.dot.Position=Vector2.new(sp.X, sp.Y); V.dot.Color=Color3.fromRGB(80,255,140); V.dot.Visible=true
            else V.tracer.Visible=false; V.dot.Visible=false end
        else V.tracer.Visible=false; V.dot.Visible=false end
    end
    Sched:Add("ToF_Aim", function() Cam = WS.CurrentCamera; updateAim() end, 90)
    Sched:Add("ToF_Vis", updateVis, 30)
    UIS.InputBegan:Connect(function(i,g) if g then return end if i.KeyCode==Enum.KeyCode.V then CFG.tof_on = not CFG.tof_on end end)
    LP.CharacterAdded:Connect(function() S.lookVector=nil; S.target=nil; S.targetPart=nil; S.locked=false; _G.KZ_ToFAimDir=nil; table.clear(S.velHistory) end)
end)

-- ====================================================
-- SILENT AIM Veil (state only)
-- ====================================================
pcall(function()
    local VS = { lookVector=nil, target=nil, velHistory={} }
    _G.KZ_VeilState = VS

    local function getRoot(c)
        if not c then return nil end
        return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or c.PrimaryPart
    end
    local function getHum(c) return c and c:FindFirstChildOfClass("Humanoid") end
    local function getVel(char)
        local root = getRoot(char)
        if not root then return Vector3.zero end
        local now = os.clock()
        local last = VS.velHistory[char]
        local measured = Vector3.zero
        if last and (now - last.t) > 0.02 then
            measured = (root.Position - last.pos) / (now - last.t)
            if measured.Magnitude > 150 then measured = last.smooth or Vector3.zero end
        end
        local smooth = last and last.smooth or measured
        smooth = smooth:Lerp(measured, 0.65)
        VS.velHistory[char] = { pos=root.Position, t=now, smooth=smooth }
        return Vector3.new(smooth.X, 0, smooth.Z)
    end
    P.PlayerRemoving:Connect(function(p) if p.Character then VS.velHistory[p.Character]=nil end end)

    local function isLocalKiller()
        local ch = LP.Character
        if not ch then return false end
        for _, a in ipairs({"Role","role","Team","team","Type","type"}) do
            local v = LP:GetAttribute(a) or ch:GetAttribute(a)
            if type(v)=="string" then
                local lv=v:lower()
                if lv:find("killer") then return true end
                if lv:find("survivor") then return false end
            end
        end
        if LP.Team and LP.Team.Name then
            local tn = LP.Team.Name:lower()
            if tn:find("killer") then return true end
            if tn:find("survivor") then return false end
        end
        local tl = ch:FindFirstChildOfClass("Tool")
        if tl then
            local n = tl.Name:lower()
            if n:find("knife") or n:find("sword") or n:find("weapon") or n:find("veil") or n:find("spear") then
                return true
            end
        end
        return _G.KZ_isKiller and _G.KZ_isKiller(ch) or false
    end

    local function solvePitch(v0, g, d, dy)
        d = math.max(d, 0.1)
        local s2 = v0 * v0
        local disc = s2 * s2 - g * (g * d * d + 2 * dy * s2)
        if disc < 0 then disc = 0 end
        local tanTheta = (s2 - math.sqrt(disc)) / (g * d)
        local theta = math.atan(tanTheta)
        local t = d / (v0 * math.cos(theta))
        return theta, t
    end

    local function updateVeil()
        if not CFG.veil_on or not isLocalKiller() then
            VS.lookVector = nil
            VS.target = nil
            return
        end
        local cam = WS.CurrentCamera
        if not cam then return end
        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local best, bestScore = nil, CFG.veil_fov or 280
        local maxDist = CFG.veil_maxdist or 500

        for _, plr in ipairs(P:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local ch = plr.Character
                local hum = getHum(ch)
                if hum and hum.Health > 0 and not isKiller(ch) then
                    local part = getRoot(ch)
                    if part then
                        local dist = (part.Position - hrp.Position).Magnitude
                        if dist <= maxDist then
                            local sp, on = cam:WorldToViewportPoint(part.Position)
                            if on and sp.Z > 0 then
                                local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if sd < bestScore then
                                    bestScore = sd
                                    best = { part=part, char=ch, dist=dist }
                                end
                            end
                        end
                    end
                end
            end
        end

        if not best then
            VS.lookVector = nil
            VS.target = nil
            return
        end

        local tp = best.part.Position
        local hand = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
        local origin = (hand and hand:IsA("BasePart")) and hand.Position or hrp.Position
        local dir = tp - origin
        local dist = dir.Magnitude

        local v0 = CFG.veil_speed or 165
        local g = CFG.veil_grav or 103

        if CFG.veil_predict and CFG.veil_predict > 0 then
            local vel = getVel(best.char)
            if vel.Magnitude > 0.5 then
                local h0 = Vector3.new(dir.X, 0, dir.Z)
                local _, tf = solvePitch(v0, g, h0.Magnitude, dir.Y)
                local ping = 0.08
                pcall(function() ping = math.clamp(LP:GetNetworkPing(), 0, 0.35) end)
                local leadT = tf + 0.10 + ping
                local lead = vel * leadT * (CFG.veil_lead or 1.4)
                local maxLead = math.clamp(dist * 0.5, 3, 45)
                if lead.Magnitude > maxLead then lead = lead.Unit * maxLead end
                tp = tp + lead
            end
        end

        local adir = tp - origin
        local ah = Vector3.new(adir.X, 0, adir.Z)
        local ahDist = ah.Magnitude
        local pitch = solvePitch(v0, g, ahDist, adir.Y)

        if ahDist > 0.001 then
            VS.lookVector = ah.Unit * math.cos(pitch) + Vector3.new(0, math.sin(pitch), 0)
        else
            VS.lookVector = adir.Unit
        end
        VS.target = best.char
        _G.KZ_VeilState = VS
    end

    Sched:Add("Veil_Aim", updateVeil, 60)
end)

-- ====================================================
-- AUTO PARRY
-- ====================================================
pcall(function()
    local lastParry = 0
    local busyAnim = false
    local attached = {}

    local function doParry()
        if busyAnim then return end
        local now = os.clock()
        if now - lastParry < ((CFG.parry_aggro and 0.04) or 0.08) then return end
        lastParry = now
        if RC.parry then
            for i=1,3 do
                pcall(function() RC.parry:FireServer() end)
                if i < 3 then task.wait(0.005) end
            end
        end
        pcall(function()
            local mob = PG:FindFirstChild("Survivor-mob")
            if mob then
                local ctrl = mob:FindFirstChild("Controls")
                if ctrl then
                    local btn = ctrl:FindFirstChild("action") or ctrl:FindFirstChildWhichIsA("ImageButton")
                    if btn and typeof(firesignal)=="function" then
                        firesignal(btn.MouseButton1Down)
                        task.wait(0.005)
                        firesignal(btn.MouseButton1Up)
                    end
                end
            end
        end)
    end

    local function bindChar(ch)
        if not ch or attached[ch] then return end
        attached[ch] = true
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local anim = hum:FindFirstChildOfClass("Animator")
        if not anim then
            task.delay(0.5, function() attached[ch]=nil; bindChar(ch) end)
            return
        end
        anim.AnimationPlayed:Connect(function(t)
            if not CFG.parry_on or busyAnim or not t or not t.Animation then return end
            local id = tostring(t.Animation.AnimationId or ""):match("(%d+)") or ""
            if not PID[id] then return end
            local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local enRoot = ch:FindFirstChild("HumanoidRootPart")
            if myRoot and enRoot then
                local d = (myRoot.Position - enRoot.Position).Magnitude
                if d > 0 and d <= (CFG.parry_radius or 12) + (CFG.parry_sensitive or 200)*0.01 then
                    doParry()
                end
            end
        end)
    end

    local function scan()
        for _, plr in ipairs(P:GetPlayers()) do
            if plr ~= LP and plr.Character then bindChar(plr.Character) end
        end
    end
    scan()
    task.spawn(function() while Main.Parent do task.wait(1.5); scan() end end)
    WS.DescendantAdded:Connect(function(o)
        if o:IsA("Model") and o ~= LP.Character then task.wait(0.3); bindChar(o) end
    end)

    Sched:Add("Parry_Scan", function()
        if not CFG.parry_on then return end
        for _, plr in ipairs(P:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local anim = hum and hum:FindFirstChildOfClass("Animator")
                if anim then
                    local ok, tracks = pcall(function() return anim:GetPlayingAnimationTracks() end)
                    if ok and tracks then
                        for _, t in ipairs(tracks) do
                            if t and t.Animation then
                                local id = tostring(t.Animation.AnimationId or ""):match("(%d+)") or ""
                                if PID[id] then
                                    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                                    local enRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                                    if myRoot and enRoot then
                                        local d = (myRoot.Position - enRoot.Position).Magnitude
                                        if d > 0 and d <= (CFG.parry_radius or 12)+2 then doParry(); return end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end, 30)

    LP.CharacterAdded:Connect(function(c)
        task.wait(1)
        local hum = c:FindFirstChildOfClass("Humanoid")
        local anim = hum and hum:FindFirstChildOfClass("Animator")
        if anim then
            anim.AnimationPlayed:Connect(function(t)
                if not t or not t.Animation then return end
                local n = (t.Animation.Name or ""):lower()
                if n:find("vault") or n:find("window") or n:find("pallet") or n:find("climb") then
                    busyAnim = true
                    task.delay(0.85, function() busyAnim = false end)
                end
            end)
        end
    end)

    UIS.InputBegan:Connect(function(i,g) if g then return end if i.KeyCode==Enum.KeyCode.P then doParry() end end)

    -- Parry Circle
    local base = Instance.new("Part")
    base.Name = "KZ_ParryCircle"
    base.Size = Vector3.new(1, 0.05, 1)
    base.Anchored = true
    base.CanCollide = false
    base.CanQuery = false
    base.CanTouch = false
    base.CastShadow = false
    base.Material = Enum.Material.SmoothPlastic
    base.Transparency = 1
    base.Parent = WS
    local sg = Instance.new("SurfaceGui", base)
    sg.Face = Enum.NormalId.Top
    sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    sg.PixelsPerStud = 40
    sg.LightInfluence = 0
    sg.ZOffset = 1
    local fill = Instance.new("Frame", sg)
    fill.AnchorPoint = Vector2.new(0.5,0.5); fill.Position = UDim2.fromScale(0.5,0.5); fill.Size = UDim2.fromScale(0.94,0.94)
    fill.BackgroundColor3 = COL.acc; fill.BackgroundTransparency = 1; fill.BorderSizePixel = 0
    cR(fill, 999)
    local ring = Instance.new("Frame", sg)
    ring.AnchorPoint = Vector2.new(0.5,0.5); ring.Position = UDim2.fromScale(0.5,0.5); ring.Size = UDim2.fromScale(0.96,0.96)
    ring.BackgroundTransparency = 1; ring.BorderSizePixel = 0; cR(ring, 999)
    local s1 = Instance.new("UIStroke", ring)
    s1.Thickness = 5; s1.Color = COL.acc; s1.Transparency = 1
    s1.LineJoinMode = Enum.LineJoinMode.Round
    local ring2 = Instance.new("Frame", sg)
    ring2.AnchorPoint = Vector2.new(0.5,0.5); ring2.Position = UDim2.fromScale(0.5,0.5); ring2.Size = UDim2.fromScale(0.88,0.88)
    ring2.BackgroundTransparency = 1; ring2.BorderSizePixel = 0; cR(ring2, 999)
    local s2 = Instance.new("UIStroke", ring2)
    s2.Thickness = 2; s2.Color = Color3.fromRGB(180,210,255); s2.Transparency = 1
    s2.LineJoinMode = Enum.LineJoinMode.Round
    local SC, DC = COL.acc, Color3.fromRGB(230,90,90)
    local curC, fIn, pl2 = SC, 0, 0
    local function getR(m) if not m then return nil end return m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart end
    local prev = os.clock()
    Sched:Add("Parry_Circle", function()
        local now = os.clock()
        local dt = now - prev
        prev = now
        pl2 = pl2 + dt
        local hrp = LP.Character and getR(LP.Character)
        local act = CFG.parry_on and CFG.parry_circle and hrp
        if act then fIn = math.min(1, fIn+dt*5) else fIn = math.max(0, fIn-dt*5) end
        if fIn <= 0.001 then base.Transparency = 1 return end
        if act then
            local hasE = false
            for _, pl in ipairs(P:GetPlayers()) do
                if pl ~= LP and pl.Character and isKiller(pl.Character) then
                    local er = getR(pl.Character)
                    if er then
                        local hu = pl.Character:FindFirstChildOfClass("Humanoid")
                        if hu and hu.Health > 0 and (er.Position - hrp.Position).Magnitude <= CFG.parry_radius then hasE = true; break end
                    end
                end
            end
            curC = curC:Lerp(hasE and DC or SC, math.min(1, dt*8))
            local r = CFG.parry_radius * 2
            base.Size = Vector3.new(r, 0.05, r)
            base.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2.95, 0))
            local p = math.sin(pl2 * (hasE and 7 or 4)) * (hasE and 0.14 or 0.06)
            s1.Color = curC
            s2.Color = curC:Lerp(Color3.fromRGB(255,255,255), 0.5)
            fill.BackgroundColor3 = curC
            s1.Transparency = math.clamp(1 - (fIn * ((hasE and 0.88 or 0.72) + p)), 0, 1)
            s2.Transparency = math.clamp(1 - (fIn * ((hasE and 0.65 or 0.42) + p*0.6)), 0, 1)
            fill.BackgroundTransparency = math.clamp(1 - (fIn * ((hasE and 0.08 or 0.05) + p*0.3)), 0, 1)
        else
            s1.Transparency = math.clamp(1 - (fIn * 0.72), 0, 1)
            s2.Transparency = math.clamp(1 - (fIn * 0.42), 0, 1)
            fill.BackgroundTransparency = math.clamp(1 - (fIn * 0.05), 0, 1)
        end
    end, 60)
end)

-- ====================================================
-- ESP
-- ====================================================
pcall(function()
    local eD, eG = {}, {}
    local ep = GUI
    local function dESP(pl)
        local d = eD[pl]; if not d then return end
        pcall(function() if d.hl then d.hl:Destroy() end end)
        eD[pl] = nil
    end
    local function isGD(o)
        local p = o:FindFirstChild("Progress") or o:GetAttribute("Progress")
        if typeof(p)=="number" and p >= 100 then return true end
        if o:GetAttribute("Completed") or o:GetAttribute("Finished") then return true end
        return false
    end
    local function isG(o)
        if not o or not o.Parent then return false end
        if not (o:IsA("Model") or o:IsA("BasePart")) then return false end
        local n = o.Name:lower()
        return n:find("generator") or n:find("fuse")
    end
    Sched:Add("ESP_Players", function()
        local mr = rtp(LP.Character)
        local mp = mr and mr.Position or Cam.CFrame.Position
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= LP and pl.Character then
                local ch = pl.Character
                local hrp = rtp(ch)
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local isK = isKiller(ch)
                    local en = (isK and CFG.esp_k) or (not isK and CFG.esp_s)
                    if en and (hrp.Position - mp).Magnitude <= CFG.esp_range then
                        if not eD[pl] then
                            local hl = Instance.new("Highlight", ep)
                            hl.Name = "KZ_HL"
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            eD[pl] = {hl = hl}
                        end
                        local d = eD[pl]
                        local cl = isK and CK or CS
                        d.hl.Adornee = ch
                        d.hl.FillColor = cl
                        d.hl.OutlineColor = cl
                        d.hl.FillTransparency = CFG.esp_out and 1 or 0.55
                        d.hl.OutlineTransparency = 0
                        d.hl.Enabled = true
                    else
                        if eD[pl] and eD[pl].hl then eD[pl].hl.Enabled = false end
                    end
                else dESP(pl) end
            elseif eD[pl] then dESP(pl) end
        end
    end, 5)
    local genCache, genT = {}, 0
    Sched:Add("ESP_Gen", function()
        local now = os.clock()
        if now - genT > 5 then
            genCache = {}
            for _, o in ipairs(WS:GetDescendants()) do if isG(o) then table.insert(genCache, o) end end
            genT = now
        end
        if CFG.esp_g then
            for _, o in ipairs(genCache) do
                if o.Parent then
                    if isGD(o) then
                        if eG[o] then pcall(function() eG[o]:Destroy() end); eG[o]=nil end
                    elseif not eG[o] then
                        local hl = Instance.new("Highlight", ep)
                        hl.Name = "KZ_GEN"
                        hl.Adornee = o
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillColor = CGr
                        hl.FillTransparency = CFG.esp_out and 1 or 0.6
                        hl.OutlineColor = CGr
                        hl.OutlineTransparency = 0
                        eG[o] = hl
                    end
                end
            end
            for o, hl in pairs(eG) do
                if not o.Parent or isGD(o) then pcall(function() hl:Destroy() end); eG[o]=nil end
            end
        else
            for _, hl in pairs(eG) do pcall(function() hl:Destroy() end) end
            eG = {}
        end
    end, 2)
    P.PlayerRemoving:Connect(function(p) dESP(p) end)
end)

-- ====================================================
-- PROXIMITY ALERT
-- ====================================================
pcall(function()
    local ag = Instance.new("ScreenGui")
    ag.Name = "KZ_Alert"
    ag.ResetOnSpawn = false
    ag.IgnoreGuiInset = true
    ag.DisplayOrder = 1000001
    ag.Parent = PG
    local al = Instance.new("TextLabel", ag)
    al.Size = UDim2.fromOffset(260,60)
    al.Position = UDim2.new(0.5,-130,0.14,0)
    al.BackgroundTransparency = 1; al.Text = ""
    al.TextColor3 = Color3.fromRGB(240,210,140)
    al.Font = Enum.Font.GothamBlack; al.TextSize = 34
    al.TextStrokeTransparency = 0; al.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    al.Visible = false
    local as = Instance.new("TextLabel", ag)
    as.Size = UDim2.fromOffset(260,16)
    as.Position = UDim2.new(0.5,-130,0.14,58)
    as.BackgroundTransparency = 1; as.Text = ""
    as.TextColor3 = Color3.fromRGB(230,230,240)
    as.Font = Enum.Font.GothamBold; as.TextSize = 11
    as.TextStrokeTransparency = 0.3; as.Visible = false
    Sched:Add("Alert", function()
        if not CFG.alert then al.Visible=false; as.Visible=false; return end
        local mr = rtp(LP.Character)
        if not mr then al.Visible=false; as.Visible=false; return end
        local cl = math.huge
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= LP and pl.Character then
                local ch = pl.Character
                local hrp = rtp(ch)
                if hrp and isKiller(ch) then
                    local hu = ch:FindFirstChildOfClass("Humanoid")
                    if hu and hu.Health > 0 then
                        local d = (hrp.Position - mr.Position).Magnitude
                        if d < cl then cl = d end
                    end
                end
            end
        end
        if cl < math.huge then
            local t, c
            if cl <= 10 then t="!!!"; c=Color3.fromRGB(255,90,90)
            elseif cl <= 17 then t="!!"; c=Color3.fromRGB(255,160,100)
            elseif cl <= 25 then t="!"; c=Color3.fromRGB(255,220,130)
            else al.Visible=false; as.Visible=false; return end
            al.Text = t; al.TextColor3 = c; al.Visible = true
            as.Text = string.format("KILLER %.1f studs", cl); as.Visible = true
        else al.Visible=false; as.Visible=false end
    end, 5)
end)

-- ====================================================
-- STUN INDICATOR
-- ====================================================
pcall(function()
    local stunBB = {}
    local function isStunned(hum, char)
        if not hum then return false end
        if hum.WalkSpeed <= 4 and not hum.Sit then return true end
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Stunned or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Ragdoll then return true end
        if char:GetAttribute("Stunned") or char:GetAttribute("stun") or char:GetAttribute("IsStunned") then return true end
        return false
    end
    local function createBB(root)
        local bb = Instance.new("BillboardGui")
        bb.Name = "KZ_Stun"
        bb.Size = UDim2.fromOffset(100,28)
        bb.StudsOffset = Vector3.new(0,4.2,0)
        bb.AlwaysOnTop = true
        bb.Adornee = root
        bb.Parent = PG
        local bg = Instance.new("Frame", bb)
        bg.Size = UDim2.new(1,0,1,0)
        bg.BackgroundColor3 = Color3.fromRGB(20,20,25)
        bg.BackgroundTransparency = 0.25
        bg.BorderSizePixel = 0; cR(bg, 6)
        local lbl = Instance.new("TextLabel", bg)
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1; lbl.Text = "STUNNED"
        lbl.TextColor3 = Color3.fromRGB(255,220,40)
        lbl.TextStrokeTransparency = 0.3
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
        local barBG = Instance.new("Frame", bg)
        barBG.Size = UDim2.new(0.8,0,0,3)
        barBG.Position = UDim2.new(0.1,0,1,-6)
        barBG.BackgroundColor3 = Color3.fromRGB(40,40,50)
        barBG.BorderSizePixel = 0; cR(barBG, 999)
        local bar = Instance.new("Frame", barBG)
        bar.Name = "Bar"
        bar.Size = UDim2.new(1,0,1,0)
        bar.BackgroundColor3 = Color3.fromRGB(255,200,40)
        bar.BorderSizePixel = 0; cR(bar, 999)
        return bb
    end
    Sched:Add("Stun_Update", function()
        if not CFG.stun_indicator then
            for plr, bb in pairs(stunBB) do pcall(function() bb:Destroy() end); stunBB[plr]=nil end
            return
        end
        for _, plr in ipairs(P:GetPlayers()) do
            if plr == LP or not plr.Character or not isKiller(plr.Character) then
                if stunBB[plr] then pcall(function() stunBB[plr]:Destroy() end); stunBB[plr]=nil end
            else
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and root then
                    if isStunned(hum, plr.Character) then
                        if not stunBB[plr] then stunBB[plr] = createBB(root) end
                        local bar = stunBB[plr]:FindFirstChild("Bar", true)
                        if bar then local t = (os.clock()%1.2)/1.2; bar.Size = UDim2.new(1-t,0,1,0) end
                    else
                        if stunBB[plr] then pcall(function() stunBB[plr]:Destroy() end); stunBB[plr]=nil end
                    end
                end
            end
        end
    end, 10)
    P.PlayerRemoving:Connect(function(plr) if stunBB[plr] then pcall(function() stunBB[plr]:Destroy() end); stunBB[plr]=nil end end)
end)

-- ====================================================
-- FOV LOCK
-- ====================================================
pcall(function()
    Sched:Add("FOV_Lock", function()
        pcall(function()
            if not CFG.cam then return end
            local c = WS.CurrentCamera
            if not c or not c.Parent then return end
            if math.abs(c.FieldOfView - (CFG.camv or 90)) > 0.5 then
                c.FieldOfView = CFG.camv or 90
            end
        end)
    end, 20)
    Sched:Add("Cam_Watch", function()
        pcall(function()
            local c = WS.CurrentCamera
            if c and c ~= Cam then Cam = c end
        end)
    end, 5)
end)

-- ====================================================
-- VISUAL PERSIST
-- ====================================================
Sched:Add("Visual_Persist", function()
    if not GUI.Parent then
        pcall(function() if gethui then GUI.Parent = gethui() else GUI.Parent = CG end end)
    end
    if CFG.bright then
        pcall(function()
            L.Ambient = Color3.fromRGB(200,200,200)
            L.Brightness = 4
            L.OutdoorAmbient = Color3.fromRGB(180,180,180)
            L.GlobalShadows = false
            L.ClockTime = 14
        end)
    end
    if CFG.fog then pcall(function() L.FogEnd = 100000; L.FogStart = 100000 end) end
end, 1)

-- ====================================================
-- UNIFIED NAMECALL HOOK (Kick + ToF + Veil) — CRASH-PROOF
-- ====================================================
pcall(function()
    if type(hookmetamethod) ~= "function" or type(newcclosure) ~= "function" then
        warn("[KALZZ] hookmetamethod tidak tersedia")
        return
    end

    local OLD
    OLD = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        -- Ambil method (pcall wrap)
        local m
        pcall(function() m = getnamecallmethod() end)
        if not m then return OLD(self, ...) end

        -- Kick protection
        if m == "Kick" then
            if self == LP then return nil end
            return OLD(self, ...)
        end

        -- Hanya intercept FireServer
        if m ~= "FireServer" then
            return OLD(self, ...)
        end

        -- Preserve args dengan table.pack
        local args = table.pack(...)
        local n = args.n

        -- Self harus Instance valid
        if type(self) ~= "userdata" and type(self) ~= "table" then
            return OLD(self, table.unpack(args, 1, n))
        end

        -- ==== JALUR 1: ToF (pakai remote cache) ====
        if CFG.tof_on and RC.tof and self == RC.tof and typeof(_G.KZ_ToFAimDir) == "Vector3" then
            for i = 1, n do
                local v = args[i]
                if typeof(v) == "Vector3" and v.Magnitude <= 5 then
                    args[i] = _G.KZ_ToFAimDir
                    break
                end
            end
        end

        -- ==== JALUR 2: Veil (pakai remote cache) ====
        if CFG.veil_on and RC.veil and self == RC.veil
            and _G.KZ_VeilState and typeof(_G.KZ_VeilState.lookVector) == "Vector3" then
            if typeof(args[1]) == "Vector3" then
                args[1] = _G.KZ_VeilState.lookVector
            end
        end

        return OLD(self, table.unpack(args, 1, n))
    end))
    print("[KALZZ] unified hook installed (Kick + ToF + Veil, crash-proof)")
end)

print("[KALZZ HUB v2] Loaded")
