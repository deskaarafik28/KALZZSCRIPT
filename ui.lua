-- === ui.lua ===
local UI = {}

function UI.Initialize(KZ)
    local P = game:GetService("Players")
    local LP = P.LocalPlayer
    local PG = LP:WaitForChild("PlayerGui")
    local CG = game:GetService("CoreGui")
    local WS = game:GetService("Workspace")
    local Cam = WS.CurrentCamera
    local UIS = game:GetService("UserInputService")
    local TS = game:GetService("TweenService")
    
    local CFG = KZ.Config
    local Sched = KZ.Utils.Scheduler
    
    local COL = {
        bg=Color3.fromRGB(15,15,18), panel=Color3.fromRGB(20,20,24), side=Color3.fromRGB(17,17,21),
        card=Color3.fromRGB(26,26,32), tabOn=Color3.fromRGB(38,38,46), brd=Color3.fromRGB(48,48,56),
        brdS=Color3.fromRGB(38,38,46), tx=Color3.fromRGB(240,240,245), txD=Color3.fromRGB(160,160,175),
        txF=Color3.fromRGB(110,110,125), acc=Color3.fromRGB(100,140,230), off=Color3.fromRGB(52,52,62),
    }
    
    local function cR(o,r) local c=Instance.new("UICorner",o) c.CornerRadius=UDim.new(0,r or 8) return c end
    local function cS(o,c,t,tr) local s=Instance.new("UIStroke",o) s.Color=c or COL.brd s.Thickness=t or 1 s.Transparency=tr or 0.4 return s end
    
    -- Main GUI
    local GUI = Instance.new("ScreenGui")
    GUI.Name = "KalzzHub"
    GUI.ResetOnSpawn = false
    GUI.IgnoreGuiInset = true
    GUI.DisplayOrder = 999999
    GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if gethui then GUI.Parent = gethui() else GUI.Parent = CG end end)
    if not GUI.Parent then GUI.Parent = PG end
    Instance.new("UIScale", GUI).Scale = 0.80
    
    local Main = Instance.new("Frame", GUI)
    Main.Size = UDim2.fromOffset(580, 480)
    Main.Position = UDim2.new(0.5,-290,0.5,-240)
    Main.BackgroundColor3 = COL.bg
    Main.BackgroundTransparency = 0.30
    Main.BorderSizePixel = 0
    Main.ZIndex = 10
    cR(Main,10); cS(Main,COL.brd,1,0.4)
    
    -- Header
    local Hdr = Instance.new("Frame", Main)
    Hdr.Size = UDim2.new(1,0,0,48)
    Hdr.BackgroundColor3 = COL.panel
    Hdr.BackgroundTransparency = 0.30
    Hdr.BorderSizePixel = 0
    Hdr.ZIndex = 11
    cR(Hdr,10)
    
    local Title = Instance.new("TextLabel", Hdr)
    Title.Size = UDim2.new(1,-140,0,20)
    Title.Position = UDim2.fromOffset(18,8)
    Title.BackgroundTransparency = 1
    Title.Text = "KALZZ HUB v1"
    Title.TextColor3 = COL.tx
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 12
    
    local Sub = Instance.new("TextLabel", Hdr)
    Sub.Size = UDim2.new(1,-140,0,14)
    Sub.Position = UDim2.fromOffset(18,28)
    Sub.BackgroundTransparency = 1
    Sub.Text = "discord.gg/dCYTep9cY"
    Sub.TextColor3 = COL.txF
    Sub.Font = Enum.Font.Gotham
    Sub.TextSize = 10
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.ZIndex = 12
    
    -- Close Button
    local ClsB = Instance.new("TextButton", Hdr)
    ClsB.Size = UDim2.fromOffset(26,26)
    ClsB.Position = UDim2.new(1,-36,0.5,-13)
    ClsB.BackgroundColor3 = Color3.fromRGB(220,80,80)
    ClsB.BackgroundTransparency = 0.25
    ClsB.Text = ""
    ClsB.BorderSizePixel = 0
    ClsB.AutoButtonColor = false
    ClsB.ZIndex = 12
    cR(ClsB,6)
    
    for _, rot in ipairs({45,-45}) do
        local l = Instance.new("Frame", ClsB)
        l.Size = UDim2.fromOffset(12,2)
        l.Position = UDim2.new(0.5,-6,0.5,-1)
        l.BackgroundColor3 = Color3.fromRGB(255,255,255)
        l.BorderSizePixel = 0
        l.ZIndex = 13
        cR(l,1)
        l.Rotation = rot
    end
    
    -- Minimize Button
    local MinB = Instance.new("TextButton", Hdr)
    MinB.Size = UDim2.fromOffset(26,26)
    MinB.Position = UDim2.new(1,-68,0.5,-13)
    MinB.BackgroundColor3 = Color3.fromRGB(60,60,75)
    MinB.BackgroundTransparency = 0.25
    MinB.Text = ""
    MinB.BorderSizePixel = 0
    MinB.AutoButtonColor = false
    MinB.ZIndex = 12
    cR(MinB,6)
    
    local l = Instance.new("Frame", MinB)
    l.Size = UDim2.fromOffset(12,2)
    l.Position = UDim2.new(0.5,-6,0.5,-1)
    l.BackgroundColor3 = Color3.fromRGB(255,255,255)
    l.BorderSizePixel = 0
    l.ZIndex = 13
    cR(l,1)
    
    -- Dragging
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
    
    -- Side panel
    local Side = Instance.new("Frame", Main)
    Side.Size = UDim2.new(0,150,1,-58)
    Side.Position = UDim2.fromOffset(8,54)
    Side.BackgroundColor3 = COL.side
    Side.BackgroundTransparency = 0.30
    Side.BorderSizePixel = 0
    Side.ZIndex = 11
    cR(Side,8)
    
    local SideL = Instance.new("ScrollingFrame", Side)
    SideL.Size = UDim2.new(1,-8,1,-8)
    SideL.Position = UDim2.fromOffset(4,4)
    SideL.BackgroundTransparency = 1
    SideL.BorderSizePixel = 0
    SideL.ScrollBarThickness = 2
    SideL.ScrollBarImageColor3 = COL.brd
    SideL.CanvasSize = UDim2.new(0,0,0,300)
    SideL.ZIndex = 12
    
    -- Content panel
    local Cont = Instance.new("Frame", Main)
    Cont.Size = UDim2.new(1,-172,1,-58)
    Cont.Position = UDim2.fromOffset(162,54)
    Cont.BackgroundColor3 = COL.bg
    Cont.BackgroundTransparency = 0.30
    Cont.BorderSizePixel = 0
    Cont.ZIndex = 11
    cR(Cont,8)
    
    local CT = Instance.new("TextLabel", Cont)
    CT.Size = UDim2.new(1,-32,0,22)
    CT.Position = UDim2.fromOffset(16,14)
    CT.BackgroundTransparency = 1
    CT.Text = ""
    CT.TextColor3 = COL.tx
    CT.Font = Enum.Font.GothamBold
    CT.TextSize = 16
    CT.TextXAlignment = Enum.TextXAlignment.Left
    CT.ZIndex = 12
    
    local CSL = Instance.new("ScrollingFrame", Cont)
    CSL.Size = UDim2.new(1,-16,1,-50)
    CSL.Position = UDim2.fromOffset(8,44)
    CSL.BackgroundTransparency = 1
    CSL.BorderSizePixel = 0
    CSL.ScrollBarThickness = 3
    CSL.ScrollBarImageColor3 = COL.brd
    CSL.CanvasSize = UDim2.new(0,0,0,2000)
    CSL.ZIndex = 12
    
    -- Widget system
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
        b.BackgroundTransparency = 1
        b.BorderSizePixel = 0
        b.Text = ""
        b.AutoButtonColor = false
        b.ZIndex = 13
        cR(b,6)
        local l = Instance.new("TextLabel", b)
        l.Name = "Lbl"
        l.Size = UDim2.new(1,-20,1,0)
        l.Position = UDim2.fromOffset(14,0)
        l.BackgroundTransparency = 1
        l.Text = n
        l.TextColor3 = COL.txD
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 14
        b.MouseButton1Click:Connect(function() W:Show(n) end)
        local p = Instance.new("Frame", CSL)
        p.Size = UDim2.new(1,0,0,2000)
        p.BackgroundTransparency = 1
        p.Visible = false
        p.ZIndex = 13
        local t = {P=p, Y=4}
        
        function t:Sec(s)
            local x = Instance.new("TextLabel", p)
            x.Size = UDim2.new(1,-8,0,24)
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
        
        function t:Tog(id, c)
            local row = Instance.new("Frame", p)
            row.Size = UDim2.new(1,-8,0,42)
            row.Position = UDim2.fromOffset(4, self.Y)
            row.BackgroundColor3 = COL.card
            row.BackgroundTransparency = 0.50
            row.BorderSizePixel = 0
            row.ZIndex = 14
            cR(row,8); cS(row,COL.brdS,1,0.5)
            local l = Instance.new("TextLabel", row)
            l.Size = UDim2.new(1,-80,1,0)
            l.Position = UDim2.fromOffset(14,0)
            l.BackgroundTransparency = 1
            l.Text = c.Title or id
            l.TextColor3 = COL.tx
            l.Font = Enum.Font.GothamMedium
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.ZIndex = 15
            local st = c.Default or false
            local tr = Instance.new("Frame", row)
            tr.Size = UDim2.fromOffset(40,22)
            tr.Position = UDim2.new(1,-54,0.5,-11)
            tr.BackgroundColor3 = st and COL.acc or COL.off
            tr.BackgroundTransparency = 0.1
            tr.BorderSizePixel = 0
            tr.ZIndex = 15
            cR(tr,11)
            local k = Instance.new("Frame", tr)
            k.Size = UDim2.fromOffset(16,16)
            k.Position = st and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,3,0.5,-8)
            k.BackgroundColor3 = Color3.fromRGB(255,255,255)
            k.BorderSizePixel = 0
            k.ZIndex = 16
            cR(k,8)
            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(1,0,1,0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 17
            btn.MouseButton1Click:Connect(function()
                st = not st
                TS:Create(k,TweenInfo.new(0.2),{Position=st and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
                TS:Create(tr,TweenInfo.new(0.2),{BackgroundColor3=st and COL.acc or COL.off}):Play()
                if c.Callback then pcall(c.Callback, st) end
            end)
            self.Y = self.Y + 48
            return self
        end
        
        function t:Btn(c)
            local b = Instance.new("TextButton", p)
            b.Size = UDim2.new(1,-8,0,38)
            b.Position = UDim2.fromOffset(4, self.Y)
            b.BackgroundColor3 = COL.card
            b.BackgroundTransparency = 0.50
            b.BorderSizePixel = 0
            b.Text = ""
            b.AutoButtonColor = false
            b.ZIndex = 14
            cR(b,8); cS(b,COL.brdS,1,0.5)
            local l = Instance.new("TextLabel", b)
            l.Size = UDim2.new(1,-20,1,0)
            l.Position = UDim2.fromOffset(14,0)
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
        
        self.T[n] = t
        self.TB[n] = b
        SideL.CanvasSize = UDim2.new(0,0,0, self.Cnt*38+8)
        if not self.Cur then self:Show(n) end
        return t
    end
    
    -- Load module tabs
    for name, module in pairs(KZ.Modules) do
        if module.CreateTab then
            module.CreateTab(W, CFG)
        end
    end
    
    ClsB.MouseButton1Click:Connect(function() Main.Visible = false end)
    MinB.MouseButton1Click:Connect(function() Main.Visible = false end)
    
    return {UI=W, Main=Main, GUI=GUI}
end

return UI
