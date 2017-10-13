#!/usr/bin/env ruby
require 'multi_json'
require_relative '../models/race'

def load(json)
  MultiJson.load File.open("./configs/#{json}.json").read, symbolize_keys: true
end

cars = load('cars2')
circuits = load('circuits')

circuits[:circuits].map do |circuit|
  puts "#CIRCUIT: #{circuit[:country]}"

  10.times do |x|
    Race.new(circuit_json: circuit, cars_json: cars).start(x)
  end
end

