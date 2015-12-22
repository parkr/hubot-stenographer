querystring = require('querystring')

class HistoryEntry
  constructor: (@room, @user, @message) ->
    @time = new Date()
    @hours = @time.getHours()
    @minutes = @time.getMinutes()
    if @minutes < 10
      @minutes = '0' + @minutes

  queryString: ->
    querystring.stringify({
      access_token: process.env.HUBOT_LOG_SERVER_TOKEN,
      room:         @room,
      message:      @message,
      author:       @user,
      time:         @time.toUTCString()
    })

  toString: ->
    "#{@user} said '#{@message}' at #{@time.toUTCString()} in #{@room}"

module.exports = HistoryEntry
