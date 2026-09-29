import "src.Common"

local class = src.Common.class

-- @param target {Turbine.Object}
-- @param event_name {string}
-- @param fn {function}
local function add_callback(target, event_name, fn)
  local prev = target[event_name]
  if prev == nil then
    target[event_name] = fn
  elseif type(prev) == "table" then
    table.insert(prev, fn)
  else
    target[event_name] = { prev, fn }
  end
  return fn
end

-- @param target {Turbine.Object}
-- @param event_name {string}
-- @param fn {function}
local function remove_callback(target, event_name, fn)
  local prev = target[event_name]
  if prev == fn then
    target[event_name] = nil
  elseif type(prev) == "table" then
    local size = table.getn(prev)
    for i = 1, size do
      if prev[i] == fn then
        table.remove(prev, i)
        break
      end
    end
  end
end

-- Use this instead of add_callback and remove_callback. It's easier.
EventManager = class()
function EventManager:Constructor()
  self.mem = {}
end

function EventManager:add(target, event_name, fn)
  add_callback(target, event_name, fn)
  local tuple = {target, event_name, fn}
  table.insert(self.mem, tuple)
  return tuple
end

function EventManager:clear()
  for _, args in ipairs(self.mem) do
    remove_callback(unpack(args))
  end
  self.mem = {}
end

-- Static
EventManager.add_callback = add_callback
EventManager.remove_callback = remove_callback
