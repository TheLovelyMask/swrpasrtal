local PLUGIN = PLUGIN

PLUGIN.name = "FIX FONTS"
PLUGIN.author = "Oren Riff"
PLUGIN.description = "Я ебал, ну фикс фонтов тип и еще чо нить может сюда буду сувать епт"

ix.util.Include("cl_plugin.lua")


-- Офф войс бокса епта --
if CLIENT then
    function PLUGIN:PlayerStartVoice()
        if IsValid(g_VoicePanelList) then
            g_VoicePanelList:Remove()
        end
    end
end

--ОФФ КВАДРАТА С ПАТРОНАМИ--

function PLUGIN:CanDrawAmmoHUD( weapon )
    return false
end

-------------------------------------------------------
--РАГДОЛ ОЧИСТКА ДВА ДВА ВОСЕМЬ------------------------
-------------------------------------------------------

ix.config.Add("ragdoll_remove_time", 60, "Как долго они будут лежать перед удалением????", nil, {
   data = {min = 0, max = 120},
   category = PLUGIN.name
})

ix.config.Add("ragdoll_remove_enabled", false, "Вкл выкл кнопка!", nil, {
   category = PLUGIN.name
})

if ( SERVER ) then
   function PLUGIN:Tick()
      if ( ix.config.Get("ragdoll_remove_enabled") ) then
         if not ( timer.Exists("ragdollremovetimer") ) then
            timer.Create("ragdollremovetimer", ix.config.Get("ragdoll_remove_time", 60), 0, function()
               for k, v in pairs(ents.FindByClass("prop_ragdoll")) do
                  SafeRemoveEntity(v)
               end
            end)
         end
      else
         if ( timer.Exists("ragdollremovetimer") ) then
            timer.Remove("ragdollremovetimer")
         end
      end
   end
end
