module RRule
  class AllOccurrences < Generator
    def combine_dates_and_times(dayset, timeset)
      dayset.compact.map { |i| context.first_day_of_year + i }.flat_map do |date|
        process_timeset(date, timeset)
      end
    end
  end
end
