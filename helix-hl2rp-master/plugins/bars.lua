PLUGIN.name = "Bars"
PLUGIN.author = "Olegle"
PLUGIN.descripton = "Adds a config to disable bars"

ix.option.Add("Отключить ХУД",ix.type.bool, true, {
  category = "ХУД"
})

function PLUGIN:ShouldHideBars(client)
  if ix.option.Get("Отключить ХУД", true) then
    return true
  end
end
