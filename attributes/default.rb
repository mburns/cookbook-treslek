default.treslek.cookbook = "treslek"

# unix user
default.treslek.uid = 805
default.treslek.gid = 805

# install path
default.treslek.path     = "/usr/local/treslek"

# git code repository
default.treslek.repo     = "https://github.com/jirwin/treslek"

default.treslek.nick     = 'treslek'
default.treslek.host     = 'localhost'

default.treslek.ignored  = %w(doslek url standupbot dreadnotbot-prod dreadnotbot-stage)
default.treslek.admins   = %w(jirwin)

# irc options
default.treslek.irc.port = 6667
default.treslek.irc.channels = %w(#treslek)
default.treslek.irc.username = 'treslekbot'
default.treslek.irc.realname = 'treslekbot'
default.treslek.irc.autoconnect = false
default.treslek.irc.floodprotection = true

#topics
default.treslek.topics.separator = '::'
default.treslek.topics.prefixes = {
  '#trelsek': 'Treslek'
}
