# rrule

## Description

rrule is a minimalist library for expanding RRULEs, with a goal of being fully compliant with [iCalendar spec](https://tools.ietf.org/html/rfc2445).

## Examples

To install this gem, add it to your Gemfile:

```ruby
gem 'rrule'
```

Create an rrule with an RRULE string:

```ruby
rrule = RRule::Rule.new('FREQ=DAILY;COUNT=3')
rrule = RRule.parse('FREQ=DAILY;COUNT=3') # alternate syntax
```

### Generating recurrence instances

Either generate all instances of a recurrence, or generate instances in a range:

```ruby
rrule.all
=> [2016-06-23 16:45:32 -0700, 2016-06-24 16:45:32 -0700, 2016-06-25 16:45:32 -0700]
rrule.between(Time.new(2016, 6, 23), Time.new(2016, 6, 24))
=> [2016-06-23 16:45:32 -0700]
```

You can limit the number of instances that are returned with the `limit` option:

```ruby
rrule = RRule::Rule.new('FREQ=DAILY;COUNT=3')
rrule.all(limit: 2)
=> [2016-06-23 16:45:32 -0700, 2016-06-24 16:45:32 -0700]
```

By default the DTSTART of the recurrence is the current time, but this can be overriden with the `dtstart` option:

```ruby
rrule = RRule::Rule.new('FREQ=DAILY;COUNT=3', dtstart: Time.new(2016, 7, 1))
rrule.all
=> [2016-07-01 00:00:00 -0700, 2016-07-02 00:00:00 -0700, 2016-07-03 00:00:00 -0700]
```

Unless your rrule should be evaluated in UTC time, you should also pass an explicit timezone in the `tzid` option to ensure that daylight saving time boundaries are respected, etc.:

```ruby
rrule = RRule::Rule.new('FREQ=DAILY;COUNT=3', dtstart: Time.new(2016, 7, 1), tzid: 'America/Los_Angeles')
```

### Exceptions (EXDATEs)

To define exception dates, pass the `exdate` option:

```ruby
rrule = RRule::Rule.new('FREQ=DAILY;COUNT=3', dtstart: Time.new(2016, 7, 1), exdate: [DateTime.parse('2016-07-02 00:00:00 -0700'])
rrule.all
=> [2016-07-01 00:00:00 -0700, 2016-07-03 00:00:00 -0700]
```

## License

Copyright 2015 Square Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
