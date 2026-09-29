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
