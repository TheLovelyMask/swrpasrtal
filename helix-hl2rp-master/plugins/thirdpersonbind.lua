
PLUGIN.name = 'Third-person'
PLUGIN.description = 'Бинд 3 лица'
PLUGIN.author = 'Freezy'
PLUGIN.bind = KEY_F1

if (CLIENT) then
    local Cooldown
    function PLUGIN:PlayerButtonDown(me, button)
        if button == self.bind then
            if IsFirstTimePredicted() then
                if (Cooldown or 0) < CurTime() then
                    RunConsoleCommand("ix_togglethirdperson")
                    Cooldown = CurTime() + 0.1
                end
            end
        end
    end
end