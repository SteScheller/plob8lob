pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- Blobby Volley clone
-- by HighPerformanceCookie
physics = { yMax = 500, gravity = 0.3, poleHeight = 50}
rules = { kickoff = true, lastTouch = 0, countTouch = 0 }
objects = {}

function _init()
 objects.w = World:create()
 objects.b = Ball:create({30, 31})
 objects.p1 = Blob:create({23, 0}, 0)
 objects.p2 = Blob:create({87, 0}, 1)
end

function _update()
 -- interact with players
 if objects.b:collide(objects.p1:getBounding()) then
   rules.kickoff = false
   objects.b:bounce(objects.p1:getCog(), objects.p1.v)
 end
 if objects.b:collide(objects.p2:getBounding()) then
   rules.kickoff = false
   objects.b:bounce(objects.p2:getCog(), objects.p2.v)
 end

 -- interact with world
 x1, y1, x2, y2 = objects.b:getBounding()
 if (x1 < 0) or (x2 > 127) then
  objects.b:reflectVertical()
 elseif objects.b:collide(objects.w:getPoleBounding()) then 
  if (y1 >= 50) then
   objects.b:reflectHorizontal()
  else
   objects.b:reflectVertical()
  end
 end

 -- check if a player scored
 if (y1 <= 0) then
  objects.b = Ball:create({30, 31})
  objects.p1 = Blob:create({23, 0}, 0)
  objects.p2 = Blob:create({87, 0}, 1)
  rules.kickoff = true
 end

 for k,v in pairs(objects) do objects[k]:update() end
end

function _draw()
 cls(1)
 for k,v in pairs(objects) do objects[k]:draw() end
end

-->8
-- world
World = {}
World.__index = World

function World:create(pos)
 local world = {}
 world.poleBb = { 63, 0, 65, physics.poleHeight }
 setmetatable(world, World)
 return world
end

function World:getPoleBounding()
 return unpack(self.poleBb)
end

function World:update()
end

function World:draw()
 rectfill(
  self.poleBb[1], 127 - self.poleBb[2], self.poleBb[3], 127 - self.poleBb[4])
end

-->8
-- player blob
Blob = {}
Blob.__index = Blob

function Blob:create(pos, p)
 local blob = {}
 setmetatable(blob, Blob)
 blob.pos = pos -- origin: lower left of bounding box
 blob.w, blob.h = 16, 16
 blob.v = {0, 0}
 blob.sprStand = 2
 blob.p = p or 0
 blob.bb = {3, 0, 12, 11}
 return blob
end

function Blob:update()
 if (self.p >= 0) then
  -- human player
  if (btn(0, self.p)) then self.v[1] = max(-3, self.v[1]-1)
  elseif (btn(1, self.p)) then self.v[1] = min(3, self.v[1]+1) 
  else 
   if self.v[1] > 0 then self.v[1] -= 1
   elseif self.v[1] < 0 then self.v[1] += 1 end
  end
  if (btn(4, self.p)) then self:jump() end
 else
  -- AI player
 end

 if (self.pos[2] > 0) then
  self.v[2] -= physics.gravity
 else
  self.v[2] = 0
 end

 self.pos = { max(-3, self.pos[1] + self.v[1]), max(0, self.pos[2] + self.v[2])}
end

function Blob:draw()
 spr(
  self.sprStand, 
  self.pos[1], 
  127 - (self.h-1 + self.pos[2]), 
  -flr(-self.w/8), 
  -flr(-self.h/8)) 
end

function Blob:jump()
 if self.pos[2] <= 0 then
  self.pos[2] = 1
  self.v[2] = 6
 end
end

function Blob:getBounding()
 return offsetBounding(self.bb, self.pos)
end

function Blob:getCog()
 return { self.pos[1] + 0.5 * (self.w-1), self.pos[2] + 0.25 * (self.h-1) }
end

-->8
-- ball
Ball = {}
Ball.__index = Ball

function Ball:create(pos)
 local ball = {}
 setmetatable(ball, Ball)
 ball.pos = pos -- origin: lower left of bounding box
 ball.w, ball.h = 8, 8
 ball.v = {0, 0}
 ball.spr = 1
 ball.bb = {0, 0, 8, 8}
 ball.bouncing = false
 return ball
end

function Ball:update()
 if not(rules.kickoff) then
  if not(self.bouncing) then
   self.v[2] -= physics.gravity
  else
   self.bouncing = false
  end
 end

 self.pos =  { self.pos[1] + self.v[1], self.pos[2] + self.v[2] }
end

function Ball:draw()
 spr(
  self.spr, 
  self.pos[1], 
  127 - (self.h-1 + self.pos[2]), 
  -flr(-self.w/8), 
  -flr(-self.h/8)) 
end

function Ball:getBounding()
 return offsetBounding(self.bb, self.pos)
end

function Ball:collide(x1, y1, x2, y2)
 local w = x2 - x1
 local h = y2 - y1
 local lx, ly, rx, uy = offsetBounding(self.bb, self.pos)
 if (
   (x1 <= rx) and
   (x1 + w >= lx) and
   (y1 <= uy) and
   (y1 + h >= ly) ) then
  self.colliding = true
 else
  self.colliding = false
 end
 return self.colliding
end

function Ball:bounce(p, v)
 if not(self.bouncing) then
  local vel = (0.5 * vlen(v) + 0.8 * vlen(self.v))
  vec = { 
   self.pos[1] + 0.5 * (self.w - 1) - p[1], 
   self.pos[2] + 0.5 * (self.h - 1) - p[2] }
  self.v = { vel * vec[1] / vlen(vec), vel * vec[2] / vlen(vec) }
  self.bouncing = true
 end
end

function Ball:reflectVertical()
 self.v = { -self.v[1], self.v[2] }
end

function Ball:reflectHorizontal()
 self.v = { self.v[1], -self.v[2] }
end
-->8
-- utils

function vlen(vec)
 local s = 0.0
 foreach(vec, function(x) s += x^2 end)
 return sqrt(s)
end

function offsetBounding(bb, pos)
 return bb[1] + pos[1], bb[2] + pos[2], bb[3] + pos[1], bb[4] + pos[2]
end

__gfx__
00000000007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770000007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770000077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
