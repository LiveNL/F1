#!/usr/bin/env ruby
require 'multi_json'
require_relative '../models/race'

def load(json)
  MultiJson.load File.open("./configs/#{json}.json").read, symbolize_keys: true
end

cars = load('cars')
circuits = load('circuits')
seed = Random.new_seed
rng = Random.new(seed)

# circuit = circuits[:circuits].find{|x| x[:country] == "Belgium"}
# Race.new(circuit_json: circuit, cars_json: cars, x: nil, rng: rng).start
# exit

File.open("crashes.json", 'w') { |file| file.write("{\"crashes\":[") }

circuits[:circuits].map do |circuit|
  puts "#CIRCUIT: #{circuit[:country]}"

  100.times do |x|
    Race.new(circuit_json: circuit, cars_json: cars, x: x, rng: rng).start
  end
end

File.open("crashes.json", 'a+') { |file|
  a = file.read
  file.truncate(0)
  file.write("#{a.chop}]}")
}

crashes = MultiJson.load File.open("./crashes.json").read, symbolize_keys: true
d = crashes[:crashes].group_by{|x| x[:distance]}.sort
d.map do |k,v|
  puts "Turn dist: #{k}, brake: #{v.first[:brake_at]} -- #{v.first[:circuit]}, crashes: #{v.count}"
end

