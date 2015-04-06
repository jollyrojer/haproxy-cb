#
# Cookbook Name:: haproxy
# Recipe:: add_servers
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
if node['haproxy']['bucket_proto'].end_with?("://")
 bucket_proto = node['haproxy']['bucket_proto']
else
 bucket_proto = "#{node['haproxy']['bucket_proto']}" + "://"
end
node.set['haproxy']['entry_urls'] = []
node['haproxy']['server_uri'].map {|x| x=x+"/" if !x.include?("/"); x}.each do |server_uri|
  uri = server_uri.split("/", 2)[0]
  path = server_uri.split("/", 2)[1] 
  haproxy_bucket = "#{bucket_proto}#{node['haproxy']['bucket_type']}:#{node['haproxy']['bucket_port']}/#{path}"
  node.set['haproxy']['entry_urls'] = node.haproxy.entry_urls | [ "#{bucket_proto}#{node['haproxy']['host']}:#{node['haproxy']['bucket_port']}/#{path}" ]
  bash "add server" do
    cwd "/usr/local/bin"
    code <<-EEND
      ./addServer.sh "#{uri}" "#{haproxy_bucket}"
    EEND
  end
end
bash "update config" do
  cwd "/usr/local/bin"
  code <<-EEND
    ./buildConfig.sh
 EEND
end
