import "Turbine"
import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"

import "src.CombatHUD.HUD"
import "src.CombatHUD.i18n"
import "src.Common"
import "src.Common.SelectBox"
import "src.Common.Slider"

local t = src.CombatHUD.i18n
local class = src.Common.class
local find_index = src.Common.find_index
local merge = src.Common.merge_deep
local Slider = src.Common.Slider
local SelectBox = src.Common.SelectBox
local DATA_KEY = "CombatHUD"

DefaultConfig = class({
  asset_pack = "auto",
  opacity = 0.90,
  enable_player_power = true,
  enable_target_power = true,
  enable_player_morale_text = true,
  enable_player_power_text = false,
  enable_target_morale_text = true,
  enable_target_power_text = false,
  always_show = false,
  morale_colors = {
    actual={
      {0.50, {0, 200/255, 0}},
      {0.25, {200/255, 200/255, 0}},
      {0.00, {200/255, 100/255, 0}},
    },
    reserved={200/255, 0, 0},
    bonus={0, 0, 0},
  },
  power_colors = {
    actual={0, 0, 200/255},
    reserved={200/255, 0, 0},
    bonus={0, 0, 0},
  },
  wrath_colors = {
    actual={200/255, 0, 0},
    reserved={0, 0, 0},
    bonus={0, 0, 0},
  },
})

function DefaultConfig:load()
  local saved_config = Turbine.PluginData.Load(Turbine.DataScope.Account, DATA_KEY)
  if saved_config then
    merge(self, saved_config)
  end
end

function DefaultConfig:saveAsync(cb)
  -- Only the modified values are saved to disk because we're using prototype inheritance
  -- Will save to
  --   C:\users\$USER\My Documents\The Lord of the Rings Online\PluginData\$ACCOUNT\AllServers\$KEY.plugindata
  --   (linux) /home/$USER/.steam/root/steamapps/compatdata/212500/pfx/drive_c/users/steamuser/My Documents/...
  -- These are just lua files containing the stringified config table
  Turbine.PluginData.Save(Turbine.DataScope.Account, DATA_KEY, self, cb)
end

local config = DefaultConfig()
config:load()

local player = Turbine.Gameplay.LocalPlayer.GetInstance()
local pkg = {
  name = plugin:GetName(),
  version = plugin:GetVersion(),
}

hud = nil
local function setup()
  if hud then
    hud:destroy()
  end
  hud = HUD(player, config)
  hud:SetPosition(
    Turbine.UI.Display.GetWidth()/2 - hud:GetWidth()/2,
    Turbine.UI.Display.GetHeight()/2 - hud:GetHeight()/2
  )

  -- Scaling currently interferes with layer alpha blending and makes text
  -- pretty blurry (when upscaling). So we're using separate pre-scaled assets instead.

  -- Need to enable scaling first, then set the origin (relative to the
  -- window's current position), then set the desired scale. Otherwise the origin
  -- is ignored.
  --hud:SetScale(1)
  --hud:SetScalingOriginPoint(hud:GetWidth()/2, hud:GetHeight()/2)
  --hud:SetScale(0.75)
end

setup()

-- Event fired when a plugin's main package has finished loading.
function plugin:Load()
  Turbine.Shell.WriteLine(pkg.name .. " v" .. pkg.version)
end

-- Event fired before a plugin is unloaded.
function plugin:Unload()
  if hud then
    hud:destroy()
  end
end

function plugin:GetOptionsPanel()
  return OptionsPanel()
end

local MARGIN = 5
local PADDING = 10

OptionsPanel = class(Turbine.UI.Control)
function OptionsPanel:Constructor()
  Turbine.UI.Control.Constructor(self)

  local cb_force_visible = Turbine.UI.Lotro.CheckBox()
  cb_force_visible:SetChecked(config.always_show)
  cb_force_visible:SetText(t.ALWAYS_SHOW)
  cb_force_visible:SetSize(300, 16)
  cb_force_visible.CheckedChanged = function(self)
    local val = self:IsChecked()
    config.always_show = val
    hud:set_visible_forced(val)
    config:saveAsync()
  end

  local cb_player_power_text = Turbine.UI.Lotro.CheckBox()
  cb_player_power_text:SetChecked(config.enable_player_power_text)
  cb_player_power_text:SetEnabled(config.enable_player_power)
  cb_player_power_text:SetText(t.SHOW_PLAYER_POWER_TEXT)
  cb_player_power_text:SetSize(300, 16)
  cb_player_power_text.CheckedChanged = function(self)
    local val = self:IsChecked()
    config.enable_player_power_text = val
    setup()
    config:saveAsync()
  end

  local cb_player_power = Turbine.UI.Lotro.CheckBox()
  cb_player_power:SetChecked(config.enable_player_power)
  cb_player_power:SetText(t.SHOW_PLAYER_POWER)
  cb_player_power:SetSize(300, 16)
  cb_player_power.CheckedChanged = function(self)
    local val = self:IsChecked()
    cb_player_power_text:SetEnabled(val)
    config.enable_player_power = val
    setup()
    config:saveAsync()
  end

  local cb_player_morale_text = Turbine.UI.Lotro.CheckBox()
  cb_player_morale_text:SetChecked(config.enable_player_morale_text)
  cb_player_morale_text:SetText(t.SHOW_PLAYER_MORALE_TEXT)
  cb_player_morale_text:SetSize(300, 16)
  cb_player_morale_text.CheckedChanged = function(self)
    local val = self:IsChecked()
    config.enable_player_morale_text = val
    setup()
    config:saveAsync()
  end

  local cb_target_power_text = Turbine.UI.Lotro.CheckBox()
  cb_target_power_text:SetChecked(config.enable_target_power_text)
  cb_target_power_text:SetEnabled(config.enable_target_power)
  cb_target_power_text:SetText(t.SHOW_TARGET_POWER_TEXT)
  cb_target_power_text:SetSize(300, 16)
  cb_target_power_text.CheckedChanged = function(self)
    local val = self:IsChecked()
    config.enable_target_power_text = val
    setup()
    config:saveAsync()
  end

  local cb_target_power = Turbine.UI.Lotro.CheckBox()
  cb_target_power:SetChecked(config.enable_target_power)
  cb_target_power:SetText(t.SHOW_TARGET_POWER)
  cb_target_power:SetSize(300, 16)
  cb_target_power.CheckedChanged = function(self)
    local val = self:IsChecked()
    cb_target_power_text:SetEnabled(val)
    config.enable_target_power = val
    setup()
    config:saveAsync()
  end

  local cb_target_morale_text = Turbine.UI.Lotro.CheckBox()
  cb_target_morale_text:SetChecked(config.enable_target_morale_text)
  cb_target_morale_text:SetText(t.SHOW_TARGET_MORALE_TEXT)
  cb_target_morale_text:SetSize(300, 16)
  cb_target_morale_text.CheckedChanged = function(self)
    local val = self:IsChecked()
    config.enable_target_morale_text = val
    setup()
    config:saveAsync()
  end

  local opacity_label = Turbine.UI.Label()
  opacity_label:SetSize(200, 16)
  opacity_label:SetFont(Turbine.UI.Lotro.Font.Verdana16)
  opacity_label:SetText(string.format("%s (%.0f%%):", t.OPACITY, config.opacity * 100))

  local opacity_slider = Slider(0, 1)
  opacity_slider:SetWidth(200)
  opacity_slider:set_value(config.opacity)
  opacity_slider.on_change = function(_, value)
    if math.abs(value - config.opacity) < 0.01 then
      return -- No meaningful change
    end
    opacity_label:SetText(string.format("%s (%.0f%%):", t.OPACITY, value * 100))
    config.opacity = value
    hud:SetOpacity(value)
    config:saveAsync()
  end

  local size_selector_label = Turbine.UI.Label()
  size_selector_label:SetFont(Turbine.UI.Lotro.Font.Verdana16)
  size_selector_label:SetTextAlignment(Turbine.UI.ContentAlignment.TopRight)
  size_selector_label:SetText(t.HUD_SIZE)
  size_selector_label:SetWidth(60)
  local size_selector = SelectBox({
    {label=t.HUD_SIZE_AUTO, value="auto"},
    {label="1440", value="1440"},
    {label="1080", value="1080"},
  }, function (item) return item.label end)
  size_selector:SetSelectedIndex(find_index(size_selector.options, function (item)
    return item.value == config.asset_pack
  end))
  size_selector:SetWidth(200)
  size_selector.on_change = function(_, selected, index)
    if config.asset_pack == selected.value then return end
    config.asset_pack = selected.value
    setup()
    config:saveAsync()
  end

  self:add_row(cb_force_visible)
  self:add_row(cb_player_power)
  self:add_row(cb_player_power_text)
  self:add_row(cb_player_morale_text)
  self:add_row(cb_target_power)
  self:add_row(cb_target_power_text)
  self:add_row(cb_target_morale_text)
  self:add_row(opacity_label)
  self:add_row(opacity_slider)
  self:add_row(size_selector_label, size_selector)

  self:resize()
end

function OptionsPanel:add_row(element, ...)
  local controls = self:GetControls()
  local count = controls:GetCount()
  local y = MARGIN
  if count > 0 then
    local previous_element = controls:Get(controls:GetCount())
    y = previous_element:GetTop() + previous_element:GetHeight() + PADDING
  end
  element:SetParent(self)
  element:SetPosition(MARGIN, y)
  local x = MARGIN + element:GetWidth()
  for i, el in pairs({...}) do
    el:SetParent(self)
    el:SetPosition(x + PADDING, y)
    x = x + PADDING + el:GetWidth()
  end
end

function OptionsPanel:resize()
  local total_width = 0
  local total_height = 0
  local controls = self:GetControls()
  local ctl
  for i = 1, controls:GetCount() do
    ctl = controls:Get(i)
    total_width = math.max(ctl:GetWidth() + ctl:GetLeft(), total_width)
    total_height = math.max(ctl:GetHeight() + ctl:GetTop(), total_height)
  end
  self:SetSize(total_width, total_height)
end
