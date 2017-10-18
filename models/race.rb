#!/usr/bin/env ruby

require 'drawille'
require 'terminal-table'

require_relative '../models/circuit'
require_relative '../models/car'

class Race
  attr_reader :circuit_json, :cars_json, :x, :rng

  def initialize(circuit_json:, cars_json:, x:, rng:)
    @circuit_json = circuit_json
    @cars_json = cars_json
    @x = x
    @rng = rng
  end

  def start
    f = Drawille::FlipBook.new

    reset_cars
    (0..60).to_a.map do |sec|
      move(cars, sec)
      safety_car = cars.find{|c| c.car.crash == true}
      @cars = cars.sort_by{ |x| x.m }.reverse
      text_output(cars, sec, x)
      next if sec.zero?
      #puts visualize(cars, f)
      break if safety_car
      break if cars.last.m > cars.first.circuit.turn.distance
    end

    #f.play repeat: true, fps: 1
  end

  def move(cars, sec)
    cars.map do |car|
      car.move(car, cars, circuit, sec, x, rng)
      return if car.crash == true
    end
  end

  def text_output(cars, sec, x)
    rows = []
    cars.map do |car|
      rows << [car.position, car.car_json[:driver], car.m.round(2), car.row, (car.speed * 3.6).round(2), (car.braking_zone if car.braking_zone), (car.crash if car.crash)]
    end

    table = Terminal::Table.new :headings => ['pos', 'driver', 'm', 'row', 'speed', 'braking', 'crash'], :rows => rows, :title => sec
    puts table
  end

  def visualize(cars, f)
    c = Drawille::Canvas.new

    circuit_ = circuit

    c.paint do
      distance = circuit_.turn.distance
      brake_at = distance - circuit_.turn.brake_at
      line from: [-1, distance], to: [-1, -150]
      line from: [11, distance], to: [11, -150]
      line from: [-1, 0], to: [11, 0]
      line from: [11, brake_at], to: [20, brake_at]

      cars.sort_by(&:m).reverse.map do |car|
        x = (car.row.round * 2); y = car.m.round;
        x2 = (x + car.width); y2 = (y + car.length)

        mv(x,y); down; mv((x + car.width),y); mv(x2,y2); mv(x,y2); mv(x,y); up
      end

      f.snapshot canvas
    end
  end

  def cars
    @cars ||= cars_json[:cars][0..20].map { |car| Car.new(car_json: car) }
  end

  def reset_cars
    @cars = cars_json[:cars][0..20].map { |car| Car.new(car_json: car) }
  end

  def circuit
    @circuit ||= Circuit.new(circuit_json: circuit_json)
  end
end
