function getName()
    return "Window No Slow"
end

Using = 0
Repeat = false
S2D = false

function init_script()
	Command = module_manager.register_text("Window No Slow", "Command", "/ac")
    AllItem = module_manager.register_boolean("Window No Slow", "All usable item", false)
end

function on_pre_update()
    if player.using_item() and (AllItem:get_boolean() or player.held_item():get_name() == "item.appleGold") and Using == 0 then
        Using = 35
        client.print("Send Command")
        player.send_message(Command:get_string())
    end
end

function on_receive_packet(id)
    if id == 0x2D and Using ~= 0 then
        client.print("Cancel S2D")
        S2D = true
        luajava.newInstance("java.awt.Robot"):mouseRelease(luajava.bindClass("java.awt.event.InputEvent").BUTTON3_DOWN_MASK)
        return true
    end
end

function on_send_packet(id)
    if id == 0x07 and Using ~= 0 and S2D then
        if not Repeat then
            client.print("Cancel C07")
            return true
        else
            Repeat = false
            Using = 1
            client.print("Cancel eating")
        end
    end
    if id == 0x08 and Using ~= 0 and S2D then
        client.print("Do not eat repeatedly, Cancel C08")
        Repeat = true
    end
    -- if id == 0x09 and Using ~= 0 then
    --     client.print("Cancel eating")
    --     Using = 1
    -- end
end

function on_tick()
    if Using == 1 and S2D then
        client.print("Close Window")
        --change "VK_E" if ur inventory key is not "E"
        --idk how to send CPacketCloseWindow so close inventory instead
        luajava.newInstance("java.awt.Robot"):keyPress(luajava.bindClass("java.awt.event.KeyEvent").VK_E)
        luajava.newInstance("java.awt.Robot"):keyRelease(luajava.bindClass("java.awt.event.KeyEvent").VK_E)
        luajava.newInstance("java.awt.Robot"):keyPress(luajava.bindClass("java.awt.event.KeyEvent").VK_ESCAPE)
        luajava.newInstance("java.awt.Robot"):keyRelease(luajava.bindClass("java.awt.event.KeyEvent").VK_ESCAPE)
        Repeat = false
        S2D = false
    end
    if Using > 0 then
        Using = Using - 1
    end
end