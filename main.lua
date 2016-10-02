local HC = require 'HC'
require 'mapLoader'
require 'player'
require 'camera'
require 'world'
require 'TEsound'

debug = false
local blockingObj = {}
local spaceReleased = true

function love.keyreleased(key, scancode)
  if scancode == 'space' then
    spaceReleased = true
  end
end

function love.keypressed(key, scancode, isrepeat)
  if scancode == 'm' and isrepeat == false then
    myWorld.mute()
  end
end

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest',0)
  gravity = 10
  map = mapLoader:new('maps/map4.lua', 'assets/Blocks 8x8 new pallette.png')
  collider = HC.new(300)
  myPlayer = player:new(10, 30, 50, 60, 3, 0.5, collider, gravity)
  blockingObj = map:getMapObjectLayer(collider, 'blocking')
  myWorld = world:new(map, collider, 500)

  myCamera = camera:new(map:getWidth(), map:getHeight(), 0, 4)
  myCamera:newLayer(-3, 0, function()
    love.graphics.setColor(256, 256, 256)
    map:draw(1, 1)
  end)
  myCamera:newLayer(-2, 1.1, function()
    love.graphics.setColor(256, 256, 256)
    map:draw(2, 2)
  end)
  myCamera:newLayer(-1,1.0, function()
    love.graphics.setColor(255, 255, 255)
    myPlayer:draw()
  end)
  myCamera:newLayer(0, 1.0, function()
    love.graphics.setColor(255, 255, 255)
    map:draw(3, 3)
    if debug == true then
      love.graphics.setColor(100, 100, 100, 150)
      for i, v in ipairs(blockingObj) do
        v:draw('fill')
      end
    end
  end)
--  myCamera:newLayer(-5, 0.3, function()
  --  love.graphics.setColor(256, 256, 256)
  --  --map:draw(1, 1)
  --  love.graphics.draw(mountains)
  --end)
  --myCamera:newLayer(-10, 0, function()
  --  love.graphics.setColor(256, 256, 256)
  --  --map:draw(1, 1)
  --  love.graphics.draw(background)
  --end)

end

function love.update(dt)

  -- movement handler
  if love.keyboard.isScancodeDown('left', 'a') then
    myPlayer:moveLeft(dt)
  end
  if love.keyboard.isScancodeDown('right', 'd') then
    myPlayer:moveRight(dt)
  end
  if love.keyboard.isScancodeDown('space') then
    spaceReleased = false
    myPlayer:jump(dt, spaceReleased)
  end

  if love.keyboard.isScancodeDown('escape') then
    love.event.quit()
  end

  myPlayer:update(dt, spaceReleased)
  myCamera:centerOn(myPlayer:getX(), myPlayer:getY())
  TEsound.cleanup()
end

function love.draw()

  myCamera:draw()

  if debug == true then
    love.graphics.print(map:getWidth(),10,50)
    love.graphics.print(map:getHeight(),10,60)

  end
end
