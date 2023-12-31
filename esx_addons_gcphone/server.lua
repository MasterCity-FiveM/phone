
ESX                       = nil
local PhoneNumbers        = {}

-- PhoneNumbers = {
--   ambulance = {
--     type  = "ambulance",
--     sources = {
--        ['1'] = true
--     }
--   }
-- }

TriggerEvent('esx:getSharedObject', function(obj)
  ESX = obj
end)

function notifyAlertSMS(number, alert, listSrc)
  if PhoneNumbers[number] ~= nil then
	if alert.notify_reciver and alert.sourceplayer then
		TriggerEvent('gcPhone:_internalAddMessage', number, alert.numero, alert.message, 0, function (smsMess)
			TriggerClientEvent("gcPhone:receiveMessage", tonumber(alert.sourceplayer), smsMess, false)
		end)
	end
	
	local mess = 'From #' .. alert.numero  .. ' : ' .. alert.message
	
	if alert.coords ~= nil then
		mess = mess .. ' GPS: ' .. alert.coords.x .. ', ' .. alert.coords.y 
	end
	
	TriggerEvent('esx_service:getInServicePlayers',  function(inServiceUsers)
		if inServiceUsers == nil then
			return
		end
		
		for k, _ in pairs(inServiceUsers) do
			getPhoneNumber(tonumber(k), function (n)
				if n ~= nil then
					TriggerEvent('gcPhone:_internalAddMessage', number, n, mess, 0, function (smsMess)
						TriggerClientEvent("gcPhone:receiveMessage", tonumber(k), smsMess, true)
					end)
				end
			 end)
		end
	end, number)
  end
end

AddEventHandler('esx_phone:registerNumber', function(number, type, sharePos, hasDispatch, hideNumber, hidePosIfAnon)
  -- print('==== Enregistrement du telephone ' .. number .. ' => ' .. type)
	local hideNumber    = hideNumber    or false
	local hidePosIfAnon = hidePosIfAnon or false

	PhoneNumbers[number] = {
		type          = type,
    sources       = {},
    alerts        = {}
	}
end)


AddEventHandler('esx:setJob', function(source, job, lastJob)
  if PhoneNumbers[lastJob.name] ~= nil then
    TriggerEvent('esx_addons_gcphone:removeSource', lastJob.name, source)
  end

  if PhoneNumbers[job.name] ~= nil then
    TriggerEvent('esx_addons_gcphone:addSource', job.name, source)
  end
end)

AddEventHandler('esx_addons_gcphone:addSource', function(number, source)
	PhoneNumbers[number].sources[tostring(source)] = true
end)

AddEventHandler('esx_addons_gcphone:removeSource', function(number, source)
	PhoneNumbers[number].sources[tostring(source)] = nil
end)

RegisterServerEvent('gcPhone:sendMessage')
AddEventHandler('gcPhone:sendMessage', function(number, message)
    local sourcePlayer = tonumber(source)
    if PhoneNumbers[number] ~= nil then
      getPhoneNumber(source, function (phone)
        notifyAlertSMS(number, {
          message = message,
          numero = phone,
        }, PhoneNumbers[number].sources)
      end)
    end
end)

RegisterServerEvent('esx_addons_gcphone:startCall')
AddEventHandler('esx_addons_gcphone:startCall', function (number, message, coords)
  local source = source
  if PhoneNumbers[number] ~= nil then
    getPhoneNumber(source, function (phone) 
      notifyAlertSMS(number, {
        message = message,
        coords = coords,
        numero = phone,
      }, PhoneNumbers[number].sources)
    end)
  -- else
  --   print('Appels sur un service non enregistre => numero : ' .. number)
  end
end)

RegisterServerEvent('esx_addons_gcphone:startCallRecNotify')
AddEventHandler('esx_addons_gcphone:startCallRecNotify', function (number, message, coords)
  local source = source
  if PhoneNumbers[number] ~= nil then
    getPhoneNumber(source, function (phone) 
      notifyAlertSMS(number, {
        message = message,
        coords = coords,
        numero = phone,
		notify_reciver = true,
		sourceplayer = source
      }, PhoneNumbers[number].sources)
    end)
  -- else
  --   print('Appels sur un service non enregistre => numero : ' .. number)
  end
end)


AddEventHandler('esx:playerLoaded', function(source)

  local xPlayer = ESX.GetPlayerFromId(source)

  MySQL.Async.fetchAll('SELECT phone_number FROM users WHERE identifier = @identifier',{
    ['@identifier'] = xPlayer.identifier
  }, function(result)

    local phoneNumber = result[1].phone_number
    xPlayer.set('phoneNumber', phoneNumber)

    if PhoneNumbers[xPlayer.job.name] ~= nil then
      TriggerEvent('esx_addons_gcphone:addSource', xPlayer.job.name, source)
    end
  end)

end)


AddEventHandler('esx:playerDropped', function(source)
  local source = source
  local xPlayer = ESX.GetPlayerFromId(source)
  if PhoneNumbers[xPlayer.job.name] ~= nil then
    TriggerEvent('esx_addons_gcphone:removeSource', xPlayer.job.name, source)
  end
end)


function getPhoneNumber (source, callback) 
  local xPlayer = ESX.GetPlayerFromId(source)
  if xPlayer == nil then
    callback(nil)
  end

  if xPlayer.phoneNumber == nil then
    MySQL.Async.fetchAll('SELECT phone_number FROM users WHERE identifier = @identifier',{
      ['@identifier'] = xPlayer.identifier
    }, function(result)
      callback(result[1].phone_number)
    end)
  else
    callback(xPlayer.phoneNumber)
  end
end

RegisterServerEvent('esx_phone:send')
AddEventHandler('esx_phone:send', function(number, message, _, coords)
  local source = source
  if PhoneNumbers[number] ~= nil then
    getPhoneNumber(source, function (phone) 
      notifyAlertSMS(number, {
        message = message,
        coords = coords,
        numero = phone,
      }, PhoneNumbers[number].sources)
    end)
  -- else
  -- print('esx_phone:send | Appels sur un service non enregistre => numero : ' .. number)
  end
end)