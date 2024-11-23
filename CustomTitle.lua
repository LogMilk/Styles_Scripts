function getName()
	return "Custom Title"
end

function on_pre_update()
	luajava.bindClass("org.lwjgl.opengl.Display"):setTitle("LiquidBounce b56.0 | 1.8.8 | DEVELOPMENT BUILD")
end