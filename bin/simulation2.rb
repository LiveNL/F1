#!/usr/bin/env ruby
require 'multi_json'
require_relative '../models/race'

def load(json)
  MultiJson.load File.open("./configs/#{json}.json").read, symbolize_keys: true
end

cars = load('cars')
circuits = load('circuits')

australia = circuits[:circuits].first
race = Race.new(circuit_json: australia, cars_json: cars)
race.start
