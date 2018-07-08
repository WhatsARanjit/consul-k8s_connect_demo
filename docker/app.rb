require 'sinatra'
require 'net/http'

set :bind, '0.0.0.0'
set :port, ENV['port']

get '/' do
  apihost = ENV['apihost'] || 'localhost'
  uri     = URI(%(http://#{apihost}:8081/api))
  begin
    @apiname = Net::HTTP.get(uri)
  rescue StandardError
    @apiname = 'unreachable'
  end
  erb :web
end

get '/api' do
  dbhost = ENV['dbhost'] || 'localhost'
  dbpass = ENV['dbpass'] || 'password123'
  uri    = URI(%(http://#{dbhost}:8082/db?password=#{dbpass}))
  begin
    @dbname = Net::HTTP.get(uri)
  rescue StandardError
    @dbname = 'unreachable'
  end
  erb :api
end

get '/db' do
  Socket.gethostname
end
