-- Copyright (c) .2018 SineDie

-- adjust DEBUG levels
local SHOW_FPS = 1 -- show text of FPS, FRAME, SLOW MO VALUE from this debug level
local SHOW_DEBUG_CONTROLS = 1 -- show pressed keys
local SHOW_DEBUG_UNIT_HITBOX = 2 -- show hitboxes
local SHOW_DEBUG_UNIT_INFO = 3 -- show unit's info: name, pos, state
local SHOW_DEBUG_BOXES = 2 -- show debug boxes (attack hitboxes, enemy AI cross, etc)
local SHOW_DEBUG_BATCHES = 2 -- show left edge of the current batch with red and the next with blue

-- Load PRofiler
if GLOBAL_SETTING.PROFILER_ENABLED then
    Profiler  = require "lib.debug.piefiller"
    ProfOn = false
    Prof = Profiler:new()
end

function getMaxDebugLevel()
    return 3
end

function getDebugLevel()
    if GLOBAL_SETTING and GLOBAL_SETTING.DEBUG then
        if type(GLOBAL_SETTING.DEBUG) ~= "number" then
            GLOBAL_SETTING.DEBUG = 0
        end
        return GLOBAL_SETTING.DEBUG
    end
    return 0
end

function setDebugLevel(n)
    if n >= 0 and n <= getMaxDebugLevel() then
        GLOBAL_SETTING.DEBUG = n
    end
end

function nextDebugLevel()
    GLOBAL_SETTING.DEBUG = getDebugLevel() + 1
    if GLOBAL_SETTING.DEBUG > getMaxDebugLevel() then
        GLOBAL_SETTING.DEBUG = 0
    end
    return GLOBAL_SETTING.DEBUG
end

function prevDebugLevel()
    GLOBAL_SETTING.DEBUG = getDebugLevel() - 1
    if GLOBAL_SETTING.DEBUG < 0 then
        GLOBAL_SETTING.DEBUG = getMaxDebugLevel()
    end
    return GLOBAL_SETTING.DEBUG
end

function isDebug(level)
    if level then
        return getDebugLevel() >= level
    end
    return getDebugLevel() > 0
end

-- Debug console output
function dp(...)
    if isDebug()then
        print(...)
    end
end

-- Print delta x and delta time
__x = 0
__anim = 0
__time = 0
function dpdi(self, text) -- reset delta
    __x = self.x
    __anim = self.sprite.curAnim
    __time = self.time
    print(self.sprite.curAnim, "DPD "..(text or ""))
end

function dpd(self, text) -- print current delta on animation change
    if __anim ~= self.sprite.curAnim then
        __anim = self.sprite.curAnim
        print(string.format("%02.2f",math.abs(self.x - __x)),  string.format("%02.2f",math.abs(self.time - __time)), self.sprite.curAnim, "DPD "..(text or ""))
    end
end

dboc = {}
dboc[0] = { x = 0, y = 0, z = 0, time = 0 }
function dpoInit(o)
    if not isDebug() then
        return
    end
    if not isDebug() then
        return
    end
    dboc[o.name] = { x = o.x, y = o.y, z = o.z, time = love.timer.getTime() }
end
local r = round
function dpo(o, txt)
    if not isDebug() then
        return
    end
    local ox = 0
    local oy = 0
    local oz = 0
    local time = 0
    if dboc[o.name] then
        --        print(o.x, o.y, o.z, o.time)
        ox = dboc[o.name].x or 0
        oy = dboc[o.name].y or 0
        oz = dboc[o.name].z or 0
        time = dboc[o.name].time or love.timer.getTime()
    end
--    print(o.name .. "(" .. o.type .. ") x:" .. o.x .. ",y:" .. o.y .. ",z:" .. o.z .. " ->" .. (txt or ""))
--    print("DELTA x: " .. r(math.abs(o.x - ox), 2) .. " y: " .. r(math.abs(o.y - oy), 2) .. " z: " .. math.abs(o.z - oz) .. " t(ms):" .. r(love.timer.getTime() - time, 3))
    print(o.name
            .." Dxyz: " .. r(math.abs(o.x - ox), 2) .. "," .. r(math.abs(o.y - oy), 2) .. "," .. math.abs(o.z - oz)
            .." xyz: " .. r(o.x, 2) .. "," .. r(o.y, 2) .. "," .. r(o.z, 2)
            .. " ".. o.type .. " t(ms): " .. r(love.timer.getTime() - time, 2) .." -> " .. (txt or ""))
    dboc[o.name] = { x = o.x, y = o.y, z = o.z, time = love.timer.getTime() }
end

local frame = 1000
function incrementDebugFrame()
    frame = frame + 1
end
local fonts = { gfx.font.arcade3, gfx.font.arcade3x2, gfx.font.arcade3x3 }
function showDebugIndicator(size, _x, _y)
    local x, y = _x or 2, _y or 480 - 9 * 4
    if isDebug(SHOW_FPS) then
        colors:set("white")
        love.graphics.setFont(fonts[size or 1])
        love.graphics.print("DEBUG:"..getDebugLevel(), x, y)
        love.graphics.print("FPS:"..tonumber(love.timer.getFPS()), x, y + 9 * 1)
        if GLOBAL_SETTING.SLOW_MO > 0 then
            love.graphics.print("SLOW:"..(GLOBAL_SETTING.SLOW_MO + 1), x, y + 9 * 2)
        end
        love.graphics.print("Frame:"..frame, x, y + 9 * 3)
    end
end

function showDebugBatch(l,t,w,h)
    if isDebug(SHOW_DEBUG_BATCHES) then
        local s = stage.batch
        if s then
            local b,b2 = s.batches[s.n], s.batches[s.n + 1]
            if b then
                colors:set("red", nil, 150)
                love.graphics.rectangle("fill", b.leftStopper, t, 1, h)
                love.graphics.rectangle("fill", b.rightStopper, t, 1, h)
                love.graphics.print(b.name, b.leftStopper + 4, t + h - 12)
                if b2 then
                    colors:set("blue", nil, 150)
                    love.graphics.rectangle("fill", b2.leftStopper, t, 1, h)
                    love.graphics.rectangle("fill", b2.rightStopper, t, 1, h)
                    love.graphics.print(b2.name, b2.leftStopper + 4, t + h - 12)
                end
            end
        end
    end
end

function showDebugControls()
    if isDebug(SHOW_DEBUG_CONTROLS) then
        love.graphics.setFont(gfx.font.arcade3)
        -- draw players controls
        for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
            local p = getRegisteredPlayer(i)
            if p and p.lifeBar then
                local x = p.lifeBar.x + 76
                local y = p.lifeBar.y + 36
                colors:set("black", nil, 150)
                love.graphics.rectangle("fill", x - 2, y, 61, 9)
                colors:set("playersColors", p.id)
                if p.b.attack:isDown() then
                    love.graphics.print("A", x, y)
                end
                x = x + 10
                if p.b.jump:isDown() then
                    love.graphics.print("J", x, y)
                end
                local horizontalValue = p.b.horizontal:getValue()
                x = x + 10
                if horizontalValue == -1 then
                    love.graphics.print("<", x, y)
                end
                if p.b.horizontal.isDoubleTap and p.b.horizontal.doubleTap.lastDirection == -1 then
                    love.graphics.print("2", x, y + 10)
                end
                x = x + 10
                if horizontalValue == 1 then
                    love.graphics.print(">", x, y)
                end
                if p.b.horizontal.isDoubleTap and p.b.horizontal.doubleTap.lastDirection == 1 then
                    love.graphics.print("2", x, y + 10)
                end
                local verticalValue = p.b.vertical:getValue()
                x = x + 10
                if verticalValue == -1 then
                    love.graphics.print("^", x, y)
                end
                if p.b.vertical.isDoubleTap and p.b.vertical.doubleTap.lastDirection == -1 then
                    love.graphics.print("2", x, y + 10)
                end
                x = x + 10
                if verticalValue == 1 then
                    love.graphics.print("V", x, y)
                end
                if p.b.vertical.isDoubleTap and p.b.vertical.doubleTap.lastDirection == 1 then
                    love.graphics.print("2", x, y + 10)
                end
                x = p.lifeBar.x + 76
                y = y - 12
                if p.chargeTimer >= p.chargedAt then
                    love.graphics.print("H", x, y)
                end
            end
        end
    end
end

function showDebugBoxes(scale)
    if not scale then
        scale = 1
    end
    if isDebug(SHOW_DEBUG_BOXES) then
        local a
        -- draw attack hitboxes
        for i = 1, #attackHitBoxes do
            a = attackHitBoxes[i]
            if a.d then
                if a.collided then
                    colors:set("red", nil, 150)
                else
                    colors:set("yellow", nil, 150)
                end
                -- yellow: width + height
                love.graphics.rectangle("line", a.x + a.sx * scale, a.y + ( -a.z - a.h / 2) * scale, a.w * scale, a.h * scale)
                colors:set("green", nil, 150)
                -- green: width + depth
                love.graphics.rectangle("line", a.x + a.sx * scale, a.y - (a.d / 2) * scale, a.w * scale, a.d * scale)
            else
                -- red / green(not collided) cross
                if a.collided then
                    colors:set("red", nil, 150)
                else
                    colors:set("green", nil, 150)
                end
                love.graphics.rectangle("line", a.x + a.sx * scale - (a.w / 2) * scale, a.y - a.z * scale, a.w * scale, a.h * scale)
                love.graphics.rectangle("line", a.x + a.sx * scale, a.y + ( -a.z - a.w / 2) * scale, a.h * scale, a.w * scale)
            end
        end
    end
end

function clearDebugBoxes()
    if isDebug() then
        attackHitBoxes = {}
    end
end

function watchDebugVariables()
    if isDebug() then
    end
end

local keysToKill = {f8 = 1, f9 = 2, f10 = 3, f7 = 0}
function checkDebugKeys(key)
    if isDebug() then
        if key == '0' then
            stage.objects:dp()
        elseif key == 'kp+' or key == '=' then
            GLOBAL_SETTING.SLOW_MO = GLOBAL_SETTING.SLOW_MO - 1
            if GLOBAL_SETTING.SLOW_MO < 0 then
                GLOBAL_SETTING.SLOW_MO = 0
                sfx.play("sfx","menuCancel")
            else
                sfx.play("sfx","menuMove")
            end
        elseif key == 'kp-' or key == '-' then
            GLOBAL_SETTING.SLOW_MO = GLOBAL_SETTING.SLOW_MO + 1
            if GLOBAL_SETTING.SLOW_MO > GLOBAL_SETTING.MAX_SLOW_MO then
                GLOBAL_SETTING.SLOW_MO = GLOBAL_SETTING.MAX_SLOW_MO
                sfx.play("sfx","menuCancel")
            else
                sfx.play("sfx","menuMove")
            end
        elseif keysToKill[key] then
            local id = keysToKill[key]
            if id == 0 then
                stage.timeLeft = 0.01
            else
                if getRegisteredPlayer(id) then
                    getRegisteredPlayer(id):setState(getRegisteredPlayer(id).dead)
                end
            end
        end
    end
end

function startUnitHighlight(slf, text, color)
    slf.debugHighlight = true
    slf.debugHighlightText = text or "TEXT"
    slf.debugHighlightColor = color or "lightBlue"
end

function stopUnitHighlight(slf)
    slf.debugHighlight = false
end

function drawUnitHighlight(slf)
    if slf.debugHighlight and slf.debugHighlightColor then
        colors:set(slf.debugHighlightColor, nil, 127)
        love.graphics.rectangle("fill", slf.x - slf.width * 1, slf.y - slf.z - slf.height, slf.width * 2, slf.height )
        love.graphics.print( slf.debugHighlightText, slf.x + slf.width * 1, slf.y - slf.z - slf.height)
    end
end

function drawDebugUnitHitbox(a)
    if isDebug(SHOW_DEBUG_UNIT_HITBOX) then
        colors:set("white", nil, 150)
        love.graphics.rectangle("line", a.x - a.width / 2, a.y - a.height - a.z + 1, a.width, a.height-1)
    end
end

function drawDebugUnitInfo(a)
    if isDebug(SHOW_DEBUG_UNIT_INFO) then
        drawUnitHighlight(a)
        love.graphics.setFont(gfx.font.debug)
        if a.hp <= 0 then
            colors:set("black", nil, 50)
            love.graphics.print( a.name, a.x - 16 , a.y - 7)
        else
            colors:set("black", nil, 120)
            love.graphics.print( "HP "..math.floor(a.hp), a.x - 16 , a.y + 14)
        end
        if a.comboN and a.sprite.def.comboMax > 0 then
            love.graphics.print( "CN" .. a.comboN .. "/".. a.sprite.def.comboMax, a.x - 14, a.y + 21)
        end
        love.graphics.print( a.state, a.x - 14, a.y)
        love.graphics.print( ""..math.floor(a.x).." "..math.floor(a.y).." "..math.floor(a.z), a.x - 22, a.y + 7)
        colors:set("yellow", nil, 120)
        love.graphics.line( a.x, a.y + 6.5, a.x, a.y + 8.5)
        love.graphics.line( a.x, a.y + 7.5, a.x + 10 * a.horizontal, a.y + 7.5)
        colors:set("purple", nil, 120)
        love.graphics.line( a.x, a.y + 8, a.x + 8 * a.face, a.y + 8)
    end
end
