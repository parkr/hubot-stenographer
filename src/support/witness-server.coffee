# Description:
#   Send messages to Gossip/Witness server.
#
# Author:
#   Parker Moore (@parkr)

class WitnessServer
  constructor: (@host, @port, @token, @error) ->
    @port = parseInt(@port)
    @http = require(if @port == 443 then 'https' else 'http')

  isEnabled: ->
    @token? and @host? and @token != "" and @host != ""

  log: (message) ->
    console.log("stenog:", msg)

  httpOpts: (data) ->
    {
      host:   @host,
      port:   @port,
      path:   "/api/messages/log",
      method: "POST",
      headers:
        'Content-Type':   "application/x-www-form-urlencoded",
        'Content-Length': data.length
    }

  handle: (res) ->
    code = res.statusCode
    log("Handling a #{code} from the gossip server.")
    @error(null, code) if code < 200 or code > 299
    res.setEncoding('utf8')
    res.on 'data', (chunk) ->
      log("Response: #{chunk}")

  send: (event) ->
    @log "Sending message to #{@host}:#{@port}..."
    data = event.queryString()
    try
      log("Logging that #{event.toString()}")
      req = http.request httpOptsForData(data), @handle
      req.on 'error', @error
      req.write(data)
      req.end()
    catch err
      @error(err)

module.exports = WitnessServer
