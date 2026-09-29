import "Turbine.UI"
import "src.Common"

local class = src.Common.class
local Category = Turbine.Gameplay.EffectCategory
local Window = Turbine.UI.Window

DebuffBar = class(Window)
function DebuffBar:Constructor(args)
  Window.Constructor(self)
  self:SetMouseVisible(false)
  -- Background is included in the morale bar so the layer/alpha blending looks better
  --self:SetBackground(args.background)
  local width, height = args.width, args.height
  self:SetSize(width, height)

  self.lights = {}
  local mode = Turbine.UI.BlendMode.AlphaBlend

  local wound = Turbine.UI.Control()
  wound:SetParent(self)
  wound:SetBackground(args.wound_img)
  wound:SetSize(width, height)
  wound:SetBlendMode(mode)
  wound:SetVisible(false)
  self.lights[Category.Wound] = wound

  local fear = Turbine.UI.Control()
  fear:SetParent(self)
  fear:SetBackground(args.fear_img)
  fear:SetSize(width, height)
  fear:SetBlendMode(mode)
  fear:SetVisible(false)
  self.lights[Category.Fear] = fear

  local disease = Turbine.UI.Control()
  disease:SetParent(self)
  disease:SetBackground(args.disease_img)
  disease:SetSize(width, height)
  disease:SetBlendMode(mode)
  disease:SetVisible(false)
  self.lights[Category.Disease] = disease

  local poison = Turbine.UI.Control()
  poison:SetParent(self)
  poison:SetBackground(args.poison_img)
  poison:SetSize(width, height)
  poison:SetBlendMode(mode)
  poison:SetVisible(false)
  self.lights[Category.Poison] = poison

  if args.corruption_img then
    local corruption = Turbine.UI.Control()
    corruption:SetParent(self)
    corruption:SetBackground(args.corruption_img)
    corruption:SetSize(width, height)
    corruption:SetBlendMode(mode)
    corruption:SetVisible(false)
    self.lights[Category.Corruption] = corruption
  end
end

-- @param effects {Turbine.Gameplay.EffectList}
-- @param args.Index {number | nil} Position of the new effect, if any
function DebuffBar:update(effects, args)
  local new_effect = args and args.Index and not args.Effect and effects:Get(args.Index)
  if new_effect then
    if new_effect:IsCurable() then
      local el = self.lights[new_effect:GetCategory()]
      if el then el:SetVisible(true) end
    end
  else
    -- If an effect was removed then we need to check the whole list. You might
    -- have another wound/etc remaining.
    local flagged = {}
    for i = 1, effects:GetCount() do
      local effect = effects:Get(i)
      local cat = effect:GetCategory()
      if effect:IsCurable() then
        flagged[cat] = true
      end
    end
    for cat, el in pairs(self.lights) do
      el:SetVisible(flagged[cat])
    end
  end
end
