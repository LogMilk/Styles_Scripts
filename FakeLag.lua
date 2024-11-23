function getName()
    return "Fake Lag"
end

Block = false
Tick = 0

function init_script()
    ReleaseTick = module_manager.register_number("Fake Lag", "Release Tick", 5, 1, 20, 1)
    OnlyAura = module_manager.register_boolean("Fake Lag", "Only Aura", true)
end

function on_enable()
    Block = false
    Tick = 0
end

function on_tick()
    if Block then
        Tick = Tick + 1
        if Tick > ReleaseTick:get_int() then
            Tick = 0
            Block = false
        end
    elseif player.kill_aura_target() ~= 0 or not OnlyAura:get_boolean() then
        Tick = 0
        Block = true
    end
    if player.kill_aura_target() == 0 and OnlyAura:get_boolean() then
        Tick = 0
        Block = false
    end
end

function on_receive_packet()
    ::Block::
    if Block then
        goto Block
    end
    return false
end

function on_disable()
    Block = false
    Tick = 0
end

function on_render_screen()
    render.rect(luajava.bindClass("org.lwjgl.opengl.Display"):getWidth()/4-25, luajava.bindClass("org.lwjgl.opengl.Display"):getHeight()/4+10,50*(Tick/ReleaseTick:get_int()),5,-1)
end