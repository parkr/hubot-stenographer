nock = require('nock')
chai = require('chai')
Path          = require("path")
rootDir       = Path.join("..", "..")
HistoryEntry  = require(Path.join(rootDir, "src", "support", "history-entry"))
WitnessServer = require(Path.join(rootDir, "src", "support", "witness-server"))

nock.disableNetConnect()

describe "Witness Server", ->
  host   = "localhost"
  port   = "8080"
  token  = "abc123"
  error  = (err, code, callback) ->
    if err instanceof chai.AssertionError
      callback(err)
      throw err
    else
      logger.log(err, code)
  server = null
  logger = null

  beforeEach ->
    server = new WitnessServer(host, port, token, error)
    logger =
      messages: []
      log: (msgs...) ->
        @messages.push(msgs.join(' '))
    server.logger = logger

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
      assert.deepEqual opts.headers,
        'Content-Type': "application/x-www-form-urlencoded",
        'Content-Length': 8

  describe "handle", ->
    fakeRes = null

    beforeEach ->
      fakeRes =
        statusCode: 201,
        setEncoding: (enc) ->
          server.log "encoding set to: #{enc}"
        handlers: {},
        on: (event, handler) ->
          @handlers[event] = handler


    it "adds a data handler", ->
      server.handle(fakeRes)
      assert.isFunction fakeRes.handlers['data']

    it "logs the code", ->
      server.handle(fakeRes)
      assert.equal 2, logger.messages.length
      assert.include logger.messages,
        "stenog: Handling a 201 from the gossip server."

    it "fires the error code if bad status code", ->
      fakeRes.statusCode = 502
      server.handle(fakeRes)
      # From @log call
      assert.include logger.messages,
        "stenog: Handling a 502 from the gossip server."
      # From our error handler
      assert.include logger.messages, " 502"

    it "sets the encoding to utf8", ->
      server.handle(fakeRes)
      assert.equal "stenog: encoding set to: utf8", logger.messages[1]

  describe "send", ->
    room  = "jekyll"
    user  = "parkr"
    msg   = "Hi, there!"
    event = new HistoryEntry(room, user, msg)

    stubReq = (handler) ->
      nock("http://#{host}:#{port}")
        .post('/api/messages/log')

    it "acts normally with a happy reply", (done) ->
      nockReq = stubReq().reply(201)
      server.send event, (err) ->
        nockReq.done()
        assert.include logger.messages,
          "stenog: Sending message to localhost:8080..."
        assert.include logger.messages,
          "stenog: Handling a 201 from the gossip server."
        done()

    it "sends handles errors", (done) ->
      nockReq = stubReq().reply(502)
      server.send event, ->
        nockReq.done()
        assert.include logger.messages,
          "stenog: Handling a 502 from the gossip server."
        done()
