function getName()
	return "Drop No Slow"
end

function init_script()
	Mode = module_manager.register_mode("Drop No Slow","Bypass Mode",{"Slow Down","Freeze","Sprint Reset"},"Freeze")
	ActiveTick = module_manager.register_number("Drop No Slow", "Active Tick", 3, 1, 10, 1)
	AutoCancel = module_manager.register_boolean("Drop No Slow", "Auto Cancel", true)
	Jump = module_manager.register_boolean("Drop No Slow", "Jump", false)
	AllItem = module_manager.register_boolean("Drop No Slow", "All usable item", false)
	NoS08Check = module_manager.register_boolean("Drop No Slow", "No S08 Check", false)
	NoDrop = module_manager.register_boolean("Drop No Slow", "No Drop", false)
	NoGroundCheck = module_manager.register_boolean("Drop No Slow", "No Ground Check", true)
end

Eating = 0
Forward = false
Slow = false

function on_send_packet(id)
	if id == 0x09 and Eating ~= 0 then
		client.print("Canceled Eating (C09)")
		Eating = 0
	end
	if id == 0x07 and player.using_item() and AllItem:get_boolean() then
		if not player.on_ground() and not NoGroundCheck:get_boolean() then
			client.print("Canceled (No Ground)")
			Eating = 0
			return false
		end
		if player.held_item():get_count() < 2 then
			client.print("Canceled (One Item)")
			Eating = 0
			return false
		end
		if not NoDrop:get_boolean() then
			Drop = true
		end
		if Mode:get_string() == "Slow Down" then
			Slow = true
			Tick = 0
			player.set_speed(0)
		end
		if Mode:get_string() == "Freeze" then
			Motion = {player.get_motion_x(),player.get_motion_y(),player.get_motion_z()}
			Slow = true
			Tick = 0
		end
		if Mode:get_string() == "Sprint Reset" then
			player.set_sprinting(false)
		end
		return true
	end
	if id == 0x07 and player.using_item() and player.held_item():get_name() == "item.appleGold" and not AllItem:get_boolean() then
		if not player.on_ground() and not NoGroundCheck:get_boolean() and not player.on_ladder() then
			client.print("Canceled (No Ground)")
			Eating = 0
			return false
		end
		if player.held_item():get_count() < 2 then
			client.print("Canceled (One Item)")
			Eating = 0
			return false
		end
		if not NoDrop:get_boolean() then
			Drop = true
		end
		if Mode:get_string() == "Slow Down" then
			Slow = true
			Tick = 0
			player.set_speed(0)
		end
		if Mode:get_string() == "Freeze" then
			Motion = {player.get_motion_x(),player.get_motion_y(),player.get_motion_z()}
			Slow = true
			Tick = 0
		end
		if Mode:get_string() == "Sprint Reset" then
			player.set_sprinting(false)
			Slow = true
			Tick = 0
		end
		return true
	end
end

function on_tick()
	if player.using_item() and AutoCancel:get_boolean() and player.held_item():get_count() > 1 then
		if AllItem:get_boolean() then
			luajava.newInstance("java.awt.Robot"):mouseRelease(luajava.bindClass("java.awt.event.InputEvent").BUTTON3_DOWN_MASK)
		elseif player.held_item():get_name() == "item.appleGold" then
			luajava.newInstance("java.awt.Robot"):mouseRelease(luajava.bindClass("java.awt.event.InputEvent").BUTTON3_DOWN_MASK)
		end
	end
	if Eating ~= 0 then
		Eating = Eating - 1
	end
	if Eating < 30 and Module then
		module_manager.set_state("Inventory Manager", Enable)
		module_manager.set_state("Chest Stealer", Enable)
		Module = false
	end
	if module_manager.get_state("Inventory Manager") then
		Enable = true
	end
	if not module_manager.get_state("Inventory Manager") and Eating == 0 then
		Enable = false
	end
	if player.using_item() then
		if player.held_item():get_name() == "item.appleGold" and Eating == 0 then
			Module = true
			module_manager.disable("Inventory Manager")
			module_manager.disable("Chest Stealer")
			Eating = 35
		end
	end
	if Drop then
		player.send0x07("DROP_ITEM", "DOWN", player.create_position(0,0,0))
		Drop = false
	end
	if Slow then
		if Jump:get_boolean() then
			client.print("Jumped!")
			player.set_sprinting(false)
			player.jump()
			Slow = false
			goto Jump
		end
		if not player.on_ground() and Mode:get_string() == "Slow Down" and not NoGroundCheck:get_boolean() then
			client.print("Detected Jumping/Falling!")
			Slow = false
			goto Jump
		end
		if Mode:get_string() == "Slow Down" then
			player.set_speed(0)
		end
		if Mode:get_string() == "Sprint Reset" then
			player.set_sprinting(false)
		end
		Tick = Tick + 1
		:: Jump ::
	end
	if Tick == ActiveTick:get_value() then
		player.set_sprinting(false)
		Slow = false
		Tick = 0
		if Mode:get_string() == "Freeze" then
			player.set_motion(table.unpack(Motion))
		end
		if Mode:get_string() == "Sprint Reset" then
			player.set_sprinting(true)
		end
	end
end

function on_player_move(event)
	if Mode:get_string() == "Freeze" and Slow then
		player.set_sprinting(false)
		event:set_x(0)
		event:set_y(0)
		event:set_z(0)
		return event
	else
		return event
	end
end

function on_receive_packet(idr)
	if idr == 0x08 and Eating ~= 0 and not NoS08Check:get_boolean() then
		if player.held_item():get_name() == "item.appleGold" then
			Eating = 0
			player.send0x07("RELEASE_USE_ITEM", "DOWN", player.create_position(0,0,0))
		end
		client.print("Canceled Eating (S08)")
	end
end

function on_render_screen()
	if Eating ~= 0 then
		render.string("¡ìeEating", luajava.bindClass("org.lwjgl.opengl.Display"):getWidth()/4-render.get_string_width("Eating")/2, luajava.bindClass("org.lwjgl.opengl.Display"):getHeight()/4-10, -1, true)
	end
end