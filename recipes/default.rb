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

include_recipe 'redis'
include_recipe 'nodejs'
include_recipe 'runit'

group 'treslek' do
  action :create
end

user 'treslek' do
  comment 'Treslek IRC Bot'
  home '/usr/sbin'
  shell '/bin/false'
  system true
  action :create
end

directory node['treslek']['path'] do
  owner 'treslek'
  group 'treslek'
  recursive true
end

directory '/etc/treslek' do
  owner 'treslek'
  group 'treslek'
  recursive true
end

nodejs_npm 'treslek' do
  version node['treslek']['version']
  notifies :restart, 'service[treslek]', :delayed
end

## Plugins

remote_directory "#{node['treslek']['path']}/comics" do
  owner 'treslek'
  group 'treslek'
  overwrite false # merge with git repo's comics dir contents
end

cookbook_file 'nagios.js' do
  path "#{node['treslek']['path']}/plugins/nagios.js"
  owner 'treslek'
  group 'treslek'
  action :create
end

remote_directory 'treslek-gh-issue-search' do
  path "#{node['treslek']['path']}/plugins/treslek-gh-issue-search"
  owner 'treslek'
  group 'treslek'
  action :create
end

creds = Chef::EncryptedDataBagItem.load('passwords', 'github')

template "#{node['treslek']['path']}/plugins/treslek-gh-issue-search/config.json" do
  source 'treslek-gh-issue-search.json.erb'
  owner 'treslek'
  group 'treslek'
  mode 0o0644
  variables ({
    username: creds['username'],
    password: creds['password']
  })
end

template node['treslek']['config'] do
  owner 'treslek'
  group 'treslek'
  mode 0o0644
  variables ({
    redis_port: '6379',
    redis_host: '127.0.0.1',
    redis_prefix: 'treslek'
  })
  notifies :restart, 'service[treslek]'
end

runit_service 'treslek' do
  owner 'treslek'
  group 'treslek'
  # start_down node['treslek']['disable']
end

iptables_rule 'ports_irccat'
iptables_rule 'ports_webhook'
