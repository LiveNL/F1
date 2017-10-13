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

  def start(x)
    f = Drawille::FlipBook.new
#    puts cars.map {|x| x.car_json}

    reset_cars
    (0..60).to_a.map do |sec|
      move(cars, sec, x)
      #puts visualize(cars, f)
#      text_output(cars, sec, x)
      next if sec.zero?
      @cars = cars.sort_by(&:m).reverse
    end

    #f.play repeat: false, fps: 1
  end

  def move(cars, sec, x)
    cars.map do |car|
      car.move(car, cars, circuit, sec, x)
    end
  end

  def text_output(cars, sec, x)
    puts "_______ #{sec} _______"
    cars.map do |car|
      @crash = car.crash == true
      puts "#{x}:#{car.position}: #{car.m.round}m, #{car.row.round}, #{car.velocity.round}, #{car.crash if car.crash}"
    end
    return if @crash
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

      crashed_car = cars.find {|x| x.crash == true}
      if crashed_car
        i = (150 + crashed_car.m.round) / 5
        canvas.rows[i] = canvas.rows[i].red
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
