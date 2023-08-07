local PLUGIN = PLUGIN

PLUGIN.name = "Font Manager"
PLUGIN.author = "Freezy"
PLUGIN.description = "Font manager for outcome war."

ix.util.Include("sh_fonts.lua")


ix.config.Add("CharCreationDisabled", false, "Включено ли создание персонажей.", nil, {
	category = "Character Creation"
})