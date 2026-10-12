--[[ KALZZSCRIPT | proximity-alert.lua ]]

local S = _G.KZ
if not S then return end

pcall(function()
    local ag = Instance.new("ScreenGui")
    ag.Name = "KZ_Alert"
    ag.ResetOnSpawn = false
    ag.IgnoreGuiInset = true
    ag.DisplayOrder = 1000001
    ag.Parent = S.PG

    local al = Instance.new("TextLabel", ag)
    al.Size = UDim2.fromOffset(300, 60)
    al.Position = UDim2.new(0.5, -150, 0.14, 0)
    al.BackgroundTransparency = 1
    al.TextColor3 = Color3.fromRGB(255, 255, 255)
    al.Font = Enum.Font.GothamBlack
    al.TextSize = 32
    al.TextStrokeTransparency = 0
    al.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    al.Visible = false

    task.spawn(function()
        while true do
            task.wait(0.2)
            if not S.CFG.alert then
                al.Visible = false
            else
                local mr = S.rtp(S.LP.Character)
                if mr then
                    local cl = math.huge
                    for _, pl in ipairs(S.Players:GetPlayers()) do
                        if pl ~= S.LP and pl.Character and S.isKiller(pl) then
                            local hrp = S.rtp(pl.Character)
                            if hrp then
                                local hu = pl.Character:FindFirstChildOfClass("Humanoid")
                                if hu and hu.Health > 0 then
                                    local d = (hrp.Position - mr.Position).Magnitude
                                    if d < cl then cl = d end
                                end
                            end
                        end
                    end
                    if cl < 26 then
                        local t
                        if cl <= 10 then t = "!!!"
                        elseif cl <= 17 then t = "!!"
                        else t = "!" end
                        al.Text = string.format("%s  (%.0f)", t, cl)
                        al.Visible = true
                    else
                        al.Visible = false
                    end
                else
                    al.Visible = false
                end
            end
        end
    end)
end)

print("[KZ] proximity-alert loaded")
