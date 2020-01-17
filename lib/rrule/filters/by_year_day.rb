# frozen_string_literal: true

module RRule
  class ByYearDay
    def initialize(by_year_days, context)
      @by_year_days = by_year_days
      @context = context
    end

    def reject?(i)
      !by_year_days.empty? &&
        ((i < context.year_length_in_days && !by_year_days.include?(i + 1) && !by_year_days.include?(i - context.year_length_in_days)) ||
          (i >= context.year_length_in_days && !by_year_days.include?(i + 1 - context.year_length_in_days) && !by_year_days.include?(i - context.year_length_in_days - context.next_year_length_in_days)))
    end

    private

    attr_reader :by_year_days, :context
  end
end
