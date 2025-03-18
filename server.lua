local configuration = {
    center= vector3(-1758.339, 440.9741, 127.3882),
    type= 'male',
    model= {
        heading= 89.579704284668,
        vector=  vector3(-1758.2, 442.1954, 127.3639)
    },
    target= {
        heading= 89.579704284668,
        vector=  vector3(-1758.228, 440.263, 127.3914)
    }
}

Citizen.CreateThread(function()
    configuration.model.server = generateDefaultFrozenModel(configuration.type, configuration.model.vector, configuration.model.heading)
    configuration.model.net = NetworkGetNetworkIdFromEntity(configuration.model.server)

    configuration.target.server = generateDefaultFrozenModel(configuration.type, configuration.target.vector, configuration.target.heading)
    configuration.target.net = NetworkGetNetworkIdFromEntity(configuration.target.server)
end)

function generateDefaultFrozenModel(type, vector, heading)
  local pedType = nil
  local modelHash = nil

  if type == 'male' then
    pedType = 4
    modelHash = 'mp_m_freemode_01'
  elseif type =='female' then
    pedType = 5
    modelHash = 'mp_f_freemode_01'
  end

  local npc = CreatePed(pedType, GetHashKey(modelHash), vector.x, vector.y, vector.z,  heading, true, false)
  FreezeEntityPosition(npc)
  return npc
end

AddEventHandler('playerJoining', function (source)
  print('player.join=' .. source)
  TriggerClientEvent('ConfigurationUpdate', source, configuration)
end)

RegisterNetEvent('PedComponentSet')
AddEventHandler('PedComponentSet', function (target, data) 
  local target = NetworkGetEntityFromNetworkId(target)
  SetPedComponentVariation(target, tonumber(data.componentId), tonumber(data.drawableId), tonumber(data.textureId), tonumber(data.paletteId))
  print('Update ' .. target .. ' componentId=' .. data.componentId .. ' drawableId=' .. data.drawableId .. ' textureId=' .. data.textureId .. ' paletteId=' .. data.paletteId)
end)

RegisterNetEvent('SwitchModel')
AddEventHandler('SwitchModel', function ()
  if configuration.type == 'male' then
    configuration.type = 'female'
  else
    configuration.type = 'male'
  end

  DeleteEntity(configuration.model.server)
  DeleteEntity(configuration.target.server)

  configuration.model.server = generateDefaultFrozenModel(configuration.type, configuration.model.vector, configuration.model.heading)
  configuration.model.net = NetworkGetNetworkIdFromEntity(configuration.model.server)

  configuration.target.server = generateDefaultFrozenModel(configuration.type, configuration.target.vector, configuration.target.heading)
  configuration.target.net = NetworkGetNetworkIdFromEntity(configuration.target.server)

  TriggerClientEvent('ConfigurationUpdate', source, configuration)
end)

RegisterNetEvent('SaveFileContentLocaly')
AddEventHandler('SaveFileContentLocaly', function (filename, data)
  SaveJSONFileFromData(filename, data)
end)