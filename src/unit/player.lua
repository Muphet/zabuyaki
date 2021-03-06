local class = require "lib/middleclass"
local Player = class('Player', Character)

local function nop() end
local dashAttackDelta = 0.25

function Player:initialize(name, sprite, x, y, f, input)
    if not f then
        f = {}
    end
    self.lives = GLOBAL_SETTING.MAX_LIVES
    self.hp = f.hp or self.hp or 100
    Character.initialize(self, name, sprite, x, y, f, input)
    self:initAttributes()
    self.type = "player"
    self.friendlyDamage = 1 --1 = full damage on other players
end

--function Player:initAttributes()
--end

function Player:setOnStage(stage)
    self.pid = GLOBAL_SETTING.PLAYERS_NAMES[self.id] or "P?"
    self.showPIDDelay = 3
    Unit.setOnStage(self, stage)
    self.victimLifeBar = nil   -- remove enemy bar under yours
    self:disableGhostTrails()
    registerPlayer(self)
    logPlayer:reset(self.id)
end

function Player:isAlive()
    if (self.playerSelectMode == 0 and credits > 0 and self.state == "useCredit")
            or (self.playerSelectMode >= 1 and self.playerSelectMode < 5)
    then
        return true
    elseif self.playerSelectMode >= 5 then
        -- Did not use continue
        return false
    end
    return self.hp + self.lives > 0
end

function Player:isInUseCreditMode()
    if self.state ~= "useCredit" then
        return false
    end
    return true
end

local edgesTolerance = 0
local topEdgeTolerance = 0
function Player:checkCollisionAndMove(dt)
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
    if self.z <= 0 then
        for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if (o.isObstacle and o.z <= 0 and o.hp > 0) or o.type == "stopper"
            then
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
            if not self.obstacles[o] and (
                o.type == "wall"
                or o.type == "stopper"
                or o:isInstanceOf(StageObject)
                )
            then
                if o:isInstanceOf(StageObject) then
                    if self.z + topEdgeTolerance >= o.height then
                        if math.abs(separatingVector.x) > edgesTolerance or math.abs(separatingVector.y) > edgesTolerance then
                            self.obstacles[o] = true
                            self:setMinZ(o) -- jumped on the obstacle
                        end
                    else
                        -- jump trough the obstacle
                    end
                else
                    self.shape:move(separatingVector.x, separatingVector.y)
                    if math.abs(separatingVector.x) > 1.5 or math.abs(separatingVector.y) > 1.5 then
                        stepx, stepy = separatingVector.x, separatingVector.y
                        success = false
                    end
                end
            end
        end
    end
    local cx,cy = self.shape:center()
    self.x = cx
    self.y = cy
    return success, stepx, stepy
end

function Player:isStuck()
    for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
        local o = other.obj
        if o.type == "wall"
                or o.type == "stopper"
        then
--            print(self.name, self.x, "STUCK")
            return true
        end
    end
    return false
end

function Player:isDoubleTapValid()
    local doubleTap = self.b.horizontal.doubleTap
    return self.face == doubleTap.lastDoubleTapDirection and love.timer.getTime() - doubleTap.lastDoubleTapTime <= delayWithSlowMotion(dashAttackDelta)
end

function Player:updateAI(dt)
    if self.isDisabled then
        return
    end
    --DEBUG: highlight P1 on the possible Special triggering
    if self.statesForSpecialToleranceDelay[self.state] then
        if love.timer.getTime() - self.lastStateTime <= delayWithSlowMotion(self.specialToleranceDelay)
        then
            startUnitHighlight(self, self.state.." YES") --default lightBlue color
        else
            startUnitHighlight(self, self.state.." NO", "red")
        end
    else
        stopUnitHighlight(self)
    end
    if self.moves.specialDefensive or self.moves.specialOffensive or self.moves.specialDash then
        if not self:canFall() and isSpecialCommand(self.b) then
            if not self.statesForSpecialToleranceDelay[self.state]
                or love.timer.getTime() - self.lastStateTime <= delayWithSlowMotion(self.specialToleranceDelay)
            then
                local hv = self.b.horizontal:getValue()
                if not self:isDoubleTapValid() then
                    if hv ~= 0 and self.moves.specialOffensive
                        and self.statesForSpecialOffensive[self.state]
                    then
                        self:releaseGrabbed()
                        self:removeTweenMove()
                        self.face = hv
                        if self.state == "duck2jump" and self.lastState == "run" then
                            self:setState(self.specialDash)
                            return
                        end
                        self:setState(self.specialOffensive)
                        return
                    end
                    if self.moves.specialDefensive and self.statesForSpecialDefensive[self.state] then
                        self:releaseGrabbed()
                        self:setState(self.specialDefensive)
                        return
                    end
                end
                if self.moves.specialDash and self.statesForSpecialDash[self.state]
                    and ( hv ~= 0 or ( hv == 0 or self:isDoubleTapValid() ) )
                then
                    self:releaseGrabbed()
                    self:removeTweenMove()
                    self:setState(self.specialDash)
                    return
                end
            end
        end
    end
    if self.moves.dashAttack and self.b.attack:pressed() then
        if self.statesForDashAttack[self.state] and self:isDoubleTapValid() then
            self:setState(self.dashAttack)
        end
    end
    if self.moves.chargeAttack then
        if self.b.attack:isDown() and self.statesForChargeAttack[self.state] then
            self.chargeTimer = self.chargeTimer + dt
        else
            if self.chargeTimer >= self.chargedAt and self.statesForChargeAttack[self.state] then
                if self.speed_y == 0 and self:canFall() then
                    if self.chargeDashAttack then
                        self:setState(self.chargeDashAttack)
                    elseif self.chargeAttack then
                        self:setState(self.chargeAttack)
                    end
                elseif not self:canFall() then
                    self:setState(self.chargeAttack)
                end
            end
            self.chargeTimer = 0
        end
    end
    Character.updateAI(self, dt)
end

function Player:isImmune()   --Immune to the attack?
    local h = self.isHurt
    if not h then
        return true
    end
    if h.type == "shockWave" or self.isDisabled then
        self.isHurt = nil --free hurt data
        return false
    end
    return false
end

function Player:onHurtDamage()
    local h = self.isHurt
    if not h then
        return
    end
    if h.continuous then
        h.source.victims[self] = true
    end
    self:releaseGrabbed()
    h.damage = h.damage or 100  --TODO debug if u forgot
    dp(h.source.name .. " damaged "..self.name.." by "..h.damage..". HP left: "..(self.hp - h.damage)..". Lives:"..self.lives)
    self:updateAttackersLifeBar(h)
    -- Score
    h.source:addScore( h.damage * 10 )
    self.killerId = h.source
    self:onShake(1, 0, 0.03, 0.3)   --shake a character
    mainCamera:onShake(0, 1, 0.03, 0.3)	--shake the screen for Players only

    self:decreaseHp(h.damage)
    if h.type == "simple" then
        self.isHurt = nil --free hurt data
        return
    end

    self:playHitSfx(h.damage)
    if h.source ~= self then
        if h.source.speed_x == 0 then
            self.face = -h.source.face --turn face to the still(pulled back) attacker
        else
            if h.source.horizontal ~= h.source.face then
                self.face = -h.source.face --turn face to the back-jumping attacker
            else
                self.face = -h.source.horizontal --turn face to the attacker
            end
        end
    end
end

local players_list = { RICK = 1, KISA = 2, CHAI = 3, YAR = 4, GOPPER = 5, NIKO = 6, SVETA = 7, ZEENA = 8, BEATNICK = 9, SATOFF = 10 }
local players_palette_list = { 0, 0, 0, 0, 1, 1, 1, 1, 0, 0 }
function Player:useCreditStart()
    self.isHittable = false
    self.lives = self.lives - 1
    if self.lives > 0 then
        dp(self.name.." used 1 life to respawn")
        self:setState(self.respawn)
        return
    end
    self.displayDelay = 10
    -- Player select
    self.playerSelectMode = 0
    self.playerSelectCur = players_list[self.name] or 1
end
function Player:useCreditUpdate(dt)
    if self.playerSelectMode == 5 then --self.isDisabled then
        return
    end
    if self.playerSelectMode == 0 then
        -- 10 seconds to choose
        self.displayDelay = self.displayDelay - dt
        if credits <= 0 or self.displayDelay <= 0 then
            -- n credits -> game over
            self.playerSelectMode = 5
            unregisterPlayer(self)
            return
        end
        -- wait press to use credit
        -- add countdown 9 .. 0 -> Game Over
        if self.b.attack:pressed() then
            dp(self.name .. " used 1 Credit to respawn")
            credits = credits - 1
            self:addScore(1) -- like CAPCM
            self:playSfx("menuSelect")
            self.displayDelay = 1 -- delay before respawn
            self.playerSelectMode = 1
        end
    elseif self.playerSelectMode == 1 then
        -- wait 1 sec before player select
        if self.displayDelay > 0 then
            -- wait before respawn / char select
            self.displayDelay = self.displayDelay - dt
            if self.displayDelay <= 0 then
                self.displayDelay = 10
                self.playerSelectMode = 2
            end
        end
    elseif self.playerSelectMode == 2 then
        -- Select Player
        -- 10 sec countdown before auto confirm
        if self.b.attack:pressed() or self.displayDelay <= 0 then
            self.displayDelay = 0
            self.playerSelectMode = 4
            self:playSfx("menuSelect")
            local player = HEROES[self.playerSelectCur].hero:new(self.name,
                HEROES[self.playerSelectCur].spriteInstance,
                self.x, self.y,
                nil, --{ shapeType = "polygon", shapeArgs = { 1, 0, 13, 0, 14, 3, 13, 6, 1, 6, 0, 3 } }
                self.b
            )
            player.playerSelectMode = 3
            player:setState(self.respawn)
            player.id = self.id
            player.palette = players_palette_list[self.playerSelectCur] or 0
            registerPlayer(player)
            fixPlayersPalette(player)
            dp(player.x, player.y, player.name, player.playerSelectMode, "Palette:", player.palette)
            SELECT_NEW_PLAYER[#SELECT_NEW_PLAYER + 1] = { id = self.id, player = player, deletePlayer = self }
            return
        else
            self.displayDelay = self.displayDelay - dt
        end
        ---
        if self.b.horizontal:pressed(-1) or self.b.vertical:pressed(-1)
            or self.b.horizontal:pressed(1) or self.b.vertical:pressed(1)
        then
            if self.b.horizontal:pressed(-1) or self.b.vertical:pressed(-1) then
                self.playerSelectCur = self.playerSelectCur - 1
            else
                self.playerSelectCur = self.playerSelectCur + 1
            end
            if isDebug() then
                if self.playerSelectCur > players_list.SATOFF then
                    self.playerSelectCur = 1
                end
                if self.playerSelectCur < 1 then
                    self.playerSelectCur = players_list.SATOFF
                end
            else
                if self.playerSelectCur > players_list.YAR then
                    self.playerSelectCur = 1
                end
                if self.playerSelectCur < 1 then
                    self.playerSelectCur = players_list.YAR
                end
            end
            self:playSfx("menuMove")
            self:onShake(1, 0, 0.03, 0.3)   --shake name + face icon
            self.name = HEROES[self.playerSelectCur][1].name
            self.sprite = getSpriteInstance(HEROES[self.playerSelectCur].spriteInstance)
            self:setSprite("stand")
            fixPlayersPalette(self)
            self.shader = getShader(self.sprite.def.spriteName:lower(), self.palette)
            self.lifeBar = LifeBar:new(self)
        end
    elseif self.playerSelectMode == 3 then
        -- Spawn selected player
    elseif self.playerSelectMode == 4 then
        -- Delete on Selecting a new Character
    elseif self.playerSelectMode == 5 then
        -- Game Over
    end
end
Player.useCredit = {name = "useCredit", start = Player.useCreditStart, exit = nop, update = Player.useCreditUpdate, draw = Unit.defaultDraw}

function Player:respawnStart()
    self.isHittable = false
    stage:freezeZoomingFor(1.5)
    self.x, self.y = stage:getSafeRespawnPosition(self)
    dpo(self, self.state)
    self:setSprite("respawn")
    self.deathDelay = 3 --seconds to remove
    self.hp = self.maxHp
    self.bounced = 0
    self.speed_z = 0
    self.z = love.math.random( 235, 245 )    --TODO get Z from the Tiled
    stage:resetTime()
end
function Player:respawnUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt)
    elseif self.bounced == 0 then
        self.playerSelectMode = 0 -- remove player select text
        self.speed_z = 0
        self.z = self:getMinZ()
        self:playSfx(self.sfx.step)
        if self.sprite.curFrame == 1 then
            self.sprite.elapsedTime = 10 -- seconds. skip to pickUp 2 frame
        end
        self:checkAndAttack(
            { x = 0, y = 0, width = 320 * 2, depth = 240 * 2, height = 240 * 2, damage = 0, type = "shockWave" },
            false
        )
        mainCamera:onShake(0, 2, 0.03, 0.3)	--shake the screen on respawn
        if self.sprite.def.fallsOnRespawn then
            --clouds under belly
            self:showEffect("bellyLanding")
        else
            --landing dust clouds by the sides
            self:showEffect("jumpLanding")
        end
        self.bounced = 1
    end
    --self.victimLifeBar = nil   -- remove enemy bar under yours
end
Player.respawn = {name = "respawn", start = Player.respawnStart, exit = nop, update = Player.respawnUpdate, draw = Unit.defaultDraw}

function Player:deadStart()
    self.isHittable = false
    self:setSprite("fallen")
    dp(self.name.." is dead.")
    self.hp = 0
    self.isHurt = nil
    self:releaseGrabbed()
    if not self:canFall() then
        self.z = self:getMinZ()
    end
    --self:onShake(1, 0, 0.1, 0.7)
    self:playSfx(self.sfx.dead)
    if self.killerId then
        self.killerId:addScore( self.scoreBonus )
    end
end
function Player:deadUpdate(dt)
    if self.isDisabled then
        return
    end
    --dp(self.name .. " - dead update", dt)
    if self.deathDelay <= 0 then
        self:setState(self.useCredit)
        return
    else
        self.deathDelay = self.deathDelay - dt
        if self:canFall() then
            self:calcFreeFall(dt)
        else
            self.z = self:getMinZ()
        end
    end
end
Player.dead = {name = "dead", start = Player.deadStart, exit = nop, update = Player.deadUpdate, draw = Unit.defaultDraw}

return Player
