ITEM.name = "Наручники"
ITEM.description = "Наручники используются для связывания и обыска людей."
ITEM.price = 0
ITEM.weight = 0.2
ITEM.model = "models/items/crossbowrounds.mdl"
ITEM.functions.Use = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
		local target = util.TraceLine(data).Entity

		if (IsValid(target) and target:IsPlayer() and target:GetCharacter()
		and !target:GetNetVar("tying") and !target:IsRestricted()) then
			itemTable.bBeingUsed = true

			client:SetAction("@tying", 5)
			target:Freeze(true)

			client:DoStaredAction(target, function()
				target:SetRestricted(true)
				target:Freeze(false)
				target:SetWalkSpeed(45)		
				target:SetRunSpeed(45)
				target:SetNetVar("tying")
				target:NotifyLocalized("fTiedUp")

				itemTable:Remove()
			end, 5, function()
				client:SetAction()

				target:SetAction()
				target:SetNetVar("tying")

				itemTable.bBeingUsed = false
			end)

			target:SetNetVar("tying", true)
			target:SetAction("@fBeingTied", 5)
		else
			itemTable.player:NotifyLocalized("plyNotValid")
		end

		return false
	end,
	OnCanRun = function(itemTable)
		return !IsValid(itemTable.entity) or itemTable.bBeingUsed
	end
}

function ITEM:CanTransfer(inventory, newInventory)
	return !self.bBeingUsed
end