# frozen_string_literal: true

module RRule
  # Based off https://github.com/jakubroztocil/rrule/blob/master/src/nlp/totext.ts
  #
  class Humanizer
    attr_reader :rrule, :options

    OPTION_ATTRIBUTE_RE = /_option/.freeze

    DAY_NAMES = %w[
      Sunday
      Monday
      Tuesday
      Wednesday
      Thursday
      Friday
      Saturday
    ].freeze

    def initialize(rrule, options)
      @rrule = rrule
      @options = options

      # Define instance method for each of the options.
      options.each { |name, value| define_singleton_method("#{name}_option") { value } }
    end

    def to_s
      @buffer = 'every'

      send freq_option.downcase

      if until_option
        raise 'Implement Until'
      elsif count_option
        add 'for'
        add count_option
        add plural?(count_option) ? 'times' : 'time'
      end

      @buffer
    end

    # Return nil if we're trying to access an option that isn't present.
    def method_missing(method_name, *args)
      if method_name.to_s.match?(OPTION_ATTRIBUTE_RE)
        nil
      else
        super
      end
    end

    def respond_to_missing?(method_name)
      super || method_name.to_s.match?(OPTION_ATTRIBUTE_RE)
    end

    protected

      def list(arr, formatter, final_delimiter = nil, delimiter: ',')
        *rest, middle, tail = arr.map(&formatter)

        if final_delimiter
          [*rest, [middle, tail].compact.join(" #{final_delimiter} ")].join("#{delimiter} ")
        else
          [*rest, middle, tail].compact.join("#{delimiter} ")
        end
      end

      def add(string)
        @buffer += " #{string}"
      end

      def plural?(num)
        num.to_i % 100 != 1
      end

      def daily
        add interval_option if interval_option != 1

        if byweekday_option && weekdays?
          add plural?(interval_option) ? 'weekdays' : 'weekday'
        else
          add plural?(interval_option) ? 'days' : 'day'
        end

        if bymonth_option
          add 'in'
          _bymonth
        end

        if bymonthday_option
          _bymonthday
        elsif byweekday_option
          _byweekday
        elsif byhour_option
          _byhour
        end
      end

      def weekly
        if interval_option != 1
          add interval_option
          add plural?(interval_option) ? 'weeks' : 'week'
        end

        if byweekday_option && weekdays?
          if interval_option == 1
            add plural?(interval_option) ? 'weekdays' : 'weekday'
          else
            add 'on'
            add 'weekdays'
          end
        elsif byweekday_option && every_day?
          add plural?(interval_option) ? 'days' : 'day'
        else
          add 'week' if interval_option == 1

          if bymonth_option
            add 'in'
            _bymonth
          end

          if bymonthday_option
            _bymonthday
          elsif byweekday_option
            _byweekday
          end
        end
      end

      def monthly
        if bymonth_option
          if interval_option != 1
            add interval_option
            add 'months'
            add 'in' if plural?(interval_option)
          end

          _bymonth
        else
          add interval_option if interval_option != 1

          add plural?(interval_option) ? 'months' : 'month'
        end

        if bymonthday_option
          _bymonthday
        elsif byweekday_option && weekdays?
          add 'on'
          add 'weekdays'
        elsif byweekday_option || bynweekday_option
          _byweekday
        end
      end

      def weekdaytext(day)
        [day.ordinal && nth(day.ordinal), DAY_NAMES[day.index]].compact.join(' ')
      end

      def all_weeks?
        bynweekday_option.all? { |option| option.ordinal.nil? }
      end

      def every_day?
        byweekday_option.sort_by(&:index).map { |day| WEEKDAYS[day.index]} == RRule::WEEKDAYS
      end

      def weekdays?
        return false if byweekday_option.none?

        byweekday_option.sort_by(&:index).map { |day| WEEKDAYS[day.index]} == RRule::WEEKDAYS - %w[SA SU]
      end

      def _bymonth
        add list(this.options.bymonth, method(:monthtext), 'and')
      end

      def _byweekday
        if byweekday_option.any?
          add 'on'
          add list(byweekday_option, method(:weekdaytext))
        end

        return unless bynweekday_option.any?

        add 'and' if all_weeks?
        add 'on the'
        add list(bynweekday_option, method(:weekdaytext), 'and')
      end

      def _byhour
        add 'at'
        add list byhour_option, :to_s, 'and'
      end

      def nth(ordinal)
        return 'last' if ordinal == -1

        nth =
          case npos = ordinal.abs
          when 1, 21, 31
            "#{npos}st"
          when 2, 22
            "#{npos}nd"
          when 3, 23
            "#{npos}rd"
          else
            "#{npos}th"
          end

        ordinal < 0 ? "#{nth} last" : nth
      end
  end
end
