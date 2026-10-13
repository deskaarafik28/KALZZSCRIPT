local CFG = {
    -- ToF
    tof_on = true,
    tof_fov = 320,
    tof_predict = 2.5,
    tof_maxdist = 800,
    tof_show_fov = true,
    tof_laser = true,

    -- Veil
    veil_on = true,
    veil_fov = 320,
    veil_predict = 2.8,
    veil_maxdist = 2000,
    veil_show_fov = true,

    -- Parry
    parry_on = true,
    parry_radius = 15,
    parry_aggro = true,
    parry_antifake = true,
    parry_show_circle = false,

    -- Vault
    fast_vault = true,

    -- ESP
    esp_k = true,
    esp_s = true,
    esp_g = true,
    esp_gen_txt = true,
    esp_item = true,
    esp_out = false,

    -- Camera
    fov_lock = false,
    fov_value = 120,

    -- Misc
    ambient = true,
    boost_fps = true,
    alert = true,
    stun_on = true,

    -- Gene
    gene_on = false,
    gene_method = "SUCCESS",
}

_G.KALZZ_CFG = CFG
