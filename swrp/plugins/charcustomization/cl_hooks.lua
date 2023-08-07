local PLUGIN = PLUGIN

hook.Add("CreateMenuButtons", "ixCharacterCustomizer", function(tabs)
	tabs["Кастомизация"] = function(container)
		container:Add("ixCharacterCustomizer")
	end
end)