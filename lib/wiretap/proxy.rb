require_relative 'tunnel'
require_relative 'vcr'
require 'sinatra'
require 'json'

set :port, ENV['LISTEN_PORT'].to_i

post '/*' do
  forward_request(:post, request, params)
end

get '/*' do
  forward_request(:get, request, params)
end

put '/*' do
  forward_request(:put, request, params)
end

delete '/*' do
  forward_request(:delete, request, params)
end

def get_port
  return @port if @port
  if ENV['TUNNEL_PORT'] && ENV['TUNNEL_USERNAME']
    @port = ENV['TUNNEL_PORT'].to_i
  else
    @port = ENV['REMOTE_PORT'].to_i
  end
end

def custom_headers
  @custom_headers ||= JSON.parse(ENV['CUSTOM_HEADERS_MAPPING'])
end

def forward_request(http_method, request, params)
  excon = Excon.new("http://localhost:#{get_port}/")
  additional_headers = Hash[request.env.map do |key, value|
    if custom_headers.keys.include?(key)
      [custom_headers[key], value]
    end
  end.compact]
  query_parameters = params.reject do |key|
    ['splat', 'captures'].include?(key) ||
    (ENV['IGNORE_CACHING_STRING'] && key.match(/#{ENV['IGNORE_CACHING_STRING']}/))
  end
  remote_response = excon.request(
    method: http_method,
    path: request.path,
    body: request.body,
    query: query_parameters,
    headers: {
      'Content-Type' => request.content_type
    }.merge!(additional_headers)
  )
  response.headers.merge!(remote_response.headers)
  response.headers.delete('Transfer-Encoding')
  response.status = remote_response.status
  response.body.push(remote_response.body)
end
