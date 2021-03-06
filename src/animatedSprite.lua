--[[
    animatedSprite.lua - 2018

    Copyright Dejaime Antonio de Oliveira Neto, 2014
    Don Miguel, 2018

    Released under the MIT license.
    Visit for more information:
    http://opensource.org/licenses/MIT
]]

local ManagerVersion = 0.42

spriteBank = {} --Map with all the sprite definitions
imageBank = {} --Contains all images that were already loaded

local function loadSprite (spriteDef)
    if spriteDef == nil then return nil end
    local definitionFile, errorMsg = love.filesystem.load( spriteDef .. '.lua' )
    if errorMsg then
        error("loadSprite: "..errorMsg)
    end
    local oldSprite = spriteBank [spriteDef]
    spriteBank [spriteDef] = definitionFile()
    --Check the version to verify if it is compatible with this one.
    if spriteBank[spriteDef].serializationVersion ~= ManagerVersion then
        dp("Attempt to load file with incompatible versions: "..spriteDef)
        dp("Expected version "..ManagerVersion..", got version "
            ..spriteBank[spriteDef].serializationVersion.." .")
        spriteBank[spriteDef] = oldSprite -- Undo the changes due to error
        -- Return old value (nil if not previously loaded)
        return spriteBank[spriteDef]
    end
    --Storing the path to the image in a variable (to add readability)
    local spriteSheet = spriteBank[spriteDef].spriteSheet
    imageBank [spriteSheet] = love.graphics.newImage(spriteSheet)
    if love.filesystem.exists( spriteDef .. '_sp.lua' ) then --TODO change to love.filesystem.getInfo for Love2D 11
        return spriteBank [spriteDef], loadSprite(spriteDef .. '_sp')
    end
    return spriteBank [spriteDef]
end

function loadSpriteSheet(spriteSheet)
    --Load the image into image bank.
    --returns width, height, image
    imageBank[spriteSheet] = love.graphics.newImage(spriteSheet)
    return imageBank[spriteSheet]:getDimensions()
end

---Returns instance of the defined sprite
---@param spriteDef string Path to the sprite definition file
function getSpriteInstance (spriteDef)
    if spriteDef == nil then return nil end -- invalid use
    if spriteBank[spriteDef] == nil then
        --Sprite not loaded attempting to load; abort on failure.
        if loadSprite (spriteDef) == nil then return nil end
    end
    local s = {
        def = spriteBank[spriteDef], --Sprite reference
        curAnim = nil,
        curFrame = 1,
        maxFrame = 1,
        isThrow = false,
        isFirst = true, -- if the 1st frame
        isLast = false, -- if the last frame
        isFinished = false, -- last frame played till the end and the animation is not a loop
        comboEnd = false, -- stare next combo from 1
        loopCount = 0, -- loop played times
        elapsedTime = 0,
        sizeScale = 1,
        timeScale = 1,
        rotation = 0,
        flipH = 1, -- 1 normal, -1 mirrored
        flipV = 1	-- same
    }
    calculateSpriteAnimation(s)
    return s
end

---Set current animation of the current sprite
---@param spr object
---@param anim string
function setSpriteAnimation(spr, anim)
    spr.curFrame = 1
    spr.loopCount = 0
    spr.curAnim = anim
    spr.isFinished = false
    spr.funcCalledOnFrame = -1
    spr.funcContCalledOnFrame = -1
    spr.elapsedTime = -math.min(love.timer.getDelta() / 2, 0.1)
    spr.isThrow = spr.def.animations[spr.curAnim].isThrow
    spr.comboEnd = spr.def.animations[spr.curAnim].comboEnd
    spr.maxFrame = #spr.def.animations[spr.curAnim]
end

---Does the sprite have 'anim' animation?
---@param spr object
---@param anim string
---@return boolean
function spriteHasAnimation(spr, anim)
    if spr.def.animations[anim] then
        return true
    end
    return false
end

function getSpriteQuad(spr, frame_n)
    local sc = spr.def.animations[spr.curAnim][frame_n or spr.curFrame]
    return sc.q
end

function getSpriteFrame(spr, frame_n)
    return spr.def.animations[spr.curAnim][frame_n or spr.curFrame]
end

-- calculate the animation delay
function getSpriteAnimationDelay(spr, anim)
    if not spr.def.animations[anim] then
--        print(spr, spr.def, spr.def.animations, spr.def.animations[anim])
--        print(inspect(spr.def.animations, {depth=1}))
        error("There is no "..anim.." animation to calc its delay. ")
    end
    local delay = 0
    local a = spr.def.animations[anim]
    for i = 1, #a do
        delay = delay + (a[i].delay or a.delay or spr.def.delay)
    end
    --a.delay = delay
    return delay
end

-- get the max animations of the same type: combo4 -> 4
function getMaxSpriteAnimation(spr, anim)
    for i = 1, 10 do
        if not spr.def.animations[anim..i] then
            return i - 1
        end
    end
    return 0
end

function calculateSpriteAnimation(spr)
    spr.def.comboMax = getMaxSpriteAnimation(spr, "combo")
    spr.def.maxGrabAttack = getMaxSpriteAnimation(spr, "grabFrontAttack")
--    spr.def.animations["grabFrontAttack"].delay = getSpriteAnimationDelay(spr, "grabFrontAttack")
end

function updateSpriteInstance(spr, dt, slf)
    local s = spr.def.animations[spr.curAnim]
    local sc = s[spr.curFrame]
    -- is there default delay for frames of 1 animation?
    if not s.delay then
        s.delay = spr.def.delay
    end
    if not sc then
        error("Missing frame #"..spr.curFrame.." in "..spr.curAnim.." animation")
    end
    -- is there delay for this frame?
    if not sc.delay then
        sc.delay = s.delay
    end
    -- call custom frame func once per the frame
    if sc.func and spr.funcCalledOnFrame ~= spr.curFrame and slf then
        spr.funcCalledOnFrame = spr.curFrame
        sc.func(slf, false) --isfuncCont = false
    end
    -- call the custom frame func on every frame
    if sc.funcCont and slf then
        sc.funcCont(slf, true) --isfuncCont = true
        spr.funcContCalledOnFrame = spr.curFrame -- do not move before funcCont call
    end
    --spr.def.animations[spr.curAnim]
    --Increment the internal counter.
    spr.elapsedTime = spr.elapsedTime + dt

    --We check we need to change the current frame.
    if spr.elapsedTime > sc.delay * spr.timeScale then
        --Check if we are at the last frame.
        if spr.curFrame < #s then
            -- Not on last frame, increment.
            spr.curFrame = spr.curFrame + 1
        else
            -- Last frame, loop back to 1.
            if s.loop then	--if cycled animation
                spr.curFrame = s.loopFrom or 1
                spr.loopCount = spr.loopCount + 1 --loop played times++
            else
                spr.isFinished = true
            end
            spr.funcCalledOnFrame = -1
            spr.funcContCalledOnFrame = -1
        end
        if s[spr.curFrame].spanFunc then -- span function from the prev frame
            s[spr.curFrame].funcCont = sc.funcCont
        else
            -- Reset internal counter on frame change.
            spr.elapsedTime = 0
        end
    end
    -- First or Last frames or the 1st start frame after the loop?
    spr.isFirst = (spr.curFrame == 1)
    spr.isLast = (spr.curFrame == #s)
    spr.isLoopFrom = (spr.curFrame == (s.loopFrom or 1))
    return nil
end

function drawSpriteInstance (spr, x, y, frame)
    local sc = spr.def.animations[spr.curAnim][frame or spr.curFrame or 1]
    local scale_h, scale_v, flipH, flipV = sc.scale_h or 1, sc.scale_v or 1, sc.flipH or 1, sc.flipV or 1
    local rotate, rx, ry = sc.rotate or 0, sc.rx or 0, sc.ry or 0 --due to rotation we have to adjust spr pos
    local y_shift = y
    if flipV == -1 then
        y_shift = y - sc.oy * spr.sizeScale
    end
    love.graphics.draw (
        imageBank[spr.def.spriteSheet], --The image
        sc.q, --Current frame of the current animation
        math.floor((x + rx * spr.flipH * flipH) * 2) / 2, math.floor((y_shift + ry) * 2) / 2,
        (spr.rotation + rotate) * spr.flipH * flipH,
        spr.sizeScale * spr.flipH * scale_h * flipH,
        spr.sizeScale * spr.flipV * scale_v * flipV,
        sc.ox, sc.oy
    )
end

function drawSpriteCustomInstance(spr, x, y, curAnim, frame)
    local sc = spr.def.animations[curAnim][frame]
    local scale_h, scale_v, flipH, flipV = sc.scale_h or 1, sc.scale_v or 1, sc.flipH or 1, sc.flipV or 1
    local rotate, rx, ry = sc.rotate or 0, sc.rx or 0, sc.ry or 0 --due to rotation we have to adjust spr pos
    local y_shift = y
    if flipV == -1 then
        y_shift = y - sc.oy * spr.sizeScale
    end
    love.graphics.draw (
        imageBank[spr.def.spriteSheet], --The image
        sc.q, --Current frame of the current animation
        math.floor((x + rx * spr.flipH * flipH) * 2) / 2, math.floor((y_shift + ry) * 2) / 2,
        (spr.rotation + rotate) * spr.flipH * flipH,
        spr.sizeScale * spr.flipH * scale_h * flipH,
        spr.sizeScale * spr.flipV * scale_v * flipV,
        sc.ox, sc.oy
    )
end

function parseSpriteAnimation(spr, curAnim)
    if (curAnim or spr.curAnim) == "icon" then
        return "Cannot parse icons"
    end
    local o = (curAnim or spr.curAnim).." = {\n"

    local animations = spr.def.animations[curAnim or spr.curAnim]
    local sc
    local scale_h, scale_v, flipH, flipV, funcCont, func
    local ox, oy, delay
    local x, y, w, h
    local rotate, rx, ry
    local wRotate, wx, wy, wAnimation, wFlip_h, wFlip_v

    for i = 1, #animations do
        sc = animations[i]
        delay = sc.delay or 100
        scale_h, scale_v, flipH, flipV = sc.scale_h or 1, sc.scale_v or 1, sc.flipH or 1, sc.flipV or 1
        rotate, rx, ry = sc.rotate or 0, sc.rx or 0, sc.ry or 0
        wRotate, wx, wy, wAnimation = sc.wRotate or 0, sc.wx, sc.wy or 0, sc.wAnimation or "?"
        wFlip_h, wFlip_v = sc.wFlip_h or 1, sc.wFlip_v or 1
        ox, oy = sc.ox or 0, sc.oy or 0
        x, y, w, h = sc.q:getViewport( )
        func, funcCont = sc.func, sc.funcCont

        o = o .. "    { q = q("..x..","..y..","..w..","..h.."), ox = "..ox..", oy = "..oy
        if delay ~= animations.delay then
            o = o .. ", delay = "..delay
        end
        if rotate ~= 0 then
            o = o .. ", rotate = "..rotate
        end
        if rx ~= 0 then
            o = o .. ", rx = "..rx
        end
        if ry ~= 0 then
            o = o .. ", ry = "..ry
        end
        if flipH ~= 1 then
            o = o .. ", flipH = "..flipH
        end
        if flipV ~= 1 then
            o = o .. ", flipV = "..flipV
        end
        if func then
            o = o .. ", func = FUNC0"
        end
        if funcCont then
            o = o .. ", funcCont = FUNC1"
        end
        if wx then
            o = o .. ",\n        wx = "..wx..", wy = "..wy..", wRotate = "..wRotate..", wAnimation = '"..wAnimation.."'"
            if wFlip_h ~= 1 then
                o = o .. ", wFlip_h = "..wFlip_h
            end
            if wFlip_v ~= 1 then
                o = o .. ", wFlip_v = "..wFlip_v
            end
        end
        o = o .. " },\n"
    end
    if animations.loop then
        o = o .. "    loop = true,\n"
    end
    if animations.loopFrom then
        o = o .. "    loopFrom = "..animations.loopFrom..",\n"
    end
    if animations.delay then
        o = o .. "    delay = "..animations.delay..",\n"
    end
    o = o .. "},\n"
    return o
end
