--[[ KALZZSCRIPT | main.lua | UNIFIED HOOK EDITION ]]

local BASE_URL = "https://raw.githubusercontent.com/deskaarafik28/KALZZSCRIPT/refs/heads/main/modules/"

local MODULES = {
    "config",
    "kick",
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

S.CFG = {}
S.SaveCfg = function() end

_G.KZ_ToFAimDir = nil
_G.KZ_ToFStamp = 0
_G.KZ_ToFTarget = nil
_G.KZ_VeilState = _G.KZ_VeilState or { lookVector=nil, stamp=0, target=nil }

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
            if not S.RC.parry and nl:find("parry") then S.RC.parry = o end
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

-- ============================================================
-- NewHook jadi NO-OP (semua hooking di-handle unified hook)
-- Module panggil S.NewHook, tapi hook-nya ga diinstall
-- ============================================================
S.NewHook = function(fn)
    -- No-op: unified hook di main.lua yang urus semua
    -- Module cuma perlu set _G.KZ_ToFAimDir / _G.KZ_VeilState.lookVector
    return nil
end

_G.KZ = S

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
-- UNIFIED HOOK (ToF + Veil + Anti-Kick) — SINGLE INSTANCE
-- Semua FireServer interception dilakukan di sini
-- ============================================================
do
    if typeof(hookmetamethod) == "function"
       and typeof(newcclosure) == "function"
       and typeof(getnamecallmethod) == "function" then

        local OLD
        OLD = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local m
            pcall(function() m = getnamecallmethod() end)

            -- === ANTI KICK ===
            if m == "Kick" then
                if self == S.LP then return nil end
                return OLD(self, ...)
            end

            -- === FILTER: cuma FireServer ===
            if m ~= "FireServer" then return OLD(self, ...) end
            if type(self) ~= "userdata" and type(self) ~= "table" then
                return OLD(self, ...)
            end

            -- === AMBIL AIM STATE ===
            local tofDir  = _G.KZ_ToFAimDir
            local veilDir = _G.KZ_VeilState and _G.KZ_VeilState.lookVector

            local hasToF  = S.CFG and S.CFG.tof_on  and typeof(tofDir)  == "Vector3"
            local hasVeil = S.CFG and S.CFG.veil_on and typeof(veilDir) == "Vector3"

            if not hasToF and not hasVeil then return OLD(self, ...) end

            local args = table.pack(...)
            local n = args.n

            -- === IDENTIFIKASI REMOTE ===
            local sName, sFull = "", ""
            pcall(function() sName = tostring(self.Name or "") end)
            pcall(function() sFull = self:GetFullName():lower() end)
            local sNameL = sName:lower()

            -- === VEIL SPEAR (prioritas: killer) ===
            if hasVeil then
                local match = (S.RC.veil and self == S.RC.veil)
                if not match then
                    if sName == "Spearthrow"
                       or sNameL == "spearthrow"
                       or sNameL == "throwspear"
                       or sNameL == "veilspear"
                       or (sNameL == "throw" and sFull:find("veil")) then
                        match = true
                    end
                end
                if match then
                    local changed = false
                    for i = 1, n do
                        if typeof(args[i]) == "Vector3" then
                            if args[i].Magnitude <= 5 then
                                args[i] = veilDir
                            else
                                -- kalau velocity, preserve magnitude
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

            -- === ToF (Twist of Fate) ===
            if hasToF then
                local match = (S.RC.tof and self == S.RC.tof)
                if not match then
                    if sName == "Fire" or sName == "Shoot"
                       or sNameL == "fire" or sNameL == "shoot" then
                        if sFull:find("twist") or sFull:find("fate")
                           or sFull:find("tof") then
                            match = true
                        end
                    end
                end
                if match then
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

            return OLD(self, table.unpack(args, 1, n))
        end))

        print("[KZ] Unified hook installed (ToF + Veil + Anti-Kick)")
    else
        warn("[KZ] hookmetamethod tidak tersedia — unified hook tidak terpasang")
    end
end

print("[KZ] main.lua loaded | modules:", #MODULES)
