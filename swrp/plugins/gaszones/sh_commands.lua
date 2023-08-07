
local PLUGIN = PLUGIN

do
    ix.command.Add("CharSetToxicity", {
        description = "Установите значение токсичности для игрока",
        adminOnly = true,
        arguments = {
            ix.type.character,
            bit.bor(ix.type.number, ix.type.optional)
        },
        OnRun = function(self, client, target, value)
            if !value then value = 0 end
            target:SetToxicity(value)
            client:Notify(Format('Вы установили %s токсичность для %s', target:GetName(), value))
        end,
        bNoIndicator = true
    })
end