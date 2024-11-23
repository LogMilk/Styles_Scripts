function getName()
    return "Intave No Fall"
end

progress = 0

function init_script()
    Click = module_manager.register_number("Intave No Fall", "Click", 17, 15, 50, 1)
    Fall = module_manager.register_number("Intave No Fall", "Min Fall Distance", 5, 3, 20, 1)
    module_manager.register_label("Intave No Fall", "Click < 17 may not work")
end

function on_tick()
    if progress == 3 and player.using_item() then
        world.set_timer(1)
        progress = 0
    end
    if player.on_ground() and progress == 2 then
        progress = 3
        player.send0x07("RELEASE_USE_ITEM", "DOWN", player.create_position(0,0,0))
        client.print("Reset due to ground, use any item to move")
    end
    if player.fall_distance() > Fall:get_int() and progress == 0 and world.block(player.position():get_x(), player.position():get_y()-5, player.position():get_z()) ~= "tile.air" then
        player.send0x09(find_slot('item.sword',1,string.len('item.sword')))
        player.set_held_item_slot(find_slot('item.sword',1,string.len('item.sword')))
        for i = 1, Click:get_int() do
            player.right_click_mouse()
        end
        client.print("Waiting for lagback")
        world.set_timer(0.5)
        progress = 1
    end
end

function on_player_move(event)
    if player.fall_distance() > Fall:get_int() - 2 and world.block(player.position():get_x(), player.position():get_y()-2, player.position():get_z()) ~= "tile.air" and progress == 1 then
        event:set_x(0.01)
        event:set_y(0)
        event:set_z(0)
    elseif player.fall_distance() > Fall:get_int() and progress < 3 then
        event:set_x(0)
	event:set_z(0)
    end
    if progress == 3 then
        event:set_x(0)
	    event:set_z(0)
    end
    return event
end

function on_receive_packet(id)
    if id == 0x08 and progress == 1 then
        client.print("Lagback")
        progress = 2
    end
end

--from ArmorBreaker.lua
function find_slot(name,start,last)
    local ItemSlot = 0
    while ItemSlot<9 do
        if pcall(function() return inventory.item(ItemSlot):get_name() end) then
            if string.sub(inventory.item(ItemSlot):get_name(),start,last)==name and not(ItemSlot==player.held_item_slot()) then
                return ItemSlot
            end
        end
        ItemSlot=ItemSlot+1
    end
end
