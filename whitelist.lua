-- ============================================================
--  Young0x Hub — Whitelist
--  github.com/Young0xYT/Hub
--
--  Para agregar un usuario:
--  1. Agrega su UserId de Roblox
--  2. Ejemplo: [123456789] = true,
--  3. NO agregues UserIds de otros sin permiso
--  4. Mantén el formato exacto
--
--  Si el archivo no existe o hay error:
--  - El loader mostrará un mensaje de error
--  - No se permitirá el acceso
-- ============================================================

local success, whitelist = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Young0xYT/Hub/main/whitelist.lua",
        true
    ))()
end)

if not success or not whitelist then
    -- Crear GUI de error si falla la whitelist
    local errorGui = Instance.new("ScreenGui")
    errorGui.Name = "WhitelistErrorGui"
    errorGui.ResetOnSpawn = false
    errorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    errorGui.IgnoreGuiInset = true
    errorGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local errorFrame = Instance.new("Frame")
    errorFrame.Size = UDim2.new(0, 300, 0, 150)
    errorFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    errorFrame.BackgroundColor3 = Color3.fromRGB(20, 19, 32)
    errorFrame.BorderSizePixel = 0
    errorFrame.ZIndex = 10
    errorFrame.Parent = errorGui

    local errorCorner = Instance.new("UICorner")
    errorCorner.CornerRadius = UDim.new(0, 16)
    errorCorner.Parent = errorFrame

    local errorLabel = Instance.new("TextLabel")
    errorLabel.Text = "⚠️ Error en whitelist\nContactá al desarrollador."
    errorLabel.Font = Enum.Font.GothamBold
    errorLabel.TextSize = 16
    errorLabel.TextColor3 = Color3.fromRGB(235, 230, 255)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Size = UDim2.new(1, -32, 1, -32)
    errorLabel.Position = UDim2.new(0, 16, 0, 16)
    errorLabel.TextXAlignment = Enum.TextXAlignment.Center
    errorLabel.TextYAlignment = Enum.TextYAlignment.Center
    errorLabel.ZIndex = 11
    errorLabel.Parent = errorFrame

    warn("[Young0x Hub] Error al cargar whitelist.lua")
    return false
end

return whitelist
