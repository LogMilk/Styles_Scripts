function getName()
    return "Keep Motion"
end

Tick = 0
Damage = false

function init_script()
    AutoDisable = module_manager.register_number("Keep Motion", "Auto Disable", 20, 0, 50, 1)
    Boost = module_manager.register_number("Keep Motion", "Boost", 1, 0.1, 5, 0.1)
    HurtTime = module_manager.register_number("Keep Motion", "Hurt Time", 10, 0, 10, 1)
    Ignore = module_manager.register_boolean("Keep Motion", "Ignore Motion Y", false)
end

function on_enable()
    Motion = {player.get_motion_x()*Boost:get_value(),player.get_motion_y()*Boost:get_value(),player.get_motion_z()*Boost:get_value()}
end

function on_pre_update()
    if HurtTime:get_value() == 0 or Damage then
        player.set_motion(table.unpack(Motion))
    end
end

function on_tick()
    if player.hurt_time() == HurtTime:get_value() and HurtTime:get_value() ~= 0 then
        Damage = true
        if Ignore:get_boolean() then
            Motion = {player.get_motion_x()*Boost:get_value(),0,player.get_motion_z()*Boost:get_value()}
        else
            Motion = {player.get_motion_x()*Boost:get_value(),player.get_motion_y()*Boost:get_value(),player.get_motion_z()*Boost:get_value()}
        end
        client.print("Damage")
    end
    if HurtTime:get_value() == 0 or Damage then
        if Tick <= AutoDisable:get_value() then
            Tick = Tick + 1
        elseif AutoDisable:get_value() ~= 0 then
            module_manager.disable("Keep Motion")
        end
    end
end

function on_disable()
    Tick = 0
    Damage = false
end