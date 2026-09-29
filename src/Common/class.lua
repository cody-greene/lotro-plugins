class = {}

function class.get_type(instance)
  local mt = getmetatable(instance)
  if mt ~= nil then
    return mt.__index
  end
end

function class.is_a(instance, klass)
  local parent = instance
  while parent ~= nil do
    parent = class.get_type(parent)
    if parent == klass then return true end
  end
  return false
end

local function class_construct(class_tbl, ...)
  if class_tbl.Abstract then error "Abstract class cannot be constructed." end

  -- Create the new class instance.
  local instance = {}
  setmetatable(instance, { __index = class_tbl })

  -- Invoke the constructor if it exists.
  if (instance.Constructor ~= nil) and (type(instance.Constructor) == "function") then
    instance:Constructor(...)
  end

  return instance
end

local class_meta = {}

function class_meta.__call(_, base)
  if base ~= nil then
    local baseType = type(base)

    if baseType ~= "table" then
      error("Base class is not a table. Base class was a " .. baseType)
    end
  end

  -- The class definition table. Contains all of the actual class
  -- methods, constructor, and an IsA function automatically
  -- provided.
  local c = {}

  -- The class definition metatable. This is used to hook up
  -- base classes and then to register a call handler that is
  -- used to construct new instances of the class.
  local mt = {}
  mt.__index = base
  mt.__call = class_construct

  setmetatable(c, mt)
  return c
end

setmetatable(class, class_meta)
