local hnMMenu = CreateHnMMenu()
hnMMenu:SetDataSource(GetDataSource())

RegisterNetEvent('ConfigurationUpdate')
AddEventHandler('ConfigurationUpdate', function (configuration)
    hnMMenu:SetConfiguration(configuration)
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)

        local configuration = hnMMenu:GetConfiguration()
        if configuration ~= nil then
            local playerPedId = PlayerPedId()
            local playerCoordinates = GetEntityCoords(playerPedId)

            if Vdist2(configuration.center, playerCoordinates) < 50 then
                ensureNetToPed(configuration.model)
                ensureNetToPed(configuration.target)

                fixNPC(configuration.model.ped)
                fixNPC(configuration.target.ped)

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

function fixNPC(ped)
    SetEntityProofs(ped, true, true, true, true, true, true, 1, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_COP_IDLES", 0, true)
    TaskHandsUp(ped, 1000, -1, -1, true)
end

function ensureNetToPed(ped)
    if ped.ped == nil or ped.ped == 0 then
        ped.ped = NetToEnt(ped.net)
    end
end