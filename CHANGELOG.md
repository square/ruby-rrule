Change Log
==========

Version 0.7.0 *(2025-10-20)*
----------------------------
## What's Changed
* Add support for `YEARLY` `BYMONTHDAY` https://github.com/square/ruby-rrule/pull/69

Version 0.6.0 *(2024-03-07)*
----------------------------
## What's Changed
* Test support for Ruby 3.1 by @rmitchell-sq in https://github.com/square/ruby-rrule/pull/43
* Rule#between didn't work when `limit` was provided by @edruder in https://github.com/square/ruby-rrule/pull/44
* Added Rule#from by @edruder in https://github.com/square/ruby-rrule/pull/45
* Added Rule#to_s by @Andy9822 in https://github.com/square/ruby-rrule/pull/50
* Implement `RRule::Rule#humanize` by @craigmcnamara in https://github.com/square/ruby-rrule/pull/49
* Update missing documentation for version 0.5.0 by @rmitchell-sq in https://github.com/square/ruby-rrule/pull/53
* Pivot from Travis CI to GitHub Actions by @leoarnold in https://github.com/square/ruby-rrule/pull/48
* Updating supported Rubies to add new versions and remove EOL ones by @rmitchell-sq in https://github.com/square/ruby-rrule/pull/56
* Implement `RRule::Rule#is_finite?` by @bahriddin in https://github.com/square/ruby-rrule/pull/55

## New Contributors
* @edruder made their first contribution in https://github.com/square/ruby-rrule/pull/44
* @Andy9822 made their first contribution in https://github.com/square/ruby-rrule/pull/50
* @craigmcnamara made their first contribution in https://github.com/square/ruby-rrule/pull/49
* @bahriddin made their first contribution in https://github.com/square/ruby-rrule/pull/55

**Full Changelog**: https://github.com/square/ruby-rrule/compare/v0.4.4...v0.5.1

Version 0.5.0 *(2022-03-14)*
----------------------------
Added `#from` method. Added test support for Ruby 3.1. Fixed bug in `#between` method when `limit` was provided.

Version 0.4.4 *(2022-03-01)*
----------------------------
Remove constraint on ActiveSupport version

Version 0.4.3 *(2021-08-10)*
----------------------------
Adding support for multiple versions of ActiveSupport, up until at least ActiveSupport 6
Handle case where DTSTART is a date
Several bugfixes (fix weekday ordinal matching, BYDAY calculations with and without ordinals)

Version 0.4.2 *(2019-02-05)*
----------------------------
Truncate the floor_date option if it's less than the dtstart option

Version 0.4.1 *(2018-11-28)*
----------------------------
Fix bug in SimpleWeekly when ENV['TZ'] was not equal to time zone of rrule


Version 0.1.0 *(2017-06-06)*
----------------------------

Initial release.
