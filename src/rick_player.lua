--
-- Created by IntelliJ IDEA.
-- User: DON
-- Date: 04.04.2016
-- Time: 22:23
-- To change this template use File | Settings | File Templates.
--

local class = require "lib/middleclass"

local Rick = class('Rick', Player)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

local function nop() --[[print "nop"]] end

function Rick:initialize(name, sprite, input, x, y, color)
    Player.initialize(self, name, sprite, input, x, y, color)

end

function Rick:combo_start()
    --	print (self.name.." - combo start")
    if self.n_combo > 5 then
        self.n_combo = 1
    end
    self.sprite.curr_frame = 1
    self.sprite.loop_count = 0

    if self.n_combo == 1 then
        self.sprite.curr_anim = "combo1"
    elseif self.n_combo == 2 then
        self.sprite.curr_anim = "combo2"
    elseif self.n_combo == 3 then
        self.sprite.curr_anim = "combo3"
    elseif self.n_combo == 4 then
        self.sprite.curr_anim = "combo4"
    elseif self.n_combo == 5 then
        self.sprite.curr_anim = "combo5"
    else
        self.sprite.curr_anim = "dead"	--TODO remove after debug
    end
    self.check_mash = false

    self.cool_down = 0.2
end
Rick.combo = {name = "combo", start = Rick.combo_start, exit = nop, update = Player.combo_update, draw = Player.default_draw}

return Rick