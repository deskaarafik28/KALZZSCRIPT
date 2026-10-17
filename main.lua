--[[ KALZZSCRIPT | main.lua | UNIFIED HOOK + CONFIG GABUNG ]]

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

local HttpService = game:GetService("HttpService")

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

-- ============================================================
-- CONFIG (GABUNG DARI config.lua)
-- ============================================================
local CONFIG_FILE = "kalzz_config.json"
local DEFAULT_CFG = {
    tof_on = true, tof_fov = 320, tof_predict = 2.5, tof_maxdist = 800, tof_show_fov = true, tof_laser = true,
    veil_on = true, veil_fov = 320, veil_predict = 2.8, veil_maxdist = 2000, veil_show_fov = true,
    parry_on = true, parry_radius = 15, parry_aggro = true, parry_antifake = true, parry_show_circle = false,
    crouch_on = true, fast_vault = true,
    esp_k = true, esp_s = true, esp_g = true, esp_gen_txt = true, esp_item = true, esp_out = false,
    fov_lock = false, fov_value = 120,
    ambient = true, boost_fps = true, alert = true, stun_on = true,
    gene_on = false, gene_method = "SUCCESS",
}

local CFG = {}
for k, v in pairs(DEFAULT_CFG) do CFG[k] = v end

-- Load dari file kalau ada
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
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(CFG))
    end)
end

task.spawn(function()
    while true do
        task.wait(30)
        saveCfg()
    end
end)

-- Set global
S.CFG = CFG
S.SaveCfg = saveCfg
_G.KALZZ_CFG = CFG
_G.KZ_SaveCfg = saveCfg

print("[KZ] config loaded | tof_on:", CFG.tof_on, "| veil_on:", CFG.veil_on)

-- State global
_G.KZ_ToFAimDir = nil
_G.KZ_ToFStamp = 0
_G.KZ_ToFTarget = nil
_G.KZ_VeilState = _G.KZ_VeilState or { lookVector=nil, stamp=0, target=nil, velHistory={} }

-- Remote cache
S.RC = { tof=nil, veil=nil, parry=nil, fastvault=nil }
pcall(function() S.RC.tof = S.RS.Remotes.Items["Twist of Fate"].Fire end)
pcall(function() S.RC.parry = S.RS.Remotes.Items["Parrying Dagger"].parry end)
pcall(function()
    local k = S.RS.Remotes:FindFirstChild("Killers")
    if k then local v=k:FindFirstChild("Veil"); if v then S.RC.veil=v:FindFirstChild("Spearthrow") end end
end)
pcall(function()
    local w = S.RS.Remotes:FindFirstChild("Window")
    if w then S.RC.fastvault = w:FindFirstChild("SurvivorFastVault") or w:FindFirstChild("fastvault") end
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
    local ch = S.LP.Character; if not ch then return false end
    local r = ch:GetAttribute("Role") or S.LP:GetAttribute("Role")
    if type(r)=="string" and r:lower():find("killer",1,true) then return true end
    if S.LP.Team and S.LP.Team.Name and S.LP.Team.Name:lower():find("killer",1,true) then return true end
    return false
end

-- No-op: module gak install hook sendiri
S.NewHook = function() return nil end

_G.KZ = S

-- ============================================================
-- MODULE LOADER
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
end)

-- ============================================================
-- UNIFIED HOOK — 1 NAME CALL SAJA
-- ============================================================
do
    if typeof(hookmetamethod) == "function"
       and typeof(newcclosure) == "function"
       and typeof(getnamecallmethod) == "function" then

        local OLD
        OLD = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local m
            pcall(function() m = getnamecallmethod() end)

            -- Anti-kick
            if m == "Kick" then
                if self == S.LP then return nil end
                return OLD(self, ...)
            end

            if m ~= "FireServer" then return OLD(self, ...) end
            if type(self) ~= "userdata" and type(self) ~= "table" then return OLD(self, ...) end

            local tofDir  = _G.KZ_ToFAimDir
            local veilDir = _G.KZ_VeilState and _G.KZ_VeilState.lookVector

            local hasToF  = CFG.tof_on  and typeof(tofDir)  == "Vector3"
            local hasVeil = CFG.veil_on and typeof(veilDir) == "Vector3"

            if not hasToF and not hasVeil then return OLD(self, ...) end

            local args = table.pack(...)
            local n = args.n
            local sName = ""
            pcall(function() sName = tostring(self.Name or "") end)

            -- VEIL SPEAR
            if hasVeil then
                local match = (S.RC.veil and self == S.RC.veil)
                if not match and sName == "Spearthrow" then match = true end
                if match and typeof(args[1]) == "Vector3" and args[1].Magnitude <= 5 then
                    args[1] = veilDir
                    return OLD(self, table.unpack(args, 1, n))
                end
            end

            -- ToF
            if hasToF then
                local match = (S.RC.tof and self == S.RC.tof)
                if not match then
                    if sName == "Fire" or sName == "Shoot" then
                        local fn = ""
                        pcall(function() fn = self:GetFullName():lower() end)
                        if fn:find("twist") or fn:find("fate") or fn:find("tof") then match = true end
                    end
                end
                if match then
                    for i = 1, n do
                        local v = args[i]
                        if typeof(v) == "Vector3" and v.Magnitude <= 5 then
                            args[i] = tofDir
                            break
                        end
                    end
                    return OLD(self, table.unpack(args, 1, n))
                end
            end

            return OLD(self, table.unpack(args, 1, n))
        end))

        print("[KZ] Unified hook installed (1x namecall)")
    end
end

print("[KZ] main.lua loaded | modules:", #MODULES)
