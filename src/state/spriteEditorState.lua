-- Sprite Editor
spriteEditorState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local menu_item_h = 40
local menu_y_offset = 200 - menu_item_h
local menu_x_offset = 0
local hint_y_offset = 80
local title_y_offset = 24
local left_item_offset  = 6
local top_item_offset  = 6
local item_width_margin = left_item_offset * 2
local item_height_margin = top_item_offset * 2 - 2

local txt_current_sprite = nil --love.graphics.newText( gfx.font.kimberley, "SPRITE" )
local txt_items = {"ANIMATIONS", "FRAMES", "WEAPON ANIMATIONS", "SHADERS", "BACK"}

local hero = nil
local sprite = nil
local animations = nil

local weapon = nil
local sprite_weapon = nil
local animations_weapon = {}

local menu = fillMenu(txt_items, txt_hints)

local menu_state, old_menu_state = 1, 1
local mouse_x, mouse_y, old_mouse_y = 0, 0, 0

local sort_abc_func = function( a, b ) return a.bName < b.bName end

function spriteEditorState:enter(_, _hero, _weapon)
    hero = _hero
    sprite = GetSpriteInstance(hero.sprite_instance)
    sprite.sizeScale = 2
    txt_current_sprite = love.graphics.newText( gfx.font.kimberley, hero.name )
    animations = {}
    for key, val in pairs(sprite.def.animations) do
        animations[#animations + 1] = key
    end
    table.sort( animations )
    SetSpriteAnimation(sprite,animations[1])

    weapon = _weapon
    if weapon then
        sprite_weapon = GetSpriteInstance(weapon.sprite_instance)
        sprite_weapon.sizeScale = 2
        animations_weapon = {}
        for key, val in pairs(sprite_weapon.def.animations) do
            animations_weapon[#animations_weapon + 1] = key
        end
        table.sort( animations_weapon )
        SetSpriteAnimation(sprite_weapon,"angle0")
    else
        sprite_weapon = nil
        animations_weapon = {}
    end
    menu[1].n = 1
    menu[3].n = 1
    mouse_x, mouse_y = 0,0

    --TEsound.stop("music")
    -- Prevent double press at start (e.g. auto confirmation)
    Control1.attack:update()
    Control1.jump:update()
    Control1.start:update()
    Control1.back:update()
    love.graphics.setLineWidth( 2 )
    self:wheelmoved(0, 0)   --pick 1st sprite to draw
end

local function displayHelp()
    local font = love.graphics.getFont()
    local x, y = left_item_offset, menu_y_offset + menu_item_h
    love.graphics.setFont(gfx.font.arcade3)
    love.graphics.setColor(100, 100, 100, 255)
    if not weapon then
        if menu_state == 1 then
            love.graphics.print(
[[<- -> / Mouse wheel :
    Select weapon
    animation

Attack/Enter :
    Replay animation]], x, y)
        elseif menu_state == 2 then
            love.graphics.print(
[[<- -> / Mouse wheel :
    Select frame

L-Shift + Arrows :
    Weapon Position

L-Alt + <- -> :
    Rotate Weapon

Attack/Enter :
    Dump to Console]], x, y)
        elseif menu_state == 4 then
            love.graphics.print(
[[<- -> / Mouse wheel :
    Select shader]], x, y)
        end
    else
        if menu_state == 1 then
            love.graphics.print(
[[<- -> / Mouse wheel :
    Select character
    animation

Attack/Enter :
    Replay animation]], x, y)
        elseif menu_state == 2 then
            love.graphics.print(
[[<- -> / Mouse wheel :
    Select frame
L-Shift + Arrows :
    Char Position
L-Alt + <- -> :
    Rotate Character
L-Ctrl + Arrows :
    Flip Character
R-Shift + Arrows :
    Weapon Position
R-Alt + <- -> :
    Rotate Weapon
R-Ctrl + Arrows :
    Flip Weapon
0 : Show/hide center
    of weapon sprite
Attack/Enter :
    Dump to Console]], x, y)
        elseif menu_state == 3 then
            love.graphics.print(
[[Attack/Enter :
     Set this weapon
     animation to
     the current
     character's frame

<- -> / Mouse wheel :
    Select weapon
    animation]], x, y)
        elseif menu_state == 4 then
            love.graphics.print(
[[<- -> / Mouse wheel :
    Select shader]], x, y)
        end
    end
    love.graphics.setFont(font)
end

--Only P1 can use menu / options
function spriteEditorState:player_input(controls)
    local s = sprite.def.animations[sprite.curAnim]
    local m = menu[menu_state]
    local f = s[m.n]    --current frame
    if menu_state == 2 then --static frame
        if love.keyboard.isDown('lctrl') then
            --flip sprite frame horizontally & vertically
            if controls.horizontal:pressed() then
                f.flipH = controls.horizontal:getValue()
            end
            if controls.vertical:pressed() then
                f.flipV = controls.vertical:getValue()
            end
            return
        end
        if love.keyboard.isDown('rctrl') then
            --flip weapon frame horizontally & vertically
            if controls.horizontal:pressed() then
                f.wFlip_h = controls.horizontal:getValue()
            end
            if controls.vertical:pressed() then
                f.wFlip_v = controls.vertical:getValue()
            end
            return
        end
        if love.keyboard.isDown('lshift') then
            --change ox, oy offset of the sprite frame
            if controls.horizontal:pressed() then
                f.ox = f.ox + controls.horizontal:getValue()
            end
            if controls.vertical:pressed() then
                f.oy = f.oy + controls.vertical:getValue()
            end
            return
        end
        if love.keyboard.isDown('rshift') then
            --change ox, oy offset of the weapon
            if not sprite_weapon then
                return
            end
            if not f.wx then
                f.wx = 0
                f.wy = -20
                f.wAnimation = animations_weapon[menu[3].n]
                f.wRotation = 0
            end
            if controls.horizontal:pressed() then
                f.wx = f.wx + controls.horizontal:getValue()
            end
            if controls.vertical:pressed() then
                f.wy = f.wy + controls.vertical:getValue()
            end
            return
        end
        if love.keyboard.isDown('lalt') then
            --change rotation of the sprite frame
            if not f.rotate then
                f.rotate = 0
            end
            if controls.horizontal:pressed() then
                f.rotate = f.rotate + controls.horizontal:getValue() * math.pi / 20
                if ( f.rotate ~= 0 and f.rotate > -0.1 and f.rotate < 0.1 )
                    or f.rotate >= math.pi * 2 or f.rotate <= -math.pi * 2
                then
                    f.rotate = 0
                end
            end
            return
        end
        if love.keyboard.isDown('ralt') then
            --change rotation of the weapon
            if not sprite_weapon or not f.wx then
                return
            end
            if not f.wRotate then
                f.wRotate = 0
            end
            if controls.horizontal:pressed() then
                f.wRotate = f.wRotate + controls.horizontal:getValue() * math.pi / 20
                if ( f.wRotate ~= 0 and f.wRotate > -0.1 and f.wRotate < 0.1 )
                    or f.wRotate >= math.pi * 2 or f.wRotate <= -math.pi * 2
                then
                    f.wRotate = 0
                end
            end
            return
        end
    end

    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menuCancel")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return self:confirm( mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1)then
        self:wheelmoved(0, -1)
    elseif controls.horizontal:pressed(1)then
        self:wheelmoved(0, 1)
    elseif controls.vertical:pressed(-1) then
        menu_state = menu_state - 1
    elseif controls.vertical:pressed(1) then
        menu_state = menu_state + 1
    end
    if menu_state < 1 then
        menu_state = #menu
    end
    if menu_state > #menu then
        menu_state = 1
    end
end

function spriteEditorState:update(dt)
    time = time + dt
    if menu_state ~= old_menu_state then
        sfx.play("sfx","menuMove")
        old_menu_state = menu_state
    end
    if sprite then
        UpdateSpriteInstance(sprite, dt)
    end
    if sprite_weapon then
--        UpdateSpriteInstance(sprite_weapon, dt)
    end
    self:player_input(Control1)
end

local function DrawSpriteWeapon(sprite, x, y, i)
    if sprite_weapon then
        local s = sprite.def.animations[sprite.curAnim][i or sprite.curFrame or 1]
        local wx, wy, wAnimation
        if s.wx and s.wy then
            wx = s.wx * sprite_weapon.sizeScale or 0
            wy = s.wy * sprite_weapon.sizeScale or 0
            wAnimation = s.wAnimation or "angle0"
            if sprite_weapon.curAnim ~= wAnimation then
                SetSpriteAnimation(sprite_weapon, wAnimation)
            end
            sprite_weapon.rotation = s.wRotate or 0
            sprite_weapon.flipH = s.wFlip_h or 1
            sprite_weapon.flipV = s.wFlip_v or 1
            DrawSpriteInstance(sprite_weapon, x + wx, y + wy)
            if GLOBAL_SETTING.DEBUG then
                --center of the weapon animation
                love.graphics.rectangle("fill", x + wx - 2, y + wy, 6, 2)
                love.graphics.rectangle("fill", x + wx, y + wy - 2, 2, 6)
            end
        end
    end
end

function spriteEditorState:draw()
    push:start()
    displayHelp()
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1,#menu do
        local m = menu[i]
        if i == 1 then
            m.item = animations[m.n].." #"..m.n
            local m2 = menu[2]
            if m2.n > #sprite.def.animations[sprite.curAnim] then
                m2.n = #sprite.def.animations[sprite.curAnim]
            end
            m2.item = "FRAME #"..m2.n.." of "..#sprite.def.animations[sprite.curAnim]
            m.hint = ""
        elseif i == 2 then
            local s = sprite.def.animations[sprite.curAnim]
            m.item = "FRAME #"..m.n.." of "..#sprite.def.animations[sprite.curAnim]
            m.hint = ""
            if s[m.n].delay then
                m.hint = m.hint .. "FR.DELAY "..s[m.n].delay.." "
            elseif s.delay then
                m.hint = m.hint .. "DELAY "..s.delay.." "
            end
            if s.loop then
                m.hint = m.hint .. "LOOP "
            end
            if s[m.n].func then
                m.hint = m.hint .. "FUNC "
            end
            if s[m.n].flipH then
                m.hint = m.hint .. "flipH "
            end
            if s[m.n].flipV then
                m.hint = m.hint .. "flipV "
            end
            if s[m.n].ox and s[m.n].oy then
                m.hint = m.hint .. "\nOXY:"..s[m.n].ox..","..s[m.n].oy.." "
            end
            if s[m.n].rotate then
                m.hint = m.hint .. "R:"..s[m.n].rotate.." RXY:"..(s[m.n].rx or 0)..","..(s[m.n].ry or 0).." "
            end
            if s[m.n].wx then
                m.hint = m.hint .. "\nWXY:"..s[m.n].wx..","..s[m.n].wy.." WR:"..(s[m.n].wRotate or 0).." "..(s[m.n].wAnimation or "?")
            end
        elseif i == 3 then
            if not animations_weapon or #animations_weapon < 1 then
                m.item = "N/A"
                m.hint = ""
            else
                m.item = animations_weapon[m.n].." #"..m.n.." of "..#animations_weapon
                m.hint = ""
                local s = sprite.def.animations[sprite.curAnim]
                if sprite_weapon.curAnim ~= animations_weapon[menu[menu_state].n] then
                    SetSpriteAnimation(sprite_weapon, animations_weapon[menu[menu_state].n])
                end
            end
        elseif i == 4 then
            if m.n > #hero.shaders then
                m.n = #hero.shaders
            end
            if #hero.shaders < 1 then
                m.item = "NO SHADERS"
                m.hint = ""
            else
                if not hero.shaders[m.n] then
                    m.item = "SHADER #"..m.n.." (ORIGINAL)"
                else
                    m.item = "SHADER #"..m.n
                end
                m.hint = ""
            end
        end
        calcMenuItem(menu, i)
        if i == old_menu_state then
            love.graphics.setColor(200, 200, 200, 255)
            love.graphics.print(m.hint, m.wx, m.wy)
            love.graphics.setColor(0, 0, 0, 80)
            love.graphics.rectangle("fill", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
            love.graphics.setColor(255,200,40, 255)
            love.graphics.rectangle("line", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(m.item, m.x, m.y )

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= old_mouse_y and
                CheckPointCollision(mouse_x, mouse_y, m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin )
        then
            old_mouse_y = mouse_y
            menu_state = i
        end
    end
    --header
    love.graphics.setColor(255, 255, 255, 120)
    love.graphics.draw(txt_current_sprite, (screen_width - txt_current_sprite:getWidth()) / 2, title_y_offset)

    --character sprite
    local sc = sprite.def.animations[sprite.curAnim][1]
    local xStep = 140 --(sc.ox or 20) * 4 + 8 or 100
    local x = screen_width /2
    local y = menu_y_offset + menu_item_h / 2
    if sprite.curAnim == "icon" then --normalize icon's pos
        y = y - 40
        x = x - 40
    end
    love.graphics.setColor(255, 255, 255, 255)
    if hero.shaders[menu[4].n] then
        love.graphics.setShader(hero.shaders[menu[4].n])
    end
    if sprite then --for Obstacles w/o shaders
        if menu_state == 2 then
            --1 frame
            love.graphics.setColor(255, 0, 0, 150)
            love.graphics.rectangle("fill", 0, y, screen_width, 2)
            love.graphics.setColor(0, 0, 255, 150)
            love.graphics.rectangle("fill", x, 0, 2, menu_y_offset + menu_item_h)
            if menu[menu_state].n > #sprite.def.animations[sprite.curAnim] then
                menu[menu_state].n = 1
            end
            love.graphics.setColor(255, 255, 255, 150)
            for i = 1, #sprite.def.animations[sprite.curAnim] do
                DrawSpriteInstance(sprite, x - (menu[menu_state].n - i) * xStep, y, i )
                DrawSpriteWeapon(sprite, x - (menu[menu_state].n - i) * xStep, y, i )
            end
            love.graphics.setColor(255, 255, 255, 255)
            DrawSpriteInstance(sprite, x, y, menu[menu_state].n)
            DrawSpriteWeapon(sprite, x, y, menu[menu_state].n)
        elseif menu_state == 3 then
            if sprite_weapon then
                love.graphics.setColor(255, 255, 255, 255)
                sprite_weapon.rotation = 0
                sprite_weapon.flipV = 1
                sprite_weapon.flipH = 1
                DrawSpriteInstance(sprite_weapon, x, y, 1)
            end
        else
            --animation
            DrawSpriteInstance(sprite, x, y)
            DrawSpriteWeapon(sprite, x, y)
        end
    end
    if hero.shaders[menu[3].n] then
            love.graphics.setShader()
    end
    showDebug_indicator()
    push:finish()
end

function spriteEditorState:confirm( x, y, button, istouch )
    if (button == 1 and menu_state == #menu) or button == 2 then
        sfx.play("sfx","menuCancel")
        TEsound.stop("music")
        TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
        return Gamestate.pop()
    end
    if button == 1 then
        if menu_state == 1 then
            SetSpriteAnimation(sprite, animations[menu[menu_state].n])
            sfx.play("sfx","menuSelect")
        elseif menu_state == 2 then
            print(ParseSpriteAnimation(sprite))
            sfx.play("sfx","menuSelect")
        elseif menu_state == 3 then
            --set current characters frame weapon anim
            if sprite_weapon then
                local s = sprite.def.animations[sprite.curAnim]
                local f = s[menu[2].n]    --current char-sprite frame
                f.wAnimation = animations_weapon[menu[menu_state].n]
                sfx.play("sfx","menuSelect")
            else
                sfx.play("sfx","menuCancel")
            end
        elseif menu_state == 4 then
            sfx.play("sfx","menuSelect")
        end
    end
end

function spriteEditorState:wheelmoved(x, y)
    local i = 0
    if y > 0 then
        i = 1
    elseif y < 0 then
        i = -1
    else
        return
    end
    menu[menu_state].n = menu[menu_state].n + i
    if menu_state == 1 then
        if menu[menu_state].n < 1 then
            menu[menu_state].n = #animations
        end
        if menu[menu_state].n > #animations then
            menu[menu_state].n = 1
        end
        SetSpriteAnimation(sprite, animations[menu[menu_state].n])

    elseif menu_state == 2 then
        --frames
        if menu[menu_state].n < 1 then
            menu[menu_state].n = #sprite.def.animations[sprite.curAnim]
        end
        if menu[menu_state].n > #sprite.def.animations[sprite.curAnim] then
            menu[menu_state].n = 1
        end
        if #sprite.def.animations[sprite.curAnim] <= 1 then
            return
        end

    elseif menu_state == 3 then
        --weapon frames
        if not sprite_weapon then
            return
        end
        if menu[menu_state].n < 1 then
            menu[menu_state].n = #animations_weapon
        end
        if menu[menu_state].n > #animations_weapon then
            menu[menu_state].n = 1
        end
        SetSpriteAnimation(sprite_weapon, animations_weapon[menu[menu_state].n])

    elseif menu_state == 4 then
        --shaders
        if #hero.shaders < 1 then
            return
        end
        if menu[menu_state].n < 0 then
            menu[menu_state].n = #hero.shaders
        end
        if menu[menu_state].n > #hero.shaders then
            menu[menu_state].n = 0
        end
    end
    if menu_state ~= #menu then
        sfx.play("sfx","menuMove")
    end
end

function spriteEditorState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    self:confirm( x, y, button, istouch )
end

function spriteEditorState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end