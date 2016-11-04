--
-- Date: 02.11.2016
--
local class = require "lib/middleclass"

local Obstacle = class("Obstacle", Character)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end
local function nop() --[[print "nop"]] end
local function clamp(val, min, max)
    if min - val > 0 then
        return min
    end
    if max - val < 0 then
        return max
    end
    return val
end

function Obstacle:initialize(name, sprite, x, y, f)
    --hp, score, shader, color,isMovable, sfxDead, func, face, horizontal, weight, sfxOnHit
    if not f then
        f = {}
    end
    Character.initialize(self, name, sprite, nil, x, y, f.shader, f.color)
    self.name = name or "Unknown Obstacle"
    self.type = "obstacle"
    self.hp = f.hp or 50
    self.max_hp = self.hp
    self.lives = 0
    self.score = f.score or 10
    self.func = f.func
    self.height = 40
    self.vertical, self.horizontal, self.face = 1, f.horizontal or 1, f.face or 1 --movement and face directions
    self.isHittable = false
    self.isDisabled = false
    self.sfx.dead = f.sfxDead --on death sfx
    self.sfx.onHit = f.sfxOnHit
    self.isMovable = f.isMovable --on death sfx

    self.weight = f.weight or 1.5
    self.gravity = self.gravity * self.weight

    self.infoBar = InfoBar:new(self)

    self:setState(self.stand)
end

function Obstacle:updateSprite(dt)
--    local spr = self.sprite
--    local s = spr.def.animations[spr.cur_anim]
    --    print(spr.cur_frame, #s)
    UpdateSpriteInstance(self.sprite, dt, self)
end

function Obstacle:setSprite(anim)
    if anim ~= "stand" then
        return
    end
    SetSpriteAnimation(self.sprite, anim)
end

function Obstacle:drawSprite(x, y)
    local spr = self.sprite
    local s = spr.def.animations[spr.cur_anim]
    local n = clamp(math.floor((#s-1) - (#s-1) * self.hp / self.max_hp)+1,
        1, #s)
--    print((#s-1) - (#s-1) * self.hp / self.max_hp+1)
    --print(n, spr.cur_frame, #s)
    DrawSpriteInstance(self.sprite, x, y, n)
end

function Obstacle:updateAI(dt)
    if self.isDisabled then
        return
    end
    --print("updateAI "..self.type.." "..self.name)
    self:updateSprite(dt)
end

function Obstacle:onHurt()
    local h = self.hurt
    if not h then
        return
    end
    --Move obstacle after hits
    if not self.isGrabbed and self.isMovable then
        self.velx = h.damage * 10
        self.horizontal = h.horizontal
    end
    Character.onHurt(self)
end

function Obstacle:stand_start()
    --	print (self.name.." - stand start")
    self.isHittable = true
    self.victims = {}
    self:setSprite("stand")
end
function Obstacle:stand_update(dt)
    --	print (self.name," - stand update",dt)
    if self.isGrabbed then
        self:setState(self.grabbed)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Obstacle.stand = {name = "stand", start = Obstacle.stand_start, exit = nop, update = Obstacle.stand_update, draw = Unit.default_draw}

function Obstacle:getup_start()
    self.isHittable = false
    self.isThrown = false
--    print (self.name.." - getup start")
    dpo(self, self.state)
    if self.z <= 0 then
        self.z = 0
    end
    if self.hp <= 0 then
        self:setState(self.dead)
        return
    end
end
function Obstacle:getup_update(dt)
    if self.velx <= 0 then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Obstacle.getup = {name = "getup", start = Obstacle.getup_start, exit = nop, update = Obstacle.getup_update, draw = Unit.default_draw}

function Obstacle:hurtHigh_start()
    self.isHittable = true
end
function Obstacle:hurtHigh_update(dt)
    if self.velx <= 0 then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Obstacle.hurtHigh = {name = "hurtHigh", start = Obstacle.hurtHigh_start, exit = nop, update = Obstacle.hurtHigh_update, draw = Unit.default_draw}

function Obstacle:hurtLow_start()
    self.isHittable = true
end
function Obstacle:hurtLow_update(dt)
    --	print (self.name.." - hurtLow update",dt)
    if self.velx <= 0 then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Obstacle.hurtLow = {name = "hurtLow", start = Obstacle.hurtLow_start, exit = nop, update = Obstacle.hurtHigh_update, draw = Unit.default_draw}

return Obstacle
