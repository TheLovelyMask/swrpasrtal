PLUGIN.name = "Miscellaneous"
PLUGIN.author = "ZeMysticalTaco"
PLUGIN.description = "Cool things such as auto-grenade callouts."
PLUGIN.SaveEnts = PLUGIN.SaveEnts or {}
--skinny bars are disgusting
BAR_HEIGHT = 12


--[[-------------------------------------------------------------------------
MPF Models
---------------------------------------------------------------------------]]

for i = 1, 9 do
	ix.anim.SetModelClass("models/police/c18_police_male_0"..i..".mdl", "metrocop")
end

for i = 1, 4 do
	ix.anim.SetModelClass("models/police/c18_police_female_0"..i..".mdl", "metrocop")
end

for i = 6, 9 do
	ix.anim.SetModelClass("models/police/c18_police_female_0"..i..".mdl", "metrocop")
end

ix.anim.SetModelClass("models/police/c18_police.mdl", "metrocop")
ix.anim.SetModelClass("models/police/c18_police_female.mdl", "metrocop")

--[[-------------------------------------------------------------------------
Auto Grenade Callout
---------------------------------------------------------------------------]]
function PLUGIN:PlayerTick(ply)
	for k, v in pairs(ents.FindByClass("npc_grenade_frag")) do
		if v:GetPos():Distance(ply:GetPos()) < 150 then
			if not ply.NextGrenadeTick or ply.NextGrenadeTick <= CurTime() then
				ix.chat.Send(ply, "ic", "Grenade!")
				ply:EmitSound("npc/metropolice/vo/grenade.wav")
				ply.NextGrenadeTick = CurTime() + 5

				return
			end
		end
	end
end

--[[-------------------------------------------------------------------------
Saving misc. ents.
---------------------------------------------------------------------------]]

local save_ents = {"ix_loyaltykiosk", "ix_applicationterminal", "ix_cidterminal"}

function PLUGIN:SaveData()
	for k, v in pairs(save_ents) do
		for k2, v2 in pairs(ents.FindByClass(v)) do
			local tbl = {}

			tbl[#tbl + 1] = {
				v2:GetPos(),
				v2:GetAngles(),
				v2:GetNetVar("destroyed", false),
			}

			ix.data.Set(v, tbl)
		end
	end
end

function PLUGIN:InitPostEntity()
	for k, v in ipairs(save_ents) do
		for _, v2 in ipairs(ix.data.Get(v) or {}) do
			local ent = ents.Create(v)
			ent:SetPos(v2[1])
			ent:SetAngles(v2[2])
			ent:Spawn()
			ent:SetNetVar("destroyed", v2[3])
		end
	end
end
--[[-------------------------------------------------------------------------
	Restrict business
---------------------------------------------------------------------------]]
function PLUGIN:CanPlayerUseBusiness()
	return false
end
--[[-------------------------------------------------------------------------
	move settings to tab
---------------------------------------------------------------------------]]
if CLIENT then
	hook.Add("CreateMenuButtons", "ixSettings", function(tabs)
	tabs["settings"] = {
		Create = function(info, container)
			container:SetTitle(L("settings"))

			local panel = container:Add("ixSettings")
			panel:SetSearchEnabled(true)

			for category, options in SortedPairs(ix.option.GetAllByCategories(true)) do
				category = L(category)
				panel:AddCategory(category)

				-- sort options by language phrase rather than the key
				table.sort(options, function(a, b)
					return L(a.phrase) < L(b.phrase)
				end)

				for _, data in pairs(options) do
					local key = data.key
					local row = panel:AddRow(data.type, category)
					local value = ix.util.SanitizeType(data.type, ix.option.Get(key))

					row:SetText(L(data.phrase))
					row:Populate(key, data)

					-- type-specific properties
					if (data.type == ix.type.number) then
						row:SetMin(data.min or 0)
						row:SetMax(data.max or 10)
						row:SetDecimals(data.decimals or 0)
					end

					row:SetValue(value, true)
					row:SetShowReset(value != data.default, key, data.default)
					row.OnValueChanged = function()
						local newValue = row:GetValue()

						row:SetShowReset(newValue != data.default, key, data.default)
						ix.option.Set(key, newValue)
					end

					row.OnResetClicked = function()
						row:SetShowReset(false)
						row:SetValue(data.default, true)

						ix.option.Set(key, data.default)
					end

					row:GetLabel():SetHelixTooltip(function(tooltip)
						local title = tooltip:AddRow("name")
						title:SetImportant()
						title:SetText(key)
						title:SizeToContents()
						title:SetMaxWidth(math.max(title:GetMaxWidth(), ScrW() * 0.5))

						local description = tooltip:AddRow("description")
						description:SetText(L(data.description))
						description:SizeToContents()
					end)
				end
			end

			panel:SizeToContents()
			container.panel = panel
		end,

		OnSelected = function(info, container)
			container.panel.searchEntry:RequestFocus()
		end
	}
end)

hook.Add("PopulateScoreboardPlayerMenu", "ixAdmin", function(client, menu)
	--[[-------------------------------------------------------------------------
	WAY too lazy to convert this
	---------------------------------------------------------------------------]]
	local options = {}
	options["Изменить Имя"] = {
		function()
			if LocalPlayer():IsAdmin() == false then ix.util.Notify("Эта функция доступна только для администраторов.") return end
			if (IsValid(client) and LocalPlayer():IsAdmin()) then
				Derma_StringRequest("Изменить имя", "На что вы хотите изменить имя этого персонажа?", client:Name(), function(text)
					ix.command.Send("CharSetName", client:Name(), text)
				end, nil, "Change", "Cancel")
			end
		end
	}

	options["Изменить ХП"] = {
		
		function()
			if LocalPlayer():IsAdmin() == false then ix.util.Notify("Эта функция доступна только для администраторов.") return end
			if (IsValid(client) and LocalPlayer():IsAdmin()) then
				Derma_StringRequest("Изменить здоровье", "На что вы хотите изменить их здоровье?", client:Health(), function(text)
					ix.command.Send("PlySetHP", client:Name(), text, "true") --Need to put ix.type.bools in quotes????
				end, nil, "Set", "Cancel")
			end
		end
	}

	options["Изменить броню"] = {
		
		function()
			if LocalPlayer():IsAdmin() == false then ix.util.Notify("Эта функция доступна только для администраторов.") return end
			if (IsValid(client) and LocalPlayer():IsAdmin()) then
				Derma_StringRequest("Изменить броню", "На что вы хотите сменить их броню?", client:Armor(), function(text)
					ix.command.Send("PlySetArmor", client:Name(), text, "true")
				end, nil, "Set", "Cancel")
			end
		end
	}

	options["Кикнуть игрока"] = {
		
		function()
			if LocalPlayer():IsAdmin() == false then ix.util.Notify("Эта функция доступна только для администраторов.") return end
			if (IsValid(client) and LocalPlayer():IsAdmin()) then
				Derma_StringRequest("Кикнуть", "Причина кика?", "", function(text)
					ix.command.Send("PlyKick", client:Name(), text)
				end, nil, "Kick", "Cancel")
			end
		end
	}

	options["Забанить игрока"] = {
		function()
			if LocalPlayer():IsAdmin() == false then ix.util.Notify("Эта функция доступна только для администраторов.") return end
			if (IsValid(client) and LocalPlayer():IsAdmin()) then
				Derma_StringRequest("Забанить", "Причина бана?", "", function(text)
					--ix.command.Send("PlyBan", client:Name(), text)
					Derma_StringRequest("Ban Length","Как долго вы хотите их запретить? 0 является постоянным.","",function(text2) ix.command.Send("PlyBan", client:Name(), text2, text) end, nil)
				end, nil, "Ban", "Cancel")
			end
		end
	}

		options["Изменить модель"] = {
		function()
				Derma_StringRequest("Изменить модель", "На что вы хотите изменить модель этого персонажа?", client:GetModel(), function(text)
					ix.command.Send("CharSetModel", client:Name(), text)
				end, nil, "Change", "Cancel")
		end
	}
	options["Перевод фракций"] = {
		function()
			if LocalPlayer():IsAdmin() == false then ix.util.Notify("Эта функция доступна только для администраторов.") return end
			local menu = vgui.Create("DFrame")
			menu:SetSize(ScrW() / 6, ScrH() / 3)
			menu.Paint = function(me,w,h)
				surface.SetDrawColor(47,54,64)
				surface.DrawRect(0,0,w,h)
			end
			menu:MakePopup()
			menu:Center()
			menu:SetTitle("Меню выдачи фракций")
			local panel = menu:Add("DScrollPanel")
			panel:Dock(FILL)
			local header = panel:Add("DLabel")
			header:Dock(TOP)
			header:SetText("Используйте это поле для поиска.")
			header:SetTextInset(3, 0)
			header:SetFont("ixMediumFont")
			header:SetTextColor(color_white)
			header:SetExpensiveShadow(1, color_black)
			header:SetTall(25)

			header.Paint = function(this, w, h)
				surface.SetDrawColor(ix.config.Get("color"))
				surface.DrawRect(0, 0, w, h)
			end
			local entry = menu:Add("DTextEntry")
			entry:Dock(TOP)
			local factionTable = ix.faction.Get(client:Team())
        	local rankTable = factionTable.Ranks
			for k, v in SortedPairs(ix.faction.indices) do
				local button = vgui.Create("DButton", panel)
				button:Dock(TOP)
				button:SetSize(20,30)
				button:SetText(L(v.name))
				button.Paint = function(me,w,h)
					surface.SetDrawColor(53,59,72) 
					surface.DrawRect(0, 0, w, h)
				end
				function button:DoClick()
					ix.command.Send("PlyWhitelist", client:Name(), v.name)
					net.Start("vidatb")
						net.WriteString(k)
						net.WriteEntity(client)
					net.SendToServer()
				end
				function button:Think()
					if string.len(entry:GetText()) < 1 then self:Show() return end
					if not string.find(v.name, entry:GetText()) then
						panel:SetVerticalScrollbarEnabled(true)
						panel:ScrollToChild(self)
					else
						panel:SetVerticalScrollbarEnabled(true)
						--panel:ScrollToChild()
					end
				end
			end
		end
	}


	options["Выдача ранга"] = {
		function()
			if LocalPlayer():IsAdmin() == false then ix.util.Notify("Эта функция доступна только для администраторов.") return end
			local menu = vgui.Create("DFrame")
			menu:SetSize(ScrW() / 6, ScrH() / 3)
			menu.Paint = function(me,w,h)
				surface.SetDrawColor(47,54,64)
				surface.DrawRect(0,0,w,h)
			end
			menu:MakePopup()
			menu:Center()
			menu:SetTitle("Меню выдачи ранга")
			local panel = menu:Add("DScrollPanel")
			panel:Dock(FILL)
			local header = panel:Add("DLabel")
			header:Dock(TOP)
			header:SetText("Используйте это поле для поиска элемента.")
			header:SetTextInset(3, 0)
			header:SetFont("ixMediumFont")
			header:SetTextColor(color_white)
			header:SetExpensiveShadow(1, color_black)
			header:SetTall(25)

			header.Paint = function(this, w, h)
				surface.SetDrawColor(ix.config.Get("color"))
				surface.DrawRect(0, 0, w, h)
			end
			local entry = menu:Add("DTextEntry")
			entry:Dock(TOP)
			local factionTable = ix.faction.Get(client:Team())
        	local rankTable = factionTable.Ranks
			for k, v in SortedPairs(rankTable) do
				local button = vgui.Create("DButton", panel)
				button:Dock(TOP)
				button:SetSize(20,30)
				button:SetText(L(v[1]))
				button.Paint = function(me,w,h)
					surface.SetDrawColor(53,59,72) 
					surface.DrawRect(0, 0, w, h)
				end
				function button:DoClick()
					ix.command.Send("CharSetRank", client:Name(), k)
				end
				function button:Think()
					if string.len(entry:GetText()) < 1 then self:Show() return end
					if not string.find(v.name, entry:GetText()) then
						panel:SetVerticalScrollbarEnabled(true)
						panel:ScrollToChild(self)
					else
						panel:SetVerticalScrollbarEnabled(true)
						--panel:ScrollToChild()
					end
				end
			end
		end
	}

		options["Выдать предмет"] = {
		function()
			if LocalPlayer():IsAdmin() == false then ix.util.Notify("Эта функция доступна только для администраторов.") return end
			local menu = vgui.Create("DFrame")
			menu:SetSize(ScrW() / 6, ScrH() / 3)
			menu:MakePopup()
			menu:Center()
			menu:SetTitle("Меню выдачи предметов")
			local panel = menu:Add("DScrollPanel")
			panel:Dock(FILL)
			local header = panel:Add("DLabel")
			header:Dock(TOP)
			header:SetText("Используйте это поле для поиска элемента.")
			header:SetTextInset(3, 0)
			header:SetFont("ixMediumFont")
			header:SetTextColor(color_white)
			header:SetExpensiveShadow(1, color_black)
			header:SetTall(25)

			header.Paint = function(this, w, h)
				surface.SetDrawColor(ix.config.Get("color"))
				surface.DrawRect(0, 0, w, h)
			end
			local entry = menu:Add("DTextEntry")
			entry:Dock(TOP)
			for k, v in SortedPairs(ix.item.list) do
				local button = vgui.Create("DButton", panel)
				button:Dock(TOP)
				button:SetSize(20,30)
				button:SetText(L(v.name))
				function button:DoClick()
					ix.command.Send("CharGiveItem", client:Name(), v.uniqueID, 1)
				end
				function button.Paint()
					surface.SetDrawColor(Color(200,200,200,255))
				end
				function button:Think()
					if string.len(entry:GetText()) < 1 then self:Show() return end
					if not string.find(v.name, entry:GetText()) then
						panel:SetVerticalScrollbarEnabled(true)
						panel:ScrollToChild(self)
					else
						panel:SetVerticalScrollbarEnabled(true)
						--panel:ScrollToChild()
					end
				end
			end
		end
	}
	for k, v in pairs(options) do
		menu:AddOption(k,v[1])
	end
end)

end


--[[-------------------------------------------------------------------------
NAME: ADMIN CHAT
CREATOR: TACO
DESC: ADMIN CHAT
---------------------------------------------------------------------------]]
if ( SERVER ) then
	util.AddNetworkString("vidatb")
	net.Receive("vidatb", function(len,ply)
		local faction = net.ReadString()
		local entity = net.ReadEntity()
		local char = entity:GetCharacter()
		char:SetFaction(faction)
	end)
end
ix.chat.Register("adminchat", {
	format = "whocares",
	--font = "nutRadioFont",
	OnGetColor = function(self, speaker, text)
		return Color(0, 196, 255)
	end,
	OnCanHear = function(self, speaker, listener)
		if listener:IsAdmin() then
			return true
		end

		return false
	end,
	OnCanSay = function(self, speaker, text)

		if not speaker:IsAdmin() then
			speaker:Notify("Ты не администратор.")
		end

		--speaker.NextAR = ix.config.Get("arequestinterval")

		return true
	end,
	OnChatAdd = function(self, speaker, text)
		local color = team.GetColor(speaker:Team())
		chat.AddText(Color(100, 255, 100), "[Админ] ", color, speaker:Name() .. " (" .. speaker:SteamName() .. ")", ": ", Color(255, 255, 255), text)
	end,
	prefix = "/a"
})

function PLUGIN:PlayerSay(client, text)
	local chatType, message, anonymous = ix.chat.Parse(client, text, true)

	if (chatType == "ic") then
		if (string.sub(text, 1, 1) == "@") then
			message = string.gsub(message, "@", "", 1)
			print(message)

			if not client:IsAdmin() then
				return
			end

			serverguard.command.Run(client, "a", false, message)

			return false
		end
	end
end

ix.chat.Register("adminrequest", {
	format = "whocares",
	--font = "nutRadioFont",
	OnGetColor = function(self, speaker, text)
		return Color(0, 196, 255)
	end,
	OnCanHear = function(self, speaker, listener)
		if listener:IsAdmin() or listener == speaker then
			return true
		end

		return false
	end,
	OnChatAdd = function(self, speaker, text)
		local schar = speaker:GetChar()
		local color = team.GetColor(speaker:Team())
		local whitelist = {"STEAM_1:0:17704583", "STEAM_0:1:34297953", "STEAM_1:1:53007042"}
		if LocalPlayer():IsAdmin() or speaker == LocalPlayer() then
			chat.AddText(Color(225, 50, 50, 255), "[РЕПОРТ] ", Color(190, 90, 90), speaker:Name(), color, " (", speaker:SteamName(), "): ", Color(255, 255, 255, 255), text)
		end
		if CLIENT then
			for k, v in pairs(player.GetAll()) do
				if table.HasValue(whitelist, v:SteamID()) then
					--print("you will not receive an alert")
					--print("you will receive an alert")
					return
				else
					if not LocalPlayer().nextbellproc or LocalPlayer().nextbellproc <= CurTime() then
						surface.PlaySound("hl1/fvox/bell.wav")
						LocalPlayer().nextbellproc = CurTime() + 5
					end
				end
			end
		end
	end
})
ix.command.Add("ar", {
	syntax = "<string message>",
	description = "Send a message to the admins.",
	OnRun = function(self, client, arguments)
		local text = table.concat(arguments, " ")
		local admintable = {}

		if client:IsAdmin() then
			client:Notify("Ты администратор, используй вместо этого чат администратора... идиот.")

			return
		end

		--[[if client.NextAR and client.NextAR > CurTime() then
			client:Notify("You cannot use admin request yet!")

			return false
		end--]]

		--client.NextAR = ix.config.Get("arequestinterval")
		ix.chat.Send(client, "adminrequest", text)

		for k, v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				table.insert(admintable, v:Name())
			end
		end

		ix.log.AddRaw(client:Name() .. " запросил администратора: " .. text .. " Админы Онлайн: " .. table.concat(admintable, ", "))

		return true
	end
})
