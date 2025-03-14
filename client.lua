print('---------------------------')
--local hnmMenu = CreateHnmMenu()
--hnmMenu:Init()

-- tp to NPCs
function tpToArea()
    local player = PlayerPedId()
    SetEntityCoords(player, -1760.57, 441.308, 127.3721, true, false, false , false)
    SetEntityHeading(player, 269.42758178711)
end
RegisterCommand('tp1', function () tpToArea() end)

RegisterNetEvent('ConfigurationUpdate')
AddEventHandler('ConfigurationUpdate', function (configuration)
    Citizen.CreateThread(function() 
        Citizen.Wait(1)

        local sortMenu = CreateSortMenu()
        sortMenu:Init()

        while true do
            Citizen.Wait(1)

            local playerPedId = PlayerPedId()
            local playerCoordinates = GetEntityCoords(playerPedId)

            if Vdist2(configuration.center, playerCoordinates) < 50 then
                if configuration.base.netPed == nil or configuration.base.netPed == 0 then
                    configuration.base.netPed = NetToEnt(configuration.base.ped)
                end
                if configuration.model.netPed == nil or configuration.model.netPed == 0 then
                    configuration.model.netPed = NetToEnt(configuration.model.ped)
                end

                TaskStandStill(configuration.base.netPed, 1000)
                TaskStandStill(configuration.model.netPed, 1000)

                if Vdist2(configuration.center, playerCoordinates) < 10 then
                    notifyAction('~INPUT_CONTEXT~ pour paramètrer')

                    if IsControlJustPressed(1, 38) then
                        sortMenu:SetConfiguration(configuration)
                        sortMenu:SetTarget(configuration.model.netPed)
                        sortMenu:Open()
                    end
                end
            end
        end
    end)
end)