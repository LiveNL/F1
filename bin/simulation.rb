#!/usr/bin/env ruby
require 'colorize'
require 'multi_json'

# speed is 300 kph in 10.6s (https://www.redbull.com/ca-en/motogp-repsol-honda-team-f1-red-bull-racing-2015)
# startgrid positions are 8 metres after each other (16 on 1 side)
# car length ~ 5, width max. 2
# 300 kph = 83.3333 ms. a = dv / dt = 83.333 / 10.6 = 7.86 ms2
# s = 1/2 at2 = 1/2 . (7.86) . (10.6)2 = 441.49
# 441.49 / 10.6 s = 41.65 m/s (linear accelerated)
# 600m till first turn in Malaysia (https://www.freemaptools.com/measure-distance.htm)
#
# if the first turn heads to the opposite site of where the car started,
# it wants to stay there to maintain it's speed as long as possible.
# unless the 'car_in_back' is faster, you want to block that one
# @var gets -20 for switching sides

# TODO: - Documentation:
# Find arguments to explain why it's logical to make it random to choose between braking and crashing,
# could be based on previous races.
# max speed car? (on for example mexico; 357 1st straight)

# TODO: - Code
# Make acceleration non-linear
# Brake at distance
# Find nicer way to switch sides

circuit = { turn: 'a', distance: 600, brake: 500}

car1 = { name: 'car1', distance: 0, side: 'b', speed: 41, start: 1, switched: false}
car2 = { name: 'car2', distance: -8, side: 'a', speed: 41.5, start: 2, switched: false}
car3 = { name: 'car3', distance: -16, side: 'b', speed: 41.5, start: 3, switched: false}
car4 = { name: 'car4', distance: -24, side: 'a', speed: 41.3, start: 4, switched: false}
car5 = { name: 'car5', distance: -32, side: 'b', speed: 41.5, start: 5, switched: false}
car6 = { name: 'car6', distance: -36, side: 'a', speed: 41.3, start: 6, switched: false}

cars = [car1, car2, car3, car4, car5, car6]
switch_keys = []

(0..15).to_a.map do |sec|
  puts "_______ #{sec} _______"
  puts "\n"

  cars.map do |car|

    # NOTE: Switch if switch plan was made
    if switch_keys.include? "#{car[:name]}:#{sec}"
      car[:side] = circuit[:turn]
      car[:switched] = true
      var = -5
    end

    car_in_front = cars.find_all{ |x| x[:distance] > car[:distance] }.sort_by{ |x| x[:distance] }.first
    car_in_back  = cars.find_all{ |x| x[:distance] < car[:distance] }.sort_by{ |x| x[:distance] }.first

    # NOTE: Switch if car in front is slower than you, or car in back is faster, based on corner
    if circuit[:turn] != car[:side] && !car[:switched]
      if car_in_front && car[:speed] > car_in_front[:speed] || car_in_back && car_in_back[:speed] > car[:speed]
        switch_keys << "#{car[:name]}:#{sec + 1}"
      end
    end

    # NOTE: Update driven distance
    car[:distance] += car[:speed] + var.to_i

    puts car # MultiJson.dump car, pretty: true

    # NOTE: Brake anyway if corner is coming
    if car[:distance] > circuit[:brake] && car[:side] == circuit[:turn]
      puts "Braking for corner! => #{car[:name]} at #{car[:distance]}".green
      car[:distance] -10
    elsif car[:distance] > (circuit[:brake] + 50)
      puts "Braking for corner! => #{car[:name]} at #{car[:distance]}".green
      car[:distance] -10
    end

    # NOTE: If car_in_front is too close, decide random to brake, or to crash
    if car_in_front && (car_in_front[:side] == car[:side]) && (car_in_front[:distance] - car[:distance]) < 2
      if rand > 0.2
        car[:distance] - 5
        puts "Braking! => #{car[:name]}".cyan
        switch_keys << "#{car[:name]}:#{sec + 1}" if !car[:switched]
      else
        puts "CRASH!!$!3!#! between #{car_in_front[:name]} && #{car[:name]}".red
        exit
      end
    end
  end

  puts "\n"
end

puts "Result:"
puts cars.sort_by {|x| x[:distance]}.reverse
