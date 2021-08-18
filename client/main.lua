local currentShop = nil
local currentAction, currentActionMsg, currentActionData = nil, nil, {}
local isInRange = false

ESX = nil
  
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    
    PlayerData = ESX.GetPlayerData()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        for k, v in pairs(Config.Shops) do
            if v['Allowed'] == PlayerData.job.name then
				if (GetDistanceBetweenCoords(playerCoords, v['Coords']['X'], v['Coords']['Y'], v['Coords']['Z'], true) <= 1.0) then
				isInRange = true
					DrawText3D(v['Coords']['X'], v['Coords']['Y'], v['Coords']['Z'], '~g~E~s~ - Winkel openen')
					if IsControlJustPressed(0, 38) then
						currentShop = k
						openShop(k)
					end
				end
				
				if (GetDistanceBetweenCoords(playerCoords, v['Coords']['X'], v['Coords']['Y'], v['Coords']['Z'], true) > 1.5) and isInRange then
					isInRange = false
					ESX.UI.Menu.CloseAll()
				end
            end
        end
    end
end)

openShop = function(currentShop)
    local elements = {}
	
	for i=1, #Config.Shops[currentShop]['Items'], 1 do
		local item = Config.Shops[currentShop]['Items'][i]

		table.insert(elements, {
			label      = ('%s - <span style="color:green;">%s</span>'):format(item.Label, ESX.Math.GroupDigits(item.Price)),
			itemLabel = item.Label,
			item       = item.Name,
			price      = item.Price,
			value      = 1,
			type       = 'slider',
			min        = 1,
			max        = 100
		})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop', {
		title    = 'Job Shop',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
			title    = 'Are you sure?',
			align    = 'top-left',
			elements = {
				{label = 'No, go back',  value = 'no'},
				{label = 'Yes', value = 'yes'}
		}}, function(data2, menu2)
			if data2.current.value == 'yes' then
				TriggerServerEvent('esx_simplejobshop', data.current.item, data.current.value, data.current.price)
			end

			menu2.close()
		end, function(data2, menu2)
			menu2.close()
		end)
	end, function(data, menu)
		menu.close()

		currentAction     = 'shop_menu'
		currentActionMsg  = 'Job Shop'
		currentActionData = {currentShop = currentShop}
	end)
end

DrawText3D = function(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end
