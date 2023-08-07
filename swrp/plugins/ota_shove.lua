PLUGIN.name = "Adds shove for OTA"
PLUGIN.author = "Yo Mama"
PLUGIN.description = "OTA /shove command."


ix.config.Add("shoveTime", 30, "Как долго персонаж должен находиться без сознания после того, как его нокаутировали?", nil, {
	data = {min = 5, max = 60},
	category = "Сервер"
})


ix.command.Add("knock", {
    description = "Вырубить кого-нибудь.",
    OnRun = function(self, client)
         if client:GetActiveWeapon():GetClass() == "ix_hands" then
             return "Ты не можешь это сделать!"
         end

         local tEntity = client:GetEyeTraceNoCursor().Entity
         local target
 
         if tEntity:IsPlayer() then 
             target = tEntity
         else
             return "Вы должны смотреть на игрока!"     
         end

         if target && target:GetPos():Distance(client:GetPos()) >= 50 then
             return "Ты недостаточно близок!"
         end 

             client:ForceSequence("melee_gunhit")
         timer.Simple(0.4, function()
             client:EmitSound("everfall/characters/clone_trooper/hit_grunts/mp_core_republic_inworld_heavyassault_soldierhit_09.mp3")
             target:SetRagdolled(true, ix.config.Get("shoveTime", 10))
         end)
    end
})