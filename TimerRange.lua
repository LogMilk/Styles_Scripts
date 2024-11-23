function getName()
    return "Timer Range"
end

Boost = false
Targeted = false
ShouldBoost = true
Tick = 0
ColdDown = 0
Target = 0

function init_script()
    NTimer = module_manager.register_number("Timer Range", "Negative Timer", 0.35, 0.1, 1, 0.01)
    WaitTick = module_manager.register_number("Timer Range", "Wait Time", 2, 1, 10, 1)
    Timer = module_manager.register_number("Timer Range", "Timer", 3, 1, 20, 0.1)
    BoostTick = module_manager.register_number("Timer Range", "Boost Tick", 1, 1, 20, 1)
    MaxRange = module_manager.register_number("Timer Range", "Max Range", 4, 2, 8, 0.1)
    MinRange = module_manager.register_number("Timer Range", "Min Range", 3.6, 2, 8, 0.1)
    Debug = module_manager.register_boolean("Timer Range", "Debug", false)
end

function on_pre_update()
    if MinRange:get_double() > MaxRange:get_double() then
        MinRange:set_double(MaxRange:get_double()-0.1)
    end
    Entities = world.entities()
    for i=1, #Entities do
        if player.distance_to_entity(Entities[i]) < MaxRange:get_double() and player.distance_to_entity(Entities[i]) > MinRange:get_double() and not entity.is_self(Entities[i]) and entity.is_player(Entities[i]) and ColdDown == 0 and ShouldBoost then
            if Debug:get_boolean() then
                client.print("Boost "..player.distance_to_entity(Entities[i]))
            end
            Target = Entities[i]
            Boost = true
            ColdDown = 20
        end
        if player.distance_to_entity(Entities[i]) < MaxRange:get_double() and not entity.is_self(Entities[i]) and entity.is_player(Entities[i]) then
            Targeted = true
        end
    end
    if Targeted then
        Targeted = false
        ShouldBoost = false
    else
        ShouldBoost = true
    end
end

function on_tick()
    if ColdDown > 0 then
        ColdDown = ColdDown - 1
    end
    if Boost then
        Tick = Tick + 1
        if Tick < WaitTick:get_int() then
            world.set_timer(NTimer:get_double())
        end
        if Tick == WaitTick:get_int() then
            world.set_timer(Timer:get_double())
        end
        if Tick > WaitTick:get_int()+BoostTick:get_int() then
            world.set_timer(1)
            Tick = 0
            if Debug:get_boolean() then
                client.print("Done "..player.distance_to_entity(Target))
            end
            Target = 0
            Boost = false
        end
    end
end

function on_disable()
    Boost = false
    Targeted = false
    ShouldBoost = true
    Tick = 0
    ColdDown = 0
    Target = 0
    world.set_timer(1)
end