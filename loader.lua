-- ============================================================
--  HUB LOADER — v1.0
--  Autor  : Young0xYT
--  Repo   : github.com/Young0xYT/Hub
--  Regla  : Este archivo NO conoce el contenido de los módulos.
--           Solo sabe cómo cargarlos.
-- ============================================================

local Hub = {}

-- ─────────────────────────────────────────────
--  CONFIGURACIÓN CENTRAL
--  Solo edita este bloque cuando agregues módulos
-- ─────────────────────────────────────────────
local CONFIG = {
    repo_base = "https://raw.githubusercontent.com/Young0xYT/Hub/main/modules/",
    
    version = "1.0.0",

    -- REGISTRO DE MÓDULOS
    -- Para agregar un módulo nuevo: solo agrega una entrada aquí.
    -- No toques nada más del loader.
    modules = {
        {
            id       = "fg90",
            file     = "fg90.lua",
            name     = "FG90",
            desc     = "Descripción del módulo FG90",
            version  = "1.0.0",
            enabled  = true,
        },
        {
            id       = "fg100",
            file     = "fg100.lua",
            name     = "FG100",
            desc     = "Descripción del módulo FG100",
            version  = "1.0.0",
            enabled  = true,
        },
        {
            id       = "fastfarm",
            file     = "fastfarm.lua",
            name     = "Fast Farm",
            desc     = "Automatización de farming",
            version  = "1.0.0",
            enabled  = true,
        },
        {
            id       = "autorebirth",
            file     = "autorebirth.lua",
            name     = "Auto Rebirth",
            desc     = "Sistema de rebirth automático",
            version  = "1.0.0",
            enabled  = true,
        },
        -- TEMPLATE para módulos futuros:
        -- {
        --     id      = "nuevo_modulo",
        --     file    = "nuevo_modulo.lua",
        --     name    = "Nombre visible",
        --     desc    = "Qué hace este módulo",
        --     version = "1.0.0",
        --     enabled = true,
        -- },
    }
}

-- ─────────────────────────────────────────────
--  ESTADO INTERNO
--  El loader registra qué módulos están cargados
--  y cuáles fallaron. Los módulos no leen esto.
-- ─────────────────────────────────────────────
local State = {
    loaded  = {},   -- { [id] = true/false }
    errors  = {},   -- { [id] = "mensaje de error" }
    started = false
}

-- ─────────────────────────────────────────────
--  LOGGER
--  Sistema de mensajes interno del loader
-- ─────────────────────────────────────────────
local function log(tipo, msg)
    local prefix = {
        info  = "[HUB] ",
        ok    = "[OK]  ",
        fail  = "[ERR] ",
        warn  = "[!]   ",
    }
    print((prefix[tipo] or "[?]   ") .. msg)
end

-- ─────────────────────────────────────────────
--  FETCH
--  Descarga el contenido de una URL
--  Devuelve: contenido (string) o nil + error
-- ─────────────────────────────────────────────
local function fetch(url)
    local ok, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    if ok and result and #result > 0 then
        return result, nil
    else
        return nil, tostring(result)
    end
end

-- ─────────────────────────────────────────────
--  EXECUTE
--  Ejecuta un string de código Lua de forma segura
--  Devuelve: true/nil + error
-- ─────────────────────────────────────────────
local function execute(code, module_id)
    local fn, compile_err = loadstring(code)
    if not fn then
        return nil, "Error de compilación: " .. tostring(compile_err)
    end
    local ok, run_err = pcall(fn)
    if not ok then
        return nil, "Error de ejecución: " .. tostring(run_err)
    end
    return true, nil
end

-- ─────────────────────────────────────────────
--  LOAD MODULE
--  Lógica central: descarga y ejecuta un módulo
--  El loader no sabe qué hace el módulo.
--  Solo sabe si cargó bien o mal.
-- ─────────────────────────────────────────────
local function loadModule(mod)
    -- Módulo deshabilitado en CONFIG
    if not mod.enabled then
        log("warn", mod.name .. " está deshabilitado en CONFIG. Saltando.")
        State.loaded[mod.id] = false
        return false
    end

    -- Ya fue cargado antes
    if State.loaded[mod.id] then
        log("warn", mod.name .. " ya está cargado. Saltando.")
        return true
    end

    log("info", "Cargando " .. mod.name .. " v" .. mod.version .. "...")

    local url  = CONFIG.repo_base .. mod.file
    local code, fetch_err = fetch(url)

    if not code then
        local err_msg = "No se pudo descargar " .. mod.file .. " → " .. tostring(fetch_err)
        log("fail", err_msg)
        State.loaded[mod.id] = false
        State.errors[mod.id] = err_msg
        return false
    end

    local ok, exec_err = execute(code, mod.id)

    if not ok then
        log("fail", mod.name .. " falló al ejecutar → " .. exec_err)
        State.loaded[mod.id] = false
        State.errors[mod.id] = exec_err
        return false
    end

    log("ok", mod.name .. " cargado correctamente.")
    State.loaded[mod.id] = true
    return true
end

-- ─────────────────────────────────────────────
--  API PÚBLICA DEL HUB
-- ─────────────────────────────────────────────

-- Carga un módulo por su ID
function Hub.load(module_id)
    for _, mod in ipairs(CONFIG.modules) do
        if mod.id == module_id then
            return loadModule(mod)
        end
    end
    log("fail", "Módulo '" .. module_id .. "' no existe en el registro.")
    return false
end

-- Carga todos los módulos habilitados
function Hub.loadAll()
    log("info", "Iniciando carga de todos los módulos...")
    local total, ok_count, fail_count = 0, 0, 0

    for _, mod in ipairs(CONFIG.modules) do
        if mod.enabled then
            total = total + 1
            local success = loadModule(mod)
            if success then
                ok_count = ok_count + 1
            else
                fail_count = fail_count + 1
            end
        end
    end

    log("info", ("Resultado: %d/%d módulos cargados. Fallos: %d"):format(ok_count, total, fail_count))
end

-- Muestra el estado actual de todos los módulos
function Hub.status()
    print("\n══════════════════════════════════")
    print("  HUB v" .. CONFIG.version .. " — Estado de módulos")
    print("══════════════════════════════════")
    for _, mod in ipairs(CONFIG.modules) do
        local estado
        if not mod.enabled then
            estado = "DESHABILITADO"
        elseif State.loaded[mod.id] == true then
            estado = "CARGADO"
        elseif State.loaded[mod.id] == false then
            estado = "FALLÓ"
        else
            estado = "PENDIENTE"
        end
        print(("  %-15s v%-8s [%s]"):format(mod.name, mod.version, estado))
        if State.errors[mod.id] then
            print("    └─ " .. State.errors[mod.id])
        end
    end
    print("══════════════════════════════════\n")
end

-- Lista los módulos disponibles (sin cargarlos)
function Hub.list()
    print("\n── Módulos registrados en Hub v" .. CONFIG.version .. " ──")
    for i, mod in ipairs(CONFIG.modules) do
        local flag = mod.enabled and "✓" or "✗"
        print(("  %s [%d] %-15s — %s"):format(flag, i, mod.name, mod.desc))
    end
    print("")
end

-- Devuelve si un módulo fue cargado exitosamente
function Hub.isLoaded(module_id)
    return State.loaded[module_id] == true
end

-- ─────────────────────────────────────────────
--  ARRANQUE AUTOMÁTICO
-- ─────────────────────────────────────────────
log("info", "Hub v" .. CONFIG.version .. " inicializado.")
Hub.list()
Hub.loadAll()
Hub.status()

return Hub
