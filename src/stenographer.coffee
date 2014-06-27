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
twilio      = require('./support/twilio-warn')

warn = ->
  twilio.warn "gossip server DOWN at #{new Date()}"

reportStatusCode = (code) ->
  twilio.warn "Got an errant #{code} from gossip server at #{new Date()}"

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
  log("Handling a #{res.statusCode} from the gossip server.")
  reportStatusCode(code) for code in [500, 502] when code is res.statusCode
  res.setEncoding('utf8')
  res.on 'data', (chunk) ->
    log("Response: #{chunk}")

errorHandler = (error) ->
  warn()
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
      message:      @message,
      author:       @name,
      time:         @time.toUTCString()
    })

module.exports = (robot) ->
  robot.respond /ping/i, (msg) ->
    if msg.message.user.id is "parkr"
      msg.send "Sending the warn message."
      twilio.warn "PING from IRC. Ohai."
      msg.send "Oh, hey parkr. How are you doing today?"
    else
      msg.send "What do I look like to you... a robot?"

  robot.hear /(.*)/i, (msg) ->
    historyentry = new HistoryEntry(msg.message.room, msg.message.user.name, msg.match[1])
    storeMessage(historyentry)
