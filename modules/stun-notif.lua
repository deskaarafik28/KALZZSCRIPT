--[[
    KALZZSCRIPT
    modules/stun-notif.lua - Stun Killer Notif
    Ring muter di kepala killer + toast slide-in
]]

local S = _G.KZ
if not S then return end

pcall(function()
    local stunHead, stunSpin = {}, 0
    local stunGui, stunCard, stunOn = nil, nil, false

    local function isStunned(ch)
        if not ch then return false end
        local h = ch:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then return false end
        if ch:GetAttribute("Stunned") == true or ch:GetAttribute("Stunned") == 1 then return true end
        if ch:GetAttribute("IsStunned") == true or ch:GetAttribute("stun") == true then return true end
        local ok, s = pcall(function() return h:GetState() end)
        if ok and s then
            if s == Enum.HumanoidStateType.FallingDown or s == Enum.HumanoidStateType.Ragdoll then
                return true
            end
        end
        return false
    end

    local function makeHead(root, cam)
        local bb = Instance.new("BillboardGui")
        bb.Name = "KZ_StunHead"
        bb.Size = UDim2.fromOffset(30, 30)
        bb.StudsOffset = Vector3.new(0, 3.4, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = root
        bb.Parent = cam

        local ring = Instance.new("Frame", bb)
        ring.Size = UDim2.fromScale(1, 1)
        ring.BackgroundTransparency = 1
        Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)

        local st = Instance.new("UIStroke", ring)
        st.Color = Color3.fromRGB(200, 200, 210)
        st.Thickness = 2.5
        st.Transparency = 0.25

        local g = Instance.new("UIGradient", st)
        g.Name = "G"
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.35, 0.2),
            NumberSequenceKeypoint.new(0.7, 1),
            NumberSequenceKeypoint.new(1, 1),
        })
        return bb
    end

    local function killHead(p)
        if stunHead[p] then pcall(function() stunHead[p]:Destroy() end) end
        stunHead[p] = nil
    end

    local function wipeToast()
        for _, g in ipairs(S.PG:GetChildren()) do
            if g.Name == "KZ_StunToast" then pcall(function() g:Destroy() end) end
        end
        stunGui, stunCard, stunOn = nil, nil, false
    end

    local function showToast()
        if stunOn and stunGui and stunGui.Parent then return end
        wipeToast()
        stunGui = Instance.new("ScreenGui")
        stunGui.Name = "KZ_StunToast"
        stunGui.ResetOnSpawn = false
        stunGui.IgnoreGuiInset = true
        stunGui.DisplayOrder = 1000005
        stunGui.Parent = S.PG

        stunCard = Instance.new("Frame", stunGui)
        stunCard.AnchorPoint = Vector2.new(1, 1)
        stunCard.Position = UDim2.new(1, 24, 1, -18)
        stunCard.Size = UDim2.fromOffset(132, 34)
        stunCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        stunCard.BackgroundTransparency = 0.4
        stunCard.BorderSizePixel = 0
        Instance.new("UICorner", stunCard).CornerRadius = UDim.new(0, 9)

        local stroke = Instance.new("UIStroke", stunCard)
        stroke.Color = Color3.fromRGB(170, 170, 180)
        stroke.Thickness = 1
        stroke.Transparency = 0.45

        local t = Instance.new("TextLabel", stunCard)
        t.Size = UDim2.new(1, 0, 1, 0)
        t.BackgroundTransparency = 1
        t.Text = "STUN KILLER"
        t.TextColor3 = Color3.fromRGB(220, 220, 230)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Center

        stunOn = true
        S.TS:Create(stunCard, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -12, 1, -18)
        }):Play()
    end

    S.RSvc.RenderStepped:Connect(function(dt)
        stunSpin = stunSpin + dt * 280

        if not S.CFG.stun_on then
            for _, p in ipairs(S.Players:GetPlayers()) do killHead(p) end
            if stunOn or stunGui then wipeToast() end
            return
        end

        local cam = S.Workspace.CurrentCamera
        if not cam then return end

        local any = false
        for _, p in ipairs(S.Players:GetPlayers()) do
            if not S.isKiller(p) then
                killHead(p)
                continue
            end
            local ch = p.Character
            local root = ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart)
            if root and isStunned(ch) then
                any = true
                if not stunHead[p] or not stunHead[p].Parent then
                    stunHead[p] = makeHead(root, cam)
                end
                local bb = stunHead[p]
                if bb.Parent ~= cam then bb.Parent = cam end
                bb.Adornee = root
                local g = bb:FindFirstChild("G", true)
                if g then g.Rotation = stunSpin % 360 end
            else
                killHead(p)
            end
        end

        if any then
            showToast()
        else
            if stunOn or stunGui then wipeToast() end
        end
    end)

    S.Players.PlayerRemoving:Connect(function(p) killHead(p) end)
end)

print("[KZ] stun-notif loaded")
