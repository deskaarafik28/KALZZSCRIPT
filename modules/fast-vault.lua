-- ======================
-- FAST VAULT • SAFE & OPTIMIZED
-- VaultEvent true → anim → fastvault
-- ======================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local CFG = _G.KALZZ_CFG or {}
if CFG.fast_vault == nil then CFG.fast_vault = true end
_G.KALZZ_CFG = CFG

local Window = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Window")
if not Window then
    warn("[KZ FastVault] Window remote tidak ditemukan!")
    return
end

local FastVault = Window:FindFirstChild("fastvault")
local VaultEvent = Window:FindFirstChild("VaultEvent")
local VaultComplete = Window:FindFirstChild("VaultCompleteEvent")
local VaultCompleteP1 = Window:FindFirstChild("VaultCompleteEventpart1")
local SurvivorFastVault = Window:FindFirstChild("SurvivorFastVault")

local FAST_ANIM_ID = "83873880822918"
local last = 0

local function fireFast(char)
    if not CFG.fast_vault then return end
    local now = os.clock()
    if now - last < 0.12 then return end
    last = now

    -- Remote utama dari spy (Dikasih jeda biar ga di-kick anti-cheat)
    pcall(function()
        if FastVault then
            FastVault:FireServer(LP)           
            task.wait(0.01)
            FastVault:FireServer(char)
            task.wait(0.01)
            FastVault:FireServer()
        end
    end)
    
    pcall(function()
        if SurvivorFastVault and SurvivorFastVault:IsA("BindableEvent") then
            SurvivorFastVault:Fire()
        elseif SurvivorFastVault then
            SurvivorFastVault:FireServer()
        end
    end)
end

local function onAnim(track, char)
    if not CFG.fast_vault or not track or not track.Animation then return end
    local name = tostring(track.Animation.Name or ""):lower()
    local id = tostring(track.Animation.AnimationId or "")

    local isVault =
        name:find("vault") or name:find("window") or name:find("runningvault")
        or id:find(FAST_ANIM_ID) or id:find("83873880822918")

    if not isVault then return end

    -- natural speed
    pcall(function() track:AdjustSpeed(1) end)
    fireFast(char)
end

local function hookChar(char)
    task.spawn(function()
        local hum = char:WaitForChild("Humanoid", 8)
        if not hum then return end
        local an = hum:FindFirstChildOfClass("Animator")
        for _ = 1, 20 do
            if an then break end
            task.wait(0.15)
            an = hum:FindFirstChildOfClass("Animator")
        end
        if not an then return end

        an.AnimationPlayed:Connect(function(t)
            onAnim(t, char)
        end)
    end)
end

if LP.Character then hookChar(LP.Character) end
LP.CharacterAdded:Connect(hookChar)

-- ⭐ FIX TYPO: Hapus backslash di ~=
print("[KZ] Fast Vault spy-based loaded")
print("fastvault=", FastVault ~= nil, "VaultEvent=", VaultEvent ~= nil)
print("anim id=", FAST_ANIM_ID)
