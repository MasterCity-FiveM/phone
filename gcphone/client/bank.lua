--====================================================================================
-- # Discord XenKnighT#7085
--====================================================================================

--[[
      Appeller SendNUIMessage({event = 'updateBankbalance', banking = xxxx})
      à la connection & à chaque changement du compte
--]]

-- ES / ESX Implementation
inMenu                      = true
local bank = 0
local firstname = ''
-- function setBankBalance (value)
--       bank = value
--       SendNUIMessage({event = 'updateBankbalance', banking = bank})
-- end

-- RegisterNetEvent("gcPhone:GetBankBalance")
-- AddEventHandler("gcPhone:GetBankBalance", function(balance)
--       setBankBalance(balance)
-- end)


-- RegisterNetEvent('esx:setAccountMoney')
-- AddEventHandler('esx:setAccountMoney', function(account)
--       if account.name == 'bank' then
--             setBankBalance(account.money)
--       end
-- end)

-- RegisterNetEvent("es:addedBank")
-- AddEventHandler("es:addedBank", function(m)
--       setBankBalance(bank + m)
-- end)

-- RegisterNetEvent("es:removedBank")
-- AddEventHandler("es:removedBank", function(m)
--       setBankBalance(bank - m)
-- end)

-- RegisterNetEvent('es:displayBank')
-- AddEventHandler('es:displayBank', function(bank)
--       setBankBalance(bank)
-- end)



--===============================================
--==         Transfer Event                    ==
--===============================================
AddEventHandler('gcphone:bankTransfer', function(data)
      TriggerServerEvent('bank:transfer', data.id, data.amount)
    TriggerServerEvent('bank:balance')
end)







