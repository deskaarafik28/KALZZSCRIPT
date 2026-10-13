local S = _G.KZ
if not S then return end

local LP = S.LP
local VIM = game:GetService("VirtualInputManager")
local IDS = {
    ["80411309607666"] = true,
    ["101344487600812"] = true,
}

local function root(m) return m and (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart) end

local function crouch()
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
    end)
end

local lastCrouch = 0

task.spawn(function()
    while task.wait(0.15) do
        if not S.CFG.crouch_on then continue end
        local my = root(LP.Character)
        if not my then continue end
        for _, p in ipairs(S.Players:GetPlayers()) do
            if p == LP or not p.Character then continue end
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local an = hum and hum:FindFirstChildOfClass("Animator")
            local kr = root(p.Character)
            if not an or not kr then continue end
            if (kr.Position - my.Position).Magnitude > 16 then continue end
            local ok, tr = pcall(function() return an:GetPlayingAnimationTracks() end)
            if ok and tr then
                for _, t in ipairs(tr) do
                    local id = tostring(t.Animation and t.Animation.AnimationId or ""):match("%d+") or ""
                    if IDS[id] and t.IsPlaying then
                        local now = os.clock()
                        if now - lastCrouch >= 1.5 then
                            lastCrouch = now
                            crouch()
                            task.wait(0.35)
                            crouch()
                        end
                    end
                end
            end
        end
    end
end)

print("[KZ] auto-crouch loaded")
