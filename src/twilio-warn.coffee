# Description:
#   Send messages to Twilio recipient.
#
# Dependencies:
#   twilio
#
# Configuration:
#   HUBOT_TWILIO_SID
#   HUBOT_TWILIO_AUTH_TOKEN
#   HUBOT_TWILIO_WARN_TO
#   HUBOT_TWILIO_WARN_FROM
#
# Author:
#   Parker Moore (@parkr)

accountSid = process.env.HUBOT_TWILIO_SID
authToken  = process.env.HUBOT_TWILIO_AUTH_TOKEN
notifyTo   = process.env.HUBOT_TWILIO_WARN_TO
notifyFrom = process.env.HUBOT_TWILIO_WARN_FROM

log = (message) ->
  console.log("twilio:", message)

isEnabled = ->
  accountSid? and authToken? and notifyTo? and notifyFrom?

sendMessage = (client, to, from, body) ->
  client.messages.create
    to: to,
    from: from,
    body: bodyk
  , (err, message) ->
    log("problem sending #{message.sid}")

newClient = ->
  require('twilio')(accountSid, authToken)

if isEnabled()
  log("enabled!")
  client = newClient()
  module.exports =
    warn: (message) ->
      sendMessage client, notifyTo, notifyFrom, "warning: #{message}"
else
  log("not enabled :(")
  module.exports =
    warn: (message) ->
      "NOPE."
