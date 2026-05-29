-- ============================================================
--   HUB LOADER v2.0
--   Young0xYT — github.com/Young0xYT/Hub
-- ============================================================

-- ─────────────────────────────────────────
--  BASE RAW DE TU REPO
-- ─────────────────────────────────────────
local RAW = "https://raw.githubusercontent.com/Young0xYT/Hub/main/modules/"

-- ─────────────────────────────────────────
--  ╔══════════════════════════════════════╗
--  ║      ZONA EDITABLE — MÓDULOS         ║
--  ╚══════════════════════════════════════╝
--
--  Para agregar un módulo:
--  1. Subi el .lua a /modules/ en GitHub
--  2. Copia un bloque y pegalo acá abajo
--  3. Cambiá name, file y desc
--
-- ─────────────────────────────────────────
local MODULES = {
    {
        name = "FG90",
        file = "fg90.lua",
        desc = "Fast Glitch 90%"
    },
    -- {
    --     name = "FG100",
    --     file = "fg100.lua",
    --     desc = "Fast Glitch 100%"
    -- },
    -- {
    --     name = "Fast Farm",
    --     file = "fastfarm.lua",
    --     desc = "Automatización de farming"
    -- },
    -- {
    --     name = "Auto Rebirth",
    --     file = "autorebirth.lua",
    --     desc = "Sistema de rebirth automático"
    -- },
}
-- ─────────────────────────────────────────
--  FIN ZONA EDITABLE
-- ─────────────────────────────────────────


-- ════════════════════════════════════════════
--   NO TOCAR NADA DE ACÁ EN ADELANTE
-- ════════════════════════════════════════════

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local player       = Players.LocalPlayer
local playerGui    = player:WaitForChild("PlayerGui")

-- Limpia instancias anteriores
if playerGui:FindFirstChild("HubGui") then
    playerGui.HubGui:Destroy()
end

-- ─────────────────────────────────────────
--  FUNCIÓN: cargar módulo desde GitHub
-- ─────────────────────────────────────────
local function loadModule(file, onDone)
    task.spawn(function()
        local ok, result = pcall(function()
            return loadstring(game:HttpGet(RAW .. file, true))()
        end)
        if onDone then onDone(ok, result) end
        if not ok then
            warn("[HUB] Error cargando " .. file .. ": " .. tostring(result))
        end
    end)
end

-- ─────────────────────────────────────────
--  FUNCIÓN: cerrar hub con animación
-- ─────────────────────────────────────────
local gui  -- declarada acá para que closeHub pueda usarla
local card
local CARD_W = 320
local CARD_H = 70 + (#MODULES * 72) + 16

local function closeHub()
    local tween = TweenService:Create(card,
        TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {
            Position = UDim2.new(0.5, -CARD_W / 2, 1.5, 0),
            BackgroundTransparency = 1
        }
    )
    tween:Play()
    tween.Completed:Connect(function()
        if gui then gui:Destroy() end
    end)
end

-- ─────────────────────────────────────────
--  CONSTRUCCIÓN DEL GUI
-- ─────────────────────────────────────────

-- ScreenGui
gui = Instance.new("ScreenGui")
gui.Name           = "HubGui"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = playerGui

-- Fondo negro total
local backdrop = Instance.new("Frame")
backdrop.Name                  = "Backdrop"
backdrop.Size                  = UDim2.new(1, 0, 1, 0)
backdrop.BackgroundColor3      = Color3.fromRGB(0, 0, 0)
backdrop.BackgroundTransparency = 0  -- NEGRO TOTAL
backdrop.BorderSizePixel       = 0
backdrop.Parent                = gui

-- Click en backdrop cierra el hub
local backdropBtn = Instance.new("TextButton")
backdropBtn.Size                  = UDim2.new(1, 0, 1, 0)
backdropBtn.BackgroundTransparency = 1
backdropBtn.Text                  = ""
backdropBtn.ZIndex                = 1
backdropBtn.Parent                = backdrop
backdropBtn.MouseButton1Click:Connect(closeHub)

-- Card principal
card = Instance.new("Frame")
card.Name             = "Card"
card.Size             = UDim2.new(0, CARD_W, 0, CARD_H)
card.Position         = UDim2.new(0.5, -CARD_W / 2, 1.5, 0) -- empieza fuera de pantalla
card.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
card.BorderSizePixel  = 0
card.ZIndex           = 2
card.Parent           = gui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 14)
cardCorner.Parent = card

local cardStroke = Instance.new("UIStroke")
cardStroke.Color     = Color3.fromRGB(50, 50, 70)
cardStroke.Thickness = 1
cardStroke.Parent    = card

-- Header
local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0, 54)
header.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
header.BorderSizePixel  = 0
header.ZIndex           = 3
header.Parent           = card

local headerCornerTop = Instance.new("UICorner")
headerCornerTop.CornerRadius = UDim.new(0, 14)
headerCornerTop.Parent = header

-- Parche para esquinas inferiores del header (cuadradas)
local headerPatch = Instance.new("Frame")
headerPatch.Size             = UDim2.new(1, 0, 0, 14)
headerPatch.Position         = UDim2.new(0, 0, 1, -14)
headerPatch.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
headerPatch.BorderSizePixel  = 0
headerPatch.ZIndex           = 3
headerPatch.Parent           = header

-- Punto de color decorativo en el header
local dot = Instance.new("Frame")
dot.Size             = UDim2.new(0, 8, 0, 8)
dot.Position         = UDim2.new(0, 14, 0.5, -4)
dot.BackgroundColor3 = Color3.fromRGB(110, 90, 220)
dot.BorderSizePixel  = 0
dot.ZIndex           = 4
dot.Parent           = header

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dot

-- Título del hub
local titleLabel = Instance.new("TextLabel")
titleLabel.Text              = "HUB"
titleLabel.Font              = Enum.Font.GothamBold
titleLabel.TextSize          = 16
titleLabel.TextColor3        = Color3.fromRGB(230, 225, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Size              = UDim2.new(1, -80, 1, 0)
titleLabel.Position          = UDim2.new(0, 30, 0, 0)
titleLabel.TextXAlignment    = Enum.TextXAlignment.Left
titleLabel.ZIndex            = 4
titleLabel.Parent            = header

-- Subtítulo de estado
local statusLabel = Instance.new("TextLabel")
statusLabel.Name             = "Status"
statusLabel.Text             = "Seleccioná un script"
statusLabel.Font             = Enum.Font.Gotham
statusLabel.TextSize         = 11
statusLabel.TextColor3       = Color3.fromRGB(100, 100, 140)
statusLabel.BackgroundTransparency = 1
statusLabel.Size             = UDim2.new(1, -80, 0, 13)
statusLabel.Position         = UDim2.new(0, 30, 0, 32)
statusLabel.TextXAlignment   = Enum.TextXAlignment.Left
statusLabel.ZIndex           = 4
statusLabel.Parent           = card

-- Botón cerrar (X — texto real, no unicode raro)
local closeBtn = Instance.new("TextButton")
closeBtn.Text             = "X"
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 13
closeBtn.TextColor3       = Color3.fromRGB(160, 150, 190)
closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
closeBtn.Size             = UDim2.new(0, 28, 0, 28)
closeBtn.Position         = UDim2.new(1, -38, 0, 13)
closeBtn.BorderSizePixel  = 0
closeBtn.ZIndex           = 5
closeBtn.Parent           = card

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 7)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(closeHub)

-- Hover en X
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(180, 50, 60),
        TextColor3       = Color3.fromRGB(255, 255, 255)
    }):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(35, 35, 50),
        TextColor3       = Color3.fromRGB(160, 150, 190)
    }):Play()
end)

-- Línea separadora bajo el header
local separator = Instance.new("Frame")
separator.Size             = UDim2.new(1, -28, 0, 1)
separator.Position         = UDim2.new(0, 14, 0, 54)
separator.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
separator.BorderSizePixel  = 0
separator.ZIndex           = 3
separator.Parent           = card

-- Contenedor de botones (scroll si hay muchos módulos)
local scroll = Instance.new("ScrollingFrame")
scroll.Size                   = UDim2.new(1, -16, 1, -70)
scroll.Position               = UDim2.new(0, 8, 0, 62)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel        = 0
scroll.ScrollBarThickness     = 2
scroll.ScrollBarImageColor3   = Color3.fromRGB(70, 70, 110)
scroll.CanvasSize             = UDim2.new(0, 0, 0, #MODULES * 72)
scroll.ZIndex                 = 3
scroll.Parent                 = card

local listLayout = Instance.new("UIListLayout")
listLayout.Padding    = UDim.new(0, 6)
listLayout.SortOrder  = Enum.SortOrder.LayoutOrder
listLayout.Parent     = scroll

-- ─────────────────────────────────────────
--  GENERAR BOTONES DINÁMICAMENTE
-- ─────────────────────────────────────────
for i, mod in ipairs(MODULES) do
    local btn = Instance.new("TextButton")
    btn.Name             = "Mod_" .. i
    btn.Size             = UDim2.new(1, 0, 0, 64)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    btn.BorderSizePixel  = 0
    btn.Text             = ""
    btn.LayoutOrder      = i
    btn.ZIndex           = 4
    btn.Parent           = scroll

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color     = Color3.fromRGB(38, 38, 58)
    btnStroke.Thickness = 1
    btnStroke.Parent    = btn

    -- Nombre del módulo
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text             = mod.name
    nameLabel.Font             = Enum.Font.GothamBold
    nameLabel.TextSize         = 14
    nameLabel.TextColor3       = Color3.fromRGB(220, 215, 255)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size             = UDim2.new(1, -50, 0, 20)
    nameLabel.Position         = UDim2.new(0, 14, 0, 12)
    nameLabel.TextXAlignment   = Enum.TextXAlignment.Left
    nameLabel.ZIndex           = 5
    nameLabel.Parent           = btn

    -- Descripción
    local descLabel = Instance.new("TextLabel")
    descLabel.Text             = mod.desc
    descLabel.Font             = Enum.Font.Gotham
    descLabel.TextSize         = 11
    descLabel.TextColor3       = Color3.fromRGB(90, 90, 130)
    descLabel.BackgroundTransparency = 1
    descLabel.Size             = UDim2.new(1, -50, 0, 15)
    descLabel.Position         = UDim2.new(0, 14, 0, 36)
    descLabel.TextXAlignment   = Enum.TextXAlignment.Left
    descLabel.ZIndex           = 5
    descLabel.Parent           = btn

    -- Indicador de estado (círculo derecha)
    local indicator = Instance.new("Frame")
    indicator.Size             = UDim2.new(0, 9, 0, 9)
    indicator.Position         = UDim2.new(1, -20, 0.5, -4)
    indicator.BackgroundColor3 = Color3.fromRGB(55, 55, 80)
    indicator.BorderSizePixel  = 0
    indicator.ZIndex           = 5
    indicator.Parent           = btn

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator

    -- Hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.13), {
            BackgroundColor3 = Color3.fromRGB(28, 28, 46)
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.13), {
            Color = Color3.fromRGB(80, 70, 160)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.13), {
            BackgroundColor3 = Color3.fromRGB(20, 20, 32)
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.13), {
            Color = Color3.fromRGB(38, 38, 58)
        }):Play()
    end)

    -- ── CLICK: cargar y cerrar ──
    local loaded = false
    btn.MouseButton1Click:Connect(function()
        if loaded then return end
        loaded = true
        btn.Active = false

        -- Feedback visual de carga
        statusLabel.Text      = "Cargando " .. mod.name .. "..."
        statusLabel.TextColor3 = Color3.fromRGB(200, 170, 60)
        TweenService:Create(indicator, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(200, 160, 40)
        }):Play()

        -- Carga el módulo y CIERRA el hub
        loadModule(mod.file, function(ok, _)
            if ok then
                TweenService:Create(indicator, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(60, 210, 110)
                }):Play()
            end
            -- Pequeña pausa para ver el feedback, luego cierra
            task.wait(0.3)
            closeHub()
        end)
    end)
end

-- ─────────────────────────────────────────
--  ANIMACIÓN DE ENTRADA
-- ─────────────────────────────────────────
local targetPos = UDim2.new(0.5, -CARD_W / 2, 0.5, -CARD_H / 2)

task.wait(0.05) -- Frame de gracia para que el GUI inicialice
TweenService:Create(card,
    TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Position = targetPos }
):Play()
