# frozen_string_literal: true

module RRule
  class Secondly < Frequency
    def possible_days
      return [] unless time_allowed?(:byhour, current_date.hour) &&
             time_allowed?(:byminute, current_date.min) &&
             time_allowed?(:bysecond, current_date.sec)

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
