module RRule
  class Frequency
    attr_reader :current_date

    def initialize(context)
      @context = context
      @current_date = context.dtstart
    end

    def advance
      @current_date = current_date.advance(advance_by).tap do |new_date|
        unless same_month(current_date, new_date)
          context.rebuild(new_date.year, new_date.month)
        end
      end
    end

    def possible_days
      fail NotImplementedError
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
