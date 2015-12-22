Path         = require("path")
rootDir      = Path.join("..", "..")
HistoryEntry = require(Path.join(rootDir, "src", "support", "history-entry"))

describe "HistoryEntry", ->
  room    = "jekyll"
  user    = "parkr"
  message = "Hi there!"
  time    = new Date()
  entry   = new HistoryEntry(room, user, message)

  describe "constructor", ->
    it "sets the room, name, message per the input", ->
      assert.equal room, entry.room
      assert.equal user, entry.user
      assert.equal message, entry.message

    it "sets the time, hours, and minutes automatically", ->
      assert.equal time.toUTCString(), entry.time.toUTCString()
      assert.equal time.getHours(), entry.hours
      assert.equal time.getMinutes(), entry.minutes

  describe "#queryString", ->
    it "encodes the room, message, and author", ->
      qs = entry.queryString()
      assert.include qs, "room=#{room}"
      assert.include qs, "message=#{encodeURIComponent(message)}"
      assert.include qs, "author=#{user}"

    it "encodes the time as a UTC string", ->
      qs = entry.queryString()
      assert.include qs, "time=#{encodeURIComponent(time.toUTCString())}"

    it "encodes the access token if it exists", ->
      qs = entry.queryString()
      assert.include qs, "access_token=&"

      process.env.HUBOT_LOG_SERVER_TOKEN = "foobar"
      qs = entry.queryString()
      assert.include qs, "access_token=foobar"

  describe "toString", ->
    it "returns a lovely message", ->
      str = entry.toString()
      timeUTC = time.toUTCString()
      assert.equal "parkr said 'Hi there!' at #{timeUTC} in jekyll", str
