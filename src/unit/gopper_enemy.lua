local class = require "lib/middleclass"
local Gopper = class('Gopper', Enemy)

local function nop() end

function Gopper:initialize(name, sprite, x, y, f, input)
    self.hp = self.hp or 40
    self.scoreBonus = self.scoreBonus or 200
    self.tx, self.ty = x, y
    Enemy.initialize(self, name, sprite, x, y, f, input)
    Gopper.initAttributes(self)
    self.subtype = "gopnik"
    self.friendlyDamage = 2 --divide friendly damage
    self.face = -1
    self:postInitialize()
end

function Gopper:initAttributes()
    self.moves = { --list of allowed moves
        run = true, pickUp = true, dashAttack = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, duck = true,
    }
    self.dashSpeed_x = 150 --speed of the character
    self.dashFallSpeed = 180 --speed caused by dash to others fall
    self.dashFriction = self.dashSpeed_x
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.gopperDeath
    self.sfx.dashAttack = sfx.gopperAttack
    self.sfx.step = "kisaStep"
    self.AI = AIGopper:new(self)
end

function Gopper:updateAI(dt)
    if self.isDisabled then
        return
    end
    Enemy.updateAI(self, dt)
    self.AI:update(dt)
end

function Gopper:onFriendlyAttack()
    local h = self.isHurt
    if not h then
        return
    end
    if h.isThrown or h.source.type == "player" then
        h.damage = h.damage or 0
    elseif h.source.subtype == "gopnik" then
        --Gopper can attack Gopper and Niko only
        h.damage = math.floor( (h.damage or 0) / self.friendlyDamage )
    else
        self.isHurt = nil
    end
end

function Gopper:walkStart()
    self.isHittable = true
    self:setSprite("walk")
    self.tx, self.ty = self.x, self.y
end
function Gopper:walkUpdate(dt)
    local complete
    if self.move then
        complete = self.move:update(dt)
        if not complete then
            if isDebug() then
                attackHitBoxes[#attackHitBoxes+1] = {x = self.ttx, sx = 0, y = self.tty, w = 31, h = 0.1, z = 0 }
            end
        end
    else
        complete = true
    end
    if complete then
        self:setState(self.stand)
        return
    end
    if not self.successfullyMoved then
        self:setState(self.stand)
        return
    end
end
Gopper.walk = { name = "walk", start = Gopper.walkStart, exit = nop, update = Gopper.walkUpdate, draw = Enemy.defaultDraw }

function Gopper:runStart()
    self.isHittable = true
    self:setSprite("run")
    self.tx, self.ty = self.x, self.y
end
function Gopper:runUpdate(dt)
    local complete
    if self.move then
        complete = self.move:update(dt)
        if not complete then
            if isDebug() then
                attackHitBoxes[#attackHitBoxes+1] = {x = self.ttx, sx = 0, y = self.tty, w = 31, h = 0.1, z = 0 }
            end
        end
    else
        complete = true
    end
    if complete then
        self:setState(self.stand)
        return
    end
    if not self.successfullyMoved then
        self:setState(self.stand)
        return
    end
end
Gopper.run = {name = "run", start = Gopper.runStart, exit = nop, update = Gopper.runUpdate, draw = Gopper.defaultDraw}

local dashAttackSpeedMultiplier = 0.75
function Gopper:dashAttackStart()
    self.isHittable = true
    self.customFriction = self.dashFriction * dashAttackSpeedMultiplier
    self:setSprite("dashAttack")
    self.speed_x = self.dashSpeed_x * 2 * dashAttackSpeedMultiplier
    self.speed_y = 0
    self.speed_z = self.jumpSpeed_z / 2 * dashAttackSpeedMultiplier
    self.z = self:getMinZ() + 0.1
    self.bounced = 0
    self:playSfx(self.sfx.dashAttack)
end
function Gopper:dashAttackUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt, dashAttackSpeedMultiplier)
    elseif self.bounced == 0 then
        self.speed_z = 0
        self.speed_x = 0
        self.z = self:getMinZ()
        self.bounced = 1
        self:playSfx("bodyDrop", 1, 1 + 0.02 * love.math.random(-2,2))
        self:showEffect("fallLanding")
    end
end
Gopper.dashAttack = {name = "dashAttack", start = Gopper.dashAttackStart, exit = nop, update = Gopper.dashAttackUpdate, draw = Character.defaultDraw }

return Gopper
