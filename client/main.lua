
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
