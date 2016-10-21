name             'treslek'
maintainer       'Michael Burns'
maintainer_email 'michael.burns@rackspace.com'
license          'Apache 2.0'
description      'Installs/Configures the Treslek IRC bot'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.2.0'

recipe           'treslek::default', 'Installs and configures Treslek'

depends          'nodejs'
depends          'redis'
depends          'runit'

supports         'ubuntu'
supports         'debian'
