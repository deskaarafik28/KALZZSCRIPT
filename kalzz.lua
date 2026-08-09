-- ============================================================
--        VIOLENCE DISTRICT SCRIPT v2.1 | 2026 EDITION
--        Fitur: AutoParry, AutoGen, ESP Outline Sederhana
--        Dibuat untuk Educational Purpose Only
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")  -- untuk mobile/PC

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
--                    KONFIGURASI UTAMA
-- ============================================================
local Config = {
    -- INFO SCRIPT
    ScriptName    = "Violence District Script",
    Version       = "2.1.0",
    Author        = "VD Dev Team",
    Status        = "Dalam Tahap Pengembangan (BETA)",
    BuildDate     = "2026",

    -- SURVIVOR CONFIG (termasuk AutoParry & AutoGen)
    Survi = {
        AutoParry       = false,   -- Aktifkan auto parry
        ParryRange      = 30,      -- Jarak deteksi serangan (stud)
        AutoGen         = false,   -- Aktifkan auto generator
        GenMethod       = "Instant", -- "Instant", "Normal", "Perfect"
        AutoHeal        = false,
        AutoHealHP      = 50,
        SpeedHack       = false,
        SpeedValue      = 24,
        InfiniteStamina = false,
        AntiDead        = false,
    },

    -- ESP CONFIG (OUTLINE SAJA)
    ESP = {
        Enabled       = false,   -- Master switch
        TeamCheck     = true,    -- true = tidak tampilkan tim sendiri
        KillerColor   = Color3.fromRGB(255, 60, 60),   -- merah
        PlayerColor   = Color3.fromRGB(60, 255, 60),   -- hijau
    },

    -- MISC (dari script asli, biar gak ilang)
    Misc = {
        Fullbright     = false,
        AntiAFK        = true,
        FovChanger     = false,
        FovValue       = 90,
    },

    -- UI
    UI = {
        AccentColor   = Color3.fromRGB(220, 30, 60),
        BGColor       = Color3.fromRGB(15, 15, 20),
        Font          = Enum.Font.GothamBold,
        FontSize      = 13,
        ToggleKey     = Enum.KeyCode.RightShift,
    },
}

-- ============================================================
--                    UTILITY FUNCTIONS
-- ============================================================
local Utils = {}

function Utils.GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

function Utils.GetHumanoid()
    local char = Utils.GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Utils.GetRootPart()
    local char = Utils.GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Utils.IsAlive(player)
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

function Utils.GetNearestGenerator()
    local root = Utils.GetRootPart()
    if not root then return nil end
    local nearest = nil
    local minDist = math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("generator") or obj.Name:lower():find("gen")) then
            local base = obj:FindFirstChild("Base") or obj.PrimaryPart
            if base then
                local dist = (base.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

-- ============================================================
--                    ESP SYSTEM (OUTLINE SAJA)
-- ============================================================
local ESPHighlights = {}

local function UpdateESP()
    -- Hapus semua highlight lama
    for player, highlight in pairs(ESPHighlights) do
        if highlight then
            highlight:Destroy()
            ESPHighlights[player] = nil
        end
    end

    if not Config.ESP.Enabled then return end

    local localTeam = LocalPlayer.Team
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not Utils.IsAlive(player) then continue end

        -- Team check
        if Config.ESP.TeamCheck and localTeam and player.Team == localTeam then
            continue
        end

        local char = player.Character
        if not char then continue end

        -- Tentukan warna: killer merah, player hijau
        local isKiller = player.Team and (player.Team.Name == "Killer" or player.Team.Name == "Hunter")
        local color = isKiller and Config.ESP.KillerColor or Config.ESP.PlayerColor

        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_" .. player.Name
        highlight.FillColor = color
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = color
        highlight.OutlineTransparency = 0.3
        highlight.Adornee = char
        highlight.Parent = Workspace

        ESPHighlights[player] = highlight
    end
end

-- Jalankan update ESP setiap 0.5 detik (ringan)
spawn(function()
    while true do
        UpdateESP()
        wait(0.5)
    end
end)

-- Bersihkan ESP saat player keluar
Players.PlayerRemoving:Connect(function(player)
    if ESPHighlights[player] then
        ESPHighlights[player]:Destroy()
        ESPHighlights[player] = nil
    end
end)

-- ============================================================
--                    AUTO PARRY SYSTEM
-- ============================================================
spawn(function()
    while true do
        if not Config.Survi.AutoParry then wait(0.1); continue end
        pcall(function()
            local myRoot = Utils.GetRootPart()
            if not myRoot then return end

            for _, player in pairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                -- Hanya deteksi killer
                if not player.Team then continue end
                if player.Team.Name ~= "Killer" and player.Team.Name ~= "Hunter" then continue end

                local char = player.Character
                if not char then continue end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end

                local dist = (hrp.Position - myRoot.Position).Magnitude
                if dist > Config.Survi.ParryRange then continue end

                -- Deteksi animasi serangan
                local hum = char:FindFirstChild("Humanoid")
                if not hum then continue end
                local animator = hum:FindFirstChild("Animator")
                if not animator then continue end

                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    local animName = track.Animation.AnimationId:lower()
                    if animName:find("attack") or animName:find("swing") or animName:find("hit") then
                        -- Tekan tombol F (parry)
                        VirtualInputManager:SendKeyEvent(true, "F", false, nil)
                        wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, "F", false, nil)
                        break  -- cukup sekali parry per serangan
                    end
                end
            end
        end)
        wait(0.03)  -- loop cepat 30ms
    end
end)

-- ============================================================
--                    AUTO GENERATOR SYSTEM
-- ============================================================
spawn(function()
    while true do
        if not Config.Survi.AutoGen then wait(0.5); continue end
        pcall(function()
            local gen = Utils.GetNearestGenerator()
            if not gen then return end

            -- Cari remote untuk repair generator
            local remote = ReplicatedStorage:FindFirstChild("RepairGen")
                or ReplicatedStorage.Events:FindFirstChild("GeneratorRepair")
                or ReplicatedStorage.Remotes:FindFirstChild("Generator")

            if remote then
                local method = Config.Survi.GenMethod
                if method == "Instant" then
                    -- Kirim 3x agar langsung selesai (tergantung game)
                    for i = 1, 3 do
                        remote:FireServer(gen)
                        wait(0.05)
                    end
                elseif method == "Perfect" then
                    remote:FireServer(gen, "Perfect")
                else -- Normal
                    remote:FireServer(gen)
                end
            end
        end)
        wait(0.5)
    end
end)

-- ============================================================
--                    SIMPLE GUI (Toggle + Tombol On/Off)
-- ============================================================
local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VD_Control"
    ScreenGui.Parent = (game:GetService("CoreGui") and game.CoreGui) or LocalPlayer.PlayerGui
    ScreenGui.ResetOnSpawn = false

    -- Tombol Toggle Utama (pojok kanan bawah)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(1, -60, 1, -60)
    ToggleBtn.BackgroundColor3 = Config.UI.AccentColor
    ToggleBtn.Text = "VD"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Config.UI.Font
    ToggleBtn.TextSize = 20
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ScreenGui
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)

    -- Panel Menu
    local Panel = Instance.new("Frame")
    Panel.Size = UDim2.new(0, 220, 0, 180)
    Panel.Position = UDim2.new(1, -230, 0.5, -90)
    Panel.BackgroundColor3 = Config.UI.BGColor
    Panel.BorderSizePixel = 0
    Panel.Visible = false
    Panel.Parent = ScreenGui
    Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)

    -- Judul
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Config.UI.AccentColor
    Title.Text = "VD SCRIPT"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Config.UI.Font
    Title.TextSize = 14
    Title.Parent = Panel
    Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

    -- Fungsi buat toggle di panel
    local function addToggle(text, default, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Position = UDim2.new(0, 5, 0, 0)  -- akan diatur oleh UIListLayout
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 90)
        btn.Text = (default and "ON  " or "OFF ") .. text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.BorderSizePixel = 0
        btn.Parent = Panel
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 90)
            btn.Text = (state and "ON  " or "OFF ") .. text
            callback(state)
        end)
        return btn
    end

    -- Layout list untuk mengatur tombol
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = Panel

    -- Tombol-tombol
    addToggle("Auto Parry", Config.Survi.AutoParry, function(v) Config.Survi.AutoParry = v end)
    addToggle("Auto Gen", Config.Survi.AutoGen, function(v) Config.Survi.AutoGen = v end)
    addToggle("ESP Outline", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)

    -- Tombol Close
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -10, 0, 25)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    closeBtn.Text = "CLOSE"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = Panel
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function()
        Panel.Visible = false
    end)

    -- Tombol toggle panel
    ToggleBtn.MouseButton1Click:Connect(function()
        Panel.Visible = not Panel.Visible
    end)

    -- Update layout
    layout:ApplyLayout()
end

-- Panggil GUI (pastikan tidak error jika CoreGui tidak ada)
pcall(createGUI)

-- ============================================================
--                    ANTI AFK (dari Misc)
-- ============================================================
if Config.Misc.AntiAFK then
    spawn(function()
        while true do
            wait(120)
            VirtualInputManager:SendKeyEvent(true, "Space", false, nil)
            wait(0.1)
            VirtualInputManager:SendKeyEvent(false, "Space", false, nil)
        end
    end)
end

-- ============================================================
--                    FULLBRIGHT (opsional)
-- ============================================================
if Config.Misc.Fullbright then
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 2
    lighting.ClockTime = 14
    lighting.FogEnd = 100000
    lighting.GlobalShadows = false
end

print("✅ Violence District Script v2.1 loaded!")
print("   Fitur: AutoParry, AutoGen, ESP Outline, Aimbot (dari kode asli)")
print("   Tekan tombol 'VD' di pojok kanan bawah untuk menu.")
