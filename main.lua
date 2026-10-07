-- === main.lua ===
local KZ = {
    Config = {},
    Modules = {},
    Utils = {}
}

-- Load utils
KZ.Utils = require(script.untils)

-- Load config
KZ.Config = require(script:WaitForChild("Config"))

-- Load modules
for _, module in ipairs(script.modules:GetChildren()) do
    if module:IsA("ModuleScript") then
        KZ.Modules[module.Name] = require(module)
    end
end

-- Load UI
local UI = require(script.ui)
UI.Initialize(KZ)

print("[KALZZ HUB v1] Loaded")

_G.KALZZ = KZ
return KZ
