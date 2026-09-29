import("Turbine.UI.Lotro")

config = {
  enable24hour = false,
  font = "Verdana18",
  -- {alpha, red, green, blue} (0-1)
  font_color = { 1, 1, 0, 0 },
  background_color = { 0.7, 0, 0, 0 },
  width = 125,
  height = 25,
}

win = Turbine.UI.Window()
win:SetSize(config.width, config.height)
win:SetPosition(Turbine.UI.Display.GetWidth() / 2 - win:GetWidth() / 2, 5)
win:SetMouseVisible(false)

local label = Turbine.UI.Label()
label:SetParent(win)
label:SetMouseVisible(false)
label:SetMultiline(false)
label:SetSize(config.width, config.height)
label:SetBackColor(Turbine.UI.Color(unpack(config.background_color)))
label:SetFont(Turbine.UI.Lotro.Font[config.font])
label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
label:SetFontStyle(Turbine.UI.FontStyle.Outline)
local font_color = Turbine.UI.Color(unpack(config.font_color))
label:SetOutlineColor(font_color)
label:SetForeColor(font_color)
label:SetText(string.format("00:00 pm"))

local function set_clock(date)
  local period = "am"
  local hour = date.Hour
  if hour > 12 then
    hour = hour - 12
    period = "pm"
  end
  label:SetText(string.format("%02d:%02d %s", hour, date.Minute, period))
end

if config.enable24hour then
  set_clock = function(date)
    label:SetText(string.format("%02d:%02d", date.Hour, date.Minute))
  end
end

local prev = -1

-- Called every frame when WantsUpdates is enabled.
function win:Update()
  local date = Turbine.Engine.GetDate()
  if prev == date.Minute then
    return -- Avoid unnecessary work
  end
  prev = date.Minute
  set_clock(date)
end

win:SetWantsUpdates(true)

-- Event fired when a plugin's main package has finished loading.
function plugin:Load()
  win:SetVisible(true)
end
