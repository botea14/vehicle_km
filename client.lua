local lastPosition = vector3(0, 0, 0)
local currentVehicle = nil
local vehiclePlate = nil
local isDriver = false

function IsPlayerDriver(vehicle)
    return GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) 

        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            if IsPlayerDriver(vehicle) then
                if vehicle ~= currentVehicle then
                    currentVehicle = vehicle
                    vehiclePlate = GetVehicleNumberPlateText(vehicle)
                    lastPosition = GetEntityCoords(vehicle)

                    TriggerServerEvent('checkVehicleAndDisplayDashboard', vehiclePlate)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if currentVehicle ~= nil and not IsPedInAnyVehicle(PlayerPedId(), false) then
            SendNUIMessage({ type = 'hide' })
            
            currentVehicle = nil
            vehiclePlate = nil
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) 
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if IsPlayerDriver(vehicle) then

                local currentPos = GetEntityCoords(vehicle)
                local distance = #(currentPos - lastPosition)

                if distance > 1.0 then
                    TriggerServerEvent('updateCarKm', vehiclePlate, math.floor(distance))

                    lastPosition = currentPos

                end
            end
        end
    end
end)

RegisterNetEvent('updateVehicleKmDisplay')
AddEventHandler('updateVehicleKmDisplay', function(plate, km)
    km = string.format("%.1f", km)
    SendNUIMessage({
        type = 'updateKmDisplay',
        plate = plate,
        km = km
    })

    SendNUIMessage({
        type = 'show'
    })
end)

RegisterNetEvent('hideVehicleDashboard')
AddEventHandler('hideVehicleDashboard', function()
    SendNUIMessage({ type = 'hide' })
end)