local FrameworkObject = nil

-- Initialize framework object based on config
function GetFrameworkObject()
    if Config.Framework == "esx" or Config.Framework == "legacy" then
        FrameworkObject = exports["es_extended"]:getSharedObject()
    elseif Config.Framework == "newqb" then
        FrameworkObject = exports["qb-core"]:GetCoreObject()
    elseif Config.Framework == "oldqb" then
        while FrameworkObject == nil do
            TriggerEvent('QBCore:GetObject', function(obj) FrameworkObject = obj end)
            Citizen.Wait(200)
        end
    end
end

GetFrameworkObject()

RegisterServerEvent('giveLicense')
AddEventHandler('giveLicense', function(itemType)
    local _source = source
    local formattedItemType = string.lower(itemType)
    local cost = 250 -- Cost of the ID card
    
    -- Validate item exists in config
    local itemExists = false
    local itemData = nil
    for _, item in ipairs(Config.License) do
        if item.type == formattedItemType then
            itemExists = true
            itemData = item
            break
        end
    end
    
    if not itemExists then
        print("Invalid item type requested: " .. formattedItemType)
        TriggerClientEvent('showNotification', _source, 'Invalid item type requested')
        return
    end

    -- Rest of your existing code...
    -- Process based on framework
    if Config.Framework == 'esx' or Config.Framework == 'legacy' then
        local xPlayer = FrameworkObject.GetPlayerFromId(_source)
        if not xPlayer then
            print('Failed to retrieve player for source: ' .. _source)
            return
        end
        
        -- Check if player has enough money
        if xPlayer.getMoney() >= cost then
            -- Deduct money
            xPlayer.removeMoney(cost)
            
            -- Add item with metadata
            xPlayer.addInventoryItem(itemData.itemName, 1, {
                itemType = formattedItemType,
                owner = xPlayer.getName(),
                date = os.date("%Y-%m-%d"),
                -- Add any additional item-specific metadata from your config
                -- For example:
                -- description = itemData.description,
                -- image = itemData.image
            })
            
            TriggerClientEvent('esx:showNotification', _source, 'You purchased a ' .. itemData.label .. ' for $' .. cost)
        else
            TriggerClientEvent('esx:showNotification', _source, 'You don\'t have enough cash ($' .. cost .. ' required)')
        end
        
    elseif Config.Framework == 'newqb' or Config.Framework == 'oldqb' then
        local Player = FrameworkObject.Functions.GetPlayer(_source)
        if not Player then
            print('Failed to retrieve player for source: ' .. _source)
            return
        end
        
        -- Check if player has enough money
        -- if Player.PlayerData.money.cash >= cost then
            -- Deduct money
        if Player.Functions.RemoveMoney('cash', cost) then
            
            -- Add item with metadata
            exports['qbx_idcard']:CreateMetaLicense(_source, itemData.itemName)
            
            TriggerClientEvent('QBCore:Notify', _source, 'You purchased a ' .. itemData.label .. ' for $' .. cost, 'success')
        else
            TriggerClientEvent('QBCore:Notify', _source, 'You don\'t have enough cash ($' .. cost .. ' required)', 'error')
        end
    end
end)

-- Handle job change requests
RegisterServerEvent('setJob')
AddEventHandler('setJob', function(jobName)
    local _source = source
    local formattedJobName = string.lower(jobName)
    
    -- Validate job exists in config
    local jobExists = false
    for _, job in ipairs(Config.Jobs) do
        if job.name == formattedJobName then
            jobExists = true
            break
        end
    end
    
    if not jobExists then
        print("Invalid job requested: " .. formattedJobName)
        return
    end

    -- Set job based on framework
    if Config.Framework == 'esx' or Config.Framework == 'legacy' then
        local xPlayer = FrameworkObject.GetPlayerFromId(_source)
        if xPlayer then
            xPlayer.setJob(formattedJobName, 0)
            TriggerClientEvent('esx:showNotification', _source, 'You are now a ' .. formattedJobName)
        else
            print('Failed to retrieve player for source: ' .. _source)
        end
    elseif Config.Framework == 'newqb' or Config.Framework == 'oldqb' then
        local Player = FrameworkObject.Functions.GetPlayer(_source)
        if Player then
            Player.Functions.SetJob(formattedJobName, 0)
            TriggerClientEvent('QBCore:Notify', _source, 'You are now a ' .. formattedJobName)
        else
            print('Failed to retrieve player for source: ' .. _source)
        end
    end
end)

-- Helper function to get current job
function GetCurrentJobForPlayer(source)
    if Config.Framework == 'esx' or Config.Framework == 'legacy' then
        local xPlayer = FrameworkObject.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.getJob().name
        end
    elseif Config.Framework == 'newqb' or Config.Framework == 'oldqb' then
        local Player = FrameworkObject.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.job.name
        end
    end
    return nil
end
