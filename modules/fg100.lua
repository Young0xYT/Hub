local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- CLEANUP — destruye instancias viejas del mismo script
for _, g in ipairs(PlayerGui:GetChildren()) do
    if g:IsA("ScreenGui") and g.Name == "FG100Hub" then
        g:Destroy()
    end
end

-- OCULTAR FRAMES DE PARTÍCULAS
local PARTICLE_FRAMES = { "strengthFrame", "durabilityFrame", "agilityFrame" }
local function hideParticleFrames()
    for _, name in ipairs(PARTICLE_FRAMES) do
        local obj = ReplicatedStorage:FindFirstChild(name)
        if obj and obj:IsA("GuiObject") then
            obj.Visible = false
        end
    end
end
hideParticleFrames()

ReplicatedStorage.ChildAdded:Connect(function(child)
    if table.find(PARTICLE_FRAMES, child.Name) and child:IsA("GuiObject") then
        child.Visible = false
    end
end)

-- FORMATO DE NÚMEROS ABREVIADOS
local function fmt(n)
    local abs = math.abs(n)
    local sign = n < 0 and "-" or ""
    local suf = { {1e15,"Qa"}, {1e12,"T"}, {1e9,"B"}, {1e6,"M"}, {1e3,"K"} }
    for _, s in ipairs(suf) do
        if abs >= s[1] then
            return sign .. string.format("%.2f%s", abs / s[1], s[2])
        end
    end
    return sign .. string.format("%.2f", abs)
end

-- TABLA DE ROCAS
local ROCKS = {
    { label = "Ancient Jungle (10M)", req = 10000000 },
    { label = "Muscle King (5M)", req = 5000000 },
    { label = "Legend Gym (1M)", req = 1000000 },
    { label = "Eternal Gym (750k)", req = 750000 },
    { label = "Mythical Gym (400k)", req = 400000 },
    { label = "Frost Gym (150k)", req = 150000 },
    { label = "Legend Beach (5k)", req = 5000 },
    { label = "Starter Island (100)", req = 100 },
    { label = "Tiny Island (0)", req = 0 },
}

-- ESTADO GLOBAL
local STATE = {
    punchEnabled = false,
    punchThreadA = nil,
    punchThreadB = nil,
    rockEnabled = false,
    rockThread = nil,
    rockIdx = nil,
    rockSetters = {},
    rebirthEnabled = false,
    rebirthThread = nil,
    sizeEnabled = false,
    sizeThread = nil,
    speedEnabled = false,
    speedThread = nil,
    speedValue = 120,
    afkConn = nil,
    heartbeatConn = nil,
    closed = false,
}

-- FAST PUNCH
local function gettool()
    for _, v in pairs(LP.Backpack:GetChildren()) do
        if v.Name == "Punch" then
            local char = LP.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:EquipTool(v)
            end
        end
    end
    pcall(function()
        LP.muscleEvent:FireServer("punch", "leftHand")
        LP.muscleEvent:FireServer("punch", "rightHand")
    end)
end

local function startFastPunch()
    STATE.punchEnabled = true
    STATE.punchThreadA = task.spawn(function()
        while STATE.punchEnabled do
            pcall(function()
                local punch = LP.Backpack:FindFirstChild("Punch")
                if punch then
                    local char = LP.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid:EquipTool(punch)
                    end
                end
                local eq = LP.Character and LP.Character:FindFirstChild("Punch")
                if eq and eq:FindFirstChild("attackTime") then
                    eq.attackTime.Value = 0
                end
            end)
            task.wait(0.05)
        end
    end)

    STATE.punchThreadB = task.spawn(function()
        while STATE.punchEnabled do
            pcall(function()
                LP.muscleEvent:FireServer("punch", "rightHand")
                LP.muscleEvent:FireServer("punch", "leftHand")
                local eq = LP.Character and LP.Character:FindFirstChild("Punch")
                if eq then
                    eq:Activate()
                end
            end)
            task.wait()
        end
    end)
end

local function stopFastPunch()
    STATE.punchEnabled = false
    if STATE.punchThreadA then
        task.cancel(STATE.punchThreadA)
        STATE.punchThreadA = nil
    end
    if STATE.punchThreadB then
        task.cancel(STATE.punchThreadB)
        STATE.punchThreadB = nil
    end
    pcall(function()
        local eq = LP.Character and LP.Character:FindFirstChild("Punch")
        if eq then
            eq.Parent = LP.Backpack
        end
    end)
end

-- ROCK FARM
local function handleRock(rock, lh)
    pcall(function()
        rock.Size = Vector3.new(2, 1, 1)
        rock.Transparency = 1
        rock.CanCollide = false
        if rock:FindFirstChild("rockGui") then
            for _, v in pairs(rock.rockGui:GetChildren()) do
                v.Visible = false
            end
        end
        for _, pname in ipairs({"rockEmitter","hoopParticle","lavaParticle"}) do
            local p = rock:FindFirstChild(pname)
            if p then
                p:Destroy()
            end
        end
        rock.CFrame = lh.CFrame
        local tp = rock:FindFirstChild("TouchPart")
        if tp then
            tp.CFrame = lh.CFrame
        end
    end)
end

local function startRockFarm(rockDef)
    STATE.rockEnabled = true
    local neededDur = rockDef.req
    STATE.rockThread = task.spawn(function()
        while STATE.rockEnabled do
            task.wait()
            if not STATE.rockEnabled then break end
            pcall(function()
                if LP.Durability.Value < neededDur then return end
                local char = LP.Character
                if not char then return end
                local lh = char:FindFirstChild("LeftHand")
                local rh = char:FindFirstChild("RightHand")
                if not lh or not rh then return end
                for _, v in pairs(workspace.machinesFolder:GetDescendants()) do
                    if not STATE.rockEnabled then break end
                    if v.Name == "neededDurability" and v.Value == neededDur then
                        local rock = v.Parent:FindFirstChild("Rock")
                        if rock then
                            handleRock(rock, lh)
                            if not STATE.rockEnabled then break end
                            firetouchinterest(rock, rh, 0)
                            firetouchinterest(rock, rh, 1)
                            firetouchinterest(rock, lh, 0)
                            firetouchinterest(rock, lh, 1)
                            firetouchinterest(rock, rh, 0)
                            firetouchinterest(rock, rh, 1)
                            firetouchinterest(rock, lh, 0)
                            firetouchinterest(rock, lh, 1)
                            if not STATE.rockEnabled then break end
                            gettool()
                        end
                    end
                end
            end)
        end
    end)
end

local function stopRockFarm()
    STATE.rockEnabled = false
    if STATE.rockThread then
        task.cancel(STATE.rockThread)
        STATE.rockThread = nil
    end
end

-- AUTO REBIRTH
local function startRebirth()
    STATE.rebirthEnabled = true
    STATE.rebirthThread = task.spawn(function()
        while STATE.rebirthEnabled do
            pcall(function()
                ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
            end)
            task.wait(0.05)
        end
    end)
end

local function stopRebirth()
    STATE.rebirthEnabled = false
    if STATE.rebirthThread then
        task.cancel(STATE.rebirthThread)
        STATE.rebirthThread = nil
    end
end

-- AUTO SIZE 1
local function startSize1()
    STATE.sizeEnabled = true
    STATE.sizeThread = task.spawn(function()
        while STATE.sizeEnabled do
            pcall(function()
                if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
                    ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 1)
                end
            end)
            task.wait(0.05)
        end
    end)
end

local function stopSize1()
    STATE.sizeEnabled = false
    if STATE.sizeThread then
        task.cancel(STATE.sizeThread)
        STATE.sizeThread = nil
    end
end

-- SPEED
local function startSpeed()
    STATE.speedEnabled = true
    STATE.speedThread = task.spawn(function()
        while STATE.speedEnabled do
            pcall(function()
                if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
                    ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSpeed", STATE.speedValue)
                end
            end)
            task.wait(0.5)
        end
    end)
end

local function stopSpeed()
    STATE.speedEnabled = false
    if STATE.speedThread then
        task.cancel(STATE.speedThread)
        STATE.speedThread = nil
    end
end

-- ANTI AFK
local function startAntiAfk()
    if STATE.afkConn then return end
    STATE.afkConn = LP.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

local function stopAntiAfk()
    if STATE.afkConn then
        STATE.afkConn:Disconnect()
        STATE.afkConn = nil
    end
end

-- CLEANUP TOTAL
local function destroyAll()
    if STATE.closed then return end
    STATE.closed = true
    stopFastPunch()
    stopRockFarm()
    stopRebirth()
    stopSize1()
    stopSpeed()
    stopAntiAfk()
    if STATE.heartbeatConn then
        STATE.heartbeatConn:Disconnect()
        STATE.heartbeatConn = nil
    end
end

-- STATS
local leaderstats = LP:WaitForChild("leaderstats", 15)
local statStrength = leaderstats and leaderstats:WaitForChild("Strength", 15)
local statRebirths = leaderstats and leaderstats:WaitForChild("Rebirths", 15)
local statKills = leaderstats and leaderstats:WaitForChild("Kills", 15)
local statDura = LP:WaitForChild("Durability", 15)
local sessionStart = tick()
local startStrength = statStrength and statStrength.Value or 0
local startDura = statDura and statDura.Value or 0
local startRebirths = statRebirths and statRebirths.Value or 0
local startKills = statKills and statKills.Value or 0

-- UI — Carga e Inicialización de Interfaz (Elerium v2)
local Hub = loadstring(game:HttpGet("https://raw.githubusercontent.com/memejames/elerium-v2-ui-library//main/Library", true))():AddWindow("100% FAST GLITCH - PAID VERSION", {
    main_color = Color3.fromRGB(27, 2, 252),
    min_size = Vector2.new(600, 600),
    can_resize = false,
})

local tabFarm = Hub:AddTab("Farm")

-- Interfaz: Fast Punch
tabFarm:AddLabel("Fast Punch").TextSize = 20
tabFarm:AddSwitch("Fast Punch (100%)", function(on)
    if on then
        startFastPunch()
    else
        stopFastPunch()
        stopRockFarm()
        for _, setter in ipairs(STATE.rockSetters) do
            if setter then setter(false) end
        end
        STATE.rockIdx = nil
    end
end):Set(false)

-- Interfaz: Rock Farm
tabFarm:AddLabel("Rock Farm").TextSize = 20
tabFarm:AddLabel("Activa Fast Punch antes de seleccionar roca.")

for i, rockDef in ipairs(ROCKS) do
    local rd = rockDef
    local sw = tabFarm:AddSwitch(rd.label, function(on)
        if on then
            if not STATE.punchEnabled then
                StarterGui:SetCore("SendNotification", {
                    Title = "Fast Glitch 100%",
                    Text = "Activa Fast Punch primero.",
                    Duration = 3,
                })
                task.defer(function()
                    if STATE.rockSetters[i] then STATE.rockSetters[i](false) end
                end)
                return
            end
            if STATE.rockIdx and STATE.rockIdx ~= i then
                stopRockFarm()
                if STATE.rockSetters[STATE.rockIdx] then STATE.rockSetters[STATE.rockIdx](false) end
            end
            STATE.rockIdx = i
            startRockFarm(rd)
        else
            if STATE.rockIdx == i then
                stopRockFarm()
                STATE.rockIdx = nil
            end
        end
    end)
    STATE.rockSetters[i] = function(val)
        if sw and sw.Set then sw:Set(val) end
    end
end

-- Interfaz: Rebirth
tabFarm:AddLabel("Rebirth").TextSize = 20
tabFarm:AddSwitch("Auto Rebirth", function(on)
    if on then startRebirth() else stopRebirth() end
end):Set(false)

tabFarm:AddSwitch("Auto Size 1 (para rebirths)", function(on)
    if on then startSize1() else stopSize1() end
end):Set(false)

-- Interfaz: Speed
tabFarm:AddLabel("Speed").TextSize = 20
tabFarm:AddTextBox("Velocidad (default 120)", function(val)
    local n = tonumber(val:match("%d+"))
    if n then STATE.speedValue = n end
end)

tabFarm:AddSwitch("Set Speed", function(on)
    if on then startSpeed() else stopSpeed() end
end):Set(false)

-- Interfaz: Misc
local tabMisc = Hub:AddTab("Misc")
tabMisc:AddLabel("Misc").TextSize = 20

tabMisc:AddSwitch("Anti AFK", function(on)
    if on then startAntiAfk() else stopAntiAfk() end
end):Set(true)
startAntiAfk()

tabMisc:AddSwitch("Ocultar Partículas", function(on)
    for _, name in ipairs(PARTICLE_FRAMES) do
        local obj = ReplicatedStorage:FindFirstChild(name)
        if obj and obj:IsA("GuiObject") then
            obj.Visible = not on
        end
    end
end):Set(true)

-- Interfaz: Stats
local tabStats = Hub:AddTab("Stats")
tabStats:AddLabel("Tiempo en sesion").TextSize = 20
local lbTime = tabStats:AddLabel("0d 0h 0m 0s")
lbTime.TextSize = 18
tabStats:AddLabel("").TextSize = 10

tabStats:AddLabel("Ritmo proyectado").TextSize = 20
local lbStrPace = tabStats:AddLabel("Fuerza: - /Hour | - /Day")
lbStrPace.TextSize = 17
local lbDuraPace = tabStats:AddLabel("Durabilidad: - /Hour | - /Day")
lbDuraPace.TextSize = 17
local lbRebPace = tabStats:AddLabel("Rebirths: - /Hour | - /Day")
lbRebPace.TextSize = 17
tabStats:AddLabel("").TextSize = 10
tabStats:AddLabel("Stats actuales").TextSize = 20
