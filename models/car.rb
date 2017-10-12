#!/usr/bin/env ruby

class Car
  attr_reader :car_json, :car, :cars, :circuit, :sec
  attr_writer :m, :row

  def initialize(car_json:)
    @car_json = car_json
  end

  def move(car, cars, circuit, sec)
    @car, @cars, @circuit, @sec = car, cars, circuit, sec
    @m, @speed = m, speed
    return if sec.zero?

    switch_rows
    brake
    accelerate
  end

  def switch_rows
    if no_space(next_row)
      puts "NOSPACE"
    else
      @row += next_row
    end
  end

  def next_row
    faster || defend || (improve_row_position if m > 100) || 0
  end

  def improve_row_position
    next_row = best_row.zero? ? - switch_row : switch_row
    next_row unless (row + next_row < 0) || (row + next_row) > 4
  end

  def faster
    return false unless car_in_front && car.velocity > car_in_front.velocity

    # if car is faster than car_in_front, but closer to best_row, move to it.
    if (best_row - row).abs < (best_row - car_in_front.row).abs
      improve_row_position
    elsif row == car_in_front.row
      next_row = best_row.zero? ? switch_row : - switch_row
    next_row unless (row + next_row < 0) || (row + next_row) > 4
    end
  end

  def defend
    return unless car_in_back && car_in_back.velocity > car.velocity
    next_row = car_in_back.row > row ? switch_row : - switch_row
    next_row unless (row + next_row < 0) || (row + next_row) > 4
  end

  def no_space(next_row)
    if car_in_front
      same_rows = (row + next_row) == car_in_front.row
      to_close = m < (car_in_front.m - car_in_front.velocity - length)
      return true if same_rows && to_close
    elsif car_in_back
      same_rows = (row + next_row) == car_in_back.row
      to_close = (m - length) < car_in_back.m
      return true if same_rows && to_close
    end
  end

  def brake
    return if m < (circuit.turn.distance - circuit.turn.brake_at)
    a = (car_json[:acceleration] / 2) - (circuit.turn.speed / 3.6)
    @brake_speed ||= a / circuit.turn.brake_at
    @velocity += @brake_speed
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
    @speed += velocity
  end

  def m
    @m ||= -(position * 8)
  end

  def last_row
    @last_row ||= row
  end

  def row
    @row ||= grid_row
  end

  def grid_row
    position.even? ? 1 : 3
  end

  def best_row
    circuit.turn.side == 'L' ? 0 : 4
  end

  def position
    @cars.index @car
  end

  def velocity
    @velocity ||= car_json[:acceleration] / 2.0
  end

  def speed
    @speed ||= sec * velocity * 3.6 # km/h
  end

  def length; 5 end
  def width; 2 end
  def switch_row; 1 end
end
