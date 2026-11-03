import "Turbine"

-- Automatically translations for the client's language.
-- Usage:
--   import("Foo.Bar.i18n")
--   local t = Foo.Bar.i18n
--   print(t.WRIT_OF_COLD) -- "Allégorie du froid"
local lang = Turbine.Engine.GetLanguage()

if lang == Turbine.Language.German then
  import "src.CombatHUD.i18n.de"
elseif lang == Turbine.Language.French then
  import "src.CombatHUD.i18n.fr"
else
  import "src.CombatHUD.i18n.en"
end


local KSUB = "%1" .. KSEP
local KPTN = "^" .. KSEP
-- Insert locale appropriate separators to group a number by the thousands.
-- e.g. 1000 -> "1,000"
function format_int(val)
  local str = tostring(math.floor(0.5 + val)) -- rounded
  return str:reverse():gsub("(%d%d%d)", KSUB):reverse():gsub(KPTN, "")
end
