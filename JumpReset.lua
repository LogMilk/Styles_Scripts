function getName()
    return "Jump Reset"
end

function on_tick()
    if player.hurt_time() == 10 and player.on_ground() then
        player.jump()
        client.print("Jump")
    end
end