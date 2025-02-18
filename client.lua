local lastPosition = vector3(0, 0, 0)
local currentVehicle = nil
local vehiclePlate = nil
local needToDisplay = false
local distanceToUpdate = 0
local vehicleCurrentKm = 0

-- Function to check if player is the driver
local function IsPlayerDriver(vehicle)
    return GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
end

-- Detect when the player enters/exits a vehicle
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle and vehicle ~= 0 and IsPlayerDriver(vehicle) then
            if vehicle ~= currentVehicle then
                currentVehicle = vehicle
                vehiclePlate = GetVehicleNumberPlateText(vehicle)
                lastPosition = GetEntityCoords(vehicle)
                needToDisplay = false
                TriggerServerEvent('checkVehicleAndDisplayDashboard', vehiclePlate)
            end
        elseif currentVehicle then

            if distanceToUpdate >= 1 then
                TriggerServerEvent('updateCarKm', vehiclePlate, math.floor(distanceToUpdate))
                distanceToUpdate = 0
            end

            -- Reset vehicle data
            currentVehicle = nil
            vehiclePlate = nil
            needToDisplay = false
            -- Ensure UI is hidden on exit
			Citizen.Wait(500)
            SendNUIMessage({ type = 'hide' })
        end

        Citizen.Wait(100)
    end
end)

-- Update vehicle kilometers
Citizen.CreateThread(function()
    while true do
        if currentVehicle then
            local currentPos = GetEntityCoords(currentVehicle)
            local distance = #(currentPos - lastPosition)

            if distance > 0.1 then
                vehicleCurrentKm = vehicleCurrentKm + distance
                distanceToUpdate = distanceToUpdate + distance

                -- Update UI every 500 meters
                if distanceToUpdate >= 100 then
                    TriggerServerEvent('updateCarKm', vehiclePlate, math.floor(distanceToUpdate))
                    distanceToUpdate = 0
				end


                lastPosition = currentPos
            end
        end

        Citizen.Wait(1000) -- Updates every second
    end
end)

-- Event to update the vehicle's kilometers on the dashboard
RegisterNetEvent('updateVehicleKmDisplay')
AddEventHandler('updateVehicleKmDisplay', function(plate, km)
    needToDisplay = true
    vehicleCurrentKm = tonumber(km) * 1000 -- Ensure proper type conversion
	local displayKm = string.format("%.1f", vehicleCurrentKm / 1000)
    SendNUIMessage({
        type = 'updateKmDisplay',
        plate = plate,
        km = displayKm
    })
    SendNUIMessage({ type = 'show' })
end)

-- Event to hide the dashboard if vehicle does not exist in the database
RegisterNetEvent('hideVehicleDashboard')
AddEventHandler('hideVehicleDashboard', function()
    SendNUIMessage({ type = 'hide' })
end)
