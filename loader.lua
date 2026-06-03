-- Young0x Hub — Loader

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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

if playerGui:FindFirstChild("HubGui") then
    playerGui.HubGui:Destroy()
end

local CARD_W = 420
local ROW_H = 76
local ROW_GAP = 8
local HEADER_H = 72
local PADDING_B = 16
local CARD_H = HEADER_H + PADDING_B + (#MODULES * ROW_H) + ((#MODULES - 1) * ROW_GAP)

local gui = Instance.new("ScreenGui")
gui.Name = "HubGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local pendingFile = nil
local closing = false
local card

local function moduleExists(mod)
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

    local tweenOut = TweenService:Create(card, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -CARD_W / 2, 1.5, 0)
    })

    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        gui:Destroy()
        if pendingFile then
            runModule(pendingFile)
        end
    end)
end

card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(0, CARD_W, 0, CARD_H)
card.Position = UDim2.new(0.5, -CARD_W / 2, 1.5, 0)
card.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
card.BorderSizePixel = 0
card.ZIndex = 10
card.Parent = gui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 16)
cardCorner.Parent = card

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = Color3.fromRGB(55, 50, 90)
cardStroke.Thickness = 1.2
cardStroke.Parent = card

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundColor3 = Color3.fromRGB(20, 19, 32)
header.BorderSizePixel = 0
header.ZIndex = 11
header.Parent = card

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

local headerPatch = Instance.new("Frame")
headerPatch.Size = UDim2.new(1, 0, 0, 16)
headerPatch.Position = UDim2.new(0, 0, 1, -16)
headerPatch.BackgroundColor3 = Color3.fromRGB(20, 19, 32)
headerPatch.BorderSizePixel = 0
headerPatch.ZIndex = 11
headerPatch.Parent = header

local accent = Instance.new("Frame")
accent.Size = UDim2.new(0, 4, 0, 32)
accent.Position = UDim2.new(0, 14, 0.5, -16)
accent.BackgroundColor3 = Color3.fromRGB(120, 90, 240)
accent.BorderSizePixel = 0
accent.ZIndex = 12
accent.Parent = header

local accentCorner = Instance.new("UICorner")
accentCorner.CornerRadius = UDim.new(0, 4)
accentCorner.Parent = accent

local hubTitle = Instance.new("TextLabel")
hubTitle.Text = "Young0x Hub"
hubTitle.Font = Enum.Font.GothamBold
hubTitle.TextSize = 20
hubTitle.TextColor3 = Color3.fromRGB(235, 230, 255)
hubTitle.BackgroundTransparency = 1
hubTitle.Size = UDim2.new(1, -80, 0, 26)
hubTitle.Position = UDim2.new(0, 26, 0, 12)
hubTitle.TextXAlignment = Enum.TextXAlignment.Left
hubTitle.ZIndex = 12
hubTitle.Parent = header

local hubSub = Instance.new("TextLabel")
hubSub.Text = "Seleccioná un Script!"
hubSub.Font = Enum.Font.Gotham
hubSub.TextSize = 12
hubSub.TextColor3 = Color3.fromRGB(95, 90, 130)
hubSub.BackgroundTransparency = 1
hubSub.Size = UDim2.new(1, -80, 0, 16)
hubSub.Position = UDim2.new(0, 26, 0, 42)
hubSub.TextXAlignment = Enum.TextXAlignment.Left
hubSub.ZIndex = 12
hubSub.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.TextColor3 = Color3.fromRGB(150, 140, 190)
closeBtn.BackgroundColor3 = Color3.fromRGB(32, 30, 48)
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0.5, -16)
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 13
closeBtn.Parent = header

closeBtn.MouseButton1Click:Connect(closeHub)

local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, -16, 1, -(HEADER_H + 10 + PADDING_B))
listFrame.Position = UDim2.new(0, 8, 0, HEADER_H + 10)
listFrame.BackgroundTransparency = 1
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 3
listFrame.ScrollBarImageColor3 = Color3.fromRGB(90, 80, 150)
listFrame.CanvasSize = UDim2.new(0, 0, 0, (#MODULES * ROW_H) + ((#MODULES - 1) * ROW_GAP))
listFrame.ZIndex = 11
listFrame.Parent = card

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, ROW_GAP)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = listFrame

for i, mod in ipairs(MODULES) do
    local row = Instance.new("TextButton")
    row.Name = "Row_" .. i
    row.Size = UDim2.new(1, 0, 0, ROW_H)
    row.BackgroundColor3 = Color3.fromRGB(22, 21, 34)
    row.BorderSizePixel = 0
    row.Text = ""
    row.LayoutOrder = i
    row.ZIndex = 12
    row.Parent = listFrame

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 10)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = Color3.fromRGB(40, 38, 65)
    rowStroke.Thickness = 1
    rowStroke.Parent = row

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = mod.name
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 15
    nameLabel.TextColor3 = moduleExists(mod) and Color3.fromRGB(225, 220, 255) or Color3.fromRGB(120, 120, 130)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, -120, 0, 22)
    nameLabel.Position = UDim2.new(0, 54, 0, 14)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = row

    local descLabel = Instance.new("TextLabel")
    descLabel.Text = moduleExists(mod) and mod.desc or "Próximamente"
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 12
    descLabel.TextColor3 = Color3.fromRGB(85, 80, 125)
    descLabel.BackgroundTransparency = 1
    descLabel.Size = UDim2.new(1, -120, 0, 16)
    descLabel.Position = UDim2.new(0, 54, 0, 42)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 13
    descLabel.Parent = row

    local arrow = Instance.new("TextLabel")
    arrow.Text = moduleExists(mod) and "›" or "•"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 22
    arrow.TextColor3 = moduleExists(mod) and Color3.fromRGB(70, 65, 110) or Color3.fromRGB(90, 90, 100)
    arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.new(0, 24, 1, 0)
    arrow.Position = UDim2.new(1, -34, 0, 0)
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.TextYAlignment = Enum.TextYAlignment.Center
    arrow.ZIndex = 13
    arrow.Parent = row

    if moduleExists(mod) then
        row.MouseButton1Click:Connect(function()
            if closing then return end
            pendingFile = mod.file
            task.wait(0.12)
            closeHub()
        end)
    else
        row.AutoButtonColor = false
    end
end

local targetPos = UDim2.new(0.5, -CARD_W / 2, 0.5, -CARD_H / 2)

task.wait(0.05)
TweenService:Create(card, TweenInfo.new(0.44, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = targetPos
}):Play()
