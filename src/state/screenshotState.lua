screenshotState = {}

local screenWidth = 640
local screenHeight = 480

function screenshotState:enter()
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME * 0.75)
    sfx.play("sfx","menuCancel")

    Controls[1].attack:update()
    Controls[1].jump:update()
    Controls[1].start:update()
    Controls[1].back:update()
end

function screenshotState:leave()
end

--Only P1 can exit the pause
function screenshotState:playerInput(controls)
    if controls.jump:pressed() or controls.back:pressed() or controls.screenshot:pressed() then
        sfx.play("sfx","menuSelect")
        return Gamestate.pop()
    end
end

function screenshotState:update(dt)
    self:playerInput(Controls[1])
end

function screenshotState:draw()
    mainCamera:draw(function(l, t, w, h)
        -- draw camera stuff here
        colors:set("white")
        stage:draw(l,t,w,h)
        showDebugBoxes() -- debug draw collision boxes
    end)
    love.graphics.setCanvas()
    push:start()
    if canvas[1] then
        love.graphics.setBlendMode("alpha", "premultiplied")
        colors:set("white")
        love.graphics.draw(canvas[1], 0,0, nil, 0.5) --bg
        colors:set("white", nil, GLOBAL_SETTING.SHADOW_OPACITY)
        love.graphics.draw(canvas[2], 0,0, nil, 0.5) --shadows
        colors:set("white")
        love.graphics.draw(canvas[3], 0,0, nil, 0.5) --sprites + fg
        love.graphics.setBlendMode("alpha")
    end
    if stage.mode == "normal" then
        drawPlayersBars()
        stage:displayGoTimer(screenWidth, screenHeight)
    end
    push:finish()
end
