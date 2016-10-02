local class = require 'middleclass'
require 'TEsound'
require 'baddie'

baddiebuilder = class('baddiebuilder')


function baddiebuilder:initialize(mapObjects, collider, gravity)
  self._baddiesTable = {}
  for i, bad in ipairs(mapObjects) do
    --local x, y = bad:center()
    table.insert(self._baddiesTable, baddie:new(bad['x'], bad['y'], 30, collider, gravity))
    --table.insert(self._baddiesTable, baddie:new(100, 50*i , 30, collider, gravity))
  end
  --table.insert(self._baddiesTable, baddie:new(50,50,30,collider,gravity))
end

function baddiebuilder:draw()
  for i, bad in ipairs(self._baddiesTable) do
    bad:draw()
  end
end

function baddiebuilder:update(dt)
  for i, bad in ipairs(self._baddiesTable) do
    bad:update(dt)
  end
end

function baddiebuilder:getBadInfo()
  local test = table.getn(self._baddiesTable)
  for i, obj in ipairs(self._baddiesTable) do
    test = test..'\n'..obj:getX()..','..obj:getY()
  end
  return test
end
