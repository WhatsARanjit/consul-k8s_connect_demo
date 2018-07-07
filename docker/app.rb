require 'sinatra'
require 'net/http'

set :bind, '0.0.0.0'
set :port, ENV['port']

get '/web' do
  dbhost = ENV['dbhost'] || 'localhost'
  dbport = ENV['dbport'] || 8081
  dbpass = ENV['dbpass'] || 'password123'
  uri    = URI(%(http://#{dbhost}:#{dbport}/db?password=#{dbpass}))
  begin
    dbname = Net::HTTP.get(uri)
  rescue StandardError
    dbname = 'unreachable'
  end
  res = [
    '<h2>',
    %(Web machine: #{Socket.gethostname}),
    dbname,
    '</h2>'
  ]
  res.join('<br />')
end

get '/db' do
  res = [
    '<h3>',
    %(DB machine: #{Socket.gethostname}),
    '</h3>'
  ]
  res.join('<br />')
end
