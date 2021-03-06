local class = require "lib/middleclass"
local StageObject = class("StageObject", Unit)

local function nop() end

-- borrow methods from character class
StageObject.checkAndAttack = Character.checkAndAttack
StageObject.onHurtDamage = Character.onHurtDamage
StageObject.afterOnHurt = Character.afterOnHurt
StageObject.releaseGrabbed = Character.releaseGrabbed
StageObject.grabbed = {name = "grabbed", start = Character.grabbedStart, exit = nop, update = nop, draw = StageObject.defaultDraw}
StageObject.grabbedFront = {name = "grabbedFront", start = Character.grabbedFrontStart, exit = nop, update = Character.grabbedUpdate, draw = StageObject.defaultDraw}
StageObject.grabbedBack = {name = "grabbedBack", start = Character.grabbedBackStart, exit = nop, update = Character.grabbedUpdate, draw = StageObject.defaultDraw}
StageObject.dead = {name = "dead", start = Character.deadStart, exit = nop, update = Character.deadUpdate, draw = StageObject.defaultDraw}
StageObject.knockedDown = {name = "knockedDown", start = Character.knockedDownStart, exit = nop, update = Character.knockedDownUpdate, draw = StageObject.defaultDraw}

function StageObject:initialize(name, sprite, x, y, f)
    --f options {}: shapeType, shapeArgs, hp, score, shader, color,isMovable, flipOnBreak, sfxDead, func, face, horizontal, weight, sfxOnHit, sfxOnBreak, sfxGrab
    if not f then
        f = {}
    end
    if not f.shapeType then
        --f.shapeType = "ellipse"
        --f.shapeArgs = { x, y, 7.5 } -- only circle shape is supported
        f.shapeType = "polygon"
        f.shapeArgs = { 4, 0, 9, 0, 14, 3, 9, 6, 4, 6, 0, 3 }
    end
    self.height = f.height or 40
    Character.initialize(self, name, sprite, x, y, f)
    self.name = name or "Unknown StageObject"
    self.type = "stageObject"
    self.vertical, self.horizontal, self.face = 1, f.horizontal or 1, f.face or 1 --movement and face directions
    self.isHittable = false
    self.isDisabled = false
    if f.flipOnBreak ~= false then
        self.flipOnBreak = true --flip face to the attacker on break (true by default)
    end
    self.decreaseHeightValue = f.decreaseHeightValue or 0 -- by pixels. Decrease height on every damaged sprite change
    self.faceFix = self.face   --keep the same facing after 1st hit
    self.sfx.dead = f.sfxDead --on death sfx
    self.sfx.onHit = f.sfxOnHit --on hurt sfx
    self.sfx.onBreak = f.sfxOnBreak --on sprite change/fall sfx
    self.sfx.grab = f.sfxGrab --on being grabbed sfx
    self.isMovable = f.isMovable
    self.isObstacle = not self.isMovable -- can walk trough it
    self.weight = f.weight or 1.5
    self.gravity = self.gravity * self.weight
    self.deathDelay = 1 --seconds to remove
    self.oldFrame = 1 --Old sprite frame N to start particles on change
    self.priority = 2
    self:setState(self.stand)
end

function StageObject:updateSprite(dt)
--    updateSpriteInstance(self.sprite, dt, self)
end

function StageObject:setSprite(anim)
    if anim ~= "stand" then
        return
    end
    setSpriteAnimation(self.sprite, anim)
end

function StageObject:drawSprite(x, y)
    self.sprite.flipH = self.faceFix
    drawSpriteInstance(self.sprite, x, y, self:calcDamageFrame())
end

function StageObject:calcShadowSpriteAndTransparency()
    local transparency = self.deathDelay < 1 and 255 * math.sin(self.deathDelay) or 255
    if isDebug() and not self:isInvincibile() then
        colors:set("debugRedShadow", nil, transparency)
    else
        colors:set("black", nil, transparency)
    end
    local spr = self.sprite
    local image = imageBank[spr.def.spriteSheet]
    local sc = spr.def.animations[spr.curAnim][self:calcDamageFrame()]
    local shadowAngle = -stage.shadowAngle * spr.flipH
    return image, spr, sc, shadowAngle, -2
end

function StageObject:checkCollisionAndMove(dt)
    local success = true
    if self.move then
        self.move:update(dt) --tweening
        self.shape:moveTo(self.x, self.y)
    else
        local stepx = self.speed_x * dt * self.horizontal
        local stepy = self.speed_y * dt * self.vertical
        self.shape:moveTo(self.x + stepx, self.y + stepy)
    end
    if not self:canFall() then
        for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.isObstacle then
                self.shape:move(separatingVector.x, separatingVector.y)
                success = false
            end
        end
    end
    local cx,cy = self.shape:center()
    self.x = cx
    self.y = cy
    return success, 0, 0
end

function StageObject:updateAI(dt)
    if self.isDisabled then
        return
    end
    self:updateShake(dt)
    Unit.updateAI(self, dt)
end

function StageObject:isImmune()   --Immune to the attack?
    local h = self.isHurt
    if h.type == "shockWave" or self.isDisabled then
        -- shockWave has no effect on players & stage objects
        self.isHurt = nil --free hurt data
        return true
    end
    return false
end

function StageObject:onHurt()
    local h = self.isHurt
    if not h then
        return
    end
    -- got Immunity?
    if self:isImmune() then
        self.isHurt = nil
        return
    end
    local newFacing = -h.horizontal
    self:removeTweenMove()
    self:onHurtDamage()
    self:afterOnHurt()
    --Check for breaking change
    local curFrame = self:calcDamageFrame()
    if self.oldFrame ~= curFrame then -- on the frame change
        if self.flipOnBreak then
            self.faceFix = newFacing -- keep previous facing
        end
        self:showEffect("breakMetal", h)
        self.height = self.height - self.decreaseHeightValue
    end
    self.oldFrame = curFrame
    self.isHurt = nil --free hurt data
end

function StageObject:standStart()
    self.isHittable = true
    self.victims = {}
    self:setSprite("stand")
end
function StageObject:standUpdate(dt)
    if self.isGrabbed then
        self:setState(self.grabbed)
        return
    end
end
StageObject.stand = {name = "stand", start = StageObject.standStart, exit = nop, update = StageObject.standUpdate, draw = Unit.defaultDraw}

function StageObject:getUpStart()
    self.isHittable = false
    self.isThrown = false
    dpo(self, self.state)
    if not self:canFall() then
        self.z = self:getMinZ()
    end
    if self.hp <= 0 then
        self:setState(self.dead)
        return
    end
end
function StageObject:getUpUpdate(dt)
    if self.speed_x <= 0 then
        self:setState(self.stand)
        return
    end
end
StageObject.getUp = {name = "getUp", start = StageObject.getUpStart, exit = nop, update = StageObject.getUpUpdate, draw = Unit.defaultDraw}

function StageObject:hurtStart()
    self.isHittable = true
end
function StageObject:hurtUpdate(dt)
    if self.speed_x <= 0 then
        self:setState(self.stand)
        return
    end
end
StageObject.hurt = {name = "hurt", start = StageObject.hurtStart, exit = nop, update = StageObject.hurtUpdate, draw = Unit.defaultDraw}

function StageObject:fallStart()
    if not self.isMovable then
        self:setState(self.knockedDown)
        return
    end
    Character.fallStart(self)
end
StageObject.fall = {name = "fall", start = StageObject.fallStart, exit = nop, update = Character.fallUpdate, draw = StageObject.defaultDraw}

return StageObject
