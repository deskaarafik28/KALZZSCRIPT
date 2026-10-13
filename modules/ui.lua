local S = _G.KZ
if not S then return end

-- Load Velvet
local VELVET_URL = "https://raw.githubusercontent.com/DexCodeSX/Velvet/main/source.lua"
local ok, Velvet = pcall(function()
    return loadstring(game:HttpGet(VELVET_URL))()
end)
if not ok or not Velvet then
    warn("[UI] gagal load Velvet: " .. tostring(Velvet))
    return
end

local CFG = S.CFG
local save = _G.KZ_SaveCfg or function() end

-- Helper: toggle + auto-save
local function Tog(sec, id, text, key)
    sec:AddToggle(id, {
        Text = text,
        Default = CFG[key],
        Callback = function(v)
            CFG[key] = v
            save()  -- AUTO-SAVE
        end,
    })
end

local function Slider(sec, id, text, key, min, max, default, inc)
    sec:AddSlider(id, {
        Text = text,
        Min = min, Max = max, Default = default or CFG[key], Increment = inc or 1,
        Callback = function(v)
            CFG[key] = v
            save()
        end,
    })
end

local function Drop(sec, id, text, key, values)
    sec:AddDropdown(id, {
        Text = text,
        Values = values,
        Default = CFG[key],
        Callback = function(v)
            CFG[key] = v
            save()
        end,
    })
end

-- WINDOW
local Window = Velvet:CreateWindow({
    Title = "KALZZ HUB",
    SubTitle = S.INVITE,
    Width = 580, Height = 460,
    ToggleKey = Enum.KeyCode.RightShift,
})

-- INFO
local tInfo = Window:AddTab("Info", "home")
local sInfo = tInfo:AddSection("Kalzz Hub")
sInfo:AddParagraph({ Title = "KALZZ HUB", Content = "Velvet UI • " .. S.INVITE })
sInfo:AddButton({
    Text = "Copy Discord Invite",
    Callback = function()
        pcall(function() if setclipboard then setclipboard("https://" .. S.INVITE) end end)
        Velvet:Notify({Title="Copied", Content="Invite tersalin!", Duration=2, Type="success"})
    end,
})
sInfo:AddButton({
    Text = "Print Remotes",
    Callback = function()
        print("[KZ] ToF:", S.RC.tof, "| Veil:", S.RC.veil, "| Parry:", S.RC.parry, "| FV:", S.RC.fastvault)
    end,
})
sInfo:AddButton({
    Text = "Save Config Now",
    Callback = function()
        save()
        Velvet:Notify({Title="Saved", Content="Config tersimpan.", Duration=2, Type="success"})
    end,
})

-- SURVIVOR
local tSurv = Window:AddTab("Survivor", "user")
local sToF = tSurv:AddSection("Silent Aim ToF")
Tog(sToF, "tof_on", "Enable ToF", "tof_on")
Tog(sToF, "tof_show_fov", "Show FOV Circle", "tof_show_fov")
Tog(sToF, "tof_laser", "Show Laser", "tof_laser")
Slider(sToF, "tof_fov", "FOV", "tof_fov", 1, 800, CFG.tof_fov, 1)
Slider(sToF, "tof_predict", "Predict x10", "tof_predict", 10, 50, math.floor(CFG.tof_predict*10), 1)
Slider(sToF, "tof_maxdist", "Max Distance", "tof_maxdist", 100, 2000, CFG.tof_maxdist, 50)

local sParry = tSurv:AddSection("Auto Parry")
Tog(sParry, "parry_on", "Enable Parry", "parry_on")
Tog(sParry, "parry_antifake", "Anti Fake", "parry_antifake")
Tog(sParry, "parry_show_circle", "Show Circle", "parry_show_circle")
Slider(sParry, "parry_radius", "Sensitiv", "parry_radius", 1, 50, CFG.parry_radius, 1)

local sCrouch = tSurv:AddSection("Auto Crouch")
Tog(sCrouch, "crouch_on", "Enable Auto Crouch", "crouch_on")

local sGene = tSurv:AddSection("Auto Generator")
Tog(sGene, "gene_on", "Enable Auto Gen", "gene_on")
Drop(sGene, "gene_method", "Method", "gene_method", {"SUCCESS","NEUTRAL","INSTANT"})

local sMove = tSurv:AddSection("Movement")
Tog(sMove, "fast_vault", "Fast Vault", "fast_vault")

-- KILLER
local tKill = Window:AddTab("Killer", "sword")
local sVeil = tKill:AddSection("Silent Aim Veil")
Tog(sVeil, "veil_on", "Enable Veil", "veil_on")
Tog(sVeil, "veil_show_fov", "Show FOV Circle", "veil_show_fov")
Slider(sVeil, "veil_fov", "FOV", "veil_fov", 1, 800, CFG.veil_fov, 1)
Slider(sVeil, "veil_predict", "Predict x10", "veil_predict", 10, 50, math.floor(CFG.veil_predict*10), 1)
Slider(sVeil, "veil_maxdist", "Max Distance", "veil_maxdist", 100, 3000, CFG.veil_maxdist, 50)

-- ESP
local tEsp = Window:AddTab("ESP", "eye")
local sEspP = tEsp:AddSection("Player ESP")
Tog(sEspP, "esp_k", "Killer ESP", "esp_k")
Tog(sEspP, "esp_s", "Survivor ESP", "esp_s")
Tog(sEspP, "esp_item", "Show Item Name", "esp_item")

local sEspG = tEsp:AddSection("Generator ESP")
Tog(sEspG, "esp_g", "Generator ESP", "esp_g")
Tog(sEspG, "esp_gen_txt", "Show Progress", "esp_gen_txt")

local sEspSty = tEsp:AddSection("Style")
Tog(sEspSty, "esp_out", "Outline Only", "esp_out")

-- MISC
local tMisc = Window:AddTab("Misc", "settings")
local sVis = tMisc:AddSection("Vision")
Tog(sVis, "fov_lock", "FOV Lock", "fov_lock")
Slider(sVis, "fov_value", "FOV Value", "fov_value", 60, 140, CFG.fov_value, 1)
Tog(sVis, "ambient", "Bright Ambient", "ambient")
Tog(sVis, "boost_fps", "Boost FPS", "boost_fps")

local sAlert = tMisc:AddSection("Alerts")
Tog(sAlert, "alert", "Proximity Alert", "alert")
Tog(sAlert, "stun_on", "Stun Killer Notif", "stun_on")

local sUI = tMisc:AddSection("UI")
sUI:AddButton({
    Text = "Notify: Test",
    Callback = function()
        Velvet:Notify({Title="KALZZ HUB", Content="Notif test aktif!", Duration=3, Type="success"})
    end,
})

Velvet:CreateWatermark({ Text = "KALZZ | {fps} fps | {ping} ms" })

task.delay(0.5, function()
    Velvet:Notify({
        Title = "KALZZ HUB",
        Content = "Loaded. Config auto-load + auto-save aktif.",
        Duration = 4,
        Type = "info",
    })
end)

print("[KZ] ui loaded | Velvet + auto-save")
