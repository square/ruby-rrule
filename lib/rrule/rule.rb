# frozen_string_literal: true

module RRule
  class Rule
    include Enumerable

    attr_reader :dtstart, :tz, :exdate

    def initialize(rrule, dtstart: Time.now, tzid: 'UTC', exdate: [], max_year: nil)
      @tz = tzid
      @rrule = rrule
      @dtstart = dtstart.is_a?(Date) ? dtstart : floor_to_seconds_in_timezone(dtstart)
      @exdate = exdate
      @options = parse_options(rrule)
      @frequency_type = Frequency.for_options(options)
      @max_year = max_year || 9999
      @max_date = DateTime.new(@max_year)
    end

    def to_s
      @rrule
    end

    def all(limit: nil)
      all_until(limit: limit)
    end

    def between(start_date, end_date, limit: nil)
      floored_start_date = floor_to_seconds_in_timezone(start_date)
      floored_end_date = floor_to_seconds_in_timezone(end_date)
      all_until(start_date: floored_start_date, end_date: floored_end_date, limit: limit).reject { |instance| instance < floored_start_date }
    end

    def from(start_date, limit:)
      floored_start_date = floor_to_seconds_in_timezone(start_date)
      all_until(start_date: floored_start_date, limit: limit).reject { |instance| instance < floored_start_date }
    end

    def each(floor_date: nil)
      # If we have a COUNT or INTERVAL option, we have to start at dtstart, because those are relative to dtstart
      floor_date = dtstart if count_or_interval_present? || floor_date.nil? || dtstart > floor_date

      return enum_for(:each, floor_date: floor_date) unless block_given?
      context = Context.new(options, dtstart, tz)
      context.rebuild(floor_date.year, floor_date.month)

      timeset = options[:timeset]
      count = options[:count]

      filters = []
      filters.push(ByMonth.new(options[:bymonth], context)) if options[:bymonth]

      filters.push(ByWeekNumber.new(options[:byweekno], context)) if options[:byweekno]

      filters.push(ByWeekDay.new(options[:byweekday], context)) if options[:byweekday]

      filters.push(ByYearDay.new(options[:byyearday], context)) if options[:byyearday]

      filters.push(ByMonthDay.new(options[:bymonthday], context)) if options[:bymonthday]

      generator = if options[:bysetpos]
        BySetPosition.new(options[:bysetpos], context)
      else
        AllOccurrences.new(context)
      end

      frequency = Frequency.for_options(options).new(context, filters, generator, timeset, start_date: floor_date)

      loop do
        return if frequency.current_date.year > max_year

        frequency.next_occurrences.each do |this_result|
          next if this_result < dtstart
          next if floor_date.present? && this_result < floor_date
          return if options[:until] && this_result > options[:until]
          return if count && (count -= 1) < 0
          yield this_result unless exdate.include?(this_result)
        end
      end
    end

    def next
      enumerator.next
    end

    def humanize
      Humanizer.new(self, options).to_s
    end

    def has_end_limit?
      [:count, :until].any? { |opt| options.include?(opt) }
    end

    private

    attr_reader :options, :max_year, :max_date, :frequency_type

    def floor_to_seconds_in_timezone(date)
      # This removes all sub-second and floors it to the second level.
      # Sub-second level calculations breaks a lot of assumptions in this
      # library and rounding it may also cause unexpected inequalities.
      Time.at(date.to_i).in_time_zone(tz)
    end

    def enumerator
      @enumerator ||= to_enum
    end

    def all_until(start_date: nil, end_date: max_date, limit: nil)
      count = 0
      each(floor_date: start_date).take_while do |date|
        if limit
          date <= end_date && (count += 1) <= limit
        else
          date <= end_date
        end
      end
    end

    def parse_options(rule)
      options = { interval: 1, wkst: 1 }

      # Remove RRULE: prefix to prevent parsing options incorrectly.
      params = rule.delete_prefix('RRULE:').split(';')
      params.each do |param|
        option, value = param.split('=')

        case option
        when 'FREQ'
          options[:freq] = value
        when 'COUNT'
          i = begin
            Integer(value)
          rescue ArgumentError
            raise InvalidRRule, 'COUNT must be a non-negative integer'
          end
          raise InvalidRRule, 'COUNT must be a non-negative integer' if i < 0
          options[:count] = i
        when 'UNTIL'
          # The value of the UNTIL rule part MUST have the same
          # value type as the "DTSTART" property.
          options[:until] = @dtstart.is_a?(Date) ? Date.parse(value) : Time.parse(value)
        when 'INTERVAL'
          i = Integer(value) rescue 0
          raise InvalidRRule, 'INTERVAL must be a positive integer' unless i > 0
          options[:interval] = i
        when 'BYHOUR'
          options[:byhour] = value.split(',').compact.map(&:to_i)
        when 'BYMINUTE'
          options[:byminute] = value.split(',').compact.map(&:to_i)
        when 'BYSECOND'
          options[:bysecond] = value.split(',').compact.map(&:to_i)
        when 'BYDAY'
          options[:byweekday] = value.split(',').map { |day| Weekday.parse(day) }
        when 'BYSETPOS'
          options[:bysetpos] = value.split(',').map(&:to_i)
        when 'WKST'
          options[:wkst] = RRule::WEEKDAYS.index(value)
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

      unless options[:byweekno] || options[:byyearday] || options[:bymonthday] || options[:byweekday]
        case options[:freq]
        when 'YEARLY'
          options[:bymonth] = [dtstart.month] unless options[:bymonth]
          options[:bymonthday] = [dtstart.day]
        when 'MONTHLY'
          options[:bymonthday] = [dtstart.day]
        when 'WEEKLY'
          options[:simple_weekly] = true
          options[:byweekday] = [Weekday.new(dtstart.wday)]
        end
      end

      options[:byweekday], options[:bynweekday] = options[:byweekday].partition { |wday| wday.ordinal.nil? } unless options[:byweekday].nil?

      # The BYSECOND, BYMINUTE and BYHOUR rule parts MUST NOT be specified
      # when the associated "DTSTART" property has a DATE value type.
      # These rule parts MUST be ignored in RECUR value that violate the
      # above requirement
      options[:timeset] = [{ hour: (options[:byhour].presence || dtstart.hour), minute: (options[:byminute].presence || dtstart.min), second: (options[:bysecond].presence || dtstart.sec) }] unless dtstart.is_a?(Date)

      options
    end

    def count_or_interval_present?
      options[:count].present? || (options[:interval].present? && options[:interval] > 1)
    end
  end
end
