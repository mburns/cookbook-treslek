#
# Cookbook Name:: treslek
# Recipe:: default
#
# Copyright 2014, Michael Burns
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'iptables'
include_recipe 'redis'
include_recipe 'nodejs'
include_recipe 'runit'

group node['treslek']['user'] do
  action :create
end

user node['treslek']['user'] do
  comment 'Treslek IRC Bot'
  gid node['treslek']['user']
  shell '/bin/false'
  system true
  action :create
end

directory node['treslek']['path'] do
  owner node['treslek']['user']
  group node['treslek']['user']
  recursive true
end

directory '/etc/treslek' do
  owner node['treslek']['user']
  group node['treslek']['user']
  recursive true
end

nodejs_npm 'treslek' do
  version node['treslek']['version']
  notifies :restart, 'service[treslek]', :delayed
end

## Plugins

remote_directory "#{node['treslek']['path']}/comics" do
  owner node['treslek']['user']
  group node['treslek']['user']
  overwrite false # merge with git repo's comics dir contents
end

cookbook_file 'nagios.js' do
  path "#{node['treslek']['path']}/plugins/nagios.js"
  owner node['treslek']['user']
  group node['treslek']['user']
  action :create
end

remote_directory 'treslek-gh-issue-search' do
  path "#{node['treslek']['path']}/plugins/treslek-gh-issue-search"
  owner node['treslek']['user']
  group node['treslek']['user']
  action :create
end

creds = Chef::EncryptedDataBagItem.load('passwords', 'github')

template "#{node['treslek']['path']}/plugins/treslek-gh-issue-search/config.json" do
  source 'treslek-gh-issue-search.json.erb'
  owner node['treslek']['user']
  group node['treslek']['user']
  mode 0o0644
  variables ({
    username: creds['username'],
    password: creds['password']
  })
end

template node['treslek']['config'] do
  owner node['treslek']['user']
  group node['treslek']['user']
  mode 0o0644
  variables ({
    redis_port: '6379',
    redis_host: '127.0.0.1',
    redis_prefix: 'treslek'
  })
  notifies :restart, 'service[treslek]'
end

runit_service 'treslek' do
  owner node['treslek']['runit']['user']
  group node['treslek']['runit']['user']
  # start_down node['treslek']['disable']
end

iptables_rule 'ports_irccat'
iptables_rule 'ports_webhook'
