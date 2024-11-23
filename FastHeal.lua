function getName()
    return "Fast Heal"
end

function init_script()
    Amount = module_manager.register_number("Fast Heal", "Amount", 5, 1, 20, 1)
    Health = module_manager.register_number("Fast Heal", "Health", 16, 1, 20, 1)
    OnlyGround = module_manager.register_boolean("Fast Heal", "Only Ground", false)
    OnlyPotion = module_manager.register_boolean("Fast Heal", "Only Potion", true)
end

function on_tick()
    if (not OnlyPotion:get_boolean() or player.is_potion_active(10)) and player.health() < Health:get_int() then
        for i=1,Amount:get_int() do
            if not OnlyGround:get_boolean() or player.on_ground() then
                player.send0x03(player.on_ground())
            end
        end
    end
end