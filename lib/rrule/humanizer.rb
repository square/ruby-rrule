module RRule
  class Humanizer
    attr_reader :rrule, :options

    def initialize rrule, options
      @rrule, @options = rrule, options
      @text = ''
    end

    def to_s
      @text = 'every'

      send options[:freq].downcase

      if until_option = options[:until]
        raise 'Implement Until'
      elsif count_option = options[:count]
        add 'for'
        add count_option
        add plural?(count_option) ? 'times' : 'time'
      end

      @text
    end

    protected

      def list(arr, formatter, finalDelim, delim: ',')
        arr.map(&formatter).join(delim + ' ')
      end

      def add string
        @text += " #{string}"
      end

      def plural? n
        n.to_i % 100 != 1
      end

      def weekly
      end

      def monthly
        interval = options[:interval]

        if bymonth = options[:bymonth]
          if interval != 1
            add interval
            add 'months'
            add 'in' if plural?(interval)
          end

          _bymonth
        else
          add interval if interval != 1

          add plural?(interval) ? 'months' : 'month'
        end

        if options[:bymonthday]
          _bymonthday
        elsif options[:byweekday] && weekdays?(options[:byweekday])
          add 'on'
          add 'weekdays'
        elsif options[:byweekday] || options[:bynweekday]
          _byweekday
        end
      end

    private

      def weekdaytext day
        "#{day.nth} #{day.full_name}"
      end

      def weekdays? byweekday
        return false if byweekday.none?

        raise 'Implement Weekdays'
      end

      def _bymonth
        add list(this.options.bymonth, method(:monthtext), 'and')
      end

      def _byweekday
        if options[:bynweekday]
          add 'on the'
          add list(options[:bynweekday], method(:weekdaytext), 'and')
        end
      end
  end
end
