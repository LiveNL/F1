#!/usr/bin/env ruby
require 'multi_json'
require 'pathname'
require_relative '../models/race'

def load(json)
  MultiJson.load File.open("./#{json}.json").read, symbolize_keys: true
end

grids = Pathname Dir.pwd + '/configs'
@cars_list = grids.children
circuits = load('circuits')
seed = Random.new_seed
rng = Random.new(seed)

File.open("crashes.json", 'w') { |file| file.write("{\"crashes\":[") }

#circuit = circuits[:circuits].find{|x| x[:country] == "Belgium"}
#Race.new(circuit_json: circuit, cars_json: cars, x: nil, rng: rng).start
#exit
def cars
  @cars_list.sample
end

circuits[:circuits].map.with_index do |circuit, i|
  puts "#{i}: #{circuit[:country]}"

  1000.times do |x|
    a = MultiJson.load cars.read, symbolize_keys: true
    Race.new(circuit_json: circuit, cars_json: a, x: x, rng: rng).start
  end
end

File.open("crashes.json", 'a+') { |file|
  a = file.read
  file.truncate(0)
  file.write("#{a.chop}]}")
}

crashes = MultiJson.load File.open("./crashes.json").read, symbolize_keys: true
c = crashes[:crashes].group_by{|x| x[:distance] - x[:brake_at] }.sort
d = crashes[:crashes].group_by{|x| x[:distance]}.sort
e = crashes[:crashes].group_by{|x| x[:speed] }.sort

c.map do |k,v|
  puts "#{k}, brake: #{v.first[:brake_at]} -- #{v.first[:circuit]}, crashes: #{v.count}"
end
