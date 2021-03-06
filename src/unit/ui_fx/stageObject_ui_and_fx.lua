-- Copyright (c) .2017 SineDie
-- Visuals and SFX go here

local StageObject = StageObject

local sign = sign

local particles
function StageObject:showEffect(effect, obj)
    if effect == "breakMetal" then
        self:playSfx(self.sfx.onBreak)
        particles = PA_OBSTACLE_BREAK_SMALL:clone()
        particles:setPosition( 0, -obj.z )
        if self.particleColor then
            particles:setColors( unpack(self.particleColor) )
        end
        particles:setLinearAcceleration(sign(-self.face) * 100 , -500, sign(-self.face) * 400, 500) -- Random movement in all directions.
        particles:emit(4)
        particles:setLinearAcceleration(sign(self.face) * 100 , -500, sign(self.face) * 400, 500) -- Random movement in all directions.
        particles:emit(2)
        stage.objects:add(Effect:new(particles, self.x, self.y + 1, self.z))
        particles = PA_OBSTACLE_BREAK_BIG:clone()
        particles:setPosition( 0, -obj.z )
        if self.particleColor then
            particles:setColors( unpack(self.particleColor) )
        end
        --particles:setAreaSpread( "uniform", 2, 8 )
        particles:setLinearDamping( 0.1, 2 )
        particles:setLinearAcceleration(sign(-self.face) * 100 , -500, sign(-self.face) * 400, 500) -- Random movement in all directions.
        particles:emit(2)
        particles:setLinearAcceleration(sign(self.face) * 100 , -500, sign(self.face) * 400, 500) -- Random movement in all directions.
        particles:emit(1)
        stage.objects:add(Effect:new(particles, self.x, self.y + 1, self.z))
    else
        Character.showEffect(self, effect, obj)
    end
end

-- borrow Lifebar methods from Character class
StageObject.initFaceIcon = Character.initFaceIcon
StageObject.drawFaceIcon = Character.drawFaceIcon
StageObject.drawTextInfo = Character.drawTextInfo
StageObject.getBarTransparency = Character.getBarTransparency
StageObject.drawLivesLeftNumber = Character.drawLivesLeftNumber
StageObject.drawScore = Character.drawScore
StageObject.drawBar = Character.drawBar
