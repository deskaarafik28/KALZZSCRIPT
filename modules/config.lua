--[[
    KALZZSCRIPT
    modules/config.lua - Auto Load + Auto Save
    - Load dari kalzz_config.json
    - Save tiap ada perubahan (via UI callback)
]]

local HttpService = game:GetService("HttpService")
local FILE = "kalzz_config.json"

-- Default config
local DEFAULT = {
    tof_on = true,
    tof_fov = 320,
    tof_predict = 2.5,
    tof_maxdist = 800,
    tof_show_fov = true,
    tof_laser = true,

    veil_on = true,
    veil_fov = 320,
    veil_predict = 2.8,
    veil_maxdist = 2000,
    veil_show_fov = true,

    parry_on = true,
    parry_radius = 15,
    parry_aggro = true,
    parry_antifake = true,
    parry_show_circle = false,

    crouch_on = true,

    fast_vault = true,

    esp_k = true,
    esp_s = true,
    esp_g = true,
    esp_gen_txt = true,
    esp_item = true,
    esp_out = false,

    fov_lock = false,
    fov_value = 120,

    ambient = true,
    boost_fps = true,
    alert = true,
    stun_on = true,

    gene_on = false,
    gene_method = "SUCCESS",
}

-- Load existing
local CFG = {}
if readfile and isfile then
    pcall(function()
        if isfile(FILE) then
            local raw = readfile(FILE)
            if raw and raw ~= "" then
                local data = HttpService:JSONDecode(raw)
                for k, v in pairs(data) do
                    if DEFAULT[k] ~= nil then
                        CFG[k] = v
                    end
                end
            end
        end
    end)
end

-- Fill dengan default yang belum ada
for k, v in pairs(DEFAULT) do
    if CFG[k] == nil then CFG[k] = v end
end

-- Save function
local function save()
    if not writefile then return end
    pcall(function()
        writefile(FILE, HttpService:JSONEncode(CFG))
    end)
end

-- Expose ke _G
_G.KALZZ_CFG = CFG
_G.KZ_SaveCfg = save

-- Auto-save tiap 30s (backup safety)
task.spawn(function()
    while true do
        task.wait(30)
        save()
    end
end)

-- Save saat game close / player leave
game:BindToClose(function()
    save()
end)

print("[KZ] config loaded (auto load + save)")
