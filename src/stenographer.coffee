# Description:
#   Hubot writes down all messages it hears on a Witness-compliant server.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_LOG_SERVER_HOST
#   HUBOT_LOG_SERVER_TOKEN
#
# Author:
#   Parker Moore (@parkr)

http        = require('http')
querystring = require('querystring')

log = (msg) ->
  console.log("[stenog] #{msg}")

isEnabled = ->
  process.env.HUBOT_LOG_SERVER_TOKEN? and process.env.HUBOT_LOG_SERVER_HOST?

httpOptsForData = (data) ->
  {
    host: process.env.HUBOT_LOG_SERVER_HOST,
    port: 80,
    path: "/api/messages/log",
    method: 'POST',
    headers:
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': data.length
  }

responseHandler = (res) ->
  res.setEncoding('utf8')
  res.on 'data', (chunk) ->
    log("Response: #{chunk}")

errorHandler = (error) ->
  log("error!!!")
  console.error(error)
  console.error(error.stack)

sendEventToServer = (event) ->
  log("SENDING MESSAGE TO #{process.env.HUBOT_LOG_SERVER_HOST}...")
  data = event.queryString()
  try
    log("Logging that #{event.name} said '#{event.message}' at #{event.time.toUTCString()} in #{event.room}")
    req = http.request httpOptsForData(data), responseHandler
    req.on 'error', errorHandler
    req.write(data)
    req.end()
  catch e
    errorHandler(e)

storeMessage = (event) ->
  if isEnabled()
    process.nextTick ->
      sendEventToServer(event)
  else
    console.log("Logging isn't enabled. Make sure you've set the proper environment variables!")

class HistoryEntry
  constructor: (@room, @name, @message) ->
    @time = new Date()
    @hours = @time.getHours()
    @minutes = @time.getMinutes()
    if @minutes < 10
      @minutes = '0' + @minutes

  queryString: ->
    querystring.stringify({
      access_token: process.env.HUBOT_LOG_SERVER_TOKEN,
      room:         @room,
      text:         @message,
      author:       @name,
      time:         @time.toUTCString()
    })

module.exports = (robot) ->
  robot.hear /(.*)/i, (msg) ->
    historyentry = new HistoryEntry(msg.message.room, msg.message.user.name, msg.match[1])
    storeMessage(historyentry)
