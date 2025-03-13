local MALE_COORDS = vector3(165.8609, -1045.6, 71.73901)
local FEMALE_COORDS = vector3(168.3367, -1046.453, 71.73901)

local male = nil
local female = nil

Citizen.CreateThread(
    function() 
        for _, playerId in ipairs(GetPlayers()) do
        end

        generateDefaultFrozenMale()
        generateDefaultFrozenFemale()

        RegisterNetEvent('ResetNPCsEvent')
        AddEventHandler('ResetNPCsEvent', function() 
          generateDefaultFrozenMale()
          generateDefaultFrozenFemale()
        end)
    end
)


function generateFrozenNPC(type, modelHash, x, y, z, heading)
  local npc = CreatePed(type, modelHash, x, y, z, heading, true, false)
  FreezeEntityPosition(npc)
  return npc
end

function generateDefaultFrozenMale()
  if male ~= nil then
    DeleteEntity(male)
  end

  male = generateFrozenNPC(4, GetHashKey('mp_m_freemode_01'), MALE_COORDS.x, MALE_COORDS.y, MALE_COORDS.z, 159.79515075684)
  return male
end

function generateDefaultFrozenFemale()
  if female ~= nil then
    DeleteEntity(female)
  end

  female = generateFrozenNPC(5, GetHashKey('mp_f_freemode_01'), FEMALE_COORDS.x, FEMALE_COORDS.y, FEMALE_COORDS.z, 154.37631225586)
  return female
end

AddEventHandler('playerJoining', function (source)
  print('player.join=' .. source)

  TriggerClientEvent('ConfigurationUpdate', source, { entities={
      { ped=NetworkGetNetworkIdFromEntity(female), type='female', pos=FEMALE_COORDS },
      { ped=NetworkGetNetworkIdFromEntity(male), type='male', pos=MALE_COORDS }
    }
   })
end)

RegisterNetEvent('PedComponentSet')
AddEventHandler('PedComponentSet', function (pedType, data) 
  local target = nil
  if pedType == 'female' then
    target = female
  elseif pedType == 'male' then
    target = male
  end

  SetPedComponentVariation(target, componentId, drawableId, textureId, paletteId)
  print('Update ' .. target .. ' componentId=' .. data.componentId .. ' drawableId=' .. data.drawableId .. ' textureId=' .. data.textureId .. ' paletteId=' .. data.paletteId)
end)