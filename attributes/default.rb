default['treslek']['cookbook'] = 'treslek'
default['treslek']['disable'] = 'false'

default['treslek']['user'] = 'treslek'

# install path
default['treslek']['path'] = '/usr/local/treslek'
default['treslek']['bin'] = "#{node['treslek']['path']}/bin/treslek.js"
default['treslek']['config'] = '/etc/treslek/conf.json'

# git code repository
default['treslek']['repo'] = 'https://github.com/jirwin/treslek'

default['treslek']['version'] = 'v0.11.0'
default['treslek']['nick'] = 'roarbot'
default['treslek']['host'] = 'irc.rackspace.com'

default['treslek']['ignored'] = %w(doslek url standupbot dreadnotbot-prod dreadnotbot-stage)
default['treslek']['admins'] = %w(jirwin)

# irc options
default['treslek']['irc']['port'] = 6697
default['treslek']['irc']['channels'] = %w(#treslek)
default['treslek']['irc']['username'] = 'treslekbot'
default['treslek']['irc']['realname'] = 'treslek'
default['treslek']['irc']['autoconnect'] = false
default['treslek']['irc']['floodprotection'] = true

default['treslek']['irc']['sasl'] = false
default['treslek']['irc']['secure'] = true
default['treslek']['irc']['password'] = ''

# topics
default['treslek']['topics']['separator'] = '::'
default['treslek']['topics']['prefixes'] = {
  '#trelsek' => 'Treslek'
}

# webhooks
default['treslek']['webhooks']['host'] = '0.0.0.0'
default['treslek']['webhooks']['port'] = 1304
default['treslek']['webhooks']['channel'] = 'webhooks'

# plugins
default['treslek']['enabledPlugins'] = %w(s help topic about nagios karma reminder treslek-memo slogan sys isup treslek-vote treslek-spotify treslek-random seen treslek-url)
default['treslek']['plugins'] = %w(treslek-memo treslek-vote treslek-spotify treslek-random treslek-url)
default['treslek']['commandPrefix'] = '!'

# runit config
default['treslek']['keep_logs'] = 20
default['treslek']['syslog_sink'] = '127.0.0.1:8001'
