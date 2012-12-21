require 'rubygems'
require 'bundler/setup'

remote_host = ENV['REMOTE_HOST']
tunnel_port = ENV['TUNNEL_PORT']
remote_port = ENV['REMOTE_PORT']
tunnel_username = ENV['TUNNEL_USERNAME']

if ENV['TUNNEL_PORT'] && ENV['TUNNEL_USERNAME']
  require 'net/ssh/gateway'
  gateway = Net::SSH::Gateway.new(remote_host, tunnel_username)
  gateway.open(remote_host, remote_port, tunnel_port)
  at_exit do
    gateway.shutdown!
  end
end
