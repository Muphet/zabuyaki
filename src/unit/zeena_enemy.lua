local class = require "lib/middleclass"
local Zeena = class('Zeena', Gopper)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Zeena:initialize(name, sprite, input, x, y, f)
    self.hp = self.hp or 50
    self.scoreBonus = self.scoreBonus or 300
    self.tx, self.ty = x, y
    Gopper.initialize(self, name, sprite, input, x, y, f)
    Zeena.initAttributes(self)
    self.subtype = "gopnitsa"
    self.whichPlayerAttack = "weak" -- random far close weak healthy fast slow
end

function Zeena:initAttributes()
    self.moves = { -- list of allowed moves
        run = false, sideStep = true, pickup = true,
        jump = true, jumpAttackForward = true, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = true,
        grab = false, grabSwap = false, grabAttack = false,
        shoveUp = false, shoveDown = false, shoveBack = false, shoveForward = false,
        dashAttack = false, offensiveSpecial = false, defensiveSpecial = false,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
    }
    self.velocityWalk_x = 93
    self.walkSpeed = self.velocityWalk_x / 1
    self.velocityWalk_y = 45
    self.velocitySlide = 200 --horizontal speed of the slide kick
    self.velocitySlide_y = 20 --vertical speed of the slide kick
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.zeenaDeath
    self.sfx.jumpAttack = sfx.zeenaAttack
    self.sfx.step = "kisaStep"
end

Zeena.onFriendlyAttack = Enemy.onFriendlyAttack -- TODO: remove once this class stops inheriting from Gopper

function Zeena:_updateAI(dt)
    Enemy.updateAI(self, dt)

    self.cooldown = self.cooldown - dt --when <=0 u can move

    --local completeMovement = self.move:update(dt)
    self.AiPoll_1 = self.AiPoll_1 - dt
    self.AiPoll_2 = self.AiPoll_2 - dt
    self.AiPoll_3 = self.AiPoll_3 - dt
    if self.AiPoll_1 < 0 then
        self.AiPoll_1 = self.maxAiPoll_1 + math.random()
        -- Intro -> Stand
        if self.state == "intro" then
            -- see near players?
            local dist = self:getDistanceToClosestPlayer()
            if dist < self.wakeupRange
                    or (dist < self.delayedWakeupRange and self.time > self.wakeupDelay )
            then
                if not self.target then
                    self:pickAttackTarget()
                    if not self.target then
                        self:setState(self.intro)
                        return
                    end
                end
                self.face = -self.target.face --face to player
                self:setState(self.stand)
            end
        elseif self.state == "stand" then
            if self.cooldown <= 0 then
                --can move
                if not self.target then
                    self:pickAttackTarget()
                    if not self.target then
                        self:setState(self.intro)
                        return
                    end
                end
                --local t = dist(self.target.x, self.target.y, self.x, self.y)
--                if t < 400 and t >= 100 and
--                        math.floor(self.y / 4) == math.floor(self.target.y / 4) then
--                    self:setState(self.run)
--                    return
--                end
                --if t < 300 then
                    self:setState(self.walk)
                    --return
                --end
            end
        elseif self.state == "walk" then
            --self:pickAttackTarget()
            --self:setState(self.stand)
            --return
            if not self.target then
                self:pickAttackTarget()
                if not self.target then
                    self:setState(self.intro)
                    return
                end
            end
            local t = dist(self.target.x, self.target.y, self.x, self.y)
            if t < 100 and t >= 30
                    and math.floor(self.y / 4) == math.floor(self.target.y / 4) then
                self.vel_x = self.velocityWalk_x
                self:setState(self.jump)
                return
            end
            if self.cooldown <= 0 then
                if math.abs(self.x - self.target.x) <= 50
                        and math.abs(self.y - self.target.y) <= 6
                then
                    self:setState(self.combo)
                    return
                end
            end
        elseif self.state == "run" then
            --self:pickAttackTarget()
            --self:setState(self.stand)
            --return
        end
        -- Facing towards the target
        self:faceToTarget()
    end
    if self.AiPoll_2 < 0 then
        self.AiPoll_2 = self.maxAiPoll_2 + math.random()
    end
    if self.AiPoll_3 < 0 then
        self.AiPoll_3 = self.maxAiPoll_3 + math.random()

        if self.state == "walk" then
        elseif self.state == "run" then
        end

        self:pickAttackTarget()

--        local t = dist(self.target.x, self.target.y, self.x, self.y)
--        if t < 600 and self.state == "walk" then
--            --set dest
--        end
    end
end

return Zeena