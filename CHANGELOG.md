Change Log
==========

Version 0.5.0 *(2022-03-14)*
----------------------------
Add #from method to Rule object

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
