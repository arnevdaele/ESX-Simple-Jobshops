ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_simplejobshop:buyItem')
AddEventHandler('esx_simplejobshop:buyItem', function(itemName, amount, price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	amount = ESX.Math.Round(amount)
	price = price * amount

	if xPlayer.getMoney() >= price then
		if xPlayer.canCarryItem(itemName, amount) then
			xPlayer.removeMoney(price)
			xPlayer.addInventoryItem(itemName, amount)
			xPlayer.showNotification('You bought ' .. amount .. 'x ' .. itemName .. ' worth $' .. ESX.Math.GroupDigits(price))
		else
			xPlayer.showNotification('You do not have enough space to carry this item...')
		end
	else
		local missingMoney = price - xPlayer.getMoney()
		xPlayer.showNotification("You're $" .. ESX.Math.GroupDigits(missingMoney) .. " short to buy this...")
	end
end)