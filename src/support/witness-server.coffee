# Description:
#   Send messages to Gossip/Witness server.
#
# Author:
#   Parker Moore (@parkr)

class WitnessServer
  constructor: (@host, @port, @token, @err) ->
    @port  = parseInt(@port)
    @proto = if @port == 443 then 'https' else 'http'
    @http  = require(@proto)
    @logger = console

  isEnabled: ->
    @token? and @host? and @token != "" and @host != ""

  log: (message) ->
    @logger.log("stenog:", message)

  httpOpts: (data) ->
    {
      protocol: "#{@proto}:",
      host:     @host,
      port:     @port,
      path:     "/api/messages/log",
      method:   "POST",
      headers:
        'Content-Type':   "application/x-www-form-urlencoded",
        'Content-Length': data.length
    }

  handle: (res) ->
    code = res.statusCode
    @log("Handling a #{code} from the gossip server.")
    @err(null, code) if code < 200 or code > 299
    res.setEncoding('utf8')
    res.on 'data', (chunk) ->
      console.log("Response: #{chunk}")

  handler: (callback) ->
    (res) ->
      @handle(res)
      res.on 'end', callback if callback?

  send: (event, callback) ->
    errhandler = @err
    @log "Sending message to #{@host}:#{@port}..."
    data = event.queryString()
    try
      @log("Logging that #{event.toString()}")
      req = @http.request @httpOpts(data), @handler(callback).bind(this)
      req.on 'error', (err) ->
        errhandler(err, -1, callback)
      req.write(data)
      req.end()
    catch err
      @err(err, -1, callback)

module.exports = WitnessServer
