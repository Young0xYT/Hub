-- ============================================================
--   HUB LOADER
--   Young0xYT — github.com/Young0xYT/Hub
-- ============================================================

-- ─────────────────────────────────────────
--  BASE RAW DE TU REPO (no tocar)
-- ─────────────────────────────────────────
local RAW = "https://raw.githubusercontent.com/Young0xYT/Hub/main/modules/"

-- ─────────────────────────────────────────
--  ╔══════════════════════════════════════╗
--  ║         AGREGAR MÓDULOS AQUÍ         ║
--  ╚══════════════════════════════════════╝
--
--  Para agregar una opción nueva al Hub:
--
--  1. Subí el archivo .lua a /modules/ en GitHub
--  2. Copiá el bloque de abajo y pegalo al final de la lista
--  3. Cambiá los valores
--
--  Campos:
--    name    → texto que aparece en el botón del Hub
--    file    → nombre exacto del archivo en /modules/
--    desc    → descripción corta debajo del botón
--
-- ─────────────────────────────────────────
local MODULES = {
    {
        name = "FG90",
        file = "fg90.lua",
        desc = "Script principal FG90"
    },
    -- EJEMPLO: descomentá esto para agregar FG100
    -- {
    --     name = "FG100",
    --     file = "fg100.lua",
    --     desc = "Script principal FG100"
    -- },
    --
    -- EJEMPLO: Fast Farm
    -- {
    --     name = "Fast Farm",
    --     file = "fastfarm.lua",
    --     desc = "Automatización de farming"
    -- },
}
-- ─────────────────────────────────────────
--  FIN DE LA ZONA EDITABLE
-- ─────────────────────────────────────────


-- ════════════════════════════════════════════
--   A PARTIR DE ACÁ NO SE TOCA NADA
-- ════════════════════════════════════════════

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player       = Players.LocalPlayer
local playerGui    = player:WaitForChild("PlayerGui")

-- Limpia instancias anteriores del Hub
if playerGui:FindFirstChild("HubGui") then
    playerGui.HubGui:Destroy()
end

-- ─────────────────────────────────────────
--  FUNCIÓN: cargar módulo desde GitHub
-- ─────────────────────────────────────────
local function loadModule(file)
    local url = RAW .. file
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    if not ok then
        warn("[HUB] Error cargando " .. file .. ": " .. tostring(result))
        return false
    end
    return true
end

-- ─────────────────────────────────────────
--  CONSTRUCCIÓN DEL GUI
-- ─────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name            = "HubGui"
gui.ResetOnSpawn    = false
gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
gui.Parent          = playerGui

-- Fondo semitransparente
local backdrop = Instance.new("Frame")
backdrop.Name          = "Backdrop"
backdrop.Size          = UDim2.new(1, 0, 1, 0)
backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backdrop.BackgroundTransparency = 0.4
backdrop.BorderSizePixel = 0
backdrop.Parent        = gui

-- Ventana principal
local CARD_W, CARD_H = 340, 80 + (#MODULES * 74) + 20
CARD_H = math.clamp(CARD_H, 180, 600)

local card = Instance.new("Frame")
card.Name              = "Card"
card.Size              = UDim2.new(0, CARD_W, 0, CARD_H)
card.Position          = UDim2.new(0.5, -CARD_W/2, 0.5, -CARD_H/2)
card.BackgroundColor3  = Color3.fromRGB(15, 15, 20)
card.BorderSizePixel   = 0
card.Parent            = gui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 12)
cardCorner.Parent = card

-- Borde sutil
local stroke = Instance.new("UIStroke")
stroke.Color          = Color3.fromRGB(60, 60, 80)
stroke.Thickness      = 1
stroke.Parent         = card

-- Header
local header = Instance.new("Frame")
header.Name            = "Header"
header.Size            = UDim2.new(1, 0, 0, 52)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
header.BorderSizePixel = 0
header.Parent          = card

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

-- Patch para que solo redondee arriba
local headerPatch = Instance.new("Frame")
headerPatch.Size              = UDim2.new(1, 0, 0, 12)
headerPatch.Position          = UDim2.new(0, 0, 1, -12)
headerPatch.BackgroundColor3  = Color3.fromRGB(20, 20, 30)
headerPatch.BorderSizePixel   = 0
headerPatch.Parent            = header

-- Título
local title = Instance.new("TextLabel")
title.Text              = "⬡  HUB"
title.Font              = Enum.Font.GothamBold
title.TextSize          = 18
title.TextColor3        = Color3.fromRGB(220, 220, 255)
title.BackgroundTransparency = 1
title.Size              = UDim2.new(1, -50, 1, 0)
title.Position          = UDim2.new(0, 16, 0, 0)
title.TextXAlignment    = Enum.TextXAlignment.Left
title.Parent            = header

-- Subtítulo / estado
local subtitle = Instance.new("TextLabel")
subtitle.Name           = "Subtitle"
subtitle.Text           = "Seleccioná un script"
subtitle.Font           = Enum.Font.Gotham
subtitle.TextSize       = 11
subtitle.TextColor3     = Color3.fromRGB(120, 120, 160)
subtitle.BackgroundTransparency = 1
subtitle.Size           = UDim2.new(1, -50, 0, 14)
subtitle.Position       = UDim2.new(0, 16, 0, 32)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent         = card

-- Botón cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Text           = "✕"
closeBtn.Font           = Enum.Font.GothamBold
closeBtn.TextSize       = 14
closeBtn.TextColor3     = Color3.fromRGB(150, 150, 180)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
closeBtn.Size           = UDim2.new(0, 28, 0, 28)
closeBtn.Position       = UDim2.new(1, -38, 0, 12)
closeBtn.BorderSizePixel = 0
closeBtn.Parent         = card

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(card,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Position = UDim2.new(0.5, -CARD_W/2, 1.2, 0), BackgroundTransparency = 1 }
    )
    tween:Play()
    tween.Completed:Connect(function() gui:Destroy() end)
end)

-- Área scrolleable de botones
local scroll = Instance.new("ScrollingFrame")
scroll.Name                    = "Scroll"
scroll.Size                    = UDim2.new(1, -24, 1, -80)
scroll.Position                = UDim2.new(0, 12, 0, 68)
scroll.BackgroundTransparency  = 1
scroll.BorderSizePixel         = 0
scroll.ScrollBarThickness      = 3
scroll.ScrollBarImageColor3    = Color3.fromRGB(80, 80, 120)
scroll.CanvasSize              = UDim2.new(0, 0, 0, #MODULES * 74)
scroll.Parent                  = card

local listLayout = Instance.new("UIListLayout")
listLayout.Padding       = UDim.new(0, 8)
listLayout.SortOrder     = Enum.SortOrder.LayoutOrder
listLayout.Parent        = scroll

-- ─────────────────────────────────────────
--  GENERAR BOTONES DESDE MODULES
-- ─────────────────────────────────────────
for i, mod in ipairs(MODULES) do
    local btn = Instance.new("TextButton")
    btn.Name              = "Btn_" .. mod.name
    btn.Size              = UDim2.new(1, 0, 0, 62)
    btn.BackgroundColor3  = Color3.fromRGB(25, 25, 38)
    btn.BorderSizePixel   = 0
    btn.Text              = ""
    btn.LayoutOrder       = i
    btn.Parent            = scroll

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color     = Color3.fromRGB(45, 45, 65)
    btnStroke.Thickness = 1
    btnStroke.Parent    = btn

    -- Nombre del módulo
    local modName = Instance.new("TextLabel")
    modName.Text          = mod.name
    modName.Font          = Enum.Font.GothamBold
    modName.TextSize      = 14
    modName.TextColor3    = Color3.fromRGB(210, 210, 255)
    modName.BackgroundTransparency = 1
    modName.Size          = UDim2.new(1, -16, 0, 22)
    modName.Position      = UDim2.new(0, 12, 0, 10)
    modName.TextXAlignment = Enum.TextXAlignment.Left
    modName.Parent        = btn

    -- Descripción
    local modDesc = Instance.new("TextLabel")
    modDesc.Text          = mod.desc
    modDesc.Font          = Enum.Font.Gotham
    modDesc.TextSize      = 11
    modDesc.TextColor3    = Color3.fromRGB(100, 100, 140)
    modDesc.BackgroundTransparency = 1
    modDesc.Size          = UDim2.new(1, -16, 0, 16)
    modDesc.Position      = UDim2.new(0, 12, 0, 34)
    modDesc.TextXAlignment = Enum.TextXAlignment.Left
    modDesc.Parent        = btn

    -- Indicador de estado (punto de color)
    local dot = Instance.new("Frame")
    dot.Name             = "Dot"
    dot.Size             = UDim2.new(0, 8, 0, 8)
    dot.Position         = UDim2.new(1, -18, 0.5, -4)
    dot.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    dot.BorderSizePixel  = 0
    dot.Parent           = btn

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    -- Hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 38)
        }):Play()
    end)

    -- Click: cargar módulo
    btn.MouseButton1Click:Connect(function()
        -- Evita doble click mientras carga
        btn.Active = false

        subtitle.Text      = "Cargando " .. mod.name .. "..."
        subtitle.TextColor3 = Color3.fromRGB(180, 180, 80)

        TweenService:Create(dot, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(200, 160, 40)
        }):Play()

        task.spawn(function()
            local success = loadModule(mod.file)

            if success then
                subtitle.Text       = mod.name .. " cargado ✓"
                subtitle.TextColor3 = Color3.fromRGB(80, 200, 120)
                TweenService:Create(dot, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(60, 200, 100)
                }):Play()
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(20, 45, 30)
                }):Play()
                btnStroke.Color = Color3.fromRGB(40, 120, 60)
            else
                subtitle.Text       = "Error al cargar " .. mod.name
                subtitle.TextColor3 = Color3.fromRGB(220, 80, 80)
                TweenService:Create(dot, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(220, 60, 60)
                }):Play()
                btn.Active = true  -- Permite reintentar si falló
            end
        end)
    end)
end

-- Animación de entrada
card.Position = UDim2.new(0.5, -CARD_W/2, 1.2, 0)
TweenService:Create(card,
    TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Position = UDim2.new(0.5, -CARD_W/2, 0.5, -CARD_H/2) }
):Play()
