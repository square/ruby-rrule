# frozen_string_literal: true

module RRule
  class Daily < Frequency
    def possible_days
      [current_date.yday - 1] # convert to 0-indexed
    end

    private

    def advance_by
      { days: context.options[:interval] }
    end
  end
end
