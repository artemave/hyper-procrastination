require 'bundler'
Bundler.setup

require 'json'

HOST = ENV.fetch('NGINX_HOST', 'localhost')

connection = Net::HTTP.start(HOST, '80')
request = Net::HTTP::Get.new("http://#{HOST}/citylots.json")

def do_work(connection, request)
  response = connection.request(request)
  json = JSON.parse(response.body)
  result = json['features'].reduce({}) do |acc, p|
    key = p['properties']['FROM_ST']

    acc[key] ||= 0
    acc[key] += 1

    acc
  end
  puts "Some data #{result.keys.size}"
end

start_time = Time.now

200.times do
  do_work(connection, request)
end

puts "Time spent: #{Time.now - start_time}"
