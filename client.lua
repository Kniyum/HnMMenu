print('')
print('##########################################################')
local year, month, day, hour, minute, second = GetLocalTime()
print('## ' .. day .. '-' .. month .. '-' .. year .. ' ' .. hour .. ':' .. minute .. ':' .. second .. ' #############################' )
function tpToArea()
    local player = PlayerPedId()
    SetEntityCoords(player, -1760.57, 441.308, 127.3721, true, false, false , false)
    SetEntityHeading(player, 269.42758178711)
end
RegisterCommand('tp1', function () tpToArea() end)


local hnMMenu = CreateHnMMenu()
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
        local configuration = hnMMenu:GetConfiguration()
        if configuration ~= nil then
            local playerPedId = PlayerPedId()
            local playerCoordinates = GetEntityCoords(playerPedId)

            if Vdist2(configuration.center, playerCoordinates) < 50 then
                -- Ensure entities have ped ID
                ensureNetToPed(configuration.model)
                ensureNetToPed(configuration.target)

                -- Force stand still ped
                TaskHandsUp(configuration.model.ped, 1000, -1, -1, true)
                TaskHandsUp(configuration.target.ped, 1000, -1, -1, true)

                if Vdist2(configuration.center, playerCoordinates) < 10 then
                    notifyAction('~INPUT_CONTEXT~ pour paramètrer')

                    if IsControlJustPressed(1, 38) then
                        hnMMenu:Open()
                    end
                end
            end
        end
    end
end)

function ensureNetToPed(ped)
    if ped.ped == nil or ped.ped == 0 then
        ped.ped = NetToEnt(ped.net)
    end
end

RegisterNetEvent('ConfigurationUpdate')
AddEventHandler('ConfigurationUpdate', function (configuration)
    hnMMenu:SetConfiguration(configuration)
end)