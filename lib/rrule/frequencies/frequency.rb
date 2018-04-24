module RRule
  class Frequency
    attr_reader :current_date, :filters, :generator, :timeset

    def initialize(context, filters, generator, timeset)
      @context = context
      @current_date = context.dtstart
      @filters = filters
      @generator = generator
      @timeset = timeset
    end

    def advance
      @current_date = current_date.advance(advance_by).tap do |new_date|
        unless same_month(current_date, new_date)
          context.rebuild(new_date.year, new_date.month)
        end
      end
    end

    def next_occurrences
      possible_days_of_year = possible_days

      if filters.present?
        possible_days_of_year.each_with_index do |day_index, i|
          possible_days_of_year[i] = nil if filters.any? { |filter| filter.reject?(day_index) }
        end
      end

      generator.combine_dates_and_times(possible_days_of_year, timeset).tap do
        advance
      end
    end

    def possible_days
      fail NotImplementedError
    end

    def self.for_options(options)
      case options[:freq]
      when 'DAILY'
        Daily
      when 'WEEKLY'
        if options[:simple_weekly] && !options[:bymonth]
          SimpleWeekly # simplified and faster version if we don't need to deal with filtering
        else
          Weekly
        end
      when 'MONTHLY'
        Monthly
      when 'YEARLY'
        Yearly
      end
    end

    private

    attr_reader :context

    def same_month(first_date, second_date)
      first_date.month == second_date.month && first_date.year == second_date.year
    end

    def advance_by
      fail NotImplementedError
    end
  end
end
