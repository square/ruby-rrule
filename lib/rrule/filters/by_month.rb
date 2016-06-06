module RRule
  class ByMonth
    def initialize(by_months, context)
      @by_months = by_months
      @context = context
    end

    def reject?(i)
      !by_months.include?(context.month_by_day_of_year[i])
    end

    private

    attr_reader :by_months, :context
  end
end
