module RRule
  class Context
    attr_reader :options, :dtstart, :tz, :day_of_year_mask, :year

    def initialize(options, dtstart, tz)
      @options = options
      @dtstart = dtstart
      @tz = tz
    end

    def rebuild(year, month)
      @year = year

      reset_year if year != last_year

      if options[:bynweekday] && !options[:bynweekday].empty? && (month != last_month || year != last_year)
        possible_date_ranges = []
        if options[:freq] == 'YEARLY'
          if options[:bymonth]
            options[:bymonth].each do |month|
              possible_date_ranges.push(elapsed_days_in_year_by_month[(month - 1)..(month)])
            end
          else
            possible_date_ranges = [[0, year_length_in_days]]
          end
        elsif options[:freq] == 'MONTHLY'
          possible_date_ranges = [elapsed_days_in_year_by_month[(month - 1)..(month)]]
        end

        unless possible_date_ranges.empty?
          @day_of_year_mask = Array.new(year_length_in_days, false)

          possible_date_ranges.each do |possible_date_range|
            year_day_start = possible_date_range[0]
            year_day_end = possible_date_range[1] - 1
            options[:bynweekday].each do |weekday|
              day_of_year = day_of_year_within_range(weekday, year_day_start, year_day_end)
              day_of_year_mask[day_of_year] = true if day_of_year
            end
          end
        end
      end

      @last_year = year
      @last_month = month
    end

    def year_length_in_days
      @year_length_in_days ||= leap_year? ? 366 : 365
    end

    def next_year_length_in_days
      @next_year_length_in_days ||= Date.leap?(year + 1) ? 366 : 365
    end

    def first_day_of_year
      @first_day_of_year ||= Date.new(year).beginning_of_year
    end

    def first_weekday_of_year
      @first_weekday_of_year ||= first_day_of_year.wday
    end

    def month_by_day_of_year
      @month_by_day_of_year ||= days_in_year.map(&:month)
    end

    def month_day_by_day_of_year
      @month_day_by_day_of_year ||= days_in_year.map(&:day)
    end

    def negative_month_day_by_day_of_year
      @negative_month_day_by_day_of_year ||= days_in_year.map { |day| day.day - day.end_of_month.day - 1 }
    end

    def weekday_by_day_of_year
      @weekday_by_day_of_year ||= weekdays_in_year.drop(first_weekday_of_year)
    end

    def week_number_by_day_of_year
      @week_number_by_day_of_year ||= days_in_year.map(&:cweek)
    end

    def negative_week_number_by_day_of_year
      @negative_week_number_by_day_of_year ||= days_in_year.map { |day| day.cweek - Date.new(day.cwyear, 12, 28).cweek - 1 }
    end

    def elapsed_days_in_year_by_month
      @elapsed_days_in_year_by_month ||= [0] + (1..12).map { |month| Date.new(year, month).end_of_month.yday }
    end

    private

    attr_reader :last_month, :last_year

    def weekdays_in_year
      @weekdays_in_year ||= ((0..6).to_a * 54)
    end

    def leap_year?
      Date.leap?(year)
    end

    def reset_year
      @days_in_year = nil
      @year_length_in_days = nil
      @next_year_length_in_days = nil
      @first_day_of_year = nil
      @first_weekday_of_year = nil
      @month_by_day_of_year = nil
      @month_day_by_day_of_year = nil
      @negative_month_day_by_day_of_year = nil
      @weekday_by_day_of_year = nil
      @week_number_by_day_of_year = nil
      @negative_week_number_by_day_of_year = nil
      @elapsed_days_in_year_by_month = nil
    end

    def days_in_year
      @days_in_year ||= (first_day_of_year..first_day_of_year.end_of_year + 7.days)
    end

    def day_of_year_within_range(weekday, year_day_start, year_day_end)
      wday = weekday.index
      ordinal_weekday = weekday.ordinal
      if ordinal_weekday < 0
        day_of_year = year_day_end + (ordinal_weekday + 1) * 7
        day_of_year -= (weekday_by_day_of_year[day_of_year] - wday) % 7
      else
        day_of_year = year_day_start + (ordinal_weekday - 1) * 7
        day_of_year += (7 - weekday_by_day_of_year[day_of_year] + wday) % 7
      end

      day_of_year if year_day_start <= day_of_year && day_of_year <= year_day_end
    end
  end
end
