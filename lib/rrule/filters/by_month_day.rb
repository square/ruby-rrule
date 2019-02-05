# frozen_string_literal: true

module RRule
  class ByMonthDay
    def initialize(by_month_days, context)
      @context = context
      @positive_month_days, @negative_month_days = by_month_days.partition { |mday| mday > 0 }
    end

    def reject?(i)
      !positive_month_days.include?(context.month_day_by_day_of_year[i]) && !negative_month_days.include?(context.negative_month_day_by_day_of_year[i])
    end

    private

    attr_reader :context, :positive_month_days, :negative_month_days
  end
end
