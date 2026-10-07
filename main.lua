--[[
╔══════════════════════════════════════════════════════════════╗
║                     KALZZ HUB v1                             ║
║                       main.lua                               ║
╚══════════════════════════════════════════════════════════════╝

Usage:
1. Copy entire script to executor
2. Paste module files between marker:
   ▼▼▼ PASTE MODULES BELOW ▼▼▼
   ▲▲▲ PASTE MODULES ABOVE ▲▲▲
3. Execute

Modules in order:
- ui.lua
- FastVault.lua
- Invisible.lua
- FakePerks.lua
- AutoGen.lua
- SilentAim.lua
- Veil.lua
- Parry.lua
- AutoCrouch.lua
- ESP.lua
- Alert.lua
- StunIndicator.lua
- FOVLock.lua
- Visuals.lua
]]

-- ═══════════════════════════════════════════════════════════════
-- §A  SERVICES & CORE
-- ═══════════════════════════════════════════════════════════════
local P    = game:GetService("Players")
local LP   = P.LocalPlayer
local PG   = LP:WaitForChild("PlayerGui")
local CG   = game:GetService("CoreGui")
local WS   = game:GetService("Workspace")
local UIS  = game:GetService("UserInputService")
local RS   = game:GetService("ReplicatedStorage")
local TS   = game:GetService("TweenService")
local RSvc = game:GetService("RunService")
local L    = game:GetService("Lighting")
local HS   = game:GetService("HttpService")

-- ═══════════════════════════════════════════════════════════════
-- §B  ANTI-KICK
-- ═══════════════════════════════════════════════════════════════
pcall(function()
    local o
    o = hookmetamethod(game, "__namecall", newcclosure(function(s, ...)
        if getnamecallmethod() == "Kick" and s == P.LocalPlayer then return end
        return o(s, ...)
    end))
end)

-- ═══════════════════════════════════════════════════════════════
-- §C  FPS TUNING
-- ═══════════════════════════════════════════════════════════════
pcall(function()
    if setfpscap then setfpscap(600) end
    local s = settings()
    if s then
        pcall(function() s.Rendering.FrameRateCap = 600 end)
        pcall(function() s.Rendering.GraphicsQuality = 1 end)
        pcall(function() s.Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        pcall(function() s.Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04 end)
        pcall(function() s.Rendering.ShowBoundingBoxes = false end)
        pcall(function() s.Rendering.ShowWelds = false end)
        pcall(function() s.Network.IncomingReplicationLag = 0 end)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- §D  CLEANUP OLD
-- ═══════════════════════════════════════════════════════════════
pcall(function()
    for _, pr in ipairs({CG, PG}) do
        for _, g in ipairs(pr:GetChildren()) do
            if g.Name:find("Kalzz") or g.Name:find("KZ_") then
                pcall(function() g:Destroy() end)
            end
        end
    end
    for _, o in ipairs(WS:GetChildren()) do
        if o.Name:sub(1, 3) == "KZ_" then pcall(function() o:Destroy() end) end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- §E  VIRTUAL MODULE REGISTRY
-- ═══════════════════════════════════════════════════════════════
local Modules = {}
local function Register(name, fn)
    Modules[name] = fn
end
local function Require(name, ...)
    local mod = Modules[name]
    if not mod then
        error("[KZ] Module not found: "..name, 2)
    end
    return mod(...)
end

-- ═══════════════════════════════════════════════════════════════
-- §F  CONFIG
-- ═══════════════════════════════════════════════════════════════
local CFG = {
    gene_on=true, gene_method="PERFECT",
    fast_vault=true, invisible=false,
    auto_crouch=true, auto_crouch_radius=16, auto_crouch_stand=5,
    tof_on=true, tof_fov=380,
    veil_on=true, veil_fov=280, veil_predict=1.4,
    parry_on=true, parry_radius=12, parry_circle=true, parry_aggro=true, parry_sensitive=200,
    esp_k=true, esp_s=true, esp_g=true, esp_out=false, esp_range=5000,
    stun_indicator=true, fog=false, bright=true, cam=true, camv=90, alert=true,
    fake_quick=true, fake_landing=true, fake_adrenaline=true,
}
local CF = "kalzz_v1.json"
local CFS = (type(writefile) == "function") and (type(readfile) == "function") and (type(isfile) == "function")
if CFS then
    pcall(function()
        if isfile(CF) then
            local d = HS:JSONDecode(readfile(CF))
            if type(d) == "table" then
                for k, v in pairs(d) do if CFG[k] ~= nil then CFG[k] = v end end
            end
        end
    end)
end
_G.KALZZ_CFG = CFG
local dirty = false
task.spawn(function()
    while true do task.wait(3)
        if dirty then dirty = false; pcall(function() writefile(CF, HS:JSONEncode(CFG)) end) end
    end
end)
pcall(function()
    game:BindToClose(function()
        if CFS then pcall(function() writefile(CF, HS:JSONEncode(CFG)) end) end
    end)
end)
_G.KZ_SaveConfig = function() dirty = true end

-- ═══════════════════════════════════════════════════════════════
-- §G  SHARED UTILS
-- ═══════════════════════════════════════════════════════════════
local PID = {
    ["122812055447896"]=1,["133963973694098"]=1,["117042998468241"]=1,["135002183282873"]=1,
    ["121216847022485"]=1,["132817836308238"]=1,["129784271201071"]=1,["82666958311998"]=1,
    ["78432063483146"]=1,["118907603246885"]=1,["139369275981139"]=1,["110355011987939"]=1,
    ["111920872708571"]=1,["105374834496520"]=1,["138720291317243"]=1,["106871536134254"]=1,
    ["130593238885843"]=1,["115244153053858"]=1,["74968262036854"]=1,["113255068724446"]=1,
    ["98163597193511"]=1,["80411309607666"]=1,
}
local CK  = Color3.fromRGB(230,80,80)
local CS  = Color3.fromRGB(80,160,230)
local CGr = Color3.fromRGB(80,220,120)

local function rtp(m)
    if not m then return nil end
    return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("RootPart") or m:FindFirstChildWhichIsA("BasePart")
end

local KKW = {"jason","killer","stalker","masked","hidden","abyss","veil","cure","hunter","slasher","mori","maniac","demon","jeff","mayers"}
local function hK(s, l)
    if not s then return false end
    s = s:lower()
    for _, k in ipairs(l) do if s:find(k, 1, true) then return true end end
    return false
end

local function isKiller(ch)
    if not ch or not ch.Parent then return false end
    local pl = P:GetPlayerFromCharacter(ch)
    if not pl then return false end
    for _, a in ipairs({"Role","role","Team","team","Type","type"}) do
        local v = pl:GetAttribute(a) or ch:GetAttribute(a)
        if type(v) == "string" then
            local lv = v:lower()
            if lv:find("killer") then return true end
            if lv:find("survivor") then return false end
        end
    end
    if pl.Team then
        local tn = pl.Team.Name:lower()
        if tn:find("killer") then return true end
        if tn:find("survivor") then return false end
    end
    local tl = ch:FindFirstChildOfClass("Tool")
    if tl then
        local n = tl.Name:lower()
        if n:find("knife") or n:find("sword") or n:find("weapon") then return true end
    end
    if hK(pl.Name, KKW) or hK(pl.DisplayName, KKW) or hK(ch.Name, KKW) then return true end
    return false
end

_G.KZ_isKiller = isKiller
_G.KZ_root = rtp

-- Scheduler
local Sched = { _t = {} }
function Sched:Add(name, fn, hz)
    self._t[name] = { fn = fn, interval = 1/(hz or 30), last = 0 }
end
RSvc.Heartbeat:Connect(function()
    local now = os.clock()
    for _, t in pairs(Sched._t) do
        if now - t.last >= t.interval then t.last = now; pcall(t.fn) end
    end
end)
_G.KZ_Sched = Sched

-- Bundle shared context
local SharedCtx = {
    P = P, LP = LP, PG = PG, CG = CG, WS = WS, UIS = UIS, RS = RS,
    TS = TS, RSvc = RSvc, L = L, HS = HS,
    CFG = CFG, CF = CF, CFS = CFS,
    PID = PID, CK = CK, CS = CS, CGr = CGr,
    rtp = rtp, isKiller = isKiller, hK = hK, KKW = KKW,
    Sched = Sched, Modules = Modules,
    Register = Register, Require = Require,
    SaveConfig = _G.KZ_SaveConfig,
}

-- ═══════════════════════════════════════════════════════════════
-- ▼▼▼ PASTE MODULES BELOW ▼▼▼
-- ═══════════════════════════════════════════════════════════════



-- ═══════════════════════════════════════════════════════════════
-- ▲▲▲ PASTE MODULES ABOVE ▲▲▲
-- ═══════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════
-- §H  BOOT — Load all modules in order
-- ═══════════════════════════════════════════════════════════════
local BootOrder = {
    "ui",
    "FastVault", "Invisible", "FakePerks", "AutoGen",
    "SilentAim", "Veil", "Parry", "AutoCrouch",
    "ESP", "Alert", "StunIndicator",
    "FOVLock", "Visuals",
}

print("[KALZZ HUB v1] Booting...")

local Loaded = {}
for _, name in ipairs(BootOrder) do
    local ok, result = pcall(function()
        return Require(name, SharedCtx)
    end)
    if ok then
        Loaded[name] = result
        print("  ✔ "..name..".lua")
    else
        warn("  ✘ "..name..".lua — "..tostring(result))
    end
end

-- Expose loaded modules
_G.KALZZ = { Modules = Modules, Loaded = Loaded, CFG = CFG, Sched = Sched }

print(("[KALZZ HUB v1] Loaded • %d/%d modules"):format(
    (function() local n=0 for _ in pairs(Loaded) do n=n+1 end return n end)(),
    #BootOrder
))

return _G.KALZZ
