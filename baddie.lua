local class = require 'middleclass'
local anim8 = require 'anim8'
require 'TEsound'

baddie = class('baddie')

function baddie:initialize(x, y, speed, collider, g)
  self._sprite = love.graphics.newImage('assets/Baddie.png')
  self._spriteWidth = 8
  self._spriteHeight = 8
  self._x = x
  self._y = y
  self._yVelocity = 0
  self._xVelocity = 0
  self._speed = speed
  self._g = g
  self._collObj = collider:rectangle(self._x, self._y, self._spriteWidth, self._spriteHeight)
  self._grid = anim8.newGrid(self._spriteWidth, self._spriteHeight, self._sprite:getWidth(), self._sprite:getHeight())
  self._animations = {}
  self._animations['walkLeft'] = anim8.newAnimation(self._grid(1, 1), 0.2)
  self._animations['walkRight'] = anim8.newAnimation(self._grid(1, 1), 0.2):flipH()
  self._animations['idleLeft'] = anim8.newAnimation(self._grid(1, 1), 0.2)
  self._animations['idleRight'] = anim8.newAnimation(self._grid(1, 1), 0.2):flipH()
  --self._jumpSound = love.sound.newSoundData('assets/bark.mp3')
end


function baddie:update(dt)

  self._moving = true
  self._facingRight = false
  self._x = self._x - (self._speed * dt)

  self._yVelocity = self._yVelocity + (self._g * dt)
  self._y = self._y + self._yVelocity
  self._collObj:moveTo(self._x, self._y)
  for shape, delta in pairs(collider:collisions(self._collObj)) do
    self._x = self._x + delta.x
    self._y = self._y + delta.y
    if delta.y < 0 then
      self._yVelocity = 0
    end
    if delta.x < 0 then
      self._xVelocity = 0
      self._moving = false
    end
  end

  self._collObj:moveTo(self._x, self._y)
  -- update the animations
  self._animations['walkLeft']:update(dt)
  self._animations['walkRight']:update(dt)
  self._animations['idleLeft']:update(dt)
  self._animations['idleRight']:update(dt)
end

function baddie:draw()
  -- draw the player
  if self._moving == true then
    if self._facingRight == true then
      self._animations['walkRight']:draw(self._sprite, self._x-(self._spriteWidth/2), self._y-(self._spriteHeight/2))
    else
      self._animations['walkLeft']:draw(self._sprite, self._x-(self._spriteWidth/2), self._y-(self._spriteHeight/2))
    end
  else
    if self._facingRight == true then
      self._animations['idleRight']:draw(self._sprite, self._x-(self._spriteWidth/2), self._y-(self._spriteHeight/2))
    else
      self._animations['idleLeft']:draw(self._sprite, self._x-(self._spriteWidth/2), self._y-(self._spriteHeight/2))
    end
  end
  -- if debug draw the collision object
  if debug == true then
    love.graphics.setColor(100, 100, 100, 150)
    self._collObj:draw('fill')
    love.graphics.setColor(256, 256, 256)
  end
  -- reset the moving flag
  self._moving = false
end

function baddie:getX()
  return self._x
end

function baddie:getY()
  return self._y
end
