#!/usr/bin/env ruby

class Car
  attr_reader :car_json, :car, :cars, :circuit, :sec
  attr_writer :m, :row

  def initialize(car_json:)
    @car_json = car_json
  end

  def move(car, cars, circuit, sec)
    @car, @cars, @circuit, @sec = car, cars, circuit, sec
    @m = m
    return if sec.zero?

    switch_rows
    accelerate
  end

  def switch_rows
    return unless want_move(next_row)
    return unless can_move(next_row)
    @row += next_row.to_i
  end

  def next_row
    if circuit.turn.side == 'R'
      return -1 if row > 0 # NOTE: maybe switch this to 0.5?
    else
      return 1 if row < 5
    end
    0
  end

  def want_move(next_row)
    return true if position.zero?
    same_rows = (car.row + next_row) == car_in_front.row
    faster = car_in_front.velocity <= car.velocity
    return true if !same_rows && faster
  end

  def can_move(next_row)
    if car_in_front
      # car.m should be smaller than the back of the car in the front (minus its velocity)
      same_rows = (car.row + next_row) == car_in_front.row
      to_close = car.m < (car_in_front.m - car_in_front.velocity - car_in_front.length)

      return false if same_rows && to_close
    end

    if car_in_back
      # back of the car should be greater than front of car in the back
      same_rows = (car.row + next_row) == car_in_back.row
      to_close = (car.m - car.length) > car_in_back.m

      return false if same_rows && to_close
    end
    true
  end

  def car_in_front
    return nil if position.zero?
    @cars[position - 1]
  end

  def car_in_back
    return nil if position == 20
    @cars[position + 1]
  end

  def accelerate
    @m += velocity
    @m.round(2)
  end

  def m
    @m ||= -(position * 8)
  end

  def row
    @row ||= grid_row
  end

  def grid_row
    position.even? ? 1 : 3
  end

  def position
    @cars.index @car
  end

  def velocity
    car_json[:acceleration] / 2
  end

  def speed
    sec * velocity * 3.6 # km/h
  end

  def length; 5 end
  def width; 2 end
end
