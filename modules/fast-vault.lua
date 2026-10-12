--[[ KALZZSCRIPT | fast-vault.lua ]]

local S = _G.KZ
if not S then return end

pcall(function()
    local last = 0
    local function trig()
        if os.clock() - last < 0.3 then return end
        last = os.clock()
        if S.RC.fastvault then
            pcall(function() S.RC.fastvault:FireServer() end)
        end
    end

    local function apply(ch)
        local hum = ch:FindFirstChildOfClass("Humanoid")
        local anim = hum and hum:FindFirstChildOfClass("Animator")
        if not anim then return end
        anim.AnimationPlayed:Connect(function(track)
            if not S.CFG.fast_vault then return end
            if not track or not track.Animation then return end
            local n = (track.Animation.Name or ""):lower()
            if n:find("vault") or n:find("window") or n:find("climb") or n:find("pallet") then
                trig()
            end
        end)
    end

    S.LP.CharacterAdded:Connect(function(c)
        task.wait(1.2)
        apply(c)
    end)
    if S.LP.Character then
        task.spawn(function() apply(S.LP.Character) end)
    end
end)

print("[KZ] fast-vault loaded")
