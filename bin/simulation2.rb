#!/usr/bin/env ruby
require 'multi_json'
require_relative '../models/race'

def load(json)
  MultiJson.load File.open("./configs/#{json}.json").read, symbolize_keys: true
end

cars = load('cars2')
circuits = load('circuits')

belgium = circuits[:circuits].find{|x| x[:country] == "Belgium"}
australia = circuits[:circuits].first
race = Race.new(circuit_json: belgium, cars_json: cars)
race.start
