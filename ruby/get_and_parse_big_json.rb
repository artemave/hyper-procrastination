require 'bundler'
Bundler.setup

require 'faraday'
require 'faraday_middleware'

url = "http://#{ENV.fetch('NGINX_HOST', 'localhost')}"

connection = Faraday.new url do |conn|
  conn.response :json, content_type: /\bjson$/
  conn.adapter Faraday.default_adapter
end

def do_work(connection)
  response = connection.get 'citylots.json'
  result = response.body['features'].reduce({}) do |acc, p|
    key = p['properties']['FROM_ST']

    acc[key] ||= 0
    acc[key] += 1

    acc
  end
  puts "Some data #{result.keys.size}"
end

start_time = Time.now

200.times.map do
  Thread.new { do_work(connection) }
end.each(&:join)

puts "Time spent: #{Time.now - start_time}"
