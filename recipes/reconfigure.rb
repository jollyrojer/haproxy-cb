#
# Cookbook Name:: haproxy
# Recipe:: reconfigure 
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bash "delete servers" do
  cwd "/usr/local/bin"
  code <<-EEND
    ./delServers.sh "#{node['haproxy']['bucket']}"
 EEND
end

node['haproxy']['server_uri'].each do |server_uri|
  bash "add server" do
    cwd "/usr/local/bin"
    code <<-EEND
      ./addServer.sh "#{server_uri}" "#{node['haproxy']['bucket']}"
    EEND
  end
end

bash "update config" do
  cwd "/usr/local/bin"
  code <<-EEND
    ./buildConfig.sh
 EEND
end
