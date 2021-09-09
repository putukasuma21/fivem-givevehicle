ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

TriggerEvent('chat:addSuggestion', '/givecar', 'Give A Car To Player', {
	{ name = "playerId", help = "The Id Of The Player" },
    { name = "vehicle", help = "Vehicle Model" },
    { name = "plate", help = "Vehicle Plate, Skip If You want Random Generate Plate Number" }
})

TriggerEvent('chat:addSuggestion', '/delcarplate', 'Delete A Owned Vehicle By Plate Number', {
	{ name = "plate", help = "Vehicle's Plate Number" }
})

RegisterNetEvent('ivrp_giveownedcar:spawnVehicle')
AddEventHandler('ivrp_giveownedcar:spawnVehicle', function(playerID, model, playerName, type, vehicleType)
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)
	local carExist  = false

	ESX.Game.SpawnVehicle(model, coords, 0.0, function(vehicle) --get vehicle info
		if DoesEntityExist(vehicle) then
			carExist = true
			SetEntityVisible(vehicle, false, false)
			SetEntityCollision(vehicle, false)
			
			local newPlate     = exports['rr-vehicleshop']:GeneratePlate()
			local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
			local aheadVehName = GetDisplayNameFromVehicleModel(model)
			local vehicleName = GetLabelText(aheadVehName)
			vehicleProps.plate = newPlate
			TriggerServerEvent('ivrp_giveownedcar:setVehicle', vehicleProps, playerID, vehicleType)
			ESX.Game.DeleteVehicle(vehicle)	
			if type ~= 'console' then
				exports['mythic_notify']:DoHudText('inform', _U('gived_car', vehicleName, newPlate, playerName))
			else
				local msg = ('addCar: ' ..model.. ', plate: ' ..newPlate.. ', toPlayer: ' ..playerName)
				TriggerServerEvent('ivrp_giveownedcar:printToConsole', msg)
			end				
		end		
	end)
	
	Wait(2000)
	if not carExist then
		if type ~= 'console' then
			exports['mythic_notify']:DoHudText('error', _U('unknown_car', model))
		else
			TriggerServerEvent('ivrp_giveownedcar:printToConsole', "ERROR: "..model.." Is An Unknown Vehicle Model")
		end		
	end
end)

RegisterNetEvent('ivrp_giveownedcar:spawnVehiclePlate')
AddEventHandler('ivrp_giveownedcar:spawnVehiclePlate', function(playerID, model, plate, playerName, type, vehicleType)
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)
	local generatedPlate = string.upper(plate)
	local carExist  = false

	ESX.TriggerServerCallback('rr-vehicleshop:isPlateTaken', function (isPlateTaken)
		if not isPlateTaken then
			ESX.Game.SpawnVehicle(model, coords, 0.0, function(vehicle) --get vehicle info	
				if DoesEntityExist(vehicle) then
					carExist = true
					SetEntityVisible(vehicle, false, false)
					SetEntityCollision(vehicle, false)	
					
					local newPlate     = string.upper(plate)
					local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
					local aheadVehName = GetDisplayNameFromVehicleModel(model)
					local vehicleName = GetLabelText(aheadVehName)
					vehicleProps.plate = newPlate
					TriggerServerEvent('ivrp_giveownedcar:setVehicle', vehicleProps, playerID, vehicleType)
					ESX.Game.DeleteVehicle(vehicle)
					if type ~= 'console' then
						exports['mythic_notify']:DoHudText('inform', _U('gived_car',  vehicleName, newPlate, playerName))
					else
						local msg = ('addCar: ' ..model.. ', plate: ' ..newPlate.. ', toPlayer: ' ..playerName)
						TriggerServerEvent('ivrp_giveownedcar:printToConsole', msg)
					end				
				end
			end)
		else
			carExist = true
			if type ~= 'console' then
				exports['mythic_notify']:DoHudText('error', _U('plate_already_have'))
			else
				local msg = ('ERROR: This Plate Is Already Been Used On Another Vehicle')
				TriggerServerEvent('ivrp_giveownedcar:printToConsole', msg)
			end					
		end
	end, generatedPlate)
	
	Wait(2000)
	if not carExist then
		if type ~= 'console' then
			exports['mythic_notify']:DoHudText('error', _U('unknown_car', model))
		else
			TriggerServerEvent('ivrp_giveownedcar:printToConsole', "ERROR: "..model.." Is An Unknown Vehicle Model")
		end		
	end	
end)