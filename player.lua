local class = require 'middleclass'
local anim8 = require 'anim8'
require 'TEsound'

player = class('player')

function player:initialize(x, y, speed, jumpSpeed, jumpHeight, jumpTimer, collider, g)
  self._animations = {}
  self._sprite = love.graphics.newImage('assets/Squiddy.png')
  self._spriteWidth = 8
  self._spriteHeight = 8
  self._x = x
  self._y = y
  self._speed = speed
  self._jumpSpeed = jumpSpeed
  self._jumpHeight = -jumpHeight
  self._jumpTimer = jumpTimer
  self._jumpTimerMax = jumpTimer
  self._canJump = true
  self._jumping = false
  self._onGround = false
  self._yVelocity = 0
  self._facingRight = true
  self._moving = false
  self._canBark = true
  self._lives = 3
  self._dead = false
  self._isFlashFrame = false
  self._invulnTimerMax = 3
  self._invulnTimer = 0
  self._g = g
  self._collObj = collider:rectangle(self._x, self._y, self._spriteWidth, self._spriteHeight)
  self._collObj.type = 'player'
  self._grid = anim8.newGrid(8, 8, self._sprite:getWidth(), self._sprite:getHeight())
  self._animations['walkLeft'] = anim8.newAnimation(self._grid(1, 1), 0.2)
  self._animations['walkRight'] = anim8.newAnimation(self._grid(1, 1), 0.2):flipH()
  self._animations['idleLeft'] = anim8.newAnimation(self._grid(1, 1), 0.2)
  self._animations['idleRight'] = anim8.newAnimation(self._grid(1, 1), 0.2):flipH()
  self._jumpSound = love.sound.newSoundData('assets/bark.mp3')
end

function player:getX()
  return self._x
end

function player:setX(x)
  self._x = x
  self._collObj:moveTo(self._x, self._y)
end

function player:getY()
  return self._y
end

function player:setY(y)
  self._y = y
  self._collObj:moveTo(self._x, self._y)
end

function player:setCoords(x, y)
  self._y = y
  self._x = x
  self._collObj:moveTo(self._x, self._y)
end

function player:moveLeft(dt)
  self._moving = true
  self._facingRight = false
  self._x = self._x - (self._speed * dt)
  self._collObj:moveTo(self._x, self._y)
end

function player:moveRight(dt)
  self._moving = true
  self._facingRight = true
  self._x = self._x + (self._speed * dt)
  self._collObj:moveTo(self._x, self._y)
end

function player:moveUp(dt)
  self._y = self._y - (self._speed * dt)
  self._collObj:moveTo(self._x, self._y)
end

function player:moveDown(dt)
  self._y = self._y + (self._speed * dt)
  self._collObj:moveTo(self._x, self._y)
end

function player:setSpeed(newSpeed)
  self._speed = newSpeed
end

function player:getCollObj()
  return self._collObj
end

function player:getJumpTimer()
  return self._jumpTimer
end

function player:flipCanBark()
  self._canBark = true
end

function player:jump()
  if self._canBark and self._canJump then
    self._canBark = false
    TEsound.play(self._jumpSound, 'jump', 1, 1, self:flipCanBark())
  end
  self._jumping = true
end

function player:update(dt, spaceReleased)
  -- if we're jumping accelerate the player up
  if self._jumping then

    if self._jumpTimer > 0 and self._canJump == true then
      self._yVelocity = self._yVelocity - self._jumpSpeed * (dt / (self._jumpTimerMax*5))
      if spaceReleased == true then
        self._jumpTimer = -1
      end
      if self._yVelocity < self._jumpHeight then
        self._yVelocity = self._jumpHeight
        self._canJump = false
      end
      self._jumpTimer = self._jumpTimer - dt
      self._collObj:moveTo(self._x, self._y)
    end
  end
  -- have gravity affect the player
  self._yVelocity = self._yVelocity + (self._g * dt)
  self._y = self._y + self._yVelocity
  if self._yVelocity > 0 then
    self._canJump = false
  end
  self._collObj:moveTo(self._x, self._y)
  for shape, delta in pairs(collider:collisions(self._collObj)) do
    self._x = self._x + delta.x
    self._y = self._y + delta.y
    if delta.y < 0 then
      self._yVelocity = 0
      self._jumpTimer = self._jumpTimerMax
      if spaceReleased then
        self._canJump = true
        self._jumping = false
      end
    elseif delta.y > 0 then
      self._yVelocity = 0.1
      self._canJump = false
    end
    local ux, uy, lx, ly = shape:bbox()
    if shape.type == 'enemy'
     and self._invulnTimer <= 0
     and self._y + (self._spriteHeight/2) > uy then
      self:getHit()
      self._invulnTimer = self._invulnTimerMax
    elseif shape.type == 'enemy'
     and self._y + (self._spriteHeight/2) <= uy then
       allBaddies:kill(shape.id)
       self._yVelocity = -2.5
       self._canJump = false
    end
  end
  self._collObj:moveTo(self._x, self._y)
  -- decrement the invulnerability timer
  if self._invulnTimer > 0 then
    self._invulnTimer = self._invulnTimer - dt
  end
  -- update the animations
  self._animations['walkLeft']:update(dt)
  self._animations['walkRight']:update(dt)
  self._animations['idleLeft']:update(dt)
  self._animations['idleRight']:update(dt)

  if self._invulnTimer > 0 then
    if self._isFlashFrame then
      self._isFlashFrame = false
    else
      self._isFlashFrame = true
    end
  else
    self._isFlashFrame = false
  end
end

function player:getYVelocity()
  return self._yVelocity
end

function player:draw()
  if not self._isFlashFrame then
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

function player:getLives()
  return self._lives
end

function player:getHit()
  self._lives = self._lives - 1
  if self._facingRight then
  --  self._x = self._x - 5
  --  self._y = self._y - 5
  else
  --  self._x = self._x + 5
  --  self._y = self._y - 5
  end
  if self._lives <= 0 then
    self._dead = true
  end
end

function player:isDead()
  return self._dead
end
