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

### Usage

Once the script is enabled for your bot, you're good to go!

### Credit

Originally written by Jacob Ela (@wubr), then modified for IRC by
Matt Aimonetti (@mattetti). Completely rewritten by Parker Moore
(@parkr) to be a script purely for logging. Thanks to Matt & Jacob
for the inspiration!
