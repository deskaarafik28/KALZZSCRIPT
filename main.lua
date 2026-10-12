--[[ KALZZSCRIPT | main.lua ]]

local BASE_URL = "https://raw.githubusercontent.com/deskaarafik28/KALZZSCRIPT/refs/heads/main/modules/"

local MODULES = {
    "kick-bypass",
    "silent-aim-veil",
    "silent-aim-tof",
    "auto-parry",
    "auto-gen",
    "fast-vault",
    "stun-notif",
    "alert",
    "vision",
    "esp",
    "utility",
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

S.CFG = _G.KALZZ_CFG or {
    tof_on=true, tof_fov=500, tof_predict=2.8, tof_maxdist=2000, tof_show_fov=true,
    veil_on=true, veil_fov=320, veil_predict=2.8, veil_maxdist=2000, veil_show_fov=true,
    parry_on=true, parry_radius=6000, parry_aggro=true, parry_show_circle=false,
    fast_vault=true,
    esp_k=true, esp_s=true, esp_g=true, esp_gen_txt=true, esp_item=true, esp_out=false,
    fov_lock=false, fov_value=120,
    ambient=true, boost_fps=true, alert=true, stun_on=true,
    gene_on=false, gene_method="SUCCESS",
}
_G.KALZZ_CFG = S.CFG

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

S.Hooks = { list = {}, installed = false }
function S.Hooks:Add(name, prio, fn)
    table.insert(self.list, { name=name, prio=prio or 50, fn=fn })
    table.sort(self.list, function(a,b) return a.prio < b.prio end)
end
function S.Hooks:Install()
    if self.installed then return end
    if typeof(hookmetamethod)~="function"
        or typeof(newcclosure)~="function"
        or typeof(getnamecallmethod)~="function"
    then warn("[KZ] executor no hook support") return end
    self.installed = true
    local OLD
    OLD = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local m; pcall(function() m = getnamecallmethod() end)
        local args = table.pack(...); local n = args.n
        for _, h in ipairs(S.Hooks.list) do
            local ok, res = pcall(h.fn, self, m, args, n)
            if ok then
                if res == true then return nil end
                if type(res)=="table" and res.n then
                    return OLD(self, table.unpack(res, 1, res.n))
                end
            end
        end
        return OLD(self, table.unpack(args, 1, n))
    end))
end
S.Hooks:Install()

_G.KZ = S

local function loadModule(name)
    local url = BASE_URL .. name .. ".lua"
    local ok, src = pcall(game.HttpGet, game, url)
    if not ok or not src or src == "" then
        warn("[KZ] gagal load: " .. name)
        return
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

print("[KZ] main.lua loaded | modules:", #MODULES)
