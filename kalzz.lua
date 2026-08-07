--[[
    CYBER-AI 2046 - VIOLENCE DISTRICT
    DELTA EXECUTOR MOBILE VERSION
    BY YUKI
]]

local a=game
local b=a:GetService("Players")
local c=a:GetService("Workspace")
local d=a:GetService("ReplicatedStorage")
local e=a:GetService("UserInputService")
local f=a:GetService("VirtualInputManager")
local g=b.LocalPlayer
local h=g:FindFirstChild("PlayerGui")or g:WaitForChild("PlayerGui")

-- CONFIG
local C={
    PARRY=false,RANGE=5,MOON=false,OPT=false,
    PESP=false,KESP=false,GESP=false,GEN=false,METH="Instant"
}

-- CLEAN OLD
for _,v in ipairs(h:GetChildren())do
    if v.Name=="CAI_Main"or v.Name=="CAI_Btn"then v:Destroy()end
end

-- MAIN SCREEN
local S=Instance.new("ScreenGui")
S.Name="CAI_Main"
S.Parent=h
S.ResetOnSpawn=false

-- TOGGLE BUTTON
local B=Instance.new("TextButton")
B.Name="CAI_Btn"
B.Size=UDim2.new(0,50,0,50)
B.Position=UDim2.new(1,-60,1,-60)
B.Text="MENU"
B.TextColor3=Color3.fromRGB(0,255,200)
B.TextSize=14
B.Font=Enum.Font.SourceSansBold
B.BackgroundColor3=Color3.fromRGB(15,15,25)
B.BorderSizePixel=0
B.Active=true
B.Draggable=true
B.Parent=S
Instance.new("UICorner",B).CornerRadius=UDim.new(1,0)
Instance.new("UIStroke",B).Color=Color3.fromRGB(0,255,200)

-- MENU FRAME
local F=Instance.new("Frame")
F.Size=UDim2.new(0,300,0,220)
F.Position=UDim2.new(0.5,-150,0.5,-110)
F.BackgroundColor3=Color3.fromRGB(18,18,28)
F.BorderSizePixel=0
F.Active=true
F.Draggable=true
F.Visible=false
F.Parent=S
Instance.new("UICorner",F).CornerRadius=UDim.new(0,8)

-- TITLE
local T=Instance.new("TextLabel")
T.Size=UDim2.new(1,0,0,30)
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
X.Position=UDim2.new(1,-28,0,2)
X.Text="X"
X.TextColor3=Color3.fromRGB(200,200,200)
X.TextSize=14
X.Font=Enum.Font.SourceSansBold
X.BackgroundTransparency=1
X.Parent=T
X.MouseButton1Click:Connect(function()F.Visible=false end)

-- TABS
local TB={"MAIN","ESP","GEN"}
local P={}

for i,t in ipairs(TB)do
    local tb=Instance.new("TextButton")
    tb.Size=UDim2.new(0,70,0,28)
    tb.Position=UDim2.new(0,5+(i-1)*74,0,32)
    tb.Text=t
    tb.TextColor3=Color3.fromRGB(180,180,180)
    tb.TextSize=11
    tb.Font=Enum.Font.SourceSansBold
    tb.BackgroundColor3=Color3.fromRGB(30,30,42)
    tb.BorderSizePixel=0
    tb.Parent=F
    Instance.new("UICorner",tb).CornerRadius=UDim.new(0,4)
    
    local p=Instance.new("Frame")
    p.Size=UDim2.new(1,-80,1,-66)
    p.Position=UDim2.new(0,75,0,62)
    p.BackgroundColor3=Color3.fromRGB(24,24,36)
    p.BorderSizePixel=0
    p.Visible=(i==1)
    p.ClipsDescendants=true
    p.Parent=F
    Instance.new("UICorner",p).CornerRadius=UDim.new(0,5)
    
    -- Scroll dalem content
    local sc=Instance.new("ScrollingFrame")
    sc.Size=UDim2.new(1,-6,1,-6)
    sc.Position=UDim2.new(0,3,0,3)
    sc.BackgroundTransparency=1
    sc.BorderSizePixel=0
    sc.ScrollBarThickness=3
    sc.ScrollBarImageColor3=Color3.fromRGB(80,80,100)
    sc.CanvasSize=UDim2.new(0,0,0,0)
    sc.Parent=p
    
    local sl=Instance.new("UIListLayout",sc)
    sl.Padding=UDim.new(0,3)
    
    P[t]=sc
    
    tb.MouseButton1Click:Connect(function()
        for _,v in pairs(P)do v.Parent.Visible=false end
        p.Visible=true
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

-- TOGGLE FUNCTION
local function TG(p,t,d,c)
    local f=Instance.new("Frame",p)
    f.Size=UDim2.new(1,0,0,30)
    f.BackgroundColor3=Color3.fromRGB(34,34,46)
    f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,3)
    
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(0,140,1,0)
    l.Position=UDim2.new(0,5,0,0)
    l.Text=t
    l.TextColor3=Color3.fromRGB(220,220,220)
    l.TextSize=10
    l.Font=Enum.Font.SourceSans
    l.BackgroundTransparency=1
    l.TextXAlignment=Enum.TextXAlignment.Left
    
    local bg=Instance.new("Frame",f)
    bg.Size=UDim2.new(0,36,0,18)
    bg.Position=UDim2.new(1,-42,0.5,-9)
    bg.BackgroundColor3=d and Color3.fromRGB(0,200,130)or Color3.fromRGB(65,65,75)
    bg.BorderSizePixel=0
    Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)
    
    local dot=Instance.new("Frame",bg)
    dot.Size=UDim2.new(0,12,0,12)
    dot.Position=d and UDim2.new(0,22,0,3)or UDim2.new(0,2,0,3)
    dot.BackgroundColor3=Color3.fromRGB(255,255,255)
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    
    local o=d
    local cl=Instance.new("TextButton",f)
    cl.Size=UDim2.new(1,0,1,0)
    cl.BackgroundTransparency=1
    cl.Text=""
    cl.MouseButton1Click:Connect(function()
        o=not o
        bg.BackgroundColor3=o and Color3.fromRGB(0,200,130)or Color3.fromRGB(65,65,75)
        dot.Position=o and UDim2.new(0,22,0,3)or UDim2.new(0,2,0,3)
        c(o)
    end)
end

-- SLIDER FUNCTION
local function SL(p,t,min,max,d,c,s)
    s=s or""
    local f=Instance.new("Frame",p)
    f.Size=UDim2.new(1,0,0,50)
    f.BackgroundColor3=Color3.fromRGB(34,34,46)
    f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,3)
    
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,-10,0,14)
    l.Position=UDim2.new(0,5,0,4)
    l.Text=t..": "..d..s
    l.TextColor3=Color3.fromRGB(190,190,190)
    l.TextSize=9
    l.Font=Enum.Font.SourceSans
    l.BackgroundTransparency=1
    l.TextXAlignment=Enum.TextXAlignment.Left
    
    local tk=Instance.new("TextButton",f)
    tk.Size=UDim2.new(1,-10,0,18)
    tk.Position=UDim2.new(0,5,0,26)
    tk.BackgroundColor3=Color3.fromRGB(50,50,60)
    tk.BorderSizePixel=0
    tk.Text=""
    Instance.new("UICorner",tk).CornerRadius=UDim.new(0,3)
    
    local pc=(d-min)/(max-min)
    local fl=Instance.new("Frame",tk)
    fl.Size=UDim2.new(pc,0,1,0)
    fl.BackgroundColor3=Color3.fromRGB(0,200,255)
    fl.BorderSizePixel=0
    Instance.new("UICorner",fl).CornerRadius=UDim.new(0,3)
    
    local function up(input)
        local ps=tk.AbsolutePosition
        local sz=tk.AbsoluteSize
        local pt=math.clamp((input.Position.X-ps.X)/sz.X,0,1)
        local v=math.floor((min+(max-min)*pt)*10)/10
        fl.Size=UDim2.new(pt,0,1,0)
        l.Text=t..": "..v..s
        c(v)
    end
    
    tk.MouseButton1Click:Connect(function()
        local input={Position=Vector2.new(e:GetMouseLocation().X,e:GetMouseLocation().Y)}
        up(input)
    end)
    
    tk.MouseMoved:Connect(function(x,y)
        if e:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)then
            up({Position=Vector2.new(x,y)})
        end
    end)
end

-- DROPDOWN FUNCTION
local function DD(p,t,op,d,c)
    local f=Instance.new("Frame",p)
    f.Size=UDim2.new(1,0,0,30)
    f.BackgroundColor3=Color3.fromRGB(34,34,46)
    f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,3)
    
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(0,80,1,0)
    l.Position=UDim2.new(0,5,0,0)
    l.Text=t
    l.TextColor3=Color3.fromRGB(220,220,220)
    l.TextSize=10
    l.Font=Enum.Font.SourceSans
    l.BackgroundTransparency=1
    l.TextXAlignment=Enum.TextXAlignment.Left
    
    local sl=Instance.new("TextLabel",f)
    sl.Size=UDim2.new(0,100,1,0)
    sl.Position=UDim2.new(1,-105,0,0)
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
        dl.Size=UDim2.new(0,100,0,#op*24)
        dl.Position=UDim2.new(1,-100,1,0)
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

-- LABEL
local function LL(p,t)
    local l=Instance.new("TextLabel",p)
    l.Size=UDim2.new(1,0,0,18)
    l.Text=t
    l.TextColor3=Color3.fromRGB(150,150,150)
    l.TextSize=9
    l.Font=Enum.Font.SourceSans
    l.BackgroundTransparency=1
    l.TextXAlignment=Enum.TextXAlignment.Left
end

-- FILL MAIN TAB
TG(P["MAIN"],"Auto Parry",false,function(v)C.PARRY=v end)
SL(P["MAIN"],"Parry Range",1,30,5,function(v)C.RANGE=v end,"s")
TG(P["MAIN"],"Moonwalk",false,function(v)C.MOON=v end)
TG(P["MAIN"],"Optimal Mode",false,function(v)C.OPT=v end)
LL(P["MAIN"],"Optimal = all features ON")

-- FILL ESP TAB
TG(P["ESP"],"Player ESP",false,function(v)C.PESP=v end)
TG(P["ESP"],"Killer ESP (Red)",false,function(v)C.KESP=v end)
TG(P["ESP"],"Generator ESP",false,function(v)C.GESP=v end)

-- FILL GEN TAB
TG(P["GEN"],"Auto Generator",false,function(v)C.GEN=v end)
DD(P["GEN"],"Method",{"Instant","Normal","Perfect"},"Instant",function(v)C.METH=v end)

-- TOGGLE BUTTON CLICK
B.MouseButton1Click:Connect(function()
    F.Visible=not F.Visible
end)

-- ESP HIGHLIGHT SYSTEM
local ESPF=Instance.new("Folder",c)
ESPF.Name="CAI_ESP"

spawn(function()
    while wait(0.3)do
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
                    local hh=Instance.new("Highlight",ESPF)
                    hh.FillColor=cl
                    hh.FillTransparency=0.7
                    hh.OutlineColor=cl
                    hh.Adornee=ch
                end
            end
            
            if C.GESP then
                for _,ob in ipairs(c:GetDescendants())do
                    if ob:IsA("Model")and(ob.Name:lower():find("generator")or ob.Name:lower():find("gen"))then
                        local hh=Instance.new("Highlight",ESPF)
                        hh.FillColor=Color3.fromRGB(255,255,0)
                        hh.FillTransparency=0.7
                        hh.OutlineColor=Color3.fromRGB(255,255,0)
                        hh.Adornee=ob
                    end
                end
            end
        end)
    end
end)

-- AUTO PARRY
spawn(function()
    while wait(0.05)do
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
                        f:SendKeyEvent(true,"F",false,nil)
                        wait(0.05)
                        f:SendKeyEvent(false,"F",false,nil)
                        break
                    end
                end
            end
        end)
    end
end)

-- MOONWALK
spawn(function()
    while wait(0.05)do
        if not C.MOON then continue end
        pcall(function()
            local hm=g.Character and g.Character:FindFirstChild("Humanoid")
            if hm and hm.MoveDirection.Magnitude>0 then hm.WalkSpeed=-24 end
        end)
    end
end)

-- OPTIMAL
spawn(function()
    while wait(1)do
        if C.OPT then
            C.PARRY=true C.RANGE=30 C.MOON=false
            C.PESP=true C.KESP=true C.GESP=true
            C.GEN=true C.METH="Instant"
        end
    end
end)

-- AUTO GENERATOR
spawn(function()
    while wait(0.5)do
        if not C.GEN then continue end
        pcall(function()
            local ng=nil
            local nd=9999
            local rt=g.Character and g.Character:FindFirstChild("HumanoidRootPart")
            if not rt then continue end
            for _,ob in ipairs(c:GetDescendants())do
                if ob:IsA("Model")and(ob.Name:lower():find("generator")or ob.Name:lower():find("gen"))then
                    local gr=ob:FindFirstChild("Base")or ob.PrimaryPart
                    if gr then
                        local di=(gr.Position-rt.Position).Magnitude
                        if di<nd then nd=di ng=ob end
                    end
                end
            end
            if ng then
                local r=d:FindFirstChild("RepairGen")or d.Events:FindFirstChild("GeneratorRepair")
                if r then
                    if C.METH=="Instant"then r:FireServer(ng)r:FireServer(ng)r:FireServer(ng)end
                    if C.METH=="Perfect"then r:FireServer(ng,"Perfect")end
                    if C.METH=="Normal"then r:FireServer(ng)end
                end
            end
        end)
    end
end)

print("CYBER-AI 2046 LOADED - DELTA VERSION")
