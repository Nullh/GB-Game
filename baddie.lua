local class = require 'middleclass'
local anim8 = require 'anim8'
require 'TEsound'

baddie = class('baddie')

local _speed
local _collObj
local _x
local _y
local _sprite
local _spriteWidth
local _spriteHeight
local _yVelocity = 0
local _g
local _grid
local _animations = {}
local _facingRight = true
local _moving = false



function baddie:initialize(x, y, speed, collider, g)
  _sprite = love.graphics.newImage('assets/Baddie.png')
  _spriteWidth = 8
  _spriteHeight = 8
  _x = x
  _y = y
  _speed = speed
  _g = g
  _collObj = collider:rectangle(_x, _y, _spriteWidth, _spriteHeight)
  _grid = anim8.newGrid(_spriteWidth, _spriteHeight, _sprite:getWidth(), _sprite:getHeight())
  _animations['walkLeft'] = anim8.newAnimation(_grid(1, 1), 0.2)
  _animations['walkRight'] = anim8.newAnimation(_grid(1, 1), 0.2):flipH()
  _animations['idleLeft'] = anim8.newAnimation(_grid(1, 1), 0.2)
  _animations['idleRight'] = anim8.newAnimation(_grid(1, 1), 0.2):flipH()
  --_jumpSound = love.sound.newSoundData('assets/bark.mp3')
end


function baddie:update(dt)

  _moving = true
  _facingRight = false
  _x = _x - (_speed * dt)

  _yVelocity = _yVelocity + (_g * dt)
  _y = _y + _yVelocity
  _collObj:moveTo(_x, _y)
  for shape, delta in pairs(collider:collisions(_collObj)) do
    _x = _x + delta.x
    _y = _y + delta.y
    if delta.y < 0 then
      _yVelocity = 0
    end
    if delta.x < 0 then
      _xVelocity = 0
      _moving = false
    end
  end

  _collObj:moveTo(_x, _y)
  -- update the animations
  _animations['walkLeft']:update(dt)
  _animations['walkRight']:update(dt)
  _animations['idleLeft']:update(dt)
  _animations['idleRight']:update(dt)
end

function baddie:draw()
  -- draw the player
  if _moving == true then
    if _facingRight == true then
      _animations['walkRight']:draw(_sprite, _x-(_spriteWidth/2), _y-(_spriteHeight/2))
    else
      _animations['walkLeft']:draw(_sprite, _x-(_spriteWidth/2), _y-(_spriteHeight/2))
    end
  else
    if _facingRight == true then
      _animations['idleRight']:draw(_sprite, _x-(_spriteWidth/2), _y-(_spriteHeight/2))
    else
      _animations['idleLeft']:draw(_sprite, _x-(_spriteWidth/2), _y-(_spriteHeight/2))
    end
  end
  -- if debug draw the collision object
  if debug == true then
    love.graphics.setColor(100, 100, 100, 150)
    _collObj:draw('fill')
    love.graphics.setColor(256, 256, 256)
  end
  -- reset the moving flag
  _moving = false
end

function baddie:getCoords()
  return _x, _y
end
