#!/usr/bin/env ruby
require 'colorize'

class Car
  attr_reader :car_json, :car, :cars, :circuit, :sec, :x, :rng

  def initialize(car_json:)
    @car_json = car_json
  end

  def move(car, cars, circuit, sec, x, rng)
    @car, @cars, @circuit, @sec, @x, @rng = car, cars, circuit, sec, x, rng
    @m, @crash, @speed, @brake_sec = m, crash,speed, brake_sec

    return if sec.zero?

    braking_zone ? adjust_speed : accelerate
    switch_rows?
    crash_check unless m > circuit.turn.distance
  end

  def crash_check
    return unless car_in_front && car_in_front.row == row # no car is blocking
    return if m <= (car_in_front.m - length) # there's still space
    return if m - length > car_in_front.m # take over
    return switch_rows? if space next_row # switching rows could prevent crashes

    if rng.rand(1.0) > 0.5
      @crash = true
      write_crash
    else
      adjust_speed
    end
  end

  def switch_rows?
    @row += next_row if space(next_row)
  end

  def next_row
    faster || defend || improve_row_position || 0
  end

  def improve_row_position
    return unless braking_zone
    best_row.zero? ? - switch_row : switch_row
  end

  def faster
    return unless car_in_front && car.speed > car_in_front.speed
    if (best_row - row).abs < (best_row - car_in_front.row).abs
      best_row.zero? ? - switch_row : switch_row # improve_row_position
    elsif row == car_in_front.row
      best_row.zero? ? switch_row : - switch_row
    end
  end

  def defend
    return unless car_in_back && car_in_back.speed > car.speed
    next_r = switch_row if car_in_back.row > row
    next_r ||= row == car_in_back.row ? 0 : - switch_row
    next_r
  end

  def off_grid(next_r)
    (row + next_r < 0) || (row + next_r) > 4
  end

  def space(next_row)
    space_in_front(next_row) && space_in_back(next_row) && !off_grid(next_row)
 end

  def space_in_front(next_row)
    if car_in_front
      same_rows = (row + next_row) == car_in_front.row
      to_close = m < (car_in_front.m - length)
      return false if same_rows && to_close
    end
    true
  end

  def space_in_back(next_row)
    if car_in_back
      same_rows = (row + next_row) == car_in_back.row
      to_close = (m - length) < car_in_back.m
      return false if same_rows && to_close
    end
    true
  end

  def adjust_speed
    @brake_sec += 1
    @acceleration = speed - brake_delay unless @speed < (circuit.turn.speed / 3.6)
    @m += (distance(sec: brake_sec) - distance(sec: (brake_sec - 1)))
    @speed = speed - brake_delay unless @speed < (circuit.turn.speed / 3.6)
  end

  def brake

  end

  def brake_delay
    vgem = (circuit.turn.speed / 3.6 + speed) / 2
    s = circuit.turn.brake_at
    t = s / vgem
    v = speed - (circuit.turn.speed / 3.6)
    @brake_delay = 0 if circuit.turn.brake_at == 0
    @brake_delay ||= v / t * t if t < 1
    @brake_delay ||= v / t
  end

  def braking_zone
    (m + 10) > (circuit.turn.distance - circuit.turn.brake_at)
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
    @m += (distance(sec: sec) - distance(sec: (sec - 1)))
    return if @speed * 3.6 > 340
    @speed += acceleration
  end

  def distance(sec:)
    0.5 * acceleration * (sec * sec)
  end

  def position; @cars.index @car end

  def crash;    @crash    ||= false end
  def row;      @row      ||= grid_row end
  def m;        @m        ||= -(position * 8) end

  def speed;        @speed        ||= acceleration * sec end
  def acceleration; @acceleration ||= car_json[:acceleration] end
  def brake_sec;    @brake_sec    ||= 0 end

  def grid_row
    if circuit.circuit_json[:pole] == 'L'
      return car.position.even? ? 1 : 3
    end

    if circuit.circuit_json[:pole] == 'R'
      return car.position.even? ? 3 : 1
    end
  end

  def best_row; circuit.turn.side == 'L' ? 0 : 4 end

  def length; 5 end
  def width; 2 end
  def switch_row; 1 end

  def write_crash
    j = { "x" => x, "sec" => sec, "position" => position, "circuit" => circuit.country,
          "distance" => circuit.turn.distance, "brake_at" => circuit.turn.brake_at,
          "speed" => circuit.turn.speed, "driver" => car_json[:driver] }

    File.open("crashes.json", 'a') { |file| file.write("#{MultiJson.dump j},") }
  end
end
