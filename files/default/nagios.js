var net = require('net');
var crypto = require('crypto');
var util = require('util');

var async = require('async');
var redis = require('redis');
var colors = require('irc-colors');
var sprintf = require('sprintf').sprintf;
var log = require('logmagic').local('treslek-nagios');

var SUPPRESSED_STATE = 'maas-nagios:suppression:suppressed';
var DEDUPE_LOCK = 'maas-nagios:dedupe';
var ALERT_OBJ = 'maas-nagios:alerts';
var SUPPRESSION_COUNTER = 'maas-nagios:suppression:counter';
var SUPPRESSION_TIME = 'maas-nagios:suppression:time';

var STATE_COLORS = {
  'OK': colors.green.bold,
  'CRIT': colors.red,
  'CRITICAL': colors.red,
  'WARN': colors.yellow,
  'WARNING': colors.yellow
};

var DEDUPE_WINDOW = 30 * 1000; // x seconds in ms.

var SUPPRESSION_ANNOUNCE_INTERVAL = 5 * 60 * 1000 // x minutes in ms


/**
 * Opens a socket and listens for input from nagios.
 *
 */
var Nagios = function() {
  this.auto = ['listen'];
  this.commands = ['suppress', 'unsuppress'];
  this.unload = ['destroy'];
  this.port = 12345;
  this.server = null;
  this.redisClient = null;
  this.suppressionAnnounceTimer = null;
  this.regions = {
    LON3: true,
    DFW1: true,
    ORD1: true
  };
};


Nagios.prototype.outputAlert = function(bot, alertId, callback) {
  var self = this;

  async.auto({
    alert: function(callback) {
      self.redisClient.hgetall(ALERT_OBJ + ':' + alertId, callback);
    },

    regions: function(callback) {
      self.redisClient.smembers(DEDUPE_LOCK + ':' + alertId, callback);
    },

    cleanupAlert: ['alert', function(callback) {
      self.redisClient.del(ALERT_OBJ + ':' + alertId, callback);
    }],

    cleanupRegions: ['regions', function(callback) {
      self.redisClient.del(DEDUPE_LOCK + ':' + alertId, callback);
    }],

    getSuppressedState: ['cleanupAlert', 'cleanupRegions', function(callback) {
      self.redisClient.get(SUPPRESSED_STATE, callback);
    }],
  }, function(err, results) {
    var msg = '';

    if (err) {
      callback(err);
      return;
    }

    if (!results.alert) {
      log.warn('No alert found. Ignoring', {alertId: alertId});
      callback();
      return;
    }

    if (!parseInt(results.getSuppressedState, 10)) {
      msg = self._formatNagiosAlert(results.regions, results.alert);
      bot.say(results.alert.channel, msg);
    } else {
      self.redisClient.incr(SUPPRESSION_COUNTER, function(err, reply) {
        log.info(reply + ' alerts suppressed.');
      });
    }
    callback();
  });
};


Nagios.prototype._dedupeAlert = function(bot, obj) {
  var self = this,
      hash = crypto.createHash('sha1'),
      alertId = '',
      now = Date.now();

  hash.update(sprintf('%s %s %s %s %s', obj.state, obj.host, obj.check, obj.msg, now - (now % DEDUPE_WINDOW)));
  alertId = hash.digest('hex');

  async.auto({
    update: function(callback) {
      self.redisClient.hmset(ALERT_OBJ + ':' + alertId, obj, callback);
    },

    updateRegions: function(callback) {
      self.redisClient.sadd(DEDUPE_LOCK + ':' + alertId, obj.region, callback);
    },

    getRegionCount: ['updateRegions', function(callback) {
      self.redisClient.scard(DEDUPE_LOCK + ':' + alertId, function(err, reply) {
        callback(err, parseInt(reply, 10));
      });
    }],

    setTimer: ['getRegionCount', function(callback, results) {
      if (results.getRegionCount !== Object.keys(self.regions).length) {
        setTimeout(self.outputAlert.bind(self, bot, alertId, callback), DEDUPE_WINDOW);
        return;
      }
      callback();
    }]

  }, function(err, results) {
  });
};


Nagios.prototype.destroy = function(callback) {
  var self = this;

  clearTimeout(this.suppressionAnnounceTimer);

  if (this.server) {
    this.server.close(function() {
      self.server = null;
      callback();
    });
  } else {
    process.nextTick(callback);
  }
};


Nagios.prototype.suppress = function(bot, to, from, msg, callback) {
  var self = this;

  async.auto({
    setState: function(callback) {
      self.redisClient.set(SUPPRESSED_STATE, 1, callback);
    },

    setCounter: function(callback) {
      self.redisClient.set(SUPPRESSION_COUNTER, 0, callback);
    },

    setTime: function(callback) {
      var time = new Date();

      self.redisClient.set(SUPPRESSION_TIME,
                           util.format('%s:%s %s/%s/%s',
                                       time.getHours(),
                                       ('0' + time.getMinutes()).slice(-2),
                                       time.getDate(),
                                       time.getMonth() + 1,
                                       time.getFullYear()), callback);
    }
  }, function() {
    self.announceSuppressions(bot);
    callback();
  });
};


Nagios.prototype.unsuppress = function(bot, to, from, msg, callback) {
  var self = this;

  this.redisClient.set(SUPPRESSED_STATE, 0, function() {
    clearTimeout(self.suppressionAnnounceTimer);
    self.getSuppressionAnnouncement(function(err, msg) {
      bot.broadcast(msg);
    });
  });
};


/**
 * Given a line from nagios, return an object.
 */
Nagios.prototype._parseNagiosAlert = function(text) {
  var obj = {},
      msgStart = 0,
      ii = msgStart;

  obj.channel = text[0];
  obj.region = text[1];
  obj.source = text[2];
  obj.action = text[3];
  obj.host = text[4];
  obj.check = text[5];

  if (text[7] === 'GRAPHITE_THRESHOLD') {
    msgStart = 10;
    obj.state = text[8];
  } else {
    msgStart = 8;
    obj.state = text[7];
  }

  obj.msg = '';
  for(ii = msgStart; ii < text.length; ii++) {
    obj.msg += text[ii] + ' ';
  }

  return obj;
};


Nagios.prototype._formatNagiosAlert = function(regions, obj) {
  if (STATE_COLORS[obj.state]) {
    obj.state = STATE_COLORS[obj.state](obj.state);
  }

  return sprintf("[%s] %s %s %s %s",
                 regions.join(' '),
                 obj.state,
                 obj.host,
                 obj.check,
                 obj.msg);
};


Nagios.prototype.getSuppressionAnnouncement = function(callback) {
  var self = this;

  async.auto({
    getCount: function(callback) {
      self.redisClient.get(SUPPRESSION_COUNTER, callback);
    },

    getTime: function(callback) {
      self.redisClient.get(SUPPRESSION_TIME, callback);
    },

    output: ['getCount', 'getTime', function(callback, results) {
      var count = results.getCount ? results.getCount : 0;

      callback(null, results.getCount + ' nagios alerts suppressed since ' + results.getTime);
    }]
  }, function(err, results) {
    if (err) {
      log.error('error getting suppression announcement');
    }

    callback(null, results.output);
  });
};


Nagios.prototype.announceSuppressions = function(bot) {
  var self = this;

  clearTimeout(this.suppressionAnnounceTimer);
  this.getSuppressionAnnouncement(function(err, msg) {
    bot.broadcast(msg);
    self.suppressionAnnounceTimer = setTimeout(self.announceSuppressions.bind(self, bot),
                                               SUPPRESSION_ANNOUNCE_INTERVAL);
  });
};


Nagios.prototype.listen = function(bot) {
  var self = this;

  this.redisClient = bot.getRedisClient();

  this.redisClient.get(SUPPRESSED_STATE, function(err, state) {
    if (parseInt(state, 10)) {
      self.announceSuppressions(bot);
    }
  });

  if (!this.server) {
    this.server = net.createServer();

    this.server.on('connection', function(c) {
      c.on('data', function(buf) {
        var text = buf.toString().replace('\n', '').split(' '),
            textObj = {};

        if (!self.regions[text[1]] && text[2] !== 'Nagios') {
          return;
        }

        textObj = self._parseNagiosAlert(text);

        self._dedupeAlert(bot, textObj);
      });
    });

    this.server.listen(this.port, function() {
      log.info('listening on ' + self.port + ' for nagios');
    });
  }
};

exports.Plugin = Nagios;
