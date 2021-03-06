-- Copyright (c) .2018 SineDie
-- Unit Tests helpers functions, saving / restoring environments
local lust = require 'lib.test.lust.lust'
local describe, it, expect = lust.describe, lust.it, lust.expect

-- save DEBUG level
local _debugLevel = getDebugLevel()
setDebugLevel(0)
-- mute units sfx
local _playSfx = Unit.playSfx
Unit.playSfx = function() end
local _playHitSfx = Unit.playHitSfx
Unit.playHitSfx = function() end
function cleanUpAfterTests()
    -- restore DEBUG level
    setDebugLevel(_debugLevel)
    -- restore units sfx
    Unit.playSfx = _playSfx
    Unit.playHitSfx = _playHitSfx
end

function isUnitsState(u, s)
    return function() return u.state == s end
end

function isUnitsCurAnim(u, a)
    return function() return u.sprite.curAnim == a end
end

function isUnitsAtMaxZ(u)
    return function() return u.maxZ > u.z end
end

showSetStateAndWaitDebug = false
function setStateAndWait(a, f)
    if not f then
        f = {}
    end
    local time = f.wait or 3
    local FPS = f.FPS or 60
    local dt = 1 / FPS
    local x, y, z, hp = a.x, a.y, a.z, a.hp
    local _state
    a.maxZ = 0
    if f.setState then
        a:setState(f.setState)
    end
    for i = 1, time * FPS do
        stage:update(dt)
        if a.z > a.maxZ then
            a.maxZ = a.z
        end
        if showSetStateAndWaitDebug and _state ~= a.state then
            print(" ::", a.state, a.x, a.y, a.z, a.hp, "MaxZ:" .. a.maxZ,  "<==", x, y, z, hp)
            _state = a.state
        end
        if f.stopFunc and f.stopFunc(i) then
            break
        end
    end
    --    print(":", a.x, a.y, a.z, a.hp, "MaxZ:" .. a.maxZ,  "<==", x, y, z, hp)
    return a.x, a.y, a.z, a.maxZ, a.hp, x, y, z, hp
end