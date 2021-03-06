local spriteSheet = "res/img/char/rick.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

local stepFx = function(slf, cont)
    slf:showEffect("step")
end
local grabFrontAttack = function(slf, cont)
    --default values: 10,0,20,12, "hit", slf.speed_x
    slf:checkAndAttack(
        { x = 18, y = 21, width = 26, damage = 9 },
        cont
    )
end
local grabFrontAttackLast = function(slf, cont)
    slf:checkAndAttack(
        { x = 18, y = 21, width = 26, damage = 11,
        type = "knockDown", repel_x = slf.shortThrowSpeed_x },
        cont
    )
end
local grabFrontAttackDown = function(slf, cont)
    slf:checkAndAttack(
        { x = 20, y = 30, width = 26, damage = 15,
        type = "knockDown", repel_x = slf.shortThrowSpeed_x },
        cont
    )
end
local grabFrontAttackBack = function(slf, cont)
    slf:doThrow(slf.throwSpeed_x * slf.throwSpeedHorizontalMutliplier, 0,
        slf.throwSpeed_z * slf.throwSpeedHorizontalMutliplier,
        slf.face, slf.face,
        slf.z + slf.throwStart_z)
end
local grabFrontAttackForward = function(slf, cont)
    slf:doThrow(slf.throwSpeed_x * slf.throwSpeedHorizontalMutliplier, 0,
        slf.throwSpeed_z * slf.throwSpeedHorizontalMutliplier,
        slf.face, nil,
        slf.z + slf.throwStart_z)
end
local grabBackAttack = function(slf, cont)
    local g = slf.grabContext
    if g and g.target then
        slf:checkAndAttack(
            { x = -38, y = 32, width = 40, height = 70, depth = 18, damage = slf.thrownFallDamage, type = "blowOut" },
            cont
        )
        local target = g.target
        slf:releaseGrabbed()
        target:applyDamage(slf.thrownFallDamage, "simple", slf)
        target:setState(target.bounce)
    end
end

local comboSlide2 = function(slf)
    slf:initSlide(slf.comboSlideSpeed2_x, slf.comboSlideDiagonalSpeed2_x, slf.comboSlideDiagonalSpeed2_y, slf.repelFriction)
end
local comboSlide3 = function(slf)
    slf:initSlide(slf.comboSlideSpeed3_x, slf.comboSlideDiagonalSpeed3_x, slf.comboSlideDiagonalSpeed3_y, slf.repelFriction)
    slf.speed_z = 30
    slf.z = slf:getMinZ() + 3
end
local comboSlide4 = function(slf)
    slf:initSlide(slf.comboSlideSpeed4_x, slf.comboSlideDiagonalSpeed4_x, slf.comboSlideDiagonalSpeed4_y, slf.repelFriction)
end

local comboAttack1 = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, y = 30, width = 26, damage = 7, sfx = "air" },
        cont
    )
end
local comboAttack2 = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, y = 31, width = 27, damage = 8, sfx = "air" },
        cont
    )
end
local comboAttack2Forward = function(slf, cont)
    slf:checkAndAttack(
        { x = 21, y = 24, width = 31, damage = 8, repel_x = slf.comboSlideRepel2, sfx = (slf.sprite.elapsedTime <= 0) and "air" },
        cont
    )
end
local comboAttack3 = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, y = 18, width = 27, damage = 10, sfx = "air" },
        cont
    )
end
local comboAttack3Up1 = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, y = 30, width = 27, damage = 4, sfx = "air" },
        cont
    )
end
local comboAttack3Up2 = function(slf, cont)
    slf:checkAndAttack(
        { x = 18, y = 24, width = 27, damage = 9 },
        cont
    )
end
local comboAttack3Forward = function(slf, cont)
    slf:checkAndAttack(
        { x = 27, y = 21, width = 39, damage = 10, repel_x = slf.comboSlideRepel3, sfx = (slf.sprite.elapsedTime <= 0) and "air" },
        cont
    )
end
local comboAttack3Down = function(slf, cont)
    slf:checkAndAttack(
        { x = 29, y = 29, width = 27, damage = 15, type = "knockDown", sfx = "air" },
        cont
    )
end
local comboAttack4 = function(slf, cont)
    slf:checkAndAttack(
        { x = 34, y = 41, width = 39, damage = 15, type = "knockDown", sfx = "air" },
        cont
    )
end
local comboAttack4Up1 = function(slf, cont)
    slf:checkAndAttack(
        { x = 27, y = 40, width = 29, damage = 18, type = "knockDown", sfx = "air" },
        cont
    )
end
local comboAttack4Up2 = function(slf, cont)
    slf:checkAndAttack(
        { x = 25, y = 50, width = 33, damage = 18, type = "knockDown" },
        cont
    )
end
local comboAttack4Forward = function(slf, cont)
    slf:checkAndAttack(
        { x = 35, y = 32, width = 39, damage = 15, type = "knockDown", repel_x = slf.comboSlideRepel4, sfx = (slf.sprite.elapsedTime <= 0) and "air" },
        cont
    )
end
local chargeAttack1 = function(slf, cont)
    slf:checkAndAttack(
        { x = 34, y = 41, width = 39, damage = 15, type = "knockDown", sfx = "air" },
        cont
    )
end
local chargeAttack2 = function(slf, cont)
    slf:checkAndAttack(
        { x = 24, y = 41, width = 39, damage = 15, type = "knockDown" },
        cont
    )
end
local chargeAttack3 = function(slf, cont)
    slf:checkAndAttack(
        { x = 14, y = 41, width = 39, damage = 15, type = "knockDown" },
        cont
    )
end
local dashAttack1 = function(slf, cont) slf:checkAndAttack(
    { x = 20, y = 37, width = 55, damage = 8, repel_x = slf.dashFallSpeed },
    cont
) end
local dashAttack2 = function(slf, cont) slf:checkAndAttack(
    { x = 20, y = 37, width = 55, damage = 12, type = "knockDown", repel_x = slf.dashFallSpeed },
    cont
) end
local dashAttackSpeedUp = function(slf, cont)
    slf.speed_x = slf.dashSpeed_x * 2
end
local dashAttackResetSpeed = function(slf, cont)
    slf.speed_x = slf.dashSpeed_x
end
local chargeDashAttack = function(slf, cont)
    slf:checkAndAttack(
        { x = 27, y = 21, width = 39, damage = 15, type = "knockDown" },
        cont
    )
end
local jumpAttackForward = function(slf, cont) slf:checkAndAttack(
    { x = 30, y = 25, width = 25, height = 45, damage = 15, type = "knockDown" },
    cont
) end
local jumpAttackLight = function(slf, cont) slf:checkAndAttack(
    { x = 15, y = 25, width = 22, damage = 9 },
    cont
) end
local jumpAttackStraight1 = function(slf, cont) slf:checkAndAttack(
    { x = 17, y = 35, width = 30, height = 55, damage = 7 },
    cont
) end
local jumpAttackStraight2 = function(slf, cont) slf:checkAndAttack(
    { x = 17, y = 14, width = 30, damage = 10, type = "knockDown" },
    cont
) end
local jumpAttackRun = function(slf, cont) slf:checkAndAttack(
    { x = 30, y = 25, width = 25, height = 45, damage = 17, type = "knockDown" },
    cont
 ) end
local specialDefensiveShake = function(slf, cont)
    slf:playSfx("hitWeak1")
    mainCamera:onShake(0, 2, 0.03, 0.3)
end
local specialDefensive1 = function(slf, cont) slf:checkAndAttack(
    { x = 0, y = 32, width = 28, height = 32, depth = 18, damage = 25, type = "blowOut" },
    cont
 ) end
local specialDefensive2 = function(slf, cont) slf:checkAndAttack(
    { x = 10, y = 17, width = 50, height = 40, depth = 18, damage = 25, type = "blowOut" },
    cont
 ) end
local specialDefensive3 = function(slf, cont) slf:checkAndAttack(
    { x = 10, y = 42, width = 66, height = 90, depth = 18, damage = 25, type = "blowOut" },
    cont
 ) end
local specialDefensive4 = function(slf, cont) slf:checkAndAttack(
    { x = 5, y = 32, width = 40, height = 70, depth = 18, damage = 25, type = "blowOut" },
    cont
 ) end
local specialOffensive = function(slf, cont) slf:checkAndAttack(
    { x = 15, y = 37, width = 65, damage = 34, repel_x = slf.specialOffensiveRepel, type = "knockDown" },
    cont
 ) end
local specialDash1 = function(slf, cont)
    if slf.sprite.elapsedTime <= 0 then
        slf.victims = {}    -- clear victims list before any contFuncAttack
    end
    slf:checkAndAttack(
        { x = 10, y = 18, width = 40, height = 35, damage = 6,
          onHit = function(slf)
              slf.isAttackConnected = true
              slf.customFriction = slf.dashFriction * 2.5
          end
        },cont)
end
local specialDashFollowUp = function(slf, cont)
    if slf.isAttackConnected then
        slf.victims = {}    -- clear victims list before this attack
        slf:setSprite("specialDash2")
        slf.speed_x = slf.dashSpeed_x * 1.5
        slf.customFriction = slf.dashFriction * 1.5
    end
end
local specialDashJumpStart = function(slf, cont)
    slf.speed_z = slf.jumpSpeed_z * 1.2
    slf.z = slf:getMinZ() + 0.01
    slf:showEffect("jumpStart")
end
local specialDash2a = function(slf, cont)
    if slf.sprite.elapsedTime <= 0 then
        slf.victims = {}    -- clear victims list before any contFuncAttack
    end
    slf:checkAndAttack(
        { x = 10, y = 18, width = 40, height = 35, damage = 6 },
        cont)
end
local specialDash2b = function(slf, cont)
    if slf.sprite.elapsedTime <= 0 then
        slf.victims = {}    -- clear victims list before any contFuncAttack
    end
    slf:checkAndAttack(
        { x = 10, y = 50, width = 40, height = 50, damage = 18, type = "knockDown", repel_x = slf.specialDashRepel },
        cont)
end

return {
    serializationVersion = 0.42, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "rick", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon = {
            { q = q(2, 280, 42, 17) }
        },
        intro = {
            { q = q(47,398,41,58), ox = 17, oy = 57 }, --pick up 2
            { q = q(2,395,43,61), ox = 20, oy = 60 }, --pick up 1
            loop = true,
            delay = 1
        },
        stand = {
            -- q = Love.graphics.newQuad( x, y, width, height, imageWidth, imageHeight),
            -- ox,oy pivots offsets from the top left corner of the quad
            -- delay = 0.1, func = func1, funcCont = func2
            { q = q(2,3,43,63), ox = 20, oy = 62 }, --stand 1
            { q = q(47,2,42,64), ox = 20, oy = 63 }, --stand 2
            { q = q(91,3,42,63), ox = 19, oy = 62, delay = 0.117 }, --stand 3
            { q = q(135,4,43,62), ox = 19, oy = 61, delay = 0.25 }, --stand 4
            loop = true,
            delay = 0.183
        },
        chargeStand = {
            { q = q(2,1310,50,62), ox = 22, oy = 61, delay = 0.267 }, --charge stand 1
            { q = q(54,1311,50,61), ox = 22, oy = 60 }, --charge stand 2
            { q = q(106,1311,49,61), ox = 22, oy = 60, delay = 0.2 }, --charge stand 3
            { q = q(54,1311,50,61), ox = 22, oy = 60 }, --charge stand 2
            loop = true,
            delay = 0.167
        },
        walk = {
            { q = q(2,68,35,64), ox = 17, oy = 63 }, --walk 1
            { q = q(39,68,35,64), ox = 17, oy = 63 }, --walk 2
            { q = q(76,69,35,63), ox = 17, oy = 62, delay = 0.25 }, --walk 3
            { q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
            { q = q(150,68,35,64), ox = 17, oy = 63 }, --walk 5
            { q = q(187,69,35,63), ox = 17, oy = 62, delay = 0.25 }, --walk 6
            loop = true,
            delay = 0.167
        },
        chargeWalk = {
            { q = q(2,1374,52,62), ox = 22, oy = 62 }, --charge walk 1
            { q = q(56,1375,51,62), ox = 22, oy = 61 }, --charge walk 2
            { q = q(109,1374,51,63), ox = 22, oy = 62 }, --charge walk 3
            { q = q(2,1439,52,63), ox = 22, oy = 62 }, --charge walk 4
            { q = q(56,1440,52,62), ox = 22, oy = 61 }, --charge walk 5
            { q = q(110,1439,52,63), ox = 22, oy = 62 }, --charge walk 6
            loop = true,
            delay = 0.2
        },
        run = {
            { q = q(2,136,42,60), ox = 13, oy = 59 }, --run 1
            { q = q(46,134,48,62), ox = 18, oy = 61, delay = 0.12 }, --run 2
            { q = q(96,134,47,62), ox = 17, oy = 61, func = stepFx }, --run 3
            { q = q(2,200,41,60), ox = 12, oy = 59 }, --run 4
            { q = q(45,198,48,61), ox = 18, oy = 61, delay = 0.12 }, --run 5
            { q = q(95,198,47,62), ox = 17, oy = 61, func = stepFx }, --run 6
            loop = true,
            delay = 0.1
        },
        jump = {
            { q = q(2,1952,39,66), ox = 20, oy = 65, delay = 0.15 }, --jump up
            { q = q(43,1952,44,66), ox = 21, oy = 65 }, --jump top
            { q = q(89,1952,46,66), ox = 24, oy = 65, delay = 5 }, --jump down
            delay = 0.09
        },
        dropDown = {
            { q = q(2,1952,39,66), ox = 20, oy = 65, delay = 0.15 }, --jump up
            { q = q(43,1952,44,66), ox = 21, oy = 65 }, --jump top
            { q = q(89,1952,46,66), ox = 24, oy = 65, delay = 5 }, --jump down
            delay = 0.09
        },
        respawn = {
            { q = q(89,1952,46,66), ox = 24, oy = 65, delay = 5 }, --jump down
            { q = q(47,398,41,58), ox = 17, oy = 57, delay = 0.5 }, --pick up 2
            { q = q(2,395,43,61), ox = 20, oy = 60 }, --pick up 1
            delay = 0.1
        },
        duck = {
            { q = q(2,269,42,59), ox = 21, oy = 58 }, --duck
            delay = 0.06
        },
        pickUp = {
            { q = q(2,395,43,61), ox = 20, oy = 60, delay = 0.03 }, --pick up 1
            { q = q(47,398,41,58), ox = 17, oy = 57, delay = 0.2 }, --pick up 2
            { q = q(2,395,43,61), ox = 20, oy = 60 }, --pick up 1
            delay = 0.05
        },
        dashAttack = {
            { q = q(2,1757,40,64), ox = 21, oy = 63, delay = 0.03 }, --dash attack 1
            { q = q(44,1759,39,62), ox = 21, oy = 61, delay = 0.1 }, --dash attack 2
            { q = q(85,1759,54,62), ox = 28, oy = 61, delay = 0.015 }, --dash attack 3
            { q = q(141,1759,40,61), ox = 15, oy = 61, func = dashAttackSpeedUp, delay = 0.015 }, --dash attack 4
            { q = q(2,1823,70,62), ox = 20, oy = 62, func = dashAttack1, delay = 0.08 }, --dash attack 5a
            { q = q(74,1823,70,62), ox = 20, oy = 62, funcCont = dashAttack2, delay = 0.08 }, --dash attack 5b
            { q = q(146,1832,52,53), ox = 17, oy = 52, func = dashAttackResetSpeed, delay = 0.07 }, --dash attack 6
            { q = q(2,1899,47,50), ox = 17, oy = 49, delay = 0.13 }, --dash attack 7
            { q = q(51,1891,41,58), ox = 14, oy = 57 }, --dash attack 8
            { q = q(94,1887,38,62), ox = 15, oy = 61 }, --dash attack 9
            delay = 0.05
        },
        chargeDash = {
            { q = q(2,269,42,59), ox = 21, oy = 58, delay = 0.06 }, --duck
            { q = q(164,1439,52,63), ox = 18, oy = 62 }, --charge dash
        },
        chargeDashAttack = {
            { q = q(176,650,51,62), ox = 31, oy = 62, delay = 0.06 }, --combo 4.6
            { q = q(2,2021,51,61), ox = 29, oy = 63, delay = 0.06 }, --charge dash attack 1
            { q = q(55,2021,72,59), ox = 25, oy = 63, funcCont = chargeDashAttack, delay = 0.15 }, --charge dash attack 2
            { q = q(129,2020,58,65), ox = 23, oy = 64 }, --charge dash attack 3
            { q = q(137,1954,45,64), ox = 16, oy = 64 }, --charge dash attack 4
            { q = q(184,1954,43,64), ox = 17, oy = 63 }, --charge dash attack 5
            delay = 0.05
        },
        specialDefensive = {
            { q = q(2,1504,45,62), ox = 22, oy = 61, delay = 0.04 }, --special defensive 1
            { q = q(49,1505,49,61), ox = 24, oy = 60, delay = 0.1 }, --special defensive 2
            { q = q(100,1505,45,61), ox = 17, oy = 60 }, --special defensive 3
            { q = q(147,1506,54,60), ox = 14, oy = 59, funcCont = specialDefensive1 }, --special defensive 4
            { q = q(2,1568,58,59), ox = 14, oy = 54, funcCont = specialDefensive2, func = specialDefensiveShake }, --special defensive 5a
            { q = q(62,1569,58,58), ox = 14, oy = 53, funcCont = specialDefensive2 }, --special defensive 5b
            { q = q(122,1570,58,55), ox = 14, oy = 52, funcCont = specialDefensive3 }, --special defensive 5c1
            { q = q(122,1570,58,55), ox = 14, oy = 52, funcCont = specialDefensive3 }, --special defensive 5c2
            { q = q(122,1570,58,55), ox = 14, oy = 52, funcCont = specialDefensive4 }, --special defensive 5c3
            { q = q(122,1570,58,55), ox = 14, oy = 52, funcCont = specialDefensive4 }, --special defensive 5c4
            { q = q(122,1570,58,55), ox = 14, oy = 52, delay = 0.04 }, --special defensive 5c5
            { q = q(2,1630,50,60), ox = 14, oy = 59, delay = 0.04 }, --special defensive 6
            { q = q(122,1627,44,63), ox = 15, oy = 62, delay = 0.04 }, --special defensive 7
            delay = 0.05
        },
        specialOffensive = {
            { q = q(2,2433,47,52), ox = 14, oy = 51 }, --special offensive 1
            { q = q(51,2430,46,55), ox = 7, oy = 54 }, --special offensive 2
            { q = q(99,2427,41,58), ox = 8, oy = 57 }, --special offensive 3
            { q = q(142,2425,61,60), ox = 14, oy = 59, funcCont = specialOffensive, delay = 0.03 }, --special offensive 4
            { q = q(2,2487,56,61), ox = 12, oy = 60, delay = 0.03 }, --special offensive 5
            { q = q(60,2489,45,59), ox = 18, oy = 58 }, --special offensive 6a
            { q = q(107,2490,44,58), ox = 17, oy = 57 }, --special offensive 6b
            { q = q(154,2490,41,58), ox = 14, oy = 57, delay = 0.2 }, --special offensive 6c
            { q = q(138,779,46,63), ox = 18, oy = 62 }, --combo 4.7 (shifted right by 4px)
            delay = 0.05
        },
        specialDash = {
            { q = q(2,2087,46,62), ox = 31, oy = 61 }, --offensive special 1
            { q = q(50,2092,39,57), ox = 26, oy = 56 }, --offensive special 2
            { q = q(91,2091,45,57), ox = 29, oy = 57 }, --offensive special 3
            { q = q(138,2094,49,54), ox = 22, oy = 54, funcCont = specialDash1, func = dashAttackSpeedUp, delay = 0.08 }, --offensive special 4a
            { q = q(2,2153,49,54), ox = 22, oy = 54, funcCont = specialDash1, delay = 0.08 }, --offensive special 4b
            { q = q(53,2153,49,54), ox = 22, oy = 54, funcCont = specialDash1, delay = 0.08 }, --offensive special 4c
            { q = q(137,2302,44,56), ox = 16, oy = 56, func = specialDashFollowUp }, --offensive special 13
            { q = q(183,2299,42,60), ox = 17, oy = 59 }, --offensive special 14
            delay = 0.06
        },
        specialDash2 = {
            { q = q(104,2151,44,56), ox = 16, oy = 56 }, --offensive special 5
            { q = q(150,2151,45,57), ox = 15, oy = 56, funcCont = specialDash2a }, --offensive special 6
            { q = q(2,2228,45,59), ox = 14, oy = 58 }, --offensive special 7
            { q = q(49,2210,54,77), ox = 22, oy = 76, funcCont = specialDash2b, func = specialDashJumpStart, delay =  0.1 }, --offensive special 8a
            { q = q(106,2210,51,77), ox = 22, oy = 76, funcCont = specialDash2b, delay =  0.08 }, --offensive special 8b
            { q = q(159,2211,47,76), ox = 22, oy = 75, funcCont = specialDash2b, delay =  0.08 }, --offensive special 8c
            { q = q(184,1617,45,73), ox = 26, oy = 72, delay =  0.1 }, --offensive special 9
            { q = q(2,2289,38,70), ox = 21, oy = 69, delay =  0.1 }, --offensive special 10
            { q = q(42,2292,43,66), ox = 23, oy = 65, delay =  0.1 }, --offensive special 11
            { q = q(87,2296,48,63), ox = 25, oy = 62, delay =  0.1 }, --offensive special 12
            { q = q(137,2302,44,56), ox = 16, oy = 56, func = function(slf) slf:showEffect("jumpLanding") end }, --offensive special 13
            { q = q(183,2299,42,60), ox = 17, oy = 59 }, --offensive special 14
            delay = 0.06
        },
        combo1 = {
            { q = q(49,519,60,63), ox = 19, oy = 62, func = comboAttack1, delay = 0.06 }, --combo 1.2
            { q = q(2,519,45,63), ox = 19, oy = 62 }, --combo 1.1
            delay = 0.01
        },
        combo2 = {
            { q = q(111,519,39,63), ox = 16, oy = 62 }, --combo 2.1
            { q = q(152,519,60,63), ox = 18, oy = 62, func = comboAttack2, delay = 0.08 }, --combo 2.2
            { q = q(111,519,39,63), ox = 16, oy = 62, delay = 0.06 }, --combo 2.1
            delay = 0.015
        },
        combo2Forward = {
            { q = q(134,715,46,61), ox = 23, oy = 60, func = comboSlide2 }, --combo forward 2.1
            { q = q(182,716,39,60), ox = 17, oy = 59 }, --combo forward 2.2
            { q = q(158,917,54,60), ox = 17, oy = 59, funcCont = comboAttack2Forward, delay = 0.1 }, --combo forward 2.3
            { q = q(111,519,39,63), ox = 16, oy = 62, delay = 0.06 }, --combo 2.1
            delay = 0.03
        },
        combo3 = {
            { q = q(2,584,44,63), ox = 21, oy = 62 }, --combo 3.1
            { q = q(48,586,63,61), ox = 21, oy = 60, func = comboAttack3, delay = 0.1 }, --combo 3.2
            { q = q(2,584,44,63), ox = 21, oy = 62, delay = 0.08 }, --combo 3.1
            delay = 0.025
        },
        combo3Up = {
            { q = q(2,913,39,64), ox = 21, oy = 63 }, --combo up 3.1
            { q = q(43,916,58,61), ox = 16, func = comboAttack3Up1, oy = 60 }, --combo up 3.2
            { q = q(103,915,53,62), ox = 20, func = comboAttack3Up2, oy = 61, delay = 0.06 }, --combo up 3.3
            delay = 0.1
        },
        combo3Forward = {
            { q = q(176,650,51,62), ox = 31, oy = 62, func = comboSlide3, delay = 0.05 }, --combo 4.6
            { q = q(2,2021,51,61), ox = 29, oy = 63, delay = 0.05 }, --charge dash attack 1
            { q = q(55,2021,72,59), ox = 25, oy = 63, funcCont = comboAttack3Forward, delay = 0.12 }, --charge dash attack 2
            { q = q(129,2020,58,65), ox = 23, oy = 64 }, --charge dash attack 3
            { q = q(137,1954,45,64), ox = 16, oy = 64 }, --charge dash attack 4
            { q = q(184,1954,43,64), ox = 17, oy = 63 }, --charge dash attack 5
            delay = 0.03
        },
        combo3Down = {
            { q = q(2,1757,40,64), ox = 21, oy = 63, delay = 0.03 }, --dash attack 1
            { q = q(44,1759,39,62), ox = 21, oy = 61, delay = 0.1 }, --dash attack 2
            { q = q(85,1759,54,62), ox = 28, oy = 61, delay = 0.015 }, --dash attack 3
            { q = q(160,1246,48,62), ox = 23, oy = 61, delay = 0.015 }, --combo down 3.1
            { q = q(157,1323,59,49), ox = 13, oy = 48, func = comboAttack3Down, delay = 0.15 }, --combo down 3.2
            { q = q(162,1377,50,60), ox = 14, oy = 59 }, --combo down 3.3
            { q = q(122,1627,44,63), ox = 15, oy = 62 }, --special defensive 7
            comboEnd = true,
            delay = 0.05
        },
        combo4 = {
            { q = q(113,584,43,62), ox = 16, oy = 62 }, --combo 4.1
            { q = q(158,584,36,62), ox = 14, oy = 62, delay = 0.05 }, --combo 4.2
            { q = q(2,650,65,61), ox = 11, oy = 61, func = comboAttack4, delay = 0.15 }, --combo 4.3
            { q = q(158,584,36,62), ox = 14, oy = 62, delay = 0.11 }, --combo 4.2
            delay = 0.03
        },
        combo4Up = {
            { q = q(2,1181,47,59), ox = 16, oy = 58, delay = 0.13 }, --combo up 4.1
            { q = q(51,1178,46,62), ox = 15, oy = 61, delay = 0.03 }, --combo up 4.2
            { q = q(99,1178,49,62), ox = 15, oy = 61, func = comboAttack4Up1, delay = 0.03 }, --combo up 4.3
            { q = q(150,1173,52,67), ox = 20, oy = 66, func = comboAttack4Up2 }, --combo up 4.4a
            { q = q(2,1242,53,65), ox = 20, oy = 64 }, --combo up 4.4b
            { q = q(57,1244,53,63), ox = 20, oy = 62 }, --combo up 4.4c
            { q = q(112,1244,46,63), ox = 19, oy = 62 }, --combo up 4.5
            delay = 0.067
        },
        combo4Forward = {
            { q = q(46,266,49,62), ox = 34, oy = 61, func = comboSlide4 }, --combo forward 4.1
            { q = q(97,266,51,62), ox = 23, oy = 61 }, --combo forward 4.2
            { q = q(150,265,65,62), ox = 10, oy = 62, funcCont = comboAttack4Forward, delay = 0.15 }, --combo forward 4.3
            { q = q(184,196,45,64), ox = 14, oy = 63, delay = 0.12 }, --combo forward 4.4
            delay = 0.06
        },
        chargeAttack = {
            { q = q(113,584,43,62), ox = 16, oy = 62 }, --combo 4.1
            { q = q(158,584,36,62), ox = 14, oy = 62 }, --combo 4.2
            { q = q(2,650,65,61), ox = 11, oy = 61, func = chargeAttack1, delay = 0.08 }, --combo 4.3
            { q = q(69,650,50,61), ox = 12, oy = 61, func = chargeAttack2 }, --combo 4.4
            { q = q(121,649,53,62), ox = 20, oy = 62, func = chargeAttack3 }, --combo 4.5
            { q = q(176,650,51,62), ox = 31, oy = 62 }, --combo 4.6
            { q = q(138,779,46,63), ox = 22, oy = 62 }, --combo 4.7
            delay = 0.04
        },
        fall = {
            { q = q(2,458,60,59), ox = 30, oy = 58 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,458,60,59), ox = 30, oy = 58, rotate = -1.57, rx = 29, ry = -30 }, --falling
            delay = 5
        },
        getUp = {
            { q = q(64,486,69,31), ox = 39, oy = 30 }, --lying down
            { q = q(135,464,56,53), ox = 31, oy = 52 }, --getting up
            { q = q(47,398,41,58), ox = 17, oy = 57 }, --pick up 2
            { q = q(2,395,43,61), ox = 20, oy = 60 }, --pick up 1
            delay = 0.15
        },
        fallen = {
            { q = q(64,486,69,31), ox = 39, oy = 30 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,330,44,63), ox = 22, oy = 62 }, --hurt high 1
            { q = q(48,331,47,62), ox = 26, oy = 61, delay = 0.2 }, --hurt high 2
            { q = q(2,330,44,63), ox = 22, oy = 62, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtLow = {
            { q = q(97,330,45,63), ox = 20, oy = 62 }, --hurt low 1
            { q = q(144,331,44,62), ox = 18, oy = 61, delay = 0.2 }, --hurt low 2
            { q = q(97,330,45,63), ox = 20, oy = 62, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        jumpAttackForward = {
            { q = q(2,714,53,61), ox = 23, oy = 65 }, --jump attack forward 1
            { q = q(57,714,75,59), ox = 33, oy = 66, funcCont = jumpAttackForward, delay = 5 }, --jump attack forward 2
            delay = 0.06
        },
        jumpAttackForwardEnd = {
            { q = q(2,714,53,61), ox = 23, oy = 65 }, --jump attack forward 1
            delay = 5
        },
        jumpAttackLight = {
            { q = q(2,844,43,66), ox = 21, oy = 65 }, --jump attack light 1
            { q = q(47,844,47,63), ox = 23, oy = 66, funcCont = jumpAttackLight, delay = 5 }, --jump attack light 2
            delay = 0.03
        },
        jumpAttackLightEnd = {
            { q = q(2,844,43,66), ox = 21, oy = 65 }, --jump attack light 1
            delay = 5
        },
        jumpAttackStraight = {
            { q = q(2,778,38,63), ox = 19, oy = 65 }, --jump attack straight 1
            { q = q(42,778,50,64), ox = 19, oy = 65, func = jumpAttackStraight1, delay = 0.05 }, --jump attack straight 2
            { q = q(94,779,42,61), ox = 19, oy = 65, funcCont = jumpAttackStraight2, delay = 5 }, --jump attack straight 3
            delay = 0.13
        },
        jumpAttackRun = {
            { q = q(2,714,53,61), ox = 23, oy = 65 }, --jump attack forward 1
            { q = q(90,395,78,53), ox = 36, oy = 66, funcCont = jumpAttackRun, delay = 5 }, --jump attack running
            delay = 0.06
        },
        jumpAttackRunEnd = {
            { q = q(2,714,53,61), ox = 23, oy = 65 }, --jump attack forward 1
            delay = 5
        },
        sideStepUp = {
            { q = q(96,844,44,64), ox = 21, oy = 63 }, --side step up
        },
        sideStepDown = {
            { q = q(142,844,44,62), ox = 21, oy = 62 }, --side step down
        },
        grab = {
            { q = q(2,979,44,63), ox = 18, oy = 62 }, --grab
        },
        grabFrontAttack1 = {
            { q = q(48,979,54,63), ox = 31, oy = 62 }, --grab attack 1
            { q = q(104,980,42,62), ox = 19, oy = 61 }, --grab attack 2
            { q = q(148,984,45,58), ox = 16, oy = 57, func = grabFrontAttack, delay = 0.16 }, --grab attack 3
            { q = q(182,716,39,60), ox = 17, oy = 59, delay = 0.02 }, --combo forward 2.2
            delay = 0.03
        },
        grabFrontAttack2 = {
            { q = q(48,979,54,63), ox = 31, oy = 62 }, --grab attack 1
            { q = q(104,980,42,62), ox = 19, oy = 61 }, --grab attack 2
            { q = q(148,984,45,58), ox = 16, oy = 57, func = grabFrontAttack, delay = 0.16 }, --grab attack 3
            { q = q(182,716,39,60), ox = 17, oy = 59, delay = 0.02 }, --combo forward 2.2
            delay = 0.03
        },
        grabFrontAttack3 = {
            { q = q(48,979,54,63), ox = 31, oy = 62 }, --grab attack 1
            { q = q(104,980,42,62), ox = 19, oy = 61 }, --grab attack 2
            { q = q(148,984,45,58), ox = 16, oy = 57, func = grabFrontAttackLast, delay = 0.16 }, --grab attack 3
            { q = q(182,716,39,60), ox = 17, oy = 59, delay = 0.02 }, --combo forward 2.2
            delay = 0.03
        },
        grabFrontAttackDown = {
            { q = q(2,1044,56,63), ox = 30, oy = 62, delay = 0.25 }, --grab attack end 1
            { q = q(60,1048,54,59), ox = 17, oy = 58, func = grabFrontAttackDown, delay = 0.05 }, --grab attack end 2
            { q = q(116,1047,52,60), ox = 17, oy = 59, delay = 0.2 }, --grab attack end 3
            { q = q(170,1044,44,63), ox = 17, oy = 62 }, --grab attack end 4
            delay = 0.1
        },
        grabFrontAttackBack = {
            { q = q(2,1111,43,60), ox = 26, oy = 59 }, --throw back 1
            { q = q(47,1113,42,58), ox = 17, oy = 57, func = grabFrontAttackBack, delay = 0.05 }, --throw back 2
            { q = q(91,1114,44,57), ox = 14, oy = 56 }, --throw back 3
            { q = q(137,1112,40,59), ox = 14, oy = 58, delay = 0.1 }, --throw back 4
            delay = 0.2,
            isThrow = true,
            moves = {
                { ox = 5, oz = 24, z = 0 },
                { ox = 10, oz = 20 }
            }
        },
        grabFrontAttackForward = {
            { q = q(2,2361,56,62), ox = 33, oy = 61 }, --throw forward 1
            { q = q(60,2362,42,61), ox = 17, oy = 61 }, --throw forward 2
            { q = q(104,2361,63,62), ox = 20, oy = 62, func = grabFrontAttackForward, delay = 0.3 }, --throw forward 3
            { q = q(169,2370,54,53), ox = 17, oy = 52, delay = 0.067 }, --throw forward 4
            { q = q(2,1899,47,50), ox = 17, oy = 49, delay = 0.13 }, --dash attack 7
            { q = q(51,1891,41,58), ox = 14, oy = 57 }, --dash attack 8
            { q = q(94,1887,38,62), ox = 15, oy = 61 }, --dash attack 9
            delay = 0.05,
            isThrow = true,
            moves = {
                { oz = 8, ox = 18, z = 0 },
                { oz = 16, ox = 14 },
                { oz = 24, ox = 20 }
            }
        },
        grabBackAttack = {
            { q = q(2,1694,41,61), ox = 12, oy = 60, delay = 0.13 }, --back throw 1
            { q = q(45,1692,45,63), ox = 15, oy = 62, delay = 0.1 }, --back throw 2
            { q = q(92,1705,61,50), ox = 39, oy = 49, delay = 0.08 }, --back throw 3
            { q = q(155,1701,60,54), ox = 48, oy = 53, delay = 0.05 }, --back throw 4
            { q = q(54,1652,63,38), ox = 51, oy = 34, func = grabBackAttack, delay = 0.3 }, --back throw 5
            { q = q(135,464,56,53), ox = 31, oy = 52 }, --getting up
            { q = q(47,398,41,58), ox = 17, oy = 57 }, --pick up 2
            { q = q(2,395,43,61), ox = 20, oy = 60, delay = 0.05 }, --pick up 1
            delay = 0.15,
            isThrow = true,
            moves = {
                --{ },
                { oz = 1, tFrame = 1 },
                { oz = 4 },
                { oz = 14, ox = 2, tFrame = 3 },
                { oz = 13, ox = -32, tFrame = 4 },
                { oz = 0, ox = -48, tFrame = 5, tFace = -1 } --oz = 0,
            }
        },
        grabSwap = {
            { q = q(134,1887,42,62), ox = 16, oy = 62 }, --grab swap 1.1
            { q = q(178,1887,35,62), ox = 17, oy = 62 }, --grab swap 1.2
            delay = 5
        },
        grabbedFront = {
            { q = q(2,330,44,63), ox = 22, oy = 62 }, --hurt high 1
            { q = q(48,331,47,62), ox = 26, oy = 61 }, --hurt high 2
            delay = 0.02
        },
        grabbedBack = {
            { q = q(97,330,45,63), ox = 20, oy = 62 }, --hurt low 1
            { q = q(144,331,44,62), ox = 18, oy = 61 }, --hurt low 2
            delay = 0.02
        },
        grabbedFrames = {
            --default order should be kept: hurtLow2, hurtHigh2, \, /, upsideDown, lying down
            { q = q(144,331,44,62), ox = 18, oy = 61 }, --hurt low 2
            { q = q(48,331,47,62), ox = 26, oy = 61 }, --hurt high 2
            { q = q(2,458,60,59), ox = 30, oy = 58 }, --falling
            { q = q(2,458,60,59), ox = 19, oy = 47, rotate = -1.57, rx = 29, ry = -30 }, --falling
            { q = q(144,331,44,62), ox = 18, oy = 61, flipV = -1 }, --hurt low 2
            { q = q(64,486,69,31), ox = 39, oy = 30 }, --lying down
            delay = 100
        },
    }
}
