

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
S.LP = S.Players.LocalPlayer
S.PG = S.LP:WaitForChild("PlayerGui")
S.Cam = S.Workspace.CurrentCamera
S.INVITE = "discord.gg/dCYTep9cY"
S.IMG = "rbxassetid://134442738689157"
S.BASE_URL = BASE_URL

-- ============================================================
-- CONFIG
-- ============================================================
local CONFIG_FILE = "kalzz_config.json"
local DEFAULT_CFG = {
    tof_on = true, tof_fov = 500, tof_predict = 2.8, tof_maxdist = 2000, tof_show_fov = true,
    veil_on = true, veil_fov = 320, veil_predict = 2.8, veil_maxdist = 2000, veil_show_fov = true,
    parry_on = true, parry_radius = 14, parry_sensitive = 200, parry_aggro = true, parry_show_circle = true,
    fast_vault = true,
    esp_k = true, esp_s = true, esp_g = true,
    esp_gen_txt = true, esp_item = true,
    esp_out = false, esp_range = 5000,
    fov_lock = false, fov_value = 120,
    ambient = true, boost_fps = true,
    alert = true,
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

task.spawn(function() while true do task.wait(30); saveCfg() end end)

S.CFG = CFG
S.SaveCfg = saveCfg
_G.KALZZ_CFG = CFG
_G.KZ_SaveCfg = saveCfg

-- ============================================================
-- STATE & REMOTE CACHE
-- ============================================================
_G.KZ_ToFAimDir = nil
_G.KZ_ToFStamp = 0
_G.KZ_ToFTarget = nil
_G.KZ_VeilState = _G.KZ_VeilState or { target=nil, lookVector=nil, velHistory={} }

local RC = { tof = nil, veil = nil, parry = nil, fastvault = nil }
pcall(function() RC.tof = S.RS.Remotes.Items["Twist of Fate"].Fire end)
pcall(function() RC.parry = S.RS.Remotes.Items["Parrying Dagger"].parry end)
pcall(function()
    local k = S.RS.Remotes:FindFirstChild("Killers")
    if k then local v=k:FindFirstChild("Veil"); if v then RC.veil=v:FindFirstChild("Spearthrow") end end
end)
pcall(function()
    local w = S.RS.Remotes:FindFirstChild("Window")
    if w then RC.fastvault = w:FindFirstChild("SurvivorFastVault") or w:FindFirstChild("fastvault") end
end)
task.delay(3, function()
    for _, o in ipairs(S.RS:GetDescendants()) do
        if o:IsA("RemoteEvent") then
            local nl = o.Name:lower()
            if not RC.tof and nl == "fire" then
                local f = ""
                pcall(function() f = o:GetFullName():lower() end)
                if f:find("twist") or f:find("fate") then RC.tof = o end
            end
            if not RC.veil and nl == "spearthrow" then RC.veil = o end
        end
    end
end)

S.RC = RC -- Masukin ke global biar bisa diakses module lain (kalo butuh)

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

S.NewHook = function() return nil end
_G.KZ = S
_G.Workspace = S.Workspace
_G.LocalPlayer = S.LP
_G.GetRole = function() return S.isLocalKiller() and "Killer" or "Survivor" end

-- Scheduler
local Scheduler = { Tasks = {} }
function Scheduler:Add(name, func, delay)
    self.Tasks[name] = { func = func, delay = delay, last = os.clock() }
    if not self.Loop then
        self.Loop = S.RSvc.Heartbeat:Connect(function()
            local now = os.clock()
            for k, v in pairs(Scheduler.Tasks) do
                if now - v.last >= v.delay then v.last = now; pcall(v.func) end
            end
        end)
    end
end
_G.Scheduler = Scheduler

-- ============================================================
-- UNIFIED HOOK (PERSIS V5 FINAL)
-- ============================================================
do
    if type(hookmetamethod) == "function" and type(newcclosure) == "function" and type(getnamecallmethod) == "function" then
        local OLD
        OLD = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local m
            pcall(function() m = getnamecallmethod() end)
            
            if m == "Kick" then
                if self == S.LP then return nil end
                return OLD(self, ...)
            end
            
            if m ~= "FireServer" then return OLD(self, ...) end
            
            local tofDir = _G.KZ_ToFAimDir
            local veilDir = _G.KZ_VeilState.lookVector
            local hasToF = CFG.tof_on and typeof(tofDir) == "Vector3"
            local hasVeil = CFG.veil_on and typeof(veilDir) == "Vector3"
            
            if not hasToF and not hasVeil then return OLD(self, ...) end
            if type(self) ~= "userdata" and type(self) ~= "table" then return OLD(self, ...) end
            
            local args = table.pack(...)
            local n = args.n
            
            if hasVeil then
                local match = (RC.veil and self == RC.veil)
                if not match then
                    local sn = ""
                    pcall(function() sn = tostring(self.Name or "") end)
                    if sn == "Spearthrow" then match = true end
                end
                if match and typeof(args[1]) == "Vector3" and args[1].Magnitude <= 5 then
                    args[1] = veilDir
                    return OLD(self, table.unpack(args, 1, n))
                end
            end
            
            if hasToF then
                local match = (RC.tof and self == RC.tof)
                if not match then
                    local sn = ""
                    pcall(function() sn = tostring(self.Name or "") end)
                    if sn == "Fire" or sn == "Shoot" then
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
        print("[KZ] Hook V5 Installed (Stable)")
    end
end

-- ============================================================
-- LOAD MODULES
-- ============================================================
local function loadModule(name)
    local url = BASE_URL .. name .. ".lua"
    local ok, src = pcall(game.HttpGet, game, url)
    if not ok or not src or src == "" then warn("[KZ] gagal load: " .. name); return end
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
    print("[KZ] All Modules Loaded")
end)
