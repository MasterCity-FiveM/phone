function TchatGetMessageChannel (channel, cb)
    MySQL.Async.fetchAll("SELECT * FROM phone_app_chat WHERE channel = @channel ORDER BY time DESC LIMIT 100", { 
        ['@channel'] = channel
    }, cb)
end

function getTChatCount(channel)
  local result = MySQL.Sync.fetchAll("SELECT COUNT(id) as messages FROM phone_app_chat WHERE channel = @channel", {
      ['@channel'] = channel
  })

  if result[1] ~= nil and result[1].messages ~= nil then
      return result[1].messages
  end

  return 0
end

function DeleteOldestTChats(channel)
  local calls_count = getTChatCount(channel)
  if calls_count > 20 then
      local mustbedelete = calls_count - 20
      MySQL.Sync.fetchAll("DELETE FROM phone_app_chat WHERE channel = @channel LIMIT " .. mustbedelete .. " ORDER by id ASC", {
          ['@ochannelwner'] = channel
      })
  end
end

function TchatAddMessage (channel, message)
  DeleteOldestTChats(channel)
  local Query = "INSERT INTO phone_app_chat (`channel`, `message`) VALUES(@channel, @message);"
  local Query2 = 'SELECT * from phone_app_chat WHERE `id` = @id;'
  local Parameters = {
    ['@channel'] = channel,
    ['@message'] = message
  }
  MySQL.Async.insert(Query, Parameters, function (id)
    MySQL.Async.fetchAll(Query2, { ['@id'] = id }, function (reponse)
      TriggerClientEvent('gcPhone:tchat_receive', -1, reponse[1])
    end)
  end)
end


RegisterServerEvent('gcPhone:tchat_channel')
AddEventHandler('gcPhone:tchat_channel', function(channel)
  local sourcePlayer = tonumber(source)
  TchatGetMessageChannel(channel, function (messages)
    TriggerClientEvent('gcPhone:tchat_channel', sourcePlayer, channel, messages)
  end)
end)

RegisterServerEvent('gcPhone:tchat_addMessage')
AddEventHandler('gcPhone:tchat_addMessage', function(channel, message)
  TchatAddMessage(channel, message)
end)