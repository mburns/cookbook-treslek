name             'treslek'
maintainer       'Michael Burns'
maintainer_email 'michael@mirwin.net'
license          'Apache-2.0'
description      'Installs/Configures the Treslek IRC bot'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.4.5'
chef_version     '>= 12.0' if respond_to?(:chef_version)

source_url 'https://github.com/mburns/cookbook-treslek' if respond_to?(:source_url)
issues_url 'https://github.com/mburns/cookbook-treslek/issues' if respond_to?(:issues_url)

recipe           'treslek::default', 'Installs and configures Treslek'

depends          'iptables'
depends          'nodejs'
depends          'redis'
depends          'runit'

supports         'ubuntu'
supports         'debian'
