local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local VirtualUser      = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService       = game:GetService("RunService")

local player           = Players.LocalPlayer
local playerGui        = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("FG100Gui") then
    playerGui.FG100Gui:Destroy()
end

-- ── Stats refs (espera a que existan) ──────────────────────────────────────
local leaderstats  = player:WaitForChild("leaderstats", 15)
local statStrength = leaderstats and leaderstats:WaitForChild("Strength",  15)
local statRebirths = leaderstats and leaderstats:WaitForChild("Rebirths",  15)
local statDurability = player:WaitForChild("Durability", 15)

local sessionStart       = tick()
local startStrength      = statStrength  and statStrength.Value  or 0
local startDurability    = statDurability and statDurability.Value or 0
local startRebirths      = statRebirths  and statRebirths.Value  or 0

-- ── Número abreviado ───────────────────────────────────────────────────────
local function fmt(n)
    local suffixes = { "K", "M", "B", "T", "Qa" }
    for i = #suffixes, 1, -1 do
        local threshold = 10 ^ (i * 3)
        if math.abs(n) >= threshold then
            return string.format("%.2f%s", n / threshold, suffixes[i])
        end
    end
    return string.format("%.2f", n)
end

-- ── GUI ───────────────────────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name           = "FG100Gui"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent         = playerGui

local WIN_W, WIN_H = 420, 480
local TAB_H        = 36

local main = Instance.new("Frame")
main.Name             = "Main"
main.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
main.Position         = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2)
main.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
main.BorderSizePixel  = 0
main.Active           = true
main.Draggable        = true
main.ZIndex           = 10
main.Parent           = gui

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 14)
    c.Parent = main
    local s = Instance.new("UIStroke")
    s.Color     = Color3.fromRGB(55, 50, 90)
    s.Thickness = 1.2
    s.Parent    = main
end

-- Header
local hdr = Instance.new("Frame")
hdr.Size             = UDim2.new(1, 0, 0, 52)
hdr.BackgroundColor3 = Color3.fromRGB(20, 19, 32)
hdr.BorderSizePixel  = 0
hdr.ZIndex           = 11
hdr.Parent           = main
do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 14)
    c.Parent = hdr
    local pad = Instance.new("Frame")
    pad.Size             = UDim2.new(1, 0, 0, 14)
    pad.Position         = UDim2.new(0, 0, 1, -14)
    pad.BackgroundColor3 = Color3.fromRGB(20, 19, 32)
    pad.BorderSizePixel  = 0
    pad.ZIndex           = 11
    pad.Parent           = hdr
end

local accent = Instance.new("Frame")
accent.Size             = UDim2.new(0, 4, 0, 28)
accent.Position         = UDim2.new(0, 14, 0.5, -14)
accent.BackgroundColor3 = Color3.fromRGB(120, 90, 240)
accent.BorderSizePixel  = 0
accent.ZIndex           = 12
accent.Parent           = hdr
do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = accent end

local titleLabel = Instance.new("TextLabel")
titleLabel.Text                 = "FG100 — Paid"
titleLabel.Font                 = Enum.Font.GothamBold
titleLabel.TextSize             = 18
titleLabel.TextColor3           = Color3.fromRGB(235, 230, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Size                 = UDim2.new(1, -90, 0, 24)
titleLabel.Position             = UDim2.new(0, 26, 0.5, -12)
titleLabel.TextXAlignment       = Enum.TextXAlignment.Left
titleLabel.ZIndex               = 12
titleLabel.Parent               = hdr

local closeBtn = Instance.new("TextButton")
closeBtn.Text             = "X"
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 12
closeBtn.TextColor3       = Color3.fromRGB(150, 140, 190)
closeBtn.BackgroundColor3 = Color3.fromRGB(32, 30, 48)
closeBtn.Size             = UDim2.new(0, 28, 0, 28)
closeBtn.Position         = UDim2.new(1, -38, 0.5, -14)
closeBtn.BorderSizePixel  = 0
closeBtn.ZIndex           = 13
closeBtn.Parent           = hdr
do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 7) c.Parent = closeBtn end

closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(170, 40, 55),
        TextColor3       = Color3.fromRGB(255, 255, 255)
    }):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(32, 30, 48),
        TextColor3       = Color3.fromRGB(150, 140, 190)
    }):Play()
end)

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Size             = UDim2.new(1, -28, 0, TAB_H)
tabBar.Position         = UDim2.new(0, 14, 0, 58)
tabBar.BackgroundColor3 = Color3.fromRGB(18, 17, 28)
tabBar.BorderSizePixel  = 0
tabBar.ZIndex           = 11
tabBar.Parent           = main
do
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = tabBar
    local l = Instance.new("UIListLayout")
    l.FillDirection = Enum.FillDirection.Horizontal
    l.SortOrder     = Enum.SortOrder.LayoutOrder
    l.Parent        = tabBar
end

-- Content area
local contentArea = Instance.new("Frame")
contentArea.Size             = UDim2.new(1, -28, 1, -(58 + TAB_H + 20))
contentArea.Position         = UDim2.new(0, 14, 0, 58 + TAB_H + 10)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel  = 0
contentArea.ZIndex           = 11
contentArea.ClipsDescendants = true
contentArea.Parent           = main

-- ── Tab system ────────────────────────────────────────────────────────────
local tabPages   = {}
local tabButtons = {}
local activeTab  = nil

local function switchTab(name)
    if activeTab == name then return end
    activeTab = name
    for n, page in pairs(tabPages) do
        page.Visible = (n == name)
    end
    for n, btn in pairs(tabButtons) do
        if n == name then
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3 = Color3.fromRGB(120, 90, 240),
                TextColor3       = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3 = Color3.fromRGB(18, 17, 28),
                TextColor3       = Color3.fromRGB(110, 105, 160)
            }):Play()
        end
    end
end

local function addTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0.5, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(18, 17, 28)
    btn.BorderSizePixel  = 0
    btn.Text             = name
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 13
    btn.TextColor3       = Color3.fromRGB(110, 105, 160)
    btn.LayoutOrder      = order
    btn.ZIndex           = 12
    btn.Parent           = tabBar
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = btn end

    local page = Instance.new("ScrollingFrame")
    page.Size                   = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel        = 0
    page.ScrollBarThickness     = 3
    page.ScrollBarImageColor3   = Color3.fromRGB(90, 80, 150)
    page.CanvasSize             = UDim2.new(0, 0, 0, 0)
    page.Visible                = false
    page.ZIndex                 = 12
    page.Parent                 = contentArea
    do
        local l = Instance.new("UIListLayout")
        l.Padding   = UDim.new(0, 8)
        l.SortOrder = Enum.SortOrder.LayoutOrder
        l.Parent    = page
        l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 8)
        end)
    end

    tabPages[name]   = page
    tabButtons[name] = btn
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    return page
end

local farmPage  = addTab("Farm",  1)
local statsPage = addTab("Stats", 2)

-- ── Widget builders ───────────────────────────────────────────────────────
local function makeRow(parent, order)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = Color3.fromRGB(22, 21, 34)
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    row.ZIndex           = 13
    row.Parent           = parent
    do
        local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 10) c.Parent = row
        local s = Instance.new("UIStroke")
        s.Color     = Color3.fromRGB(40, 38, 65)
        s.Thickness = 1
        s.Parent    = row
    end
    return row
end

local function makeLabel(parent, text, size, color, xalign, pos, sz)
    local l = Instance.new("TextLabel")
    l.Text                 = text
    l.Font                 = Enum.Font.Gotham
    l.TextSize             = size or 13
    l.TextColor3           = color or Color3.fromRGB(200, 195, 240)
    l.BackgroundTransparency = 1
    l.TextXAlignment       = xalign or Enum.TextXAlignment.Left
    l.Size                 = sz  or UDim2.new(1, -16, 1, 0)
    l.Position             = pos or UDim2.new(0, 12, 0, 0)
    l.ZIndex               = 14
    l.Parent               = parent
    return l
end

local function makeToggleRow(parent, order, labelText, defaultOn, onToggle)
    local row = makeRow(parent, order)

    makeLabel(row, labelText, 14, Color3.fromRGB(215, 210, 255),
        Enum.TextXAlignment.Left,
        UDim2.new(0, 12, 0, 0),
        UDim2.new(1, -70, 1, 0))

    local track = Instance.new("TextButton")
    track.Size             = UDim2.new(0, 44, 0, 24)
    track.Position         = UDim2.new(1, -54, 0.5, -12)
    track.BackgroundColor3 = defaultOn and Color3.fromRGB(120, 90, 240) or Color3.fromRGB(45, 42, 72)
    track.BorderSizePixel  = 0
    track.Text             = ""
    track.ZIndex           = 15
    track.Parent           = row
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = track end

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 18, 0, 18)
    knob.Position         = defaultOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 16
    knob.Parent           = track
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = knob end

    local state = defaultOn
    local function applyState()
        TweenService:Create(track, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Color3.fromRGB(120, 90, 240) or Color3.fromRGB(45, 42, 72)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        onToggle(state)
    end

    track.MouseButton1Click:Connect(function()
        state = not state
        applyState()
    end)
    row.MouseButton1Click:Connect(function()
        state = not state
        applyState()
    end)

    if defaultOn then
        task.spawn(function() onToggle(true) end)
    end

    return row
end

local function makeTextBoxRow(parent, order, placeholder, btnLabel, onSubmit)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 64)
    row.BackgroundColor3 = Color3.fromRGB(22, 21, 34)
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    row.ZIndex           = 13
    row.Parent           = parent
    do
        local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 10) c.Parent = row
        local s = Instance.new("UIStroke")
        s.Color     = Color3.fromRGB(40, 38, 65)
        s.Thickness = 1
        s.Parent    = row
    end

    local box = Instance.new("TextBox")
    box.Size             = UDim2.new(1, -100, 0, 28)
    box.Position         = UDim2.new(0, 10, 0.5, -14)
    box.BackgroundColor3 = Color3.fromRGB(18, 17, 28)
    box.BorderSizePixel  = 0
    box.PlaceholderText  = placeholder
    box.PlaceholderColor3 = Color3.fromRGB(70, 65, 110)
    box.Text             = ""
    box.Font             = Enum.Font.Gotham
    box.TextSize         = 13
    box.TextColor3       = Color3.fromRGB(215, 210, 255)
    box.ClearTextOnFocus = false
    box.ZIndex           = 15
    box.Parent           = row
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = box end

    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, 76, 0, 28)
    btn.Position         = UDim2.new(1, -86, 0.5, -14)
    btn.BackgroundColor3 = Color3.fromRGB(90, 70, 190)
    btn.BorderSizePixel  = 0
    btn.Text             = btnLabel
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 12
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.ZIndex           = 15
    btn.Parent           = row
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = btn end

    btn.MouseButton1Click:Connect(function()
        onSubmit(box.Text)
    end)
    return row, box
end

local function makeStatRow(parent, order, text)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(19, 18, 30)
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    row.ZIndex           = 13
    row.Parent           = parent
    do
        local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = row
        local s = Instance.new("UIStroke")
        s.Color     = Color3.fromRGB(40, 38, 65)
        s.Thickness = 1
        s.Parent    = row
    end
    return makeLabel(row, text, 13, Color3.fromRGB(180, 175, 230),
        Enum.TextXAlignment.Left,
        UDim2.new(0, 12, 0, 0),
        UDim2.new(1, -16, 1, 0))
end

-- ── FARM TAB ──────────────────────────────────────────────────────────────

-- Anti AFK (activado por defecto)
local afkConn = nil
local function enableAfk()
    if afkConn then return end
    afkConn = player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
local function disableAfk()
    if afkConn then
        afkConn:Disconnect()
        afkConn = nil
    end
end

makeToggleRow(farmPage, 1, "Anti AFK", true, function(on)
    if on then enableAfk() else disableAfk() end
end)

-- Fast Rebirth
local rebirthActive = false

makeToggleRow(farmPage, 2, "Fast Rebirth", false, function(on)
    rebirthActive = on
    if on then
        task.spawn(function()
            while rebirthActive do
                local char = player.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    pcall(function()
                        ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                    end)
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- Speed
local speedActive = false
local speedValue  = 120

local speedRow, speedBox = makeTextBoxRow(farmPage, 3, "Velocidad (ej: 120)", "Set", function(val)
    local n = tonumber(val)
    if n then speedValue = n end
end)

makeToggleRow(farmPage, 4, "Activar Speed", false, function(on)
    speedActive = on
    if on then
        task.spawn(function()
            while speedActive do
                local char = player.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    pcall(function()
                        ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSpeed", speedValue)
                    end)
                end
                task.wait(0.5)
            end
        end)
    end
end)

-- Ocultar partículas
local particleConn = nil
local PARTICLE_FRAMES = { "strengthFrame", "durabilityFrame", "agilityFrame" }

local function hideParticles()
    for _, name in ipairs(PARTICLE_FRAMES) do
        local obj = ReplicatedStorage:FindFirstChild(name)
        if obj and obj:IsA("GuiObject") then
            obj.Visible = false
        end
    end
end

makeToggleRow(farmPage, 5, "Ocultar Partículas", false, function(on)
    if on then
        hideParticles()
        if not particleConn then
            particleConn = ReplicatedStorage.ChildAdded:Connect(function(child)
                if table.find(PARTICLE_FRAMES, child.Name) and child:IsA("GuiObject") then
                    child.Visible = false
                end
            end)
        end
    else
        if particleConn then
            particleConn:Disconnect()
            particleConn = nil
        end
        for _, name in ipairs(PARTICLE_FRAMES) do
            local obj = ReplicatedStorage:FindFirstChild(name)
            if obj and obj:IsA("GuiObject") then
                obj.Visible = true
            end
        end
    end
end)

-- ── STATS TAB ─────────────────────────────────────────────────────────────
local lbTime      = makeStatRow(statsPage, 1,  "Tiempo:  00:00:00")
local lbStrength  = makeStatRow(statsPage, 2,  "Fuerza:  — | Ganada: —")
local lbDura      = makeStatRow(statsPage, 3,  "Durabilidad:  — | Ganada: —")
local lbRebirths  = makeStatRow(statsPage, 4,  "Rebirths:  — | Ganados: —")

RunService.Heartbeat:Connect(function()
    if not statsPage.Visible then return end

    local elapsed = tick() - sessionStart
    local hh = math.floor(elapsed / 3600)
    local mm = math.floor(elapsed % 3600 / 60)
    local ss = math.floor(elapsed % 60)
    lbTime.Text = string.format("Tiempo:  %02d:%02d:%02d", hh, mm, ss)

    if statStrength then
        local cur = statStrength.Value
        lbStrength.Text = string.format("Fuerza:  %s  |  Ganada: %s", fmt(cur), fmt(cur - startStrength))
    end
    if statDurability then
        local cur = statDurability.Value
        lbDura.Text = string.format("Durabilidad:  %s  |  Ganada: %s", fmt(cur), fmt(cur - startDurability))
    end
    if statRebirths then
        local cur = statRebirths.Value
        lbRebirths.Text = string.format("Rebirths:  %s  |  Ganados: %s", fmt(cur), fmt(cur - startRebirths))
    end
end)

-- ── Activar primer tab ────────────────────────────────────────────────────
switchTab("Farm")
