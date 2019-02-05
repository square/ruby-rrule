# frozen_string_literal: true

module RRule
  class Monthly < Frequency
    def possible_days
      # yday is 1-indexed, need results 0-indexed
      (current_date.beginning_of_month.yday - 1..current_date.end_of_month.yday - 1).to_a
    end

    private

    def advance_by
      { months: context.options[:interval] }
    end
  end
end
