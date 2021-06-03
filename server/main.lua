ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_CustomStorage:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory
	cb({items = items})
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

	TriggerEvent('esx_addoninventory:getSharedInventory', storageName, function(inventory)
		local inventoryItem = xPlayer.getInventoryItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			xPlayer.showNotification('You have deposited ~b~' .. count .. ' ~y~' .. inventoryItem.label)
		else
			xPlayer.showNotification('Invalid Amount')
		end
	end)
end)

RegisterNetEvent('esx_CustomStorage:getStockItem')
AddEventHandler('esx_CustomStorage:getStockItem', function(itemName, count, storageName)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', storageName, function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then
			if xPlayer.canCarryItem(itemName, count) then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				xPlayer.showNotification('You have withdrawn ~b~' .. count .. ' ~y~ ' .. inventoryItem.label)
			else
				xPlayer.showNotification('~r~Invalid Amount')
			end
		else
			xPlayer.showNotification('~r~Invalid Amount')
		end
	end)
end)