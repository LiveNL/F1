#!/usr/bin/env ruby
require 'colorize'

class Car
  attr_reader :car_json, :car, :cars, :circuit, :sec, :x, :rng

  def initialize(car_json:)
    @car_json = car_json
  end

  def move(car, cars, circuit, sec, x, rng)
    @car, @cars, @circuit, @sec, @x, @rng = car, cars, circuit, sec, x, rng
    @m, @crash, @brake_speed = m, crash, brake_speed

    return if sec.zero?

    switch_rows?
    adjust_speed if braking_zone
    crash_check unless m > circuit.turn.distance
    accelerate
  end

  def crash_check
    # no car is blocking
    return unless car_in_front && car_in_front.row == row
    # take over
    return if (m + velocity) > car_in_front.m
    # there's still space
    return if m < (car_in_front.m - length)
    return switch_rows? if space(next_row)

    if rng.rand(1.0) > 0.5
      @crash = true
      write_crash
    else
      @m += brake_speed
    end
  end

  def switch_rows?
    @row += next_row if space(next_row)
  end

  def next_row
    faster || defend || improve_row_position || 0
  end

  def improve_row_position
    next_row = best_row.zero? ? - switch_row : switch_row
    next_row unless (row + next_row < 0) || (row + next_row) > 4
  end

  def faster
    return unless car_in_front && car.velocity > car_in_front.velocity
    if (best_row - row).abs < (best_row - car_in_front.row).abs
      improve_row_position
    elsif row == car_in_front.row
      next_row = best_row.zero? ? switch_row : - switch_row
      next_row unless (row + next_row < 0) || (row + next_row) > 4
    end
  end

  def defend
    return unless car_in_back && car_in_back.velocity > car.velocity
    next_row = switch_row if car_in_back.row > row
    next_row ||= row == car_in_back.row ? 0 : - switch_row
    next_row unless (row + next_row < 0) || (row + next_row) > 4
  end

  def space(next_row)
    space_in_front(next_row) && space_in_back(next_row)
 end

  def space_in_front(next_row)
    if car_in_front
      same_rows = (row + next_row) == car_in_front.row
      to_close = m < (car_in_front.m - car_in_front.velocity - length)
      return false if same_rows && to_close
    end
    true
  end

  def space_in_back(next_row)
    if car_in_back
      same_rows = (row + next_row) == car_in_back.row
      to_close = (m + velocity - length) < car_in_back.m
      return false if same_rows && to_close
    end
    true
  end

  def adjust_speed
    return if @velocity <= 0.5
    @velocity += @brake_speed
  end

  def brake_speed
    @brake_speed = 0 if circuit.turn.brake_at == 0
    @brake_speed ||= (speed - (circuit.turn.speed / 3.6)) / circuit.turn.brake_at
  end

  def braking_zone
    m > (circuit.turn.distance - circuit.turn.brake_at)
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
  end

  def position; @cars.index @car end

  def crash;    @crash    ||= false end
  def m;        @m        ||= -(position * 8) end
  def row;      @row      ||= grid_row end
  def velocity; @velocity ||= speed end
  def speed;    @speed    ||= car_json[:acceleration] / 2.0 end

  def grid_row; circuit.circuit_json[:pole] == 'L' ? 1 : 3 end
  def best_row; circuit.turn.side == 'L' ? 0 : 4 end

  def length; 5 end
  def width; 2 end
  def switch_row; 1 end

  def write_crash
    j = {
      "x" => x,
      "sec" => sec,
      "position" => position,
      "circuit" => circuit.country,
      "distance" => circuit.turn.distance,
      "brake_at" => circuit.turn.brake_at,
      "speed" => circuit.turn.speed,
      "driver" => car_json[:driver]
    }

    File.open("crashes.json", 'a') { |file| file.write("#{MultiJson.dump j},") }
  end
end
