-- ============================================================
--   Young0x Hub — Loader v4.0
--   github.com/Young0xYT/Hub
-- ============================================================

local RAW          = "https://raw.githubusercontent.com/Young0xYT/Hub/main/modules/"
local WHITELIST_URL = "https://raw.githubusercontent.com/Young0xYT/Hub/main/whitelist.lua"

-- ─────────────────────────────────────────
--  MÓDULOS PLANEADOS
--  available = true  → intenta ejecutar
--  available = false → "En mantenimiento"
--  dev       = true  → "En desarrollo"
-- ─────────────────────────────────────────
local PLANNED_MODULES = {
    {
        name      = "Fast Glitch 90%",
        file      = "fg90.lua",
        desc      = "Simple Fast Glitch (Activa el Anti AFK)",
        available = true,
        dev       = false,
    },
    {
        name      = "Fast Glitch 100%",
        file      = "fg100.lua",
        desc      = "Fast Glitch mejorado",
        available = false,
        dev       = true,
    },
    {
        name      = "Fast Farm",
        file      = "fastfarm.lua",
        desc      = "Automatización de farming",
        available = false,
        dev       = false,
    },
    {
        name      = "Auto Rebirth",
        file      = "autorebirth.lua",
        desc      = "Sistema de rebirth automático",
        available = false,
        dev       = false,
    },
    {
        name      = "Auto Kill",
        file      = "autokill.lua",
        desc      = "Automatiza el combate",
        available = false,
        dev       = false,
    },
    {
        name      = "Anti Lag",
        file      = "antilag.lua",
        desc      = "Reduce el lag del juego",
        available = false,
        dev       = false,
    },
    {
        name      = "Anti AFK",
        file      = "antiafk.lua",
        desc      = "Evita desconexiones por AFK",
        available = false,
        dev       = false,
    },
}
-- ─────────────────────────────────────────
--  FIN ZONA EDITABLE
-- ─────────────────────────────────────────


-- ════════════════════════════════════════
--   NO TOCAR NADA DE ACÁ EN ADELANTE
-- ════════════════════════════════════════

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player       = Players.LocalPlayer
local playerGui    = player:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────
--  WHITELIST — verifica antes de abrir hub
-- ─────────────────────────────────────────
local function checkWhitelist()
    local ok, result = pcall(function()
        return game:HttpGet(WHITELIST_URL, true)
    end)
    if not ok or not result then return false end

    local fn, err = loadstring(result)
    if not fn then return false end

    local wl = fn()
    if type(wl) ~= "table" then return false end

    return wl[player.UserId] == true
end

if not checkWhitelist() then
    -- Usuario no autorizado — notificación simple y corte
    local ng = Instance.new("ScreenGui")
    ng.Name           = "HubDenied"
    ng.ResetOnSpawn   = false
    ng.IgnoreGuiInset = true
    ng.Parent         = playerGui

    local bg = Instance.new("Frame")
    bg.Size             = UDim2.new(0, 360, 0, 90)
    bg.Position         = UDim2.new(0.5, -180, 0, -100)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
    bg.BorderSizePixel  = 0
    bg.Parent           = ng

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 14)
    bgCorner.Parent = bg

    local bgStroke = Instance.new("UIStroke")
    bgStroke.Color     = Color3.fromRGB(0, 200, 255)
    bgStroke.Thickness = 1.5
    bgStroke.Parent    = bg

    local icon = Instance.new("TextLabel")
    icon.Text                  = "⛔"
    icon.TextSize               = 28
    icon.Font                  = Enum.Font.GothamBold
    icon.BackgroundTransparency = 1
    icon.Size                  = UDim2.new(0, 40, 1, 0)
    icon.Position              = UDim2.new(0, 14, 0, 0)
    icon.TextXAlignment        = Enum.TextXAlignment.Left
    icon.TextYAlignment        = Enum.TextYAlignment.Center
    icon.ZIndex                = 2
    icon.Parent                = bg

    local msg = Instance.new("TextLabel")
    msg.Text                  = "Acceso denegado\nNo estás en la whitelist."
    msg.Font                  = Enum.Font.GothamBold
    msg.TextSize               = 14
    msg.TextColor3             = Color3.fromRGB(220, 220, 255)
    msg.BackgroundTransparency = 1
    msg.Size                  = UDim2.new(1, -70, 1, 0)
    msg.Position              = UDim2.new(0, 58, 0, 0)
    msg.TextXAlignment        = Enum.TextXAlignment.Left
    msg.TextYAlignment        = Enum.TextYAlignment.Center
    msg.ZIndex                = 2
    msg.Parent                = bg

    -- Animación entrada y salida
    TweenService:Create(bg,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, -180, 0, 24) }
    ):Play()

    task.wait(3.5)

    TweenService:Create(bg,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Position = UDim2.new(0.5, -180, 0, -120) }
    ):Play()

    task.wait(0.35)
    ng:Destroy()

    return  -- corta ejecución del loader
end

-- ─────────────────────────────────────────
--  USUARIO AUTORIZADO — abre el hub
-- ─────────────────────────────────────────

if playerGui:FindFirstChild("HubGui") then
    playerGui.HubGui:Destroy()
end

-- ─────────────────────────────────────────
--  COLORES GLOBALES — celeste, blanco, negro
-- ─────────────────────────────────────────
local C = {
    bg          = Color3.fromRGB(8,   10,  16),   -- fondo card negro puro
    header      = Color3.fromRGB(12,  14,  22),   -- header negro azulado
    accent      = Color3.fromRGB(0,   210, 255),  -- celeste principal
    accentDim   = Color3.fromRGB(0,   140, 180),  -- celeste oscuro
    row         = Color3.fromRGB(14,  16,  26),   -- fila normal
    rowHover    = Color3.fromRGB(20,  24,  40),   -- fila hover
    rowDisabled = Color3.fromRGB(10,  11,  18),   -- fila deshabilitada
    stroke      = Color3.fromRGB(30,  35,  60),   -- borde normal
    strokeHover = Color3.fromRGB(0,   210, 255),  -- borde hover celeste
    strokeDis   = Color3.fromRGB(20,  22,  35),   -- borde deshabilitado
    textMain    = Color3.fromRGB(240, 245, 255),  -- blanco principal
    textSub     = Color3.fromRGB(100, 120, 160),  -- gris azulado subtítulo
    textDis     = Color3.fromRGB(50,  58,  80),   -- texto deshabilitado
    textDev     = Color3.fromRGB(0,   180, 220),  -- celeste para "en desarrollo"
    white       = Color3.fromRGB(255, 255, 255),
}

-- ─────────────────────────────────────────
--  TAMAÑO
-- ─────────────────────────────────────────
local CARD_W    = 430
local ROW_H     = 72
local ROW_GAP   = 6
local HEADER_H  = 78
local PADDING_B = 14
local CARD_H    = HEADER_H + PADDING_B + (#PLANNED_MODULES * (ROW_H + ROW_GAP))

-- ─────────────────────────────────────────
--  GUI RAÍZ
-- ─────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name           = "HubGui"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent         = playerGui

local pendingFile = nil
local closing     = false
local card        -- forward declaration

-- ─────────────────────────────────────────
--  CERRAR HUB
-- ─────────────────────────────────────────
local function closeHub()
    if closing then return end
    closing = true

    TweenService:Create(card,
        TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        { Position = UDim2.new(0.5, -CARD_W / 2, 1.5, 0) }
    ):Play()

    task.wait(0.36)
    gui:Destroy()

    if pendingFile then
        local ok, err = pcall(function()
            loadstring(game:HttpGet(RAW .. pendingFile, true))()
        end)
        if not ok then
            warn("[Young0x Hub] Error: " .. tostring(err))
        end
    end
end

-- ─────────────────────────────────────────
--  CARD
-- ─────────────────────────────────────────
card = Instance.new("Frame")
card.Name             = "Card"
card.Size             = UDim2.new(0, CARD_W, 0, CARD_H)
card.Position         = UDim2.new(0.5, -CARD_W / 2, 1.5, 0)
card.BackgroundColor3 = C.bg
card.BorderSizePixel  = 0
card.ZIndex           = 10
card.Parent           = gui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 18)
cardCorner.Parent       = card

local cardStroke = Instance.new("UIStroke")
cardStroke.Color     = C.accent
cardStroke.Thickness = 1.4
cardStroke.Parent    = card

-- Brillo sutil interior top (línea blanca difusa arriba del card)
local shine = Instance.new("Frame")
shine.Size             = UDim2.new(0.7, 0, 0, 1)
shine.Position         = UDim2.new(0.15, 0, 0, 0)
shine.BackgroundColor3 = Color3.fromRGB(180, 230, 255)
shine.BorderSizePixel  = 0
shine.ZIndex           = 15
shine.Parent           = card

-- ─────────────────────────────────────────
--  HEADER
-- ─────────────────────────────────────────
local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0, HEADER_H)
header.Position         = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = C.header
header.BorderSizePixel  = 0
header.ZIndex           = 11
header.Parent           = card

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 18)
headerCorner.Parent       = header

local headerPatch = Instance.new("Frame")
headerPatch.Size             = UDim2.new(1, 0, 0, 18)
headerPatch.Position         = UDim2.new(0, 0, 1, -18)
headerPatch.BackgroundColor3 = C.header
headerPatch.BorderSizePixel  = 0
headerPatch.ZIndex           = 11
headerPatch.Parent           = header

-- Línea celeste inferior del header
local headerLine = Instance.new("Frame")
headerLine.Size             = UDim2.new(1, 0, 0, 1)
headerLine.Position         = UDim2.new(0, 0, 1, -1)
headerLine.BackgroundColor3 = C.accent
headerLine.BorderSizePixel  = 0
headerLine.ZIndex           = 12
headerLine.Parent           = header

-- Barra acento izquierda (celeste)
local accent = Instance.new("Frame")
accent.Size             = UDim2.new(0, 3, 0, 36)
accent.Position         = UDim2.new(0, 18, 0.5, -18)
accent.BackgroundColor3 = C.accent
accent.BorderSizePixel  = 0
accent.ZIndex           = 13
accent.Parent           = header

local accentCorner = Instance.new("UICorner")
accentCorner.CornerRadius = UDim.new(0, 4)
accentCorner.Parent       = accent

-- Punto decorativo arriba de la barra
local accentDot = Instance.new("Frame")
accentDot.Size             = UDim2.new(0, 7, 0, 7)
accentDot.Position         = UDim2.new(0, 15, 0.5, -22)
accentDot.BackgroundColor3 = C.accent
accentDot.BorderSizePixel  = 0
accentDot.ZIndex           = 13
accentDot.Parent           = header

local accentDotCorner = Instance.new("UICorner")
accentDotCorner.CornerRadius = UDim.new(1, 0)
accentDotCorner.Parent       = accentDot

-- Título
local hubTitle = Instance.new("TextLabel")
hubTitle.Text                  = "Young0x Hub"
hubTitle.Font                  = Enum.Font.GothamBold
hubTitle.TextSize               = 21
hubTitle.TextColor3             = C.white
hubTitle.BackgroundTransparency = 1
hubTitle.Size                  = UDim2.new(1, -90, 0, 28)
hubTitle.Position              = UDim2.new(0, 32, 0, 14)
hubTitle.TextXAlignment        = Enum.TextXAlignment.Left
hubTitle.ZIndex                = 13
hubTitle.Parent                = header

-- Subtítulo
local hubSub = Instance.new("TextLabel")
hubSub.Text                  = "Seleccioná un script para ejecutar"
hubSub.Font                  = Enum.Font.Gotham
hubSub.TextSize               = 12
hubSub.TextColor3             = C.accent
hubSub.BackgroundTransparency = 1
hubSub.Size                  = UDim2.new(1, -90, 0, 16)
hubSub.Position              = UDim2.new(0, 32, 0, 46)
hubSub.TextXAlignment        = Enum.TextXAlignment.Left
hubSub.ZIndex                = 13
hubSub.Parent                = header

-- Badge versión
local badge = Instance.new("TextLabel")
badge.Text                  = " v4.0 "
badge.Font                  = Enum.Font.GothamBold
badge.TextSize               = 10
badge.TextColor3             = C.bg
badge.BackgroundColor3       = C.accent
badge.Size                  = UDim2.new(0, 42, 0, 18)
badge.Position              = UDim2.new(0, 144, 0, 15)
badge.TextXAlignment        = Enum.TextXAlignment.Center
badge.TextYAlignment        = Enum.TextYAlignment.Center
badge.ZIndex                = 14
badge.Parent                = header

local badgeCorner = Instance.new("UICorner")
badgeCorner.CornerRadius = UDim.new(0, 6)
badgeCorner.Parent       = badge

-- Botón cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Text             = "✕"
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 14
closeBtn.TextColor3       = C.textSub
closeBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 36)
closeBtn.Size             = UDim2.new(0, 34, 0, 34)
closeBtn.Position         = UDim2.new(1, -46, 0.5, -17)
closeBtn.BorderSizePixel  = 0
closeBtn.ZIndex           = 14
closeBtn.Parent           = header

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent       = closeBtn

local closeBtnStroke = Instance.new("UIStroke")
closeBtnStroke.Color     = Color3.fromRGB(30, 35, 60)
closeBtnStroke.Thickness = 1
closeBtnStroke.Parent    = closeBtn

closeBtn.MouseButton1Click:Connect(closeHub)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(180, 30, 50),
        TextColor3       = C.white
    }):Play()
    TweenService:Create(closeBtnStroke, TweenInfo.new(0.12), {
        Color = Color3.fromRGB(200, 40, 60)
    }):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(20, 22, 36),
        TextColor3       = C.textSub
    }):Play()
    TweenService:Create(closeBtnStroke, TweenInfo.new(0.12), {
        Color = Color3.fromRGB(30, 35, 60)
    }):Play()
end)

-- ─────────────────────────────────────────
--  LISTA DE MÓDULOS
-- ─────────────────────────────────────────
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size                   = UDim2.new(1, -16, 1, -(HEADER_H + 10 + PADDING_B))
listFrame.Position               = UDim2.new(0, 8, 0, HEADER_H + 8)
listFrame.BackgroundTransparency = 1
listFrame.BorderSizePixel        = 0
listFrame.ScrollBarThickness     = 2
listFrame.ScrollBarImageColor3   = C.accent
listFrame.CanvasSize             = UDim2.new(0, 0, 0, #PLANNED_MODULES * (ROW_H + ROW_GAP))
listFrame.ZIndex                 = 11
listFrame.Parent                 = card

local layout = Instance.new("UIListLayout")
layout.Padding   = UDim.new(0, ROW_GAP)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent    = listFrame

-- ─────────────────────────────────────────
--  GENERAR FILAS
-- ─────────────────────────────────────────
for i, mod in ipairs(PLANNED_MODULES) do

    local isAvailable = mod.available == true
    local isDev       = mod.dev == true

    -- Colores base según estado
    local rowBG     = isAvailable and C.row        or C.rowDisabled
    local strokeCol = isAvailable and C.stroke     or C.strokeDis
    local nameCol   = isAvailable and C.textMain   or C.textDis
    local numCol    = isAvailable and C.accent     or C.textDis

    local descText  = isAvailable and mod.desc
                      or isDev    and "En desarrollo..."
                      or           "En mantenimiento..."

    local descCol   = isAvailable and C.textSub
                      or isDev    and C.textDev
                      or           C.textDis

    -- ── FILA ──
    local row = Instance.new("TextButton")
    row.Name             = "Row_" .. i
    row.Size             = UDim2.new(1, 0, 0, ROW_H)
    row.BackgroundColor3 = rowBG
    row.BorderSizePixel  = 0
    row.Text             = ""
    row.LayoutOrder      = i
    row.ZIndex           = 12
    row.Active           = isAvailable
    row.Parent           = listFrame

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 10)
    rowCorner.Parent       = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color     = strokeCol
    rowStroke.Thickness = 1
    rowStroke.Parent    = row

    -- Número
    local numLabel = Instance.new("TextLabel")
    numLabel.Text                  = string.format("%02d", i)
    numLabel.Font                  = Enum.Font.GothamBold
    numLabel.TextSize               = 11
    numLabel.TextColor3             = numCol
    numLabel.BackgroundTransparency = 1
    numLabel.Size                  = UDim2.new(0, 30, 1, 0)
    numLabel.Position              = UDim2.new(0, 14, 0, 0)
    numLabel.TextXAlignment        = Enum.TextXAlignment.Left
    numLabel.TextYAlignment        = Enum.TextYAlignment.Center
    numLabel.ZIndex                = 13
    numLabel.Parent                = row

    -- Separador vertical
    local vSep = Instance.new("Frame")
    vSep.Size             = UDim2.new(0, 1, 0, 32)
    vSep.Position         = UDim2.new(0, 46, 0.5, -16)
    vSep.BackgroundColor3 = isAvailable and C.accent or C.strokeDis
    vSep.BorderSizePixel  = 0
    vSep.ZIndex           = 13
    vSep.Parent           = row

    -- Nombre
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text                  = mod.name
    nameLabel.Font                  = Enum.Font.GothamBold
    nameLabel.TextSize               = 15
    nameLabel.TextColor3             = nameCol
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size                  = UDim2.new(1, -110, 0, 22)
    nameLabel.Position              = UDim2.new(0, 56, 0, 12)
    nameLabel.TextXAlignment        = Enum.TextXAlignment.Left
    nameLabel.ZIndex                = 13
    nameLabel.Parent                = row

    -- Descripción / estado
    local descLabel = Instance.new("TextLabel")
    descLabel.Text                  = descText
    descLabel.Font                  = Enum.Font.Gotham
    descLabel.TextSize               = 11
    descLabel.TextColor3             = descCol
    descLabel.BackgroundTransparency = 1
    descLabel.Size                  = UDim2.new(1, -110, 0, 16)
    descLabel.Position              = UDim2.new(0, 56, 0, 38)
    descLabel.TextXAlignment        = Enum.TextXAlignment.Left
    descLabel.ZIndex                = 13
    descLabel.Parent                = row

    -- Badge estado (derecha)
    if isAvailable then
        -- Flecha celeste
        local arrow = Instance.new("TextLabel")
        arrow.Text                  = "›"
        arrow.Font                  = Enum.Font.GothamBold
        arrow.TextSize               = 24
        arrow.TextColor3             = C.accentDim
        arrow.BackgroundTransparency = 1
        arrow.Size                  = UDim2.new(0, 28, 1, 0)
        arrow.Position              = UDim2.new(1, -36, 0, 0)
        arrow.TextXAlignment        = Enum.TextXAlignment.Center
        arrow.TextYAlignment        = Enum.TextYAlignment.Center
        arrow.ZIndex                = 13
        arrow.Name                  = "Arrow"
        arrow.Parent                = row

        -- Hover
        row.MouseEnter:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.14), {
                BackgroundColor3 = C.rowHover
            }):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.14), {
                Color = C.strokeHover
            }):Play()
            TweenService:Create(arrow, TweenInfo.new(0.14), {
                TextColor3 = C.accent
            }):Play()
        end)
        row.MouseLeave:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.14), {
                BackgroundColor3 = C.row
            }):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.14), {
                Color = C.stroke
            }):Play()
            TweenService:Create(arrow, TweenInfo.new(0.14), {
                TextColor3 = C.accentDim
            }):Play()
        end)

        -- Click
        local clicked = false
        row.MouseButton1Click:Connect(function()
            if clicked or closing then return end
            clicked = true

            TweenService:Create(row, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(0, 40, 55)
            }):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.1), {
                Color = C.accent
            }):Play()

            pendingFile = mod.file
            task.wait(0.12)
            closeHub()
        end)

    elseif isDev then
        -- Badge "DEV"
        local devBadge = Instance.new("TextLabel")
        devBadge.Text                  = " DEV "
        devBadge.Font                  = Enum.Font.GothamBold
        devBadge.TextSize               = 10
        devBadge.TextColor3             = C.bg
        devBadge.BackgroundColor3       = C.accentDim
        devBadge.Size                  = UDim2.new(0, 38, 0, 18)
        devBadge.Position              = UDim2.new(1, -50, 0.5, -9)
        devBadge.TextXAlignment        = Enum.TextXAlignment.Center
        devBadge.TextYAlignment        = Enum.TextYAlignment.Center
        devBadge.ZIndex                = 13
        devBadge.Parent                = row

        local devBadgeCorner = Instance.new("UICorner")
        devBadgeCorner.CornerRadius = UDim.new(0, 6)
        devBadgeCorner.Parent       = devBadge

    else
        -- Ícono mantenimiento
        local lockIcon = Instance.new("TextLabel")
        lockIcon.Text                  = "🔧"
        lockIcon.TextSize               = 16
        lockIcon.Font                  = Enum.Font.GothamBold
        lockIcon.BackgroundTransparency = 1
        lockIcon.Size                  = UDim2.new(0, 28, 1, 0)
        lockIcon.Position              = UDim2.new(1, -38, 0, 0)
        lockIcon.TextXAlignment        = Enum.TextXAlignment.Center
        lockIcon.TextYAlignment        = Enum.TextYAlignment.Center
        lockIcon.ZIndex                = 13
        lockIcon.Parent                = row
    end
end

-- ─────────────────────────────────────────
--  ANIMACIÓN DE ENTRADA
-- ─────────────────────────────────────────
local targetPos = UDim2.new(0.5, -CARD_W / 2, 0.5, -CARD_H / 2)

task.wait(0.05)
TweenService:Create(card,
    TweenInfo.new(0.44, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Position = targetPos }
):Play()
