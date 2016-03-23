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
  gid node['treslek']['gid']
  action :create
end

user node['treslek']['user'] do
  comment 'Treslek IRC Bot'
  uid node['treslek']['uid']
  gid node['treslek']['gid']
  home '/usr/sbin'
  shell '/bin/false'
  system true
  action :create
end

direcotry node['treslek']['path'] do
  uid node['treslek']['uid']
  gid node['treslek']['gid']
  recursive true
end

execute 'npm-install-treslek' do
  cwd node['treslek']['path']
  command 'npm install --production'
  action :nothing
end

git node['treslek']['path'] do
  repository node['treslek']['repo']
  revision node['treslek']['tag']
  user node['treslek']['uid']
  group node['treslek']['gid']
  action :sync
  notifies :restart, 'service[treslek]', :delayed
end

remote_directory "#{node['treslek']['path']}/comics" do
  uid node['treslek']['uid']
  gid node['treslek']['gid']
  overwrite false #merge with git repo's comics dir contents
 end

cookbook_file 'nagios.js' do
  path "#{node['treslek']['path']}/plugins/nagios.js"
  owner node[:treslek][:uid]
  group node[:treslek][:gid]
  action :create
end

template node['treslek']['config'] do
  uid node['treslek']['uid']
  gid node['treslek']['gid']
  mode 00644
  variables ({
    :redis_port => '6379',
    :redis_host => '127.0.0.1',
    :redis_prefix => 'treslek'
  })
  notifies :restart, 'service[treslek]', :delayed
end

runit_service 'treslek' do
  log_owner 'daemon'
  log_group 'daemon'
end

iptables_rule "ports_irccat"
iptables_rule "ports_webhook"
