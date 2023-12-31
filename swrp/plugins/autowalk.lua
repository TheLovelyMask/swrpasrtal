
PLUGIN.name = "Auto Walk"
PLUGIN.author = "NightAngel (Ported from Flux)"
PLUGIN.description = "Allows users to press a button to automatically walk forward."
--
if (SERVER) then
    PLUGIN.check = {
        [IN_FORWARD]    = true,
        [IN_BACK]       = true,
        [IN_MOVELEFT]   = true,
        [IN_MOVERIGHT]  = true,
        [IN_JUMP]       = true
    }

    function PLUGIN:SetupMove(client, move_data, cmd_data)
        if !client:GetNetVar('auto_walk', false) then return end
        move_data:SetForwardSpeed(move_data:GetMaxSpeed())

        for k in pairs(self.check) do
            if cmd_data:KeyDown(k) then
                client:SetNetVar('auto_walk', false)
                break
            end
        end
    end

    concommand.Add('ix_toggleautowalk', function(client)
        if hook.Run('CanPlayerAutoWalk', client) != false then
            client:SetNetVar('auto_walk', !client:GetNetVar('auto_walk', false))
        end
    end)

    function PLUGIN:CanPlayerAutoWalk(client)
        return true
    end
else
    function PLUGIN:SetupMove(client, move_data, cmd_data)
        if !client:GetNetVar('auto_walk', false) then return end
        move_data:SetForwardSpeed(move_data:GetMaxSpeed())
    end


     function PLUGIN:PlayerButtonDown(client, button)
        if (button == KEY_F1) then
            if (client.ixNextAWToggle or 0) > CurTime() then return end
            RunConsoleCommand("ix_togglethirdperson")
            client.ixNextAWToggle = CurTime() + 0.5
        end
    end

    function PLUGIN:PlayerButtonDown(client, button)
        if (button == KEY_M) then
            if (client.ixNextAWToggle or 0) > CurTime() then return end
            RunConsoleCommand("ix_toggleautowalk")
            client.ixNextAWToggle = CurTime() + 0.5
        end
    end
end