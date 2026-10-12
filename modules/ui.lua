--[[
    KALZZSCRIPT
    modules/ui.lua - Hub UI
]]

local S = _G.KZ
if not S then warn("[UI] main.lua belum di-load"); return end

local Players = S.Players
local TS = S.TS
local UIS = S.UIS
local CoreGui = S.CoreGui
local LP = S.LP
local PG = S.PG
local CFG = S.CFG
local IMG = S.IMG
local INVITE = S.INVITE

local COL = {
    bg = Color3.fromRGB(15,15,18),
    panel = Color3.fromRGB(20,20,24),
    side = Color3.fromRGB(17,17,21),
    cardB = Color3.fromRGB(26,26,32),
    tabOn = Color3.fromRGB(40,40,48),
    brd = Color3.fromRGB(60,60,70),
    tx = Color3.fromRGB(240,240,245),
    txD = Color3.fromRGB(180,180,190),
    txF = Color3.fromRGB(120,120,130),
    off = Color3.fromRGB(40,40,48),
    red = Color3.fromRGB(220,80,80),
}

local function getParentTarget()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    return CoreGui
end

local function cR(o, r)
    local c = Instance.new("UICorner", o)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local GUI = Instance.new("ScreenGui")
GUI.Name = "KalzzHub_" .. tostring(os.time())
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
cR(Main, 10)

local Hdr = Instance.new("Frame", Main)
Hdr.Size = UDim2.new(1, 0, 0, 48)
Hdr.BackgroundColor3 = COL.panel
Hdr.BackgroundTransparency = 0.3
Hdr.BorderSizePixel = 0
Hdr.ZIndex = 11
cR(Hdr, 10)

local Title = Instance.new("TextLabel", Hdr)
Title.Size = UDim2.new(1, -140, 0, 20)
Title.Position = UDim2.fromOffset(18, 8)
Title.BackgroundTransparency = 1
Title.Text = "KALZZ HUB"
Title.TextColor3 = COL.tx
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12

local Sub = Instance.new("TextLabel", Hdr)
Sub.Size = UDim2.new(1, -140, 0, 14)
Sub.Position = UDim2.fromOffset(18, 28)
Sub.BackgroundTransparency = 1
Sub.Text = INVITE
Sub.TextColor3 = COL.txF
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 10
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.ZIndex = 12

local function mkBtn(x, col, txt)
    local b = Instance.new("TextButton", Hdr)
    b.Size = UDim2.fromOffset(26, 26)
    b.Position = UDim2.new(1, x, 0.5, -13)
    b.BackgroundColor3 = col
    b.BackgroundTransparency = 0.25
    b.Text = txt or ""
    b.TextColor3 = Color3.fromRGB(240,240,240)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.ZIndex = 12
    cR(b, 6)
    return b
end
local MinBtn = mkBtn(-68, Color3.fromRGB(60,60,75), "–")
local ClsBtn = mkBtn(-36, COL.red, "×")

local drg, ds, sp
Hdr.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drg = true
        ds = i.Position
        sp = Main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - ds
        Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drg = false
    end
end)

local Side = Instance.new("Frame", Main)
Side.Size = UDim2.new(0, 150, 1, -58)
Side.Position = UDim2.fromOffset(8, 54)
Side.BackgroundColor3 = COL.side
Side.BackgroundTransparency = 0.3
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
Cont.BackgroundTransparency = 0.3
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

local W = { T = {}, TB = {}, Cur = nil, Cnt = 0 }
function W:Show(n)
    for k, p in pairs(self.T) do p.P.Visible = (k == n) end
    for k, b in pairs(self.TB) do
        local a = (k == n)
        TS:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = a and COL.tabOn or COL.side,
            BackgroundTransparency = a and 0 or 1
        }):Play()
        local l = b:FindFirstChild("Lbl")
        if l then
            TS:Create(l, TweenInfo.new(0.15), {
                TextColor3 = a and COL.tx or COL.txD
            }):Play()
        end
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

    local t = { P = p, Y = 4 }

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
        bc.Size = UDim2.new(1, -8, 0, 120)
        bc.Position = UDim2.fromOffset(4, self.Y)
        bc.BackgroundColor3 = COL.cardB
        bc.BackgroundTransparency = 0.4
        bc.BorderSizePixel = 0
        bc.ZIndex = 14
        cR(bc, 8)
        local img = Instance.new("ImageLabel", bc)
        img.Size = UDim2.new(1, -12, 1, -12)
        img.Position = UDim2.fromOffset(6, 6)
        img.BackgroundTransparency = 1
        img.Image = c.Image or IMG
        img.ScaleType = Enum.ScaleType.Crop
        img.ZIndex = 15
        cR(img, 6)
        self.Y = self.Y + 132
        return self
    end

    function t:Btn(c)
        local b2 = Instance.new("TextButton", p)
        b2.Size = UDim2.new(1, -8, 0, 38)
        b2.Position = UDim2.fromOffset(4, self.Y)
        b2.BackgroundColor3 = COL.cardB
        b2.BackgroundTransparency = 0.7
        b2.BorderSizePixel = 0
        b2.Text = ""
        b2.AutoButtonColor = false
        b2.ZIndex = 14
        cR(b2, 8)
        local l2 = Instance.new("TextLabel", b2)
        l2.Size = UDim2.new(1, -20, 1, 0)
        l2.Position = UDim2.fromOffset(14, 0)
        l2.BackgroundTransparency = 1
        l2.Text = c.Title
        l2.TextColor3 = COL.tx
        l2.Font = Enum.Font.GothamMedium
        l2.TextSize = 12
        l2.TextXAlignment = Enum.TextXAlignment.Left
        l2.ZIndex = 15
        b2.MouseButton1Click:Connect(function()
            if c.Callback then pcall(c.Callback) end
        end)
        self.Y = self.Y + 44
        return self
    end

    function t:Tog(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1, -8, 0, 42)
        row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.cardB
        row.BackgroundTransparency = 0.7
        row.BorderSizePixel = 0
        row.ZIndex = 14
        cR(row, 6)

        local l2 = Instance.new("TextLabel", row)
        l2.Size = UDim2.new(1, -80, 1, 0)
        l2.Position = UDim2.fromOffset(14, 0)
        l2.BackgroundTransparency = 1
        l2.Text = c.Title or id
        l2.TextColor3 = COL.tx
        l2.Font = Enum.Font.GothamMedium
        l2.TextSize = 12
        l2.TextXAlignment = Enum.TextXAlignment.Left
        l2.ZIndex = 15

        local st = c.Default or false
        local tr = Instance.new("Frame", row)
        tr.Size = UDim2.fromOffset(40, 22)
        tr.Position = UDim2.new(1, -54, 0.5, -11)
        tr.BackgroundColor3 = st and Color3.fromRGB(255,255,255) or COL.off
        tr.BackgroundTransparency = st and 0 or 0.1
        tr.BorderSizePixel = 0
        tr.ZIndex = 15
        cR(tr, 3)

        local k = Instance.new("Frame", tr)
        k.Size = UDim2.fromOffset(16, 16)
        k.Position = st and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        k.BackgroundColor3 = Color3.fromRGB(255,255,255)
        k.BorderSizePixel = 0
        k.ZIndex = 16
        cR(k, 2)

        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 17
        btn.MouseButton1Click:Connect(function()
            st = not st
            TS:Create(k, TweenInfo.new(0.15), {
                Position = st and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            }):Play()
            TS:Create(tr, TweenInfo.new(0.15), {
                BackgroundColor3 = st and Color3.fromRGB(255,255,255) or COL.off,
                BackgroundTransparency = st and 0 or 0.1
            }):Play()
            if c.Callback then pcall(c.Callback, st) end
        end)
        self.Y = self.Y + 48
        return self
    end

    function t:Sl(id, c)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1, -8, 0, 56)
        row.Position = UDim2.fromOffset(4, self.Y)
        row.BackgroundColor3 = COL.cardB
        row.BackgroundTransparency = 0.7
        row.BorderSizePixel = 0
        row.ZIndex = 14
        cR(row, 6)

        local l2 = Instance.new("TextLabel", row)
        l2.Size = UDim2.new(1, -80, 0, 18)
        l2.Position = UDim2.fromOffset(14, 9)
        l2.BackgroundTransparency = 1
        l2.Text = c.Title or id
        l2.TextColor3 = COL.tx
        l2.Font = Enum.Font.GothamMedium
        l2.TextSize = 12
        l2.TextXAlignment = Enum.TextXAlignment.Left
        l2.ZIndex = 15

        local vL = Instance.new("TextLabel", row)
        vL.Size = UDim2.fromOffset(56, 18)
        vL.Position = UDim2.new(1, -70, 0, 9)
        vL.BackgroundTransparency = 1
        vL.Text = tostring(c.Default or c.Min or 0)
        vL.TextColor3 = Color3.fromRGB(255,255,255)
        vL.Font = Enum.Font.GothamBold
        vL.TextSize = 12
        vL.TextXAlignment = Enum.TextXAlignment.Right
        vL.ZIndex = 15

        local tr = Instance.new("Frame", row)
        tr.Size = UDim2.new(1, -28, 0, 4)
        tr.Position = UDim2.new(0, 14, 1, -16)
        tr.BackgroundColor3 = Color3.fromRGB(70,70,80)
        tr.BackgroundTransparency = 0.3
        tr.BorderSizePixel = 0
        tr.ZIndex = 15
        cR(tr, 2)

        local mn, mx = c.Min or 0, c.Max or 100
        local pct = ((c.Default or mn) - mn) / (mx - mn)

        local f = Instance.new("Frame", tr)
        f.Size = UDim2.new(pct, 0, 1, 0)
        f.BackgroundColor3 = Color3.fromRGB(255,255,255)
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
            local a = math.clamp((x - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
            local v = math.floor(mn + (mx - mn) * a + 0.5)
            f.Size = UDim2.new(a, 0, 1, 0)
            k.Position = UDim2.new(a, -7, 0.5, -7)
            vL.Text = tostring(v)
            if c.Callback then pcall(c.Callback, v) end
        end
        local hb = Instance.new("TextButton", row)
        hb.Size = UDim2.new(1, -20, 0, 26)
        hb.Position = UDim2.new(0, 10, 1, -30)
        hb.BackgroundTransparency = 1
        hb.Text = ""
        hb.ZIndex = 18
        hb.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dg = true
                upd(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                upd(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dg = false
            end
        end)
        self.Y = self.Y + 62
        return self
    end

    self.T[n] = t
    self.TB[n] = b
    SideL.CanvasSize = UDim2.new(0, 0, 0, self.Cnt * 38 + 8)
    if not self.Cur then self:Show(n) end
    return t
end

-- TABS
local TInfo = W:AddTab({ Title = "Info" })
local TSurv = W:AddTab({ Title = "Survivor" })
local TKil  = W:AddTab({ Title = "Killer" })
local TEsp  = W:AddTab({ Title = "ESP" })
local TMisc = W:AddTab({ Title = "Misc" })

TInfo:Banner({ Image = IMG })
TInfo:Sec("KALZZ HUB")
TInfo:Btn({ Title = "Copy Discord Invite", Callback = function()
    pcall(function() if setclipboard then setclipboard("https://" .. INVITE) end end)
end})
TInfo:Btn({ Title = "Print Remotes", Callback = function()
    print("[KZ] ToF:", S.RC.tof, "| Veil:", S.RC.veil, "| Parry:", S.RC.parry, "| FV:", S.RC.fastvault)
end})
TInfo:Btn({ Title = "Print Handlers", Callback = function()
    for i, h in ipairs(S.Hooks.list) do print(i, h.name, h.prio) end
end})

TSurv:Sec("Silent Aim (ToF)")
TSurv:Tog("tof_on", { Title = "Enable ToF", Default = CFG.tof_on, Callback = function(v) CFG.tof_on = v end })
TSurv:Tog("tof_show_fov", { Title = "Show FOV Circle", Default = CFG.tof_show_fov, Callback = function(v) CFG.tof_show_fov = v end })
TSurv:Sl("tof_fov", { Title = "FOV", Min = 1, Max = 600, Default = CFG.tof_fov, Callback = function(v) CFG.tof_fov = v end })
TSurv:Sl("tof_predict", { Title = "Predict x10", Min = 10, Max = 50, Default = math.floor(CFG.tof_predict * 10), Callback = function(v) CFG.tof_predict = v / 10 end })
TSurv:Sl("tof_maxdist", { Title = "Max Distance", Min = 100, Max = 3000, Default = CFG.tof_maxdist, Callback = function(v) CFG.tof_maxdist = v end })

TSurv:Sec("Auto Parry")
TSurv:Tog("parry_on", { Title = "Enable Parry", Default = CFG.parry_on, Callback = function(v) CFG.parry_on = v end })
TSurv:Tog("parry_show_circle", { Title = "Show Parry Circle", Default = CFG.parry_show_circle, Callback = function(v) CFG.parry_show_circle = v end })
TSurv:Sl("parry_radius", { Title = "Sensitiv", Min = 100, Max = 10000, Default = CFG.parry_radius, Callback = function(v) CFG.parry_radius = v end })

TSurv:Sec("Movement")
TSurv:Tog("fast_vault", { Title = "Fast Vault", Default = CFG.fast_vault, Callback = function(v) CFG.fast_vault = v end })

TKil:Sec("Silent Aim (Veil)")
TKil:Tog("veil_on", { Title = "Enable Veil", Default = CFG.veil_on, Callback = function(v) CFG.veil_on = v end })
TKil:Tog("veil_show_fov", { Title = "Show FOV Circle", Default = CFG.veil_show_fov, Callback = function(v) CFG.veil_show_fov = v end })
TKil:Sl("veil_fov", { Title = "FOV", Min = 1, Max = 600, Default = CFG.veil_fov, Callback = function(v) CFG.veil_fov = v end })
TKil:Sl("veil_predict", { Title = "Predict x10", Min = 10, Max = 50, Default = math.floor(CFG.veil_predict * 10), Callback = function(v) CFG.veil_predict = v / 10 end })
TKil:Sl("veil_maxdist", { Title = "Max Distance", Min = 100, Max = 3000, Default = CFG.veil_maxdist, Callback = function(v) CFG.veil_maxdist = v end })

TEsp:Sec("Player ESP")
TEsp:Tog("esp_k", { Title = "Killer ESP", Default = CFG.esp_k, Callback = function(v) CFG.esp_k = v end })
TEsp:Tog("esp_s", { Title = "Survivor ESP", Default = CFG.esp_s, Callback = function(v) CFG.esp_s = v end })
TEsp:Tog("esp_item", { Title = "Show Item Name", Default = CFG.esp_item, Callback = function(v) CFG.esp_item = v end })

TEsp:Sec("Generator ESP")
TEsp:Tog("esp_g", { Title = "Generator ESP", Default = CFG.esp_g, Callback = function(v) CFG.esp_g = v end })
TEsp:Tog("esp_gen_txt", { Title = "Show Progress Text", Default = CFG.esp_gen_txt, Callback = function(v) CFG.esp_gen_txt = v end })

TEsp:Sec("Style")
TEsp:Tog("esp_out", { Title = "Outline Only", Default = CFG.esp_out, Callback = function(v) CFG.esp_out = v end })

TMisc:Sec("Vision")
TMisc:Tog("fov_lock", { Title = "FOV Lock", Default = CFG.fov_lock, Callback = function(v) CFG.fov_lock = v end })
TMisc:Sl("fov_value", { Title = "FOV Value", Min = 60, Max = 140, Default = CFG.fov_value, Callback = function(v) CFG.fov_value = v end })
TMisc:Tog("ambient", { Title = "Bright Ambient", Default = CFG.ambient, Callback = function(v) CFG.ambient = v end })
TMisc:Tog("boost_fps", { Title = "Boost FPS", Default = CFG.boost_fps, Callback = function(v)
    CFG.boost_fps = v
    pcall(function() if v then setfpscap(240) else setfpscap(0) end end)
end})

TMisc:Sec("Alerts")
TMisc:Tog("alert", { Title = "Proximity Alert", Default = CFG.alert, Callback = function(v) CFG.alert = v end })
TMisc:Tog("stun_on", { Title = "Stun Killer Notif", Default = CFG.stun_on, Callback = function(v) CFG.stun_on = v end })

TMisc:Sec("UI")
TMisc:Btn({ Title = "Hide UI (Float Mode)", Callback = function()
    if _G.KZ_ToggleUI then _G.KZ_ToggleUI() end
end})

W:Show("Info")

-- FLOAT BUTTON
pcall(function()
    local FG = Instance.new("ScreenGui")
    FG.Name = "KZ_Float_" .. tostring(os.time())
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
    FB.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    bgStroke.Color = Color3.fromRGB(255, 255, 255)
    bgStroke.Thickness = 2
    bgStroke.Transparency = 0.5

    _G.KZ_FloatButton = FB
    local fD, fStart, fPos, fMoved = false, nil, nil, false
    FB.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            fD = true
            fMoved = false
            fStart = i.Position
            fPos = FB.Position
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

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.V then CFG.tof_on = not CFG.tof_on end
    if i.KeyCode == Enum.KeyCode.B then CFG.veil_on = not CFG.veil_on end
    if i.KeyCode == Enum.KeyCode.RightShift then
        if _G.KZ_ToggleUI then _G.KZ_ToggleUI() end
    end
end)

print("[KZ] UI module loaded")
