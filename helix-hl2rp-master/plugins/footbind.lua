
PLUGIN.name = 'Ход'
PLUGIN.description = 'Бинд на движение вперед'
PLUGIN.author = 'Freezy'
PLUGIN.bind = KEY_H

if (CLIENT) then
    local Cooldown
    function PLUGIN:PlayerButtonDown(me, button)
        if button == self.bind then
            if IsFirstTimePredicted() then
                if (Cooldown or 0) < CurTime() then
                    RunConsoleCommand("mightyfootengaged")
                    Cooldown = CurTime() + 0.1
                end
            end
        end
    end
end
