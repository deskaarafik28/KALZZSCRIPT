-- === main.lua ===
local KZ = {}

local P = game:GetService("Players")
local LP = P.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local CG = game:GetService("CoreGui")
local WS = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local RSvc = game:GetService("RunService")
local L = game:GetService("Lighting")
local HS = game:GetService("HttpService")

-- Config
local CFG = {
    gene_on=true, gene_method="PERFECT",
    fast_vault=true, invisible=false,
    auto_crouch=true, auto_crouch_radius=16, auto_crouch_stand=5,
    tof_on=true, tof_fov=380,
    veil_on=true, veil_fov=280,
    parry_on=true, parry_radius=12, parry_circle=true, parry_aggro=true, parry_sensitive=200,
    esp_k=true, esp_s=true, esp_g=true, esp_out=false, esp_range=5000,
    stun_indicator=true, fog=false, bright=true, cam=true, camv=90, alert=true,
    fake_quick=true, fake_landing=true, fake_adrenaline=true,
}

-- Utils
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

local function rtp(m) 
    if not m then return nil end 
    return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("RootPart") or m:FindFirstChildWhichIsA("BasePart") 
end

local function isKiller(ch)
    if not ch or not ch.Parent then return false end
    local pl = P:GetPlayerFromCharacter(ch)
    if not pl then return false end
    for _,a in ipairs({"Role","role","Team","team","Type","type"}) do
        local v = pl:GetAttribute(a) or ch:GetAttribute(a)
        if type(v)=="string" then local lv=v:lower() if lv:find("killer") then return true end if lv:find("survivor") then return false end end
    end
    if pl.Team then local tn=pl.Team.Name:lower() if tn:find("killer") then return true end if tn:find("survivor") then return false end end
    return false
end

_G.KZ_isKiller = isKiller
_G.KZ_root = rtp

-- Load UI
local UI = require(script.ui)
local UIData = UI.Initialize(KZ, CFG, Sched, rtp, isKiller, P, LP, PG, CG, WS, UIS, TS, RSvc, RS, L, HS)

-- Load systems
require(script.FastVault)(CFG, Sched, rtp, RS, LP, P)
require(script.Invisible)(CFG, LP)
require(script.FakePerks)(CFG, RSvc, LP, P)
require(script.AutoGen)(CFG, Sched, PG, RS, LP, TS)
require(script.SilentAim)(CFG, Sched, WS, LP, P, UIS)
require(script.Veil)(CFG, Sched, WS, LP, P, UIS, isKiller)
require(script.Parry)(CFG, Sched, WS, RS, LP, P, UIS, rtp, isKiller, UIData.Main, UIData.COL)
require(script.AutoCrouch)(CFG, Sched, RSvc, WS, LP, P, rtp)
require(script.ESP)(CFG, Sched, WS, LP, P, rtp, isKiller, UIData.GUI, UIData.COL)
require(script.Alert)(CFG, Sched, WS, LP, P, rtp, isKiller, PG)
require(script.StunIndicator)(CFG, Sched, LP, P, isKiller, PG, rtp)
require(script.FOVLock)(CFG, Sched, WS)
require(script.Visuals)(CFG, Sched, L)

print("[KALZZ HUB v1] Loaded")

_G.KALZZ = {Config=CFG, Scheduler=Sched}
return KZ
