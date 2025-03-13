print('---------------------------')
local hnmMenu = CreateHnmMenu()

-- tp to NPCs
RegisterCommand('tp1', function () 
    local player = PlayerPedId()
    SetEntityCoords(player, 165.0185, -1050.483, 71.739, true, false, false , false)
    SetEntityHeading(player, 343.01705932617)
end)

-- Server send NPCs data on player join
RegisterNetEvent('ConfigurationUpdate')
AddEventHandler('ConfigurationUpdate', function(data)
    Citizen.CreateThread(
        function() 
            while true do
                Citizen.Wait(1)

                local playerPedId = PlayerPedId()
                local playerCoordinates = GetEntityCoords(playerPedId)

                -- For each NPC (female-male)
                for _, entity in ipairs(data.entities) do

                    -- Avoid warning spams
                    if Vdist2(entity.pos, playerCoordinates) < 10 then
                        if entity.netPed == nil then
                            entity.netPed = NetToEnt(entity.ped)
                        end
                        -- Force NPCs to stand still
                        TaskStandStill(entity.netPed, 10000)
                    end

                    -- Interact if close enough
                    if Vdist2(entity.pos, playerCoordinates) < 2.3 then
                        notifyAction('~INPUT_CONTEXT~ pour paramètrer')
                        
                        if IsControlJustPressed(1, 38) then 
                            hnmMenu:SetTarget(entity)
                            hnmMenu:Open()
                        end
                    end
                end
            end
        end
    )
end)