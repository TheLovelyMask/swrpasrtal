
PLUGIN.name = 'Radio Bind'
PLUGIN.description = 'Radio'
PLUGIN.author = 'Freezy'
PLUGIN.bind = KEY_O

if (CLIENT) then
    local Cooldown
    function PLUGIN:PlayerButtonDown(me, button)
        if button == self.bind then
            if IsFirstTimePredicted() then
                if (Cooldown or 0) < CurTime() then
                    RunConsoleCommand("+menuradio")
                    Cooldown = CurTime() + 0.1
                end
            end
        end
    end
end
