import "Turbine"
import "Turbine.UI"
import "Turbine.UI.Lotro"
import "src.Common"
import "src.Common.EventManager"

local class = src.Common.class
local EventManager = src.Common.EventManager
local log = src.Common.log
local bind = src.Common.bind
local FONT_HEIGHT = 32

BuffTimers = class(Turbine.UI.Window)

-- @param effectlist {Turbine.Gameplay.EffectList}
-- @param names {string | list[string]}
function BuffTimers:Constructor(effectlist, names)
  Turbine.UI.Window.Constructor(self)
  self:SetMouseVisible(false)
  self:SetSize(100, 33*5)

  -- All timers {number} -> {EffectTimer}
  self.timer_by_slot = {}
  for i, name in ipairs(names) do
    local timer = EffectTimer()
    timer:SetParent(self)
    timer:SetPosition(0, 33*(i-1))
    self.timer_by_slot[i] = timer
  end

  -- Active timers, by effect id {number} -> {EffectTimer}
  self.timer_by_id = {}

  -- Reverse lookup: effect_name {string] -> slot {number}
  self.effect_to_slot = {}
  local valtype
  for slot, name in ipairs(names) do
    valtype = type(name)
    if valtype == "string" then
      self.effect_to_slot[name] = slot
    elseif valtype == "table" then
      for i, v in ipairs(name) do
        self.effect_to_slot[v] = slot
      end
    end
  end

  self.count = 0
  self.callbacks = EventManager()

  self.callbacks:add(effectlist, "EffectAdded", bind(self.add, self))
  self.callbacks:add(effectlist, "EffectRemoved", bind(self.remove, self))
  self.callbacks:add(effectlist, "EffectsCleared", bind(self.clear, self))
end

--[[
  -- @param effects {Turbine.Gameplay.EffectList}
  -- @param args.Index {number} 1 2 3 ...
]]
function BuffTimers:add(effects, args)
  local effect = effects:Get(args.Index)
  local name = effect:GetName()
  local slot = self.effect_to_slot[name]
  if slot == nil then
    return -- Not interested
  end
  local timer = self.timer_by_slot[slot]
  if timer.effect then
    -- Replacing/refreshing an effect
    self.timer_by_id[timer.effect:GetID()] = nil
  else
    self.count = self.count + 1
    self:SetWantsUpdates(true)
  end
  timer:set(effect)
  self.timer_by_id[effect:GetID()] = timer
end

--[[
  -- @param effects {Turbine.Gameplay.EffectList}
  -- @param args.Effect {Turbine.Gameplay.Effect | nil}
]]
function BuffTimers:remove(effects, args)
  local effect = args.Effect
  if not effect then
    return
  end
  local id = effect:GetID()
  local timer = self.timer_by_id[id]
  if timer then
    self.timer_by_id[id] = nil
    timer:set(nil)
    self.count = self.count - 1
    if self.count == 0 then
      self:SetWantsUpdates(false)
    end
  end
end

function BuffTimers:clear()
  self.SetWantsUpdates(false)
  self.count = 0
  for _, timer in pairs(self.timer_by_id) do
    timer:set(nil)
  end
  self.timer_by_id = {}
end

function BuffTimers:Update()
  local time = Turbine.Engine.GetGameTime()
  for _, timer in pairs(self.timer_by_id) do
    timer:Update(time)
  end
end

function BuffTimers:destroy()
  self.callbacks:clear()
end

EffectTimer = class(Turbine.UI.Control)
function EffectTimer:Constructor(effect)
  Turbine.UI.Control.Constructor(self)
  self:SetMouseVisible(false)
  self:SetVisible(false)
  self:SetSize(170, FONT_HEIGHT) -- TODO 162

  self.icon = Turbine.UI.Control()
  self.icon:SetMouseVisible(false)
  self.icon:SetParent(self)
  self.icon:SetSize(32, 32)

  self.text = Turbine.UI.Label()
  self.text:SetMouseVisible(false)
  self.text:SetParent(self)
  self.text:SetSize(FONT_HEIGHT*4, FONT_HEIGHT)
  self.text:SetFont(Turbine.UI.Lotro.Font.BookAntiqua32)
  self.text:SetPosition(32 + 2, 0)
end

-- @param effect {Turbine.Gameplay.Effect | nil}
function EffectTimer:set(effect)
  if effect then
    self.effect = effect
    self.icon:SetBackground(effect:GetIcon())
    self.text:SetText(string.format("%4.1f", effect:GetDuration()))
    self:SetVisible(true)
  else
    self.effect = nil
    self:SetVisible(false)
  end
end

-- @param gametime {number}
function EffectTimer:Update(gametime)
  local elapsed = gametime - self.effect:GetStartTime()
  local remaining = self.effect:GetDuration() - elapsed
  self.text:SetText(string.format("%4.1f", math.max(0, remaining)))
end
