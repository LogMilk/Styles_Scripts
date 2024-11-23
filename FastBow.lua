function getName()
    return "Fast Bow"
end

function init_script()
    OnlyGround = module_manager.register_boolean("Fast Bow", "Only Ground", false)
end

function on_tick()
    if player.using_item() and module_manager.get_state("Kill Aura") then
        if player.held_item():get_name() == "item.bow" then
            player.send0x08(player.held_item())
            for i=1,20 do
                if not OnlyGround:get_boolean() or player.on_ground() then
                    player.send0x03(player.on_ground())
                end
            end
            player.send0x07("RELEASE_USE_ITEM", "DOWN", player.create_position(0,0,0))
        end
    end
end