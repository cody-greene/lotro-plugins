import "Turbine"
import "src.Common.class"

function hook(obj, key, fn)
  local super = obj[key]
  assert(type(super) == "function", "hook target is not a function")
  obj[key] = function(...)
    return fn(super, ...)
  end
end

-- Divide a string into a list of substrings, delimited by "sep"
function split(str, sep)
  if sep == nil then
    sep = "%s"
  end
  local res = {}
  for chunk in string.gmatch(str, "([^"..sep.."]+)") do
    table.insert(res, chunk)
  end
  return res
end

-- stringify a key-value table
function formatkv(args)
  local lines = {}
  for k, v in pairs(args) do
    table.insert(lines, "  " .. tostring(k) .. ": " .. tostring(v))
  end

  return table.concat(lines, "\n")
end

function formatlist(items, sep)
  local lines = {}
  for _, v in ipairs(items) do
    table.insert(lines, tostring(v))
  end
  return table.concat(lines, sep or ", ")
end

function log(str, ...)
  local formatted = string.format(str, ...)
  Turbine.Engine.ScriptLog(formatted)
  Turbine.Shell.WriteLine(formatted)
end

function bind(fn, ...)
  local args = {...}
  return function (...)
    return fn(unpack(args), ...)
  end
end

function find_index(list, fn)
  for i, v in ipairs(list) do
    if fn(v) then
      return i
    end
  end
end

function map(list, fn)
  local res = {}
  for i, v in ipairs(list) do
    res[i] = fn(v, i)
  end
  return res
end

-- Merge src into dst (mutates dst and returns it)
-- @param dst {table}
-- @param src {table}
function merge_deep(dst, src, deep)
  for key, value in pairs(src) do
    if type(value) == "table" and type(dst[key]) == "table" then
      merge(dst[key], value, true)
    else
      dst[key] = value
    end
  end
  return dst
end

StretchMode = {
 -- No scaling. Image cropped/tiled. Properly bounded by parent.
  None=0,

 -- Scales based on size when mode assigned vs current size. Can exceed parent bounds. Mouse events work.
  Stretch=1,

  -- Scales control to background image size. Useful for determining image dimensions. No mouse events.
  Auto=2,

  -- Like mode 0 but not properly bounded by parent.
  Overflow=3,

  -- Like mode 1 but no mouse events.
  StretchNoClick=4,
}
