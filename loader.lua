-- Young0x Hub — Loader

-- Config
local RAW = "https://raw.githubusercontent.com/Young0xYT/Hub/main/modules/"

local MODULES = {
    { name = "Fast Glitch 90%",  file = "fg90.lua",        desc = "Simple Fast Glitch", status = "ready" },
    { name = "Fast Glitch 100%", file = "fg100.lua",       desc = "Fast Glitch 100%",   status = "soon"  },
    { name = "Fast Farm",        file = "fastfarm.lua",    desc = "Automatización",     status = "soon"  },
    { name = "Auto Rebirth",     file = "autorebirth.lua", desc = "Rebirth automático", status = "soon"  },
    { name = "Auto Kill",        file = "autokill.lua",    desc = "Kill automático",    status = "soon"  },
    { name = "Anti Lag",         file = "antilag.lua",     desc = "Reducción de lag",   status = "soon"  },
    { name = "Anti AFK",         file = "antiafk.lua",     desc = "Anti AFK",           status = "soon"  },
}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("HubGui") then
    playerGui.HubGui:Destroy()
end

-- Layout
local CARD_W = 820      -- más horizontal
local ROW_H = 70
local ROW_GAP = 10
local HEADER_H = 64
local PADDING_B = 14
local ROWS = math.max(#MODULES, 2)
local CARD_H = HEADER_H + PADDING_B + (ROWS * ROW_H) + math.max(ROWS - 1, 0) * ROW_GAP

local gui = Instance.new("ScreenGui")
gui.Name = "HubGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local pendingFile = nil
local closing = false
local card

-- Modules
local function moduleReady(mod)
    return mod.status == "ready"
end

local function runModule(file)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(RAW .. file, true))()
    end)
    if not ok then
        warn("[Young0x Hub] Error al ejecutar " .. file .. ": " .. tostring(err))
    end
end

local function closeHub()
    if closing then return end
    closing = true

    local tweenOut = TweenService:Create(
        card,
        TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        { Position = UDim2.new(0.5, -CARD_W / 2, 1.2, 0) }
    )
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        gui:Destroy()
        if pendingFile then
            runModule(pendingFile)
        end
    end)
end

-- Card
card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(0, CARD_W, 0, CARD_H)
card.Position = UDim2.new(0.5, -CARD_W / 2, -0.2, 0)
card.BackgroundColor3 = Color3.fromRGB(6, 10, 18)  -- negro azulado
card.BorderSizePixel = 0
card.ZIndex = 10
card.Parent = gui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 14)
cardCorner.Parent = card

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = Color3.fromRGB(0, 180, 255)     -- celeste neón
cardStroke.Thickness = 1.4
cardStroke.Parent = card

-- Glow simple
local glow = Instance.new("ImageLabel")
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5028857084" -- blur suave
glow.ImageColor3 = Color3.fromRGB(0, 190, 255)
glow.ImageTransparency = 0.7
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(24, 24, 276, 276)
glow.Size = UDim2.new(1, 20, 1, 20)
glow.Position = UDim2.new(0, -10, 0, -10)
glow.ZIndex = 9
glow.Parent = card

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(8, 14, 26)
header.BorderSizePixel = 0
header.ZIndex = 11
header.Parent = card

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

local headerPatch = Instance.new("Frame")
headerPatch.Size = UDim2.new(1, 0, 0, 14)
headerPatch.Position = UDim2.new(0, 0, 1, -14)
headerPatch.BackgroundColor3 = header.BackgroundColor3
headerPatch.BorderSizePixel = 0
headerPatch.ZIndex = 11
headerPatch.Parent = header

-- Barra celeste izquierda
local accent = Instance.new("Frame")
accent.Size = UDim2.new(0, 6, 0, HEADER_H - 24)
accent.Position = UDim2.new(0, 18, 0.5, -(HEADER_H - 24)/2)
accent.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
accent.BorderSizePixel = 0
accent.ZIndex = 12
accent.Parent = header

local accentCorner = Instance.new("UICorner")
accentCorner.CornerRadius = UDim.new(0, 3)
accentCorner.Parent = accent

-- Título
local hubTitle = Instance.new("TextLabel")
hubTitle.Text = "Young0x Hub"
hubTitle.Font = Enum.Font.GothamBold
hubTitle.TextSize = 18
hubTitle.TextColor3 = Color3.fromRGB(240, 244, 255)
hubTitle.BackgroundTransparency = 1
hubTitle.Size = UDim2.new(0.5, 0, 0, 24)
hubTitle.Position = UDim2.new(0, 40, 0, 10)
hubTitle.TextXAlignment = Enum.TextXAlignment.Left
hubTitle.ZIndex = 12
hubTitle.Parent = header

local hubSub = Instance.new("TextLabel")
hubSub.Text = "Seleccioná un Script"
hubSub.Font = Enum.Font.Gotham
hubSub.TextSize = 12
hubSub.TextColor3 = Color3.fromRGB(150, 160, 190)
hubSub.BackgroundTransparency = 1
hubSub.Size = UDim2.new(0.5, 0, 0, 18)
hubSub.Position = UDim2.new(0, 40, 0, 34)
hubSub.TextXAlignment = Enum.TextXAlignment.Left
hubSub.ZIndex = 12
hubSub.Parent = header

-- “Game” badge fake
local gameTag = Instance.new("TextLabel")
gameTag.Text = "Game"
gameTag.Font = Enum.Font.GothamBold
gameTag.TextSize = 12
gameTag.TextColor3 = Color3.fromRGB(0, 210, 255)
gameTag.BackgroundColor3 = Color3.fromRGB(12, 20, 32)
gameTag.BackgroundTransparency = 0
gameTag.Size = UDim2.new(0, 80, 0, 24)
gameTag.Position = UDim2.new(1, -150, 0, 20)
gameTag.BorderSizePixel = 0
gameTag.ZIndex = 12
gameTag.Parent = header

local gameCorner = Instance.new("UICorner")
gameCorner.CornerRadius = UDim.new(0, 12)
gameCorner.Parent = gameTag

-- Cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(230, 240, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(24, 32, 48)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -40, 0, 18)
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 13
closeBtn.Parent = header

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(1, 0)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(closeHub)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(220, 60, 80),
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(24, 32, 48),
        TextColor3 = Color3.fromRGB(230, 240, 255)
    }):Play()
end)

-- Línea separadora
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -30, 0, 1)
sep.Position = UDim2.new(0, 15, 0, HEADER_H)
sep.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
sep.BorderSizePixel = 0
sep.ZIndex = 11
sep.Parent = card

-- Lista
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, -20, 1, -(HEADER_H + 12 + PADDING_B))
listFrame.Position = UDim2.new(0, 10, 0, HEADER_H + 12)
listFrame.BackgroundTransparency = 1
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 3
listFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 190, 255)
listFrame.CanvasSize = UDim2.new(0, 0, 0, (ROWS * ROW_H) + math.max(ROWS - 1, 0) * ROW_GAP)
listFrame.ZIndex = 11
listFrame.Parent = card

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, ROW_GAP)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = listFrame

-- Filas
for i, mod in ipairs(MODULES) do
    local row = Instance.new("TextButton")
    row.Name = "Row_" .. i
    row.Size = UDim2.new(0.96, 0, 0, ROW_H)
    row.BackgroundColor3 = Color3.fromRGB(12, 18, 30)
    row.BorderSizePixel = 0
    row.Text = ""
    row.LayoutOrder = i
    row.ZIndex = 12
    row.Parent = listFrame

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 10)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = Color3.fromRGB(22, 32, 52)
    rowStroke.Thickness = 1
    rowStroke.Parent = row

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = mod.name
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 15
    nameLabel.TextColor3 = moduleReady(mod) and Color3.fromRGB(235, 245, 255) or Color3.fromRGB(150, 150, 170)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(0.7, 0, 0, 22)
    nameLabel.Position = UDim2.new(0, 20, 0, 10)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = row

    local descLabel = Instance.new("TextLabel")
    descLabel.Text = moduleReady(mod) and mod.desc or "Próximamente"
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 12
    descLabel.TextColor3 = Color3.fromRGB(130, 140, 170)
    descLabel.BackgroundTransparency = 1
    descLabel.Size = UDim2.new(0.7, 0, 0, 16)
    descLabel.Position = UDim2.new(0, 20, 0, 38)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 13
    descLabel.Parent = row

    -- Badge estado
    local state = Instance.new("TextLabel")
    state.Font = Enum.Font.GothamBold
    state.TextSize = 11
    state.BackgroundTransparency = 0
    state.Size = UDim2.new(0, 80, 0, 22)
    state.Position = UDim2.new(1, -120, 0, 12)
    state.BorderSizePixel = 0
    state.ZIndex = 13
    state.Parent = row

    local stateCorner = Instance.new("UICorner")
    stateCorner.CornerRadius = UDim.new(0, 11)
    stateCorner.Parent = state

    if moduleReady(mod) then
        state.Text = "Listo"
        state.TextColor3 = Color3.fromRGB(0, 240, 130)
        state.BackgroundColor3 = Color3.fromRGB(10, 40, 24)
    else
        state.Text = "Soon"
        state.TextColor3 = Color3.fromRGB(255, 220, 60)
        state.BackgroundColor3 = Color3.fromRGB(40, 32, 10)
    end

    local arrow = Instance.new("TextLabel")
    arrow.Text = moduleReady(mod) ? "›" : "•"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 20
    arrow.TextColor3 = moduleReady(mod) and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(90, 100, 130)
    arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.new(0, 24, 1, 0)
    arrow.Position = UDim2.new(1, -40, 0, 0)
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.TextYAlignment = Enum.TextYAlignment.Center
    arrow.ZIndex = 13
    arrow.Parent = row

    if moduleReady(mod) then
        local clicked = false

        row.MouseButton1Click:Connect(function()
            if clicked or closing then return end
            clicked = true

            TweenService:Create(row, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(20, 30, 52),
            }):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.1), {
                Color = Color3.fromRGB(0, 200, 255),
            }):Play()

            pendingFile = mod.file
            task.wait(0.12)
            closeHub()
        end)

        row.MouseEnter:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.14), {
                BackgroundColor3 = Color3.fromRGB(18, 26, 44),
            }):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.14), {
                Color = Color3.fromRGB(0, 170, 255),
            }):Play()
        end)

        row.MouseLeave:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.14), {
                BackgroundColor3 = Color3.fromRGB(12, 18, 30),
            }):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.14), {
                Color = Color3.fromRGB(22, 32, 52),
            }):Play()
        end)
    else
        row.AutoButtonColor = false
    end
end

-- Animación
local targetPos = UDim2.new(0.5, -CARD_W / 2, 0.15, 0)

TweenService:Create(
    card,
    TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Position = targetPos }
):Play()
