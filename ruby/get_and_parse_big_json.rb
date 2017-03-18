require 'bundler'
Bundler.setup

require 'typhoeus'
require 'json'

URL = "http://#{ENV.fetch('NGINX_HOST', 'localhost')}/citylots.json"

class BM
  def initialize
    @store = Hash.new {|h,k| h[k] = 0}
  end

  def sample(key, time = nil)
    if time
      @store[key] += time
    else
      start = Time.now
      res = yield
      @store[key] += Time.now - start
      res
    end
  end

  def method_missing meth
    key = meth.to_s.sub(/total_/, '')
    @store[key.to_sym]
  end
end

$bm = BM.new

def process_data(response)
  $bm.sample :request, response.total_time.to_f / 1000

  data = $bm.sample :parse do
    JSON.parse(response.body)
  end

  result = $bm.sample :process do
    data['features'].reduce({}) do |acc, p|
      key = p['properties']['FROM_ST']

      acc[key] ||= 0
      acc[key] += 1

      acc
    end
  end

  puts "Some data #{result.keys.size}"
end

$bm.sample :overall do
  hydra = Typhoeus::Hydra.new
  200.times do
    request = Typhoeus::Request.new(URL)
    request.on_complete(&method(:process_data))
    hydra.queue(request)
  end
  hydra.run
end

File.open(Dir.pwd + '/results.json', 'w') do |f|
  f.write(JSON.dump(
    request: $bm.total_request.round,
    parse: $bm.total_parse.round,
    process: $bm.total_process.round,
    total: $bm.total_overall.round,
  ))
end

puts "Time spent: #{$bm.total_request.round(2)}s request, #{$bm.total_parse.round(2)}s parse, #{$bm.total_process.round(2)}s process, #{$bm.total_overall.round(2)}s total"
