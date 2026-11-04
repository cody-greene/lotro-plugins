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


local SUFFIX_MAP = {
  {limit = 0, divisor = 0, suffix = ""}, -- 99,999
  {limit = 1e5, divisor = 1e3, suffix = "k"}, -- 100k - 999.9k
  {limit = 1e6, divisor = 1e6, suffix = "M"}, -- 1M - 999.9M
  {limit = 1e9, divisor = 1e9, suffix = "G"},
}
local KSUB = "%1" .. KSEP
local KPTN = "^" .. KSEP
-- Insert locale appropriate separators to group a number by the thousands.
-- e.g. 1000 -> "1,000"
function format_int(val)
  local rounded = math.floor(0.5 + val)
  local suffix, divisor
  for _, v in ipairs(SUFFIX_MAP) do
    if val < v.limit then
      break
    end
    divisor = v.divisor
    suffix = v.suffix
  end

  if divisor > 0 then
    local x = rounded / divisor
    local fractional = math.floor(x*10%10 + 0.5)
    if fractional == 10 then
      -- Carry the one... might need to upgrade the suffix
      return format_int((math.floor(x) + 1) * divisor)
    end
    return math.floor(x) .. DSEP .. fractional .. suffix
  end

  return tostring(rounded):reverse():gsub("(%d%d%d)", KSUB):reverse():gsub(KPTN, "")
end
