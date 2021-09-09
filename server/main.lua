ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--give car with a random plate- 1: playerID 2: carModel (3: plate)
RegisterCommand('givecar', function(source, args)
	givevehicle(source, args, 'car')
end)

function givevehicle(_source, _args, vehicleType)
	if havePermission(_source) then
		if _args[1] == nil or _args[2] == nil then
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = '/givevehicle playerID carModel [plate]' })
		elseif _args[3] ~= nil then
			local playerName = GetPlayerName(_args[1])
			local plate = _args[3]
			if #_args > 3 then
				for i=4, #_args do
					plate = plate.." ".._args[i]
				end
			end	
			plate = string.upper(plate)
			TriggerClientEvent('ivrp_giveownedcar:spawnVehiclePlate', _source, _args[1], _args[2], plate, playerName, 'player', vehicleType)
		else
			local playerName = GetPlayerName(_args[1])
			TriggerClientEvent('ivrp_giveownedcar:spawnVehicle', _source, _args[1], _args[2], playerName, 'player', vehicleType)
		end
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'You Don\'t Have Permission To Do This Command!' })
	end
end

RegisterCommand('_givecar', function(source, args)
	_givevehicle(source, args, 'car')
end)

function _givevehicle(_source, _args, vehicleType)
	if _source == 0 then
		local sourceID = _args[1]
		if _args[1] == nil or _args[2] == nil then
			print("SYNTAX ERROR: _givevehicle <playerID> <carModel> [plate]")
		elseif _args[3] ~= nil then
			local playerName = GetPlayerName(sourceID)
			local plate = _args[3]
			if #_args > 3 then
				for i=4, #_args do
					plate = plate.." ".._args[i]
				end
			end
			plate = string.upper(plate)
			TriggerClientEvent('ivrp_giveownedcar:spawnVehiclePlate', sourceID, _args[1], _args[2], plate, playerName, 'console', vehicleType)
		else
			local playerName = GetPlayerName(_args[1])
			TriggerClientEvent('ivrp_giveownedcar:spawnVehicle', sourceID, _args[1], _args[2], playerName, 'console', vehicleType)
		end
	end
end

RegisterCommand('delcarplate', function(source, args)
	if havePermission(source) then
		if args[1] == nil then
			TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = '/delcarplate <plate>' })
		else
			local plate = args[1]
			if #args > 1 then
				for i=2, #args do
					plate = plate.." "..args[i]
				end		
			end
			plate = string.upper(plate)
			
			local result = MySQL.Sync.execute('DELETE FROM owned_vehicles WHERE plate = @plate', {
				['@plate'] = plate
			})
			if result == 1 then
				TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = _U('del_car', plate) })
			elseif result == 0 then
				TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = _U('del_car_error', plate) })
			end		
		end
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'You Don\'t Have Permission To Do This Command!' })
	end		
end)

RegisterCommand('_delcarplate', function(source, args)
    if source == 0 then
		if args[1] == nil then	
			print("SYNTAX ERROR: _delcarplate <plate>")
		else
			local plate = args[1]
			if #args > 1 then
				for i=2, #args do
					plate = plate.." "..args[i]
				end		
			end
			plate = string.upper(plate)
			
			local result = MySQL.Sync.execute('DELETE FROM owned_vehicles WHERE plate = @plate', {
				['@plate'] = plate
			})
			if result == 1 then
				print('Deleted Car Plate: ' ..plate)
			elseif result == 0 then
				print('Can\'t Find Car with Plate Is ' ..plate)
			end
		end
	end
end)


-- Functions --

RegisterServerEvent('ivrp_giveownedcar:setVehicle')
AddEventHandler('ivrp_giveownedcar:setVehicle', function (vehicleProps, playerID, vehicleType)
	local _source = playerID
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, garage, type) VALUES (@owner, @plate, @vehicle, @stored, @garage, @type)',
	{
		['@owner']   = xPlayer.identifier,
		['@plate']   = vehicleProps.plate,
		['@vehicle'] = json.encode(vehicleProps),
		['@stored']  = 1,
		['garage'] = 'H',
		['type'] = vehicleType
	}, function ()
		if Config.ReceiveMsg then
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'inform', text = _U('received_car', string.upper(vehicleProps.plate)) })
		end
	end)
end)

RegisterServerEvent('ivrp_giveownedcar:printToConsole')
AddEventHandler('ivrp_giveownedcar:printToConsole', function(msg)
	print(msg)
end)

function havePermission(_source)
	local xPlayer = ESX.GetPlayerFromId(_source)
	local playerGroup = xPlayer.getGroup()
	local isAdmin = false
	for k,v in pairs(Config.AuthorizedRanks) do
		if v == playerGroup then
			isAdmin = true
			break
		end
	end
	
	if IsPlayerAceAllowed(_source, "giveownedcar.command") then isAdmin = true end
	
	return isAdmin
end
