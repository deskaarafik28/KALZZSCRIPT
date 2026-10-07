-- === ui.lua ===
Register("ui", function(S)
    local P, LP, PG, CG = S.P, S.LP, S.PG, S.CG
    local UIS, TS, RSvc = S.UIS, S.TS, S.RSvc
    local CFG, SaveConfig = S.CFG, S.SaveConfig
    local INV, IMG = "dCYTep9cY", "rbxassetid://134442738689157"

    -- ─── Colors ───
    local COL = {
        bg=Color3.fromRGB(15,15,18), panel=Color3.fromRGB(20,20,24), side=Color3.fromRGB(17,17,21),
        card=Color3.fromRGB(26,26,32), tabOn=Color3.fromRGB(38,38,46), brd=Color3.fromRGB(48,48,56),
        brdS=Color3.fromRGB(38,38,46), tx=Color3.fromRGB(240,240,245), txD=Color3.fromRGB(160,160,175),
        txF=Color3.fromRGB(110,110,125), acc=Color3.fromRGB(100,140,230), off=Color3.fromRGB(52,52,62),
    }
    local TR, TRP, TRC = 0.30, 0.30, 0.50

    local function cR(o, r)
        local c = Instance.new("UICorner", o)
        c.CornerRadius = UDim.new(0, r or 8)
        return c
    end
    local function cS(o, c, t, tr)
        local s = Instance.new("UIStroke", o)
        s.Color = c or COL.brd
        s.Thickness = t or 1
        s.Transparency = tr or 0.4
        return s
    end

    -- ─── Root GUI ───
    local GUI = Instance.new("ScreenGui")
    GUI.Name = "KalzzHub"
    GUI.ResetOnSpawn = false
    GUI.IgnoreGuiInset = true
    GUI.DisplayOrder = 999999
    GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if gethui then GUI.Parent = gethui() else GUI.Parent = CG end end)
    if not GUI.Parent then GUI.Parent = PG end
    Instance.new("UIScale", GUI).Scale = 0.80

    -- ─── Main Window ───
    local Main = Instance.new("Frame", GUI)
    Main.Size = UDim2.fromOffset(580, 480)
    Main.Position = UDim2.new(0.5, -290, 0.5, -240)
    Main.BackgroundColor3 = COL.bg
    Main.BackgroundTransparency = TR
    Main.BorderSizePixel = 0
    Main.ZIndex = 10
    cR(Main, 10); cS(Main, COL.brd, 1, 0.4)

    -- ─── Header ───
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
    Title.Text = "KALZZ HUB v1"
    Title.TextColor3 = COL.tx
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 12

    local Sub = Instance.new("TextLabel", Hdr)
    Sub.Size = UDim2.new(1, -140, 0, 14)
    Sub.Position = UDim2.fromOffset(18, 28)
    Sub.BackgroundTransparency = 1
    Sub.Text = "discord.gg/"..INV
    Sub.TextColor3 = COL.txF
    Sub.Font = Enum.Font.Gotham
    Sub.TextSize = 10
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.ZIndex = 12

    -- ─── Window buttons ───
    local function mkX(x)
        local b = Instance.new("TextButton", Hdr)
        b.Size = UDim2.fromOffset(26, 26)
        b.Position = UDim2.new(1, x, 0.5, -13)
        b.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
        b.BackgroundTransparency = 0.25
        b.Text = ""
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.ZIndex = 12
        cR(b, 6)
        for _, rot in ipairs({45, -45}) do
            local l = Instance.new("Frame", b)
            l.Size = UDim2.fromOffset(12, 2)
            l.Position = UDim2.new(0.5, -6, 0.5, -1)
            l.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
        b.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
        b.BackgroundTransparency = 0.25
        b.Text = ""
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.ZIndex = 12
        cR(b, 6)
        local l = Instance.new("Frame", b)
        l.Size = UDim2.fromOffset(12, 2)
        l.Position = UDim2.new(0.5, -6, 0.5, -1)
        l.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        l.BorderSizePixel = 0
        l.ZIndex = 13
        cR(l, 1)
        return b
    end
    local MinB = mkM(-68)
    local ClsB = mkX(-36)

    -- ─── Drag ───
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
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drg = false
        end
    end)

    -- ─── Sidebar ───
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

    -- ─── Content Area ───
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

    -- ─── Window Manager ───
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
            if l then TS:Create(l, TweenInfo.new(0.15), {
                TextColor3 = a and COL.tx or COL.txD
            }):Play() end
        end
        self.Cur = n
        CT.Text = n
    end

    function W:AddTab(cfg)
        local n = cfg.Title
        self.Cnt = self.Cnt + 1
        local i = self.Cnt - 1

        -- Tab button
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

        -- Tab page
        local p = Instance.new("Frame", CSL)
        p.Size = UDim2.new(1, 0, 0, 2000)
        p.BackgroundTransparency = 1
        p.Visible = false
        p.ZIndex = 13

        local t = { P = p, Y = 4 }

        -- ─── Section ───
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

        -- ─── Banner ───
        function t:Banner(cfg)
            local bc = Instance.new("Frame", p)
            bc.Size = UDim2.new(1, -8, 0, 140)
            bc.Position = UDim2.fromOffset(4, self.Y)
            bc.BackgroundColor3 = COL.card
            bc.BackgroundTransparency = TRC
            bc.BorderSizePixel = 0
            bc.ZIndex = 14
            cR(bc, 8); cS(bc, COL.brdS, 1, 0.5)

            local img = Instance.new("ImageLabel", bc)
            img.Size = UDim2.new(1, -12, 1, -12)
            img.Position = UDim2.fromOffset(6, 6)
            img.BackgroundTransparency = 1
            img.Image = cfg.Image or IMG
            img.ScaleType = Enum.ScaleType.Crop
            img.ZIndex = 15
            cR(img, 6)
            self.Y = self.Y + 152
            return self
        end

        -- ─── Button ───
        function t:Btn(cfg)
            local bb = Instance.new("TextButton", p)
            bb.Size = UDim2.new(1, -8, 0, 38)
            bb.Position = UDim2.fromOffset(4, self.Y)
            bb.BackgroundColor3 = COL.card
            bb.BackgroundTransparency = TRC
            bb.BorderSizePixel = 0
            bb.Text = ""
            bb.AutoButtonColor = false
            bb.ZIndex = 14
            cR(bb, 8); cS(bb, COL.brdS, 1, 0.5)

            local lbl = Instance.new("TextLabel", bb)
            lbl.Size = UDim2.new(1, -20, 1, 0)
            lbl.Position = UDim2.fromOffset(14, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = cfg.Title
            lbl.TextColor3 = COL.tx
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 15

            bb.MouseButton1Click:Connect(function()
                if cfg.Callback then pcall(cfg.Callback) end
            end)
            self.Y = self.Y + 44
            return self
        end

        -- ─── Paragraph ───
        function t:Par(cfg)
            local cc = Instance.new("Frame", p)
            cc.Size = UDim2.new(1, -8, 0, 60)
            cc.Position = UDim2.fromOffset(4, self.Y)
            cc.BackgroundColor3 = COL.card
            cc.BackgroundTransparency = TRC
            cc.BorderSizePixel = 0
            cc.ZIndex = 14
            cR(cc, 8); cS(cc, COL.brdS, 1, 0.5)

            local tt = Instance.new("TextLabel", cc)
            tt.Size = UDim2.new(1, -24, 0, 18)
            tt.Position = UDim2.fromOffset(14, 10)
            tt.BackgroundTransparency = 1
            tt.Text = cfg.Title or ""
            tt.TextColor3 = COL.tx
            tt.Font = Enum.Font.GothamBold
            tt.TextSize = 13
            tt.TextXAlignment = Enum.TextXAlignment.Left
            tt.ZIndex = 15

            local dd = Instance.new("TextLabel", cc)
            dd.Size = UDim2.new(1, -24, 0, 28)
            dd.Position = UDim2.fromOffset(14, 28)
            dd.BackgroundTransparency = 1
            dd.Text = cfg.Content or ""
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

        -- ─── Toggle ───
        function t:Tog(id, cfg)
            local row = Instance.new("Frame", p)
            row.Size = UDim2.new(1, -8, 0, 42)
            row.Position = UDim2.fromOffset(4, self.Y)
            row.BackgroundColor3 = COL.card
            row.BackgroundTransparency = TRC
            row.BorderSizePixel = 0
            row.ZIndex = 14
            cR(row, 8); cS(row, COL.brdS, 1, 0.5)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -80, 1, 0)
            lbl.Position = UDim2.fromOffset(14, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = cfg.Title or id
            lbl.TextColor3 = COL.tx
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 15

            local st = cfg.Default or false
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
            k.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
                TS:Create(k, TweenInfo.new(0.2), {
                    Position = st and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                }):Play()
                TS:Create(tr, TweenInfo.new(0.2), {
                    BackgroundColor3 = st and COL.acc or COL.off
                }):Play()
                if cfg.Callback then pcall(cfg.Callback, st) end
                if SaveConfig then SaveConfig() end
            end)
            self.Y = self.Y + 48
            return self
        end

        -- ─── Slider ───
        function t:Sl(id, cfg)
            local row = Instance.new("Frame", p)
            row.Size = UDim2.new(1, -8, 0, 56)
            row.Position = UDim2.fromOffset(4, self.Y)
            row.BackgroundColor3 = COL.card
            row.BackgroundTransparency = TRC
            row.BorderSizePixel = 0
            row.ZIndex = 14
            cR(row, 8); cS(row, COL.brdS, 1, 0.5)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -80, 0, 18)
            lbl.Position = UDim2.fromOffset(14, 9)
            lbl.BackgroundTransparency = 1
            lbl.Text = cfg.Title or id
            lbl.TextColor3 = COL.tx
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 15

            local vL = Instance.new("TextLabel", row)
            vL.Size = UDim2.fromOffset(56, 18)
            vL.Position = UDim2.new(1, -70, 0, 9)
            vL.BackgroundTransparency = 1
            vL.Text = tostring(cfg.Default or cfg.Min or 0)
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

            local mn, mx = cfg.Min or 0, cfg.Max or 100
            local pct = ((cfg.Default or mn) - mn) / (mx - mn)

            local f = Instance.new("Frame", tr)
            f.Size = UDim2.new(pct, 0, 1, 0)
            f.BackgroundColor3 = COL.acc
            f.BorderSizePixel = 0
            f.ZIndex = 16
            cR(f, 2)

            local k = Instance.new("Frame", tr)
            k.Size = UDim2.fromOffset(14, 14)
            k.Position = UDim2.new(pct, -7, 0.5, -7)
            k.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
                if cfg.Callback then pcall(cfg.Callback, v) end
                if SaveConfig then SaveConfig() end
            end

            local hb = Instance.new("TextButton", row)
            hb.Size = UDim2.new(1, -20, 0, 26)
            hb.Position = UDim2.new(0, 10, 1, -30)
            hb.BackgroundTransparency = 1
            hb.Text = ""
            hb.ZIndex = 18

            hb.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dg = true; upd(i.Position.X)
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

        -- ─── Dropdown ───
        function t:Drop(id, cfg)
            local row = Instance.new("Frame", p)
            row.Size = UDim2.new(1, -8, 0, 42)
            row.Position = UDim2.fromOffset(4, self.Y)
            row.BackgroundColor3 = COL.card
            row.BackgroundTransparency = TRC
            row.BorderSizePixel = 0
            row.ZIndex = 14
            cR(row, 8); cS(row, COL.brdS, 1, 0.5)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -140, 1, 0)
            lbl.Position = UDim2.fromOffset(14, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = cfg.Title or id
            lbl.TextColor3 = COL.tx
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 15

            local vs = cfg.Values or {}
            local cur = cfg.Default or vs[1] or "?"

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
            cR(hd, 8); cS(hd, COL.brd, 1, 0.4)

            for i, v in ipairs(vs) do
                local opt = Instance.new("TextButton", hd)
                opt.Size = UDim2.new(1, -8, 0, 28)
                opt.Position = UDim2.fromOffset(4, (i - 1) * 30 + 4)
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
                    TS:Create(hd, TweenInfo.new(0.2), { Size = UDim2.new(1, -8, 0, 0) }):Play()
                    task.delay(0.2, function() hd.Visible = false end)
                    if cfg.Callback then pcall(cfg.Callback, v) end
                    if SaveConfig then SaveConfig() end
                end)
            end

            local hH = math.min(#vs * 30 + 8, 150)
            btn.MouseButton1Click:Connect(function()
                if hd.Visible then
                    TS:Create(hd, TweenInfo.new(0.2), { Size = UDim2.new(1, -8, 0, 0) }):Play()
                    task.delay(0.2, function() hd.Visible = false end)
                else
                    hd.Visible = true
                    TS:Create(hd, TweenInfo.new(0.2), { Size = UDim2.new(1, -8, 0, hH) }):Play()
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

    -- ─── Return module API ───
    return {
        GUI = GUI,
        Main = Main,
        MinB = MinB,
        ClsB = ClsB,
        SideL = SideL,
        CSL = CSL,
        CT = CT,
        COL = COL,
        W = W,
        Show = function(n) W:Show(n) end,
        AddTab = function(cfg) return W:AddTab(cfg) end,
    }
end)
