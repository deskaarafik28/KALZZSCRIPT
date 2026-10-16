-- ============================================================
-- MODULES/UI.LUA — NEO-BRUTALISM + ANTI-ILANG
-- ============================================================
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local PG = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local CoreGui = game:GetService("CoreGui")

-- ============================================================
-- CLEANUP: hapus ScreenGui lama biar gak numpuk
-- ============================================================
for _, child in ipairs(PG:GetChildren()) do
    if child:IsA("ScreenGui") then
        local n = child.Name
        if n:find("KalzzHub") or n:find("KZ_Float") or n:find("KZ_Aim") 
           or n:find("KZ_ToF_FOV") or n:find("KZ_Alert") or n:find("KZ_Stun") then
            pcall(function() child:Destroy() end)
        end
    end
end

local S = _G.KZ or {}
local CFG = S.CFG or _G.KALZZ_CFG or {}
local INVITE = S.INVITE or "discord.gg/dCYTep9cY"
local IMG = S.IMG or "rbxassetid://134442738689157"
local RC = S.RC or _G.KZ_RC or { tof=nil, veil=nil, parry=nil, fastvault=nil }
local save = S.SaveCfg or _G.KZ_SaveCfg or function() end

if not CFG or next(CFG) == nil then
    warn("[KZ UI] CFG kosong! Pastikan config.lua di-load duluan di main.lua.")
end

local COL = {
    bg = Color3.fromRGB(255, 230, 0), panel = Color3.fromRGB(0, 0, 0),
    side = Color3.fromRGB(255, 255, 255), cardB = Color3.fromRGB(255, 255, 255),
    brd = Color3.fromRGB(0, 0, 0), tx = Color3.fromRGB(0, 0, 0),
    off = Color3.fromRGB(200, 200, 200), red = Color3.fromRGB(255, 50, 50),
    cyan = Color3.fromRGB(0, 255, 255), pink = Color3.fromRGB(255, 0, 255),
}

local function addStroke(parent, thickness, color)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or COL.brd; s.Thickness = thickness or 2
    s.LineJoinMode = Enum.LineJoinMode.Miter; return s
end

-- ============================================================
-- MAIN GUI
-- ============================================================
local GUI = Instance.new("ScreenGui")
GUI.Name = "KalzzHub_Main"
GUI.ResetOnSpawn = false; GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 999998; GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Enabled = true
pcall(function() if gethui then GUI.Parent = gethui() else GUI.Parent = PG end end)
if not GUI.Parent then GUI.Parent = PG end

local uiScale = Instance.new("UIScale", GUI)
uiScale.Scale = 0.75

local Main = Instance.new("Frame", GUI)
Main.Name = "KZ_Main"; Main.Size = UDim2.new(0, 580, 0, 480)
Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = COL.bg; Main.BorderSizePixel = 0; Main.ZIndex = 10
addStroke(Main, 3)

local sizeConstraint = Instance.new("UISizeConstraint", Main)
sizeConstraint.MaxSize = Vector2.new(580, 480); sizeConstraint.MinSize = Vector2.new(580, 480)

-- HEADER
local Hdr = Instance.new("Frame", Main)
Hdr.Size = UDim2.new(1, -6, 0, 48); Hdr.Position = UDim2.fromOffset(3, 3)
Hdr.BackgroundColor3 = COL.panel; Hdr.BorderSizePixel = 0; Hdr.ZIndex = 11
addStroke(Hdr, 2)

local Title = Instance.new("TextLabel", Hdr)
Title.Size = UDim2.new(1, -160, 0, 20); Title.Position = UDim2.fromOffset(18, 8)
Title.BackgroundTransparency = 1; Title.Text = "KALZZ HUB"
Title.TextColor3 = COL.bg; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left; Title.ZIndex = 12

local Sub = Instance.new("TextLabel", Hdr)
Sub.Size = UDim2.new(1, -160, 0, 14); Sub.Position = UDim2.fromOffset(18, 28)
Sub.BackgroundTransparency = 1; Sub.Text = INVITE
Sub.TextColor3 = COL.side; Sub.Font = Enum.Font.GothamBold; Sub.TextSize = 10
Sub.TextXAlignment = Enum.TextXAlignment.Left; Sub.ZIndex = 12

local function mkBtn(x, col, txt)
    local b = Instance.new("TextButton", Hdr)
    b.Size = UDim2.fromOffset(32, 32); b.Position = UDim2.new(1, x, 0.5, -16)
    b.BackgroundColor3 = col; b.Text = txt or ""; b.TextColor3 = COL.brd
    b.Font = Enum.Font.GothamBlack; b.TextSize = 18
    b.BorderSizePixel = 0; b.AutoButtonColor = false; b.ZIndex = 12
    addStroke(b, 2); return b
end
local MinBtn = mkBtn(-76, COL.cyan, "—")
local ClsBtn = mkBtn(-40, COL.red, "X")

-- DRAG
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

-- SIDEBAR & CONTENT
local Side = Instance.new("Frame", Main)
Side.Size = UDim2.new(0, 150, 1, -64); Side.Position = UDim2.fromOffset(6, 56)
Side.BackgroundColor3 = COL.side; Side.BorderSizePixel = 0; Side.ZIndex = 11
addStroke(Side, 2)

local SideL = Instance.new("ScrollingFrame", Side)
SideL.Size = UDim2.new(1, -8, 1, -8); SideL.Position = UDim2.fromOffset(4, 4)
SideL.BackgroundTransparency = 1; SideL.BorderSizePixel = 0
SideL.ScrollBarThickness = 2; SideL.ScrollBarImageColor3 = COL.brd
SideL.CanvasSize = UDim2.new(0, 0, 0, 300); SideL.ZIndex = 12

local Cont = Instance.new("Frame", Main)
Cont.Size = UDim2.new(1, -168, 1, -64); Cont.Position = UDim2.fromOffset(162, 56)
Cont.BackgroundColor3 = COL.side; Cont.BorderSizePixel = 0; Cont.ZIndex = 11
addStroke(Cont, 2)

local CT = Instance.new("TextLabel", Cont)
CT.Size = UDim2.new(1, -32, 0, 22); CT.Position = UDim2.fromOffset(16, 14)
CT.BackgroundTransparency = 1; CT.Text = ""
CT.TextColor3 = COL.tx; CT.Font = Enum.Font.GothamBlack; CT.TextSize = 16
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
        TS:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = a and COL.cyan or COL.side, BackgroundTransparency = 0}):Play()
        local l = b:FindFirstChild("Lbl")
        if l then TS:Create(l, TweenInfo.new(0.1), {TextColor3 = COL.brd}):Play() end
    end
    self.Cur = n; CT.Text = n
end

function W:AddTab(cfg)
    local n = cfg.Title; self.Cnt = self.Cnt + 1; local i = self.Cnt - 1
    local b = Instance.new("TextButton", SideL)
    b.Size = UDim2.new(1, -4, 0, 34); b.Position = UDim2.new(0, 2, 0, i * 38 + 2)
    b.BackgroundColor3 = COL.side; b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false; b.ZIndex = 13
    addStroke(b, 2)
    local l = Instance.new("TextLabel", b)
    l.Name = "Lbl"; l.Size = UDim2.new(1, -20, 1, 0); l.Position = UDim2.fromOffset(14, 0)
    l.BackgroundTransparency = 1; l.Text = n; l.TextColor3 = COL.brd
    l.Font = Enum.Font.GothamBlack; l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 14
    b.MouseButton1Click:Connect(function() W:Show(n) end)
    local p = Instance.new("Frame", CSL)
    p.Size = UDim2.new(1, 0, 0, 2000); p.BackgroundTransparency = 1; p.Visible = false; p.ZIndex = 13
    local t = {P=p, Y=4}

    function t:Sec(s)
        local x = Instance.new("TextLabel", p)
        x.Size = UDim2.new(1, -8, 0, 24); x.Position = UDim2.fromOffset(4, self.Y)
        x.BackgroundTransparency = 1; x.Text = string.upper(s)
        x.TextColor3 = COL.brd; x.Font = Enum.Font.GothamBlack; x.TextSize = 11
        x.TextXAlignment = Enum.TextXAlignment.Left; x.ZIndex = 14
        self.Y = self.Y + 28; return self
    end

    function t:Banner(c)
        local bc = Instance.new("Frame", p)
        bc.Size = UDim2.new(1, -8, 0, 120); bc.Position = UDim2.fromOffset(4, self.Y)
        bc.BackgroundColor3 = COL.cardB; bc.BorderSizePixel = 0; bc.ZIndex = 14
        addStroke(bc, 2)
        local img = Instance.new("ImageLabel", bc)
        img.Size = UDim2.new(1, -12, 1, -12); img.Position = UDim2.fromOffset(6, 6)
        img.BackgroundTransparency = 1; img.Image = c.Image or IMG
        img.ScaleType = Enum.ScaleType.Crop; img.ZIndex = 15
        self.Y = self.Y + 132; return self
    end

    function t:Btn(c)
        local b2 = Instance.new("TextButton", p)
        b2.Size = UDim2.new(1, -8, 0, 38); b2.Position = UDim2.fromOffset(4, self.Y)
        b2.BackgroundColor3 = COL.cyan; b2.BorderSizePixel = 0; b2.Text = ""; b2.AutoButtonColor = false; b2.ZIndex = 14
        addStroke(b2, 2)
        local l2 = Instance.new("TextLabel", b2)
        l2.Size = UDim2.new(1, -20, 1, 0); l2.Position = UDim2.fromOffset(14, 0)
        l2.BackgroundTransparency = 1; l2.Text = c.Title; l2.TextColor3 = COL.brd
        l2.Font = Enum.Font.GothamBlack; l2.TextSize = 12; l2.TextXAlignment = Enum.TextXAlignment.Left; l2.ZIndex = 15
        b2.MouseButton1Click:Connect(function() if c.Callback then pcall(c.Callback) end end)
        self.Y = self.Y + 44; return self
    end

    function t:Tog(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1, -8, 0, 42); row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.cardB; row.BorderSizePixel = 0; row.ZIndex = 14
        addStroke(row, 2)
        local l2 = Instance.new("TextLabel", row)
        l2.Size = UDim2.new(1, -80, 1, 0); l2.Position = UDim2.fromOffset(14, 0)
        l2.BackgroundTransparency = 1; l2.Text = c.Title or id; l2.TextColor3 = COL.tx
        l2.Font = Enum.Font.GothamBold; l2.TextSize = 12; l2.TextXAlignment = Enum.TextXAlignment.Left; l2.ZIndex = 15
        local st = c.Default or false
        local tr = Instance.new("Frame", row)
        tr.Size = UDim2.fromOffset(40, 22); tr.Position = UDim2.new(1, -54, 0.5, -11)
        tr.BackgroundColor3 = st and COL.brd or COL.off; tr.BorderSizePixel = 0; tr.ZIndex = 15
        addStroke(tr, 2)
        local k = Instance.new("Frame", tr)
        k.Size = UDim2.fromOffset(14, 14); k.Position = st and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
        k.BackgroundColor3 = st and COL.cyan or COL.side; k.BorderSizePixel = 0; k.ZIndex = 16
        addStroke(k, 2)
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 17
        btn.MouseButton1Click:Connect(function()
            st = not st
            TS:Create(k, TweenInfo.new(0.1), {Position = st and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7), BackgroundColor3 = st and COL.cyan or COL.side}):Play()
            TS:Create(tr, TweenInfo.new(0.1), {BackgroundColor3 = st and COL.brd or COL.off}):Play()
            if c.Callback then pcall(c.Callback, st) end
        end)
        self.Y = self.Y + 48; return self
    end

    function t:Sl(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1, -8, 0, 56); row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.cardB; row.BorderSizePixel = 0; row.ZIndex = 14
        addStroke(row, 2)
        local l2 = Instance.new("TextLabel", row)
        l2.Size = UDim2.new(1, -80, 0, 18); l2.Position = UDim2.fromOffset(14, 9)
        l2.BackgroundTransparency = 1; l2.Text = c.Title or id; l2.TextColor3 = COL.tx
        l2.Font = Enum.Font.GothamBold; l2.TextSize = 12; l2.TextXAlignment = Enum.TextXAlignment.Left; l2.ZIndex = 15
        local vL = Instance.new("TextLabel", row)
        vL.Size = UDim2.fromOffset(56, 18); vL.Position = UDim2.new(1, -70, 0, 9)
        vL.BackgroundTransparency = 1; vL.Text = tostring(c.Default or c.Min or 0)
        vL.TextColor3 = COL.brd; vL.Font = Enum.Font.GothamBlack; vL.TextSize = 12
        vL.TextXAlignment = Enum.TextXAlignment.Right; vL.ZIndex = 15
        local tr = Instance.new("Frame", row)
        tr.Size = UDim2.new(1, -28, 0, 8); tr.Position = UDim2.new(0, 14, 1, -18)
        tr.BackgroundColor3 = COL.off; tr.BorderSizePixel = 0; tr.ZIndex = 15
        addStroke(tr, 2)
        local mn, mx = c.Min or 0, c.Max or 100
        local pct = ((c.Default or mn) - mn) / (mx - mn)
        local f = Instance.new("Frame", tr)
        f.Size = UDim2.new(pct, 0, 1, 0); f.BackgroundColor3 = COL.pink; f.BorderSizePixel = 0; f.ZIndex = 16
        local k = Instance.new("Frame", tr)
        k.Size = UDim2.fromOffset(16, 16); k.Position = UDim2.new(pct, -8, 0.5, -8)
        k.BackgroundColor3 = COL.bg; k.BorderSizePixel = 0; k.ZIndex = 17
        addStroke(k, 2)
        local dg = false
        local function upd(x)
            local a = math.clamp((x - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
            local v = math.floor(mn + (mx - mn) * a + 0.5)
            f.Size = UDim2.new(a, 0, 1, 0); k.Position = UDim2.new(a, -8, 0.5, -8)
            vL.Text = tostring(v)
            if c.Callback then pcall(c.Callback, v) end
        end
        local hb = Instance.new("TextButton", row)
        hb.Size = UDim2.new(1, -20, 0, 26); hb.Position = UDim2.new(0, 10, 1, -30)
        hb.BackgroundTransparency = 1; hb.Text = ""; hb.ZIndex = 18
        hb.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = true; upd(i.Position.X) end
        end)
        UIS.InputChanged:Connect(function(i)
            if dg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = false end
        end)
        self.Y = self.Y + 62; return self
    end

    function t:Drop(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1, -8, 0, 42); row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.cardB; row.BorderSizePixel = 0; row.ZIndex = 14
        addStroke(row, 2)
        local l2 = Instance.new("TextLabel", row)
        l2.Size = UDim2.new(1, -140, 1, 0); l2.Position = UDim2.fromOffset(14, 0)
        l2.BackgroundTransparency = 1; l2.Text = c.Title or id; l2.TextColor3 = COL.tx
        l2.Font = Enum.Font.GothamBold; l2.TextSize = 12; l2.TextXAlignment = Enum.TextXAlignment.Left; l2.ZIndex = 15
        local vs = c.Values or {}; local cur = c.Default or vs[1] or "?"
        local vL = Instance.new("TextLabel", row)
        vL.Size = UDim2.new(0, 110, 1, 0); vL.Position = UDim2.new(1, -122, 0, 0)
        vL.BackgroundTransparency = 1; vL.Text = cur; vL.TextColor3 = COL.brd
        vL.Font = Enum.Font.GothamBlack; vL.TextSize = 11; vL.TextXAlignment = Enum.TextXAlignment.Right; vL.ZIndex = 15
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 16
        local hd = Instance.new("Frame", p)
        hd.Size = UDim2.new(1, -8, 0, 0); hd.Position = UDim2.fromOffset(4, self.Y + 46)
        hd.BackgroundColor3 = COL.side; hd.BorderSizePixel = 0; hd.ClipsDescendants = true; hd.Visible = false; hd.ZIndex = 20
        addStroke(hd, 2)
        for i, v in ipairs(vs) do
            local opt = Instance.new("TextButton", hd)
            opt.Size = UDim2.new(1, -8, 0, 28); opt.Position = UDim2.fromOffset(4, (i - 1) * 30 + 4)
            opt.BackgroundColor3 = COL.side; opt.BorderSizePixel = 0; opt.Text = ""; opt.AutoButtonColor = false; opt.ZIndex = 22
            addStroke(opt, 2)
            local oL = Instance.new("TextLabel", opt)
            oL.Size = UDim2.new(1, -16, 1, 0); oL.Position = UDim2.fromOffset(12, 0)
            oL.BackgroundTransparency = 1; oL.Text = v; oL.TextColor3 = COL.tx
            oL.Font = Enum.Font.GothamBold; oL.TextSize = 11; oL.TextXAlignment = Enum.TextXAlignment.Left; oL.ZIndex = 23
            opt.MouseButton1Click:Connect(function()
                cur = v; vL.Text = v
                TS:Create(hd, TweenInfo.new(0.15), {Size = UDim2.new(1, -8, 0, 0)}):Play()
                task.delay(0.15, function() hd.Visible = false end)
                if c.Callback then pcall(c.Callback, v) end
            end)
        end
        local hH = math.min(#vs * 30 + 8, 150)
        btn.MouseButton1Click:Connect(function()
            if hd.Visible then
                TS:Create(hd, TweenInfo.new(0.15), {Size = UDim2.new(1, -8, 0, 0)}):Play()
                task.delay(0.15, function() hd.Visible = false end)
            else
                hd.Visible = true
                TS:Create(hd, TweenInfo.new(0.15), {Size = UDim2.new(1, -8, 0, hH)}):Play()
            end
        end)
        self.Y = self.Y + 48; return self
    end

    self.T[n] = t; self.TB[n] = b
    SideL.CanvasSize = UDim2.new(0, 0, 0, self.Cnt * 38 + 8)
    if not self.Cur then self:Show(n) end
    return t
end

-- ============================================================
-- ISI TAB LENGKAP
-- ============================================================
local TInfo = W:AddTab({Title = "Info"})
local TSurv = W:AddTab({Title = "Penyintas"})
local TKil  = W:AddTab({Title = "Pembunuh"})
local TEsp  = W:AddTab({Title = "ESP"})
local TMisc = W:AddTab({Title = "Misc"})

TInfo:Banner({Image = IMG})
TInfo:Sec("KALZZ HUB")
TInfo:Btn({Title = "Copy Discord Invite", Callback = function()
    pcall(function() if setclipboard then setclipboard("https://"..INVITE) end end)
end})
TInfo:Btn({Title = "Save Config Now", Callback = function()
    save(); print("[KZ] Config saved")
end})

TSurv:Sec("Silent Aim (ToF)")
TSurv:Tog("tof_on", {Title = "Enable ToF", Default = CFG.tof_on, Callback = function(v) CFG.tof_on = v; save() end})
TSurv:Tog("tof_show_fov", {Title = "Show FOV Circle", Default = CFG.tof_show_fov, Callback = function(v) CFG.tof_show_fov = v; save() end})
TSurv:Sl("tof_fov", {Title = "FOV", Min = 1, Max = 600, Default = CFG.tof_fov, Callback = function(v) CFG.tof_fov = v; save() end})
TSurv:Sl("tof_predict", {Title = "Predict x10", Min = 10, Max = 50, Default = math.floor((CFG.tof_predict or 2.5) * 10), Callback = function(v) CFG.tof_predict = v / 10; save() end})
TSurv:Sl("tof_maxdist", {Title = "Max Distance", Min = 100, Max = 3000, Default = CFG.tof_maxdist, Callback = function(v) CFG.tof_maxdist = v; save() end})

TSurv:Sec("Auto Generator")
TSurv:Tog("gene_on", {Title = "Enable Auto Gen", Default = CFG.gene_on, Callback = function(v) CFG.gene_on = v; save() end})
TSurv:Drop("gene_method", {Title = "Method", Values = {"SUCCESS", "NEUTRAL", "INSTANT"}, Default = CFG.gene_method, Callback = function(v) CFG.gene_method = v; save() end})

TSurv:Sec("Auto Parry")
TSurv:Tog("parry_on", {Title = "Enable Parry", Default = CFG.parry_on, Callback = function(v) CFG.parry_on = v; save() end})
TSurv:Tog("parry_show_circle", {Title = "Show Parry Circle", Default = CFG.parry_show_circle, Callback = function(v) CFG.parry_show_circle = v; save() end})
TSurv:Tog("parry_aggro", {Title = "Aggressive", Default = CFG.parry_aggro, Callback = function(v) CFG.parry_aggro = v; save() end})
TSurv:Tog("parry_antifake", {Title = "Anti Fake", Default = CFG.parry_antifake, Callback = function(v) CFG.parry_antifake = v; save() end})
TSurv:Sl("parry_radius", {Title = "Radius", Min = 1, Max = 30, Default = CFG.parry_radius, Callback = function(v) CFG.parry_radius = v; save() end})

TSurv:Sec("Movement")
TSurv:Tog("crouch_on", {Title = "Auto Crouch", Default = CFG.crouch_on, Callback = function(v) CFG.crouch_on = v; save() end})
TSurv:Tog("fast_vault", {Title = "Fast Vault", Default = CFG.fast_vault, Callback = function(v) CFG.fast_vault = v; save() end})

TKil:Sec("Silent Aim (Veil)")
TKil:Tog("veil_on", {Title = "Enable Veil", Default = CFG.veil_on, Callback = function(v) CFG.veil_on = v; save() end})
TKil:Tog("veil_show_fov", {Title = "Show FOV Circle", Default = CFG.veil_show_fov, Callback = function(v) CFG.veil_show_fov = v; save() end})
TKil:Sl("veil_fov", {Title = "FOV", Min = 1, Max = 600, Default = CFG.veil_fov, Callback = function(v) CFG.veil_fov = v; save() end})
TKil:Sl("veil_predict", {Title = "Predict x10", Min = 10, Max = 50, Default = math.floor((CFG.veil_predict or 2.8) * 10), Callback = function(v) CFG.veil_predict = v / 10; save() end})
TKil:Sl("veil_maxdist", {Title = "Max Distance", Min = 100, Max = 3000, Default = CFG.veil_maxdist, Callback = function(v) CFG.veil_maxdist = v; save() end})

TEsp:Sec("Player ESP")
TEsp:Tog("esp_k", {Title = "Killer ESP", Default = CFG.esp_k, Callback = function(v) CFG.esp_k = v; save() end})
TEsp:Tog("esp_s", {Title = "Survivor ESP", Default = CFG.esp_s, Callback = function(v) CFG.esp_s = v; save() end})
TEsp:Tog("esp_item", {Title = "Show Item Name", Default = CFG.esp_item, Callback = function(v) CFG.esp_item = v; save() end})

TEsp:Sec("Generator ESP")
TEsp:Tog("esp_g", {Title = "Generator ESP", Default = CFG.esp_g, Callback = function(v) CFG.esp_g = v; save() end})
TEsp:Tog("esp_gen_txt", {Title = "Show Progress Text", Default = CFG.esp_gen_txt, Callback = function(v) CFG.esp_gen_txt = v; save() end})

TEsp:Sec("Style")
TEsp:Tog("esp_out", {Title = "Outline Only", Default = CFG.esp_out, Callback = function(v) CFG.esp_out = v; save() end})

TMisc:Sec("Vision")
TMisc:Tog("fov_lock", {Title = "FOV Lock", Default = CFG.fov_lock, Callback = function(v) CFG.fov_lock = v; save() end})
TMisc:Sl("fov_value", {Title = "FOV Value", Min = 60, Max = 140, Default = CFG.fov_value, Callback = function(v) CFG.fov_value = v; save() end})
TMisc:Tog("ambient", {Title = "Bright Ambient", Default = CFG.ambient, Callback = function(v) CFG.ambient = v; save() end})
TMisc:Tog("boost_fps", {Title = "Boost FPS", Default = CFG.boost_fps, Callback = function(v)
    CFG.boost_fps = v; save()
    pcall(function() if v then setfpscap(240) else setfpscap(0) end end)
end})

TMisc:Sec("Alerts")
TMisc:Tog("alert", {Title = "Proximity Alert", Default = CFG.alert, Callback = function(v) CFG.alert = v; save() end})
TMisc:Tog("stun_on", {Title = "Stun Killer Notif", Default = CFG.stun_on, Callback = function(v) CFG.stun_on = v; save() end})

W:Show("Info")

-- ============================================================
-- FLOATING BUTTON (TRANSPARAN KOTAK)
-- ============================================================
local FG = Instance.new("ScreenGui")
FG.Name = "KZ_Float"
FG.ResetOnSpawn = false; FG.IgnoreGuiInset = true
FG.DisplayOrder = 2147483646
pcall(function() if gethui then FG.Parent = gethui() else FG.Parent = PG end end)
if not FG.Parent then FG.Parent = PG end

local FB = Instance.new("TextButton", FG)
FB.Size = UDim2.fromOffset(60, 60); FB.Position = UDim2.new(0, 20, 0.5, -30)
FB.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FB.BackgroundTransparency = 0.35
FB.Text = "KZ"; FB.TextColor3 = Color3.fromRGB(255, 255, 255)
FB.Font = Enum.Font.GothamBlack; FB.TextSize = 28
FB.TextStrokeTransparency = 0
FB.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
FB.AutoButtonColor = false; FB.Active = true; FB.Visible = false
FB.ZIndex = 10
addStroke(FB, 3, Color3.fromRGB(255, 255, 255))
FB.UIStroke.Transparency = 0.4

local fbCorner = Instance.new("UICorner", FB)
fbCorner.CornerRadius = UDim.new(0, 8)

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
            Main.Visible = true
            FB.Visible = false
        end
        fD = false
        task.delay(0.1, function() fMoved = false end)
    end
end)

-- ============================================================
-- TOMBOL CLOSE & MINIMIZE
-- ============================================================
ClsBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    FB.Visible = true
end)

MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    FB.Visible = true
end)

-- Toggle via RightShift
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.V then CFG.tof_on = not CFG.tof_on; save() end
    if i.KeyCode == Enum.KeyCode.B then CFG.veil_on = not CFG.veil_on; save() end
    if i.KeyCode == Enum.KeyCode.P then if _G.KZ_ManualParry then _G.KZ_ManualParry() end end
    if i.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then
            Main.Visible = false
            FB.Visible = true
        else
            Main.Visible = true
            FB.Visible = false
        end
    end
end)

-- ============================================================
-- UI ANTI ILANG (WATCHDOG + RESPAWN PROTECTION)
-- ============================================================
do
    local NamesToProtect = { "KalzzHub_Main", "KZ_Float", "KZ_Aim_FOV", "KZ_ToF_FOV", "KZ_Alert", "KZ_StunToast" }

    local function isProtectedGui(g)
        if not g:IsA("ScreenGui") then return false end
        local n = g.Name
        for _, key in ipairs(NamesToProtect) do
            if n == key then return true end
        end
        if n:find("KZ_") or n:find("KalzzHub") or n:find("KALZZ") then
            return true
        end
        return false
    end

    local function protect(g)
        if not g or not isProtectedGui(g) then return end
        pcall(function() g.ResetOnSpawn = false end)
        pcall(function() g.IgnoreGuiInset = true end)
        pcall(function()
            local target
            if gethui then target = gethui() else target = PG end
            if g.Parent ~= target then g.Parent = target end
        end)
        pcall(function() g.Enabled = true end)
    end

    local function scanAndProtect()
        local parents = { PG, CoreGui }
        pcall(function() if gethui then table.insert(parents, gethui()) end end)
        for _, parent in ipairs(parents) do
            if parent then
                for _, g in ipairs(parent:GetChildren()) do
                    if isProtectedGui(g) then protect(g) end
                end
            end
        end
    end

    -- Initial scan + retry
    task.spawn(function()
        for _ = 1, 25 do
            scanAndProtect()
            task.wait(0.2)
        end
    end)

    -- Respawn protection
    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
        task.defer(function()
            task.wait(0.3)
            scanAndProtect()
            if GUI and GUI.Parent == nil then
                pcall(function() GUI.Parent = PG end)
            end
            if FG and FG.Parent == nil then
                pcall(function() FG.Parent = PG end)
            end
            Main.Visible = true
            FB.Visible = false
        end)
    end)

    -- Watchdog tiap 2 detik
    task.spawn(function()
        while task.wait(2) do
            scanAndProtect()
            if Main and Main.Size ~= UDim2.new(0, 580, 0, 480) then
                Main.Size = UDim2.new(0, 580, 0, 480)
            end
        end
    end)

    -- Auto-protect ScreenGui baru di PG
    PG.ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") and isProtectedGui(child) then
            task.defer(function() protect(child) end)
        end
    end)
    pcall(function()
        if gethui then
            gethui().ChildAdded:Connect(function(child)
                if child:IsA("ScreenGui") and isProtectedGui(child) then
                    task.defer(function() protect(child) end)
                end
            end)
        end
    end)

    print("[KZ UI] Anti-ilang aktif (watchdog + respawn protection)")
end

print("[KZ UI] Neo-Brutalism loaded + Anti-Ilang")
return true
