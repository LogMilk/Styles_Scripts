function getName()
    return "Stuck"
end

throw = 0

function init_script()
	Rotation = module_manager.register_boolean("Stuck", "Block Rotation Packet", true)
	Using = module_manager.register_boolean("Stuck", "Block Using Packet", true)
end

function on_enable()
    Motion = {player.get_motion_x(),player.get_motion_y(),player.get_motion_z()}
	X = player.get_motion_x()
	Y = player.get_motion_y()
	Z = player.get_motion_z()
	Yaw = player.angles():get_yaw()
	Pitch = player.angles():get_pitch()
	module_manager.disable("Kill Aura")
	module_manager.disable("Scaffold")
end

function on_player_move(event)
	event:set_x(0)
	event:set_y(0)
	event:set_z(0)
	return event
end

function on_disable()
    throw = 0
	if (player.angles():get_yaw() ~= Yaw or player.angles():get_pitch() ~= Pitch) and Rotation:get_boolean() and throw == 0 then
		player.send0x05(player.angles():get_yaw(), player.angles():get_pitch(), false)
	end
    player.set_motion(table.unpack(Motion))
end

function on_send_packet(id)
	if id == 0x03 or id == 0x04 then
		return true
	end
    if throw == 0 or throw == 2 then
		if (id == 0x07 or id == 0x08) and Using:get_boolean() then
			return true
		end
		if (id == 0x05 or id == 0x06) and Rotation:get_boolean() then
			return true
		end
	end
end

function on_pre_update()
	-- if math.abs(player.get_motion_x()) + math.abs(player.get_motion_z()) > 0.2 and player.hurt_time() == 9 then
	-- 	Motion = {player.get_motion_x(),player.get_motion_y(),player.get_motion_z()}
	-- 	client.print("Received motion "..player.get_motion_x().." "..player.get_motion_z())
	-- end
	if input.is_mouse_down(1) and throw == 0 then
        throw = 1
		client.print("Use item")
		if (player.angles():get_yaw() ~= Yaw or player.angles():get_pitch() ~= Pitch) and Rotation:get_boolean() then
        	player.send0x05(player.angles():get_yaw(), player.angles():get_pitch(), false)
		end
		player.right_click_mouse()
		Yaw = player.angles():get_yaw()
		Pitch = player.angles():get_pitch()
		throw = 2
    end
end

function on_receive_packet(id)
	if id == 0x08 then
		client.print("Stuck disabled! (S08)")
		module_manager.disable("Stuck")
	end
end