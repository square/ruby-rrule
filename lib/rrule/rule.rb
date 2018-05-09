module RRule
  class Rule
    include Enumerable

    attr_reader :dtstart, :tz, :exdate

    def initialize(rrule, dtstart: Time.now, tzid: 'UTC', exdate: [], max_year: nil)
      @dtstart = floor_to_seconds(dtstart).in_time_zone(tzid)
      @tz = tzid
      @exdate = exdate
      @options = parse_options(rrule)
      @max_year = max_year || 9999
      @max_date = DateTime.new(@max_year)
    end

    def all(limit: nil)
      all_until(limit: limit)
    end

    def between(start_date, end_date, limit: nil)
      floored_start_date = floor_to_seconds(start_date)
      floored_end_date = floor_to_seconds(end_date)
      all_until(end_date: floored_end_date, limit: limit).reject { |instance| instance < floored_start_date }
    end

    def each
      return enum_for(:each) unless block_given?

      context = Context.new(options, dtstart, tz)
      context.rebuild(dtstart.year, dtstart.month)

      timeset = options[:timeset]
      count = options[:count]

      filters = []
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

      frequency = Frequency.for_options(options).new(context, filters, generator, timeset)

      loop do
        return if frequency.current_date.year > max_year

        frequency.next_occurrences.each do |this_result|
          next if this_result < dtstart
          return if options[:until] && this_result > options[:until]
          return if count && (count -= 1) < 0
          yield this_result unless exdate.include?(this_result)
        end
      end
    end

    def next
      enumerator.next
    end

    private

    attr_reader :options, :max_year, :max_date

    def floor_to_seconds(date)
      # This removes all sub-second and floors it to the second level.
      # Sub-second level calculations breaks a lot of assumptions in this
      # library and rounding it may also cause unexpected inequalities.
      Time.at(date.to_i)
    end

    def enumerator
      @enumerator ||= to_enum
    end

    def all_until(end_date: max_date, limit: nil)
      limit ? take(limit) : take_while { |date| date <= end_date }
    end

    def parse_options(rule)
      options = { interval: 1, wkst: 1 }

      params = rule.split(';')
      params.each do |param|
        option, value = param.split('=')

        case option
        when 'FREQ'
          options[:freq] = value
        when 'COUNT'
          i = begin
            Integer(value)
          rescue ArgumentError
            raise InvalidRRule, "COUNT must be a non-negative integer"
          end
          raise InvalidRRule, "COUNT must be a non-negative integer" if i < 0
          options[:count] = i
        when 'UNTIL'
          options[:until] = Time.parse(value)
        when 'INTERVAL'
          i = Integer(value) rescue 0
          raise InvalidRRule, "INTERVAL must be a positive integer" unless i > 0
          options[:interval] = i
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
          options[:simple_weekly] = true
          options[:byweekday] = [Weekday.new(dtstart.wday)]
        end
      end

      unless options[:byweekday].nil?
        options[:byweekday], options[:bynweekday] = options[:byweekday].partition { |wday| wday.ordinal.nil? }
      end

      options[:timeset] = [{ hour: dtstart.hour, minute: dtstart.min, second: dtstart.sec }]

      options
    end

    def count_or_interval_present?
      options[:count].present? || (options[:interval].present? && options[:interval] > 1)
    end
  end
end
