pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- Blobby Volley clone
-- by HighPerformanceCookie
physics = { yMax = 500, gravity = 0.2 }
rules = { kickoff = true, lastTouch = 0, countTouch = 0 }
objects = {}

function _init()
 objects.w = World:create()
 objects.b = Ball:create({31, 31})
 objects.p1 = Blob:create({23, 0}, -1)
 objects.p2 = Blob:create({87, 0}, -2)
end

function _update()
 -- interact with players
 if objects.b:collide(objects.p1:getBounding()) then
   objects.b:bounce(objects.p1.pos, objects.p1.v)
 end
 if objects.b:collide(objects.p2:getBounding()) then
   objects.b:bounce(objects.p2.pos, objects.p2.v)
 end

 -- interact with world
 x1, y1, x2, y2 = objects.b:getBounding()
 if (x1 < 0) or (x2 > 127) then
  -- objects.b:reflectHorizontal()
 end
 if (y1 <= 0) then
  objects.b = Ball:create({31, 31})
  objects.p1 = Blob:create({23, 0}, -1)
  objects.p2 = Blob:create({87, 0}, -2)
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
 setmetatable(world, World)
 return world
end

function World:update()
end

function World:draw()
 rect(63, 127, 65, 80)
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
 blob.sprStand = 0
 blob.p = p or 0
 return blob
end

function Blob:update()
 if (self.p > 0) then
  -- human player
 else
  -- AI player
 end

 if (btn(0, self.p)) then self.pos[1] -= 1 end
 if (btn(1, self.p)) then self.pos[1] += 1 end
 if (btn(2, self.p)) then self.pos[2] += 1 end
 if (btn(3, self.p)) then self.pos[2] -= 1 end
 if (btn(4, self.p)) then self:jump() end
 if (btn(5, self.p)) then end

 self.v[2] -= physics.gravity
 self.pos = { 
  mid(0, self.pos[1] + self.v[1], 127), 
  mid(0, self.pos[2] + self.v[2], physics.yMax) }
end

function Blob:draw()
 spr(
  self.sprStand, 
  self.pos[1], 
  127 - (self.h-1 - self.pos[2]), 
  -flr(-self.w/8), 
  -flr(-self.h/8)) 
end

function Blob:jump()
 if (btnp(4, self.p)) then self.v = {0, 3} end
end

function Blob:getBounding()
 return self.pos[1], self.pos[2], self.pos[1]+(self.w-1), self.pos[2]+(self.h-1)
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
 ball.spr = 2
 return ball
end

function Ball:update()
 if not(kickoff) then
  self.v[2] -= physics.gravity
 end

 self.pos = { 
  mid(0, self.pos[1] + self.v[1], 127), 
  mid(0, self.pos[2] + self.v[2], physics.yMax) }
end

function Ball:draw()
 printh(self.pos[1])
 printh(self.pos[2])
 spr(
  self.spr, 
  self.pos[1], 
  127 - (self.h-1 - self.pos[2]), 
  -flr(-self.w/8), 
  -flr(-self.h/8)) 
end

function Ball:getBounding()
 return self.pos[1], self.pos[2], self.pos[1]+(self.w-1), self.pos[2]+(self.h-1)
end

function Ball:collide(x1, y1, x2, y2)
 local w = x2 - x1
 local h = y2 - y1
 if (
   (x1 < self.pos[1] + self.w) and
   (x1 + w > self.pos[1]) and
   (y1 < self.pos[2] + self.h) and
   (y1 + h > self.pos[2]) ) then
  return false 
 end
 return false
end

function Ball:bounce(p, v)
 vec = {self.pos[1] - p[1], self.pos[2] - p[2]}
 self.v = vec
end

-->8
-- utils

function vlen(vec)
 local s = 0.0
 foreach(vec, function(x) s += pow(x, 2) end)
 return sqrt(s)
end

__gfx__
00000000000000000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000077770000007777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000777777000007777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777700000777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777700000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
