#!/usr/bin/env ruby

require 'drawille'

require_relative '../models/circuit'
require_relative '../models/car'

class Race
  attr_reader :circuit_json, :cars_json

  def initialize(circuit_json:, cars_json:)
    @circuit_json = circuit_json
    @cars_json = cars_json
  end

  def start
    f = Drawille::FlipBook.new

    (0..60).to_a.map do |sec|
      move(cars, sec)
      c = Drawille::Canvas.new
      puts visualize(cars, c, f)
      next if sec.zero?
      @cars = cars.sort_by(&:m).reverse
    end

    f.play repeat: false, fps: 2
    puts 'okedaag'
  end

  def move(cars, sec)
    cars.map do |car|
      car.move(car, cars, circuit, sec)
    end
  end

  def visualize(cars, c, f)
    circuit_ = circuit
    c.paint do
      distance = circuit_.turn.distance
      brake_at = distance - circuit_.turn.brake_at
      line from: [-1, distance], to: [-1, -150]
      line from: [11, distance], to: [11, -150]
      line from: [-1, 0], to: [11, 0]
      line from: [11, brake_at], to: [20, brake_at]

      cars.sort_by(&:m).reverse.map do |car|
        x = (car.row * 2); y = car.m.round;
        x2 = (x + car.width); y2 = (y + car.length)

        mv(x,y); down; mv((x + car.width),y); mv(x2,y2); mv(x,y2); mv(x,y); up
      end

      f.snapshot canvas
    end
  end

  def cars
    @cars ||= cars_json[:cars].map { |car| Car.new(car_json: car) }
  end

  def circuit
    @circuit ||= Circuit.new(circuit_json: circuit_json)
  end
end