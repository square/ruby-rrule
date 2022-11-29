# frozen_string_literal: true

module RRule
  class Weekday
    attr_reader :index, :ordinal

    DAY_NAMES = %w[
      Sunday
      Monday
      Tuesday
      Wednesday
      Thursday
      Friday
      Saturday
    ].freeze

    def initialize(index, ordinal = nil)
      @index = index
      @ordinal = ordinal
    end

    def self.parse(weekday)
      match = /([+-]?\d+)?([A-Z]{2})/.match(weekday)
      index = RRule::WEEKDAYS.index(match[2])
      ordinal = match[1] ? match[1].to_i : nil
      new(index, ordinal)
    end

    def full_name
      DAY_NAMES[index]
    end

    def nth
      return 'last' if ordinal == -1

      nth =
        case npos = ordinal.abs
        when 1, 21, 31
          npos + 'st'
        when 2, 22
          npos + 'nd'
        when 3, 23
          npos + 'rd'
        else
          npos + 'th'
        end

      ordinal < 0 ? nth + ' ' + 'last' : nth
    end
  end
end
