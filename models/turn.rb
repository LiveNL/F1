#!/usr/bin/env ruby

class Turn
  attr_reader :turn

  def initialize(turn_json:)
    @turn = turn_json
  end

  def rows
    if side == 'L'
      (0..4).to_a[0..(width - 1)]
    else
      (0..4).to_a[(width + 1)..4]
    end
  end

  def width
    turn[:width]
  end

  def distance
    turn[:distance]
  end

  def brake_at
    turn[:brake_at]
  end

  def speed
    turn[:speed]
  end

  def side
    turn[:side]
  end
end
