ESX              = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(250)
	end
end)

-- Create Enter / Exit Markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		for k,v in pairs(Config.Locations) do
			local StorageLocation = vector3(v.coord.x, v.coord.y, v.coord.z)

			while #(GetEntityCoords(PlayerPedId()) - StorageLocation) <= 5.0 do
				Citizen.Wait(0) -- REQUIRED
				-- Draw the marker
				DrawMarker(25, StorageLocation.x, StorageLocation.y, StorageLocation.z - 0.98, 
				0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 0, 255, 0, 155, false, true, 2, nil, nil, false)
			end
		end
	end
end)

-- Check the distance from the markers
Citizen.CreateThread(function() --Checks to see if player is near the coords and if so, displays the text.
	while not NetworkIsSessionStarted() do -- Wait for the user to load
		Wait(500)
	end

	while true do
		Citizen.Wait(1)
		local coords = GetEntityCoords(PlayerPedId())
		for k,v in pairs(Config.Locations) do
			local markerlocation = vector3(v.coord.x, v.coord.y, v.coord.z)
		
			-- Check how close the player is to the marker location
			while #(GetEntityCoords(PlayerPedId()) - markerlocation) <= 1.0 do
				Citizen.Wait(0) -- REQUIRED
				local storageLabel = v.label
				-- Draw text with instructions
				ESX.Game.Utils.DrawText3D(markerlocation, "Press ~y~[E]~s~ to use " .. storageLabel .. " storage")

				-- Check for button press
				if IsControlJustReleased(0, 51) then
					-- Open menu is the button is pressed
					local storageName = v.name
					
					OpenMainStorageMenu(storageName, storageLabel)
				end
			end
		end
	end
end)

function OpenMainStorageMenu(storageName, storageLabel)
	local elements = {
		{label = 'Store Items', value = 'store_item'},
		{label = 'Withdraw Items', value = 'remove_item'}
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'storage', {
		title    = 'Storage: ' .. storageLabel,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'store_item' then
			OpenStorageMenu(storageName, storageLabel)
		elseif data.current.value == 'remove_item' then
			OpenGetStocksMenu(storageName, storageLabel)
		end

	end, function(data, menu)
		menu.close()
	end)
end

function OpenStorageMenu(storageName, storageLabel)
	ESX.TriggerServerCallback('esx_CustomStorage:getPlayerInventory', function(inventory)
		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = 'Inventory',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = 'Quantity'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('quantity_invalid')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_CustomStorage:putStockItems', itemName, count, storageName)

					Citizen.Wait(300)
					OpenStorageMenu(storageName, storageLabel)
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenGetStocksMenu(storageName, storageLabel)
	ESX.TriggerServerCallback('esx_CustomStorage:getStockItems', function(items)
		local elements = {}

		for i=1, #items, 1 do
			table.insert(elements, {
				label = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = 'Storage: ' .. storageLabel,
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = 'Quantity'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('Invalid Amount')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_CustomStorage:getStockItem', itemName, count, storageName)

					Citizen.Wait(300)
					OpenGetStocksMenu(storageName, storageLabel)
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end, storageName)
end
