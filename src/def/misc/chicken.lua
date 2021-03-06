-- Copyright (c) .2017 SineDie
local spriteSheet = "res/img/misc/loot.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.42, -- The version of this serialization process
    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "chicken", -- The name of the sprite
    delay = 5.23,	--default delay for all animations
    animations = {
        icon = {
            { q = q(22,2,30,19) } -- default 38x17
        },
        stand = {
            { q = q(22,2,30,19), ox = 15, oy = 18 } --on the ground
        },
    }
} --return (end of file)
