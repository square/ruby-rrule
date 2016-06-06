module RRule
  class ByWeekNumber
    def initialize(by_week_numbers, context)
      @by_week_numbers = by_week_numbers
      @context = context
    end

    def reject?(i)
      !by_week_numbers.include?(context.week_number_by_day_of_year[i]) && !by_week_numbers.include?(context.negative_week_number_by_day_of_year[i])
    end

    private

    attr_reader :by_week_numbers, :context
  end
end
