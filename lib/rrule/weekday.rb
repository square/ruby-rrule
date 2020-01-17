# frozen_string_literal: true

module RRule
  class Weekday
    attr_reader :index, :ordinal

    def initialize(index, ordinal = nil)
      @index = index
      @ordinal = ordinal
    end

    def self.parse(weekday)
      match = /([+-]?\d)?([A-Z]{2})/.match(weekday)
      index = RRule::WEEKDAYS.index(match[2])
      ordinal = match[1] ? match[1].to_i : nil
      new(index, ordinal)
    end
  end
end
