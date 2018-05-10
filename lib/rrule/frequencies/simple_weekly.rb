module RRule
  class SimpleWeekly < Frequency
    def next_occurrences
      this_occurrence = current_date
      @current_date += context.options[:interval].weeks
      generator.process_timeset(this_occurrence, timeset)
    end
  end
end
