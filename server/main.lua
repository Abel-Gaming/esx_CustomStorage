ESX = exports["es_extended"]:getSharedObject()
local GetCurrentResourceName = GetCurrentResourceName()
local ox_inventory = exports.ox_inventory

ESX.RegisterServerCallback('esx_CustomStorage:getPlayerInventory', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local items = xPlayer.getInventory()
    cb({ items = items })
end)

ESX.RegisterServerCallback('esx_CustomStorage:getStockItems', function(source, cb, storageName)
    if Config.ServerPrint then
        print('Getting items from: ' .. storageName)
    end
    TriggerEvent('esx_addoninventory:getSharedInventory', storageName, function(inventory)
        cb(inventory.items)
    end)
end)

RegisterNetEvent('esx_CustomStorage:putStockItems')
AddEventHandler('esx_CustomStorage:putStockItems', function(itemName, count, storageName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local sourceItem = xPlayer.getInventoryItem(itemName)

    if sourceItem.count >= count and count > 0 then
        xPlayer.removeInventoryItem(itemName, count)
        TriggerEvent('esx_addoninventory:getSharedInventory', storageName, function(inventory)
            inventory.addItem(itemName, count)
            xPlayer.showNotification('You have deposited ~b~' .. count .. ' ~y~ ' .. sourceItem.label)
        end)
    else
        xPlayer.showNotification('Invalid Amount')
    end
end)

RegisterNetEvent('esx_CustomStorage:getStockItem')
AddEventHandler('esx_CustomStorage:getStockItem', function(itemName, count, storageName)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerEvent('esx_addoninventory:getSharedInventory', storageName, function(inventory)
        local inventoryItem = inventory.getItem(itemName)

        if count > 0 and inventoryItem.count >= count then
            if xPlayer.canCarryItem(itemName, count) then
                inventory.removeItem(itemName, count)
                xPlayer.addInventoryItem(itemName, count)
                xPlayer.showNotification('You have withdrawn ~b~' .. count .. ' ~y~ ' .. inventoryItem.label)
            else
                xPlayer.showNotification('~r~Inventory full')
            end
        else
            xPlayer.showNotification('~r~Invalid Amount')
        end
    end)
end)

AddEventHandler('onServerResourceStart', function(resourceName)
	if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName then
		for i=1, #(Config.Locations) do
			local stash = Config.Locations[i]
			ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner, stash.jobs)
		end
	end
end)