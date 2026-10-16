--[[ KALZZSCRIPT | main.lua | UNIFIED HOOK FINAL ]]
-- 1x hookmetamethod — no double hook
-- CFG sync dari config.lua biar aimbot jalan
-- Silent aim ToF + Veil inject di sini

local BASE_URL = "https://raw.githubusercontent.com/deskaarafik28/KALZZSCRIPT/refs/heads/main/modules/"

local MODULES = {
    "config",
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
-- SETUP GLOBAL S
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

-- CFG placeholder (bakal di-sync dari config.lua nanti)
S.CFG      = {}
S.SaveCfg  = function() end

-- AIM STATE (dibaca unified hook)
_G.KZ_ToFAimDir  = nil
_G.KZ_ToFStamp   = 0
_G.KZ_ToFTarget  = nil
_G.KZ_VeilState  = _G.KZ_VeilState or {
    lookVector = nil,
    stamp      = 0,
    target     = nil,
    velHistory = {},
}

-- ============================================================
-- REMOTE CACHE
-- ============================================================
S.RC = { tof=nil, veil=nil, parry=nil, fastvault=nil }
pcall(function() S.RC.tof = S.RS.Remotes.Items["Twist of Fate"].Fire end)
pcall(function() S.RC.parry = S.RS.Remotes.Items["Parrying Dagger"].parry end)
pcall(function()
    local k = S.RS.Remotes:FindFirstChild("Killers")
    if k then
        local v = k:FindFirstChild("Veil")
        if v then S.RC.veil = v:FindFirstChild("Spearthrow") end
    end
end)
pcall(function()
    local w = S.RS.Remotes:FindFirstChild("Window")
    if w then
        S.RC.fastvault = w:FindFirstChild("SurvivorFastVault")
            or w:FindFirstChild("fastvault")
    end
end)

-- Fallback scan nama remote (kalau path standar gak match)
task.delay(3, function()
    for _, o in ipairs(S.RS:GetDescendants()) do
        if o:IsA("RemoteEvent") then
            local nl = o.Name:lower()
            local fn = ""
            pcall(function() fn = o:GetFullName():lower() end)

            if not S.RC.tof and nl == "fire"
               and (fn:find("twist") or fn:find("fate")) then
                S.RC.tof = o
            end
            if not S.RC.veil and (nl == "spearthrow" or nl == "throwspear") then
                S.RC.veil = o
            end
            if not S.RC.parry and nl:find("parry") then
                S.RC.parry = o
            end
        end
    end
end)

-- ============================================================
-- HELPERS
-- ============================================================
S.rtp = function(m)
    if not m then return nil end
    return m:FindFirstChild("HumanoidRootPart")
        or m:FindFirstChild("Torso")
        or m.PrimaryPart
end

S.isKiller = function(c)
    local p
    if typeof(c) == "Instance" then
        if c:IsA("Player") then p = c
        else p = S.Players:GetPlayerFromCharacter(c) end
    end
    if not p then return false end

    local r = (p.Character and p.Character:GetAttribute("Role")) or p:GetAttribute("Role")
    if type(r) == "string" then
        local rl = r:lower()
        if rl:find("killer", 1, true)   then return true  end
        if rl:find("survivor", 1, true) then return false end
    end

    if p.Team and p.Team.Name then
        local t = p.Team.Name:lower()
        if t:find("killer", 1, true)   then return true  end
        if t:find("survivor", 1, true) then return false end
    end
    return false
end

S.isLocalKiller = function()
    local ch = S.LP.Character
    if not ch then return false end
    local r = ch:GetAttribute("Role") or S.LP:GetAttribute("Role")
    if type(r) == "string" and r:lower():find("killer", 1, true) then return true end
    if S.LP.Team and S.LP.Team.Name
       and S.LP.Team.Name:lower():find("killer", 1, true) then
        return true
    end
    return false
end

-- Module tetap panggil S.NewHook, tapi no-op (unified hook di main.lua)
S.NewHook = function(fn)
    return nil
end

_G.KZ = S

-- ============================================================
-- MODULE LOADER
-- ============================================================
local function loadModule(name)
    local url = BASE_URL .. name .. ".lua"
    local ok, src = pcall(game.HttpGet, game, url)
    if not ok or not src or src == "" then
        warn("[KZ] gagal load: " .. name)
        return false
    end
    local fn, err = loadstring(src)
    if not fn then
        warn("[KZ] syntax error " .. name .. ": " .. tostring(err))
        return false
    end
    local ok2, err2 = pcall(fn)
    if not ok2 then
        warn("[KZ] runtime error " .. name .. ": " .. tostring(err2))
        return false
    end
    return true
end

-- ============================================================
-- INSTALL UNIFIED HOOK DULU (biar semua FireServer ke-catch)
-- ============================================================
do
    if typeof(hookmetamethod) == "function"
       and typeof(newcclosure) == "function"
       and typeof(getnamecallmethod) == "function" then

        local OLD
        OLD = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method
            pcall(function() method = getnamecallmethod() end)

            -- ─── ANTI KICK ───
            if method == "Kick" then
                if self == S.LP then return nil end
                return OLD(self, ...)
            end

            -- ─── CUMA FIRESERVER ───
            if method ~= "FireServer" then
                return OLD(self, ...)
            end

            if type(self) ~= "userdata" and type(self) ~= "table" then
                return OLD(self, ...)
            end

            -- ─── AMBIL STATE DARI MODULE ───
            local tofDir  = _G.KZ_ToFAimDir
            local veilDir = _G.KZ_VeilState and _G.KZ_VeilState.lookVector

            local cfgTof  = (S.CFG and S.CFG.tof_on)  == true
            local cfgVeil = (S.CFG and S.CFG.veil_on) == true

            local hasToF  = cfgTof  and typeof(tofDir)  == "Vector3"
            local hasVeil = cfgVeil and typeof(veilDir) == "Vector3"

            if not hasToF and not hasVeil then
                return OLD(self, ...)
            end

            -- ─── IDENTIFIKASI REMOTE ───
            local sName, sFull = "", ""
            pcall(function() sName = tostring(self.Name or "") end)
            pcall(function() sFull = self:GetFullName():lower() end)
            local sNameL = sName:lower()

            -- ─── VEIL SPEAR ───
            if hasVeil and S.isLocalKiller() then
                local isVeil = (S.RC.veil and self == S.RC.veil)
                if not isVeil then
                    if sName == "Spearthrow"
                       or sNameL == "spearthrow"
                       or sNameL == "throwspear"
                       or sNameL == "veilspear"
                       or (sNameL == "throw" and sFull:find("veil", 1, true)) then
                        isVeil = true
                    end
                end

                if isVeil then
                    -- recompute fresh kalau module expose
                    if S.RecomputeVeil then
                        local ok, fresh = pcall(S.RecomputeVeil)
                        if ok and typeof(fresh) == "Vector3" then
                            veilDir = fresh
                        end
                    end

                    local args = table.pack(...)
                    local n = args.n
                    local changed = false
                    for i = 1, n do
                        if typeof(args[i]) == "Vector3" then
                            if args[i].Magnitude <= 5 then
                                args[i] = veilDir
                            else
                                args[i] = veilDir.Unit * args[i].Magnitude
                            end
                            changed = true
                            break
                        end
                    end
                    if not changed then args[1] = veilDir end
                    return OLD(self, table.unpack(args, 1, n))
                end
            end

            -- ─── ToF ───
            if hasToF and not S.isLocalKiller() then
                local isToF = (S.RC.tof and self == S.RC.tof)
                if not isToF then
                    if sName == "Fire" or sName == "Shoot"
                       or sNameL == "fire" or sNameL == "shoot" then
                        if sFull:find("twist", 1, true)
                           or sFull:find("fate", 1, true)
                           or sFull:find("tof", 1, true) then
                            isToF = true
                        end
                    end
                end

                if isToF then
                    local args = table.pack(...)
                    local n = args.n
                    local changed = false
                    for i = 1, n do
                        local v = args[i]
                        if typeof(v) == "Vector3" then
                            if v.Magnitude <= 5 then
                                args[i] = tofDir
                            else
                                args[i] = tofDir.Unit * v.Magnitude
                            end
                            changed = true
                            break
                        end
                    end
                    if not changed then args[1] = tofDir end
                    return OLD(self, table.unpack(args, 1, n))
                end
            end

            return OLD(self, ...)
        end))

        print("[KZ] Unified hook installed (1x namecall — AntiKick + Veil + ToF)")
    else
        warn("[KZ] hookmetamethod tidak tersedia!")
    end
end

-- ============================================================
-- LOAD SEMUA MODULE + SYNC CFG
-- ============================================================
task.spawn(function()
    task.wait(0.3)

    for _, name in ipairs(MODULES) do
        loadModule(name)
        task.wait(0.05)
    end

    -- ⭐ SYNC CFG dari config.lua (INI YANG BIKIN AIMBOT JALAN)
    if _G.KALZZ_CFG then
        S.CFG = _G.KALZZ_CFG
        _G.KZ.CFG = S.CFG
    end
    if _G.KZ_SaveCfg then
        S.SaveCfg = _G.KZ_SaveCfg
        _G.KZ.SaveCfg = S.SaveCfg
    end

    print("[KZ] CFG synced | tof_on:", tostring(S.CFG.tof_on),
          "| veil_on:", tostring(S.CFG.veil_on))
end)

print("[KZ] main.lua loaded | modules:", #MODULES)
