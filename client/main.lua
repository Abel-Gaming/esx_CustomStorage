ESX = exports["es_extended"]:getSharedObject()
local GetCurrentResourceName = GetCurrentResourceName()
local ox_inventory = exports.ox_inventory

----- CHECK MARKER LOCATION -----
Citizen.CreateThread(function()
	while not NetworkIsSessionStarted() do
		Wait(500)
	end

	while true do
		Citizen.Wait(1)

        for k,v in pairs(Config.Locations) do
            while #(GetEntityCoords(PlayerPedId()) - v.Coords) <= 1.0 do
                Citizen.Wait(0)
                Draw3DText(v.Coords, "Press ~y~[E]~s~ to open storage", 0.4)
                if IsControlJustReleased(0, 51) then
                    exports.ox_inventory:openInventory('stash', {id=v.id, owner=v.owner})
                end
            end
        end
	end
end)

----- DRAW MARKER -----
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
        for k,v in pairs(Config.Locations) do
            DrawMarker(25, v.Coords.x, v.Coords.y, v.Coords.z - 0.98, 
		    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 0, 255, 0, 155, false, true, 2, nil, nil, false)
        end
	end
end)

----- DRAW BLIP IF ENABLED -----
Citizen.CreateThread(function()
    for k,v in pairs(Config.Locations) do
        if v.DrawBlip then
		    local blip = AddBlipForCoord(v.Coords.x, v.Coords.y, v.Coords.z)
		    SetBlipSprite (blip, v.BlipSprite)
		    SetBlipDisplay(blip, 4)
		    SetBlipScale  (blip, 1.0)
		    SetBlipAsShortRange(blip, true)
		    BeginTextCommandSetBlipName("STRING")
		    AddTextComponentString(v.name)
		    EndTextCommandSetBlipName(blip)
	    end
    end
end)

----- FUNCTIONS ------
function Draw3DText(coords, text, scale) --Function to draw 3D text
	local x, y, z = table.unpack(coords)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
	SetTextScale(scale, scale)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry("STRING")
	SetTextCentre(true)
	SetTextColour(255, 255, 255, 215)
	AddTextComponentString(text)
	DrawText(_x, _y)
	local factor = (string.len(text)) / 700
	DrawRect(_x, _y + 0.0150, 0.06 + factor, 0.03, 41, 11, 41, 100)
end

function CreateMarker(coords, rgba, height, scale)
	coords = coords - vector3(0.0, 0.0, 1.0)
    local checkPoint = CreateCheckpoint(45, coords, coords, scale, rgba.red, rgba.green, rgba.blue, rgba.alpha, 0)
    SetCheckpointCylinderHeight(checkPoint, height, height, scale)
    return checkPoint
end

function InfoMessage(message)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName('~y~[INFO]~w~ ' .. message)
	DrawNotification(false, true)
end

function OpenMainStorageMenu(storageName, storageLabel)
    local elements = {
        {label = 'Store Items', value = 'store_item'},
        {label = 'Withdraw Items', value = 'remove_item'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'storage', {
        title    = 'Storage: ' .. storageLabel,
        align    = 'center',
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

        for _, item in ipairs(inventory.items) do
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
            align    = 'center',
            elements = elements
        }, function(data, menu)
            local itemName = data.current.value

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
                title = 'Quantity'
            }, function(data2, menu2)
                local count = tonumber(data2.value)

                if not count then
                    ESX.ShowNotification('Invalid Quantity')
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

        for _, item in ipairs(items) do
            table.insert(elements, {
                label = 'x' .. item.count .. ' ' .. item.label,
                value = item.name
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
            title    = 'Storage: ' .. storageLabel,
            align    = 'center',
            elements = elements
        }, function(data, menu)
            local itemName = data.current.value

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
                title = 'Quantity'
            }, function(data2, menu2)
                local count = tonumber(data2.value)

                if not count then
                    ESX.ShowNotification('Invalid Quantity')
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