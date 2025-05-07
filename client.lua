local display = false
local menuOpen = false
local markerVisible = false

function openCityHallMenu()
    if not menuOpen then
        SetDisplay(true)
        menuOpen = true
    end
end

-- Function to toggle UI display
function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
        jobs = Config.Jobs
    })
end

-- Initialize display state
Citizen.CreateThread(function()
    SetDisplay(false)
end)

-- Handle NUI callbacks
RegisterNUICallback('exit', function(data, cb)
    SetDisplay(false)
    menuOpen = false
    cb('ok')
end)

RegisterNUICallback("jobSelected", function(data, cb)
    if data.job then
        TriggerServerEvent("setJob", data.job)
        SetDisplay(false)
        menuOpen = false
    end
    cb("ok")
end)

RegisterNUICallback("licenseSelected", function(data, cb)
    if data.license then
        TriggerServerEvent("giveLicense", data.license)
        SetDisplay(false)
        menuOpen = false
    end
    cb("ok")
end)

-- Helper function to show notifications
function ShowHelpNotification(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end


Citizen.CreateThread(function()
    local cityHallCoords = Config.Location
    
    local blip = AddBlipForCoord(cityHallCoords.x, cityHallCoords.y, cityHallCoords.z)
    
    -- Blip customization
    SetBlipSprite(blip, 439) -- Different sprite (439 is a government building)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 5) -- Yellow color
    SetBlipAsShortRange(blip, true)
    
    -- Blip name/label
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("City Hall")
    EndTextCommandSetBlipName(blip)
    
end)

Citizen.CreateThread(function()
    -- Load the ped model
    local pedModel = Config.TargetPeds[1].model
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Citizen.Wait(10)
    end

    -- Create the ped
    local clerkPed = CreatePed(
        4, -- pedType
        pedModel,
        Config.TargetPeds[1].coords.x,
        Config.TargetPeds[1].coords.y,
        Config.TargetPeds[1].coords.z - 1.0, -- Adjust Z slightly
        Config.TargetPeds[1].heading,
        false, -- isNetworked
        true -- thisScriptCheck
    )
    
    SetEntityInvincible(clerkPed, true)
    SetBlockingOfNonTemporaryEvents(clerkPed, true)
    TaskStartScenarioInPlace(clerkPed, Config.TargetPeds[1].scenario, 0, true)
    FreezeEntityPosition(clerkPed, true)

    -- QB-Target implementation
    if Config.Framework == 'qb-core' then
        exports['qb-target']:AddTargetEntity(clerkPed, {
            options = {
                {
                    type = "client",
                    event = "qb-cityhall:openMenu",
                    icon = Config.TargetPeds[1].icon,
                    label = Config.TargetPeds[1].label,
                }
            },
            distance = Config.TargetPeds[1].distance
        })
        
        -- Register the event that QB-Target will trigger
        RegisterNetEvent('qb-cityhall:openMenu', function()
            openCityHallMenu()
        end)
    end
    
    -- OX_Target implementation
    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:addLocalEntity(clerkPed, {
            {
                name = 'cityhall_clerk',
                label = Config.TargetPeds[1].label,
                icon = Config.TargetPeds[1].icon,
                distance = Config.TargetPeds[1].distance,
                onSelect = function()
                    openCityHallMenu()
                end
            }
        })
    end

    -- Fallback for servers without target systems
    if GetResourceState('qb-target') ~= 'started' and GetResourceState('ox_target') ~= 'started' then
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(0)
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - Config.Location)
                
                if distance < 2.0 then
                    ShowHelpNotification('Press ~INPUT_CONTEXT~ to speak with the clerk')
                    if IsControlJustPressed(0, 38) then -- 'E' key
                        openCityHallMenu()
                    end
                end
            end
        end)
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Remove QB-Target options
        if Config.Framework == 'qb-core' then
            exports['qb-target']:RemoveTargetEntity(clerkPed, 'Speak to Clerk')
        end
        
        -- Remove OX_Target options
        if GetResourceState('ox_target') == 'started' then
            exports.ox_target:removeLocalEntity(clerkPed)
        end
        
        -- Delete the ped
        if DoesEntityExist(clerkPed) then
            DeleteEntity(clerkPed)
        end
    end
end)