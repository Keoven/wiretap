require 'excon'
require 'vcr'

cassette_directory = File.expand_path(File.join('..', '..', '..', 'tmp', 'cassettes'), __FILE__)
VCR.configure do |c|
  c.cassette_library_dir = cassette_directory
  c.hook_into :excon
  c.default_cassette_options = {
    match_requests_on: [:method, :host, :path, :body, :headers]
  }
  c.around_http_request(lambda {|r| r.uri =~ /.*/}) do |request|
    VCR.use_cassette('default', :record => :new_episodes, &request)
  end
end
