ITEM.name = "Антидот"
ITEM.description = "Помогает вылечить отравление"
ITEM.model = Model("models/pg_props/pg_stargate/pg_shot.mdl")
ITEM.category = "Medical"

ITEM.functions.Use = {
    name = "Использовать",
    tip = "use",
	OnRun = function(itemTable)
        local client = itemTable.player
        local character = client:GetCharacter()

        if (character) then
            local toxicity = character:GetToxicity()
            if (toxicity > 85) then
                client:Notify("Это тебе не поможет")
                return false
            end

            if timer.Exists('GasAntidote.'..client:AccountID()) then
                ix.util.NotifyLocalized('notNow', client)
                return false
            end

            timer.Create('GasAntidote.'..client:AccountID(), 5, 5, function()
                if !IsValid(client) then return end
                if !character then return end
                character:SubtractToxicity(5)
                if toxicity <= 0 then timer.Remove('GasAntidote.'..client:AccountID()) end
            end)

            client:EmitSound("eler/schema/load01.ogg")
        else
            return false
        end

        return true
	end
}
