MySQL.ready(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS vehicle_km (
            plate VARCHAR(50) PRIMARY KEY,
            km INT DEFAULT 0
        )
    ]], {}, function(rowsChanged)
        print("[Vehicle KM] Database initialized successfully.")
    end)
end)

RegisterNetEvent('checkVehicleAndDisplayDashboard')
AddEventHandler('checkVehicleAndDisplayDashboard', function(plate)
    local _source = source
    MySQL.Async.fetchAll('SELECT km FROM vehicle_km WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(result)
        if result[1] then
            local km = result[1].km
			local realKM = km / 1000
            TriggerClientEvent('updateVehicleKmDisplay', _source, plate, realKM)
        else
            MySQL.Async.execute('INSERT INTO vehicle_km (plate, km) VALUES (@plate, 0)', {
                ['@plate'] = plate
            }, function()
                TriggerClientEvent('updateVehicleKmDisplay', _source, plate, 0.0)
            end)
        end
    end)
end)

RegisterNetEvent('updateCarKm')
AddEventHandler('updateCarKm', function(plate, distance)
    local _source = source
    MySQL.Async.execute('UPDATE vehicle_km SET km = km + @distance WHERE plate = @plate', {
        ['@distance'] = distance,
        ['@plate'] = plate
    }, function()
        MySQL.Async.fetchScalar('SELECT km FROM vehicle_km WHERE plate = @plate', {
            ['@plate'] = plate
        }, function(updatedDistance)
            if updatedDistance then
                local km = updatedDistance
				local realKM = km / 1000
                TriggerClientEvent('updateVehicleKmDisplay', _source, plate, realKM)
            end
        end)
    end)
end)
