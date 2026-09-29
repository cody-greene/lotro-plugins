import "Turbine"
import "Turbine.UI"
import "Turbine.Gameplay"
import "src.BuffTimer.BuffTimers"

config = {
  buffs = {
    "Battle-readied", -- Empowers next Devastating Blow or Pressing Attack
    "Battle-hardened", -- Empowers next Blade of Elendil
    {"Elendil's Boon", "Elendil's Favour"}, -- Empowers next Shadow's Lament / Valiant Strike
    "Enemy Defeat Response", -- Empowers next Rallying Cry or Routing Cry
  },
}

local HUD_WIDTH = 710
local OFFSET_X = 144
local OFFSET_Y = 64
local player = Turbine.Gameplay.LocalPlayer.GetInstance()
local pkg = {
  name = plugin:GetName(),
  version = plugin:GetVersion(),
}

timers = BuffTimers(player:GetEffects(), config.buffs)
timers:SetPosition(
  (Turbine.UI.Display.GetWidth()/2 - HUD_WIDTH/2) + OFFSET_X,
  Turbine.UI.Display.GetHeight()/2 - OFFSET_Y
)

-- Event fired when a plugin's main package has finished loading.
function plugin:Load()
  timers:SetVisible(true)
  Turbine.Shell.WriteLine(pkg.name .. " v" .. pkg.version)
end

-- Event fired before a plugin is unloaded.
function plugin:Unload()
  timers:destroy()
end
