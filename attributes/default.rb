default['treslek'].cookbook = 'treslek'

# unix user
default['treslek']['uid'] = 805
default['treslek']['gid'] = 805
default['treslek']['user']     = 'treslek'

# paths
default['treslek']['path']     = '/usr/local/treslek'
default['treslek']['bin']      = "#{node['treslek']['path']}/bin/treslek.js"
default['treslek']['config']   = '/etc/treslek/conf.json'

# git code repository
default['treslek']['repo']     = 'https://github.com/rackerlabs/treslek'
default['treslek']['tag']      = '2252d98325f4d3e85108171a2250b11deb0ae81d'

default['treslek']['nick']     = 'treslek'
default['treslek']['host']     = 'localhost'

default['treslek']['ignored']  = %w(doslek url)
default['treslek']['admins']   = %w(jirwin)

# irc options
default['treslek']['irc']['port'] = 6667
default['treslek']['irc']['channels'] = %w(#treslek)
default['treslek']['irc']['username'] = 'treslekbot'
default['treslek']['irc']['realname'] = 'treslekbot'
default['treslek']['irc']['autoconnect'] = false
default['treslek']['irc']['floodprotection'] = true
default['treslek']['irc']['sasl'] = false
default['treslek']['irc']['secure'] = false
default['treslek']['irc']['password'] = ''

#topics
default['treslek']['topics']['separator'] = '::'
default['treslek']['topics']['prefixes'] = {
  '#trelsek' => 'Treslek'
}

#webhooks
default['treslek']['webhooks']['host'] = '0.0.0.0'
default['treslek']['webhooks']['port'] = 1304
default['treslek']['webhooks']['channel'] = 'webhooks'

#plugins
default['treslek']['enabledPlugins'] = %w(s help topic about nagios karma reminder treslek-memo slogan sys isup treslek-vote treslek-spotify treslek-random seen treslek-url)
default['treslek']['plugins'] = %w(treslek-memo treslek-vote treslek-spotify treslek-random treslek-url)
default['treslek']['commandPrefix'] = '!'

#runit config
default['treslek']['keep_logs'] = 20
default['treslek']['syslog_sink'] = '127.0.0.1:8001'
