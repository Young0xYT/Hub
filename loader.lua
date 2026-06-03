-- Young0x Hub — Loader (UI compacta para PC + Cel)

local RAW = "https://raw.githubusercontent.com/Young0xYT/Hub/main/modules/"

local MODULES = {
    { name = "Fast Glitch 90%",  file = "fg90.lua",        desc = "Simple Fast Glitch", status = "ready" },
    { name = "Fast Glitch 100%", file = "fg100.lua",       desc = "En desarrollo",      status = "soon"  },
    { name = "Fast Farm",        file = "fastfarm.lua",    desc = "En desarrollo",      status = "soon"  },
    { name = "Auto Rebirth",     file = "autorebirth.lua", desc = "En desarrollo",      status = "soon"  },
    { name = "Auto Kill",        file = "autokill.lua",    desc = "En desarrollo",      status = "soon"  },
    { name = "Anti Lag",         file = "antilag.lua",     desc = "En desarrollo",      status = "soon"  },
    { name = "Anti AFK",         file = "antiafk.lua",     desc = "En desarrollo",      status = "soon"  },
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("HubGui")
if old then
    old:Destroy()
end

-- Más chico para que entre en cel y se vea completo
local CARD_W = 620          -- antes 760
local CARD_H = 380          -- antes 470
local HEADER_H = 72
local LIST_TOP = HEADER_H + 6
local LIST_BOTTOM_PADDING = 8
local ROW_H = 64
local ROW_GAP = 6

local gui = Instance.new("ScreenGui")
gui.Name = "HubGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local pendingFile = nil
local closing = false

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

local card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(0, CARD_W, 0, CARD_H)
card.Position = UDim2.new(0.5, -CARD_W / 2, 0.5, -CARD_H / 2)
card.BackgroundColor3 = Color3.fromRGB(7, 11, 19)
card.BackgroundTransparency = 0.1
card.BorderSizePixel = 0
card.Active = true
card.Draggable = false
card.ZIndex = 10
card.Parent = gui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 16)
cardCorner.Parent = card

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = Color3.fromRGB(0, 180, 255)
cardStroke.Thickness = 1
cardStroke.Transparency = 0.05
cardStroke.Parent = card

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundColor3 = Color3.fromRGB(9, 14, 24)
header.BackgroundTransparency = 0.08
header.BorderSizePixel = 0
header.ZIndex = 11
header.Parent = card

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

local headerPatch = Instance.new("Frame")
headerPatch.Size = UDim2.new(1, 0, 0, 16)
headerPatch.Position = UDim2.new(0, 0, 1, -16)
headerPatch.BackgroundColor3 = header.BackgroundColor3
headerPatch.BackgroundTransparency = header.BackgroundTransparency
headerPatch.BorderSizePixel = 0
headerPatch.ZIndex = 11
headerPatch.Parent = header

local accent = Instance.new("Frame")
accent.Size = UDim2.new(0, 5, 0, 44)
accent.Position = UDim2.new(0, 14, 0, 16)
accent.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
accent.BorderSizePixel = 0
accent.ZIndex = 12
accent.Parent = header

local accentCorner = Instance.new("UICorner")
accentCorner.CornerRadius = UDim.new(0, 3)
accentCorner.Parent = accent

local title = Instance.new("TextLabel")
title.Text = "Young0x Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(240, 244, 255)
title.BackgroundTransparency = 1
title.Size = UDim2.new(0, 220, 0, 22)
title.Position = UDim2.new(0, 30, 0, 14)
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 12
title.Parent = header

local sub = Instance.new("TextLabel")
sub.Text = "Seleccioná un Script"
sub.Font = Enum.Font.Gotham
sub.TextSize = 12
sub.TextColor3 = Color3.fromRGB(145, 155, 185)
sub.BackgroundTransparency = 1
sub.Size = UDim2.new(0, 220, 0, 16)
sub.Position = UDim2.new(0, 30, 0, 38)
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.ZIndex = 12
sub.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(230, 240, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(24, 32, 48)
closeBtn.AutoButtonColor = false
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -38, 0, 24)
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 13
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

-- SCROLL interno, el card no se mueve
local listFrame = Instance.new("ScrollingFrame")
listFrame.Name = "List"
listFrame.Size = UDim2.new(1, -16, 1, -(LIST_TOP + LIST_BOTTOM_PADDING))
listFrame.Position = UDim2.new(0, 8, 0, LIST_TOP)
listFrame.BackgroundTransparency = 1
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 190, 255)
listFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
listFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.None
listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
listFrame.ZIndex = 11
listFrame.CanvasSize = UDim2.new(0, 0, 0, (#MODULES * ROW_H) + ((#MODULES - 1) * ROW_GAP))
listFrame.Parent = card

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, ROW_GAP)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = listFrame

local function closeHub()
    if closing then return end
    closing = true
    local tweenOut = TweenService:Create(
        card,
        TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Position = UDim2.new(0.5, -CARD_W / 2, 1.1, 0) }
    )
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        gui:Destroy()
        if pendingFile then
            runModule(pendingFile)
        end
    end)
end

closeBtn.MouseButton1Click:Connect(closeHub)

for i, mod in ipairs(MODULES) do
    local row = Instance.new("TextButton")
    row.Name = "Row_" .. i
    row.Size = UDim2.new(0.98, 0, 0, ROW_H)
    row.BackgroundColor3 = Color3.fromRGB(12, 18, 30)
    row.BackgroundTransparency = 0.08
    row.BorderSizePixel = 0
    row.Text = ""
    row.LayoutOrder = i
    row.AutoButtonColor = false
    row.ZIndex = 12
    row.Parent = listFrame

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 12)
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
    nameLabel.Size = UDim2.new(0.7, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 16, 0, 8)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = row

    local descLabel = Instance.new("TextLabel")
    descLabel.Text = moduleReady(mod) and mod.desc or "En desarrollo"
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextColor3 = Color3.fromRGB(130, 140, 170)
    descLabel.BackgroundTransparency = 1
    descLabel.Size = UDim2.new(0.7, 0, 0, 14)
    descLabel.Position = UDim2.new(0, 16, 0, 32)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 13
    descLabel.Parent = row

    local state = Instance.new("TextLabel")
    state.Font = Enum.Font.GothamBold
    state.TextSize = 11
    state.BackgroundTransparency = 0
    state.Size = UDim2.new(0, 104, 0, 22)
    state.Position = UDim2.new(1, -150, 0, 10)
    state.BorderSizePixel = 0
    state.ZIndex = 13
    state.Parent = row

    local stateCorner = Instance.new("UICorner")
    stateCorner.CornerRadius = UDim.new(0, 11)
    stateCorner.Parent = state

    if moduleReady(mod) then
        state.Text = "Activo."
        state.TextColor3 = Color3.fromRGB(255, 255, 255)
        state.BackgroundColor3 = Color3.fromRGB(10, 200, 90)
    else
        state.Text = "En desarrollo"
        state.TextColor3 = Color3.fromRGB(255, 230, 120)
        state.BackgroundColor3 = Color3.fromRGB(50, 38, 10)
    end

    local arrow = Instance.new("TextLabel")
    arrow.Text = moduleReady(mod) and "›" or "•"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 18
    arrow.TextColor3 = moduleReady(mod) and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(90, 100, 130)
    arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -32, 0, 0)
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
    end
end

TweenService:Create(
    card,
    TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Position = UDim2.new(0.5, -CARD_W / 2, 0.5, -CARD_H / 2) }
):Play()
