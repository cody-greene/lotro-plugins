import "Turbine.UI"
import "Turbine.UI.Lotro"

import "src.Common.class"

local SELECTED_COLOR = Turbine.UI.Color(0.239, 0.682, 0.914)
local BACK_COLOR = Turbine.UI.Color(0.2, 0.2, 0.2)
local FONT_SIZE = 16
local PADDING = 3
local FONT = Turbine.UI.Lotro.Font["Verdana" .. tostring(FONT_SIZE)]
local LABEL_HEIGHT = FONT_SIZE + 2*PADDING

--[[
  Display a list of items, from which the user can select one. Will
  automatically expand vertically to display all options unless the height is
  changed after initialization.

  `on_change(selected_val, index)` is called whenever the selected value
  changes.
]]--
SelectBox = class(Turbine.UI.ListBox)

local function default_get_label(val)
  return val
end

-- @param options {list[string] | list[any]}
-- @param get_label {function} (option) -> string
function SelectBox:Constructor(options, get_label)
  Turbine.UI.ListBox.Constructor(self)

  if not get_label then
    get_label = default_get_label
  end

  self.options = options

  -- The most recently selected item
  -- @type {Turbine.UI.Label | nil}
  self.prev = nil

  self:SetBackColor(BACK_COLOR)

  local opt_count = #options
  self:SetHeight(opt_count * LABEL_HEIGHT)

  for i = 1, #options do
    local label = Turbine.UI.Label()
    label:SetHeight(LABEL_HEIGHT)
    label:SetWidth(self:GetWidth())
    label:SetFont(FONT)
    label:SetText(get_label(options[i]))
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    self:AddItem(label)
  end
end

function SelectBox:SetWidth(width)
  Turbine.UI.ListBox.SetWidth(self, width)
  local label
  for i = 1, self:GetItemCount() do
    label = self:GetItem(i)
    label:SetWidth(width)
  end
end

function SelectBox:SetSize(width, height)
  Turbine.UI.ListBox.SetSize(self, width, height)
  local label
  for i = 1, self:GetItemCount() do
    label = self:GetItem(i)
    label:SetWidth(width)
  end
end

function SelectBox:SelectedIndexChanged()
  local index = self:GetSelectedIndex()
  local selected_val = self.options[index]
  local selected_control = self:GetItem(index)
  if self.prev then
    self.prev:SetBackColor(nil)
  end
  selected_control:SetBackColor(SELECTED_COLOR)
  self.prev = selected_control
  if self.on_change then
    self:on_change(selected_val, index)
  end
end
