import "Turbine.UI"
import "src.Common"
import "src.Common.EventManager"

local Window = Turbine.UI.Window

ScalableWindow = class(Window)

function ScalableWindow:Constructor()
  Window.Constructor(self)
  self.scalable_state = {
    parent = parent,
    x = 0,
    y = 0,
  }
end

function ScalableWindow:SetParent(parent)
  -- By default, nested Window objects are not scaled properly. So we're rewriting this
  -- method and have to do a few things ourself:
  -- * Visibility should match the "parent" HUD object
  -- * Position should be relative to the HUD object
  -- * Scale should match the HUD object

  -- Don't need to support parent swaps (ever?)
  assert(not self.scalable_state.parent, "Can't reassign parent of ScalableWindow")
  assert(class.is_a(parent, Turbine.UI.Window), "ScalableWindow parent must be a Window")

  self.scalable_state.parent = parent
  self:SetPosition(0, 0)
  Window.SetVisible(self, self.is_visible and parent:IsVisible())

  EventManager.add_callback(parent, "VisibleChanged", function()
    Window.SetVisible(self, self.is_visible and parent:IsVisible())
  end)

  EventManager.add_callback(parent, "PositionChanged", function(_, args)
    self:SetPosition(self.scalable_state.x, self.scalable_state.y)
  end)

  hook(parent, "SetScale", function(super, parent, val)
    super(parent, val)
    self:SetScale(val)
  end)
end

function ScalableWindow:SetPosition(x, y)
  local xp, yp = 0, 0
  local scale = 1
  local parent = self.scalable_state.parent
  if parent then
    xp, yp = parent:GetPosition()
    scale = parent:GetScale()
  end
  self.scalable_state.x = x
  self.scalable_state.y = y
  Window.SetPosition(self, math.ceil(xp + x*scale), math.ceil(yp + y*scale))
end

function ScalableWindow:SetVisible(val)
  local is_parent_visible = true
  if self.scalable_state.parent then
    is_parent_visible = self.scalable_state.parent:IsVisible()
  end
  self.is_visible = val
  Window.SetVisible(self, val and is_parent_visible)
end

function ScalableWindow:scale_from_center()
  self:SetScale(1)
  self:SetScalingOriginPoint(self:GetWidth()/2, self:GetHeight()/2)
end
