module RRule
  class Weekly < Frequency
    def possible_days
      i = current_date.yday - 1
      possible_days = []
      7.times do
        possible_days.push(i)
        i += 1
        break if context.weekday_by_day_of_year[i] == context.options[:wkst]
      end
      possible_days
    end

    private

    def advance_by
      { days: days_to_advance(current_date) }
    end

    def days_to_advance(date)
      if context.options[:wkst] > date.wday
        -(date.wday + 1 + (6 - context.options[:wkst])) + context.options[:interval] * 7
      else
        -(date.wday - context.options[:wkst]) + context.options[:interval] * 7
      end
    end
  end
end

