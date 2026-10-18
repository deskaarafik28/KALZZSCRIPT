-- ======================
-- ALWAYS FAST VAULT • SAFE VERSION
-- Tanpa double hook, tanpa spam kick
-- ======================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local CFG = _G.KALZZ_CFG or {}
if CFG.fast_vault == nil then CFG.fast_vault = true end
_G.KALZZ_CFG = CFG

local Window
pcall(function() Window = RS:WaitForChild("Remotes"):WaitForChild("Window") end)

local R = {}
local function grab()
    if not Window then return end
    R.fast = Window:FindFirstChild("fastvault")
    R.survivor = Window:FindFirstChild("SurvivorFastVault")
end
grab()

local FAST_IDS = {
    ["83873880822918"] = true,
}

local lastFire = 0
local hooked = {}

local function applyFast(char)
    if not CFG.fast_vault then return end
    local now = os.clock()
    -- Cooldown 0.1 detik biar gak dianggap spam
    if now - lastFire < 0.1 then return end
    lastFire = now

    grab()

    -- ⭐ HANYA TEMBAK 1 REMOTE UTAMA (Anti-Kick)
    pcall(function()
        if R.fast then
            R.fast:FireServer(LP)           
            task.wait(0.01) -- Jeda 10ms
            R.fast:FireServer(char)
        end
    end)

    pcall(function()
        if R.survivor then
            if R.survivor:IsA("BindableEvent") then
                R.survivor:Fire()
            else
                R.survivor:FireServer()
            end
        end
    end)
end

local function isVaultAnim(t)
    if not t or not t.Animation then return false end
    local n = tostring(t.Animation.Name or ""):lower()
    local id = tostring(t.Animation.AnimationId or ""):match("%d+") or ""
    if FAST_IDS[id] then return true end
    if n:find("vault") or n:find("window") or n:find("runningvault") then
        return true
    end
    return false
end

local function hookChar(char)
    if not char or hooked[char] then return end
    hooked[char] = true

    task.spawn(function()
        local hum = char:WaitForChild("Humanoid", 10)
        if not hum then return end
        local an = hum:FindFirstChildOfClass("Animator")
        for _ = 1, 25 do
            if an then break end
            task.wait(0.12)
            an = hum:FindFirstChildOfClass("Animator")
            if not char.Parent then return end
        end
        if not an then return end

        -- ⭐ CUKUP PAKAI EVENT (Hapus while loop yang bikin lag)
        an.AnimationPlayed:Connect(function(t)
            if not CFG.fast_vault then return end
            if isVaultAnim(t) then
                pcall(function() t:AdjustSpeed(1) end)
                applyFast(char)
            end
        end)
    end)
end

if LP.Character then hookChar(LP.Character) end
LP.CharacterAdded:Connect(function(c)
    hooked[c] = nil
    task.wait(0.2)
    hookChar(c)
end)

-- Cek Window terus-terusan kalau misal dia telat load
task.spawn(function()
    while task.wait(2) do
        if not Window then
            pcall(function() Window = RS.Remotes.Window end)
        end
        grab()
    end
end)

print("[KZ] Fast Vault loaded (Safe & No Hook)")
