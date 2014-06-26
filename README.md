hubot-stenographer
==================

Let Hubot write down all messages it hears on a [Witness][]-compliant server.

[Witness]: https://github.com/parkr/witness

### Installation

These instructions assume you've deployed Hubot to Heroku. Please make the
appropriate adjustments for other hosting solutions.

```bash
$ npm install --save hubot-stenographer
$ hk set HUBOT_LOG_SERVER_HOST="witness.yourdomain.com"
$ hk set HUBOT_LOG_SERVER_TOKEN="supersecrettoavoidspam"
$ vim external-scripts.json # add "hubot-stenographer" to the array
```

### Twilio Warnings

If you're into that sort of thing, you can utilize Twilio to text you when
the service you're logging to is down. Just add the following configuration
options:

- `HUBOT_TWILIO_SID` - your Twilio SID
- `HUBOT_TWILIO_AUTH_TOKEN` - your Twilio auth token
- `HUBOT_TWILIO_WARN_FROM` - your Twilio number (e.g. `+15551234567`)
- `HUBOT_TWILIO_WARN_TO` - the phone number to send the message to (same
  formatting as above)

Once all four of those are set, restart your app and look for `twilio:
enabled` in your logs.

### Usage

Once the script is enabled for your bot, you're good to go!

### Credit

Originally written by Jacob Ela (@wubr), then modified for IRC by
Matt Aimonetti (@mattetti). Completely rewritten by Parker Moore
(@parkr) to be a script purely for logging. Thanks to Matt & Jacob
for the inspiration!
