module RRule
  class BySetPosition
    attr_reader :by_set_positions, :context

    def initialize(by_set_positions, context)
      @by_set_positions = by_set_positions
      @context = context
    end

    def combine_dates_and_times(dayset, timeset)
      valid_dates(dayset).flat_map do |date|
        timeset.map do |time|
          Time.use_zone(context.tz) do
            Time.zone.local(
                date.year,
                date.month,
                date.day,
                time[:hour],
                time[:minute],
                time[:second]
            )
          end
        end
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
