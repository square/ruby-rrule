# frozen_string_literal: true

require 'active_support/all'

module RRule
  autoload :Rule, 'rrule/rule'
  autoload :Context, 'rrule/context'
  autoload :Weekday, 'rrule/weekday'
  autoload :Humanizer, 'rrule/humanizer'

  autoload :Frequency, 'rrule/frequencies/frequency'
  autoload :Daily, 'rrule/frequencies/daily'
  autoload :Weekly, 'rrule/frequencies/weekly'
  autoload :SimpleWeekly, 'rrule/frequencies/simple_weekly'
  autoload :Monthly, 'rrule/frequencies/monthly'
  autoload :Yearly, 'rrule/frequencies/yearly'

  autoload :ByMonth, 'rrule/filters/by_month'
  autoload :ByWeekNumber, 'rrule/filters/by_week_number'
  autoload :ByWeekDay, 'rrule/filters/by_week_day'
  autoload :ByYearDay, 'rrule/filters/by_year_day'
  autoload :ByMonthDay, 'rrule/filters/by_month_day'

  autoload :Generator, 'rrule/generators/generator'
  autoload :AllOccurrences, 'rrule/generators/all_occurrences'
  autoload :BySetPosition, 'rrule/generators/by_set_position'

  WEEKDAYS = %w[SU MO TU WE TH FR SA].freeze

  def self.parse(rrule, **options)
    Rule.new(rrule, **options)
  end

  class InvalidRRule < StandardError; end
end
