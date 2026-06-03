-- ============================================================
--   Young0x Hub — Loader v4.0
--   github.com/Young0xYT/Hub
-- ============================================================

local RAW = "https://raw.githubusercontent.com/Young0xYT/Hub/main/modules/"

-- ─────────────────────────────────────────
--  MÓDULOS
--  available = true  → ejecutable
--  available = false → "En mantenimiento..."
--  dev       = true  → "En desarrollo..."
-- ─────────────────────────────────────────
local MODULES = {
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

-- ════════════════════════════════════════
--   NO TOCAR NADA DE ACÁ EN ADELANTE
-- ════════════════════════════════════════

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player       = Players.LocalPlayer
local playerGui    = player:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────
--  WHITELIST
-- ─────────────────────────────────────────
local wlOk, wlResult = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Young0xYT/Hub/main/whitelist.lua", true
    ))()
end)

if not wlOk or type(wlResult) ~= "table" or wlResult[player.UserId] ~= true then
    warn("[Young0x Hub] No autorizado.")
    return
end

-- ─────────────────────────────────────────
--  LIMPIA GUI ANTERIOR
-- ─────────────────────────────────────────
if playerGui:FindFirstChild("HubGui") then
    playerGui.HubGui:Destroy()
end

-- ─────────────────────────────────────────
--  TAMAÑO
-- ─────────────────────────────────────────
local CARD_W    = 420
local ROW_H     = 70
local ROW_GAP   = 6
local HEADER_H  = 74
local PADDING_B = 14
local MAX_H     = 580  -- límite para que no reviente la pantalla
local CARD_H    = math.min(
    HEADER_H + PADDING_B + (#MODULES * (ROW_H + ROW_GAP)),
    MAX_H
)

-- ─────────────────────────────────────────
--  COLORES
-- ─────────────────────────────────────────
local BG         = Color3.fromRGB(8,   10,  16)
local BG_HEADER  = Color3.fromRGB(12,  14,  22)
local BG_ROW     = Color3.fromRGB(14,  16,  26)
local BG_ROW_DIS = Color3.fromRGB(10,  11,  18)
local CYAN       = Color3.fromRGB(0,   210, 255)
local CYAN_DIM   = Color3.fromRGB(0,   130, 170)
local WHITE      = Color3.fromRGB(240, 245, 255)
local GRAY       = Color3.fromRGB(80,  95,  130)
local DARK       = Color3.fromRGB(40,  45,  70)
local DIS_TEXT   = Color3.fromRGB(45,  52,  75)
local DEV_COL    = Color3.fromRGB(0,   170, 210)

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
local card

-- ─────────────────────────────────────────
--  CERRAR
-- ─────────────────────────────────────────
local function closeHub()
    if closing then return end
    closing = true

    TweenService:Create(card,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        { Position = UDim2.new(0.5, -CARD_W / 2, 1.5, 0) }
    ):Play()

    task.wait(0.35)
    gui:Destroy()

    if pendingFile then
        local ok, err = pcall(function()
            loadstring(game:HttpGet(RAW .. pendingFile, true))()
        end)
        if not ok then
            warn("[Young0x Hub] Error al cargar " .. pendingFile .. ": " .. tostring(err))
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
card.BackgroundColor3 = BG
card.BorderSizePixel  = 0
card.ZIndex           = 10
card.Parent           = gui

Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)

local cardStroke = Instance.new("UIStroke")
cardStroke.Color     = CYAN
cardStroke.Thickness = 1.2
cardStroke.Parent    = card

-- ─────────────────────────────────────────
--  HEADER
-- ─────────────────────────────────────────
local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0, HEADER_H)
header.Position         = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = BG_HEADER
header.BorderSizePixel  = 0
header.ZIndex           = 11
header.Parent           = card

Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

-- Parche esquinas inferiores del header
local patch = Instance.new("Frame")
patch.Size             = UDim2.new(1, 0, 0, 16)
patch.Position         = UDim2.new(0, 0, 1, -16)
patch.BackgroundColor3 = BG_HEADER
patch.BorderSizePixel  = 0
patch.ZIndex           = 11
patch.Parent           = header

-- Línea celeste inferior del header
local hLine = Instance.new("Frame")
hLine.Size             = UDim2.new(1, -28, 0, 1)
hLine.Position         = UDim2.new(0, 14, 1, -1)
hLine.BackgroundColor3 = CYAN
hLine.BorderSizePixel  = 0
hLine.ZIndex           = 12
hLine.Parent           = header

-- Barra acento izquierda
local accentBar = Instance.new("Frame")
accentBar.Size             = UDim2.new(0, 3, 0, 34)
accentBar.Position         = UDim2.new(0, 18, 0.5, -17)
accentBar.BackgroundColor3 = CYAN
accentBar.BorderSizePixel  = 0
accentBar.ZIndex           = 13
accentBar.Parent           = header
Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 4)

-- Título
local hubTitle = Instance.new("TextLabel")
hubTitle.Text                  = "Young0x Hub"
hubTitle.Font                  = Enum.Font.GothamBold
hubTitle.TextSize               = 20
hubTitle.TextColor3             = WHITE
hubTitle.BackgroundTransparency = 1
hubTitle.Size                  = UDim2.new(1, -90, 0, 26)
hubTitle.Position              = UDim2.new(0, 30, 0, 12)
hubTitle.TextXAlignment        = Enum.TextXAlignment.Left
hubTitle.ZIndex                = 13
hubTitle.Parent                = header

-- Badge v4.0
local badge = Instance.new("TextLabel")
badge.Text                  = "v4.0"
badge.Font                  = Enum.Font.GothamBold
badge.TextSize               = 9
badge.TextColor3             = BG
badge.BackgroundColor3       = CYAN
badge.Size                  = UDim2.new(0, 38, 0, 16)
badge.Position              = UDim2.new(0, 138, 0, 14)
badge.TextXAlignment        = Enum.TextXAlignment.Center
badge.TextYAlignment        = Enum.TextYAlignment.Center
badge.ZIndex                = 14
badge.Parent                = header
Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 5)

-- Subtítulo
local hubSub = Instance.new("TextLabel")
hubSub.Text                  = "Seleccioná un script"
hubSub.Font                  = Enum.Font.Gotham
hubSub.TextSize               = 12
hubSub.TextColor3             = CYAN_DIM
hubSub.BackgroundTransparency = 1
hubSub.Size                  = UDim2.new(1, -90, 0, 16)
hubSub.Position              = UDim2.new(0, 30, 0, 44)
hubSub.TextXAlignment        = Enum.TextXAlignment.Left
hubSub.ZIndex                = 13
hubSub.Parent                = header

-- Botón cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Text             = "✕"
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 13
closeBtn.TextColor3       = GRAY
closeBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 36)
closeBtn.Size             = UDim2.new(0, 32, 0, 32)
closeBtn.Position         = UDim2.new(1, -44, 0.5, -16)
closeBtn.BorderSizePixel  = 0
closeBtn.ZIndex           = 14
closeBtn.Parent           = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

closeBtn.MouseButton1Click:Connect(closeHub)
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(160, 30, 45),
        TextColor3       = WHITE
    }):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(20, 22, 36),
        TextColor3       = GRAY
    }):Play()
end)

-- ─────────────────────────────────────────
--  LISTA
-- ─────────────────────────────────────────
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size                   = UDim2.new(1, -16, 1, -(HEADER_H + 10 + PADDING_B))
listFrame.Position               = UDim2.new(0, 8, 0, HEADER_H + 8)
listFrame.BackgroundTransparency = 1
listFrame.BorderSizePixel        = 0
listFrame.ScrollBarThickness     = 2
listFrame.ScrollBarImageColor3   = CYAN
listFrame.CanvasSize             = UDim2.new(0, 0, 0, #MODULES * (ROW_H + ROW_GAP))
listFrame.ZIndex                 = 11
listFrame.Parent                 = card

local layout = Instance.new("UIListLayout")
layout.Padding   = UDim.new(0, ROW_GAP)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent    = listFrame

-- ─────────────────────────────────────────
--  FILAS
-- ─────────────────────────────────────────
for i, mod in ipairs(MODULES) do

    local isAvailable = mod.available == true
    local isDev       = mod.dev == true

    local row = Instance.new("TextButton")
    row.Name             = "Row_" .. i
    row.Size             = UDim2.new(1, 0, 0, ROW_H)
    row.BackgroundColor3 = isAvailable and BG_ROW or BG_ROW_DIS
    row.BorderSizePixel  = 0
    row.Text             = ""
    row.LayoutOrder      = i
    row.ZIndex           = 12
    row.Active           = isAvailable
    row.Parent           = listFrame

    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color     = isAvailable and DARK or Color3.fromRGB(20, 22, 34)
    rowStroke.Thickness = 1
    rowStroke.Parent    = row

    -- Nombre
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text                  = mod.name
    nameLabel.Font                  = Enum.Font.GothamBold
    nameLabel.TextSize               = 14
    nameLabel.TextColor3             = isAvailable and WHITE or DIS_TEXT
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size                  = UDim2.new(1, -100, 0, 22)
    nameLabel.Position              = UDim2.new(0, 16, 0, 12)
    nameLabel.TextXAlignment        = Enum.TextXAlignment.Left
    nameLabel.ZIndex                = 13
    nameLabel.Parent                = row

    -- Desc / estado
    local descLabel = Instance.new("TextLabel")
    descLabel.Text                  = isAvailable and mod.desc
                                      or isDev     and "En desarrollo..."
                                      or              "En mantenimiento..."
    descLabel.Font                  = Enum.Font.Gotham
    descLabel.TextSize               = 11
    descLabel.TextColor3             = isAvailable and GRAY
                                       or isDev     and DEV_COL
                                       or              DIS_TEXT
    descLabel.BackgroundTransparency = 1
    descLabel.Size                  = UDim2.new(1, -100, 0, 16)
    descLabel.Position              = UDim2.new(0, 16, 0, 38)
    descLabel.TextXAlignment        = Enum.TextXAlignment.Left
    descLabel.ZIndex                = 13
    descLabel.Parent                = row

    -- Indicador derecho
    if isAvailable then
        local arrow = Instance.new("TextLabel")
        arrow.Text                  = "›"
        arrow.Font                  = Enum.Font.GothamBold
        arrow.TextSize               = 26
        arrow.TextColor3             = CYAN_DIM
        arrow.BackgroundTransparency = 1
        arrow.Size                  = UDim2.new(0, 28, 1, 0)
        arrow.Position              = UDim2.new(1, -36, 0, 0)
        arrow.TextXAlignment        = Enum.TextXAlignment.Center
        arrow.TextYAlignment        = Enum.TextYAlignment.Center
        arrow.ZIndex                = 13
        arrow.Parent                = row

        row.MouseEnter:Connect(function()
            TweenService:Create(row,      TweenInfo.new(0.14), { BackgroundColor3 = Color3.fromRGB(18, 22, 38) }):Play()
            TweenService:Create(rowStroke,TweenInfo.new(0.14), { Color = CYAN }):Play()
            TweenService:Create(arrow,    TweenInfo.new(0.14), { TextColor3 = CYAN }):Play()
        end)
        row.MouseLeave:Connect(function()
            TweenService:Create(row,      TweenInfo.new(0.14), { BackgroundColor3 = BG_ROW }):Play()
            TweenService:Create(rowStroke,TweenInfo.new(0.14), { Color = DARK }):Play()
            TweenService:Create(arrow,    TweenInfo.new(0.14), { TextColor3 = CYAN_DIM }):Play()
        end)

        local clicked = false
        row.MouseButton1Click:Connect(function()
            if clicked or closing then return end
            clicked = true
            TweenService:Create(row,      TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(0, 35, 50) }):Play()
            TweenService:Create(rowStroke,TweenInfo.new(0.1), { Color = CYAN }):Play()
            pendingFile = mod.file
            task.wait(0.12)
            closeHub()
        end)

    elseif isDev then
        local devBadge = Instance.new("TextLabel")
        devBadge.Text                  = "DEV"
        devBadge.Font                  = Enum.Font.GothamBold
        devBadge.TextSize               = 9
        devBadge.TextColor3             = BG
        devBadge.BackgroundColor3       = CYAN_DIM
        devBadge.Size                  = UDim2.new(0, 36, 0, 18)
        devBadge.Position              = UDim2.new(1, -48, 0.5, -9)
        devBadge.TextXAlignment        = Enum.TextXAlignment.Center
        devBadge.TextYAlignment        = Enum.TextYAlignment.Center
        devBadge.ZIndex                = 13
        devBadge.Parent                = row
        Instance.new("UICorner", devBadge).CornerRadius = UDim.new(0, 5)

    else
        local lockLabel = Instance.new("TextLabel")
        lockLabel.Text                  = "🔧"
        lockLabel.TextSize               = 15
        lockLabel.Font                  = Enum.Font.GothamBold
        lockLabel.BackgroundTransparency = 1
        lockLabel.Size                  = UDim2.new(0, 28, 1, 0)
        lockLabel.Position              = UDim2.new(1, -38, 0, 0)
        lockLabel.TextXAlignment        = Enum.TextXAlignment.Center
        lockLabel.TextYAlignment        = Enum.TextYAlignment.Center
        lockLabel.ZIndex                = 13
        lockLabel.Parent                = row
    end
end

-- ─────────────────────────────────────────
--  ANIMACIÓN ENTRADA
-- ─────────────────────────────────────────
task.wait(0.05)
TweenService:Create(card,
    TweenInfo.new(0.44, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Position = UDim2.new(0.5, -CARD_W / 2, 0.5, -CARD_H / 2) }
):Play()
