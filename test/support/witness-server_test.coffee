WitnessServer = require(require("path").join("..", "..", "src", "support", "witness-server"))

describe "Witness Server", ->
  host   = "localhost"
  port   = "8080"
  token  = "abc123"
  error  = (err, code) -> @logger.log(err, code)
  server = new WitnessServer(host, port, token, error)
  logger =
    messages: []
    log: (msgs...) ->
      @messages.push(msgs.join(' '))

  describe "constructor", ->
    it "sets host, port, token, and error handler", ->
      assert.equal host, server.host
      assert.equal port, server.port
      assert.equal token, server.token
      assert.isNumber server.port
      assert.isFunction server.err

    it "requires the http module if non-443 port", ->
      assert.equal require("http"), server.http

    it "requires the http module if non-443 port", ->
      httpsServer = new WitnessServer(host, 443, token, error)
      assert.equal require("https"), httpsServer.http

  describe "isEnabled", ->
    it "returns false if no token", ->
      badServer = new WitnessServer(host, port, "", error)
      assert.isFalse badServer.isEnabled()

    it "returns false if no host", ->
      badServer = new WitnessServer("", port, token, error)
      assert.isFalse badServer.isEnabled()

    it "returns false if no host and no token", ->
      badServer = new WitnessServer("", port, "", error)
      assert.isFalse badServer.isEnabled()

    it "returns true if a token and host is present", ->
      assert.ok server.isEnabled()

  describe "log", ->
    server.logger = logger
    it "should work", ->
      server.log("hi")
      assert.equal "stenog: hi", server.logger.messages[0]

  describe "httpOpts", ->
    it "returns a hash with the proper content-type and -length headers", ->
      opts = server.httpOpts("hi=there")
      assert.equal opts.host, server.host
      assert.equal opts.port, server.port
      assert.equal opts.path, "/api/messages/log"
      assert.equal opts.method, "POST"
      assert.equal opts.headers['Content-Type'], "application/x-www-form-urlencoded"
      assert.equal opts.headers['Content-Length'], 8
