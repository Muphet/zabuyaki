local class = require "lib/middleclass"
local Unit = class("Unit")

local function nop() end
local clamp = clamp

GLOBAL_UNIT_ID = 1

function Unit:initialize(name, sprite, x, y, f, input)
    --f options {}: shapeType, shapeArgs, hp, score, shader, palette, color, sfxOnHit, sfxDead, func
    if not f then
        f = {}
    end
    self.isDisabled = true
    self.sprite = getSpriteInstance(sprite)
    self.spriteOverlay = nil
    self.name = name or "Unknown"
    self.type = "unit"
    self.subtype = ""
    self.deathDelay = 3 --seconds to remove
    self.lives = f.lives or self.lives or 0
    self.maxHp = f.hp or self.hp or 1
    self.hp = self.maxHp
    self.scoreBonus = f.score or self.scoreBonus or 0 --goes to your killer
    self.b = input or DUMMY_CONTROL

    self.x, self.y, self.z = x, y, 0
    self.height = f.height or 50
    self.width = 10 --calcs from the hitbox in addShape()
    self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
    self.speed_x, self.speed_y, self.speed_z = 0, 0, 0
    self.gravity = 800 --650 * 2
    self.weight = 1
    self.friction = 1650 -- speed penalty for stand (when you slide on ground)
    self.repelFriction = 1650 / 2
    self.customFriction = 0 --used in :calcMovement
    self.pushBackOnHitSpeed = 65
    self.toSlowDown = true --used in :calcMovement
    self.isMovable = false --cannot be moved by attacks / can be grabbed
    self.shape = nil
    self.state = "nop"
    self.lastStateTime = love.timer.getTime()
    self.prevState = "" -- text name
    self.lastState = "" -- text name
    self.shake = {x = 0, y = 0, sx = 0, sy = 0, delay = 0, f = 0, freq = 0, m = {-1, -0.5, 0, 0.5, 1, 0.5, 0, -0.5}, i = 1 }
    self.sfx = {}
    self.sfx.onHit = f.sfxOnHit --on hurt sfx
    self.sfx.dead = f.sfxDead --on death sfx
    self.isObstacle = false
    self.isHittable = false
    self.isGrabbed = false
    self.grabContext = {source = nil, target = nil, grabTimer = 0 }
    self.victims = {} -- [victim] = true
    self.obstacles = {} -- [obstacle] = true
    self.isThrown = false
    self.invincibilityTimeout = 0.2 -- invincibility time after getUp state
    self.invincibilityTimer = 0     -- invincible if > 0
    self.shader = f.shader  --it is set on spawn (alter unit's colors)
    self.palette = f.palette  --unit's shader/palette number
    self.color = f.color or "white" --support additional color tone. Not used now
    self.particleColor = f.particleColor
    self.ghostTrails = {
        enabled = false,
        fade = false,
        i = 1,
        n = 0,
        time = 0,
        delay = 0.1, -- interval of removal of 1 ghost on ghostTrailsFadeout
        shift = 2,  -- frames count back to the past per the ghost
        ghost = {}
    }
    self.func = f.func  --custom function call onDeath
    self.finalizerFunc = nop  -- called on every updateAI if present
    self.draw = nop
    self.update = nop
    self.start = nop
    self.exit = nop
    self.priority = 3   -- priority to show lifeBar (1 highest)
    self.id = GLOBAL_UNIT_ID --to stop Y coord sprites flickering
    GLOBAL_UNIT_ID= GLOBAL_UNIT_ID + 1
    self.pid = ""
    self.showPIDDelay = 0
    self:addShape(f.shapeType or "rectangle", f.shapeArgs or {self.x, self.y, 15, 7})
    self:setState(self.stand)
    dpoInit(self)
end

function Unit:setOnStage(stage)
--    dp("SET ON STAGE", self.name, self.id, self.palette)
    stage.objects:add(self)
    self.shader = getShader(self.sprite.def.spriteName:lower(), self.palette)
    self.lifeBar = LifeBar:new(self)
end

function Unit:addShape(shapeType, shapeArgs)
    shapeType, shapeArgs = shapeType or self.shapeType, shapeArgs or self.shapeArgs
    if not self.shape then
        if shapeType == "rectangle" then
            self.shape = stage.world:rectangle(unpack(shapeArgs))
            self.width = shapeArgs[3] or 1
        elseif shapeType == "ellipse" then
            self.shape = stage.world:circle(unpack(shapeArgs))
            self.width = shapeArgs[3] * 2 or 1
        elseif shapeType == "polygon" then
            self.shape = stage.world:polygon(unpack(shapeArgs))
            local xMin, xMax = shapeArgs[1], shapeArgs[1]
            for i = 1, #shapeArgs, 2 do
                local x = shapeArgs[i]
                if x < xMin then
                    xMin = x
                end
                if x > xMax then
                    xMax = x
                end
            end
            self.width = xMax - xMin
        elseif shapeType == "point" then
            self.shape = stage.world:point(unpack(shapeArgs))
            self.width = 1
        else
            dp(self.name.."("..self.id.."): Unknown shape type -"..shapeType)
        end
        if shapeArgs.rotate then
            self.shape:rotate(shapeArgs.rotate)
        end
        self.shape.obj = self
    else
        dp(self.name.."("..self.id..") has predefined shape")
    end
end

function Unit:setState(state, condition)
    if state then
        self.prevStateTime = self.lastStateTime
        self.lastStateTime = love.timer.getTime()
        self.prevState = self.lastState
        self.lastState = self.state
        self.lastFace = self.face
        self.lastVertical = self.vertical
        self:exit()
        self.customFriction = 0
        self.toSlowDown = true
        self.state = state.name
        self.draw = state.draw
        self.update = state.update
        self.start = state.start
        self.exit = state.exit
        self.condition = condition
        self:start()
        self:updateSprite(0)
    end
end
function Unit:getLastStateTime()
    -- time from the switching to current frame
    return love.timer.getTime() - self.lastStateTime
end
function Unit:getPrevStateTime()
    -- time from the previous to the last switching to current frame
    return love.timer.getTime() - self.prevStateTime
end
function Unit:addHp(hp)
    self.hp = self.hp + hp
    if self.hp > self.maxHp then
        self.hp = self.maxHp
    end
end
function Unit:decreaseHp(damage)
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self.hp = 0
        if self.func then   -- custom function on death
            self:func(self)
            self.func = nil
        end
    end
end
function Unit:applyDamage(damage, type, source, repel_x, sfx1)
    self.isHurt = {source = source or self, state = self.state, damage = damage,
                   type = type, repel_x = repel_x or 0,
                   horizontal = self.face, isThrown = false,
                   x = self.x, y = self.y, z = self.z }
    if sfx1 then
        self:playSfx(sfx1)
    end
end
function Unit:updateAI(dt)
    if self.isDisabled then
        return
    end
    if self.finalizerFunc then
        self.finalizerFunc()
    end
    self:updateSprite(dt)
    self:calcMovement(dt)
    if self.platform and not self.platform.isDisabled and self.platform.shape then
        if not self.shape:collidesWith(self.platform.shape) then
            self.platform = nil
        end
    end
    self:updateGhostTrails(dt)
end

function Unit:isInvincibile()
    if self.isDisabled or not self.isHittable or self.invincibilityTimer > 0 or self.hp <= 0 then
        return true
    end
    return false
end

-- stop unit from moving by tweening
function Unit:removeTweenMove()
    --dp(self.name.." removed tween move")
    self.move = nil
end

-- private
function Unit:tweenMove(dt)
    local complete = true
    if self.move then
        complete = self.move:update(dt) --tweening
        self.shape:moveTo(self.x, self.y)
    end
    return complete
end

function Unit:checkCollisionAndMove(dt)
    local success = true
    local stepx, stepy = 0, 0
    if self.move then
        self.move:update(dt) --tweening
        self.shape:moveTo(self.x, self.y)
    else
        stepx = self.speed_x * dt * self.horizontal
        stepy = self.speed_y * dt * self.vertical
        self.shape:moveTo(self.x + stepx, self.y + stepy)
    end
    if not self:canFall() then
        for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.isObstacle and o.z <= 0 and o.hp > 0 then
                self.shape:move(separatingVector.x, separatingVector.y)
                if math.abs(separatingVector.y) > 1.5 or math.abs(separatingVector.x) > 1.5 then
                    stepx, stepy = separatingVector.x, separatingVector.y
                    success = false
                end
            end
        end
    else
        for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.isObstacle	then
                self.shape:move(separatingVector.x, separatingVector.y)
                if math.abs(separatingVector.y) > 1.5 or math.abs(separatingVector.x) > 1.5 then
                    stepx, stepy = separatingVector.x, separatingVector.y
                    success = false
                end
            end
        end
    end
    local cx,cy = self.shape:center()
    self.x = cx
    self.y = cy
    return success, stepx, stepy
end

function Unit:ignoreCollisionAndMove(dt)
    if self.move then
        self.move:update(dt) --tweening
        self.shape:moveTo(self.x, self.y)
    else
        local stepx = self.speed_x * dt * self.horizontal
        local stepy = self.speed_y * dt * self.vertical
        self.shape:moveTo(self.x + stepx, self.y + stepy)
    end
    local cx,cy = self.shape:center()
    self.x = cx
    self.y = cy
end

function Unit:isStuck()
    for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
        local o = other.obj
        if o.type == "wall"	then
            return true
        end
    end
    return false
end

function Unit:hasPlaceToStand(x, y)
    local testShape = stage.testShape
    testShape:moveTo(x, y)
    for other, separatingVector in pairs(stage.world:collisions(testShape)) do
        local o = other.obj
        if o.type == "wall"	then
            if math.abs(separatingVector.y) > 1.5 or math.abs(separatingVector.x) > 1.5 then
                success = false
            end
        end
    end
    return true
end

function Unit:canFall()
    if self.z > self:getMinZ() then
        return true
    end
    return false
end

function Unit:getMinZ()
    local g = self.grabContext
    if self.isGrabbed and g and g.source then
        return g.source.z
    elseif self.platform and self.platform.hp > 0 then
        return self.platform.z + self.platform.height
    end
    return 0
end

function Unit:setMinZ(platform)
    if self.platform then
        if self.platform.height < platform.height then
            self.platform = platform
        elseif math.abs(platform.x - self.x) < math.abs(self.platform.x - self.x)
            or math.abs(platform.y - self.y) < math.abs(self.platform.y - self.y)
        then
            self.platform = platform
        end
    else
        self.platform = platform
    end
end

function Unit:calcFreeFall(dt, speed)
    self.z = self.z + dt * self.speed_z
    self.speed_z = self.speed_z - self.gravity * dt * (speed or self.jumpSpeedMultiplier)
end

function Unit:canMove()
    if self.isMovable then
        return true
    end
    return false
end

function Unit:calcFriction(dt, friction)
    local frctn = friction or self.friction
    if self.speed_x > 0 then
        self.speed_x = self.speed_x - frctn * dt
        if self.speed_x < 0 then
            self.speed_x = 0
        end
    else
        self.speed_x = 0
    end
    if self.speed_y > 0 then
        self.speed_y = self.speed_y - frctn * dt
        if self.speed_y < 0 then
            self.speed_y = 0
        end
    else
        self.speed_y = 0
    end
end

local ignoreObstacles = { combo = true, chargeAttack = true, eventMove = true }
function Unit:calcMovement(dt)
    if not self.toSlowDown then
        if ignoreObstacles[self.state] then
            self.successfullyMoved, self.collision_x, self.collision_y = self:ignoreCollisionAndMove(dt)
        else
            self.successfullyMoved, self.collision_x, self.collision_y = true, 0, 0
        end
    else
        --try to move and get x,y vectors to recover from collision
        -- these are not collision x y. should return vectors.
        self.successfullyMoved, self.collision_x, self.collision_y = self:checkCollisionAndMove(dt)
    end
    if not self:canFall() then
        if self.toSlowDown then
            if self.customFriction ~= 0 then
                self:calcFriction(dt, self.customFriction)
            else
                self:calcFriction(dt)
            end
        else
            self:calcFriction(dt)
        end
    end
end

function Unit:calcDamageFrame()
    -- HP max..0 / Frame 1..#max
    local spr = self.sprite
    local s = spr.def.animations[spr.curAnim]
    local n = clamp(math.floor((#s-1) - (#s-1) * self.hp / self.maxHp)+1,
        1, #s)
    return n
end

function Unit:moveStatesInit()
    local g = self.grabContext
    local t = g.target
    if not g then
        error("ERROR: No target for init")
    end
    g.init = {
        x = self.x, y = self.y, z = self.z,
        face = self.face, tFace = t.face,
        --tx = t.x, ty = t.y, tz = t.z,
        tFrame = -1,
        lastFrame = -1
    }
end

function Unit:moveStatesApply()
    local moves = self.sprite.def.animations[self.sprite.curAnim].moves
    local frame = self.sprite.curFrame
    if not moves or not moves[frame] then
        return
    end
    local g = self.grabContext
    local t = g.target
    if not g then
        error("ERROR: No target for apply")
    end
    local i = g.init
    if i.lastFrame ~= frame then
        local m = moves[frame]
        if m.face then
            self.face = i.face * m.face
        end
        if m.tFace then
            t.face = i.tFace * m.tFace
        end
        if m.tFrame and t.sprite.def.animations.grabbedFrames then
            t.sprite.curAnim = "grabbedFrames"
            t.sprite.curFrame = m.tFrame
        end
        if m.x then
            self.x = i.x + m.x * self.face
        end
        if m.y then --rarely used
            self.y = i.y + m.y
        end
        if m.z then
            self.z = i.z + m.z
        end
        if m.ox then
            t.x = self.x + m.ox * self.face
        end
        if m.oy then --rarely used
            t.y = self.y + m.oy
        end
        if m.oz then
            t.z = self.z + m.oz
        end
        i.lastFrame = frame
    end
    if isDebug() and t then
        attackHitBoxes[#attackHitBoxes+1] = {x = self.x, sx = 0, y = self.y, w = 11, h = 0.1, z = self.z, collided = false }
        attackHitBoxes[#attackHitBoxes+1] = {x = t.x, sx = 0, y = t.y, w = 9, h = 0.1, z = t.z, collided = true }
    end
end

function Unit:updateAttackersLifeBar(h)
    if h.type ~= "shockWave"
        and (not h.source.victimLifeBar
        or h.source.victimLifeBar.source.priority >= self.priority
        or h.source.victimLifeBar.timer <= LifeBar.OVERRIDE
    )
    then
        -- show enemy bar for other attacks
        h.source.victimLifeBar = self.lifeBar:setAttacker(h.source)
        if self.id <= GLOBAL_SETTING.MAX_PLAYERS then
            self.victimLifeBar = h.source.lifeBar:setAttacker(self)
        end
    end
end

function Unit:getZIndex()
    local g = self.grabContext
    if self.isGrabbed and g and g.source then
        return g.source.y - 0.001
    end
    if self.platform then
        return self.platform.y + 0.005
    end
    return self.y
end

function Unit:getMovementTime(x, y) -- time needed to walk/run to the next point x,y
    local dist = math.sqrt( (x - self.x) ^ 2 + (y - self.y) ^ 2 )
    if self.sprite.curAnim == "run" then
        if math.abs(x - self.x) / 2 < math.abs(y - self.y) then
            return dist / self.runSpeed_y
        end
        return dist / self.runSpeed_x
    end
    if math.abs(x - self.x) / 2 < math.abs(y - self.y) then
        return dist / self.walkSpeed_y
    end
    return dist / self.walkSpeed_x
end

return Unit
