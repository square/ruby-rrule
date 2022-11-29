module RRule
  class Humanizer
    attr_reader :rrule, :options

    def initialize rrule, options
      @rrule, @options = rrule, options

      # Define instance method for each of the options.
      options.each do |name, value|
        define_singleton_method("#{name}_option") { value }
      end
    end

    def to_s
      @text = 'every'

      send freq_option.downcase

      if until_option
        raise 'Implement Until'
      elsif count_option
        add 'for'
        add count_option
        add plural?(count_option) ? 'times' : 'time'
      end

      @text
    end

    # Get crazy with it.
    def method_missing method_name, *args
      if method_name.to_s.match?(/_option/)
        nil
      else
        super
      end
    end

    protected

      def list(arr, formatter, finalDelim = nil, delim: ',')
        arr.map(&formatter).join(delim + ' ')
      end

      def add string
        @text += " #{string}"
      end

      def plural? n
        n.to_i % 100 != 1
      end

      def weekly
        if interval_option != 1
          add interval_option
          add plural?(interval_option) ? 'weeks' : 'week'
        end

        case
        when byweekday_option && weekdays?(byweekday_option)
          if interval_option == 1
            add plural?(interval_option) ? 'weekdays' : 'weekday'
          else
            add 'on'
            add 'weekdays'
          end
        when byweekday_option && every_day?(byweekday_option)
          add plural?(interval_option) ? 'days' : 'day'
        else
          add 'week' if interval_option == 1

          if bymonth_option
            add 'in'
            _bymonth
          end

          case
          when bymonthday_option
            _bymonthday
          when byweekday_option
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
        elsif byweekday_option && weekdays?(byweekday_option)
          add 'on'
          add 'weekdays'
        elsif byweekday_option || bynweekday_option
          _byweekday
        end
      end

    private

      def weekdaytext day
        [day.ordinal && day.nth, day.full_name].compact.join(' ')
      end

      def every_day? days
        days.sort_by { |d| d.index }.map(&:short_name) == RRule::WEEKDAYS
      end

      def weekdays? days
        return false if days.none?

        days.sort_by { |d| d.index }.map(&:short_name) == RRule::WEEKDAYS - %w(SA SU)
      end

      def _bymonth
        add list(this.options.bymonth, method(:monthtext), 'and')
      end

      def _byweekday
        if byweekday_option.any?
          add 'on'
          add list(byweekday_option, method(:weekdaytext))
        end

        if bynweekday_option.any?
          add 'on the'
          add list(bynweekday_option, method(:weekdaytext), 'and')
        end
      end
  end
end
