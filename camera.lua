local class = require 'middleclass'

camera = class('camera')

local _width = nil
local _height = nil
local _transformationX = nil
local _transformationY = nil
local _mapWidth
local _mapHeight
local _rotation
local _layers = {}

function camera:initialize(mapWidth, mapHeight, rotation, scale)
  _width = love.graphics.getWidth()
  _height = love.graphics.getHeight()
  _mapWidth = mapWidth
  _mapHeight = mapHeight
  _rotation = rotation
  _scale = scale
end

function camera:centerOn(x, y)
  if _width  < _mapWidth*_scale then
    _transformationX = math.floor((-x * _scale) + (_width /2))/_scale
    if _transformationX > 0 then
      _transformationX = 0
    elseif _transformationX < ((_mapWidth)  - (_width)) then
      _transformationX = (_mapWidth - _width)
    end
  else
    _transformationX = ((_width / _scale) - _mapWidth)/2
  end

  if _height < _mapHeight * _scale then
    _transformationY = (-y /2)/_scale
    if _transformationY > 0 then
      _transformationY = 0
    elseif _transformationY < -((_mapHeight * _scale)  - (_height))/_scale then
      _transformationY = (_height / _scale) - _mapHeight
    end
  else
    _transformationY = ((_height / _scale) - _mapHeight)/2
  end

  --if _height  < _mapHeight*_scale  then
  --  _transformationY = math.floor(-y/_scale + ((_height/_scale) /2))
  --  if _transformationY > 0 then
  --    _transformationY = 0
  --  elseif _transformationY < -((_mapHeight/_scale)  - (_height/_scale)) then
  --    _transformationY = -((_mapHeight/_scale)  - (_height/_scale))
  --  end
  --else
  --  _transformationY = ((_height/_scale)  - (_mapHeight/_scale))/2
  --end
end

function camera:newLayer(order, scale, func)
  local newLayer = {draw = func, scale = scale, order = order}
  table.insert(_layers, newLayer)
  table.sort(_layers, function(a,b) return a.order < b.order end)
  return newLayer
end

function camera:set()
  love.graphics.push()
  love.graphics.rotate(-_rotation)
  love.graphics.scale(_scale, _scale)
  love.graphics.translate(_transformationX, _transformationY)
end

function camera:unset()
  love.graphics.pop()
end

function camera:draw()
  local bx, by = _transformationX, _transformationY
  for _, v in ipairs(_layers) do
    _transformationX = bx * v.scale
    --_transformationY = by * v.scale
    self:set()
    v.draw()
    self:unset()
  end
  _transformationX, _transformationY = bx, by
end

function camera:getScale()
  return _scale
end
