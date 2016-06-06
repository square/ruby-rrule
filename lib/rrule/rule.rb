module RRule
  class Rule
    attr_reader :rrule, :dtstart, :tz, :exdate

    def initialize(rrule, dtstart: Time.now, tzid: 'UTC', exdate: [])
      @rrule = rrule
      # This removes all sub-second and floors it to the second level.
      # Sub-second level calculations breaks a lot of assumptions in this
      # library and rounding it may also cause unexpected inequalities.
      @dtstart = Time.at(dtstart.to_i).in_time_zone(tzid)
      @tz = tzid
      @exdate = exdate
    end

    def all
      reject_exdates(all_until(nil))
    end

    def between(start_date, end_date)
      # This removes all sub-second and floors it to the second level.
      # Sub-second level calculations breaks a lot of assumptions in this
      # library and rounding it may also cause unexpected inequalities.
      floored_start_date = Time.at(start_date.to_i)
      floored_end_date = Time.at(end_date.to_i)
      reject_exdates(all_until(floored_end_date).reject { |instance| instance < floored_start_date })
    end

    private

    def reject_exdates(results)
      results.reject { |date| exdate.include?(date) }
    end

    def all_until(end_date)
      result = []

      context = Context.new(options, dtstart, tz)
      context.rebuild(dtstart.year, dtstart.month)

      timeset = options[:timeset]
      total = 0
      count = options[:count]

      filters = []

      frequency = case options[:freq]
      when 'DAILY'
        Daily.new(context)
      when 'WEEKLY'
        Weekly.new(context)
      when 'MONTHLY'
        Monthly.new(context)
      when 'YEARLY'
        Yearly.new(context)
      end

      if options[:bymonth]
        filters.push(ByMonth.new(options[:bymonth], context))
      end

      if options[:byweekno]
        filters.push(ByWeekNumber.new(options[:byweekno], context))
      end

      if options[:byweekday]
        filters.push(ByWeekDay.new(options[:byweekday], context))
      end

      if options[:byyearday]
        filters.push(ByYearDay.new(options[:byyearday], context))
      end

      if options[:bymonthday]
        filters.push(ByMonthDay.new(options[:bymonthday], context))
      end

      if options[:bysetpos]
        generator = BySetPosition.new(options[:bysetpos], context)
      else
        generator = AllOccurrences.new(context)
      end

      loop do
        return result if frequency.current_date.year > MAX_YEAR

        possible_days_of_year = frequency.possible_days

        possible_days_of_year.each_with_index do |day_index, i|
          possible_days_of_year[i] = nil if filters.any? { |filter| filter.reject?(day_index) }
        end

        results_with_time = generator.combine_dates_and_times(possible_days_of_year, timeset)
        results_with_time.sort.each do |this_result|
          if end_date
            if this_result > end_date
              return result
            end
          end

          if options[:until]
            if this_result > options[:until]
              return result
            end
            result.push(this_result)
          elsif this_result >= dtstart
            total += 1
            if options[:count]
              count -= 1
              result.push(this_result)
              return result if count == 0
            else
              result.push(this_result)
            end
          end
        end

        frequency.advance
      end
    end

    def options
      @options ||= parse_options
    end

    def parse_options
      options = { interval: 1, wkst: 1 }

      params = @rrule.split(';')
      params.each do |param|
        option, value = param.split('=')

        case option
        when 'FREQ'
          options[:freq] = value
        when 'COUNT'
          options[:count] = value.to_i
        when 'UNTIL'
          options[:until] = Time.parse(value)
        when 'INTERVAL'
          options[:interval] = value.to_i
        when 'BYDAY'
          options[:byweekday] = value.split(',').map { |day| Weekday.parse(day) }
        when 'BYSETPOS'
          options[:bysetpos] = value.split(',').map(&:to_i)
        when 'WKST'
          options[:wkst] = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'].index(value)
        when 'BYMONTH'
          options[:bymonth] = value.split(',').compact.map(&:to_i)
        when 'BYMONTHDAY'
          options[:bymonthday] = value.split(',').map(&:to_i)
        when 'BYWEEKNO'
          options[:byweekno] = value.split(',').map(&:to_i)
        when 'BYYEARDAY'
          options[:byyearday] = value.split(',').map(&:to_i)
        end
      end

      if !(options[:byweekno] || options[:byyearday] || options[:bymonthday] || options[:byweekday])
        case options[:freq]
        when 'YEARLY'
          unless options[:bymonth]
            options[:bymonth] = [dtstart.month]
          end
          options[:bymonthday] = [dtstart.day]
        when 'MONTHLY'
          options[:bymonthday] = [dtstart.day]
        when 'WEEKLY'
          options[:byweekday] = [Weekday.new(dtstart.wday)]
        end
      end

      unless options[:byweekday].nil?
        options[:byweekday], options[:bynweekday] = options[:byweekday].partition { |wday| wday.ordinal.nil? }
      end

      options[:timeset] = [{ hour: dtstart.hour, minute: dtstart.min, second: dtstart.sec }]

      options
    end
  end
end
