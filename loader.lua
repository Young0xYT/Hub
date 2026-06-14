-- Young0x Hub 

local RAW = "https://raw.githubusercontent.com/Young0xYT/Hub/refs/heads/main/loader.lua"

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

-- Medidas del Hub (Puto el que lee)
local CARD_W = 560      -- ancho
local CARD_H = 320      -- alto 
local HEADER_H = 68
local LIST_TOP = HEADER_H + 4
local LIST_BOTTOM_PADDING = 6
local ROW_H = 58
local ROW_GAP = 4

local gui = Instance.new("ScreenGui")
gui.Name = "HubGui"
