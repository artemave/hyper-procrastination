require 'bundler'
Bundler.setup

require 'typhoeus'
require 'json'

URL = "http://#{ENV.fetch('NGINX_HOST', 'localhost')}/citylots.json"

def process_data(response)
  data = JSON.parse(response.body)
  result = data['features'].reduce({}) do |acc, p|
    key = p['properties']['FROM_ST']

    acc[key] ||= 0
    acc[key] += 1

    acc
  end
  puts "Some data #{result.keys.size}"
end

start_time = Time.now

hydra = Typhoeus::Hydra.new
200.times do
  request = Typhoeus::Request.new(URL)
  request.on_complete(&method(:process_data))
  hydra.queue(request)
end
hydra.run

puts "Time spent: #{Time.now - start_time}"
