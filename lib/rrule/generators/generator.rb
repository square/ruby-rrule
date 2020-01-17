# frozen_string_literal: true

module RRule
  class Generator
    attr_reader :context

    def initialize(context)
      @context = context
    end

    def process_timeset(date, timeset)
      timeset.map do |time|
        hour_sets = (
          Array.wrap(time[:hour]).sort.map do |hour|
            Array.wrap(time[:minute]).sort.map do  |minute|
              Array.wrap(time[:second]).sort.map{ |second| [hour, minute, second]}
            end
          end
        ).flatten(2)

        Time.use_zone(context.tz) do
          hour_sets.map do |hour, minute, second|
            Time.zone.local(
              date.year,
              date.month,
              date.day,
              hour,
              minute,
              second
            )
          end
        end
      end.flatten
    end
  end
end
