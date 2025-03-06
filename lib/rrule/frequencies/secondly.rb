# frozen_string_literal: true

module RRule
  class Secondly < Frequency
    def possible_days
      [current_date.yday - 1] # convert to 0-indexed
    end

    def timeset
      super.map { |time| time.merge(hour: current_date.hour, minute: current_date.min, second: current_date.sec) }
    end

    private

    def advance_by
      { seconds: context.options[:interval] }
    end
  end
end
