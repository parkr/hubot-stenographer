# Description:
#   Hubot writes down all messages it hears on a Witness-compliant server.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_LOG_SERVER_HOST
#   HUBOT_LOG_SERVER_PORT
#   HUBOT_LOG_SERVER_TOKEN
#
# Author:
#   Parker Moore (@parkr)

HistoryEntry  = require('./support/history-entry')
WitnessServer = require('./support/witness-server')
twilio        = require('./support/twilio-warn')

warn = ->
  twilio.warn "gossip server DOWN at #{new Date()}"

reportStatusCode = (code) ->
  twilio.warn "Got an errant #{code} from gossip server at #{new Date()}"

errHandler = (err, code) ->
  warn()
  reportStatusCode(code)
  if err?
    console.log(err, err.stack)

witness = new WitnessServer \
  process.env.HUBOT_LOG_SERVER_HOST,
  process.env.HUBOT_LOG_SERVER_PORT,
  process.env.HUBOT_LOG_SERVER_TOKEN,
  errHandler

storeMessage = (event) ->
  if witness.isEnabled()
    process.nextTick ->
      witness.send event
  else
    console.log("Logging isn't enabled. " +
      "Make sure you've set the proper environment variables!")

module.exports = (robot) ->
  robot.respond /ping/i, (msg) ->
    if msg.message.user.id is "parkr"
      msg.send "Sending the warn message."
      twilio.warn "You just pinged yourself from IRC. Well done."
      msg.send "Oh, hey parkr. How are you doing today?"
    else
      msg.send "What do I look like to you... a robot?"

  robot.hear /(.*)/i, (msg) ->
    event = new HistoryEntry(
      msg.message.room,
      msg.message.user.name,
      msg.match[1]
    )
    storeMessage event
