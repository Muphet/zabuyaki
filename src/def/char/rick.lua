local sprite_sheet = "res/img/char/rick.png"
local image_w,image_h = LoadSpriteSheet(sprite_sheet)

local function q(x,y,w,h)
	return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local step_sfx = function(slf, cont)
	sfx.play("sfx", slf.sfx.step, 0.5, 1 + 0.02 * love.math.random(-2,2))
	local padust = PA_DUST_STEPS:clone()
	padust:setLinearAcceleration(-slf.face * 50, 1, -slf.face * 100, -15)
	padust:emit(3)
	stage.objects:add(Effect:new(padust, slf.x - 20 * slf.face, slf.y+2))
end
local grabHit_attack = function(slf, cont) slf:checkAndAttackGrabbed(10,0, 20,12, 9, "low", slf.velx) end
local grabLast_attack = function(slf, cont) slf:checkAndAttackGrabbed(20,0, 20,12, 11, "grabKO", slf.velx) end
local grabEnd_attack = function(slf, cont) slf:checkAndAttackGrabbed(20,0, 20,12, 15, "grabKO", slf.velx) end
local combo_attack1 = function(slf, cont)
	slf:checkAndAttackN(
        {l = 28, w = 26, h = 12, damage = 7, type = "high", velocity = slf.velx, sfx = "air" },
        cont
    )
	slf.cool_down_combo = 0.4
end
local combo_attack2 = function(slf, cont)
	slf:checkAndAttackN(
        {l = 28, w = 27, h = 12, damage = 8, type = "high", velocity = slf.velx, sfx = "air" },
        cont
    )
	slf.cool_down_combo = 0.4
end
local combo_attack3 = function(slf, cont)
	slf:checkAndAttackN(
        {l = 28, w = 27, h = 12, damage = 10, type = "low", velocity = slf.velx, sfx = "air" },
        cont
    )
	slf.cool_down_combo = 0.4
end
local combo_attack4 = function(slf, cont)
	slf:checkAndAttackN(
        {l = 34, w = 39, h = 12, damage = 15, type = "fall", velocity = slf.velx, sfx = "air" },
        cont
    )
end
local dash_attack1 = function(slf, cont) slf:checkAndAttackN(
    {l = 20, w = 55, h = 12, damage = 8, type = "high", velocity = slf.velocity_dash_fall },
    cont
) end
local dash_attack2 = function(slf, cont) slf:checkAndAttackN(
    {l = 20, w = 55, h = 12, damage = 9, type = "fall", velocity = slf.velocity_dash_fall },
    cont
) end
local jump_forward_attack = function(slf, cont) slf:checkAndAttackN(
    {l = 30, w = 25, h = 12, damage = 15, type = "fall", velocity = slf.velx },
    cont
) end
 local jump_run_attack = function(slf, cont) slf:checkAndAttackN(
    {l = 30, w = 25, h = 12, damage = 17, type = "fall", velocity = slf.velx },
     cont
 ) end
local jump_light_attack = function(slf, cont) slf:checkAndAttackN(
    {l = 15, w = 22, h = 12, damage = 9, type = "high", velocity = slf.velx },
    cont
) end
local jump_straight_attack1 = function(slf, cont) slf:checkAndAttackN(
    {l = 20, w = 25, h = 12, damage = 7, type = "high", velocity = slf.velx },
    cont
) end
local jump_straight_attack2 = function(slf, cont) slf:checkAndAttackN(
    {l = 20, w = 25, h = 12, damage = 9, type = "fall", velocity = slf.velocity_fall_x },
    cont
) end
local grabThrow_now = function(slf, cont) slf.can_throw_now = true end

return {
	serialization_version = 0.42, -- The version of this serialization process

	sprite_sheet = sprite_sheet, -- The path to the spritesheet
	sprite_name = "rick", -- The name of the sprite

	delay = 0.20,	--default delay for all animations

	--The list with all the frames mapped to their respective animations
	--  each one can be accessed like this:
	--  mySprite.animations["idle"][1], or even
	animations = {
		icon  = {
			{ q = q(55, 597, 38, 17) }
		},
		intro = {
			{ q = q(48,398,43,58), ox = 21, oy = 57 }, --pickup 2
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			loop = true,
			delay = 1
		},
		stand = {
			-- q = Love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H),
			-- ox,oy pivots offsets from the top left corner of the quad
			-- delay = 0.1, func = func1, funcCont = func2
			{ q = q(2,2,44,64), ox = 22, oy = 63 }, --stand 1
			{ q = q(48,3,45,63), ox = 22, oy = 62 }, --stand 2
			{ q = q(95,4,46,62), ox = 22, oy = 61 }, --stand 3
			{ q = q(48,3,45,63), ox = 22, oy = 62 }, --stand 2
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
			--loopFrom = 5, --start animation from 5th frame on loop
            delay = 0.167
		},
		run = {
			{ q = q(2,136,44,60), ox = 14, oy = 60 }, --run 1
			{ q = q(48,134,49,62), ox = 18, oy = 61 }, --run 2
			{ q = q(99,134,48,62), ox = 17, oy = 60, func = step_sfx }, --run 3
			{ q = q(2,200,42,60), ox = 12, oy = 60 }, --run 4
			{ q = q(46,198,49,61), ox = 18, oy = 61 }, --run 5
			{ q = q(97,198,48,62), ox = 17, oy = 60, func = step_sfx }, --run 6
            loop = true,
            delay = 0.1
		},
		jump = {
			{ q = q(46,262,44,66), ox = 22, oy = 65, delay = 0.4 }, --jump up
			{ q = q(92,262,45,61), ox = 22, oy = 65 }, --jump down
			delay = 5
		},
		respawn = {
			{ q = q(92,262,45,61), ox = 22, oy = 65, delay = 5 }, --jump down
			{ q = q(48,398,43,58), ox = 21, oy = 57, delay = 0.5 }, --pickup 2
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			delay = 0.1
		},
		duck = {
			{ q = q(2,269,42,59), ox = 21, oy = 58 }, --duck
			delay = 0.06
		},
		pickup = {
			{ q = q(2,395,44,61), ox = 22, oy = 60, delay = 0.03 }, --pickup 1
			{ q = q(48,398,43,58), ox = 21, oy = 57, delay = 0.2 }, --pickup 2
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			delay = 0.05
		},
		dash = {
			{ q = q(2,915,63,62), ox = 37, oy = 61, delay = 0.07 }, --dash1
			{ q = q(67,914,37,63), ox = 17, oy = 62, delay = 0.1 }, --dash2
			{ q = q(106,913,61,64), ox = 17, oy = 63, func = dash_attack1, delay = 0.08 }, --dash3
			{ q = q(106,913,61,64), ox = 17, oy = 63, func = dash_attack2, delay = 0.08 }, --dash3
			{ q = q(168,916,53,61), ox = 17, oy = 60 }, --dash4
			{ q = q(117,519,40,63), ox = 17, oy = 62 }, --c2.1
			delay = 0.16
		},
		special = {
			{ q = q(114,584,44,62), ox = 18, oy = 61 }, --c4.1
			{ q = q(160,584,39,62), ox = 16, oy = 61 }, --c4.2
			{ q = q(2,649,66,62), ox = 12, oy = 61, func = combo_attack4, delay = 0.08 }, --c4.3
			{ q = q(70,649,51,62), ox = 13, oy = 61, func = combo_attack4 }, --c4.4
			{ q = q(123,649,55,62), ox = 22, oy = 61, func = combo_attack4 }, --c4.5
			{ q = q(135,714,52,62), ox = 32, oy = 61 }, --c4.6
			{ q = q(139,779,47,63), ox = 22, oy = 62 }, --c4.7
			delay = 0.04
		},
		dashSpecial = {
			{ q = q(2,1181,49,59), ox = 18, oy = 58, delay = 0.167 }, --dash special 1
			{ q = q(53,1178,49,62), ox = 17, oy = 61, func = dash_attack1, delay = 0.05 }, --dash special 2
			{ q = q(104,1178,49,62), ox = 15, oy = 61, func = dash_attack1, delay = 0.05 }, --dash special 3
			{ q = q(155,1173,54,67), ox = 20, oy = 66, func = dash_attack2 }, --dash special 4
			{ q = q(2,1242,54,66), ox = 20, oy = 65, func = dash_attack2 }, --dash special 5
			{ q = q(58,1242,54,66), ox = 20, oy = 65, func = dash_attack2 }, --dash special 6
			delay = 0.117
		},
		combo1 = {
			{ q = q(2,519,48,63), ox = 22, oy = 62 }, --c1.1
			{ q = q(52,519,63,63), ox = 22, oy = 62, func = combo_attack1, delay = 0.06 }, --c1.2
			{ q = q(2,519,48,63), ox = 22, oy = 62, delay = 0.01 }, --c1.1
			delay = 0.005
		},
		combo2 = {
			{ q = q(117,519,40,63), ox = 17, oy = 62 }, --c2.1
			{ q = q(159,519,60,63), ox = 18, oy = 62, func = combo_attack2, delay = 0.08 }, --c2.2
			{ q = q(117,519,40,63), ox = 17, oy = 62, delay = 0.06 }, --c2.1
			delay = 0.015
		},
		combo3 = {
			{ q = q(2,584,44,63), ox = 21, oy = 62 }, --c3.1
			{ q = q(48,586,64,61), ox = 22, oy = 60, func = combo_attack3, delay = 0.1 }, --c3.2
			{ q = q(2,584,44,63), ox = 21, oy = 62, delay = 0.08 }, --c3.1
			delay = 0.025
		},
		combo4 = {
			{ q = q(114,584,44,62), ox = 18, oy = 61 }, --c4.1
			{ q = q(160,584,39,62), ox = 16, oy = 61, delay = 0.06 }, --c4.2
			{ q = q(2,649,66,62), ox = 12, oy = 61, func = combo_attack4, delay = 0.15 }, --c4.3
			{ q = q(160,584,39,62), ox = 16, oy = 61, delay = 0.11 }, --c4.2
			delay = 0.03
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
		getup = {
			{ q = q(64,486,69,31), ox = 40, oy = 30 }, --lying down
			{ q = q(135,464,56,53), ox = 28, oy = 52 }, --getting up
			{ q = q(48,398,43,58), ox = 21, oy = 57 }, --pickup 2
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			delay = 0.2
		},
		fallen = {
			{ q = q(64,486,69,31), ox = 40, oy = 30 }, --lying down
			delay = 65
		},
		hurtHigh = {
			{ q = q(2,330,45,63), ox = 24, oy = 62, delay = 0.02 }, --hh1
			{ q = q(49,331,47,62), ox = 27, oy = 61, delay = 0.2 }, --hh2
			{ q = q(2,330,45,63), ox = 24, oy = 62 }, --hh1
			delay = 0.05
		},
		hurtLow = {
			{ q = q(98,330,45,63), ox = 20, oy = 62, delay = 0.02 }, --hl1
			{ q = q(145,331,44,62), ox = 18, oy = 61, delay = 0.2 }, --hl2
			{ q = q(98,330,45,63), ox = 20, oy = 62 }, --hl1
			delay = 0.05
		},
		jumpAttackForward = {
			{ q = q(2,714,54,62), ox = 23, oy = 61 }, --jaf1
			{ q = q(58,714,75,58), ox = 33, oy = 57, funcCont = jump_forward_attack, delay = 5 }, --jaf2
			delay = 0.06
		},
		jumpAttackLight = {
			{ q = q(2,844,43,67), ox = 21, oy = 66 }, --jal1
			{ q = q(47,844,47,63), ox = 23, oy = 62, funcCont = jump_light_attack, delay = 5 }, --jal2
			delay = 0.03
		},
		jumpAttackStraight = {
			{ q = q(2,778,38,63), ox = 19, oy = 62 }, --jas1
			{ q = q(42,778,50,64), ox = 19, oy = 63, func = jump_straight_attack1, delay = 0.07 }, --jas2
			{ q = q(94,778,43,62), ox = 19, oy = 61, funcCont = jump_straight_attack2, delay = 5 }, --jas3
			delay = 0.1
		},
		jumpAttackRun = {
			{ q = q(2,714,54,62), ox = 23, oy = 61 }, --jaf1
			{ q = q(143,2,75,55), ox = 33, oy = 57, funcCont = jump_run_attack, delay = 5 }, --jar
			delay = 0.06
		},
		sideStepUp = {
			{ q = q(96,844,44,64), ox = 22, oy = 63 }, --ssu
		},
		sideStepDown = {
			{ q = q(142,844,44,63), ox = 22, oy = 62 }, --ssd
		},
		grab = {
			{ q = q(2,979,45,63), ox = 22, oy = 62 }, --grab
		},
		grabHit = {
			{ q = q(49,980,42,62), ox = 21, oy = 61 }, --grab attack 1.1
			{ q = q(93,980,49,62), ox = 18, oy = 61, func = grabHit_attack, delay = 0.18 }, --grab attack 1.2
			{ q = q(49,980,42,62), ox = 21, oy = 61, delay = 0.01 }, --grab attack 1.1
			delay = 0.005
		},
		grabHitLast = {
			{ q = q(49,980,42,62), ox = 21, oy = 61 }, --grab attack 1.1
			{ q = q(168,916,53,61), ox = 17, oy = 60, func = grabLast_attack, delay = 0.18 }, --dash4
			{ q = q(117,519,40,63), ox = 17, oy = 62, delay = 0.1 }, --c2.1
			delay = 0.02
		},
		grabHitEnd = {
			{ q = q(2,1044,56,63), ox = 30, oy = 62, delay = 0.25 }, --grab end 1.1
			{ q = q(2,979,45,63), ox = 22, oy = 62, delay = 0.01 }, --grab
			{ q = q(60,1047,51,60), ox = 17, oy = 59, func = grabEnd_attack, delay = 0.25 }, --grab end 1.2
			{ q = q(113,1044,45,63), ox = 18, oy = 62 }, --grab end 1.3
			delay = 0.1
		},
		grabThrow = {
			{ q = q(2,1109,45,62), ox = 25, oy = 61, delay = 0.2 }, --throw 1.1
			{ q = q(49,1111,42,60), ox = 18, oy = 59, func = grabThrow_now, delay = 0.05 }, --throw 1.2
			{ q = q(93,1112,42,59), ox = 17, oy = 58, delay = 0.2 }, --throw 1.3
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			delay = 0.1
		},
		grabSwap = {
			{ q = q(137,1109,44,62), ox = 22, oy = 62 }, --grab swap 1.1
			{ q = q(183,1109,37,62), ox = 18, oy = 62 }, --grab swap 1.2
			delay = 5
		},
		grabbed = {
			{ q = q(2,330,45,63), ox = 24, oy = 62 }, --hh1
			{ q = q(49,331,47,62), ox = 27, oy = 61 }, --hh2
			delay = 0.1
		},

	} --offsets

} --return (end of file)