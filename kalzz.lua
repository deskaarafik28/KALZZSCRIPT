--[[ KALZZ HUB v10 | Full ]]
pcall(function() local o; o=hookmetamethod(game,"__namecall",newcclosure(function(s,...) if getnamecallmethod()=="Kick" and s==game:GetService("Players").LocalPlayer then return end return o(s,...) end)) end)

local P = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RSvc = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local L = game:GetService("Lighting")
local TS = game:GetService("TweenService")
local CG = game:GetService("CoreGui")
local HS = game:GetService("HttpService")
local LP = P.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local Cam = WS.CurrentCamera
local INV = "dCYTep9cY"
local URL = "https://discord.gg/"..INV
local IMG = "rbxassetid://134442738689157"

pcall(function()
    for _,pr in ipairs({CG,PG}) do for _,g in ipairs(pr:GetChildren()) do if g.Name:find("Kalzz") or g.Name:find("KZ_") then pcall(function() g:Destroy() end) end end end
    for _,o in ipairs(WS:GetChildren()) do if o.Name:sub(1,3)=="KZ_" then pcall(function() o:Destroy() end) end end
end)

local DEF = {gene_on=true,gene_method="PERFECT",gene_min=102,gene_max=116,gene_delay=0.035,fast_vault=true,invisible=false,aim_on=true,aim_fov=350,aim_predict=true,aim_zigzag=true,veil_on=true,veil_fov=280,veil_predict=2.8,parry_on=true,parry_radius=12,parry_circle=true,parry_aggro=true,esp_k=true,esp_s=true,esp_g=true,esp_out=false,esp_range=5000,fog=false,bright=true,cam=true,camv=90,alert=true,fake_quick=true,fake_landing=true,fake_adrenaline=true}
local CF = "kalzz_cfg_v10.json"
local CFS = (type(writefile)=="function") and (type(readfile)=="function") and (type(isfile)=="function")
local CFG = {}
if CFS then pcall(function() if isfile(CF) then local d=HS:JSONDecode(readfile(CF)) if type(d)=="table" then for k,v in pairs(d) do if DEF[k]~=nil then CFG[k]=v end end end end end) end
for k,v in pairs(DEF) do if CFG[k]==nil then CFG[k]=v end end
_G.KALZZ_CFG = CFG
local dirty = false
local function SaveCfg() dirty = true end
task.spawn(function() while true do task.wait(3) if dirty then dirty=false pcall(function() writefile(CF,HS:JSONEncode(CFG)) end) end end end)
pcall(function() game:BindToClose(function() if CFS then pcall(function() writefile(CF,HS:JSONEncode(CFG)) end) end end) end)
_G.KZ_SaveConfig = SaveCfg

local PID = {["122812055447896"]=1,["133963973694098"]=1,["117042998468241"]=1,["135002183282873"]=1,["121216847022485"]=1,["132817836308238"]=1,["129784271201071"]=1,["82666958311998"]=1,["78432063483146"]=1,["118907603246885"]=1,["139369275981139"]=1,["110355011987939"]=1,["111920872708571"]=1,["105374834496520"]=1,["138720291317243"]=1,["106871536134254"]=1,["130593238885843"]=1,["115244153053858"]=1,["74968262036854"]=1,["113255068724446"]=1,["98163597193511"]=1,["80411309607666"]=1}
local Att, VB = {},{}
local CK = Color3.fromRGB(230,80,80)
local CS = Color3.fromRGB(80,160,230)
local CGr = Color3.fromRGB(80,220,120)

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

-- UI
local COL = {bg=Color3.fromRGB(15,15,18),panel=Color3.fromRGB(20,20,24),side=Color3.fromRGB(17,17,21),card=Color3.fromRGB(26,26,32),tabOn=Color3.fromRGB(38,38,46),brd=Color3.fromRGB(48,48,56),brdS=Color3.fromRGB(38,38,46),tx=Color3.fromRGB(240,240,245),txD=Color3.fromRGB(160,160,175),txF=Color3.fromRGB(110,110,125),acc=Color3.fromRGB(100,140,230),off=Color3.fromRGB(52,52,62)}
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
Main.Position = UDim2.new(0.5, -290, 0.5, -240)
Main.BackgroundColor3 = COL.bg
Main.BackgroundTransparency = TR
Main.BorderSizePixel = 0
Main.ZIndex = 10
cR(Main, 10)
cS(Main, COL.brd, 1, 0.4)

local Hdr = Instance.new("Frame", Main)
Hdr.Size = UDim2.new(1, 0, 0, 48)
Hdr.BackgroundColor3 = COL.panel
Hdr.BackgroundTransparency = TRP
Hdr.BorderSizePixel = 0
Hdr.ZIndex = 11
cR(Hdr, 10)
local HF = Instance.new("Frame", Hdr)
HF.Size = UDim2.new(1, 0, 0, 12)
HF.Position = UDim2.new(0, 0, 1, -12)
HF.BackgroundColor3 = COL.panel
HF.BackgroundTransparency = TRP
HF.BorderSizePixel = 0
HF.ZIndex = 11

local Title = Instance.new("TextLabel", Hdr)
Title.Size = UDim2.new(1, -140, 0, 20)
Title.Position = UDim2.fromOffset(18, 8)
Title.BackgroundTransparency = 1
Title.Text = "KALZZ HUB | VIOLENCE DISTRICT"
Title.TextColor3 = COL.tx
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12

local Sub = Instance.new("TextLabel", Hdr)
Sub.Size = UDim2.new(1, -140, 0, 14)
Sub.Position = UDim2.fromOffset(18, 28)
Sub.BackgroundTransparency = 1
Sub.Text = "v10  •  discord.gg/"..INV
Sub.TextColor3 = COL.txF
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 10
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.ZIndex = 12

local function mkX(x)
    local b = Instance.new("TextButton", Hdr)
    b.Size = UDim2.fromOffset(26, 26)
    b.Position = UDim2.new(1, x, 0.5, -13)
    b.BackgroundColor3 = Color3.fromRGB(220,80,80)
    b.BackgroundTransparency = 0.25
    b.Text = ""
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.ZIndex = 12
    cR(b, 6)
    for _, rot in ipairs({45,-45}) do
        local l = Instance.new("Frame", b)
        l.Size = UDim2.fromOffset(12, 2)
        l.Position = UDim2.new(0.5, -6, 0.5, -1)
        l.BackgroundColor3 = Color3.fromRGB(255,255,255)
        l.BorderSizePixel = 0
        l.ZIndex = 13
        cR(l, 1)
        l.Rotation = rot
    end
    return b
end
local function mkM(x)
    local b = Instance.new("TextButton", Hdr)
    b.Size = UDim2.fromOffset(26, 26)
    b.Position = UDim2.new(1, x, 0.5, -13)
    b.BackgroundColor3 = Color3.fromRGB(60,60,75)
    b.BackgroundTransparency = 0.25
    b.Text = ""
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.ZIndex = 12
    cR(b, 6)
    local l = Instance.new("Frame", b)
    l.Size = UDim2.fromOffset(12, 2)
    l.Position = UDim2.new(0.5, -6, 0.5, -1)
    l.BackgroundColor3 = Color3.fromRGB(255,255,255)
    l.BorderSizePixel = 0
    l.ZIndex = 13
    cR(l, 1)
    return b
end
local MinB = mkM(-68)
local ClsB = mkX(-36)

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
Side.Size = UDim2.new(0, 150, 1, -58)
Side.Position = UDim2.fromOffset(8, 54)
Side.BackgroundColor3 = COL.side
Side.BackgroundTransparency = TRP
Side.BorderSizePixel = 0
Side.ZIndex = 11
cR(Side, 8)

local SideL = Instance.new("ScrollingFrame", Side)
SideL.Size = UDim2.new(1, -8, 1, -8)
SideL.Position = UDim2.fromOffset(4, 4)
SideL.BackgroundTransparency = 1
SideL.BorderSizePixel = 0
SideL.ScrollBarThickness = 2
SideL.ScrollBarImageColor3 = COL.brd
SideL.CanvasSize = UDim2.new(0, 0, 0, 300)
SideL.ZIndex = 12

local Cont = Instance.new("Frame", Main)
Cont.Size = UDim2.new(1, -172, 1, -58)
Cont.Position = UDim2.fromOffset(162, 54)
Cont.BackgroundColor3 = COL.bg
Cont.BackgroundTransparency = TRP
Cont.BorderSizePixel = 0
Cont.ZIndex = 11
cR(Cont, 8)

local CT = Instance.new("TextLabel", Cont)
CT.Size = UDim2.new(1, -32, 0, 22)
CT.Position = UDim2.fromOffset(16, 14)
CT.BackgroundTransparency = 1
CT.Text = ""
CT.TextColor3 = COL.tx
CT.Font = Enum.Font.GothamBold
CT.TextSize = 16
CT.TextXAlignment = Enum.TextXAlignment.Left
CT.ZIndex = 12

local CSL = Instance.new("ScrollingFrame", Cont)
CSL.Size = UDim2.new(1, -16, 1, -50)
CSL.Position = UDim2.fromOffset(8, 44)
CSL.BackgroundTransparency = 1
CSL.BorderSizePixel = 0
CSL.ScrollBarThickness = 3
CSL.ScrollBarImageColor3 = COL.brd
CSL.CanvasSize = UDim2.new(0, 0, 0, 2000)
CSL.ZIndex = 12

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
    b.Size = UDim2.new(1, -4, 0, 34)
    b.Position = UDim2.new(0, 2, 0, i*38+2)
    b.BackgroundColor3 = COL.side
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.Text = ""
    b.AutoButtonColor = false
    b.ZIndex = 13
    cR(b, 6)
    local l = Instance.new("TextLabel", b)
    l.Name = "Lbl"
    l.Size = UDim2.new(1, -20, 1, 0)
    l.Position = UDim2.fromOffset(14, 0)
    l.BackgroundTransparency = 1
    l.Text = n
    l.TextColor3 = COL.txD
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 14
    b.MouseButton1Click:Connect(function() W:Show(n) end)
    local p = Instance.new("Frame", CSL)
    p.Size = UDim2.new(1, 0, 0, 2000)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.ZIndex = 13
    local t = {P=p, Y=4}
    function t:Sec(s)
        local x = Instance.new("TextLabel", p)
        x.Size = UDim2.new(1, -8, 0, 24)
        x.Position = UDim2.fromOffset(4, self.Y)
        x.BackgroundTransparency = 1
        x.Text = string.upper(s)
        x.TextColor3 = COL.txF
        x.Font = Enum.Font.GothamBold
        x.TextSize = 11
        x.TextXAlignment = Enum.TextXAlignment.Left
        x.ZIndex = 14
        self.Y = self.Y + 28
        return self
    end
    function t:Banner(c)
        local bc = Instance.new("Frame", p)
        bc.Size = UDim2.new(1, -8, 0, 140)
        bc.Position = UDim2.fromOffset(4, self.Y)
        bc.BackgroundColor3 = COL.card
        bc.BackgroundTransparency = TRC
        bc.BorderSizePixel = 0
        bc.ZIndex = 14
        cR(bc, 8)
        cS(bc, COL.brdS, 1, 0.5)
        local img = Instance.new("ImageLabel", bc)
        img.Size = UDim2.new(1, -12, 1, -12)
        img.Position = UDim2.fromOffset(6, 6)
        img.BackgroundTransparency = 1
        img.Image = c.Image or IMG
        img.ScaleType = Enum.ScaleType.Crop
        img.ZIndex = 15
        cR(img, 6)
        self.Y = self.Y + 152
        return self
    end
    function t:Btn(c)
        local b = Instance.new("TextButton", p)
        b.Size = UDim2.new(1, -8, 0, 38)
        b.Position = UDim2.fromOffset(4, self.Y)
        b.BackgroundColor3 = COL.card
        b.BackgroundTransparency = TRC
        b.BorderSizePixel = 0
        b.Text = ""
        b.AutoButtonColor = false
        b.ZIndex = 14
        cR(b, 8)
        cS(b, COL.brdS, 1, 0.5)
        local l = Instance.new("TextLabel", b)
        l.Size = UDim2.new(1, -20, 1, 0)
        l.Position = UDim2.fromOffset(14, 0)
        l.BackgroundTransparency = 1
        l.Text = c.Title
        l.TextColor3 = COL.tx
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 15
        b.MouseButton1Click:Connect(function() if c.Callback then pcall(c.Callback) end end)
        self.Y = self.Y + 44
        return self
    end
    function t:Par(c)
        local cc = Instance.new("Frame", p)
        cc.Size = UDim2.new(1, -8, 0, 60)
        cc.Position = UDim2.fromOffset(4, self.Y)
        cc.BackgroundColor3 = COL.card
        cc.BackgroundTransparency = TRC
        cc.BorderSizePixel = 0
        cc.ZIndex = 14
        cR(cc, 8)
        cS(cc, COL.brdS, 1, 0.5)
        local tt = Instance.new("TextLabel", cc)
        tt.Size = UDim2.new(1, -24, 0, 18)
        tt.Position = UDim2.fromOffset(14, 10)
        tt.BackgroundTransparency = 1
        tt.Text = c.Title or ""
        tt.TextColor3 = COL.tx
        tt.Font = Enum.Font.GothamBold
        tt.TextSize = 13
        tt.TextXAlignment = Enum.TextXAlignment.Left
        tt.ZIndex = 15
        local dd = Instance.new("TextLabel", cc)
        dd.Size = UDim2.new(1, -24, 0, 28)
        dd.Position = UDim2.fromOffset(14, 28)
        dd.BackgroundTransparency = 1
        dd.Text = c.Content or ""
        dd.TextColor3 = COL.txD
        dd.Font = Enum.Font.Gotham
        dd.TextSize = 11
        dd.TextXAlignment = Enum.TextXAlignment.Left
        dd.TextYAlignment = Enum.TextYAlignment.Top
        dd.TextWrapped = true
        dd.ZIndex = 15
        self.Y = self.Y + 66
        return self
    end
    function t:Tog(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1, -8, 0, 42)
        row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.card
        row.BackgroundTransparency = TRC
        row.BorderSizePixel = 0
        row.ZIndex = 14
        cR(row, 8)
        cS(row, COL.brdS, 1, 0.5)
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(1, -80, 1, 0)
        l.Position = UDim2.fromOffset(14, 0)
        l.BackgroundTransparency = 1
        l.Text = c.Title or id
        l.TextColor3 = COL.tx
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 15
        local st = c.Default or false
        local tr = Instance.new("Frame", row)
        tr.Size = UDim2.fromOffset(40, 22)
        tr.Position = UDim2.new(1, -54, 0.5, -11)
        tr.BackgroundColor3 = st and COL.acc or COL.off
        tr.BackgroundTransparency = 0.1
        tr.BorderSizePixel = 0
        tr.ZIndex = 15
        cR(tr, 11)
        local k = Instance.new("Frame", tr)
        k.Size = UDim2.fromOffset(16, 16)
        k.Position = st and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        k.BackgroundColor3 = Color3.fromRGB(255,255,255)
        k.BorderSizePixel = 0
        k.ZIndex = 16
        cR(k, 8)
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 17
        btn.MouseButton1Click:Connect(function()
            st = not st
            TS:Create(k,TweenInfo.new(0.2),{Position=st and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
            TS:Create(tr,TweenInfo.new(0.2),{BackgroundColor3=st and COL.acc or COL.off}):Play()
            if c.Callback then pcall(c.Callback, st) end
            if _G.KZ_SaveConfig then _G.KZ_SaveConfig() end
        end)
        self.Y = self.Y + 48
        return self
    end
    function t:Sl(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1, -8, 0, 56)
        row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.card
        row.BackgroundTransparency = TRC
        row.BorderSizePixel = 0
        row.ZIndex = 14
        cR(row, 8)
        cS(row, COL.brdS, 1, 0.5)
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(1, -80, 0, 18)
        l.Position = UDim2.fromOffset(14, 9)
        l.BackgroundTransparency = 1
        l.Text = c.Title or id
        l.TextColor3 = COL.tx
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 15
        local vL = Instance.new("TextLabel", row)
        vL.Size = UDim2.fromOffset(56, 18)
        vL.Position = UDim2.new(1, -70, 0, 9)
        vL.BackgroundTransparency = 1
        vL.Text = tostring(c.Default or c.Min or 0)
        vL.TextColor3 = COL.acc
        vL.Font = Enum.Font.GothamBold
        vL.TextSize = 12
        vL.TextXAlignment = Enum.TextXAlignment.Right
        vL.ZIndex = 15
        local tr = Instance.new("Frame", row)
        tr.Size = UDim2.new(1, -28, 0, 4)
        tr.Position = UDim2.new(0, 14, 1, -16)
        tr.BackgroundColor3 = COL.off
        tr.BackgroundTransparency = 0.1
        tr.BorderSizePixel = 0
        tr.ZIndex = 15
        cR(tr, 2)
        local mn, mx = c.Min or 0, c.Max or 100
        local pct = ((c.Default or mn)-mn)/(mx-mn)
        local f = Instance.new("Frame", tr)
        f.Size = UDim2.new(pct, 0, 1, 0)
        f.BackgroundColor3 = COL.acc
        f.BorderSizePixel = 0
        f.ZIndex = 16
        cR(f, 2)
        local k = Instance.new("Frame", tr)
        k.Size = UDim2.fromOffset(14, 14)
        k.Position = UDim2.new(pct, -7, 0.5, -7)
        k.BackgroundColor3 = Color3.fromRGB(255,255,255)
        k.BorderSizePixel = 0
        k.ZIndex = 17
        cR(k, 7)
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
        hb.Size = UDim2.new(1, -20, 0, 26)
        hb.Position = UDim2.new(0, 10, 1, -30)
        hb.BackgroundTransparency = 1
        hb.Text = ""
        hb.ZIndex = 18
        hb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true upd(i.Position.X) end end)
        UIS.InputChanged:Connect(function(i) if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end end)
        self.Y = self.Y + 62
        return self
    end
    function t:Drop(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1, -8, 0, 42)
        row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.card
        row.BackgroundTransparency = TRC
        row.BorderSizePixel = 0
        row.ZIndex = 14
        cR(row, 8)
        cS(row, COL.brdS, 1, 0.5)
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(1, -140, 1, 0)
        l.Position = UDim2.fromOffset(14, 0)
        l.BackgroundTransparency = 1
        l.Text = c.Title or id
        l.TextColor3 = COL.tx
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 15
        local vs = c.Values or {}
        local cur = c.Default or vs[1] or "?"
        local vL = Instance.new("TextLabel", row)
        vL.Size = UDim2.new(0, 110, 1, 0)
        vL.Position = UDim2.new(1, -122, 0, 0)
        vL.BackgroundTransparency = 1
        vL.Text = cur
        vL.TextColor3 = COL.txD
        vL.Font = Enum.Font.GothamMedium
        vL.TextSize = 11
        vL.TextXAlignment = Enum.TextXAlignment.Right
        vL.ZIndex = 15
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 16
        local hd = Instance.new("Frame", p)
        hd.Size = UDim2.new(1, -8, 0, 0)
        hd.Position = UDim2.fromOffset(4, self.Y + 46)
        hd.BackgroundColor3 = COL.card
        hd.BackgroundTransparency = 0.1
        hd.BorderSizePixel = 0
        hd.ClipsDescendants = true
        hd.Visible = false
        hd.ZIndex = 20
        cR(hd, 8)
        cS(hd, COL.brd, 1, 0.4)
        for i,v in ipairs(vs) do
            local opt = Instance.new("TextButton", hd)
            opt.Size = UDim2.new(1, -8, 0, 28)
            opt.Position = UDim2.fromOffset(4, (i-1)*30+4)
            opt.BackgroundColor3 = COL.card
            opt.BackgroundTransparency = 1
            opt.BorderSizePixel = 0
            opt.Text = ""
            opt.AutoButtonColor = false
            opt.ZIndex = 22
            cR(opt, 5)
            local oL = Instance.new("TextLabel", opt)
            oL.Size = UDim2.new(1, -16, 1, 0)
            oL.Position = UDim2.fromOffset(12, 0)
            oL.BackgroundTransparency = 1
            oL.Text = v
            oL.TextColor3 = COL.txD
            oL.Font = Enum.Font.GothamMedium
            oL.TextSize = 11
            oL.TextXAlignment = Enum.TextXAlignment.Left
            oL.ZIndex = 23
            opt.MouseButton1Click:Connect(function()
                cur = v
                vL.Text = v
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
        return self
    end
    self.T[n] = t
    self.TB[n] = b
    SideL.CanvasSize = UDim2.new(0, 0, 0, self.Cnt*38+8)
    if not self.Cur then self:Show(n) end
    return t
end

-- TABS
local TI = W:AddTab({Title="Information"})
local TSv = W:AddTab({Title="Survivor"})
local TA = W:AddTab({Title="Aim"})
local TP = W:AddTab({Title="Parry"})
local TE = W:AddTab({Title="ESP"})
local TM = W:AddTab({Title="Misc"})

TI:Banner({Image=IMG})
TI:Par({Title="KALZZ HUB v10", Content="Discord: discord.gg/"..INV})
TI:Btn({Title="Copy Discord Invite", Callback=function() pcall(function() if setclipboard then setclipboard(URL) end end) end})
TI:Btn({Title="Reset Config", Callback=function() pcall(function() if delfile and isfile(CF) then delfile(CF) end end) end})

TSv:Sec("Auto Generator")
TSv:Tog("gene_on", {Title="Enable Auto Gen", Default=CFG.gene_on, Callback=function(v) CFG.gene_on=v end})
TSv:Drop("gene_method", {Title="Method", Values={"PERFECT","NORMAL","INSTANT"}, Default=CFG.gene_method, Callback=function(v) CFG.gene_method=v end})
TSv:Sec("Movement")
TSv:Tog("fv", {Title="Always Fast Vault", Default=CFG.fast_vault, Callback=function(v) CFG.fast_vault=v end})
TSv:Sec("Stealth")
TSv:Tog("inv", {Title="Invisible (Local)", Default=CFG.invisible, Callback=function(v) CFG.invisible=v if _G.KZ_SetInvisible then _G.KZ_SetInvisible(v) end end})
TSv:Sec("Fake Perks")
TSv:Tog("fake_quick", {Title="Quick Recovery", Default=CFG.fake_quick, Callback=function(v) CFG.fake_quick=v end})
TSv:Tog("fake_landing", {Title="Perfect Landing", Default=CFG.fake_landing, Callback=function(v) CFG.fake_landing=v end})
TSv:Tog("fake_adrenaline", {Title="Adrenaline Rush", Default=CFG.fake_adrenaline, Callback=function(v) CFG.fake_adrenaline=v end})

TA:Sec("Silent Aim (ToF)")
TA:Tog("aim_on", {Title="Enable ToF", Default=CFG.aim_on, Callback=function(v) CFG.aim_on=v end})
TA:Sl("aim_fov", {Title="ToF FOV", Min=50, Max=700, Default=CFG.aim_fov, Callback=function(v) CFG.aim_fov=v end})
TA:Tog("ap", {Title="Predict", Default=CFG.aim_predict, Callback=function(v) CFG.aim_predict=v end})
TA:Tog("az", {Title="Zigzag", Default=CFG.aim_zigzag, Callback=function(v) CFG.aim_zigzag=v end})
TA:Sec("Silent Aim (Veil)")
TA:Tog("veil_on", {Title="Enable Veil", Default=CFG.veil_on, Callback=function(v) CFG.veil_on=v end})
TA:Sl("veil_fov", {Title="Veil FOV", Min=50, Max=500, Default=CFG.veil_fov, Callback=function(v) CFG.veil_fov=v end})

TP:Sec("Auto Parry")
TP:Tog("po", {Title="Enable Auto Parry", Default=CFG.parry_on, Callback=function(v) CFG.parry_on=v end})
TP:Sl("pr", {Title="Radius", Min=1, Max=20, Default=CFG.parry_radius, Callback=function(v) CFG.parry_radius=v end})
TP:Tog("pc", {Title="Show Circle", Default=CFG.parry_circle, Callback=function(v) CFG.parry_circle=v end})
TP:Tog("pa", {Title="Aggressive", Default=CFG.parry_aggro, Callback=function(v) CFG.parry_aggro=v end})

TE:Sec("ESP Targets")
TE:Tog("ek", {Title="Killer ESP", Default=CFG.esp_k, Callback=function(v) CFG.esp_k=v end})
TE:Tog("es", {Title="Survivor ESP", Default=CFG.esp_s, Callback=function(v) CFG.esp_s=v end})
TE:Tog("eg", {Title="Generator ESP", Default=CFG.esp_g, Callback=function(v) CFG.esp_g=v end})
TE:Sec("Display")
TE:Tog("eo", {Title="Outline Only", Default=CFG.esp_out, Callback=function(v) CFG.esp_out=v end})
TE:Sl("er", {Title="Max Range", Min=100, Max=5000, Default=CFG.esp_range, Callback=function(v) CFG.esp_range=v end})

TM:Sec("Visual")
TM:Tog("fog", {Title="No Fog", Default=CFG.fog, Callback=function(v) CFG.fog=v if v then L.FogEnd=100000; L.FogStart=100000 end end})
TM:Tog("br", {Title="Bright Light", Default=CFG.bright, Callback=function(v) CFG.bright=v if v then L.Ambient=Color3.fromRGB(200,200,200); L.Brightness=4; L.OutdoorAmbient=Color3.fromRGB(180,180,180); L.GlobalShadows=false; L.ClockTime=14 end end})
TM:Sec("Camera")
TM:Tog("cam", {Title="FOV Lock", Default=CFG.cam, Callback=function(v) CFG.cam=v end})
TM:Sl("camv", {Title="FOV Value", Min=30, Max=140, Default=CFG.camv, Callback=function(v) CFG.camv=v end})
TM:Sec("Alert")
TM:Tog("alert", {Title="Proximity Alert", Default=CFG.alert, Callback=function(v) CFG.alert=v end})

W:Show("Information")

-- FLOAT BUTTON
local FG = Instance.new("ScreenGui")
FG.Name = "KZ_Float"
FG.ResetOnSpawn = false
FG.IgnoreGuiInset = true
FG.DisplayOrder = 2147483647
pcall(function() if gethui then FG.Parent = gethui() else FG.Parent = CG end end)
local FB = Instance.new("TextButton", FG)
FB.Size = UDim2.fromOffset(80, 80)
FB.Position = UDim2.new(0, 20, 0.5, -40)
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
local function TogUI()
    if Main.Visible then Main.Visible = false else Main.Visible = true; FB.Visible = false end
end
MinB.MouseButton1Click:Connect(function() Main.Visible=false; FB.Visible=true end)
ClsB.MouseButton1Click:Connect(function() Main.Visible=false; FB.Visible=true end)
local fD, fS, fP, fM = false, nil, nil, false
FB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then fD=true; fM=false; fS=i.Position; fP=FB.Position end end)
UIS.InputChanged:Connect(function(i) if fD and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-fS if d.Magnitude>8 then fM=true; FB.Position=UDim2.new(fP.X.Scale,fP.X.Offset+d.X,fP.Y.Scale,fP.Y.Offset+d.Y) end end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then if fD and not fM then TogUI() end; fD=false; task.delay(0.1, function() fM=false end) end end)
UIS.InputBegan:Connect(function(i,g) if g then return end if i.KeyCode==Enum.KeyCode.RightShift then TogUI() end end)

-- ============ FAST VAULT ============
pcall(function()
    local function applyFV(char)
        if not char or VB[char] then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local anim = hum:FindFirstChildOfClass("Animator")
        if not anim then task.wait(0.4); anim = hum:FindFirstChildOfClass("Animator") end
        if not anim then return end
        VB[char] = anim.AnimationPlayed:Connect(function(t)
            if not CFG.fast_vault or not t or not t.Animation then return end
            local n = (t.Animation.Name or ""):lower()
            local id = tostring(t.Animation.AnimationId or "")
            if n:find("vault") or n:find("window") or n:find("pallet") or n:find("climb") or id:find("79965656177566") then
                t:Stop(0)
                task.defer(function()
                    if t.Animation then
                        local nt = anim:LoadAnimation(t.Animation)
                        nt:Play(0); nt:AdjustSpeed(2.1)
                        nt.Priority = Enum.AnimationPriority.Action
                    end
                end)
            end
        end)
    end
    LP.CharacterAdded:Connect(function(c) task.wait(1); applyFV(c) end)
    if LP.Character then task.spawn(function() applyFV(LP.Character) end) end
end)

-- ============ INVISIBLE ============
pcall(function()
    local function setInvisible(char, state)
        if not char then return end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                if state then
                    if not v:GetAttribute("OldTrans") then v:SetAttribute("OldTrans", v.Transparency) end
                    v.Transparency = 1
                    pcall(function() v.LocalTransparencyModifier = -1 end)
                    v.CanCollide = false
                else
                    v.Transparency = v:GetAttribute("OldTrans") or 0
                    pcall(function() v.LocalTransparencyModifier = 0 end)
                    v.CanCollide = true
                end
            elseif v:IsA("Decal") or v:IsA("Texture") then
                if state then
                    if not v:GetAttribute("OldTrans") then v:SetAttribute("OldTrans", v.Transparency) end
                    v.Transparency = 1
                else
                    v.Transparency = v:GetAttribute("OldTrans") or 0
                end
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = not state
            end
        end
        for _, acc in ipairs(char:GetChildren()) do
            if acc:IsA("Accessory") then
                for _, p in ipairs(acc:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if state then
                            if not p:GetAttribute("OldTrans") then p:SetAttribute("OldTrans", p.Transparency) end
                            p.Transparency = 1
                            pcall(function() p.LocalTransparencyModifier = -1 end)
                        else
                            p.Transparency = p:GetAttribute("OldTrans") or 0
                            pcall(function() p.LocalTransparencyModifier = 0 end)
                        end
                    elseif p:IsA("Decal") then
                        if state then p.Transparency = 1 else p.Transparency = p:GetAttribute("OldTrans") or 0 end
                    end
                end
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.DisplayDistanceType = state and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer end
    end
    local function onChar(char) task.wait(1) if CFG.invisible then setInvisible(char, true) end end
    LP.CharacterAdded:Connect(onChar)
    if LP.Character then task.spawn(function() onChar(LP.Character) end) end
    _G.KZ_SetInvisible = function(state) CFG.invisible = state; if LP.Character then setInvisible(LP.Character, state) end end
end)

-- ============ FAKE PERKS ============
pcall(function()
    local ab = {}
    local bid = 0
    local function getHum() local c=LP.Character return c and c:FindFirstChildOfClass("Humanoid") end
    local function boost(m, d)
        local h = getHum()
        if not h then return end
        bid = bid + 1
        local id = bid
        local orig = h.WalkSpeed
        h.WalkSpeed = orig * m
        ab[id] = {t = os.clock() + d, o = orig}
        task.delay(d, function()
            if ab[id] then
                ab[id] = nil
                local still = false
                for _ in pairs(ab) do still = true; break end
                if not still and h and h.Parent then h.WalkSpeed = orig end
            end
        end)
    end
    local VK = {"vault","window","runningvault","fastvault","vaultanim","climb","mantle","ledge"}
    local function isV(n) n=(n or ""):lower() for _,k in ipairs(VK) do if n:find(k) then return true end end return false end
    local function sq(char)
        if not CFG.fake_quick then return end
        local h = char:FindFirstChildOfClass("Humanoid")
        if not h then return end
        local a = h:FindFirstChildOfClass("Animator")
        if not a then task.delay(0.5, function() sq(char) end); return end
        a.AnimationPlayed:Connect(function(t)
            if not CFG.fake_quick or not t or not t.Animation then return end
            local n = t.Animation.Name or ""
            local id = tostring(t.Animation.AnimationId or "")
            if isV(n) or id:find("79965656177566") then task.delay(0.18, function() boost(1.4, 3.2) end) end
        end)
    end
    local function sl(char)
        if not CFG.fake_landing then return end
        local r = char:FindFirstChild("HumanoidRootPart")
        local h = char:FindFirstChildOfClass("Humanoid")
        if not r or not h then return end
        local wf = false
        local sy = 0
        local md = 8
        local c
        c = RSvc.Heartbeat:Connect(function()
            if not CFG.fake_landing then return end
            if not r or not r.Parent or not h or not h.Parent then if c then c:Disconnect() end return end
            local vy = r.AssemblyLinearVelocity.Y
            local st = h:GetState()
            if vy < -28 or st == Enum.HumanoidStateType.Freefall then if not wf then wf = true; sy = r.Position.Y end end
            if wf then
                if vy > -12 and (st == Enum.HumanoidStateType.Landed or st == Enum.HumanoidStateType.Running or st == Enum.HumanoidStateType.RunningNoPhysics) then
                    local fd = sy - r.Position.Y
                    if fd >= md then boost(1.4, 3.2) end
                    wf = false
                end
            end
        end)
    end
    local function sa(char)
        if not CFG.fake_adrenaline then return end
        local h = char:FindFirstChildOfClass("Humanoid")
        if not h then return end
        local lh = h.Health
        local cd = false
        h.HealthChanged:Connect(function(hp)
            if not CFG.fake_adrenaline or cd then return end
            if hp <= 50 and lh > 50 then
                cd = true
                local o = h.WalkSpeed
                h.WalkSpeed = o + 4.5
                task.delay(5, function()
                    if h and h.Parent then h.WalkSpeed = math.max(16, h.WalkSpeed - 4.5) end
                    cd = false
                end)
            end
            lh = hp
        end)
    end
    local function setup(c)
        if not c then return end
        task.wait(1.4)
        sq(c); sl(c); sa(c)
    end
    LP.CharacterAdded:Connect(setup)
    if LP.Character then task.spawn(function() setup(LP.Character) end) end
    LP.CharacterRemoving:Connect(function() ab = {} end)
end)

-- ============ AUTO GEN ============
pcall(function()
    local KS, KE
    local KP = RS:WaitForChild("Remotes", 5)
    if KP then KP = KP:WaitForChild("KillerPerks", 5) end
    if KP then KP = KP:WaitForChild("kingscourge", 5) end
    if KP then KS = KP:FindFirstChild("KingScourgeStart"); KE = KP:FindFirstChild("KingScourgeEnd") end
    local G = {last=0, busy=false, sa=false, pv=false, lg=nil}
    local R = {}
    local function rf()
        local sg = PG:FindFirstChild("SkillCheckPromptGui")
        if sg then
            R.Check = sg:FindFirstChild("Check")
            if R.Check then R.Line = R.Check:FindFirstChild("Line"); R.Goal = R.Check:FindFirstChild("Goal") end
        end
        local sv = PG:FindFirstChild("Survivor-mob")
        if sv then local c = sv:FindFirstChild("Controls"); if c then R.Action = c:FindFirstChild("action") end end
    end
    rf()
    local function tr()
        if not R.Action then rf() end
        if not R.Action then return end
        local n = os.clock()
        if n - G.last < 0.035 then return end
        G.last = n
        pcall(function() if R.Action:IsA("GuiButton") then R.Action:Activate() end end)
        if typeof(firesignal) == "function" then pcall(function() firesignal(R.Action.MouseButton1Down) end) end
    end
    local function pf()
        if not R.Line or not R.Goal then return false end
        local l = tonumber(R.Line.Rotation) or 0
        local g = tonumber(R.Goal.Rotation) or 0
        return l >= g + 102 and l <= g + 116
    end
    local function iN()
        if not R.Check or not R.Line or not R.Goal then rf() end
        if not R.Check or not R.Line or not R.Goal or not R.Check.Visible then return end
        R.Line.Rotation = (tonumber(R.Goal.Rotation) or 0) + 109
        tr()
    end
    if KS then KS.OnClientEvent:Connect(function()
        if not CFG.gene_on then return end
        G.sa = true; G.busy = false
        task.defer(function()
            if CFG.gene_on and CFG.gene_method == "INSTANT" and R.Line and R.Goal then
                R.Line.Rotation = (tonumber(R.Goal.Rotation) or 0) + 109; tr()
            end
        end)
    end) end
    if KE then KE.OnClientEvent:Connect(function() G.sa = false; G.busy = false end) end
    task.spawn(function() while true do task.wait(0.5); rf() end end)
    RSvc.RenderStepped:Connect(function()
        if not CFG.gene_on then G.pv = false; return end
        if not R.Check then rf() end
        if not R.Check then return end
        local v = R.Check.Visible
        if v and not G.pv then
            G.busy = false
            if not G.sa and CFG.gene_method == "INSTANT" then iN() end
        end
        G.pv = v
        if v and not G.sa and not G.busy and (CFG.gene_method == "PERFECT" or CFG.gene_method == "NORMAL") then
            if pf() then G.busy = true; tr(); task.delay(0.07, function() G.busy = false end) end
        end
    end)
    task.spawn(function()
        while true do
            task.wait(0.01)
            if CFG.gene_on and G.sa and CFG.gene_method == "INSTANT" then
                rf()
                if R.Check and R.Check.Visible and R.Goal and R.Line then
                    local c = tonumber(R.Goal.Rotation) or 0
                    if G.lg == nil then G.lg = c; R.Line.Rotation = c + 109; tr()
                    elseif math.abs(c - G.lg) > 1 then G.lg = c; R.Line.Rotation = c + 109; tr() end
                end
            else G.lg = nil end
        end
    end)
end)

-- ============ SILENT AIM ToF ============
pcall(function()
    local FR
    local RR = RS:FindFirstChild("Remotes")
    if RR then local it = RR:FindFirstChild("Items")
        if it then local t = it:FindFirstChild("Twist of Fate")
            if t then FR = t:FindFirstChild("Fire") end
        end
    end
    if not FR then return end
    local AC = {dir=nil, tpart=nil, lastLock=0}
    local VH = {}
    local function gSV(p)
        if not p then return Vector3.zero end
        VH[p] = VH[p] or {}
        table.insert(VH[p], p.AssemblyLinearVelocity or Vector3.zero)
        if #VH[p] > 16 then table.remove(VH[p], 1) end
        if #VH[p] == 0 then return Vector3.zero end
        local s = Vector3.zero
        for _, v in ipairs(VH[p]) do s = s + v end
        return s / #VH[p]
    end
    local function prP(rp, mz)
        if not rp then return mz end
        local b = rp.Position
        if not CFG.aim_predict then return b end
        local v = gSV(rp)
        local pg = (LP:GetNetworkPing() or 0) + 0.048
        local pr = b
        for i = 1, 14 do
            local d = (pr - mz).Magnitude
            local t = d / 135000
            local np = b + v * (t + pg * 1.15)
            if (np - pr).Magnitude < 0.025 then return np end
            pr = np
        end
        return pr
    end
    local function gMZ()
        local ch = LP.Character
        if not ch then return Cam.CFrame.Position end
        local tl = ch:FindFirstChildOfClass("Tool")
        if tl then
            local h = tl:FindFirstChild("Handle") or tl:FindFirstChildWhichIsA("BasePart")
            if h then return h.Position + h.CFrame.LookVector * 2.4 end
        end
        return Cam.CFrame.Position + Cam.CFrame.LookVector * 1.6
    end
    local function selRP()
        local ctr = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
        local bs, br = math.huge, nil
        local cp = Cam.CFrame.Position
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= LP and pl.Character then
                local ch = pl.Character
                local hu = ch:FindFirstChildOfClass("Humanoid")
                local hrp = rtp(ch)
                if hrp and hu and hu.Health > 0 and isKiller(ch) then
                    local wp = hrp.Position
                    local sp, on = Cam:WorldToViewportPoint(wp)
                    local d3 = (wp - cp).Magnitude
                    local s = d3
                    if d3 <= 18 then s = d3 * 0.3
                    elseif on then
                        local d2 = (Vector2.new(sp.X, sp.Y) - ctr).Magnitude
                        if d2 > CFG.aim_fov then s = 99999 else s = d2 + (d3 * 0.15) end
                    else s = 99999 end
                    if s < bs then bs = s; br = hrp end
                end
            end
        end
        AC.tpart = br
        if br then AC.lastLock = os.clock() end
    end
    local function solA()
        local mz = gMZ()
        AC.dir = nil
        if not AC.tpart or not AC.tpart.Parent then return end
        if os.clock() - AC.lastLock > 0.5 then return end
        local pr = prP(AC.tpart, mz)
        if CFG.aim_zigzag then
            local t = tick()
            pr = pr + Vector3.new(math.sin(t*16.8)*0.22, math.cos(t*12.5)*0.14, math.sin(t*10.9)*0.19)
        end
        local d = pr - mz
        if d.Magnitude > 0.03 then AC.dir = d.Unit * 999999 end
    end
    local fg = Instance.new("ScreenGui")
    fg.Name = "KZ_FOV"
    fg.ResetOnSpawn = false
    fg.IgnoreGuiInset = true
    fg.DisplayOrder = 999998
    fg.Parent = PG
    local fc = Instance.new("Frame", fg)
    fc.AnchorPoint = Vector2.new(0.5, 0.5)
    fc.Position = UDim2.new(0.5, 0, 0.5, 0)
    fc.BackgroundTransparency = 1
    fc.Visible = false
    fc.ZIndex = 10
    cR(fc, 999)
    local fs = Instance.new("UIStroke", fc)
    fs.Color = Color3.fromRGB(255, 50, 50)
    fs.Thickness = 1.5
    fs.Transparency = 0.3
    RSvc.RenderStepped:Connect(function()
        if CFG.aim_on then
            fc.Size = UDim2.fromOffset(CFG.aim_fov*2, CFG.aim_fov*2)
            fc.Visible = true
            fs.Color = AC.tpart and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(150, 150, 150)
        else fc.Visible = false end
    end)
    RSvc.Heartbeat:Connect(function()
        if not CFG.aim_on then AC.dir = nil; AC.tpart = nil; return end
        pcall(selRP); pcall(solA)
    end)
    if type(hookmetamethod) == "function" and type(newcclosure) == "function" and type(getnamecallmethod) == "function" then
        local old
        old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            if self == FR and getnamecallmethod() == "FireServer" and CFG.aim_on and AC.dir then
                local a = {...}
                for i = 1, #a do if typeof(a[i]) == "Vector3" then a[i] = AC.dir; break end end
                return old(self, table.unpack(a))
            end
            return old(self, ...)
        end))
    end
end)

-- ============ SILENT AIM VEIL ============
pcall(function()
    local V
    pcall(function() V = RS.Remotes.Killers.Veil.Spearthrow end)
    if not V then return end
    local function gt()
        local m = UIS:GetMouseLocation()
        local c, cd = nil, CFG.veil_fov
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= LP and pl.Character and not isKiller(pl.Character) then
                local hu = pl.Character:FindFirstChildOfClass("Humanoid")
                local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                if hu and hu.Health > 0 and hrp then
                    local sp, on = Cam:WorldToViewportPoint(hrp.Position)
                    if on then
                        local d = (Vector2.new(sp.X, sp.Y) - m).Magnitude
                        if d < cd then cd = d; c = hrp end
                    end
                end
            end
        end
        return c
    end
    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if CFG.veil_on and getnamecallmethod() == "FireServer" and self == V then
            local a = {...}
            if typeof(a[1]) == "Vector3" then
                local t = gt()
                if t then
                    local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if my then
                        local v = t.AssemblyLinearVelocity or Vector3.zero
                        local pr = t.Position + v * (CFG.veil_predict * 0.085)
                        local d = (pr - my.Position).Magnitude
                        pr = pr + Vector3.new(0, math.clamp(d * 0.045, 1.5, 12), 0)
                        local nd = pr - my.Position
                        if nd.Magnitude > 0.1 then a[1] = nd.Unit end
                    end
                end
            end
            return old(self, table.unpack(a))
        end
        return old(self, ...)
    end))
end)

-- ============ AUTO PARRY + CIRCLE ============
pcall(function()
    local PR
    pcall(function() PR = RS.Remotes.Items["Parrying Dagger"].parry end)
    local lp = 0
    local function getR(m) if not m then return nil end return m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart end
    local function gD(m) local a=getR(LP.Character); local b=getR(m); if not a or not b then return 999 end return (a.Position-b.Position).Magnitude end
    local function doP()
        local n = os.clock()
        local cd = CFG.parry_aggro and 0.06 or 0.12
        if n - lp < cd then return end
        lp = n
        if PR then for i = 1, 7 do pcall(function() PR:FireServer() end) end end
        pcall(function()
            local mob = PG:FindFirstChild("Survivor-mob")
            if mob then
                local c = mob:FindFirstChild("Controls")
                if c then
                    local b = c:FindFirstChild("Gui-mob") or c:FindFirstChild("action") or c:FindFirstChildWhichIsA("ImageButton") or c:FindFirstChildWhichIsA("TextButton")
                    if b and typeof(firesignal) == "function" then
                        firesignal(b.MouseButton1Down); task.wait(0.008); firesignal(b.MouseButton1Up)
                    end
                end
            end
        end)
    end
    local function bind(m)
        if not m or Att[m] then return end
        Att[m] = true
        local hum = m:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        task.spawn(function()
            local anim = hum:FindFirstChildOfClass("Animator")
            if not anim then
                for _ = 1, 20 do task.wait(0.15); if not m.Parent then return end; anim = hum:FindFirstChildOfClass("Animator"); if anim then break end end
            end
            if not anim then return end
            anim.AnimationPlayed:Connect(function(t)
                if not CFG.parry_on or not t or not t.Animation then return end
                local id = tostring(t.Animation.AnimationId or ""):match("(%d+)") or ""
                if not PID[id] then return end
                local d = gD(m)
                if d > 0 and d <= (CFG.parry_radius or 12) then doP() end
            end)
        end)
    end
    local function scan()
        for _, o in ipairs(WS:GetDescendants()) do
            if o:IsA("Model") and o:FindFirstChildOfClass("Humanoid") and o ~= LP.Character then bind(o) end
        end
    end
    scan()
    task.spawn(function() while Main.Parent do task.wait(1.5); scan() end end)
    WS.DescendantAdded:Connect(function(o)
        if o:IsA("Model") and o:FindFirstChildOfClass("Humanoid") and o ~= LP.Character then
            task.wait(0.3); bind(o)
        end
    end)
    task.spawn(function()
        while Main.Parent do
            task.wait(0.05)
            if CFG.parry_on then
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
                                            local d = gD(plr.Character)
                                            if d > 0 and d <= (CFG.parry_radius or 12) + 2 then doP(); break end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    UIS.InputBegan:Connect(function(i, g) if g then return end if i.KeyCode == Enum.KeyCode.P then doP() end end)

    -- Circle
    local base = Instance.new("Part")
    base.Name = "KZ_ParryCircleV2"
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
    sg.AlwaysOnTop = false
    sg.ZOffset = 1
    local fill = Instance.new("Frame", sg)
    fill.AnchorPoint = Vector2.new(0.5, 0.5)
    fill.Position = UDim2.fromScale(0.5, 0.5)
    fill.Size = UDim2.fromScale(0.94, 0.94)
    fill.BackgroundColor3 = Color3.fromRGB(100, 140, 230)
    fill.BackgroundTransparency = 1
    fill.BorderSizePixel = 0
    cR(fill, 999)
    local ring = Instance.new("Frame", sg)
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.fromScale(0.5, 0.5)
    ring.Size = UDim2.fromScale(0.96, 0.96)
    ring.BackgroundTransparency = 1
    ring.BorderSizePixel = 0
    cR(ring, 999)
    local s1 = Instance.new("UIStroke", ring)
    s1.Thickness = 5
    s1.Color = Color3.fromRGB(100, 140, 230)
    s1.Transparency = 1
    s1.LineJoinMode = Enum.LineJoinMode.Round
    local ring2 = Instance.new("Frame", sg)
    ring2.AnchorPoint = Vector2.new(0.5, 0.5)
    ring2.Position = UDim2.fromScale(0.5, 0.5)
    ring2.Size = UDim2.fromScale(0.88, 0.88)
    ring2.BackgroundTransparency = 1
    ring2.BorderSizePixel = 0
    cR(ring2, 999)
    local s2 = Instance.new("UIStroke", ring2)
    s2.Thickness = 2
    s2.Color = Color3.fromRGB(180, 210, 255)
    s2.Transparency = 1
    s2.LineJoinMode = Enum.LineJoinMode.Round
    local SC = Color3.fromRGB(100, 140, 230)
    local DC = Color3.fromRGB(230, 90, 90)
    local curC = SC
    local fIn = 0
    local pl2 = 0
    RSvc.Heartbeat:Connect(function(dt)
        pl2 = pl2 + dt
        local hrp = LP.Character and getR(LP.Character)
        local act = CFG.parry_on and CFG.parry_circle and hrp
        if act then fIn = math.min(1, fIn + dt * 5) else fIn = math.max(0, fIn - dt * 5) end
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
            local tc = hasE and DC or SC
            curC = curC:Lerp(tc, math.min(1, dt * 8))
            local r = CFG.parry_radius * 2
            base.Size = Vector3.new(r, 0.05, r)
            base.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2.95, 0))
            local pa = hasE and 0.14 or 0.06
            local pf2 = hasE and 7 or 4
            local p = math.sin(pl2 * pf2) * pa
            s1.Color = curC
            s2.Color = curC:Lerp(Color3.fromRGB(255,255,255), 0.5)
            fill.BackgroundColor3 = curC
            local so = hasE and 0.88 or 0.72
            local s2o = hasE and 0.65 or 0.42
            local fo = hasE and 0.08 or 0.05
            s1.Transparency = math.clamp(1 - (fIn * (so + p)), 0, 1)
            s2.Transparency = math.clamp(1 - (fIn * (s2o + p * 0.6)), 0, 1)
            fill.BackgroundTransparency = math.clamp(1 - (fIn * (fo + p * 0.3)), 0, 1)
        else
            s1.Transparency = math.clamp(1 - (fIn * 0.72), 0, 1)
            s2.Transparency = math.clamp(1 - (fIn * 0.42), 0, 1)
            fill.BackgroundTransparency = math.clamp(1 - (fIn * 0.05), 0, 1)
        end
    end)
end)

-- ============ ESP ============
pcall(function()
    local eD = {}
    local eG = {}
    local ep = GUI
    local function dESP(pl)
        local d = eD[pl]
        if not d then return end
        pcall(function() if d.hl then d.hl:Destroy() end end)
        eD[pl] = nil
    end
    local function isGD(o)
        local p = o:FindFirstChild("Progress") or o:GetAttribute("Progress")
        if typeof(p) == "number" and p >= 100 then return true end
        if o:GetAttribute("Completed") or o:GetAttribute("Finished") then return true end
        return false
    end
    local function isG(o)
        if not o or not o.Parent then return false end
        if not (o:IsA("Model") or o:IsA("BasePart")) then return false end
        local n = o.Name:lower()
        return n:find("generator") or n:find("fuse")
    end
    task.spawn(function()
        while Main.Parent do
            task.wait(0.15)
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
                        local dist = (hrp.Position - mp).Magnitude
                        if en and dist <= CFG.esp_range then
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
        end
    end)
    task.spawn(function()
        while Main.Parent do
            task.wait(1)
            if CFG.esp_g then
                for _, o in ipairs(WS:GetDescendants()) do
                    if isG(o) then
                        if isGD(o) then
                            if eG[o] then pcall(function() eG[o]:Destroy() end); eG[o] = nil end
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
                    if not o.Parent or isGD(o) then pcall(function() hl:Destroy() end); eG[o] = nil end
                end
            else
                for _, hl in pairs(eG) do pcall(function() hl:Destroy() end) end
                eG = {}
            end
        end
    end)
    P.PlayerRemoving:Connect(function(p) dESP(p) end)
end)

-- ============ PROXIMITY ALERT ============
pcall(function()
    local ag = Instance.new("ScreenGui")
    ag.Name = "KZ_Alert"
    ag.ResetOnSpawn = false
    ag.IgnoreGuiInset = true
    ag.DisplayOrder = 1000001
    ag.Parent = PG
    local al = Instance.new("TextLabel", ag)
    al.Size = UDim2.fromOffset(260, 60)
    al.Position = UDim2.new(0.5, -130, 0.14, 0)
    al.BackgroundTransparency = 1
    al.Text = ""
    al.TextColor3 = Color3.fromRGB(240, 210, 140)
    al.Font = Enum.Font.GothamBlack
    al.TextSize = 34
    al.TextStrokeTransparency = 0
    al.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    al.Visible = false
    local as = Instance.new("TextLabel", ag)
    as.Size = UDim2.fromOffset(260, 16)
    as.Position = UDim2.new(0.5, -130, 0.14, 58)
    as.BackgroundTransparency = 1
    as.Text = ""
    as.TextColor3 = Color3.fromRGB(230, 230, 240)
    as.Font = Enum.Font.GothamBold
    as.TextSize = 11
    as.TextStrokeTransparency = 0.3
    as.Visible = false
    task.spawn(function()
        while Main.Parent do
            task.wait(0.2)
            if not CFG.alert then al.Visible = false; as.Visible = false; continue end
            local mr = rtp(LP.Character)
            if not mr then al.Visible = false; as.Visible = false; continue end
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
                if cl <= 10 then t = "!!!"; c = Color3.fromRGB(255, 90, 90)
                elseif cl <= 17 then t = "!!"; c = Color3.fromRGB(255, 160, 100)
                elseif cl <= 25 then t = "!"; c = Color3.fromRGB(255, 220, 130)
                else al.Visible = false; as.Visible = false; continue end
                al.Text = t; al.TextColor3 = c; al.Visible = true
                as.Text = string.format("KILLER %.1f studs", cl); as.Visible = true
            else
                al.Visible = false
                as.Visible = false
            end
        end
    end)
end)

-- ============ FOV LOCK ============
pcall(function()
    local function fF()
        if not CFG.cam then return end
        if Cam and Cam.Parent and math.abs(Cam.FieldOfView - CFG.camv) > 0.5 then
            Cam.FieldOfView = CFG.camv
        end
    end
    RSvc.RenderStepped:Connect(fF)
    WS:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        task.wait(0.1)
        if WS.CurrentCamera then Cam = WS.CurrentCamera; fF() end
    end)
    LP.CharacterAdded:Connect(function() task.wait(0.5); fF(); task.wait(1); fF() end)
    task.spawn(function() while true do task.wait(0.5); fF() end end)
end)

-- ============ VISUAL PERSIST ============
task.spawn(function()
    while true do
        task.wait(1)
        if not GUI.Parent then
            pcall(function() if gethui then GUI.Parent = gethui() else GUI.Parent = CG end end)
        end
        if CFG.bright then
            pcall(function()
                L.Ambient = Color3.fromRGB(200, 200, 200)
                L.Brightness = 4
                L.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
                L.GlobalShadows = false
                L.ClockTime = 14
            end)
        end
        if CFG.fog then pcall(function() L.FogEnd = 100000; L.FogStart = 100000 end) end
    end
end)

print("[KALZZ v1] LOADED")
