ITEM.name = "Фонарик"
ITEM.model = Model("models/sw_battlefront/props/flashlight/flashlight.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Используется для освещения в темных местах."
ITEM.category = "Tools"
ITEM.weight = 0.5

ITEM:Hook("drop", function(item)
	item.player:Flashlight(false)
end)
