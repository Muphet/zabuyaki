local spriteSheet = "res/img/char/chai.png"
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
        { x = 8, y = 20, width = 26, damage = 9 },
        cont
    )
end
local grabFrontAttackLast = function(slf, cont)
    slf:checkAndAttack(
        { x = 10, y = 21, width = 26, damage = 11,
        type = "knockDown", repel_x = slf.shortThrowSpeed_x },
        cont
    )
end
local grabFrontAttackDown = function(slf, cont)
    slf:checkAndAttack(
        { x = 18, y = 37, width = 26, damage = 15,
        type = "knockDown", repel_x = slf.shortThrowSpeed_x },
        cont
    )
end
local grabFrontAttackBack = function(slf, cont) slf:doThrow(slf.throwSpeed_x, 0, slf.throwSpeed_z / 10, slf.face) end
local grabFrontAttackForward = function(slf, cont)
    slf:doThrow(slf.throwSpeed_x * slf.throwSpeedHorizontalMutliplier, 0,
        slf.throwSpeed_z * slf.throwSpeedHorizontalMutliplier,
        slf.face)
end

local comboSlide1 = function(slf)
    slf:initSlide(slf.comboSlideSpeed1_x, slf.comboSlideDiagonalSpeed1_x, slf.comboSlideDiagonalSpeed1_y, slf.repelFriction)
end
local comboSlide2 = function(slf)
    slf:initSlide(slf.comboSlideSpeed2_x, slf.comboSlideDiagonalSpeed2_x, slf.comboSlideDiagonalSpeed2_y, slf.repelFriction)
end
local comboSlide3 = function(slf)
    slf:initSlide(slf.comboSlideSpeed3_x, slf.comboSlideDiagonalSpeed3_x, slf.comboSlideDiagonalSpeed3_y, slf.repelFriction)
end
local comboSlide4 = function(slf)
    slf:initSlide(slf.comboSlideSpeed4_x, slf.comboSlideDiagonalSpeed4_x, slf.comboSlideDiagonalSpeed4_y, slf.repelFriction)
end

local comboAttack1 = function(slf, cont)
    slf:checkAndAttack(
        { x = 26, y = 24, width = 26, damage = 8, sfx = "air" },
        cont
    )
end
local comboAttack1Forward = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, y = 21, width = 26, damage = 6, sfx = (slf.sprite.elapsedTime <= 0) and "air" },
        cont
    )
end
local comboAttack2 = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, y = 11, width = 30, damage = 10, sfx = "air" },
        cont
    )
end
local comboAttack2Forward = function(slf, cont)
    slf:checkAndAttack(
        { x = 22, y = 22, width = 31, damage = 10, repel_x = slf.comboSlideRepel2, sfx = (slf.sprite.elapsedTime <= 0) and "air" },
        cont
    )
end
local comboAttack3 = function(slf, cont)
    slf:checkAndAttack(
        { x = 32, y = 40, width = 38, damage = 12, sfx = "air" },
        cont
    )
end
local comboAttack3Forward = function(slf, cont)
    slf:checkAndAttack(
        { x = 22, y = 22, width = 31, damage = 12, repel_x = slf.comboSlideRepel3, sfx = (slf.sprite.elapsedTime <= 0) and "air" },
        cont
    )
end
local comboAttack4 = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, y = 37, width = 30, damage = 14, type = "knockDown", sfx = "air" },
        cont
    )
end
local comboAttack4Forward = function(slf, cont)
    slf:checkAndAttack(
        { x = 25, y = 18, width = 39, damage = 14, type = "knockDown", repel_x = slf.comboSlideRepel4, sfx = (slf.sprite.elapsedTime <= 0) and "air" },
        cont
    )
end
local comboAttack4NoSfx = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, y = 37, width = 30, damage = 14, type = "knockDown" },
        cont
    )
end
local dashAttack1 = function(slf, cont) slf:checkAndAttack(
    { x = 8, y = 20, width = 22, damage = 17, type = "knockDown", repel_x = slf.dashFallSpeed },
    cont
) end
local dashAttack2 = function(slf, cont) slf:checkAndAttack(
    { x = 10, y = 24, width = 26, damage = 17, type = "knockDown", repel_x = slf.dashFallSpeed },
    cont
) end
local dashAttack3 = function(slf, cont) slf:checkAndAttack(
    { x = 12, y = 28, width = 30, damage = 17, type = "knockDown", repel_x = slf.dashFallSpeed },
    cont
) end
local jumpAttackForward = function(slf, cont) slf:checkAndAttack(
    { x = 30, y = 18, width = 25, height = 45, damage = 15, type = "knockDown" },
    cont
) end
local jumpAttackLight = function(slf, cont) slf:checkAndAttack(
    { x = 12, y = 21, width = 22, damage = 8 },
    cont
) end
local jumpAttackStraight = function(slf, cont) slf:checkAndAttack(
    { x = 15, y = 21, width = 25, damage = 15, type = "knockDown" },
    cont
) end
local jumpAttackRun = function(slf, cont) slf:checkAndAttack(
    { x = 25, y = 25, width = 35, height = 50, damage = 7 },
    cont
) end
local jumpAttackRunLast = function(slf, cont) slf:checkAndAttack(
    { x = 25, y = 25, width = 35, height = 50, damage = 8, type = "knockDown" },
    cont
) end
local chargeDashAttackCheck = function(slf, cont)
    slf:checkAndAttack(
        { x = 25, y = 18, width = 39, height = 45, type = "check",
            onHit = function(slf) slf.speed_x = slf.dashSpeed_x * 0.7 end,
            followUpAnimation = "chargeDashAttack2"
        },
        cont
    )
end
local chargeDashAttack = function(slf, cont) slf:checkAndAttack(
    { x = 25, y = 18, width = 39, height = 45, damage = 7, repel_x = slf.fallSpeed_x * 1.4},
    cont
) end
local chargeDashAttack2 = function(slf, cont) slf:checkAndAttack(
    { x = 25, y = 18, width = 39, height = 45, damage = 10, type = "knockDown" },
    cont
) end
local specialDefensiveMiddle = function(slf, cont) slf:checkAndAttack(
    { x = 0, y = 22, width = 66, height = 45, depth = 18, damage = 15, type = "blowOut" },
    cont
 ) end
local specialDefensiveRight = function(slf, cont) slf:checkAndAttack(
    { x = 5, y = 27, width = 66, height = 45, depth = 18, damage = 15, type = "blowOut" },
    cont
 ) end
local specialDefensiveRightMost = function(slf, cont) slf:checkAndAttack(
    { x = 10, y = 32, width = 66, height = 45, depth = 18, damage = 15, type = "blowOut" },
    cont
 ) end
local specialDefensiveLeft = function(slf, cont) slf:checkAndAttack(
    { x = -5, y = 22, width = 66, height = 45, depth = 18, damage = 15, type = "blowOut" },
    cont
 ) end
local specialOffensive = function(slf, cont) slf:checkAndAttack(
    { x = 30, y = 18, width = 25, height = 45, damage = 5, repel_x = 0 },
    cont
 ) end
local specialOffensiveCheck = function(slf, cont) slf:checkAndAttack(
        { x = 30, y = 18, width = 25, height = 45, damage = 5, type = "check",
            onHit = function(slf)
                slf.speed_x = slf.jumpSpeedBoost.x
                slf.horizontal = slf.face
                slf.speed_z = 0
                slf.victims = {}
            end,
            followUpAnimation = "specialOffensive2"
        },
        cont
 ) end
local specialOffensive2Middle = function(slf, cont) slf:checkAndAttack(
    { x = 0, y = 22, width = 60, height = 40, damage = 6, type = "blowOut" },
    cont
 ) end
local specialOffensive2Right = function(slf, cont) slf:checkAndAttack(
    { x = 5, y = 27, width = 60, height = 40, damage = 6, type = "blowOut" },
    cont
 ) end
local specialOffensive2RightMost = function(slf, cont) slf:checkAndAttack(
    { x = 10, y = 32, width = 66, height = 45, damage = 6, type = "blowOut" },
    cont
 ) end
local specialOffensive2Left = function(slf, cont) slf:checkAndAttack(
    { x = -5, y = 22, width = 60, height = 40, damage = 6, type = "blowOut" },
    cont
 ) end
local specialOffensiveHop = function(slf, cont)
    slf.speed_x = slf.jumpSpeedBoost.x
    slf.horizontal = -slf.face
    slf.speed_z = slf.jumpSpeed_z
end
local specialDash = function(slf, cont) slf:checkAndAttack(
    { x = 30, y = 18, width = 25, height = 45, damage = 5, repel_x = 0 },
    cont
) end
local specialDashCheck = function(slf, cont) slf:checkAndAttack(
    { x = 30, y = 18, width = 25, height = 45, damage = 5, type = "check",
      onHit = function(slf)
          slf.speed_x = slf.jumpSpeedBoost.x
          slf.horizontal = slf.face
          slf.speed_z = 0
          slf.victims = {}
      end,
      followUpAnimation = "specialDash2"
    },
    cont
) end
local specialDash2Middle = function(slf, cont) slf:checkAndAttack(
    { x = 0, y = 22, width = 60, height = 40, damage = 6, type = "blowOut" },
    cont
 ) end
local specialDash2Right = function(slf, cont) slf:checkAndAttack(
    { x = 5, y = 27, width = 60, height = 40, damage = 6, type = "blowOut" },
    cont
 ) end
local specialDash2RightMost = function(slf, cont) slf:checkAndAttack(
    { x = 10, y = 32, width = 66, height = 45, damage = 6, type = "blowOut" },
    cont
 ) end
local specialDash2Left = function(slf, cont) slf:checkAndAttack(
    { x = -5, y = 22, width = 60, height = 40, damage = 6, type = "blowOut" },
    cont
 ) end
local specialDashHop = function(slf, cont)
    slf.speed_x = slf.jumpSpeedBoost.x
    slf.horizontal = -slf.face
    slf.speed_z = slf.jumpSpeed_z
end

return {
    serializationVersion = 0.42, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "chai", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon = {
            { q = q(2, 287, 36, 17) }
        },
        intro = {
            { q = q(43,404,39,58), ox = 23, oy = 57 }, --pick up 2
            { q = q(2,401,39,61), ox = 23, oy = 60 }, --pick up 1
            loop = true,
            delay = 1
        },
        stand = {
            -- q = Love.graphics.newQuad( x, y, width, height, imageWidth, imageHeight),
            -- ox,oy pivots offsets from the top left corner of the quad
            -- delay = 0.1, func = func1, funcCont = func2
            { q = q(2,2,41,64), ox = 23, oy = 63, delay = 0.25 }, --stand 1
            { q = q(45,2,43,64), ox = 23, oy = 63 }, --stand 2
            { q = q(90,3,43,63), ox = 23, oy = 62 }, --stand 3
            { q = q(45,2,43,64), ox = 23, oy = 63 }, --stand 2
            loop = true,
            delay = 0.155
        },
        chargeStand = {
            { q = q(2,1198,50,63), ox = 22, oy = 62, delay = 0.3 }, --charge stand 1
            { q = q(54,1198,50,63), ox = 22, oy = 62 }, --charge stand 2
            { q = q(106,1198,49,63), ox = 21, oy = 62, delay = 0.13 }, --charge stand 3
            { q = q(54,1198,50,63), ox = 22, oy = 62 }, --charge stand 2
            loop = true,
            delay = 0.2
        },
        walk = {
            { q = q(2,68,39,64), ox = 21, oy = 63 }, --walk 1
            { q = q(43,68,39,64), ox = 21, oy = 63 }, --walk 2
            { q = q(84,68,38,64), ox = 20, oy = 63, delay = 0.25 }, --walk 3
            { q = q(123,68,39,64), ox = 21, oy = 63 }, --walk 4
            { q = q(164,68,39,64), ox = 21, oy = 63 }, --walk 5
            { q = q(205,68,38,64), ox = 20, oy = 63, delay = 0.25 }, --walk 6
            loop = true,
            delay = 0.167
        },
        chargeWalk = {
            { q = q(169,1132,50,64), ox = 22, oy = 63 }, --charge walk 1
            { q = q(157,1198,49,63), ox = 21, oy = 62 }, --charge walk 2
            { q = q(2,1264,49,63), ox = 21, oy = 62 }, --charge walk 3
            { q = q(53,1263,50,63), ox = 22, oy = 63 }, --charge walk 4
            { q = q(105,1263,50,63), ox = 22, oy = 63 }, --charge walk 5
            { q = q(157,1263,50,64), ox = 22, oy = 63 }, --charge walk 6
            loop = true,
            delay = 0.117
        },
        run = {
            { q = q(2,135,37,63), ox = 18, oy = 62, delay = 0.117 }, --run 1
            { q = q(41,134,50,63), ox = 25, oy = 63, delay = 0.133 }, --run 2
            { q = q(93,134,46,64), ox = 25, oy = 63, func = stepFx }, --run 3
            { q = q(2,201,37,63), ox = 18, oy = 62, delay = 0.117 }, --run 4
            { q = q(41,200,49,64), ox = 23, oy = 63, delay = 0.133 }, --run 5
            { q = q(92,200,48,63), ox = 26, oy = 63, func = stepFx }, --run 6
            loop = true,
            delay = 0.1
        },
        jump = {
            { q = q(43,266,39,67), ox = 26, oy = 65, delay = 0.15 }, --jump up
            { q = q(84,266,42,65), ox = 24, oy = 66 }, --jump up/top
            { q = q(128,266,44,62), ox = 23, oy = 65, delay = 0.16 }, --jump top
            { q = q(174,266,40,65), ox = 22, oy = 66 }, --jump down/top
            { q = q(207,335,36,68), ox = 23, oy = 66, delay = 5 }, --jump down
            delay = 0.05
        },
        dropDown = {
            { q = q(128,266,44,62), ox = 23, oy = 65, delay = 0.16 }, --jump top
            { q = q(174,266,40,65), ox = 22, oy = 66 }, --jump down/top
            { q = q(207,335,36,68), ox = 23, oy = 66, delay = 5 }, --jump down
            delay = 0.05
        },
        respawn = {
            { q = q(207,335,36,68), ox = 23, oy = 66, delay = 5 }, --jump down
            { q = q(43,404,39,58), ox = 23, oy = 57, delay = 0.5 }, --pick up 2
            { q = q(2,401,39,61), ox = 23, oy = 60 }, --pick up 1
            delay = 0.1
        },
        duck = {
            { q = q(2,273,39,60), ox = 22, oy = 59 }, --duck
            delay = 0.06
        },
        pickUp = {
            { q = q(2,401,39,61), ox = 23, oy = 60, delay = 0.03 }, --pick up 1
            { q = q(43,404,39,58), ox = 23, oy = 57, delay = 0.2 }, --pick up 2
            { q = q(2,401,39,61), ox = 23, oy = 60 }, --pick up 1
            delay = 0.05
        },
        dashAttack = {
            { q = q(2,273,39,60), ox = 22, oy = 59, delay = 0.06 }, --duck
            { q = q(2,722,39,65), ox = 22, oy = 64, funcCont = dashAttack1, delay = 0.03 }, --jump attack forward 1 (shifted left by 4px)
            { q = q(2,858,38,65), ox = 22, oy = 64, funcCont = dashAttack2 }, --dash attack 1
            { q = q(42,858,49,68), ox = 26, oy = 65, funcCont = dashAttack3 }, --dash attack 2a
            { q = q(93,858,48,68), ox = 26, oy = 65, funcCont = dashAttack3 }, --dash attack 2b
            { q = q(143,858,47,68), ox = 26, oy = 65, funcCont = dashAttack3 }, --dash attack 2c
            { q = q(192,858,45,68), ox = 26, oy = 65, funcCont = dashAttack3 }, --dash attack 2d
            { q = q(192,858,45,68), ox = 26, oy = 65, delay = 0.04 }, --dash attack 2d
            { q = q(153,722,37,65), ox = 22, oy = 64, delay = 5 }, --dash attack 3
            delay = 0.06
        },
        chargeDash = {
            { q = q(2,273,39,60), ox = 22, oy = 59, delay = 0.06 }, --duck
            { q = q(175,1655,48,63), ox = 20, oy = 63 }, --charge dash
        },
        chargeDashAttack = {
            { q = q(2,1341,46,57), ox = 28, oy = 56 }, --special defensive 1
            { q = q(50,1343,42,55), ox = 33, oy = 54 }, --special defensive 2
            { q = q(186,137,39,60), ox = 22, oy = 59 }, --charge dash attack 1
            { q = q(141,134,43,64), ox = 20, oy = 63 }, --charge dash attack 2
            { q = q(2,1587,70,65), ox = 23, oy = 64, funcCont = chargeDashAttackCheck, delay = 0.06 }, --charge dash attack 3a
            { q = q(74,1587,70,65), ox = 23, oy = 64, funcCont = chargeDashAttackCheck, delay = 0.06 }, --charge dash attack 3b
            { q = q(146,1587,69,65), ox = 23, oy = 64, funcCont = chargeDashAttackCheck, delay = 0.06 }, --charge dash attack 3c
            { q = q(43,722,37,64), ox = 16, oy = 66, delay = 0.05 }, --jump attack forward 2 (shifted left by 4px)
            { q = q(2,722,39,65), ox = 18, oy = 66, delay = 0.05 }, --jump attack forward 1
            delay = 0.03
        },
        chargeDashAttack2 = {
            { q = q(146,1587,69,65), ox = 23, oy = 64, hover = true, funcCont = chargeDashAttack, delay = 0.06 }, --charge dash attack 3c
            { q = q(175,199,67,65), ox = 23, oy = 64, hover = true, func = function(slf) slf.speed_x = slf.walkSpeed_x * 0.7; slf.speed_z = 0; slf.victims = {} end, delay = 0.02 }, --charge dash attack 3d
            { q = q(43,722,37,64), ox = 16, oy = 66, hover = true, }, --jump attack forward 2 (shifted left by 4px)
            { q = q(2,722,39,65), ox = 18, oy = 66, hover = true }, --jump attack forward 1
            { q = q(101,1462,40,62), ox = 23, oy = 66, hover = true, func = function(slf) slf.speed_x = slf.dashSpeed_x / 2; slf.speed_z = 0 end }, --special defensive 12 (shifted up by 2px)
            { q = q(84,403,69,59), ox = 28, oy = 58, hover = true, funcCont = chargeDashAttack2, delay = 0.18 }, --charge dash attack 4
            { q = q(84,403,69,59), ox = 28, oy = 58, funcCont = chargeDashAttack2, delay = 0.04 }, --charge dash attack 4
            { q = q(101,1462,40,62), ox = 23, oy = 66, func = function(slf) slf.speed_x = slf.dashSpeed_x * 0.7 end, delay = 5 }, --special defensive 12 (shifted up by 2px)
            delay = 0.03
        },
        specialDefensive = {
            { q = q(2,1341,46,57), ox = 28, oy = 56, delay = 0.06 }, --special defensive 1
            { q = q(50,1343,42,55), ox = 33, oy = 54, delay = 0.12 }, --special defensive 2
            { q = q(94,1329,42,69), ox = 24, oy = 68, func = function(slf) slf.jumpType = 1 end, delay = 0.06 }, --special defensive 3
            { q = q(138,1331,41,66), ox = 25, oy = 67, funcCont = specialDefensiveMiddle }, --special defensive 4
            { q = q(181,1330,63,63), ox = 29, oy = 67, funcCont = specialDefensiveMiddle }, --special defensive 5
            { q = q(2,1400,75,60), ox = 31, oy = 66, funcCont = specialDefensiveRightMost }, --special defensive 6
            { q = q(79,1400,49,59), ox = 29, oy = 66, funcCont = specialDefensiveRightMost }, --special defensive 7
            { q = q(130,1400,51,60), ox = 26, oy = 65, funcCont = specialDefensiveRight }, --special defensive 8
            { q = q(183,1400,45,60), ox = 26, oy = 65, funcCont = specialDefensiveMiddle }, --special defensive 9
            { q = q(2,1462,51,60), ox = 36, oy = 65, funcCont = specialDefensiveLeft, func = function(slf) slf.jumpType = 2 end }, --special defensive 10
            { q = q(55,1462,44,62), ox = 26, oy = 65, funcCont = specialDefensiveLeft }, --special defensive 11
            { q = q(101,1462,40,62), ox = 23, oy = 64, funcCont = specialDefensiveMiddle }, --special defensive 12
            delay = 0.04
        },
        specialOffensive = {
            { q = q(43,266,39,67), ox = 26, oy = 65 }, --jump up
            { q = q(84,266,42,65), ox = 24, oy = 66 }, --jump up/top
            { q = q(128,266,44,62), ox = 23, oy = 65 }, --jump top
            { q = q(101,1462,40,62), ox = 23, oy = 67 }, --special defensive 12 (shifted up by 3px)
            { q = q(2,1786,71,59), ox = 26, oy = 65, funcCont = specialOffensiveCheck }, --offensive special 1a
            { q = q(75,1786,71,59), ox = 26, oy = 65, funcCont = specialOffensiveCheck }, --offensive special 1b
            { q = q(148,1786,71,59), ox = 26, oy = 65, funcCont = specialOffensiveCheck }, --offensive special 1c
            loop = true,
            loopFrom = 5,
            delay = 0.05
        },
        specialOffensive2 = {
            { q = q(2,1786,71,59), ox = 26, oy = 65, func = specialOffensive, delay = 0.05 }, --offensive special 1a
            { q = q(75,1786,71,59), ox = 26, oy = 65, func = specialOffensive, delay = 0.05 }, --offensive special 1b
            { q = q(148,1786,71,59), ox = 26, oy = 65, func = specialOffensive, delay = 0.05 }, --offensive special 1c
            { q = q(2,1786,71,59), ox = 26, oy = 65, func = specialOffensive, delay = 0.05 }, --offensive special 1a
            { q = q(75,1786,71,59), ox = 26, oy = 65, func = specialOffensive, delay = 0.05 }, --offensive special 1b
            { q = q(148,1786,71,59), ox = 26, oy = 65, func = specialOffensive, delay = 0.05 }, --offensive special 1c
            { q = q(181,1330,63,63), ox = 29, oy = 67, funcCont = specialOffensive2RightMost, func = specialOffensiveHop }, --special defensive 5
            { q = q(2,1400,75,60), ox = 31, oy = 66, funcCont = specialOffensive2RightMost }, --special defensive 6
            { q = q(79,1400,49,59), ox = 29, oy = 66, funcCont = specialOffensive2RightMost }, --special defensive 7
            { q = q(130,1400,51,60), ox = 26, oy = 65, funcCont = specialOffensive2Right }, --special defensive 8
            { q = q(183,1400,45,60), ox = 26, oy = 65, funcCont = specialOffensive2Middle }, --special defensive 9
            { q = q(2,1462,51,60), ox = 36, oy = 65, funcCont = specialOffensive2Left }, --special defensive 10
            { q = q(55,1462,44,62), ox = 26, oy = 65, funcCont = specialOffensive2Left }, --special defensive 11
            { q = q(101,1462,40,62), ox = 23, oy = 64, funcCont = specialOffensive2Middle }, --special defensive 12
            { q = q(101,1462,40,62), ox = 23, oy = 64 }, --special defensive 12 (no fire effect)
            delay = 0.04
        },
        specialDash = {
            { q = q(43,266,39,67), ox = 26, oy = 65 }, --jump up
            { q = q(84,266,42,65), ox = 24, oy = 66 }, --jump up/top
            { q = q(128,266,44,62), ox = 23, oy = 65 }, --jump top
            { q = q(101,1462,40,62), ox = 23, oy = 67 }, --special defensive 12 (shifted up by 3px)
            { q = q(2,1786,71,59), ox = 26, oy = 65, funcCont = specialDashCheck }, --dash special 1a
            { q = q(75,1786,71,59), ox = 26, oy = 65, funcCont = specialDashCheck }, --dash special 1b
            { q = q(148,1786,71,59), ox = 26, oy = 65, funcCont = specialDashCheck }, --dash special 1c
            loop = true,
            loopFrom = 5,
            delay = 0.05
        },
        specialDash2 = {
            { q = q(2,1786,71,59), ox = 26, oy = 65, func = specialDash, delay = 0.05 }, --dash special 1a
            { q = q(75,1786,71,59), ox = 26, oy = 65, func = specialDash, delay = 0.05 }, --dash special 1b
            { q = q(148,1786,71,59), ox = 26, oy = 65, func = specialDash, delay = 0.05 }, --dash special 1c
            { q = q(2,1786,71,59), ox = 26, oy = 65, func = specialDash, delay = 0.05 }, --dash special 1a
            { q = q(75,1786,71,59), ox = 26, oy = 65, func = specialDash, delay = 0.05 }, --dash special 1b
            { q = q(148,1786,71,59), ox = 26, oy = 65, func = specialDash, delay = 0.05 }, --dash special 1c
            { q = q(181,1330,63,63), ox = 29, oy = 67, funcCont = specialDash2RightMost, func = specialDashHop }, --special defensive 5
            { q = q(2,1400,75,60), ox = 31, oy = 66, funcCont = specialDash2RightMost }, --special defensive 6
            { q = q(79,1400,49,59), ox = 29, oy = 66, funcCont = specialDash2RightMost }, --special defensive 7
            { q = q(130,1400,51,60), ox = 26, oy = 65, funcCont = specialDash2Right }, --special defensive 8
            { q = q(183,1400,45,60), ox = 26, oy = 65, funcCont = specialDash2Middle }, --special defensive 9
            { q = q(2,1462,51,60), ox = 36, oy = 65, funcCont = specialDash2Left }, --special defensive 10
            { q = q(55,1462,44,62), ox = 26, oy = 65, funcCont = specialDash2Left }, --special defensive 11
            { q = q(101,1462,40,62), ox = 23, oy = 64, funcCont = specialDash2Middle }, --special defensive 12
            { q = q(101,1462,40,62), ox = 23, oy = 64 }, --special defensive 12 (no fire effect)
            delay = 0.05
        },
        combo1 = {
            { q = q(2,1721,40,63), ox = 16, oy = 62 }, --combo 1.1
            { q = q(44,1720,51,64), ox = 13, oy = 63, func = comboAttack1, delay = 0.07 }, --combo 1.2
            { q = q(97,1721,41,63), ox = 17, oy = 62, delay = 0.02 }, --combo 1.1
            delay = 0.01
        },
        combo1Forward = {
            { q = q(135,2,51,64), ox = 24, oy = 63, func = comboSlide1 }, --combo forward 1.1
            { q = q(2,521,65,64), ox = 24, oy = 63, funcCont = comboAttack1Forward, delay = 0.09 }, --combo forward 1.2
            { q = q(69,521,57,64), ox = 24, oy = 63, delay = 0.03 }, --combo forward 1.3
            delay = 0.05
        },
        combo2 = {
            { q = q(128,521,41,64), ox = 19, oy = 64 }, --combo 2.1
            { q = q(171,521,65,64), ox = 21, oy = 64, func = comboAttack2, delay = 0.1 }, --combo 2.2
            { q = q(128,521,41,64), ox = 19, oy = 64, delay = 0.06 }, --combo 2.1
            delay = 0.015
        },
        combo2Forward = {
            { q = q(2,1847,43,65), ox = 21, oy = 64, func = comboSlide2 }, --combo forward 2.1
            { q = q(47,1847,40,65), ox = 15, oy = 64, delay = 0.03 }, --combo forward 2.2
            { q = q(90,1850,54,62), ox = 14, oy = 61, funcCont = comboAttack2Forward }, --combo forward 2.3a
            { q = q(146,1850,55,62), ox = 14, oy = 61, spanFunc = true }, --combo forward 2.3b
            { q = q(2,1917,54,62), ox = 14, oy = 61, spanFunc = true }, --combo forward 2.3c
            { q = q(58,1915,40,64), ox = 18, oy = 63, delay = 0.05 }, --combo forward 2.4
            delay = 0.04
        },
        combo3 = {
            { q = q(128,521,41,64), ox = 19, oy = 64 }, --combo 2.1
            { q = q(2,588,42,64), ox = 18, oy = 64 }, --combo 3.1
            { q = q(46,589,69,63), ox = 18, oy = 63, func = comboAttack3, delay = 0.11 }, --combo 3.2
            { q = q(2,588,42,64), ox = 18, oy = 64, delay = 0.04 }, --combo 3.1
            { q = q(128,521,41,64), ox = 19, oy = 64, delay = 0.04 }, --combo 2.1
            delay = 0.015
        },
        combo3Forward = {
            { q = q(100,1914,38,65), ox = 17, oy = 64, func = comboSlide3 }, --combo forward 3.1
            { q = q(140,1914,43,65), ox = 16, oy = 64, delay = 0.03 }, --combo forward 3.2
            { q = q(185,1915,55,64), ox = 14, oy = 63, funcCont = comboAttack3Forward }, --combo forward 3.3a
            { q = q(2,1982,54,64), ox = 14, oy = 63, spanFunc = true }, --combo forward 3.3b
            { q = q(58,1982,52,64), ox = 14, oy = 63, spanFunc = true }, --combo forward 3.3c
            { q = q(112,1982,49,64), ox = 14, oy = 63, spanFunc = true }, --combo forward 3.3d
            { q = q(163,1981,38,65), ox = 21, oy = 64 }, --combo forward 3.4
            delay = 0.05
        },
        combo4 = {
            { q = q(117,587,48,65), ox = 13, oy = 64, delay = 0.03 }, --combo 4.1
            { q = q(167,587,50,65), ox = 14, oy = 64, delay = 0.02 }, --combo 4.2
            { q = q(2,654,59,66), ox = 14, oy = 65, func = comboAttack4 }, --combo 4.3
            { q = q(63,659,60,61), ox = 14, oy = 60, func = comboAttack4NoSfx }, --combo 4.4
            { q = q(125,659,59,61), ox = 14, oy = 60, func = comboAttack4NoSfx }, --combo 4.5
            { q = q(186,659,50,61), ox = 14, oy = 60, delay = 0.09 }, --combo 4.6
            { q = q(192,725,49,62), ox = 14, oy = 61 }, --combo 4.7
            delay = 0.03
        },
        combo4Forward = {
            { q = q(2,1341,46,57), ox = 28, oy = 56 }, --special defensive 1
            { q = q(50,1343,42,55), ox = 33, oy = 54, func = comboSlide4 }, --special defensive 2
            { q = q(186,137,39,60), ox = 22, oy = 59 }, --charge dash attack 1
            { q = q(141,134,43,64), ox = 20, oy = 63 }, --charge dash attack 2
            { q = q(74,1587,70,65), ox = 23, oy = 64, funcCont = comboAttack4Forward, delay = 0.06 }, --charge dash attack 3b
            { q = q(146,1587,69,65), ox = 23, oy = 64, funcCont = comboAttack4Forward, delay = 0.06 }, --charge dash attack 3c
            { q = q(175,199,67,65), ox = 23, oy = 64, funcCont = comboAttack4Forward, delay = 0.05 }, --charge dash attack 3d
            { q = q(43,722,37,64), ox = 16, oy = 66, delay = 0.05 }, --jump attack forward 2 (shifted left by 4px)
            { q = q(2,722,39,65), ox = 18, oy = 66, delay = 0.05 }, --jump attack forward 1
            delay = 0.03
        },
        chargeAttack = {
            { q = q(117,587,48,65), ox = 13, oy = 64, delay = 0.02 }, --combo 4.1
            { q = q(167,587,50,65), ox = 14, oy = 64, delay = 0.01 }, --combo 4.2
            { q = q(2,654,59,66), ox = 14, oy = 65, func = comboAttack4 }, --combo 4.3
            { q = q(63,659,60,61), ox = 14, oy = 60, func = comboAttack4NoSfx }, --combo 4.4
            { q = q(125,659,59,61), ox = 14, oy = 60, func = comboAttack4NoSfx }, --combo 4.5
            { q = q(186,659,50,61), ox = 14, oy = 60, delay = 0.09 }, --combo 4.6
            { q = q(192,725,49,62), ox = 14, oy = 61 }, --combo 4.7
            delay = 0.03
        },
        fall = {
            { q = q(2,464,66,56), ox = 32, oy = 54 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,464,66,56), ox = 32, oy = 54, rotate = -1.57, rx = 29, ry = -30 }, --falling
            delay = 5
        },
        getUp = {
            { q = q(70,488,69,30), ox = 39, oy = 28 }, --lying down
            { q = q(141,466,56,53), ox = 30, oy = 51 }, --getting up
            { q = q(43,404,39,58), ox = 23, oy = 57 }, --pick up 2
            { q = q(2,401,39,61), ox = 23, oy = 60 }, --pick up 1
            delay = 0.15
        },
        fallen = {
            { q = q(70,488,69,30), ox = 39, oy = 28 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,335,48,64), ox = 29, oy = 63 }, --hurt high 1
            { q = q(52,335,50,64), ox = 32, oy = 63, delay = 0.2 }, --hurt high 2
            { q = q(2,335,48,64), ox = 29, oy = 63, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtLow = {
            { q = q(104,336,42,63), ox = 22, oy = 62 }, --hurt low 1
            { q = q(148,338,42,61), ox = 22, oy = 60, delay = 0.2 }, --hurt low 2
            { q = q(104,336,42,63), ox = 22, oy = 62, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        jumpAttackForward = {
            { q = q(2,722,39,65), ox = 18, oy = 66 }, --jump attack forward 1
            { q = q(43,722,37,64), ox = 12, oy = 66 }, --jump attack forward 2
            { q = q(82,722,69,64), ox = 24, oy = 66, funcCont = jumpAttackForward, delay = 5 }, --jump attack forward 3
            delay = 0.03
        },
        jumpAttackForwardEnd = {
            { q = q(43,722,37,64), ox = 12, oy = 66, delay = 0.03 }, --jump attack forward 2
            { q = q(2,722,39,65), ox = 18, oy = 66 }, --jump attack forward 1
            delay = 5
        },
        jumpAttackLight = {
            { q = q(2,722,39,65), ox = 18, oy = 66 }, --jump attack forward 1
            { q = q(43,722,37,64), ox = 12, oy = 66, funcCont = jumpAttackLight, delay = 5 }, --jump attack forward 2
            delay = 0.03
        },
        jumpAttackLightEnd = {
            { q = q(2,722,39,65), ox = 18, oy = 66 }, --jump attack forward 1
            delay = 5
        },
        jumpAttackStraight = {
            { q = q(2,789,42,67), ox = 26, oy = 66 }, --jump attack straight 1
            { q = q(46,789,41,63), ox = 22, oy = 66, delay = 0.05 }, --jump attack straight 2
            { q = q(89,789,42,61), ox = 22, oy = 66, funcCont = jumpAttackStraight, delay = 5 }, --jump attack straight 3
            delay = 0.1
        },
        jumpAttackRun = {
            { q = q(2,993,63,66), ox = 26, oy = 66 }, --jump attack running 1a
            { q = q(67,993,63,66), ox = 22, oy = 66, func = jumpAttackRun }, --jump attack running 1b
            { q = q(132,993,64,66), ox = 22, oy = 66 }, --jump attack running 2a
            { q = q(2,1061,65,66), ox = 22, oy = 66, func = jumpAttackRun }, --jump attack running 2b
            { q = q(69,1061,65,66), ox = 22, oy = 66 }, --jump attack running 2c
            { q = q(136,1061,63,66), ox = 20, oy = 66, func = jumpAttackRunLast }, --jump attack running 3a
            { q = q(2,1129,61,67), ox = 20, oy = 66, func = jumpAttackRunLast }, --jump attack running 3b
            { q = q(65,1129,59,66), ox = 20, oy = 66, func = jumpAttackRunLast }, --jump attack running 3c
            { q = q(126,1129,41,67), ox = 23, oy = 66, delay = 5 }, --jump attack running 4
            delay = 0.02
        },
        jumpAttackRunEnd = {
            { q = q(126,1129,42,67), ox = 23, oy = 66 }, --jump attack running 4
            delay = 5
        },
        sideStepUp = {
            { q = q(133,789,44,63), ox = 23, oy = 62 }, --side step up
        },
        sideStepDown = {
            { q = q(179,789,45,64), ox = 26, oy = 63 }, --side step down
        },
        grab = {
            { q = q(2,1654,45,64), ox = 23, oy = 63 }, --grab
        },
        grabFrontAttack1 = {
            { q = q(49,1654,41,64), ox = 23, oy = 63 }, --grab attack 1.1
            { q = q(92,1655,37,63), ox = 11, oy = 62, func = grabFrontAttack, delay = 0.18 }, --grab attack 1.2
            { q = q(131,1655,42,63), ox = 17, oy = 62 }, --grab attack 1.3
            delay = 0.03
        },
        grabFrontAttack2 = {
            { q = q(49,1654,41,64), ox = 23, oy = 63 }, --grab attack 1.1
            { q = q(92,1655,37,63), ox = 11, oy = 62, func = grabFrontAttack, delay = 0.18 }, --grab attack 1.2
            { q = q(131,1655,42,63), ox = 17, oy = 62 }, --grab attack 1.3
            delay = 0.03
        },
        grabFrontAttack3 = {
            { q = q(49,1654,41,64), ox = 23, oy = 63 }, --grab attack 1.1
            { q = q(2,722,39,65), ox = 15, oy = 64, delay = 0.02 }, --jump attack forward 1 (shifted right by 3px)
            { q = q(43,722,37,64), ox = 9, oy = 63, func = grabFrontAttackLast, delay = 0.18 }, --jump attack forward 2 (shifted right by 3px)
            { q = q(2,722,39,65), ox = 15, oy = 64, delay = 0.05 }, --jump attack forward 1 (shifted right by 3px)
            delay = 0.03
        },
        grabFrontAttackDown = {
            { q = q(117,587,48,65), ox = 13, oy = 64, delay = 0.15 }, --combo 4.1
            { q = q(167,587,50,65), ox = 14, oy = 64 }, --combo 4.2
            { q = q(192,725,49,62), ox = 14, oy = 61, func = grabFrontAttackDown }, --combo 4.7
            { q = q(186,659,50,61), ox = 14, oy = 60, delay = 0.35 }, --combo 4.6
            delay = 0.05
        },
        grabFrontAttackBack = {
            { q = q(131,1655,42,63), ox = 20, oy = 62, flipH = -1 }, --grab attack 1.3 (shifted left by 3px)
            { q = q(2,928,40,62), ox = 20, oy = 62, flipH = -1 }, --throw back 1
            { q = q(44,928,51,63), ox = 26, oy = 62, func = grabFrontAttackBack }, --throw back 2
            { q = q(97,928,53,63), ox = 22, oy = 62, delay = 0.2 }, --throw back 3
            { q = q(2,273,39,60), ox = 22, oy = 59, delay = 0.07 }, --duck
            { q = q(2,273,39,60), ox = 22, oy = 59, delay = 0.07 }, --duck
            delay = 0.07,
            isThrow = true,
            moves = {
                { ox = -20, oz = 10, oy = 1, z = 0, face = -1 },
                { ox = -10, oz = 20, z = 4 },
                { ox = 10, oz = 30, tFace = 1, z = 8 },
                { z = 4 },
                { z = 2 },
                { z = 0 }
            }
        },
        grabFrontAttackForward = {
            { q = q(131,1655,42,63), ox = 20, oy = 62, flipH = -1 }, --grab attack 1.3 (shifted left by 3px)
            { q = q(131,1655,42,63), ox = 20, oy = 62, flipH = -1 }, --grab attack 1.3 (shifted left by 3px)
            { q = q(131,1655,42,63), ox = 20, oy = 62, flipH = -1 }, --grab attack 1.3 (shifted left by 3px)
            { q = q(2,928,40,62), ox = 20, oy = 62, flipH = -1 }, --throw 1.1
            { q = q(44,928,51,63), ox = 26, oy = 62, func = grabFrontAttackForward }, --throw 1.2
            { q = q(97,928,53,63), ox = 22, oy = 62 }, --throw 1.3
            { q = q(2,273,39,60), ox = 22, oy = 59 }, --duck
            { q = q(2,273,39,60), ox = 22, oy = 59 }, --duck
            delay = 0.07,
            isThrow = true,
            moves = {
                { ox = 10, oz = 5, oy = -1, z = 0 },
                { ox = -5, oz = 10, tFace = -1, z = 0 },
                { ox = -20, oz = 12, tFace = -1, z = 2 },
                { ox = -10, oz = 24, tFace = -1, z = 4 },
                { ox = 10, oz = 30, tFace = 1, z = 8 },
                { z = 4 },
                { z = 0 }
            }
        },
        grabSwap = {
            { q = q(152,928,44,63), ox = 22, oy = 63 }, --grab swap 1.1
            { q = q(198,928,38,59), ox = 21, oy = 63 }, --grab swap 1.2
            delay = 3
        },
        grabbedFront = {
            { q = q(2,335,48,64), ox = 29, oy = 63 }, --hurt high 1
            { q = q(52,335,50,64), ox = 32, oy = 63 }, --hurt high 2
            delay = 0.02
        },
        grabbedBack = {
            { q = q(104,336,42,63), ox = 22, oy = 62 }, --hurt low 1
            { q = q(148,338,42,61), ox = 22, oy = 60 }, --hurt low 2
            delay = 0.02
        },
        grabbedFrames = {
            --default order should be kept: hurtLow2, hurtHigh2, \, /, upsideDown, lying down
            { q = q(148,338,42,61), ox = 22, oy = 60 }, --hurt low 2
            { q = q(52,335,50,64), ox = 32, oy = 63 }, --hurt high 2
            { q = q(2,464,66,56), ox = 32, oy = 54 }, --falling
            { q = q(2,464,66,56), ox = 22, oy = 46, rotate = -1.57, rx = 31, ry = -27 }, --falling
            { q = q(148,338,42,61), ox = 22, oy = 60, flipV = -1 }, --hurt low 2
            { q = q(70,488,69,30), ox = 39, oy = 28 }, --lying down
            delay = 100
        },
    }
}
