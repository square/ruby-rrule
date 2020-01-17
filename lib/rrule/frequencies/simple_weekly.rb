# frozen_string_literal: true

module RRule
  class SimpleWeekly < Frequency
    def next_occurrences
      correct_current_date_if_needed
      this_occurrence = current_date
      @current_date += context.options[:interval].weeks
      generator.process_timeset(this_occurrence, timeset)
    end

    def correct_current_date_if_needed
      target_wday = if context.options[:byweekday].present?
        context.options[:byweekday].first.index
      else
        context.dtstart.wday
      end

      @current_date += 1.day while @current_date.wday != target_wday
    end
  end
end
