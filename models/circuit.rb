#!/usr/bin/env ruby

require_relative '../models/turn'

class Circuit
  attr_reader :circuit_json

  def initialize(circuit_json:)
    @circuit_json = circuit_json
  end

  def pole
    circuit_json[:pole]
  end

  def width
    15
  end

  def turn
    @turn ||= Turn.new(turn_json: circuit_json[:turn])
  end
end

