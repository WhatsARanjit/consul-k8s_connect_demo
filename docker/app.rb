require 'sinatra'
require 'net/http'

set :bind, '0.0.0.0'
set :port, ENV['port']

get '/' do
  @dbhost = ENV['dbhost'] || 'localhost'
  dbport  = ENV['dbport'] || 8081
  dbpass  = ENV['dbpass'] || 'password123'
  uri     = URI(%(http://#{@dbhost}:#{dbport}/db?password=#{dbpass}))
  begin
    @dbname = Net::HTTP.get(uri)
  rescue StandardError
    @dbname = 'unreachable'
  end
  erb :web
end

get '/db' do
  Socket.gethostname
end
