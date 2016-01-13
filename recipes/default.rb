#
# Cookbook Name:: treslek
# Recipe:: default
#
# Copyright 2014, Michael Burns
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "redis"
include_recipe "runit"

group "treslek" do
  gid node[:treslek][:gid]
  action :create
end

user "treslek" do
  comment "Treslek IRC Bot"
  uid node[:treslek][:uid]
  gid node[:treslek][:gid]
  home "/usr/sbin"
  shell "/bin/false"
  system true
  action :create
end

execute "npm-install-treslek" do
  cwd node[:treslek][:path]
  command "npm install --production"
  action :nothing
end

git node[:treslek][:path] do
  repository node[:treslek][:repo]
  action :sync
  notifies :run, "execute[npm-install-treslek]"
end

remote_directory "${node[:treslek][:path]}/comics" do
  uid node[:treslek][:uid]
  gid node[:treslek][:gid]
  overwrite false #merge with git repo's comics dir contents
 end

directory "/etc/treslek" do
  uid node[:treslek][:uid]
  gid node[:treslek][:gid]
  recursive true
end

template "/etc/treslek/config.js" do
  uid node[:treslek][:uid]
  gid node[:treslek][:gid]
  mode 00644
  variables ({
    :redis_port => '6379',
    :redis_host => '127.0.0.1',
    :redis_prefix => 'treslek'
  })
  notifies :restart, "service[treslek]"
end

runit_service "treslek" do
  log_owner "treslek"
  log_group "treslek"
  down false
end
