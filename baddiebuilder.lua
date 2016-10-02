local class = require 'middleclass'
require 'TEsound'
require 'baddie'

baddiebuilder = class('baddiebuilder')


function baddiebuilder:initialize(mapObjects, collider, gravity)
  self._baddiesTable = {}
  for i, bad in ipairs(mapObjects) do
    --local x, y = bad:center()
    local obj = baddie:new(bad['x'], bad['y'], 30, collider, gravity, self)
    --self._baddiesTable[obj] = obj
    table.insert(self._baddiesTable, obj)
    --table.insert(self._baddiesTable, baddie:new(100, 50*i , 30, collider, gravity))
  end
  --table.insert(self._baddiesTable, baddie:new(50,50,30,collider,gravity))
end

function baddiebuilder:draw()
  for i, bad in ipairs(self._baddiesTable) do
    bad:draw()
  end
end

function baddiebuilder:update(dt, fallLimit)
  for i, bad in ipairs(self._baddiesTable) do
    bad:update(dt, fallLimit)
  end
end

function baddiebuilder:getBadInfo()
  local test = table.getn(self._baddiesTable)
  for i, obj in ipairs(self._baddiesTable) do
    test = test..'\n'..obj:getX()..','..obj:getY()
  end
  return test
end

function baddiebuilder:removeSelf()
  for i, bad in ipairs(self._baddiesTable) do
    if bad:isDead() then
      table.remove(self._baddiesTable, i)
      bad:removeCollObj()
    end
  end
end
