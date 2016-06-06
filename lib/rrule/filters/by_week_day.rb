module RRule
  class ByWeekDay
    def initialize(weekdays, context)
      @by_week_days = weekdays.map(&:index)
      @context = context
    end

    def reject?(i)
      masked?(i) || !matches_by_week_days?(i)
    end

    private

    def masked?(i)
      context.day_of_year_mask && !context.day_of_year_mask[i]
    end

    def matches_by_week_days?(i)
      by_week_days.empty? || by_week_days.include?(context.weekday_by_day_of_year[i])
    end

    attr_reader :by_week_days, :context
  end
end
