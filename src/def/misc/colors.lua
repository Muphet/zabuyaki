-- Copyright (c) .2018 SineDie

local class = require "lib/middleclass"
local Colors = class('Colors')

local pauseStateTransp = 0.75   -- used to alter the Pause State screen's darkness
function Colors:initialize()
    self.c = {
        ghostTrailsColors = { {125, 150, 255, 200}, {75, 100, 255, 150 }, {25, 50, 255, 100 } }, -- RGBA, also the number of the ghosts
        playersColors = {{204, 38, 26}, {24, 137, 20}, {23, 84, 216} },
        white = {255, 255, 255, 255},
        chargeAttack = {255, 255, 255, 63},
        lightGray = {200, 200, 200, 255},
        gray = {100, 100, 100, 255},
        black = {0, 0, 0, 255},
        red = {255, 0, 0, 255},
        redGoTimer = {240, 40, 40, 255},
        yellow = {255, 255, 0, 255},
        lightBlue = {0, 255, 255, 255},
        green = {0, 255, 0, 255},
        blue = {0, 0, 255, 255},
        purple = {255, 0, 255, 255},
        darkGray = {55, 55, 55, 255},
        menuOutline = {255, 200, 40, 255},
        debugRedShadow = {40, 0, 0, 255},
        pauseStateColors = { {255 * pauseStateTransp, 255 * pauseStateTransp, 255 * pauseStateTransp, 255},
            {GLOBAL_SETTING.SHADOW_OPACITY * pauseStateTransp, GLOBAL_SETTING.SHADOW_OPACITY * pauseStateTransp,
            GLOBAL_SETTING.SHADOW_OPACITY * pauseStateTransp, GLOBAL_SETTING.SHADOW_OPACITY * pauseStateTransp } },
        batchColors = {{255, 0, 0, 125}, {0, 255, 0, 125}, {0, 0, 255, 125}},
        barNormColor = {244, 210, 14, 255},
        barLosingColor = { 228, 102, 21, 255 },
        barLostColor = { 199, 32, 26, 255 },
        barGotColor = { 34, 172, 11, 255 },
        barTopBottomSmoothColor = { 100, 50, 50, 255 },
    }
end

function Colors:get(name, index)
    if index then
        return self.c[name][index]
    else
        return self.c[name]
    end
end

function Colors:getInstance(name)
    local c = {}
    c[1] = self.c[name][1]
    c[2] = self.c[name][3]
    c[3] = self.c[name][3]
    c[4] = self.c[name][4]
    return c
end

function Colors:unpack(...)
    return unpack(self:get(...))
end

local tempColor, tempAlpha
function Colors:set(name, index, alpha) -- index or alpha might be undefined
    if not name then
        love.graphics.setColor(255, 100, 100)  -- use red color to mark color errors
        return
    end
    if index then
        tempColor = self.c[name][index]
    else
        tempColor = self.c[name]
    end
    if alpha then
        tempAlpha = tempColor[4]
        tempColor[4] = alpha
    end
    love.graphics.setColor(unpack(tempColor))
    if alpha then
        tempColor[4] = tempAlpha
    end
end

return Colors
