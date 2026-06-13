local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local StarterGui        = game:GetService("StarterGui")

local LP = Players.LocalPlayer

local CONFIG = {
    Colors = {
        bg        = Color3.fromRGB(12, 12, 12),
        surface   = Color3.fromRGB(20, 20, 20),
        surface2  = Color3.fromRGB(26, 26, 26),
        border    = Color3.fromRGB(42, 42, 42),
        red       = Color3.fromRGB(185, 0, 0),
        text      = Color3.fromRGB(230, 230, 230),
        textDim   = Color3.fromRGB(120, 120, 120),
        white     = Color3.fromRGB(255, 255, 255),
        pillOff   = Color3.fromRGB(48, 48, 48),
    },
    UI = {
        hubW   = 240,
        hubH   = 330,
        titleH = 44,
        tabH   = 30,
        tabY   = 42,
    },
    Timing = {
        tween         = TweenInfo.new(0.12, Enum.EasingStyle.Quad),
        minimizeDur   = 0.18,
        gradPulse     = 0.05,
        dotPulse      = 0.7,
        borderGlow    = 1.2,
        alertBlink    = 0.5,
        alertAutohide = 3,
    },
    Texts = {
        title          = "Fast Glitch 90%",
        notifTitle     = "Fast Glitch 90%",
        notifReady     = "@Real_Young0x",
        notifAntiLag   = "60% Optimizado",
        notifSellNeons = "Neones vendidos.",
    },
    Rocks = {
        { label = " Ancient Rock ",     req = 10000000, minDur = 10000000 },
        { label = " Muscle King Rock ", req = 5000000,  minDur = 5000000  },
        { label = " Legend Rock ",      req = 1000000,  minDur = 1000000  },
        { label = " Eternal Rock ",     req = 750000,   minDur = 750000   },
        { label = " Mythical Rock ",    req = 400000,   minDur = 400000   },
        { label = " Frost Rock ",       req = 150000,   minDur = 150000   },
        { label = " Beach Rock ",       req = 5000,     minDur = 5000     },
        { label = " Starter Rock ",     req = 100,      minDur = 100      },
        { label = " Tiny Rock ",        req = 0,        minDur = 0        },
    },
}

local C = CONFIG.Colors
local UI = CONFIG.UI
local T  = CONFIG.Timing

getgenv().BRG = {}
local S = getgenv().BRG
S.fastPunch    = false
S.selectedRock = nil
S.autoFarm     = false
S.antiAfk      = false
S.afkStartTime = nil
S.autoBuyNeons = false

local fastPunch = { enabled = false, threadA = nil, threadB = nil }

local function fastPunchStart()
    fastPunch.threadA = task.spawn(function()
        while fastPunch.enabled do
            pcall(function()
                local punch = LP.Backpack:FindFirstChild("Punch")
                if punch and LP.Character and LP.Character:FindFirstChild("Humanoid") then
                    LP.Character.Humanoid:EquipTool(punch)
                end
                local equipped = LP.Character and LP.Character:FindFirstChild("Punch")
                if equipped and equipped:FindFirstChild("attackTime") then
                    equipped.attackTime.Value = 0
                end
            end)
            task.wait(0.05)
        end
    end)
    fastPunch.threadB = task.spawn(function()
        while fastPunch.enabled do
            pcall(function()
                LP.muscleEvent:FireServer("punch", "rightHand")
                LP.muscleEvent:FireServer("punch", "leftHand")
                local equipped = LP.Character and LP.Character:FindFirstChild("Punch")
                if equipped then equipped:Activate() end
            end)
            task.wait(0.01)
        end
    end)
end

local function fastPunchStop()
    fastPunch.enabled = false
    if fastPunch.threadA then task.cancel(fastPunch.threadA); fastPunch.threadA = nil end
    if fastPunch.threadB then task.cancel(fastPunch.threadB); fastPunch.threadB = nil end
    pcall(function()
        local char = LP.Character
        if char then
            local eq = char:FindFirstChild("Punch")
            if eq then eq.Parent = LP.Backpack end
        end
    end)
end

local function gettool()
    for _, v in pairs(LP.Backpack:GetChildren()) do
        if v.Name == "Punch" and LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid:EquipTool(v)
        end
    end
    pcall(function()
        LP.muscleEvent:FireServer("punch", "leftHand")
        LP.muscleEvent:FireServer("punch", "rightHand")
    end)
end

local function handleRock(rock, leftHand)
    if not rock or not leftHand then return end
    pcall(function()
        rock.Size         = Vector3.new(2, 1, 1)
        rock.Transparency = 1
        rock.CanCollide   = false
        if rock:FindFirstChild("rockGui") then
            for _, v in pairs(rock.rockGui:GetChildren()) do v.Visible = false end
        end
        for _, name in ipairs({"rockEmitter", "hoopParticle", "lavaParticle"}) do
            if rock:FindFirstChild(name) then rock[name]:Destroy() end
        end
        rock.CFrame = leftHand.CFrame
        local touchPart = rock:FindFirstChild("TouchPart")
        if touchPart then touchPart.CFrame = leftHand.CFrame end
    end)
end

local function makeFarmLoop(toggle, neededDur, minDur, waitTime)
    return function()
        while toggle.enabled do
            task.wait(waitTime or 0.001)
            if not toggle.enabled then break end
            pcall(function()
                if not toggle.enabled then return end
                if LP.Durability.Value < minDur then return end
                local char = LP.Character
                if not char then return end
                local lh = char:FindFirstChild("LeftHand")
                local rh = char:FindFirstChild("RightHand")
                if not lh or not rh then return end
                for _, v in pairs(workspace.machinesFolder:GetDescendants()) do
                    if not toggle.enabled then break end
                    if v.Name == "neededDurability" and v.Value == neededDur then
                        local rock = v.Parent:FindFirstChild("Rock")
                        if rock then
                            handleRock(rock, lh)
                            if not toggle.enabled then break end
                            firetouchinterest(rock, rh, 0)
                            if not toggle.enabled then break end
                            firetouchinterest(rock, rh, 1)
                            if not toggle.enabled then break end
                            firetouchinterest(rock, lh, 0)
                            if not toggle.enabled then break end
                            firetouchinterest(rock, lh, 1)
                            if not toggle.enabled then break end
                            gettool()
                        end
                    end
                end
            end)
        end
    end
end

local activeRockToggle = nil
local rockSetters      = {}

local function stopAllRocks()
    if activeRockToggle then
        activeRockToggle:Stop()
        activeRockToggle = nil
    end
    for _, setter in ipairs(rockSetters) do setter(false, true) end
    S.autoFarm     = false
    S.selectedRock = nil
end

local function startBuyNeons()
    coroutine.wrap(function()
        while S.autoBuyNeons do
            local shopFolder = ReplicatedStorage:FindFirstChild("cPetShopFolder")
            local shopRemote = ReplicatedStorage:FindFirstChild("cPetShopRemote")
            if shopFolder and shopRemote then
                for _, pet in pairs(shopFolder:GetChildren()) do
                    if pet.Name:lower():find("neon") then
                        pcall(function() shopRemote:InvokeServer(pet) end)
                    end
                end
            end
            task.wait(0.1)
        end
    end)()
end

local function sellAllNeons()
    local petsFolder = LP:FindFirstChild("petsFolder")
    local rEvents    = ReplicatedStorage:FindFirstChild("rEvents")
    local sellEvent  = rEvents and (
        rEvents:FindFirstChild("sellPetRemote") or
        rEvents:FindFirstChild("sellPetEvent")  or
        rEvents:FindFirstChild("SellPetEvent")
    )
    if not petsFolder or not sellEvent then return end
    for _, folder in pairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                if pet.Name:lower():find("neon") then
                    pcall(function()
                        if sellEvent:IsA("RemoteFunction") then
                            sellEvent:InvokeServer("sellPet", pet)
                        else
                            sellEvent:FireServer("sellPet", pet)
                        end
                    end)
                    task.wait(0.1)
                end
            end
        end
    end
end

local afkIdleConn = nil

local function startAntiAfk()
    if afkIdleConn then return end
    local vim = game:GetService("VirtualInputManager")
    pcall(function()
        afkIdleConn = LP.Idled:Connect(function()
            vim:SendKeyEvent(true,  Enum.KeyCode.W, false, game)
            task.wait(0.1)
            vim:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        end)
    end)
end

local BLOCKED_ANIMS = {
    ["rbxassetid://3638729053"] = true,
    ["rbxassetid://3638767427"] = true,
}

local function isBlockedAnim(track)
    if not track.Animation then return false end
    local id   = track.Animation.AnimationId
    local name = track.Name:lower()
    return BLOCKED_ANIMS[id] or name:match("punch") or name:match("attack") or name:match("right")
end

local function stopBlockedTracks(char)
    if not char or not char:FindFirstChild("Humanoid") then return end
    for _, track in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
        if isBlockedAnim(track) then track:Stop() end
    end
end

local function setupAnimBlock()
    local char = LP.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    stopBlockedTracks(char)
    if not _G.BRAnimBlockConn then
        _G.BRAnimBlockConn = char.Humanoid.AnimationPlayed:Connect(function(track)
            if isBlockedAnim(track) then track:Stop() end
        end)
    end
end

local function setupToolBlock(tool)
    if not tool or not (tool.Name == "Punch" or tool.Name:match("Attack")) then return end
    if tool:GetAttribute("BRAnimOverride") then return end
    tool:SetAttribute("BRAnimOverride", true)
    local conn = tool.Activated:Connect(function()
        task.wait(0.05)
        stopBlockedTracks(LP.Character)
    end)
    if not _G.BRToolConns then _G.BRToolConns = {} end
    _G.BRToolConns[tool] = conn
end

local function startAnimBlock()
    setupAnimBlock()
    for _, tool in pairs(LP.Backpack:GetChildren()) do setupToolBlock(tool) end
    local char = LP.Character
    if char then
        for _, child in pairs(char:GetChildren()) do
            if child:IsA("Tool") then setupToolBlock(child) end
        end
    end
    if not _G.BRBkpConn then
        _G.BRBkpConn = LP.Backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then task.wait(0.1); setupToolBlock(child) end
        end)
    end
    if not _G.BRAnimMonitor then
        _G.BRAnimMonitor = RunService.Heartbeat:Connect(function()
            if tick() % 0.5 < 0.016 then stopBlockedTracks(LP.Character) end
        end)
    end
    if not _G.BRCharAddedConn then
        _G.BRCharAddedConn = LP.CharacterAdded:Connect(function()
            task.wait(1)
            setupAnimBlock()
        end)
    end
end

local function applyAntiLag()
    pcall(function()
        local L = game:GetService("Lighting")
        L.GlobalShadows = false
        L.FogEnd        = 9e9
        L.Brightness    = 1
        for _, fx in pairs(L:GetChildren()) do
            if fx:IsA("BloomEffect") or fx:IsA("BlurEffect") or
               fx:IsA("ColorCorrectionEffect") or fx:IsA("SunRaysEffect") or
               fx:IsA("DepthOfFieldEffect") then
                fx.Enabled = false
            end
        end
    end)
    local charModel = LP.Character
    for _, v in pairs(workspace:GetDescendants()) do
        if charModel and v:IsDescendantOf(charModel) then continue end
        pcall(function()
            if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or
               v:IsA("Sparkles") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
            end
            if v:IsA("SpecialMesh")  then v.TextureId = "" end
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
            if v:IsA("BasePart") then
                v.CastShadow = false
                v.Material   = Enum.Material.SmoothPlastic
            end
            if v:IsA("SelectionBox") or v:IsA("SelectionSphere") then v.Visible = false end
        end)
    end
    StarterGui:SetCore("SendNotification", {
        Title = "Anti Lag", Text = CONFIG.Texts.notifAntiLag, Duration = 3
    })
end

for _, g in ipairs(LP.PlayerGui:GetChildren()) do
    if g:IsA("ScreenGui") then
        local n = g.Name:lower()
        if n:find("brhub") or n:find("brafk") or n:find("bugeo") or n:find("fastglitch") then
            g:Destroy()
        end
    end
end

local HUB_W     = UI.hubW
local HUB_H     = UI.hubH
local TITLE_H   = UI.titleH
local TAB_H     = UI.tabH
local TAB_Y     = UI.tabY
local tabW      = math.floor(HUB_W / 3)
local CONTENT_Y = TAB_Y + TAB_H + 1

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "BRHub"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder   = 999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent         = LP.PlayerGui

local Shadow = Instance.new("Frame")
Shadow.Size                   = UDim2.fromOffset(HUB_W + 10, HUB_H + 10)
Shadow.Position               = UDim2.new(0.5, -(HUB_W / 2) - 5, 0.5, -(HUB_H / 2) - 5)
Shadow.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.5
Shadow.BorderSizePixel        = 0
Shadow.ZIndex                 = 1
Shadow.Parent                 = ScreenGui
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 10)

local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Size             = UDim2.fromOffset(HUB_W, HUB_H)
MainFrame.Position         = UDim2.new(0.5, -HUB_W / 2, 0.5, -HUB_H / 2)
MainFrame.BackgroundColor3 = C.bg
MainFrame.BorderSizePixel  = 0
MainFrame.ZIndex           = 2
MainFrame.ClipsDescendants = true
MainFrame.Parent           = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color     = Color3.fromRGB(55, 5, 5)
mainStroke.Thickness = 1.5

local TitleBar = Instance.new("Frame")
TitleBar.Name             = "TitleBar"
TitleBar.Size             = UDim2.new(1, 0, 0, TITLE_H)
TitleBar.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
TitleBar.BorderSizePixel  = 0
TitleBar.ZIndex           = 3
TitleBar.ClipsDescendants = true
TitleBar.Parent           = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local titleBaseGrad = Instance.new("UIGradient", TitleBar)
titleBaseGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(30, 0, 0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(100, 0, 0)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(55, 0, 0)),
})
titleBaseGrad.Rotation = 90

local gradLayer = Instance.new("Frame")
gradLayer.Size                   = UDim2.new(2, 0, 1, 0)
gradLayer.Position               = UDim2.new(-0.5, 0, 0, 0)
gradLayer.BackgroundColor3       = Color3.fromRGB(130, 0, 0)
gradLayer.BackgroundTransparency = 0.15
gradLayer.BorderSizePixel        = 0
gradLayer.ZIndex                 = 2
gradLayer.Parent                 = TitleBar

local gradLayerGrad = Instance.new("UIGradient", gradLayer)
gradLayerGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(40, 0, 0)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(150, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 25, 25)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(150, 0, 0)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(40, 0, 0)),
})
gradLayerGrad.Rotation = 90

local TitleFix = Instance.new("Frame")
TitleFix.Size             = UDim2.new(1, 0, 0, 8)
TitleFix.Position         = UDim2.new(0, 0, 1, -8)
TitleFix.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
TitleFix.BorderSizePixel  = 0
TitleFix.ZIndex           = 3
TitleFix.Parent           = TitleBar

local TitleAccent = Instance.new("Frame")
TitleAccent.Size             = UDim2.new(1, 0, 0, 2)
TitleAccent.Position         = UDim2.new(0, 0, 1, 0)
TitleAccent.BackgroundColor3 = C.red
TitleAccent.BorderSizePixel  = 0
TitleAccent.ZIndex           = 5
TitleAccent.Parent           = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size               = UDim2.new(1, -72, 1, 0)
TitleLabel.Position           = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text               = CONFIG.Texts.title
TitleLabel.TextColor3         = C.white
TitleLabel.Font               = Enum.Font.GothamBlack
TitleLabel.TextSize           = 11
TitleLabel.TextXAlignment     = Enum.TextXAlignment.Left
TitleLabel.TextYAlignment     = Enum.TextYAlignment.Center
TitleLabel.ZIndex             = 6
TitleLabel.Parent             = TitleBar

local titleStroke = Instance.new("UIStroke", TitleLabel)
titleStroke.Color        = Color3.fromRGB(140, 0, 0)
titleStroke.Thickness    = 1.5
titleStroke.Transparency = 0.2

local MinBtn = Instance.new("TextButton")
MinBtn.Size             = UDim2.fromOffset(26, 26)
MinBtn.Position         = UDim2.new(1, -63, 0.5, -13)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinBtn.Text             = "-"
MinBtn.TextColor3       = C.white
MinBtn.Font             = Enum.Font.GothamBlack
MinBtn.TextSize         = 16
MinBtn.BorderSizePixel  = 0
MinBtn.ZIndex           = 6
MinBtn.Parent           = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)

MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtn, T.tween, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
end)
MinBtn.MouseLeave:Connect(function()
    TweenService:Create(MinBtn, T.tween, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.fromOffset(26, 26)
CloseBtn.Position         = UDim2.new(1, -33, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(155, 0, 0)
CloseBtn.Text             = "X"
CloseBtn.TextColor3       = C.white
CloseBtn.Font             = Enum.Font.GothamBlack
CloseBtn.TextSize         = 12
CloseBtn.BorderSizePixel  = 0
CloseBtn.ZIndex           = 6
CloseBtn.Parent           = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, T.tween, {BackgroundColor3 = Color3.fromRGB(220, 20, 20)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, T.tween, {BackgroundColor3 = Color3.fromRGB(155, 0, 0)}):Play()
end)

local TabBar = Instance.new("Frame")
TabBar.Name             = "TabBar"
TabBar.Size             = UDim2.new(1, 0, 0, TAB_H)
TabBar.Position         = UDim2.new(0, 0, 0, TAB_Y)
TabBar.BackgroundColor3 = C.surface
TabBar.BorderSizePixel  = 0
TabBar.ZIndex           = 3
TabBar.ClipsDescendants = true
TabBar.Parent           = MainFrame

local TabSep = Instance.new("Frame")
TabSep.Size             = UDim2.new(1, 0, 0, 1)
TabSep.Position         = UDim2.new(0, 0, 1, 0)
TabSep.BackgroundColor3 = C.border
TabSep.BorderSizePixel  = 0
TabSep.ZIndex           = 4
TabSep.Parent           = TabBar

local ContentArea = Instance.new("Frame")
ContentArea.Size                   = UDim2.new(1, 0, 1, -CONTENT_Y)
ContentArea.Position               = UDim2.new(0, 0, 0, CONTENT_Y)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants       = true
ContentArea.ZIndex                 = 2
ContentArea.Parent                 = MainFrame

local tabButtons = {}
local pages      = {}
local tabIndex   = 0

local function createPage()
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size                   = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness     = 2
    scroll.ScrollBarImageColor3   = C.red
    scroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    scroll.BorderSizePixel        = 0
    scroll.Visible                = false
    scroll.ZIndex                 = 2
    scroll.Parent                 = ContentArea
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding   = UDim.new(0, 4)
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingLeft   = UDim.new(0, 8)
    pad.PaddingRight  = UDim.new(0, 8)
    pad.PaddingTop    = UDim.new(0, 7)
    pad.PaddingBottom = UDim.new(0, 7)
    return scroll
end

local function switchTab(name)
    for n, btn in pairs(tabButtons) do
        local active = (n == name)
        btn.BackgroundColor3 = active and C.surface2 or C.surface
        btn.TextColor3       = active and C.white or Color3.fromRGB(130, 130, 130)
        local ul = btn:FindFirstChild("UL")
        if ul then ul.BackgroundColor3 = active and C.red or C.surface end
    end
    for n, pg in pairs(pages) do pg.Visible = (n == name) end
end

local function addTab(name)
    local idx = tabIndex
    tabIndex  = tabIndex + 1
    local btn = Instance.new("TextButton")
    btn.Name             = name
    btn.Size             = UDim2.fromOffset(tabW, TAB_H)
    btn.Position         = UDim2.fromOffset(idx * tabW, 0)
    btn.BackgroundColor3 = C.surface
    btn.Text             = name
    btn.TextColor3       = Color3.fromRGB(145, 145, 145)
    btn.Font             = Enum.Font.GothamBlack
    btn.TextSize         = 12
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 4
    btn.Parent           = TabBar
    local ul = Instance.new("Frame")
    ul.Name             = "UL"
    ul.Size             = UDim2.new(1, 0, 0, 2)
    ul.Position         = UDim2.new(0, 0, 1, -2)
    ul.BackgroundColor3 = C.surface
    ul.BorderSizePixel  = 0
    ul.ZIndex           = 5
    ul.Parent           = btn
    local pg = createPage()
    tabButtons[name] = btn
    pages[name]      = pg
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    return pg
end

local function createSeparator(parent, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size                  = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text                  = text
    lbl.TextColor3            = C.textDim
    lbl.Font                  = Enum.Font.GothamBold
    lbl.TextSize              = 9
    lbl.TextXAlignment        = Enum.TextXAlignment.Center
    lbl.LayoutOrder           = order
    lbl.ZIndex                = 2
    lbl.Parent                = parent
end

local function createToggle(parent, labelText, order, callback)
    local row = Instance.new("Frame")
    row.Name             = "T" .. order
    row.Size             = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = C.surface2
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    row.ZIndex           = 2
    row.Parent           = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size                  = UDim2.new(1, -54, 1, 0)
    lbl.Position              = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                  = labelText
    lbl.TextColor3            = C.text
    lbl.Font                  = Enum.Font.GothamBold
    lbl.TextSize              = 11
    lbl.TextXAlignment        = Enum.TextXAlignment.Left
    lbl.TextWrapped           = true
    lbl.ZIndex                = 3
    lbl.Parent                = row

    local pill = Instance.new("Frame")
    pill.Size             = UDim2.fromOffset(36, 18)
    pill.Position         = UDim2.new(1, -44, 0.5, -9)
    pill.BackgroundColor3 = C.pillOff
    pill.BorderSizePixel  = 0
    pill.ZIndex           = 3
    pill.Parent           = row
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Size             = UDim2.fromOffset(12, 12)
    dot.Position         = UDim2.new(0, 3, 0.5, -6)
    dot.BackgroundColor3 = C.white
    dot.BorderSizePixel  = 0
    dot.ZIndex           = 4
    dot.Parent           = pill
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local state = false

    local function setState(v, silent)
        state = v
        TweenService:Create(pill, T.tween, {
            BackgroundColor3 = v and C.red or C.pillOff
        }):Play()
        TweenService:Create(dot, T.tween, {
            Position = v and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        }):Play()
        if not silent and callback then callback(v) end
    end

    local function handleInput(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            setState(not state)
        elseif inp.UserInputType == Enum.UserInputType.Touch then
            local startPos2 = inp.Position
            local moved     = false
            local movedConn
            movedConn = inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    movedConn:Disconnect()
                    if not moved then setState(not state) end
                else
                    local delta = inp.Position - startPos2
                    if math.abs(delta.X) > 10 or math.abs(delta.Y) > 10 then
                        moved = true
                    end
                end
            end)
        end
    end

    row.InputBegan:Connect(handleInput)
    pill.InputBegan:Connect(handleInput)
    return row, setState
end

local function createButton(parent, labelText, order, callback)
    local btn = Instance.new("TextButton")
    btn.Name             = "B" .. order
    btn.Size             = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = C.surface2
    btn.Text             = labelText
    btn.TextColor3       = C.text
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 11
    btn.BorderSizePixel  = 0
    btn.LayoutOrder      = order
    btn.TextWrapped      = true
    btn.ZIndex           = 2
    btn.Parent           = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local st = Instance.new("UIStroke", btn)
    st.Color     = C.border
    st.Thickness = 1
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, T.tween, {BackgroundColor3 = Color3.fromRGB(34, 34, 34)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, T.tween, {BackgroundColor3 = C.surface2}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function showConfirmModal(onYes)
    local overlay = Instance.new("Frame")
    overlay.Size                   = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel        = 0
    overlay.ZIndex                 = 20
    overlay.Parent                 = MainFrame
    Instance.new("UICorner", overlay).CornerRadius = UDim.new(0, 8)

    local modal = Instance.new("Frame")
    modal.Size             = UDim2.fromOffset(204, 112)
    modal.Position         = UDim2.new(0.5, -102, 0.5, -56)
    modal.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    modal.BorderSizePixel  = 0
    modal.ZIndex           = 21
    modal.Parent           = MainFrame
    Instance.new("UICorner", modal).CornerRadius = UDim.new(0, 8)
    local ms = Instance.new("UIStroke", modal)
    ms.Color     = C.red
    ms.Thickness = 1.5

    local header = Instance.new("TextLabel")
    header.Size               = UDim2.new(1, 0, 0, 28)
    header.Position           = UDim2.new(0, 0, 0, 8)
    header.BackgroundTransparency = 1
    header.Text               = "¿Vender?"
    header.TextColor3         = C.red
    header.Font               = Enum.Font.GothamBlack
    header.TextSize           = 12
    header.ZIndex             = 22
    header.Parent             = modal

    local msg = Instance.new("TextLabel")
    msg.Size               = UDim2.new(1, -16, 0, 30)
    msg.Position           = UDim2.new(0, 8, 0, 36)
    msg.BackgroundTransparency = 1
    msg.Text               = "Se venderan TODOS tus Neones.\n¿Estas seguro?"
    msg.TextColor3         = C.text
    msg.Font               = Enum.Font.Gotham
    msg.TextSize           = 10
    msg.TextWrapped        = true
    msg.ZIndex             = 22
    msg.Parent             = modal

    local function closeModal() overlay:Destroy(); modal:Destroy() end

    local yesBtn = Instance.new("TextButton")
    yesBtn.Size             = UDim2.fromOffset(86, 26)
    yesBtn.Position         = UDim2.new(0, 10, 1, -34)
    yesBtn.BackgroundColor3 = C.red
    yesBtn.Text             = "SI, VENDER"
    yesBtn.TextColor3       = C.white
    yesBtn.Font             = Enum.Font.GothamBold
    yesBtn.TextSize         = 11
    yesBtn.BorderSizePixel  = 0
    yesBtn.ZIndex           = 22
    yesBtn.Parent           = modal
    Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 5)

    local noBtn = Instance.new("TextButton")
    noBtn.Size             = UDim2.fromOffset(86, 26)
    noBtn.Position         = UDim2.new(1, -96, 1, -34)
    noBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
    noBtn.Text             = "CANCELAR"
    noBtn.TextColor3       = C.text
    noBtn.Font             = Enum.Font.GothamBold
    noBtn.TextSize         = 11
    noBtn.BorderSizePixel  = 0
    noBtn.ZIndex           = 22
    noBtn.Parent           = modal
    Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 5)

    yesBtn.MouseButton1Click:Connect(function() closeModal(); onYes() end)
    noBtn.MouseButton1Click:Connect(closeModal)
end

local AfkGui = Instance.new("ScreenGui")
AfkGui.Name           = "BRAfkGui"
AfkGui.ResetOnSpawn   = false
AfkGui.DisplayOrder   = 998
AfkGui.IgnoreGuiInset = true
AfkGui.Parent         = LP.PlayerGui

local afkFrame = Instance.new("Frame")
afkFrame.Name                   = "AfkOverlay"
afkFrame.Size                   = UDim2.fromOffset(190, 90)
afkFrame.Position               = UDim2.new(1, -200, 1, -160)
afkFrame.BackgroundColor3       = Color3.fromRGB(10, 5, 5)
afkFrame.BackgroundTransparency = 0.18
afkFrame.BorderSizePixel        = 0
afkFrame.Visible                = false
afkFrame.Active                 = false
afkFrame.Parent                 = AfkGui
Instance.new("UICorner", afkFrame).CornerRadius = UDim.new(0, 14)

local afkStroke = Instance.new("UIStroke", afkFrame)
afkStroke.Color        = Color3.fromRGB(200, 20, 20)
afkStroke.Thickness    = 1.5
afkStroke.Transparency = 0.1

local afkGrad = Instance.new("UIGradient", afkFrame)
afkGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(22, 4, 4)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 2, 2)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(8, 1, 1)),
})
afkGrad.Rotation = 135

local afkAccent = Instance.new("Frame")
afkAccent.Size             = UDim2.new(0.55, 0, 0, 2)
afkAccent.Position         = UDim2.new(0.225, 0, 0, 0)
afkAccent.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
afkAccent.BorderSizePixel  = 0
afkAccent.ZIndex           = 3
afkAccent.Active           = false
afkAccent.Parent           = afkFrame
Instance.new("UICorner", afkAccent).CornerRadius = UDim.new(1, 0)

local afkAccentGrad = Instance.new("UIGradient", afkAccent)
afkAccentGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(80, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 40, 40)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(80, 0, 0)),
})

local afkDot = Instance.new("Frame")
afkDot.Size             = UDim2.fromOffset(7, 7)
afkDot.Position         = UDim2.new(0, 12, 0, 12)
afkDot.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
afkDot.BorderSizePixel  = 0
afkDot.ZIndex           = 4
afkDot.Active           = false
afkDot.Parent           = afkFrame
Instance.new("UICorner", afkDot).CornerRadius = UDim.new(1, 0)

local afkStatusLabel = Instance.new("TextLabel")
afkStatusLabel.Size               = UDim2.new(1, -28, 0, 22)
afkStatusLabel.Position           = UDim2.new(0, 24, 0, 8)
afkStatusLabel.BackgroundTransparency = 1
afkStatusLabel.Text               = "ANTI AFK ACTIVO"
afkStatusLabel.TextColor3         = Color3.fromRGB(245, 245, 245)
afkStatusLabel.Font               = Enum.Font.GothamBlack
afkStatusLabel.TextSize           = 13
afkStatusLabel.TextXAlignment     = Enum.TextXAlignment.Left
afkStatusLabel.ZIndex             = 4
afkStatusLabel.Active             = false
afkStatusLabel.Parent             = afkFrame

local afkDiv = Instance.new("Frame")
afkDiv.Size                   = UDim2.new(0.8, 0, 0, 1)
afkDiv.Position               = UDim2.new(0.1, 0, 0, 38)
afkDiv.BackgroundColor3       = Color3.fromRGB(160, 15, 15)
afkDiv.BackgroundTransparency = 0.3
afkDiv.BorderSizePixel        = 0
afkDiv.ZIndex                 = 3
afkDiv.Active                 = false
afkDiv.Parent                 = afkFrame

local afkTimer = Instance.new("TextLabel")
afkTimer.Size               = UDim2.new(1, 0, 0, 44)
afkTimer.Position           = UDim2.new(0, 0, 0, 44)
afkTimer.BackgroundTransparency = 1
afkTimer.Text               = "00:00:00"
afkTimer.TextColor3         = Color3.fromRGB(235, 60, 60)
afkTimer.Font               = Enum.Font.GothamBlack
afkTimer.TextSize           = 26
afkTimer.TextXAlignment     = Enum.TextXAlignment.Center
afkTimer.ZIndex             = 4
afkTimer.Active             = false
afkTimer.Parent             = afkFrame

task.spawn(function()
    local t = 0
    while ScreenGui and ScreenGui.Parent do
        t = t + task.wait(T.gradPulse)
        local offset = (math.sin(t * 0.55) * 0.5) + 0.5
        local r1 = math.floor(130 + offset * 55)
        local r2 = math.floor(200 + offset * 35)
        gradLayerGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(35, 0, 0)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(r1, 0, 0)),
            ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(r2, 18, 18)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(r1, 0, 0)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(35, 0, 0)),
        })
        gradLayer.Position = UDim2.new(-0.5 + offset * 0.28, 0, 0, 0)
    end
end)

task.spawn(function()
    while AfkGui and AfkGui.Parent do
        if S.antiAfk then
            TweenService:Create(afkDot, TweenInfo.new(T.dotPulse, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.7
            }):Play()
            task.wait(T.dotPulse)
            TweenService:Create(afkDot, TweenInfo.new(T.dotPulse, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0
            }):Play()
            task.wait(T.dotPulse)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while AfkGui and AfkGui.Parent do
        if S.antiAfk and afkFrame.Visible then
            TweenService:Create(afkStroke, TweenInfo.new(T.borderGlow, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.5
            }):Play()
            task.wait(T.borderGlow)
            TweenService:Create(afkStroke, TweenInfo.new(T.borderGlow, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.05
            }):Play()
            task.wait(T.borderGlow)
        else
            task.wait(0.5)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if S.antiAfk and S.afkStartTime and afkFrame.Visible then
        local e = math.floor(tick() - S.afkStartTime)
        afkTimer.Text = string.format("%02d:%02d:%02d",
            math.floor(e / 3600), math.floor((e % 3600) / 60), e % 60)
    end
end)

local pageRocks    = addTab("Rocks")
local rocksSection = nil
local alertLabel   = nil
local alertHideThread = nil

local function showFastPunchAlert()
    if alertLabel then alertLabel.Visible = true end
    if alertHideThread then task.cancel(alertHideThread); alertHideThread = nil end
    alertHideThread = task.delay(T.alertAutohide, function()
        if alertLabel then alertLabel.Visible = false end
        alertHideThread = nil
    end)
end

local function setRocksSectionFaded(faded)
    if not rocksSection then return end
    local transparency = faded and 0.65 or 0
    for _, child in pairs(rocksSection:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                TextTransparency = transparency
            }):Play()
        end
    end
end

createSeparator(pageRocks, "Fast Glitch", 1)

local _, setPunch = createToggle(pageRocks, "Fast Punch 90%", 2, function(v)
    fastPunch.enabled = v
    if v then
        fastPunchStart()
        setRocksSectionFaded(false)
        if alertLabel then alertLabel.Visible = false end
    else
        fastPunchStop()
        stopAllRocks()
        for _, setter in ipairs(rockSetters) do setter(false, true) end
        setRocksSectionFaded(true)
    end
end)

createSeparator(pageRocks, "Selecciona una Roca", 3)

alertLabel = Instance.new("TextLabel")
alertLabel.Name                   = "FastPunchAlert"
alertLabel.Size                   = UDim2.new(1, 0, 0, 38)
alertLabel.BackgroundColor3       = Color3.fromRGB(18, 0, 0)
alertLabel.BackgroundTransparency = 0
alertLabel.Text                   = "⚠ ACTIVA FAST PUNCH PRIMERO ⚠"
alertLabel.TextColor3             = C.white
alertLabel.Font                   = Enum.Font.GothamBlack
alertLabel.TextSize               = 12
alertLabel.TextXAlignment         = Enum.TextXAlignment.Center
alertLabel.BorderSizePixel        = 0
alertLabel.LayoutOrder            = 4
alertLabel.Visible                = false
alertLabel.ZIndex                 = 3
alertLabel.Parent                 = pageRocks
Instance.new("UICorner", alertLabel).CornerRadius = UDim.new(0, 7)

local alertStroke = Instance.new("UIStroke", alertLabel)
alertStroke.Color        = C.white
alertStroke.Thickness    = 1.2
alertStroke.Transparency = 0.55

local alertGrad = Instance.new("UIGradient", alertLabel)
alertGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(8, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90, 4, 4)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(8, 0, 0)),
})
alertGrad.Rotation = 90

local alertHighlight = Instance.new("Frame")
alertHighlight.Size                   = UDim2.new(0.6, 0, 0, 1)
alertHighlight.Position               = UDim2.new(0.2, 0, 0, 0)
alertHighlight.BackgroundColor3       = C.white
alertHighlight.BackgroundTransparency = 0.55
alertHighlight.BorderSizePixel        = 0
alertHighlight.ZIndex                 = 5
alertHighlight.Parent                 = alertLabel
Instance.new("UICorner", alertHighlight).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        if alertLabel and alertLabel.Visible then
            TweenService:Create(alertLabel, TweenInfo.new(T.alertBlink, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(140, 5, 5)
            }):Play()
            TweenService:Create(alertStroke, TweenInfo.new(T.alertBlink, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.25
            }):Play()
            task.wait(T.alertBlink)
            TweenService:Create(alertLabel, TweenInfo.new(T.alertBlink, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(18, 0, 0)
            }):Play()
            TweenService:Create(alertStroke, TweenInfo.new(T.alertBlink, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.55
            }):Play()
            task.wait(T.alertBlink)
        else
            task.wait(0.4)
        end
    end
end)

rocksSection = Instance.new("Frame")
rocksSection.Name                   = "RocksSection"
rocksSection.Size                   = UDim2.new(1, 0, 0, 0)
rocksSection.AutomaticSize          = Enum.AutomaticSize.Y
rocksSection.BackgroundTransparency = 1
rocksSection.BorderSizePixel        = 0
rocksSection.LayoutOrder            = 5
rocksSection.ZIndex                 = 2
rocksSection.Parent                 = pageRocks

local rocksSectionLayout = Instance.new("UIListLayout", rocksSection)
rocksSectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
rocksSectionLayout.Padding   = UDim.new(0, 4)

for i, rockDef in ipairs(CONFIG.Rocks) do
    local rd     = rockDef
    local toggle = { enabled = false, thread = nil }

    function toggle:Start()
        if self.thread then task.cancel(self.thread); self.thread = nil end
        self.enabled = true
        self.thread  = task.spawn(makeFarmLoop(self, rd.req, rd.minDur, 0.001))
    end

    function toggle:Stop()
        self.enabled = false
        if self.thread then task.cancel(self.thread); self.thread = nil end
    end

    local _, setter = createToggle(rocksSection, rd.label, i, function(v)
        if v and not fastPunch.enabled then
            pageRocks.CanvasPosition = Vector2.new(0, 0)
            showFastPunchAlert()
            task.defer(function()
                if rockSetters[i] then rockSetters[i](false, true) end
            end)
            return
        end
        if v then
            if activeRockToggle and activeRockToggle ~= toggle then
                local prev = activeRockToggle
                prev:Stop()
                for idx2, s in ipairs(rockSetters) do
                    if idx2 ~= i then s(false, true) end
                end
                activeRockToggle = nil
            end
            activeRockToggle = toggle
            S.selectedRock   = rd.label
            S.autoFarm       = true
            toggle:Start()
        else
            if activeRockToggle == toggle then activeRockToggle = nil end
            toggle:Stop()
            S.autoFarm     = false
            S.selectedRock = nil
        end
    end)
    rockSetters[i] = setter
end

setRocksSectionFaded(true)

local pagePets = addTab("Neones")

createSeparator(pagePets, "Compra Rapida de Neones", 1)

createToggle(pagePets, "Comprar Neones", 2, function(v)
    S.autoBuyNeons = v
    if v then startBuyNeons() end
end)

createButton(pagePets, "Vender Neones", 3, function()
    showConfirmModal(function()
        sellAllNeons()
        StarterGui:SetCore("SendNotification", {
            Title = "Vendidos!", Text = CONFIG.Texts.notifSellNeons, Duration = 3
        })
    end)
end)

local pageMisc = addTab("Misc")

createSeparator(pageMisc, "ANTI AFK", 1)

local afkActivated    = false
local afkTimerShowing = true
local afkBtn

afkBtn = createButton(pageMisc, "Anti AFK", 2, function()
    if afkActivated then return end
    afkActivated   = true
    S.antiAfk      = true
    S.afkStartTime = tick()
    startAntiAfk()
    afkFrame.Visible        = true
    afkTimerShowing         = true
    afkBtn.Text             = "Anti-AFK Activo"
    afkBtn.TextColor3       = Color3.fromRGB(20, 20, 20)
    afkBtn.BackgroundColor3 = Color3.fromRGB(40, 8, 8)
    local st = afkBtn:FindFirstChildWhichIsA("UIStroke")
    if st then st.Color = C.red end
end)

createButton(pageMisc, "Ocultar / Mostrar AFK", 3, function()
    afkTimerShowing  = not afkTimerShowing
    afkFrame.Visible = afkTimerShowing and S.antiAfk
end)

createSeparator(pageMisc, "RENDIMIENTO", 10)

local antiLagUsed = false
local antiLagBtn
antiLagBtn = createButton(pageMisc, "Anti Lag", 11, function()
    if antiLagUsed then
        StarterGui:SetCore("SendNotification", {
            Title = "Anti Lag", Text = "Ya fue aplicado.", Duration = 2
        })
        return
    end
    antiLagUsed                 = true
    antiLagBtn.Text             = "Anti Lag Aplicado"
    antiLagBtn.TextColor3       = C.textDim
    antiLagBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    applyAntiLag()
end)

createSeparator(pageMisc, "ANIMACIONES", 20)

local animUsed = false
local animBtn
animBtn = createButton(pageMisc, "Quitar Animacion de Puños", 21, function()
    if animUsed then return end
    animUsed = true
    startAnimBlock()
    animBtn.Text             = "Animaciones Eliminadas"
    animBtn.TextColor3       = Color3.fromRGB(20, 20, 20)
    animBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    local st = animBtn:FindFirstChildWhichIsA("UIStroke")
    if st then st.Color = C.border end
end)

CloseBtn.MouseButton1Click:Connect(function()
    fastPunchStop()
    stopAllRocks()
    S.autoBuyNeons = false
    if LP.PlayerGui:FindFirstChild("BRAfkGui") then
        LP.PlayerGui.BRAfkGui:Destroy()
    end
    ScreenGui:Destroy()
    Shadow:Destroy()
end)

local isMinimized = false

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinBtn.Text         = "+"
        TabBar.Visible      = false
        ContentArea.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(T.minimizeDur, Enum.EasingStyle.Quad), {
            Size = UDim2.fromOffset(HUB_W, TITLE_H)
        }):Play()
        TweenService:Create(Shadow, TweenInfo.new(T.minimizeDur, Enum.EasingStyle.Quad), {
            Size = UDim2.fromOffset(HUB_W + 10, TITLE_H + 10)
        }):Play()
    else
        MinBtn.Text = "-"
        TweenService:Create(MainFrame, TweenInfo.new(T.minimizeDur, Enum.EasingStyle.Quad), {
            Size = UDim2.fromOffset(HUB_W, HUB_H)
        }):Play()
        TweenService:Create(Shadow, TweenInfo.new(T.minimizeDur, Enum.EasingStyle.Quad), {
            Size = UDim2.fromOffset(HUB_W + 10, HUB_H + 10)
        }):Play()
        task.delay(T.minimizeDur, function()
            TabBar.Visible      = true
            ContentArea.Visible = true
        end)
    end
end)

local dragging  = false
local dragStart = nil
local startPos  = nil

TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or
       inp.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = inp.Position
        startPos  = MainFrame.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if not dragging then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement or
       inp.UserInputType == Enum.UserInputType.Touch then
        local d  = inp.Position - dragStart
        local nx = startPos.X.Offset + d.X
        local ny = startPos.Y.Offset + d.Y
        MainFrame.Position = UDim2.new(startPos.X.Scale, nx, startPos.Y.Scale, ny)
        Shadow.Position    = UDim2.new(startPos.X.Scale, nx - 5, startPos.Y.Scale, ny - 5)
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or
       inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

switchTab("Rocks")

task.wait(0.5)
StarterGui:SetCore("SendNotification", {
    Title    = CONFIG.Texts.notifTitle,
    Text     = CONFIG.Texts.notifReady,
    Duration = 2,
})
