import "Turbine.UI"
import "src.Common"

local class = src.Common.class
local map = src.Common.map
local Color = Turbine.UI.Color
local Window = Turbine.UI.Window
local Control = Turbine.UI.Control

VerticalFillbar = class(Control)

--[[
  @param args.background {string} Path to a background image
  @param args.mask {string} Path to a image for the fill mask
  @param args.width {number}
  @param args.height {number}
]]
function VerticalFillbar:Constructor(args)
  Control.Constructor(self)
  self:SetMouseVisible(false)

  self.bg = Window()
  self.bg:SetParent(self)
  self.bg:SetVisible(true)
  self.bg:SetMouseVisible(false)
  self.bg:SetBackground(args.background)

  -- Fills from bottom to top
  self.fill = Window()
  self.fill:SetParent(self)
  self.fill:SetVisible(true)
  self.fill:SetMouseVisible(false)
  self.mask = Turbine.UI.Control()
  self.mask:SetParent(self.fill)
  self.mask:SetMouseVisible(false)
  self.mask:SetBackground(args.mask)
  self.overlay = Turbine.UI.Control()
  self.overlay:SetParent(self.mask)
  self.overlay:SetMouseVisible(false)
  self.overlay:SetBackColorBlendMode(Turbine.UI.BlendMode.Overlay)

  -- Fills from top to bottom
  self.fill_reserved = Window()
  self.fill_reserved:SetParent(self)
  self.fill_reserved:SetVisible(true)
  self.fill_reserved:SetMouseVisible(false)
  self.mask_reserved = Turbine.UI.Control()
  self.mask_reserved:SetParent(self.fill_reserved)
  self.mask_reserved:SetMouseVisible(false)
  self.mask_reserved:SetBackground(args.mask)
  self.overlay_reserved = Turbine.UI.Control()
  self.overlay_reserved:SetParent(self.mask_reserved)
  self.overlay_reserved:SetMouseVisible(false)
  self.overlay_reserved:SetBackColorBlendMode(Turbine.UI.BlendMode.Overlay)

  -- Fills from bottom to top
  self.fill_bonus = Window()
  self.fill_bonus:SetParent(self)
  self.fill_bonus:SetVisible(true)
  self.fill_bonus:SetMouseVisible(false)
  self.mask_bonus = Turbine.UI.Control()
  self.mask_bonus:SetParent(self.fill_bonus)
  self.mask_bonus:SetMouseVisible(false)
  self.mask_bonus:SetBackground(args.mask_bonus or args.mask)
  self.overlay_bonus = Turbine.UI.Control()
  self.overlay_bonus:SetParent(self.mask_bonus)
  self.overlay_bonus:SetMouseVisible(false)
  self.overlay_bonus:SetBackColorBlendMode(Turbine.UI.BlendMode.Overlay)

  self.colors = {}
  self:SetSize(args.width, args.height)
  self:SetFill({actual=0, reserved=0, bonus=0})
end

function VerticalFillbar:SetOpacity(val)
  --Control.SetOpacity(self, val)
  --self.bg:SetOpacity(val)
  self.fill:SetOpacity(val)
  self.fill_reserved:SetOpacity(val)
  self.fill_bonus:SetOpacity(val)
end

--[[
  @param pct.actual {number} Between 0 - 1
  @param pct.reserved {number}
  @param pct.bonus {number}
]]
function VerticalFillbar:SetFill(pct)
  local height = self:GetHeight()
  local distance = (1 - pct.actual) * height
  self.fill:SetTop(distance)
  self.mask:SetTop(-distance)

  self.fill_reserved:SetHeight(pct.reserved * height)

  distance = (1 - pct.bonus) * height
  self.mask_bonus:SetTop(-distance)
  self.fill_bonus:SetTop(distance)

  -- Change color at fill thresholds e.g. 50% and 25%
  for _, item in ipairs(self.colors) do
    local mark, color = unpack(item)
    if pct.actual >= mark then
      self.overlay:SetBackColor(color)
      break
    end
  end
end

--[[
  @param colors.actual {list[number] | list[...]}
  @param colors.reserved {tuple[number, number, number]}
  @param colors.bonus {tuple[number, number, number]}
]]
function VerticalFillbar:SetColor(colors)
  if colors.actual then
    if type(colors.actual[1]) == "number" then
      -- It's a list of numbers, a single color
      self.colors = {{0, Color(unpack(colors.actual))}}
    else
      -- Assume its a list of {threshold, color_values} pairs
      self.colors = colors.actual
      -- Convert to list[{threshold, Color}] so we can pass values directly to SetBackColor()
      self.colors = map(colors.actual, function (e) return {e[1], Color(unpack(e[2]))} end)
    end
    self.overlay:SetBackColor(self.colors[1][2])
  end
  if colors.reserved then
    self.overlay_reserved:SetBackColor(Color(unpack(colors.reserved)))
  end
  if colors.bonus then
    self.overlay_bonus:SetBackColor(Color(unpack(colors.bonus)))
  end
end

--[[
  @param width {number}
  @param height {number}
]]
function VerticalFillbar:SetSize(width, height)
  Control.SetSize(self, width, height)
  self.bg:SetSize(width, height)
  self.fill:SetSize(width, height)
  self.mask:SetSize(width, height)
  self.overlay:SetSize(width, height)

  self.fill_reserved:SetSize(width, height)
  self.mask_reserved:SetSize(width, height)
  self.overlay_reserved:SetSize(width, height)

  self.fill_bonus:SetSize(width, height)
  self.mask_bonus:SetSize(width, height)
  self.overlay_bonus:SetSize(width, height)
end
