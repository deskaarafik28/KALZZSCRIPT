--[[ KALZZSCRIPT | main.lua | UNIFIED HOOK + CONFIG GABUNG + ANTI-BUG PISTOL ]]

local HttpService = game:GetService("HttpService")
local BASE_URL = "https://raw.githubusercontent.com/deskaarafik28/KALZZSCRIPT/refs/heads/main/modules/"

local MODULES = {
    "silent-aim-tof",
    "silent-aim-veil",
    "auto-parry",
    "auto-crouch",
    "gen",
    "fast-vault",
    "stun-notif",
    "alert",
    "vision",
    "esp",
    "ui",
}

-- ============================================================
-- 1. GLOBAL VARIABLES & SERVICES
-- ============================================================
local S = {
    Players   = game:GetService("Players"),
    RS        = game:GetService("ReplicatedStorage"),
    RSvc      = game:GetService("RunService"),
    UIS       = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    Lighting  = game:GetService("Lighting"),
    TS        = game:GetService("TweenService"),
    CoreGui   = game:GetService("CoreGui"),
}
S.LP       = S.Players.LocalPlayer
S.PG       = S.LP:WaitForChild("PlayerGui")
S.Cam      = S.Workspace.CurrentCamera
S.INVITE   = "discord.gg/dCYTep9cY"
S.IMG      = "rbxassetid://134442738689157"
S.BASE_URL = BASE_URL

-- Sediakan fungsi global yang dipanggil module
_G.GetRole = function()
    local ch = S.LP.Character
    if not ch then return "Survivor" end
    local r = ch:GetAttribute("Role") or S.LP:GetAttribute("Role")
    if type(r) == "string" and r:lower():find("killer") then return "Killer" end
    if S.LP.Team and S.LP.Team.Name and S.LP.Team.Name:lower():find("killer") then return "Killer" end
    return "Survivor"
end

-- ============================================================
-- 2. CONFIG & AUTO-SAVE (GABUNGAN DARI config.lua)
-- ============================================================
local CONFIG_FILE = "kalzz_config.json"
local DEFAULT_CFG = {
    -- ToF
    tof_on = true, tof_fov = 320, tof_predict = 2.5, tof_maxdist = 800, tof_show_fov = true, tof_laser = true,
    -- Veil
    veil_on = true, veil_fov = 320, veil_predict = 2.8, veil_maxdist = 2000, veil_show_fov = true,
    veil_auto_predict = true, veil_show_tracker = true,
    veil_spear_speed = 165, veil_gravity = 103, veil_lead_multiplier = 1.4,
    veil_aura_spear_speed = 165, veil_aura_spear_gravity = 96.5,
    -- Parry
    parry_on = true, parry_radius = 15, parry_aggro = true, parry_antifake = true, parry_show_circle = true,
    -- Movement
    crouch_on = true, fast_vault = true,
    -- ESP
    esp_k = false, esp_s = true, esp_g = true, esp_gen_txt = true, esp_item = true, esp_out = false,
    -- Vision & FPS
    fov_lock = false, fov_value = 120, ambient = true, boost_fps = true,
    -- Alerts
    alert = true, stun_on = true,
    -- Auto Gen
    gene_on = false, gene_method = "SUCCESS",
}

local CFG = {}
for k, v in pairs(DEFAULT_CFG) do CFG[k] = v end

if readfile and isfile then
    pcall(function()
        if isfile(CONFIG_FILE) then
            local raw = readfile(CONFIG_FILE)
            if raw and raw ~= "" then
                local data = HttpService:JSONDecode(raw)
                for k, v in pairs(data) do
                    if DEFAULT_CFG[k] ~= nil then CFG[k] = v end
                end
            end
        end
    end)
end

local function saveCfg()
    if not writefile then return end
    pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(CFG)) end)
end

task.spawn(function()
    while true do
        task.wait(30)
        saveCfg()
    end
end)

S.CFG = CFG
S.SaveCfg = saveCfg
_G.KALZZ_CFG = CFG
_G.KZ_SaveCfg = saveCfg

print("[KZ] Config Loaded & Synced")

-- ============================================================
-- 3. SCHEDULER (PENGGANTI Scheduler:Add DI MODUL LU)
-- ============================================================
local Scheduler = { Tasks = {} }
function Scheduler:Add(name, func, delay)
    self.Tasks[name] = { func = func, delay = delay, last = os.clock() }
    if not self.Loop then
        self.Loop = S.RSvc.Heartbeat:Connect(function()
            local now = os.clock()
            for k, v in pairs(Scheduler.Tasks) do
                if now - v.last >= v.delay then
                    v.last = now
                    pcall(v.func)
                end
            end
        end)
    end
end
_G.Scheduler = Scheduler
_G.Workspace = S.Workspace
_G.LocalPlayer = S.LP

-- ============================================================
-- 4. AIM STATE & REMOTE CACHE
-- ============================================================
_G.KZ_ToFAimDir = nil
_G.KZ_VeilState = _G.KZ_VeilState or { target=nil, lookVector=nil, velHistory={} }

S.RC = { tof=nil, veil=nil, parry=nil, fastvault=nil }
pcall(function() S.RC.tof = S.RS.Remotes.Items["Twist of Fate"].Fire end)
pcall(function() S.RC.parry = S.RS.Remotes.Items["Parrying Dagger"].parry end)
pcall(function()
    local k = S.RS.Remotes:FindFirstChild("Killers")
    if k then local v=k:FindFirstChild("Veil"); if v then S.RC.veil=v:FindFirstChild("Spearthrow") end end
end)

task.delay(3, function()
    for _,o in ipairs(S.RS:GetDescendants()) do
        if o:IsA("RemoteEvent") then
            local nl = o.Name:lower()
            if not S.RC.tof and nl == "fire" then
                local f=""; pcall(function() f=o:GetFullName():lower() end)
                if f:find("twist") or f:find("fate") then S.RC.tof = o end
            end
            if not S.RC.veil and nl == "spearthrow" then S.RC.veil = o end
        end
    end
end)

S.rtp = function(m)
    if not m then return nil end
    return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m.PrimaryPart
end

S.isKiller = function(c)
    local p
    if typeof(c)=="Instance" then
        if c:IsA("Player") then p=c else p=S.Players:GetPlayerFromCharacter(c) end
    end
    if not p then return false end
    local r = (p.Character and p.Character:GetAttribute("Role")) or p:GetAttribute("Role")
    if type(r)=="string" then
        local rl=r:lower()
        if rl:find("killer",1,true) then return true end
        if rl:find("survivor",1,true) then return false end
    end
    if p.Team and p.Team.Name then
        local t=p.Team.Name:lower()
        if t:find("killer",1,true) then return true end
        if t:find("survivor",1,true) then return false end
    end
    return false
end

S.isLocalKiller = function()
    return _G.GetRole() == "Killer"
end

S.NewHook = function() return nil end

_G.KZ = S

-- ============================================================
-- 5. UNIFIED HOOK (HANYA 1 NAMECALL) - FIXED PISTOL BUG
-- ============================================================
do
    if typeof(hookmetamethod) == "function" and typeof(newcclosure) == "function" then
        local OLD
        OLD = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local m = getnamecallmethod()

            -- Anti-Kick
            if m == "Kick" then
                if self == S.LP then return nil end
                return OLD(self, ...)
            end

            if m ~= "FireServer" then return OLD(self, ...) end
            if type(self) ~= "userdata" and type(self) ~= "table" then return OLD(self, ...) end

            local sName = ""
            pcall(function() sName = tostring(self.Name or "") end)

            -- ⭐ CEK TOOL YANG LAGI DIPEGANG
            local char = S.LP.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            local toolName = tool and tostring(tool.Name):lower() or ""
            
            local isToFTool = toolName:find("twist") or toolName:find("fate") or toolName:find("tof")
            local isVeilTool = toolName:find("veil") or toolName:find("spear") or toolName:find("dagger")

            -- === 1. VEIL SPEAR (KILLER) ===
            if sName == "Spearthrow" and CFG.veil_on and _G.GetRole() == "Killer" and isVeilTool then
                local dir = _G.KZ_VeilState and _G.KZ_VeilState.lookVector
                if typeof(dir) == "Vector3" then
                    local args = table.pack(...)
                    if typeof(args[1]) == "Vector3" then
                        args[1] = dir
                        return OLD(self, table.unpack(args, 1, args.n))
                    end
                end
            end

            -- === 2. ToF (SURVIVOR) ===
            if (sName == "Fire" or sName == "Shoot") and CFG.tof_on and _G.GetRole() == "Survivor" and isToFTool then
                local fn = ""
                pcall(function() fn = self:GetFullName():lower() end)
                local isRemoteToF = fn:find("twist") or fn:find("fate") or fn:find("tof")
                
                if isRemoteToF then
                    local dir = _G.KZ_ToFAimDir
                    if typeof(dir) == "Vector3" then
                        local args = table.pack(...)
                        local changed = false
                        for i = 1, args.n do
                            -- Magnitude <= 5 (cuma ngeganti vektor arah, bukan velocity/posisi)
                            if typeof(args[i]) == "Vector3" and args[i].Magnitude <= 5 then
                                args[i] = dir
                                changed = true
                                break
                            end
                        end
                        if changed then
                            return OLD(self, table.unpack(args, 1, args.n))
                        end
                    end
                end
            end

            -- === 3. FAST VAULT EVENT BYPASS ===
            if sName == "VaultEvent" and CFG.fast_vault then
                local args = table.pack(...)
                if typeof(args[2]) == "boolean" then
                    args[2] = true
                end
                return OLD(self, table.unpack(args, 1, args.n))
            end

            return OLD(self, ...)
        end))

        print("[KZ] Unified Hook Installed (1x Namecall + Anti-Bug Pistol)")
    else
        warn("[KZ] hookmetamethod tidak tersedia")
    end
end

-- ============================================================
-- 6. LOAD SEMUA MODULES
-- ============================================================
local function loadModule(name)
    local url = BASE_URL .. name .. ".lua"
    local ok, src = pcall(game.HttpGet, game, url)
    if not ok or not src or src == "" then
        warn("[KZ] gagal load: " .. name); return
    end
    local fn, err = loadstring(src)
    if not fn then warn("[KZ] syntax error "..name..": "..tostring(err)) return end
    local ok2, err2 = pcall(fn)
    if not ok2 then warn("[KZ] runtime error "..name..": "..tostring(err2)) end
end

task.spawn(function()
    task.wait(0.3)
    for _, name in ipairs(MODULES) do
        loadModule(name)
        task.wait(0.05)
    end
    print("[KZ] All modules loaded successfully.")
end)
