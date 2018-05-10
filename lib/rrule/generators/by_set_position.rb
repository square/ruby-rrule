module RRule
  class BySetPosition < Generator
    attr_reader :by_set_positions

    def initialize(by_set_positions, context)
      @by_set_positions = by_set_positions
      super(context)
    end

    def combine_dates_and_times(dayset, timeset)
      valid_dates(dayset).flat_map do |date|
        process_timeset(date, timeset)
      end
    end

    def valid_dates(dayset)
      dayset.compact!
      by_set_positions.map do |position|
        position -= 1 if position > 0
        dayset[position]
      end.compact.map { |i| context.first_day_of_year + i }
    end
  end
end
