module RRule
  class AllOccurrences
    attr_reader :context

    def initialize(context)
      @context = context
    end

    def combine_dates_and_times(dayset, timeset)
      dayset.compact.map { |i| context.first_day_of_year + i }.flat_map do |date|
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
  end
end
