# frozen_string_literal: true

module RRule
  class Minutely < Frequency
    def possible_days
      [current_date.yday - 1] # convert to 0-indexed
    end

    def timeset
      super.map { |time| time.merge(hour: current_date.hour, minute: current_date.min) }
    end

    private

    def advance_by
      { minutes: context.options[:interval] }
    end
  end
end
