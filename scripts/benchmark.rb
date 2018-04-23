$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../lib/'))
require 'rrule'
include Benchmark

rules_to_benchmark = ['FREQ=WEEKLY', 'FREQ=WEEKLY;BYDAY=WE']
rrule_version = '0.3.0'

puts "Benchmarking rules in version #{rrule_version}\n"
Benchmark.benchmark(CAPTION, rules_to_benchmark.map(&:size).max, FORMAT) do |bm|
  rules_to_benchmark.each do |rule|
    rrule = RRule.parse(rule, dtstart: Time.parse('Wed Jan 30 09:00:00 PST 2013'), tzid: 'America/Chicago')
    bm.report(rule) do
      1000.times { rrule.between(Time.parse('Sun Jul 31 22:00:00 PDT 2016'), Time.parse('Wed Aug 31 21:59:59 PDT 2016')) }
    end
  end
end
puts "\n"
