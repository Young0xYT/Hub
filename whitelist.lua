-- ============================================================
--  Young0x Hub — Whitelist (Mejorado)
--  github.com/Young0xYT/Hub
--
--  Si el archivo no existe o hay error:
--  - El loader mostrará un mensaje de error
--  - No se permitirá el acceso
-- ============================================================

local success, whitelist = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Young0xYT/Hub/main/whitelist.lua",
        true
    ))()
end)

if not success or not whitelist then
    warn("[Young0x Hub] Error al cargar whitelist.lua")
    return false
end

return whitelist
