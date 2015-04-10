#
# Cookbook Name:: haproxy
# Recipe:: reconfigure 
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
haproxy_buckets = [ "http://#{node['haproxy']['bucket_type']}:80/", "https://#{node['haproxy']['bucket_type']}:443/" ]
ssl_cert="#{Chef::Config[:file_cache_path]}/cert.pem"
if ( !node['haproxy']['ssl_cert'].nil? )
  if "#{node['haproxy']['ssl_cert']}".match("^(http|ftp)")
    remote_file ssl_cert do
      source "#{node['haproxy']['ssl_cert']}"
    end
  else
    file ssl_cert do
      content node['haproxy']['ssl_cert']
      mode 00644
      owner "root"
      group "root"
      action :create
    end
  end
else
  ssl_cert=""
end
haproxy_buckets.each do |bucket|

bash "delete servers" do
  cwd "/usr/local/bin"
  code <<-EEND
    ./delServers.sh "#{bucket}"
  EEND
end

node.set['haproxy']['entry_urls'] = [] 
node['haproxy']['server_uri'].map {|x| x=x+"/" if !x.include?("/"); x.gsub(/^http:\/\//, '')}.each do |server_uri|
  uri = server_uri.split("/", 2)[0]
  host = node.cloud.public_hostname rescue node.ipaddress
  path = server_uri.split("/", 2)[1]
  node.set['haproxy']['entry_urls'] = node.haproxy.entry_urls | [ "http://#{host}/#{path}" ] 
  bash "add server" do
    cwd "/usr/local/bin"
    code <<-EEND
      ./addServer.sh "#{uri}" "#{bucket}" "#{ssl_cert}"
    EEND
  end
end

bash "update config" do
  cwd "/usr/local/bin"
  code <<-EEND
    ./buildConfig.sh
 EEND
end
end
