function getName()
    return "Aim Bot"
end

function init_script()
    MaxRange = module_manager.register_number("Aim Bot", "Range", 4, 1, 8, 0.1)
    HorizontalSpeed = module_manager.register_number("Aim Bot", "Horizontal Speed", 0.3, 0.01, 1, 0.01)
    VerticalSpeed = module_manager.register_number("Aim Bot", "Vertical Speed", 0.1, 0.01, 1, 0.01)
    StopOverMouse = module_manager.register_boolean("Aim Bot", "Stop while over mouse", true)
    -- bad work
    -- RandomSpeed = module_manager.register_number("Aim Bot", "Random", 0, 0, 1, 0.01)
    -- Jitter = module_manager.register_boolean("Aim Bot", "Jitter", true)
    module_manager.disable("Aim Bot")
end

function on_post_update()
    Entities = world.entities()
    for i=1, #Entities do
        if not entity.is_living_base(Entities[i]) then
            return
        end
        if player.distance_to_entity(Entities[i]) < MaxRange:get_double() and not entity.is_self(Entities[i]) and entity.is_player(Entities[i]) then
            if StopOverMouse:get_boolean() and player.over_mouse() == Entities[i] then
                return
            end
            px = entity.get_x(player.id())
            py = entity.get_y(player.id())
            pz = entity.get_z(player.id())
            tx = entity.get_x(Entities[i])
            ty = entity.get_y(Entities[i])
            tz = entity.get_z(Entities[i])
            yaw = (math.deg(math.atan2(tz-pz,tx-px))-player.angles():get_yaw())%360
            pitch = math.deg(math.atan2(ty-py,math.sqrt((tx-px)*(tx-px)+(tz-pz)*(tz-pz))))
            player.set_angles(player.angles():get_yaw()+(yaw-90)*HorizontalSpeed:get_double(),player.angles():get_pitch()-(player.angles():get_pitch()+pitch)*VerticalSpeed:get_double())
            -- player.set_angles(player.angles():get_yaw()+(yaw-90)*HorizontalSpeed:get_double()*math.random(1-RandomSpeed:get_double(),1),player.angles():get_pitch()-(player.angles():get_pitch()+pitch)*VerticalSpeed:get_double()*math.random(1-RandomSpeed:get_double(),1))
        end
    end
end

-- function on_send_packet(id)
--     if id == 0x0A and Jitter:get_boolean() then
--         player.set_angles(player.angles():get_yaw()+math.random(-100,100)*0.01,player.angles():get_pitch()+math.random(-100,100)*0.01)
--     end
-- end