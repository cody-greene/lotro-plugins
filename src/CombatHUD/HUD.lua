import "Turbine.UI"
import "Turbine.Gameplay"
import "src.CombatHUD.DebuffBar"
import "src.CombatHUD.VerticalFillbar"
import "src.Common.EventManager"
import "src.Common"

local EventManager = src.Common.EventManager
local class = src.Common.class
local bind = src.Common.bind
local LABEL_MARGIN = 5

local function get_morale_text(actor)
  return string.format("%i/%i", actor:GetMorale(), actor:GetBaseMaxMorale())
end

local function get_power_text(actor)
  return string.format("%i/%i", actor:GetPower(), actor:GetBaseMaxPower())
end

local function get_wratch_text(actor)
  return string.format("%i/%i", actor:GetClassAttributes():GetWrath(), 100)
end

-- @param actor {Turbine.Gameplay.Actor}
local function get_morale_pct(actor)
  local cur = actor:GetMorale()
  local max_actual = actor:GetMaxMorale()
  local max_ideal = actor:GetBaseMaxMorale()
  local bonus_cur = actor:GetTemporaryMorale()
  return {
    actual = cur / max_ideal,
    reserved = (max_ideal - max_actual) / max_ideal,
    bonus = math.min(bonus_cur / max_ideal, 1),
  }
end

-- @param actor {Turbine.Gameplay.Actor}
local function get_power_pct(actor)
  local cur = actor:GetPower()
  local max_actual = actor:GetMaxPower()
  local max_ideal = actor:GetBaseMaxPower()
  local bonus_cur = actor:GetTemporaryPower()
  return {
    actual = cur / max_ideal,
    reserved = (max_ideal - max_actual) / max_ideal,
    bonus = math.min(bonus_cur / max_ideal, 1),
  }
end

-- @param actor {Turbine.Gameplay.Actor}
local function get_wrath_pct(actor)
  local cur = actor:GetClassAttributes():GetWrath()
  return {
    actual = cur / 100,
    reserved = 0,
    bonus = 0,
  }
end

HUD = class(Turbine.UI.Window)
function HUD:Constructor(player, config)
  Turbine.UI.Window.Constructor(self)

  local asset_pack = "1440"
  if (config.asset_pack == "1080") or (config.asset_pack == "auto" and Turbine.UI.Display.GetHeight() < 1440) then
    asset_pack = "1080"
  end
  import("src.CombatHUD.res." .. asset_pack)
  local assets = src.CombatHUD.res[asset_pack]
  local font_size = assets.font_size
  local font_key = assets.font_face .. font_size
  local font = Turbine.UI.Lotro.Font[font_key]
  assert(font ~= nil, string.format("Font does not exist; asset_pack=%s, font=%s", asset_pack, font_key))

  self:SetMouseVisible(false)
  self:SetSize(assets.width, assets.height)
  self.player = player
  self.player_callbacks = EventManager()
  self.target_callbacks = EventManager()

  -- Bind self so we can use this fn as a callback
  self.schedule_update = function ()
    self.update_scheduled = true
  end

  local morale = VerticalFillbar(assets.player_morale)
  morale:SetParent(self)
  morale:SetFill(get_morale_pct(player))
  morale:SetColor(config.morale_colors)
  morale:SetVisible(true)
  self.morale = morale

  if config.enable_player_power then
    local power = VerticalFillbar(assets.player_power)
    power:SetParent(self)
    if player:GetClass() == Turbine.Gameplay.Class.Beorning then
      self.get_player_power_pct = get_wrath_pct
      self.player_callbacks:add(player:GetClassAttributes(), "WrathChanged", self.schedule_update)
    else
      self.get_player_power_pct = get_power_pct
      self.player_callbacks:add(player, "PowerChanged", self.schedule_update)
      self.player_callbacks:add(player, "MaxPowerChanged", self.schedule_update)
      self.player_callbacks:add(player, "BaseMaxPowerChanged", self.schedule_update)
    end
    power:SetFill(self.get_player_power_pct(player))
    power:SetVisible(true)
    if player:GetClass() == Turbine.Gameplay.Class.Beorning then
      power:SetColor(config.wrath_colors)
    else
      power:SetColor(config.power_colors)
    end
    self.power = power
  end

  self.player_callbacks:add(player, "MoraleChanged", self.schedule_update)
  self.player_callbacks:add(player, "MaxMoraleChanged", self.schedule_update)
  self.player_callbacks:add(player, "BaseMaxMoraleChanged", self.schedule_update)
  self.player_callbacks:add(player, "TargetChanged", function (player, args)
    self:change_target(player:GetTarget())
  end)
  self.player_callbacks:add(player, "InCombatChanged", bind(self.maybe_toggle_combat, self))

  local player_debuffs = DebuffBar(assets.player_debuffs)
  player_debuffs:SetParent(self)
  player_debuffs:SetVisible(true)
  self.player_debuffs = player_debuffs
  local player_effects = player:GetEffects()
  local update_player_debuffs = bind(player_debuffs.update, player_debuffs)
  self.player_callbacks:add(player_effects, "EffectsCleared", update_player_debuffs)
  self.player_callbacks:add(player_effects, "EffectAdded", update_player_debuffs)
  self.player_callbacks:add(player_effects, "EffectRemoved", update_player_debuffs)

  local target_morale = VerticalFillbar(assets.target_morale)
  target_morale:SetParent(self)
  target_morale:SetPosition(self:GetWidth() - target_morale:GetWidth(), 0)
  target_morale:SetColor(config.morale_colors)
  self.target_morale = target_morale

  if config.enable_target_power then
    local target_power = VerticalFillbar(assets.target_power)
    target_power:SetParent(self)
    target_power:SetPosition(self:GetWidth() - target_power:GetWidth(), 0)
    target_power:SetColor(config.power_colors)
    self.target_power = target_power
  end

  local target_debuffs = DebuffBar(assets.target_debuffs)
  target_debuffs:SetParent(self)
  target_debuffs:SetPosition(self:GetWidth() - target_debuffs:GetWidth(), 0)
  self.target_debuffs = target_debuffs
  self.update_target_debuffs = bind(target_debuffs.update, target_debuffs)

  if config.enable_player_morale_text then
    local label = Turbine.UI.Label()
    label:SetMouseVisible(false)
    label:SetParent(self)
    label:SetPosition(morale:GetWidth() + LABEL_MARGIN, assets.height - font_size)
    label:SetSize(assets.width - morale:GetWidth()*2, font_size)
    label:SetFont(font)
    label:SetText(get_morale_text(player))
    self.player_morale_label = label
  end

  if config.enable_player_power_text and config.enable_player_power then
    local label = Turbine.UI.Label()
    label:SetMouseVisible(false)
    label:SetParent(self)
    label:SetPosition(morale:GetWidth() + LABEL_MARGIN, assets.height - font_size*2 - LABEL_MARGIN)
    label:SetSize(assets.width - morale:GetWidth()*2, font_size)
    label:SetFont(font)
    label:SetText(get_power_text(player))
    self.player_power_label = label
  end

  if config.enable_target_morale_text then
    local label = Turbine.UI.Label()
    label:SetMouseVisible(false)
    label:SetVisible(false)
    label:SetParent(self)
    label:SetSize(assets.width - morale:GetWidth()*2, font_size)
    label:SetPosition(assets.width - label:GetWidth() - (morale:GetWidth() + LABEL_MARGIN), assets.height - font_size)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.TopRight)
    label:SetFont(font)
    --label:SetText(get_morale_text(target))
    self.target_morale_label = label
  end

  if config.enable_target_power_text and config.enable_target_power then
    local label = Turbine.UI.Label()
    label:SetMouseVisible(false)
    label:SetVisible(false)
    label:SetParent(self)
    label:SetSize(assets.width - morale:GetWidth()*2, font_size)
    label:SetPosition(assets.width - label:GetWidth() - (morale:GetWidth() + LABEL_MARGIN), assets.height - font_size*2 - LABEL_MARGIN)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.TopRight)
    label:SetFont(font)
    --label:SetText(get_power_text(target))
    self.target_power_label = label
  end

  self:SetOpacity(config.opacity)
  self:change_target(player:GetTarget())
  self:set_visible_forced(config.always_show)
  self:maybe_toggle_combat(player)
end

function HUD:change_target(target)
  self.target_callbacks:clear()
  self:set_target_visible(false)
  if not class.is_a(target, Turbine.Gameplay.Actor) or target == self.player then
    self.target = nil
    return -- Not an interesting target
  end
  self.target = target
  self.target_morale:SetFill(get_morale_pct(target))
  self.target_debuffs:update(target:GetEffects())
  if self.target_morale_label then
    self.target_morale_label:SetText(get_morale_text(target))
  end
  -- New targets (unfortunately) often report 0 morale until the MoraleChangd
  -- event some time later. Reselecting this target will then report the correct
  -- values on the first try. We don't want to show the target-side of the HUD
  -- until we have useful data.
  local has_morale = target:GetMorale() > 0
  -- Can't read the Wrath value of another player; player:GetClassAttributes():GetWrath()
  -- exists only on LocalPlayer. So we hide the resource bar for other Beornings.
  local is_beorn = class.is_a(target, Turbine.Gameplay.Player) and target:GetClass() == Turbine.Gameplay.Class.Beorning
  if not is_beorn and self.target_power then
    self.target_power:SetFill(get_power_pct(target))
    if self.target_power_label then
      self.target_power_label:SetText(get_power_text(target))
    end
    self.target_callbacks:add(target, "PowerChanged", self.schedule_update)
    self.target_callbacks:add(target, "MaxPowerChanged", self.schedule_update)
    self.target_callbacks:add(target, "BaseMaxPowerChanged", self.schedule_update)
  end
  self:set_target_visible(has_morale, is_beorn)
  self.target_callbacks:add(target, "MoraleChanged", function()
    self.schedule_update()
    local has_morale = target:GetMorale() > 0
    if has_morale then
      self:set_target_visible(has_morale, is_beorn)
    end
  end)
  self.target_callbacks:add(target, "MaxMoraleChanged", self.schedule_update)
  self.target_callbacks:add(target, "BaseMaxMoraleChanged", self.schedule_update)
  local effects = target:GetEffects()
  self.target_callbacks:add(effects, "EffectAdded", self.update_target_debuffs)
  self.target_callbacks:add(effects, "EffectRemoved", self.update_target_debuffs)
end

function HUD:SetVisible(val)
  val = self.force_visible or val
  self:SetWantsUpdates(val)
  Turbine.UI.Window.SetVisible(self, val)
end

function HUD:set_visible_forced(val)
  self.force_visible = val
  self:SetVisible(val)
end

function HUD:set_target_visible(val, hide_power)
  self.target_debuffs:SetVisible(val)
  self.target_morale:SetVisible(val)
  if self.target_morale_label then
    self.target_morale_label:SetVisible(val)
  end
  if self.target_power then
    self.target_power:SetVisible(val and not hide_power)
  end
  if self.target_power_label then
    self.target_power_label:SetVisible(val and not hide_power)
  end
end

function HUD:SetOpacity(val)
  Turbine.UI.Window.SetOpacity(self, val)
  self.morale:SetOpacity(val)
  self.target_morale:SetOpacity(val)
  if self.power then
    self.power:SetOpacity(val)
  end
  if self.target_power then
    self.target_power:SetOpacity(val)
  end
end

-- Fired every frame when WantsUpdates is enabled.
function HUD:Update()
  if not self.update_scheduled then
    return -- No update this tick; avoid unnecessary work
  end
  self.update_scheduled = false
  -- If we simply change the fill in the "MoraleChanged" event then it looks
  -- janky; you can see each individual window adjustment. I suspect this is
  -- because UI updates are actually batched together when requested here,
  -- instead, since "Update" runs every frame.
  local player = self.player
  local target = self.target
  self.morale:SetFill(get_morale_pct(player))
  if self.player_morale_label then
    self.player_morale_label:SetText(get_morale_text(player))
  end
  if self.power then
    self.power:SetFill(self.get_player_power_pct(player))
  end
  if self.player_power_label then
    self.player_power_label:SetText(get_power_text(player))
  end
  if target then
    self.target_morale:SetFill(get_morale_pct(target))
    if self.target_morale_label then
      self.target_morale_label:SetText(get_morale_text(target))
    end
    if self.target_power then
      self.target_power:SetFill(get_power_pct(target))
      if self.target_power_label then
        self.target_power_label:SetText(get_power_text(target))
      end
    end
  end

  if not player:IsInCombat() then
    self:maybe_toggle_health()
  end
end

function HUD:maybe_toggle_health()
  local full_health = self.player:GetMaxMorale() - self.player:GetMorale() <= 1
  self:SetVisible(not full_health)
end

function HUD:maybe_toggle_combat(player)
  if player:IsInCombat() then
    self:SetVisible(true)
  else
    self:maybe_toggle_health()
  end
end

function HUD:destroy()
  self.player_callbacks:clear()
  self.target_callbacks:clear()
  self:set_visible_forced(false)
end
