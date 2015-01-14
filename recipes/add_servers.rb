#
# Cookbook Name:: haproxy
# Recipe:: add_servers
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

node['haproxy']['server_uri'].each do |server_uri|
  bash "add server" do
    cwd "/usr/local/bin"
    code <<-EEND
      ./addServer.sh "#{server_uri}" "#{node['haproxy']['bucket']}"
      ./buildConfig.sh
    EEND
  end
end
