--[[
    CYBER-AI 2046 - VIOLENCE DISTRICT
    REMASTERED ULTRA LIGHT
    BY YUKI
]]

local a=game
local b=a:GetService("Players")
local c=a:GetService("RunService")
local d=a:GetService("UserInputService")
local e=a:GetService("Workspace")
local f=a:GetService("ReplicatedStorage")
local g=b.LocalPlayer
local h=g:WaitForChild("PlayerGui")

-- CONFIG
local C={
    PARRY=false,RANGE=5,MOON=false,OPT=false,
    PESP=false,KESP=false,GESP=false,GEN=false,METH="Instant"
}

-- CLEAN
for _,v in ipairs(h:GetChildren())do
    if v.Name=="CAI_Btn"or v.Name=="CAI_Menu"then v:Destroy()end
end

-- TOGGLE BUTTON
local S=Instance.new("ScreenGui")
S.Name="CAI_Btn"
S.Parent=h

local B=Instance.new("TextButton")
B.Size=UDim2.new(0,45,0,45)
B.Position=UDim2.new(1,-55,1,-55)
B.Text="[=]"
B.TextColor3=Color3.fromRGB(0,255,200)
B.TextSize=20
B.Font=Enum.Font.SourceSansBold
B.BackgroundColor3=Color3.fromRGB(15,15,30)
B.BorderSizePixel=0
B.Draggable=true
B.Parent=S
Instance.new("UICorner",B).CornerRadius=UDim.new(1,0)
Instance.new("UIStroke",B).Color=Color3.fromRGB(0,255,200)

-- MENU
local M=Instance.new("ScreenGui")
M.Name="CAI_Menu"
M.Parent=h

local F=Instance.new("Frame")
F.Size=UDim2.new(0,340,0,250)
F.Position=UDim2.new(0.5,-170,0.5,-125)
F.BackgroundColor3=Color3.fromRGB(18,18,28)
F.BorderSizePixel=0
F.Draggable=true
F.Visible=false
F.Parent=M
Instance.new("UICorner",F).CornerRadius=UDim.new(0,8)

-- TITLE
local T=Instance.new("TextLabel")
T.Size=UDim2.new(1,0,0,32)
T.BackgroundColor3=Color3.fromRGB(10,10,20)
T.Text="CYBER-AI 2046"
T.TextColor3=Color3.fromRGB(255,255,255)
T.TextSize=14
T.Font=Enum.Font.SourceSansBold
T.BorderSizePixel=0
T.Parent=F
Instance.new("UICorner",T).CornerRadius=UDim.new(0,8)

local X=Instance.new("TextButton")
X.Size=UDim2.new(0,26,0,26)
X.Position=UDim2.new(1,-30,0,3)
X.Text="X"
X.TextColor3=Color3.fromRGB(200,200,200)
X.TextSize=14
X.Font=Enum.Font.SourceSansBold
X.BackgroundTransparency=1
X.Parent=T
X.MouseButton1Click:Connect(function()F.Visible=false end)

-- TABS
local TB={"INFO","MAIN","ESP","SURVI"}
local P={}
local CT="INFO"

for i,t in ipairs(TB)do
    local tb=Instance.new("TextButton")
    tb.Size=UDim2.new(1,0,0,30)
    tb.Position=UDim2.new(0,0,0,32+(i-1)*32)
    tb.Text=t
    tb.TextColor3=Color3.fromRGB(180,180,180)
    tb.TextSize=11
    tb.Font=Enum.Font.SourceSansBold
    tb.BackgroundColor3=Color3.fromRGB(30,30,42)
    tb.BorderSizePixel=0
    tb.Parent=F
    Instance.new("UICorner",tb).CornerRadius=UDim.new(0,4)
    
    local p=Instance.new("Frame")
    p.Size=UDim2.new(1,-90,1,-40)
    p.Position=UDim2.new(0,82,0,36)
    p.BackgroundColor3=Color3.fromRGB(24,24,36)
    p.BorderSizePixel=0
    p.Visible=(i==1)
    p.ClipsDescendants=true
    p.Parent=F
    Instance.new("UICorner",p).CornerRadius=UDim.new(0,5)
    
    P[t]=p
    
    tb.MouseButton1Click:Connect(function()
        for _,v in pairs(P)do v.Visible=false end
        p.Visible=true
        CT=t
        for _,v in ipairs(F:GetChildren())do
            if v:IsA("TextButton")and table.find(TB,v.Text)then
                v.BackgroundColor3=Color3.fromRGB(30,30,42)
                v.TextColor3=Color3.fromRGB(180,180,180)
            end
        end
        tb.BackgroundColor3=Color3.fromRGB(0,180,220)
        tb.TextColor3=Color3.fromRGB(255,255,255)
    end)
end

-- SECTION LINE
local function L(p,t)
    local f=Instance.new("Frame",p)
    f.Size=UDim2.new(1,0,0,20)
    f.BackgroundTransparency=1
    local l=Instance.new("Frame",f)
    l.Size=UDim2.new(0,2,1,0)
    l.BackgroundColor3=Color3.fromRGB(0,200,255)
    Instance.new("UICorner",l).CornerRadius=UDim.new(1,0)
    local tt=Instance.new("TextLabel",f)
    tt.Size=UDim2.new(1,-8,1,0)
    tt.Position=UDim2.new(0,6,0,0)
    tt.Text=t
    tt.TextColor3=Color3.fromRGB(0,200,255)
    tt.TextSize=10
    tt.Font=Enum.Font.SourceSansBold
    tt.BackgroundTransparency=1
    tt.TextXAlignment=Enum.TextXAlignment.Left
end

-- LABEL
local function LL(p,t)
    local l=Instance.new("TextLabel",p)
    l.Size=UDim2.new(1,0,0,18)
    l.Text=t
    l.TextColor3=Color3.fromRGB(180,180,180)
    l.TextSize=10
    l.Font=Enum.Font.SourceSans
    l.BackgroundTransparency=1
    l.TextXAlignment=Enum.TextXAlignment.Left
end

-- TOGGLE
local function TG(p,t,d,c)
    local f=Instance.new("Frame",p)
    f.Size=UDim2.new(1,0,0,30)
    f.BackgroundColor3=Color3.fromRGB(34,34,46)
    f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,3)
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(0,160,1,0)
    l.Position=UDim2.new(0,6,0,0)
    l.Text=t
    l.TextColor3=Color3.fromRGB(220,220,220)
    l.TextSize=10
    l.Font=Enum.Font.SourceSans
    l.BackgroundTransparency=1
    l.TextXAlignment=Enum.TextXAlignment.Left
    local b=Instance.new("Frame",f)
    b.Size=UDim2.new(0,36,0,18)
    b.Position=UDim2.new(1,-44,0.5,-9)
    b.BackgroundColor3=d and Color3.fromRGB(0,200,130)or Color3.fromRGB(65,65,75)
    b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
    local dt=Instance.new("Frame",b)
    dt.Size=UDim2.new(0,12,0,12)
    dt.Position=d and UDim2.new(0,22,0,3)or UDim2.new(0,2,0,3)
    dt.BackgroundColor3=Color3.fromRGB(255,255,255)
    Instance.new("UICorner",dt).CornerRadius=UDim.new(1,0)
    local o=d
    local cl=Instance.new("TextButton",f)
    cl.Size=UDim2.new(1,0,1,0)
    cl.BackgroundTransparency=1
    cl.Text=""
    cl.MouseButton1Click:Connect(function()
        o=not o
        b.BackgroundColor3=o and Color3.fromRGB(0,200,130)or Color3.fromRGB(65,65,75)
        dt.Position=o and UDim2.new(0,22,0,3)or UDim2.new(0,2,0,3)
        c(o)
    end)
end

-- SLIDER
local function SL(p,t,min,max,d,c,s)
    s=s or""
    local f=Instance.new("Frame",p)
    f.Size=UDim2.new(1,0,0,55)
    f.BackgroundColor3=Color3.fromRGB(34,34,46)
    f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,3)
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,-12,0,16)
    l.Position=UDim2.new(0,6,0,4)
    l.Text=t..": "..d..s
    l.TextColor3=Color3.fromRGB(190,190,190)
    l.TextSize=9
    l.Font=Enum.Font.SourceSans
    l.BackgroundTransparency=1
    l.TextXAlignment=Enum.TextXAlignment.Left
    local tk=Instance.new("Frame",f)
    tk.Size=UDim2.new(1,-12,0,4)
    tk.Position=UDim2.new(0,6,0,30)
    tk.BackgroundColor3=Color3.fromRGB(50,50,60)
    Instance.new("UICorner",tk).CornerRadius=UDim.new(1,0)
    local pc=(d-min)/(max-min)
    local fl=Instance.new("Frame",tk)
    fl.Size=UDim2.new(pc,0,1,0)
    fl.BackgroundColor3=Color3.fromRGB(0,200,255)
    Instance.new("UICorner",fl).CornerRadius=UDim.new(1,0)
    local kn=Instance.new("Frame",tk)
    kn.Size=UDim2.new(0,10,0,10)
    kn.Position=UDim2.new(pc,-5,0.5,-5)
    kn.BackgroundColor3=Color3.fromRGB(255,255,255)
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
    local dr=false
    local function up(inp)
        local ps=tk.AbsolutePosition
        local sz=tk.AbsoluteSize
        local pt=math.clamp((inp.Position.X-ps.X)/sz.X,0,1)
        local v=math.floor((min+(max-min)*pt)*10)/10
        fl.Size=UDim2.new(pt,0,1,0)
        kn.Position=UDim2.new(pt,-5,0.5,-5)
        l.Text=t..": "..v..s
        c(v)
    end
    tk.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true up(i)end
    end)
    d.InputChanged:Connect(function(i)
        if dr and i.UserInputType==Enum.UserInputType.MouseMovement then up(i)end
    end)
    d.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end
    end)
end

-- DROPDOWN
local function DD(p,t,op,d,c)
    local f=Instance.new("Frame",p)
    f.Size=UDim2.new(1,0,0,30)
    f.BackgroundColor3=Color3.fromRGB(34,34,46)
    f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,3)
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(0,90,1,0)
    l.Position=UDim2.new(0,6,0,0)
    l.Text=t
    l.TextColor3=Color3.fromRGB(220,220,220)
    l.TextSize=10
    l.Font=Enum.Font.SourceSans
    l.BackgroundTransparency=1
    l.TextXAlignment=Enum.TextXAlignment.Left
    local sl=Instance.new("TextLabel",f)
    sl.Size=UDim2.new(0,110,1,0)
    sl.Position=UDim2.new(1,-120,0,0)
    sl.Text=d
    sl.TextColor3=Color3.fromRGB(0,200,255)
    sl.TextSize=10
    sl.Font=Enum.Font.SourceSansBold
    sl.BackgroundTransparency=1
    sl.TextXAlignment=Enum.TextXAlignment.Right
    local dl=nil
    local cl=Instance.new("TextButton",f)
    cl.Size=UDim2.new(1,0,1,0)
    cl.BackgroundTransparency=1
    cl.Text=""
    cl.MouseButton1Click:Connect(function()
        if dl and dl.Parent then dl:Destroy()return end
        dl=Instance.new("Frame",f)
        dl.Size=UDim2.new(0,110,0,#op*24)
        dl.Position=UDim2.new(1,-110,1,0)
        dl.BackgroundColor3=Color3.fromRGB(28,28,38)
        dl.BorderSizePixel=0
        dl.ZIndex=5
        Instance.new("UICorner",dl).CornerRadius=UDim.new(0,3)
        for _,o in ipairs(op)do
            local ob=Instance.new("TextButton",dl)
            ob.Size=UDim2.new(1,0,0,24)
            ob.Text=o
            ob.TextColor3=Color3.fromRGB(190,190,190)
            ob.TextSize=10
            ob.Font=Enum.Font.SourceSans
            ob.BackgroundColor3=Color3.fromRGB(36,36,48)
            ob.BorderSizePixel=0
            ob.ZIndex=6
            ob.MouseButton1Click:Connect(function()
                sl.Text=o
                c(o)
                dl:Destroy()
            end)
        end
    end)
end

-- FILL TABS
L(P["INFO"],"SCRIPT INFO")
LL(P["INFO"],"CYBER-AI 2046 v3.0")
LL(P["INFO"],"Violence District")
LL(P["INFO"],"Created by YUKI")

L(P["MAIN"],"AUTO PARRY")
TG(P["MAIN"],"Auto Parry",false,function(v)C.PARRY=v end)
SL(P["MAIN"],"Range",1,30,5,function(v)C.RANGE=v end,"s")

L(P["MAIN"],"MOONWALK")
TG(P["MAIN"],"Moonwalk",false,function(v)C.MOON=v end)

L(P["MAIN"],"OPTIMAL")
TG(P["MAIN"],"Optimal Mode",false,function(v)C.OPT=v end)

L(P["ESP"],"ESP PLAYER")
TG(P["ESP"],"Player ESP",false,function(v)C.PESP=v end)

L(P["ESP"],"ESP KILLER")
TG(P["ESP"],"Killer ESP (Red)",false,function(v)C.KESP=v end)

L(P["ESP"],"ESP GENERATOR")
TG(P["ESP"],"Gen ESP",false,function(v)C.GESP=v end)

L(P["SURVI"],"AUTO GENERATOR")
TG(P["SURVI"],"Auto Generator",false,function(v)C.GEN=v end)
DD(P["SURVI"],"Method",{"Instant","Normal","Perfect"},"Instant",function(v)C.METH=v end)

-- CLICK TOGGLE
B.MouseButton1Click:Connect(function()
    F.Visible=not F.Visible
end)

-- ESP SYSTEM (HIGHLIGHT ONLY)
local ESPF=Instance.new("Folder",e)
ESPF.Name="CAI_ESP"

spawn(function()
    while task.wait(0.2)do
        pcall(function()
            for _,v in ipairs(ESPF:GetChildren())do v:Destroy()end
            if not C.PESP and not C.KESP and not C.GESP then continue end
            if C.PESP or C.KESP then
                for _,pl in ipairs(b:GetPlayers())do
                    if pl==g then continue end
                    local ch=pl.Character
                    if not ch then continue end
                    local hm=ch:FindFirstChild("Humanoid")
                    if not hm or hm.Health<=0 then continue end
                    local isK=pl.Team and(pl.Team.Name=="Killer"or pl.Team.Name=="Hunter")
                    if isK and not C.KESP then continue end
                    if not isK and not C.PESP then continue end
                    local cl=isK and Color3.fromRGB(255,50,50)or Color3.fromRGB(0,255,100)
                    local h=Instance.new("Highlight",ESPF)
                    h.FillColor=cl
                    h.FillTransparency=0.7
                    h.OutlineColor=cl
                    h.Adornee=ch
                end
            end
            if C.GESP then
                for _,ob in ipairs(e:GetDescendants())do
                    if ob:IsA("Model")and(ob.Name:lower():find("generator")or ob.Name:lower():find("gen"))then
                        local h=Instance.new("Highlight",ESPF)
                        h.FillColor=Color3.fromRGB(255,255,0)
                        h.FillTransparency=0.7
                        h.OutlineColor=Color3.fromRGB(255,255,0)
                        h.Adornee=ob
                    end
                end
            end
        end)
    end
end)

-- AUTO PARRY
spawn(function()
    while task.wait(0.001)do
        if not C.PARRY then continue end
        pcall(function()
            for _,pl in ipairs(b:GetPlayers())do
                if pl==g or not pl.Team then continue end
                if pl.Team.Name~="Killer"and pl.Team.Name~="Hunter"then continue end
                local ch=pl.Character
                if not ch then continue end
                local hp=ch:FindFirstChild("HumanoidRootPart")
                local my=g.Character and g.Character:FindFirstChild("HumanoidRootPart")
                if not hp or not my then continue end
                if(hp.Position-my.Position).Magnitude>C.RANGE then continue end
                local hm=ch:FindFirstChild("Humanoid")
                if not hm then continue end
                local an=hm:FindFirstChild("Animator")
                if not an then continue end
                for _,t in ipairs(an:GetPlayingAnimationTracks())do
                    if t.Animation.AnimationId:lower():find("attack")then
                        keypress(0x46)task.wait(0.05)keyrelease(0x46)
                        break
                    end
                end
            end
        end)
    end
end)

-- MOONWALK
spawn(function()
    while task.wait(0.01)do
        if not C.MOON then continue end
        pcall(function()
            local hm=g.Character and g.Character:FindFirstChild("Humanoid")
            if hm and hm.MoveDirection.Magnitude>0 then hm.WalkSpeed=-24 end
        end)
    end
end)

-- OPTIMAL
spawn(function()
    while task.wait(1)do
        if C.OPT then
            C.PARRY=true C.RANGE=30 C.MOON=false
            C.PESP=true C.KESP=true C.GESP=true
            C.GEN=true C.METH="Instant"
        end
    end
end)

-- AUTO GEN
spawn(function()
    while task.wait(0.3)do
        if not C.GEN then continue end
        pcall(function()
            local ng=nil
            local nd=9999
            local rt=g.Character and g.Character:FindFirstChild("HumanoidRootPart")
            if not rt then continue end
            for _,ob in ipairs(e:GetDescendants())do
                if ob:IsA("Model")and(ob.Name:lower():find("generator")or ob.Name:lower():find("gen"))then
                    local gr=ob:FindFirstChild("Base")or ob.PrimaryPart
                    if gr then
                        local d=(gr.Position-rt.Position).Magnitude
                        if d<nd then nd=d ng=ob end
                    end
                end
            end
            if ng then
                local r=f:FindFirstChild("RepairGen")or f.Events:FindFirstChild("GeneratorRepair")
                if r then
                    if C.METH=="Instant"then r:FireServer(ng)r:FireServer(ng)r:FireServer(ng)end
                    if C.METH=="Perfect"then r:FireServer(ng,"Perfect")end
                    if C.METH=="Normal"then r:FireServer(ng)end
                end
            end
        end)
    end
end)

print("CYBER-AI 2046 LOADED - BY YUKI")
