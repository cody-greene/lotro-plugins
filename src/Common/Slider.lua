import "Turbine.UI"
import "src.Common"

local LINE_COLOR = Turbine.UI.Color(0.5, 0.5, 0.35)
local LINE_HEIGHT = 2
local BUTTON_COLOR = Turbine.UI.Color(0.7, 0.7, 0.5)
local BUTTON_WIDTH = 5
local BUTTON_HEIGHT = 8
local PADDING = 2

Slider = class(Turbine.UI.Control)

function Slider:Constructor(min_value, max_value)
  Turbine.UI.Control.Constructor(self)

  self.drag = false
  self.min_value = min_value or 0
  self.max_value = max_value or 1
  self.normalized_value = self.min_value

  local line = Turbine.UI.Button()
  self.line = line
  line:SetParent(self)
  line:SetBackColor(LINE_COLOR)
  line:SetHeight(LINE_HEIGHT)
  line:SetMouseVisible(false)

  local button = Turbine.UI.Button()
  self.button = button
  button:SetParent(self)
  button:SetBackColor(BUTTON_COLOR)
  button:SetZOrder(self.line:GetZOrder() + 1)
  button:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
  button:SetMouseVisible(false)

  self:SetSize(100, BUTTON_HEIGHT + PADDING*2)
end

function Slider:MouseDown(args)
  self.drag = true
  self:update_raw(args.X)
end

function Slider:MouseMove(args)
  if self.drag then
    self:update_raw(args.X)
  end
end

function Slider:MouseUp(args)
  if self.drag then
    self.drag = false
    self:update_raw(args.X)
  end
end

function Slider:update_raw(x)
  local width = self:GetWidth()
  local normalized = math.max(0, math.min(x/width, 1))
  local actual = (normalized * (self.max_value - self.min_value)) + self.min_value
  self.button:SetLeft((width - BUTTON_WIDTH) * normalized)
  self.normalized_value = normalized
  self:on_change(actual)
end

function Slider:set_value(actual)
  actual = math.max(self.min_value, math.min(actual, self.max_value))
  local normalized = (actual - self.min_value) / (self.max_value - self.min_value)
  self.button:SetLeft((self:GetWidth() - BUTTON_WIDTH) * normalized)
  self.normalized_value = normalized
  --self:on_change(actual)
end

function Slider:SetSize(width, height)
  Turbine.UI.Control.SetSize(self, width, height)
  self.line:SetWidth(width - BUTTON_WIDTH)
  self.line:SetPosition(BUTTON_WIDTH/2, height/2 - LINE_HEIGHT/2)
  self.button:SetPosition(
    (width - BUTTON_WIDTH) * self.normalized_value,
    height/2 - BUTTON_HEIGHT/2
  )
end

function Slider:SetHeight(height)
  self:SetSize(self:GetWidth(), height)
end

function Slider:SetWidth(width)
  self:SetSize(width, self:GetHeight())
end

function Slider:on_change() end
