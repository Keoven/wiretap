require 'rubygems'
require 'bundler/setup'

require 'sinatra'

set :port, ENV['PORT'].to_i

post '/wiretap/set-cassette' do
end
