local class = require 'middleclass'
require 'TEsound'
require 'baddie'

baddiebuilder = class('baddiebuilder')

local _baddiesTable = {}

function baddiebuilder:initialize(mapObjects, collider, gravity)
  for i, bad in ipairs(mapObjects) do
    local x
    local y
    x, y = bad:center()
    table.insert(_baddiesTable, baddie:new(x, y, 30, collider, gravity))
  end
end

function baddiebuilder:draw()
  for i, bad in ipairs(_baddiesTable) do
    bad:draw()
  end
end

function baddiebuilder:update(dt)
  for i, bad in ipairs(_baddiesTable) do
    bad:update(dt)
  end
end

function baddiebuilder:getBadInfo()
  local test = {}

  for i, obj in ipairs(_baddiesTable) do
    table.insert(test, obj:getCoords())
  end
  return test
end
