module RRule
  class SimpleWeekly < Frequency
    def next_occurrences
      correct_current_date_if_needed
      this_occurrence = current_date
      @current_date += context.options[:interval].weeks
      [this_occurrence]
    end

    def correct_current_date_if_needed
      if context.options[:byweekday].present?
        target_wday = context.options[:byweekday].first.index
      else
        target_wday = context.dtstart.wday
      end

      while @current_date.wday != target_wday
        @current_date = @current_date + 1.day
      end
    end
  end
end
