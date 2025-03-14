local configuration = {
    center= vector3(-1758.339, 440.9741, 127.3882),
    type= 'male',
    base= {
        heading= 89.579704284668,
        vector=  vector3(-1758.2, 442.1954, 127.3639)
    },
    model= {
        heading= 89.579704284668,
        vector=  vector3(-1758.228, 440.263, 127.3914)
    }
}

Citizen.CreateThread(function() 
    print('Thread: running')
    configuration.base.ped = NetworkGetNetworkIdFromEntity(generateDefaultFrozenModel(configuration.type, configuration.base.vector, configuration.base.heading))
    configuration.model.ped = NetworkGetNetworkIdFromEntity(generateDefaultFrozenModel(configuration.type, configuration.model.vector, configuration.model.heading))
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
AddEventHandler('PedComponentSet', function (pedType, data) 
  SetPedComponentVariation(target, componentId, drawableId, textureId, paletteId)
  print('Update ' .. target .. ' componentId=' .. data.componentId .. ' drawableId=' .. data.drawableId .. ' textureId=' .. data.textureId .. ' paletteId=' .. data.paletteId)
end)