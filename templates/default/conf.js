exports.conf = {
  nick: "<%= node['treslek']['nick'] %>",
  host: "<%= node['treslek']['host'] %>",
  ircOptions: {
    port: <%= node['treslek']['irc']['port'] %>,
    channels: <%= node['treslek']['irc']['channels'] %>,
    userName: "<%= node['treslek']['irc']['username'] %>",
    realName: "<%= node['treslek']['irc']['realname'] %>",
    autoConnect: <%= node['treslek']['irc']['autoconnect'] %>,
    floodProtection: <%= node['treslek']['irc']['floodprotection'] %>,
    floodProtectionDelay: 100
  },
  ignored: <%= node['treslek']['ignored'] %>,
  redis: {
    host: "<%= @redis_host %>",
    port: "<%= @redis_port %>",
    prefix: "<%= @redis_prefix %>"
  },
  topics: {
    separator: "<%= node['treslek']['topics']['separator'] %>",
    prefixes: {
      '#treslek': 'Treslek'
    }
  },
  admins: <%= node['treslek']['admins'] %>,
  plugins_dir: "<%= node['treslek']['path'] %>/plugins"
}s