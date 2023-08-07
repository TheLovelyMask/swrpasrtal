local PLUGIN = PLUGIN

PLUGIN.name = "Tying"
PLUGIN.author = "Shavargo"
PLUGIN.description = "Ported from HL2RP; Adds the ability to tie players."

ix.lang.AddTable("russian", {
	tying = "Связываем...",
	unTying = "Развязываем...",
	isTied = "Связан",
	fTiedUp = "Вы были связаны.",
	fBeingTied = "Тебя связывают.",
	tiedUp = "Связан.",
	beingTied = "Его связывают.",
	beingUntied = "Тебя развязывают."
})

if (SERVER) then
	function PLUGIN:PlayerLoadout(client)
		client:SetNetVar("restricted")
	end

	function PLUGIN:CanPlayerJoinClass(client, class, info)
		if (client:IsRestricted()) then
			client:Notify("Вы не можете менять классы, когда вы ограничены!")
			return false
		end
	end

	function PLUGIN:SearchPlayer(client, target)
		if (!target:GetCharacter() or !target:GetCharacter():GetInventory()) then
			return false
		end

		local name = hook.Run("GetDisplayedName", target) or target:Name()
		local inventory = target:GetCharacter():GetInventory()

		ix.storage.Open(client, inventory, {
			entity = target,
			name = name
		})

		return true
	end
end

if (CLIENT) then
	function PLUGIN:PopulateCharacterInfo(client, character, tooltip)
		if (client:IsRestricted()) then
			local panel = tooltip:AddRowAfter("name", "ziptie")
			panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
			panel:SetText(L("tiedUp"))
			panel:SizeToContents()
		elseif (client:GetNetVar("tying")) then
			local panel = tooltip:AddRowAfter("name", "ziptie")
			panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
			panel:SetText(L("beingTied"))
			panel:SizeToContents()
		elseif (client:GetNetVar("untying")) then
			local panel = tooltip:AddRowAfter("name", "ziptie")
			panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
			panel:SetText(L("beingUntied"))
			panel:SizeToContents()
		end
	end
end

do
	local COMMAND = {}

	function COMMAND:OnRun(client, arguments)
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
		local target = util.TraceLine(data).Entity

		if (IsValid(target) and target:IsPlayer() and target:IsRestricted()) or (IsValid(target) and target:GetRagdollOwner():IsPlayer() and !target:GetRagdollOwner():Alive()) then
			if (!client:IsRestricted()) then
				PLUGIN:SearchPlayer(client, target)
			elseif (!target:GetRagdollOwner():Alive()) then
				PLUGIN:SearchPlayer(client,target:GetRagdollOwner())
			else
				return "@notNow"
			end
		end
	end

	ix.command.Add("CharSearch", COMMAND)

	local COMMAND2 = {}

	function COMMAND2:OnRun(client, arguments)
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
		local target = util.TraceLine(data).Entity
		local stamina = target:GetCharacter():GetAttribute("stm")
		if (!client:IsRestricted() and target:IsPlayer() and target:IsRestricted() and !target:GetNetVar("untying")) then
			target:SetAction("@beingUntied", 5)
			target:SetNetVar("untying", true)

			target:Freeze(true)
			client:SetAction("@unTying", 5)

			client:DoStaredAction(target, function()
				target:SetRestricted(false)
				target:Freeze(false)
				target:SetWalkSpeed(ix.config.Get("walkSpeed") + stamina)		
				target:SetRunSpeed(ix.config.Get("runSpeed") + stamina)
				target:SetNetVar("untying")
			end, 5, function()
				if (IsValid(target)) then
					target:SetNetVar("untying")
					target:SetAction()
				end

				if (IsValid(client)) then
					client:SetAction()
				end
			end)
		end
	end
	ix.command.Add("CharUnTy", COMMAND2)
end