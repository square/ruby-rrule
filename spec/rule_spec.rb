# frozen_string_literal: true

require 'spec_helper'

describe RRule::Rule do
  describe '#next' do
    it 'can sequentially return values' do
      rrule = 'FREQ=DAILY;COUNT=10'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)

      expect(rrule.next).to eql Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      expect(rrule.next).to eql Time.parse('Wed Sep  3 06:00:00 PDT 1997')
      expect(rrule.next).to eql Time.parse('Thu Sep  4 06:00:00 PDT 1997')
    end
  end

  describe '#take' do
    it 'can return the next N instances' do
      rrule = 'FREQ=DAILY;COUNT=10'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.take(3)).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Wed Sep  3 06:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 06:00:00 PDT 1997'),
      ])
    end
  end

  describe 'iterating with a floor_date' do
    describe 'No COUNT or INTERVAL > 1' do
      it 'uses the floor_date provided when iterating' do
        rrule = 'FREQ=DAILY'
        dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
        timezone = 'America/New_York'

        rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)

        floor_date = Time.parse('Mon Sep  3 06:00:00 PDT 2018')

        expect(rrule.each(floor_date: floor_date).take(3)).to match_array([
          Time.parse('Tue Sep  3 06:00:00 PDT 2018'),
          Time.parse('Wed Sep  4 06:00:00 PDT 2018'),
          Time.parse('Thu Sep  5 06:00:00 PDT 2018'),
        ])
      end
    end

    describe 'COUNT present' do
      it 'starts at dtstart when iterating' do
        rrule = 'FREQ=DAILY;COUNT=10'
        dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
        timezone = 'America/New_York'

        rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)

        floor_date = Time.parse('Mon Sep  3 06:00:00 PDT 2018')

        expect(rrule.each(floor_date: floor_date).take(3)).to match_array([
          Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
          Time.parse('Wed Sep  3 06:00:00 PDT 1997'),
          Time.parse('Thu Sep  4 06:00:00 PDT 1997'),
        ])
      end
    end

    describe 'INTERVAL present' do
      it 'starts at dtstart when iterating' do
        rrule = 'FREQ=DAILY;INTERVAL=10'
        dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
        timezone = 'America/New_York'

        rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)

        floor_date = Time.parse('Mon Sep  3 06:00:00 PDT 2018')

        expect(rrule.each(floor_date: floor_date).take(3)).to match_array([
          Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
          Time.parse('Fri Sep 12 06:00:00 PDT 1997'),
          Time.parse('Mon Sep 22 06:00:00 PDT 1997'),
        ])
      end
    end

    describe 'INTERVAL AND COUNT present' do
      it 'starts at dtstart when iterating' do
        rrule = 'FREQ=DAILY;INTERVAL=10;COUNT=5'
        dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
        timezone = 'America/New_York'

        rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)

        floor_date = Time.parse('Mon Sep  3 06:00:00 PDT 2018')

        expect(rrule.each(floor_date: floor_date).take(3)).to match_array([
          Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
          Time.parse('Fri Sep 12 06:00:00 PDT 1997'),
          Time.parse('Mon Sep 22 06:00:00 PDT 1997'),
        ])
      end
    end

    describe 'floor_date < dtstart' do
      it 'starts at dtstart when iterating' do
        rrule = 'FREQ=DAILY'
        dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
        timezone = 'America/New_York'

        rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)

        floor_date = Time.parse('Sun Sep  1 06:00:00 PDT 0097')

        Timeout.timeout(2) do
          expect(rrule.each(floor_date: floor_date).take(3)).to match_array([
            Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
            Time.parse('Wed Sep  3 06:00:00 PDT 1997'),
            Time.parse('Thu Sep  4 06:00:00 PDT 1997'),
          ])
        end
      end
    end
  end

  describe '#all' do
    it 'returns the correct result with an rrule of FREQ=DAILY;COUNT=10' do
      rrule = 'FREQ=DAILY;COUNT=10'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Wed Sep  3 06:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 06:00:00 PDT 1997'),
        Time.parse('Fri Sep  5 06:00:00 PDT 1997'),
        Time.parse('Sat Sep  6 06:00:00 PDT 1997'),
        Time.parse('Sun Sep  7 06:00:00 PDT 1997'),
        Time.parse('Mon Sep  8 06:00:00 PDT 1997'),
        Time.parse('Tue Sep  9 06:00:00 PDT 1997'),
        Time.parse('Wed Sep 10 06:00:00 PDT 1997'),
        Time.parse('Thu Sep 11 06:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;COUNT=10 and a limit' do
      rrule = 'FREQ=DAILY;COUNT=10'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all(limit: 5)).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Wed Sep  3 06:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 06:00:00 PDT 1997'),
        Time.parse('Fri Sep  5 06:00:00 PDT 1997'),
        Time.parse('Sat Sep  6 06:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;UNTIL=19971224T000000Z' do
      rrule = 'FREQ=DAILY;UNTIL=19971224T000000Z'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Wed Sep  3 06:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 06:00:00 PDT 1997'),
        Time.parse('Fri Sep  5 06:00:00 PDT 1997'),
        Time.parse('Sat Sep  6 06:00:00 PDT 1997'),
        Time.parse('Sun Sep  7 06:00:00 PDT 1997'),
        Time.parse('Mon Sep  8 06:00:00 PDT 1997'),
        Time.parse('Tue Sep  9 06:00:00 PDT 1997'),
        Time.parse('Wed Sep 10 06:00:00 PDT 1997'),
        Time.parse('Thu Sep 11 06:00:00 PDT 1997'),
        Time.parse('Fri Sep 12 06:00:00 PDT 1997'),
        Time.parse('Sat Sep 13 06:00:00 PDT 1997'),
        Time.parse('Sun Sep 14 06:00:00 PDT 1997'),
        Time.parse('Mon Sep 15 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 06:00:00 PDT 1997'),
        Time.parse('Wed Sep 17 06:00:00 PDT 1997'),
        Time.parse('Thu Sep 18 06:00:00 PDT 1997'),
        Time.parse('Fri Sep 19 06:00:00 PDT 1997'),
        Time.parse('Sat Sep 20 06:00:00 PDT 1997'),
        Time.parse('Sun Sep 21 06:00:00 PDT 1997'),
        Time.parse('Mon Sep 22 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 23 06:00:00 PDT 1997'),
        Time.parse('Wed Sep 24 06:00:00 PDT 1997'),
        Time.parse('Thu Sep 25 06:00:00 PDT 1997'),
        Time.parse('Fri Sep 26 06:00:00 PDT 1997'),
        Time.parse('Sat Sep 27 06:00:00 PDT 1997'),
        Time.parse('Sun Sep 28 06:00:00 PDT 1997'),
        Time.parse('Mon Sep 29 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 30 06:00:00 PDT 1997'),
        Time.parse('Wed Oct  1 06:00:00 PDT 1997'),
        Time.parse('Thu Oct  2 06:00:00 PDT 1997'),
        Time.parse('Fri Oct  3 06:00:00 PDT 1997'),
        Time.parse('Sat Oct  4 06:00:00 PDT 1997'),
        Time.parse('Sun Oct  5 06:00:00 PDT 1997'),
        Time.parse('Mon Oct  6 06:00:00 PDT 1997'),
        Time.parse('Tue Oct  7 06:00:00 PDT 1997'),
        Time.parse('Wed Oct  8 06:00:00 PDT 1997'),
        Time.parse('Thu Oct  9 06:00:00 PDT 1997'),
        Time.parse('Fri Oct 10 06:00:00 PDT 1997'),
        Time.parse('Sat Oct 11 06:00:00 PDT 1997'),
        Time.parse('Sun Oct 12 06:00:00 PDT 1997'),
        Time.parse('Mon Oct 13 06:00:00 PDT 1997'),
        Time.parse('Tue Oct 14 06:00:00 PDT 1997'),
        Time.parse('Wed Oct 15 06:00:00 PDT 1997'),
        Time.parse('Thu Oct 16 06:00:00 PDT 1997'),
        Time.parse('Fri Oct 17 06:00:00 PDT 1997'),
        Time.parse('Sat Oct 18 06:00:00 PDT 1997'),
        Time.parse('Sun Oct 19 06:00:00 PDT 1997'),
        Time.parse('Mon Oct 20 06:00:00 PDT 1997'),
        Time.parse('Tue Oct 21 06:00:00 PDT 1997'),
        Time.parse('Wed Oct 22 06:00:00 PDT 1997'),
        Time.parse('Thu Oct 23 06:00:00 PDT 1997'),
        Time.parse('Fri Oct 24 06:00:00 PDT 1997'),
        Time.parse('Sat Oct 25 06:00:00 PDT 1997'),
        Time.parse('Sun Oct 26 06:00:00 PST 1997'),
        Time.parse('Mon Oct 27 06:00:00 PST 1997'),
        Time.parse('Tue Oct 28 06:00:00 PST 1997'),
        Time.parse('Wed Oct 29 06:00:00 PST 1997'),
        Time.parse('Thu Oct 30 06:00:00 PST 1997'),
        Time.parse('Fri Oct 31 06:00:00 PST 1997'),
        Time.parse('Sat Nov  1 06:00:00 PST 1997'),
        Time.parse('Sun Nov  2 06:00:00 PST 1997'),
        Time.parse('Mon Nov  3 06:00:00 PST 1997'),
        Time.parse('Tue Nov  4 06:00:00 PST 1997'),
        Time.parse('Wed Nov  5 06:00:00 PST 1997'),
        Time.parse('Thu Nov  6 06:00:00 PST 1997'),
        Time.parse('Fri Nov  7 06:00:00 PST 1997'),
        Time.parse('Sat Nov  8 06:00:00 PST 1997'),
        Time.parse('Sun Nov  9 06:00:00 PST 1997'),
        Time.parse('Mon Nov 10 06:00:00 PST 1997'),
        Time.parse('Tue Nov 11 06:00:00 PST 1997'),
        Time.parse('Wed Nov 12 06:00:00 PST 1997'),
        Time.parse('Thu Nov 13 06:00:00 PST 1997'),
        Time.parse('Fri Nov 14 06:00:00 PST 1997'),
        Time.parse('Sat Nov 15 06:00:00 PST 1997'),
        Time.parse('Sun Nov 16 06:00:00 PST 1997'),
        Time.parse('Mon Nov 17 06:00:00 PST 1997'),
        Time.parse('Tue Nov 18 06:00:00 PST 1997'),
        Time.parse('Wed Nov 19 06:00:00 PST 1997'),
        Time.parse('Thu Nov 20 06:00:00 PST 1997'),
        Time.parse('Fri Nov 21 06:00:00 PST 1997'),
        Time.parse('Sat Nov 22 06:00:00 PST 1997'),
        Time.parse('Sun Nov 23 06:00:00 PST 1997'),
        Time.parse('Mon Nov 24 06:00:00 PST 1997'),
        Time.parse('Tue Nov 25 06:00:00 PST 1997'),
        Time.parse('Wed Nov 26 06:00:00 PST 1997'),
        Time.parse('Thu Nov 27 06:00:00 PST 1997'),
        Time.parse('Fri Nov 28 06:00:00 PST 1997'),
        Time.parse('Sat Nov 29 06:00:00 PST 1997'),
        Time.parse('Sun Nov 30 06:00:00 PST 1997'),
        Time.parse('Mon Dec  1 06:00:00 PST 1997'),
        Time.parse('Tue Dec  2 06:00:00 PST 1997'),
        Time.parse('Wed Dec  3 06:00:00 PST 1997'),
        Time.parse('Thu Dec  4 06:00:00 PST 1997'),
        Time.parse('Fri Dec  5 06:00:00 PST 1997'),
        Time.parse('Sat Dec  6 06:00:00 PST 1997'),
        Time.parse('Sun Dec  7 06:00:00 PST 1997'),
        Time.parse('Mon Dec  8 06:00:00 PST 1997'),
        Time.parse('Tue Dec  9 06:00:00 PST 1997'),
        Time.parse('Wed Dec 10 06:00:00 PST 1997'),
        Time.parse('Thu Dec 11 06:00:00 PST 1997'),
        Time.parse('Fri Dec 12 06:00:00 PST 1997'),
        Time.parse('Sat Dec 13 06:00:00 PST 1997'),
        Time.parse('Sun Dec 14 06:00:00 PST 1997'),
        Time.parse('Mon Dec 15 06:00:00 PST 1997'),
        Time.parse('Tue Dec 16 06:00:00 PST 1997'),
        Time.parse('Wed Dec 17 06:00:00 PST 1997'),
        Time.parse('Thu Dec 18 06:00:00 PST 1997'),
        Time.parse('Fri Dec 19 06:00:00 PST 1997'),
        Time.parse('Sat Dec 20 06:00:00 PST 1997'),
        Time.parse('Sun Dec 21 06:00:00 PST 1997'),
        Time.parse('Mon Dec 22 06:00:00 PST 1997'),
        Time.parse('Tue Dec 23 06:00:00 PST 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;INTERVAL=10;COUNT=5' do
      rrule = 'FREQ=DAILY;INTERVAL=10;COUNT=5'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Fri Sep 12 06:00:00 PDT 1997'),
        Time.parse('Mon Sep 22 06:00:00 PDT 1997'),
        Time.parse('Thu Oct  2 06:00:00 PDT 1997'),
        Time.parse('Sun Oct 12 06:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;UNTIL=20000131T140000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA' do
      rrule = 'FREQ=YEARLY;UNTIL=20000131T140000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA'
      dtstart = Time.parse('Thu Jan  1 06:00:00 PST 1998')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan  1 06:00:00 PST 1998'),
        Time.parse('Fri Jan  2 06:00:00 PST 1998'),
        Time.parse('Sat Jan  3 06:00:00 PST 1998'),
        Time.parse('Sun Jan  4 06:00:00 PST 1998'),
        Time.parse('Mon Jan  5 06:00:00 PST 1998'),
        Time.parse('Tue Jan  6 06:00:00 PST 1998'),
        Time.parse('Wed Jan  7 06:00:00 PST 1998'),
        Time.parse('Thu Jan  8 06:00:00 PST 1998'),
        Time.parse('Fri Jan  9 06:00:00 PST 1998'),
        Time.parse('Sat Jan 10 06:00:00 PST 1998'),
        Time.parse('Sun Jan 11 06:00:00 PST 1998'),
        Time.parse('Mon Jan 12 06:00:00 PST 1998'),
        Time.parse('Tue Jan 13 06:00:00 PST 1998'),
        Time.parse('Wed Jan 14 06:00:00 PST 1998'),
        Time.parse('Thu Jan 15 06:00:00 PST 1998'),
        Time.parse('Fri Jan 16 06:00:00 PST 1998'),
        Time.parse('Sat Jan 17 06:00:00 PST 1998'),
        Time.parse('Sun Jan 18 06:00:00 PST 1998'),
        Time.parse('Mon Jan 19 06:00:00 PST 1998'),
        Time.parse('Tue Jan 20 06:00:00 PST 1998'),
        Time.parse('Wed Jan 21 06:00:00 PST 1998'),
        Time.parse('Thu Jan 22 06:00:00 PST 1998'),
        Time.parse('Fri Jan 23 06:00:00 PST 1998'),
        Time.parse('Sat Jan 24 06:00:00 PST 1998'),
        Time.parse('Sun Jan 25 06:00:00 PST 1998'),
        Time.parse('Mon Jan 26 06:00:00 PST 1998'),
        Time.parse('Tue Jan 27 06:00:00 PST 1998'),
        Time.parse('Wed Jan 28 06:00:00 PST 1998'),
        Time.parse('Thu Jan 29 06:00:00 PST 1998'),
        Time.parse('Fri Jan 30 06:00:00 PST 1998'),
        Time.parse('Sat Jan 31 06:00:00 PST 1998'),
        Time.parse('Fri Jan  1 06:00:00 PST 1999'),
        Time.parse('Sat Jan  2 06:00:00 PST 1999'),
        Time.parse('Sun Jan  3 06:00:00 PST 1999'),
        Time.parse('Mon Jan  4 06:00:00 PST 1999'),
        Time.parse('Tue Jan  5 06:00:00 PST 1999'),
        Time.parse('Wed Jan  6 06:00:00 PST 1999'),
        Time.parse('Thu Jan  7 06:00:00 PST 1999'),
        Time.parse('Fri Jan  8 06:00:00 PST 1999'),
        Time.parse('Sat Jan  9 06:00:00 PST 1999'),
        Time.parse('Sun Jan 10 06:00:00 PST 1999'),
        Time.parse('Mon Jan 11 06:00:00 PST 1999'),
        Time.parse('Tue Jan 12 06:00:00 PST 1999'),
        Time.parse('Wed Jan 13 06:00:00 PST 1999'),
        Time.parse('Thu Jan 14 06:00:00 PST 1999'),
        Time.parse('Fri Jan 15 06:00:00 PST 1999'),
        Time.parse('Sat Jan 16 06:00:00 PST 1999'),
        Time.parse('Sun Jan 17 06:00:00 PST 1999'),
        Time.parse('Mon Jan 18 06:00:00 PST 1999'),
        Time.parse('Tue Jan 19 06:00:00 PST 1999'),
        Time.parse('Wed Jan 20 06:00:00 PST 1999'),
        Time.parse('Thu Jan 21 06:00:00 PST 1999'),
        Time.parse('Fri Jan 22 06:00:00 PST 1999'),
        Time.parse('Sat Jan 23 06:00:00 PST 1999'),
        Time.parse('Sun Jan 24 06:00:00 PST 1999'),
        Time.parse('Mon Jan 25 06:00:00 PST 1999'),
        Time.parse('Tue Jan 26 06:00:00 PST 1999'),
        Time.parse('Wed Jan 27 06:00:00 PST 1999'),
        Time.parse('Thu Jan 28 06:00:00 PST 1999'),
        Time.parse('Fri Jan 29 06:00:00 PST 1999'),
        Time.parse('Sat Jan 30 06:00:00 PST 1999'),
        Time.parse('Sun Jan 31 06:00:00 PST 1999'),
        Time.parse('Sat Jan  1 06:00:00 PST 2000'),
        Time.parse('Sun Jan  2 06:00:00 PST 2000'),
        Time.parse('Mon Jan  3 06:00:00 PST 2000'),
        Time.parse('Tue Jan  4 06:00:00 PST 2000'),
        Time.parse('Wed Jan  5 06:00:00 PST 2000'),
        Time.parse('Thu Jan  6 06:00:00 PST 2000'),
        Time.parse('Fri Jan  7 06:00:00 PST 2000'),
        Time.parse('Sat Jan  8 06:00:00 PST 2000'),
        Time.parse('Sun Jan  9 06:00:00 PST 2000'),
        Time.parse('Mon Jan 10 06:00:00 PST 2000'),
        Time.parse('Tue Jan 11 06:00:00 PST 2000'),
        Time.parse('Wed Jan 12 06:00:00 PST 2000'),
        Time.parse('Thu Jan 13 06:00:00 PST 2000'),
        Time.parse('Fri Jan 14 06:00:00 PST 2000'),
        Time.parse('Sat Jan 15 06:00:00 PST 2000'),
        Time.parse('Sun Jan 16 06:00:00 PST 2000'),
        Time.parse('Mon Jan 17 06:00:00 PST 2000'),
        Time.parse('Tue Jan 18 06:00:00 PST 2000'),
        Time.parse('Wed Jan 19 06:00:00 PST 2000'),
        Time.parse('Thu Jan 20 06:00:00 PST 2000'),
        Time.parse('Fri Jan 21 06:00:00 PST 2000'),
        Time.parse('Sat Jan 22 06:00:00 PST 2000'),
        Time.parse('Sun Jan 23 06:00:00 PST 2000'),
        Time.parse('Mon Jan 24 06:00:00 PST 2000'),
        Time.parse('Tue Jan 25 06:00:00 PST 2000'),
        Time.parse('Wed Jan 26 06:00:00 PST 2000'),
        Time.parse('Thu Jan 27 06:00:00 PST 2000'),
        Time.parse('Fri Jan 28 06:00:00 PST 2000'),
        Time.parse('Sat Jan 29 06:00:00 PST 2000'),
        Time.parse('Sun Jan 30 06:00:00 PST 2000'),
        Time.parse('Mon Jan 31 06:00:00 PST 2000'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;UNTIL=20000131T140000Z;BYMONTH=1' do
      rrule = 'FREQ=DAILY;UNTIL=20000131T140000Z;BYMONTH=1'
      dtstart = Time.parse('Thu Jan  1 06:00:00 PST 1998')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan  1 06:00:00 PST 1998'),
        Time.parse('Fri Jan  2 06:00:00 PST 1998'),
        Time.parse('Sat Jan  3 06:00:00 PST 1998'),
        Time.parse('Sun Jan  4 06:00:00 PST 1998'),
        Time.parse('Mon Jan  5 06:00:00 PST 1998'),
        Time.parse('Tue Jan  6 06:00:00 PST 1998'),
        Time.parse('Wed Jan  7 06:00:00 PST 1998'),
        Time.parse('Thu Jan  8 06:00:00 PST 1998'),
        Time.parse('Fri Jan  9 06:00:00 PST 1998'),
        Time.parse('Sat Jan 10 06:00:00 PST 1998'),
        Time.parse('Sun Jan 11 06:00:00 PST 1998'),
        Time.parse('Mon Jan 12 06:00:00 PST 1998'),
        Time.parse('Tue Jan 13 06:00:00 PST 1998'),
        Time.parse('Wed Jan 14 06:00:00 PST 1998'),
        Time.parse('Thu Jan 15 06:00:00 PST 1998'),
        Time.parse('Fri Jan 16 06:00:00 PST 1998'),
        Time.parse('Sat Jan 17 06:00:00 PST 1998'),
        Time.parse('Sun Jan 18 06:00:00 PST 1998'),
        Time.parse('Mon Jan 19 06:00:00 PST 1998'),
        Time.parse('Tue Jan 20 06:00:00 PST 1998'),
        Time.parse('Wed Jan 21 06:00:00 PST 1998'),
        Time.parse('Thu Jan 22 06:00:00 PST 1998'),
        Time.parse('Fri Jan 23 06:00:00 PST 1998'),
        Time.parse('Sat Jan 24 06:00:00 PST 1998'),
        Time.parse('Sun Jan 25 06:00:00 PST 1998'),
        Time.parse('Mon Jan 26 06:00:00 PST 1998'),
        Time.parse('Tue Jan 27 06:00:00 PST 1998'),
        Time.parse('Wed Jan 28 06:00:00 PST 1998'),
        Time.parse('Thu Jan 29 06:00:00 PST 1998'),
        Time.parse('Fri Jan 30 06:00:00 PST 1998'),
        Time.parse('Sat Jan 31 06:00:00 PST 1998'),
        Time.parse('Fri Jan  1 06:00:00 PST 1999'),
        Time.parse('Sat Jan  2 06:00:00 PST 1999'),
        Time.parse('Sun Jan  3 06:00:00 PST 1999'),
        Time.parse('Mon Jan  4 06:00:00 PST 1999'),
        Time.parse('Tue Jan  5 06:00:00 PST 1999'),
        Time.parse('Wed Jan  6 06:00:00 PST 1999'),
        Time.parse('Thu Jan  7 06:00:00 PST 1999'),
        Time.parse('Fri Jan  8 06:00:00 PST 1999'),
        Time.parse('Sat Jan  9 06:00:00 PST 1999'),
        Time.parse('Sun Jan 10 06:00:00 PST 1999'),
        Time.parse('Mon Jan 11 06:00:00 PST 1999'),
        Time.parse('Tue Jan 12 06:00:00 PST 1999'),
        Time.parse('Wed Jan 13 06:00:00 PST 1999'),
        Time.parse('Thu Jan 14 06:00:00 PST 1999'),
        Time.parse('Fri Jan 15 06:00:00 PST 1999'),
        Time.parse('Sat Jan 16 06:00:00 PST 1999'),
        Time.parse('Sun Jan 17 06:00:00 PST 1999'),
        Time.parse('Mon Jan 18 06:00:00 PST 1999'),
        Time.parse('Tue Jan 19 06:00:00 PST 1999'),
        Time.parse('Wed Jan 20 06:00:00 PST 1999'),
        Time.parse('Thu Jan 21 06:00:00 PST 1999'),
        Time.parse('Fri Jan 22 06:00:00 PST 1999'),
        Time.parse('Sat Jan 23 06:00:00 PST 1999'),
        Time.parse('Sun Jan 24 06:00:00 PST 1999'),
        Time.parse('Mon Jan 25 06:00:00 PST 1999'),
        Time.parse('Tue Jan 26 06:00:00 PST 1999'),
        Time.parse('Wed Jan 27 06:00:00 PST 1999'),
        Time.parse('Thu Jan 28 06:00:00 PST 1999'),
        Time.parse('Fri Jan 29 06:00:00 PST 1999'),
        Time.parse('Sat Jan 30 06:00:00 PST 1999'),
        Time.parse('Sun Jan 31 06:00:00 PST 1999'),
        Time.parse('Sat Jan  1 06:00:00 PST 2000'),
        Time.parse('Sun Jan  2 06:00:00 PST 2000'),
        Time.parse('Mon Jan  3 06:00:00 PST 2000'),
        Time.parse('Tue Jan  4 06:00:00 PST 2000'),
        Time.parse('Wed Jan  5 06:00:00 PST 2000'),
        Time.parse('Thu Jan  6 06:00:00 PST 2000'),
        Time.parse('Fri Jan  7 06:00:00 PST 2000'),
        Time.parse('Sat Jan  8 06:00:00 PST 2000'),
        Time.parse('Sun Jan  9 06:00:00 PST 2000'),
        Time.parse('Mon Jan 10 06:00:00 PST 2000'),
        Time.parse('Tue Jan 11 06:00:00 PST 2000'),
        Time.parse('Wed Jan 12 06:00:00 PST 2000'),
        Time.parse('Thu Jan 13 06:00:00 PST 2000'),
        Time.parse('Fri Jan 14 06:00:00 PST 2000'),
        Time.parse('Sat Jan 15 06:00:00 PST 2000'),
        Time.parse('Sun Jan 16 06:00:00 PST 2000'),
        Time.parse('Mon Jan 17 06:00:00 PST 2000'),
        Time.parse('Tue Jan 18 06:00:00 PST 2000'),
        Time.parse('Wed Jan 19 06:00:00 PST 2000'),
        Time.parse('Thu Jan 20 06:00:00 PST 2000'),
        Time.parse('Fri Jan 21 06:00:00 PST 2000'),
        Time.parse('Sat Jan 22 06:00:00 PST 2000'),
        Time.parse('Sun Jan 23 06:00:00 PST 2000'),
        Time.parse('Mon Jan 24 06:00:00 PST 2000'),
        Time.parse('Tue Jan 25 06:00:00 PST 2000'),
        Time.parse('Wed Jan 26 06:00:00 PST 2000'),
        Time.parse('Thu Jan 27 06:00:00 PST 2000'),
        Time.parse('Fri Jan 28 06:00:00 PST 2000'),
        Time.parse('Sat Jan 29 06:00:00 PST 2000'),
        Time.parse('Sun Jan 30 06:00:00 PST 2000'),
        Time.parse('Mon Jan 31 06:00:00 PST 2000'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;COUNT=10' do
      rrule = 'FREQ=WEEKLY;COUNT=10'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Tue Sep  9 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 23 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 30 06:00:00 PDT 1997'),
        Time.parse('Tue Oct  7 06:00:00 PDT 1997'),
        Time.parse('Tue Oct 14 06:00:00 PDT 1997'),
        Time.parse('Tue Oct 21 06:00:00 PDT 1997'),
        Time.parse('Tue Oct 28 06:00:00 PST 1997'),
        Time.parse('Tue Nov  4 06:00:00 PST 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;UNTIL=19971224T000000Z' do
      rrule = 'FREQ=WEEKLY;UNTIL=19971224T000000Z'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Tue Sep  9 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 23 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 30 06:00:00 PDT 1997'),
        Time.parse('Tue Oct  7 06:00:00 PDT 1997'),
        Time.parse('Tue Oct 14 06:00:00 PDT 1997'),
        Time.parse('Tue Oct 21 06:00:00 PDT 1997'),
        Time.parse('Tue Oct 28 06:00:00 PST 1997'),
        Time.parse('Tue Nov  4 06:00:00 PST 1997'),
        Time.parse('Tue Nov 11 06:00:00 PST 1997'),
        Time.parse('Tue Nov 18 06:00:00 PST 1997'),
        Time.parse('Tue Nov 25 06:00:00 PST 1997'),
        Time.parse('Tue Dec  2 06:00:00 PST 1997'),
        Time.parse('Tue Dec  9 06:00:00 PST 1997'),
        Time.parse('Tue Dec 16 06:00:00 PST 1997'),
        Time.parse('Tue Dec 23 06:00:00 PST 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH' do
      rrule = 'FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 06:00:00 PDT 1997'),
        Time.parse('Tue Sep  9 06:00:00 PDT 1997'),
        Time.parse('Thu Sep 11 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 06:00:00 PDT 1997'),
        Time.parse('Thu Sep 18 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 23 06:00:00 PDT 1997'),
        Time.parse('Thu Sep 25 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 30 06:00:00 PDT 1997'),
        Time.parse('Thu Oct  2 06:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH' do
      rrule = 'FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 06:00:00 PDT 1997'),
        Time.parse('Tue Sep  9 06:00:00 PDT 1997'),
        Time.parse('Thu Sep 11 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 06:00:00 PDT 1997'),
        Time.parse('Thu Sep 18 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 23 06:00:00 PDT 1997'),
        Time.parse('Thu Sep 25 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 30 06:00:00 PDT 1997'),
        Time.parse('Thu Oct  2 06:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;BYDAY=MO,WE,FR' do
      rrule = 'FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;BYDAY=MO,WE,FR'
      dtstart = Time.parse('Mon Sep  1 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Mon Sep  1 06:00:00 PDT 1997'),
        Time.parse('Wed Sep  3 06:00:00 PDT 1997'),
        Time.parse('Fri Sep  5 06:00:00 PDT 1997'),
        Time.parse('Mon Sep 15 06:00:00 PDT 1997'),
        Time.parse('Wed Sep 17 06:00:00 PDT 1997'),
        Time.parse('Fri Sep 19 06:00:00 PDT 1997'),
        Time.parse('Mon Sep 29 06:00:00 PDT 1997'),
        Time.parse('Wed Oct  1 06:00:00 PDT 1997'),
        Time.parse('Fri Oct  3 06:00:00 PDT 1997'),
        Time.parse('Mon Oct 13 06:00:00 PDT 1997'),
        Time.parse('Wed Oct 15 06:00:00 PDT 1997'),
        Time.parse('Fri Oct 17 06:00:00 PDT 1997'),
        Time.parse('Mon Oct 27 06:00:00 PST 1997'),
        Time.parse('Wed Oct 29 06:00:00 PST 1997'),
        Time.parse('Fri Oct 31 06:00:00 PST 1997'),
        Time.parse('Mon Nov 10 06:00:00 PST 1997'),
        Time.parse('Wed Nov 12 06:00:00 PST 1997'),
        Time.parse('Fri Nov 14 06:00:00 PST 1997'),
        Time.parse('Mon Nov 24 06:00:00 PST 1997'),
        Time.parse('Wed Nov 26 06:00:00 PST 1997'),
        Time.parse('Fri Nov 28 06:00:00 PST 1997'),
        Time.parse('Mon Dec  8 06:00:00 PST 1997'),
        Time.parse('Wed Dec 10 06:00:00 PST 1997'),
        Time.parse('Fri Dec 12 06:00:00 PST 1997'),
        Time.parse('Mon Dec 22 06:00:00 PST 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH' do
      rrule = 'FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 06:00:00 PDT 1997'),
        Time.parse('Thu Sep 18 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 30 06:00:00 PDT 1997'),
        Time.parse('Thu Oct  2 06:00:00 PDT 1997'),
        Time.parse('Tue Oct 14 06:00:00 PDT 1997'),
        Time.parse('Thu Oct 16 06:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;COUNT=10;BYDAY=1FR' do
      rrule = 'FREQ=MONTHLY;COUNT=10;BYDAY=1FR'
      dtstart = Time.parse('Fri Sep  5 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Fri Sep  5 06:00:00 PDT 1997'),
        Time.parse('Fri Oct  3 06:00:00 PDT 1997'),
        Time.parse('Fri Nov  7 06:00:00 PST 1997'),
        Time.parse('Fri Dec  5 06:00:00 PST 1997'),
        Time.parse('Fri Jan  2 06:00:00 PST 1998'),
        Time.parse('Fri Feb  6 06:00:00 PST 1998'),
        Time.parse('Fri Mar  6 06:00:00 PST 1998'),
        Time.parse('Fri Apr  3 06:00:00 PST 1998'),
        Time.parse('Fri May  1 06:00:00 PDT 1998'),
        Time.parse('Fri Jun  5 06:00:00 PDT 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;UNTIL=19971224T000000Z;BYDAY=1FR' do
      rrule = 'FREQ=MONTHLY;UNTIL=19971224T000000Z;BYDAY=1FR'
      dtstart = Time.parse('Fri Sep  5 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Fri Sep  5 06:00:00 PDT 1997'),
        Time.parse('Fri Oct  3 06:00:00 PDT 1997'),
        Time.parse('Fri Nov  7 06:00:00 PST 1997'),
        Time.parse('Fri Dec  5 06:00:00 PST 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU' do
      rrule = 'FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU'
      dtstart = Time.parse('Sun Sep  7 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Sun Sep  7 06:00:00 PDT 1997'),
        Time.parse('Sun Sep 28 06:00:00 PDT 1997'),
        Time.parse('Sun Nov  2 06:00:00 PST 1997'),
        Time.parse('Sun Nov 30 06:00:00 PST 1997'),
        Time.parse('Sun Jan  4 06:00:00 PST 1998'),
        Time.parse('Sun Jan 25 06:00:00 PST 1998'),
        Time.parse('Sun Mar  1 06:00:00 PST 1998'),
        Time.parse('Sun Mar 29 06:00:00 PST 1998'),
        Time.parse('Sun May  3 06:00:00 PDT 1998'),
        Time.parse('Sun May 31 06:00:00 PDT 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;COUNT=6;BYDAY=-2MO' do
      rrule = 'FREQ=MONTHLY;COUNT=6;BYDAY=-2MO'
      dtstart = Time.parse('Mon Sep 22 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Mon Sep 22 06:00:00 PDT 1997'),
        Time.parse('Mon Oct 20 06:00:00 PDT 1997'),
        Time.parse('Mon Nov 17 06:00:00 PST 1997'),
        Time.parse('Mon Dec 22 06:00:00 PST 1997'),
        Time.parse('Mon Jan 19 06:00:00 PST 1998'),
        Time.parse('Mon Feb 16 06:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15' do
      rrule = 'FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Mon Sep 15 06:00:00 PDT 1997'),
        Time.parse('Thu Oct  2 06:00:00 PDT 1997'),
        Time.parse('Wed Oct 15 06:00:00 PDT 1997'),
        Time.parse('Sun Nov  2 06:00:00 PST 1997'),
        Time.parse('Sat Nov 15 06:00:00 PST 1997'),
        Time.parse('Tue Dec  2 06:00:00 PST 1997'),
        Time.parse('Mon Dec 15 06:00:00 PST 1997'),
        Time.parse('Fri Jan  2 06:00:00 PST 1998'),
        Time.parse('Thu Jan 15 06:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1' do
      rrule = 'FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1'
      dtstart = Time.parse('Tue Sep 30 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep 30 06:00:00 PDT 1997'),
        Time.parse('Wed Oct  1 06:00:00 PDT 1997'),
        Time.parse('Fri Oct 31 06:00:00 PST 1997'),
        Time.parse('Sat Nov  1 06:00:00 PST 1997'),
        Time.parse('Sun Nov 30 06:00:00 PST 1997'),
        Time.parse('Mon Dec  1 06:00:00 PST 1997'),
        Time.parse('Wed Dec 31 06:00:00 PST 1997'),
        Time.parse('Thu Jan  1 06:00:00 PST 1998'),
        Time.parse('Sat Jan 31 06:00:00 PST 1998'),
        Time.parse('Sun Feb  1 06:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,15' do
      rrule = 'FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,15'
      dtstart = Time.parse('Wed Sep 10 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Wed Sep 10 06:00:00 PDT 1997'),
        Time.parse('Thu Sep 11 06:00:00 PDT 1997'),
        Time.parse('Fri Sep 12 06:00:00 PDT 1997'),
        Time.parse('Sat Sep 13 06:00:00 PDT 1997'),
        Time.parse('Sun Sep 14 06:00:00 PDT 1997'),
        Time.parse('Mon Sep 15 06:00:00 PDT 1997'),
        Time.parse('Wed Mar 10 06:00:00 PST 1999'),
        Time.parse('Thu Mar 11 06:00:00 PST 1999'),
        Time.parse('Fri Mar 12 06:00:00 PST 1999'),
        Time.parse('Sat Mar 13 06:00:00 PST 1999'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=10;BYMONTH=6,7' do
      rrule = 'FREQ=YEARLY;COUNT=10;BYMONTH=6,7'
      dtstart = Time.parse('Tue Jun 10 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Jun 10 06:00:00 PDT 1997'),
        Time.parse('Thu Jul 10 06:00:00 PDT 1997'),
        Time.parse('Wed Jun 10 06:00:00 PDT 1998'),
        Time.parse('Fri Jul 10 06:00:00 PDT 1998'),
        Time.parse('Thu Jun 10 06:00:00 PDT 1999'),
        Time.parse('Sat Jul 10 06:00:00 PDT 1999'),
        Time.parse('Sat Jun 10 06:00:00 PDT 2000'),
        Time.parse('Mon Jul 10 06:00:00 PDT 2000'),
        Time.parse('Sun Jun 10 06:00:00 PDT 2001'),
        Time.parse('Tue Jul 10 06:00:00 PDT 2001'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;INTERVAL=2;COUNT=10;BYMONTH=1,2,3' do
      rrule = 'FREQ=YEARLY;INTERVAL=2;COUNT=10;BYMONTH=1,2,3'
      dtstart = Time.parse('Mon Mar 10 06:00:00 PST 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Mon Mar 10 06:00:00 PST 1997'),
        Time.parse('Sun Jan 10 06:00:00 PST 1999'),
        Time.parse('Wed Feb 10 06:00:00 PST 1999'),
        Time.parse('Wed Mar 10 06:00:00 PST 1999'),
        Time.parse('Wed Jan 10 06:00:00 PST 2001'),
        Time.parse('Sat Feb 10 06:00:00 PST 2001'),
        Time.parse('Sat Mar 10 06:00:00 PST 2001'),
        Time.parse('Fri Jan 10 06:00:00 PST 2003'),
        Time.parse('Mon Feb 10 06:00:00 PST 2003'),
        Time.parse('Mon Mar 10 06:00:00 PST 2003'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200' do
      rrule = 'FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200'
      dtstart = Time.parse('Wed Jan  1 06:00:00 PST 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Wed Jan  1 06:00:00 PST 1997'),
        Time.parse('Thu Apr 10 06:00:00 PDT 1997'),
        Time.parse('Sat Jul 19 06:00:00 PDT 1997'),
        Time.parse('Sat Jan  1 06:00:00 PST 2000'),
        Time.parse('Sun Apr  9 06:00:00 PDT 2000'),
        Time.parse('Tue Jul 18 06:00:00 PDT 2000'),
        Time.parse('Wed Jan  1 06:00:00 PST 2003'),
        Time.parse('Thu Apr 10 06:00:00 PDT 2003'),
        Time.parse('Sat Jul 19 06:00:00 PDT 2003'),
        Time.parse('Sun Jan  1 06:00:00 PST 2006'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13;COUNT=6' do
      rrule = 'FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13;COUNT=6'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Fri Feb 13 06:00:00 PST 1998'),
        Time.parse('Fri Mar 13 06:00:00 PST 1998'),
        Time.parse('Fri Nov 13 06:00:00 PST 1998'),
        Time.parse('Fri Aug 13 06:00:00 PDT 1999'),
        Time.parse('Fri Oct 13 06:00:00 PDT 2000'),
        Time.parse('Fri Apr 13 06:00:00 PDT 2001'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3' do
      rrule = 'FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3'
      dtstart = Time.parse('Thu Sep  4 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Sep  4 06:00:00 PDT 1997'),
        Time.parse('Tue Oct  7 06:00:00 PDT 1997'),
        Time.parse('Thu Nov  6 06:00:00 PST 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=MO' do
      rrule = 'FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=MO'
      dtstart = Time.parse('Tue Aug  5 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Aug  5 06:00:00 PDT 1997'),
        Time.parse('Sun Aug 10 06:00:00 PDT 1997'),
        Time.parse('Tue Aug 19 06:00:00 PDT 1997'),
        Time.parse('Sun Aug 24 06:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=SU' do
      rrule = 'FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=SU'
      dtstart = Time.parse('Tue Aug  5 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Aug  5 06:00:00 PDT 1997'),
        Time.parse('Sun Aug 17 06:00:00 PDT 1997'),
        Time.parse('Tue Aug 19 06:00:00 PDT 1997'),
        Time.parse('Sun Aug 31 06:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;BYMONTHDAY=15,30;COUNT=5' do
      rrule = 'FREQ=MONTHLY;BYMONTHDAY=15,30;COUNT=5'
      dtstart = Time.parse('Mon Jan 15 06:00:00 PST 2007')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Mon Jan 15 06:00:00 PST 2007'),
        Time.parse('Tue Jan 30 06:00:00 PST 2007'),
        Time.parse('Thu Feb 15 06:00:00 PST 2007'),
        Time.parse('Thu Mar 15 06:00:00 PDT 2007'),
        Time.parse('Fri Mar 30 06:00:00 PDT 2007'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;COUNT=3' do
      rrule = 'FREQ=DAILY;COUNT=3'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Wed Sep  3 09:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;BYMONTH=1,3;COUNT=4' do
      rrule = 'FREQ=DAILY;BYMONTH=1,3;COUNT=4'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan  1 09:00:00 PST 1998'),
        Time.parse('Fri Jan  2 09:00:00 PST 1998'),
        Time.parse('Sat Jan  3 09:00:00 PST 1998'),
        Time.parse('Sun Jan  4 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;BYMONTH=1,3;COUNT=4;BYMONTHDAY=5,7' do
      rrule = 'FREQ=DAILY;BYMONTH=1,3;COUNT=4;BYMONTHDAY=5,7'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Mon Jan  5 09:00:00 PST 1998'),
        Time.parse('Wed Jan  7 09:00:00 PST 1998'),
        Time.parse('Thu Mar  5 09:00:00 PST 1998'),
        Time.parse('Sat Mar  7 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH;BYMONTHDAY=1,3' do
      rrule = 'FREQ=DAILY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH;BYMONTHDAY=1,3'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan  1 09:00:00 PST 1998'),
        Time.parse('Tue Mar  3 09:00:00 PST 1998'),
        Time.parse('Thu Mar  1 09:00:00 PST 2001'),
        Time.parse('Tue Jan  1 09:00:00 PST 2002'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH' do
      rrule = 'FREQ=DAILY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan  1 09:00:00 PST 1998'),
        Time.parse('Tue Jan  6 09:00:00 PST 1998'),
        Time.parse('Thu Jan  8 09:00:00 PST 1998'),
        Time.parse('Tue Jan 13 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;COUNT=4;BYMONTHDAY=1,3' do
      rrule = 'FREQ=DAILY;COUNT=4;BYMONTHDAY=1,3'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Wed Sep  3 09:00:00 PDT 1997'),
        Time.parse('Wed Oct  1 09:00:00 PDT 1997'),
        Time.parse('Fri Oct  3 09:00:00 PDT 1997'),
        Time.parse('Sat Nov  1 09:00:00 PST 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;COUNT=4;BYDAY=TU,TH;BYMONTHDAY=1,3' do
      rrule = 'FREQ=DAILY;COUNT=4;BYDAY=TU,TH;BYMONTHDAY=1,3'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan  1 09:00:00 PST 1998'),
        Time.parse('Tue Feb  3 09:00:00 PST 1998'),
        Time.parse('Tue Mar  3 09:00:00 PST 1998'),
        Time.parse('Tue Sep  1 09:00:00 PDT 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;COUNT=3;BYDAY=TU,TH' do
      rrule = 'FREQ=DAILY;COUNT=3;BYDAY=TU,TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 09:00:00 PDT 1997'),
        Time.parse('Tue Sep  9 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;COUNT=3;INTERVAL=2' do
      rrule = 'FREQ=DAILY;COUNT=3;INTERVAL=2'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 09:00:00 PDT 1997'),
        Time.parse('Sat Sep  6 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;COUNT=3;INTERVAL=92' do
      rrule = 'FREQ=DAILY;COUNT=3;INTERVAL=92'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Wed Dec  3 09:00:00 PST 1997'),
        Time.parse('Thu Mar  5 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;BYMONTH=2;COUNT=1;BYMONTHDAY=31' do
      rrule = 'FREQ=YEARLY;BYMONTH=2;COUNT=1;BYMONTHDAY=31'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 9997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to be_empty
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;COUNT=3' do
      rrule = 'FREQ=MONTHLY;COUNT=3'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Thu Oct  2 09:00:00 PDT 1997'),
        Time.parse('Sun Nov  2 09:00:00 PST 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;BYMONTH=1,3;COUNT=4' do
      rrule = 'FREQ=MONTHLY;BYMONTH=1,3;COUNT=4'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Fri Jan  2 09:00:00 PST 1998'),
        Time.parse('Mon Mar  2 09:00:00 PST 1998'),
        Time.parse('Sat Jan  2 09:00:00 PST 1999'),
        Time.parse('Tue Mar  2 09:00:00 PST 1999'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;BYMONTH=1,3;COUNT=4;BYMONTHDAY=5,7' do
      rrule = 'FREQ=MONTHLY;BYMONTH=1,3;COUNT=4;BYMONTHDAY=5,7'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Mon Jan  5 09:00:00 PST 1998'),
        Time.parse('Wed Jan  7 09:00:00 PST 1998'),
        Time.parse('Thu Mar  5 09:00:00 PST 1998'),
        Time.parse('Sat Mar  7 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH;BYMONTHDAY=1,3' do
      rrule = 'FREQ=MONTHLY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH;BYMONTHDAY=1,3'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan  1 09:00:00 PST 1998'),
        Time.parse('Tue Mar  3 09:00:00 PST 1998'),
        Time.parse('Thu Mar  1 09:00:00 PST 2001'),
        Time.parse('Tue Jan  1 09:00:00 PST 2002'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;BYMONTH=1,3;COUNT=4;BYDAY=1TU,-1TH' do
      rrule = 'FREQ=MONTHLY;BYMONTH=1,3;COUNT=4;BYDAY=1TU,-1TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Jan  6 09:00:00 PST 1998'),
        Time.parse('Thu Jan 29 09:00:00 PST 1998'),
        Time.parse('Tue Mar  3 09:00:00 PST 1998'),
        Time.parse('Thu Mar 26 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;BYMONTH=1,3;COUNT=4;BYDAY=3TU,-3TH' do
      rrule = 'FREQ=MONTHLY;BYMONTH=1,3;COUNT=4;BYDAY=3TU,-3TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan 15 09:00:00 PST 1998'),
        Time.parse('Tue Jan 20 09:00:00 PST 1998'),
        Time.parse('Thu Mar 12 09:00:00 PST 1998'),
        Time.parse('Tue Mar 17 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH' do
      rrule = 'FREQ=MONTHLY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan  1 09:00:00 PST 1998'),
        Time.parse('Tue Jan  6 09:00:00 PST 1998'),
        Time.parse('Thu Jan  8 09:00:00 PST 1998'),
        Time.parse('Tue Jan 13 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;COUNT=4;BYMONTHDAY=1,3' do
      rrule = 'FREQ=MONTHLY;COUNT=4;BYMONTHDAY=1,3'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Wed Sep  3 09:00:00 PDT 1997'),
        Time.parse('Wed Oct  1 09:00:00 PDT 1997'),
        Time.parse('Fri Oct  3 09:00:00 PDT 1997'),
        Time.parse('Sat Nov  1 09:00:00 PST 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;COUNT=4;BYDAY=TU,TH;BYMONTHDAY=1,3' do
      rrule = 'FREQ=MONTHLY;COUNT=4;BYDAY=TU,TH;BYMONTHDAY=1,3'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan  1 09:00:00 PST 1998'),
        Time.parse('Tue Feb  3 09:00:00 PST 1998'),
        Time.parse('Tue Mar  3 09:00:00 PST 1998'),
        Time.parse('Tue Sep  1 09:00:00 PDT 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;COUNT=3;BYDAY=1TU,-1TH' do
      rrule = 'FREQ=MONTHLY;COUNT=3;BYDAY=1TU,-1TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Thu Sep 25 09:00:00 PDT 1997'),
        Time.parse('Tue Oct  7 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;COUNT=4;BYDAY=3TU,-3TH' do
      rrule = 'FREQ=MONTHLY;COUNT=4;BYDAY=3TU,-3TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Sep 11 09:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 09:00:00 PDT 1997'),
        Time.parse('Thu Oct 16 09:00:00 PDT 1997'),
        Time.parse('Tue Oct 21 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;COUNT=3;BYDAY=TU,TH' do
      rrule = 'FREQ=MONTHLY;COUNT=3;BYDAY=TU,TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 09:00:00 PDT 1997'),
        Time.parse('Tue Sep  9 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;COUNT=3;INTERVAL=2' do
      rrule = 'FREQ=MONTHLY;COUNT=3;INTERVAL=2'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Sun Nov  2 09:00:00 PST 1997'),
        Time.parse('Fri Jan  2 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;COUNT=3;INTERVAL=18' do
      rrule = 'FREQ=MONTHLY;COUNT=3;INTERVAL=18'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Tue Mar  2 09:00:00 PST 1999'),
        Time.parse('Sat Sep  2 09:00:00 PDT 2000'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;UNTIL=19970901T170000Z' do
      rrule = 'FREQ=DAILY;UNTIL=19970901T170000Z'
      dtstart = Time.parse('Mon Sep  1 10:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Mon Sep  1 10:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;UNTIL=19970904T160000Z' do
      rrule = 'FREQ=DAILY;UNTIL=19970904T160000Z'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Wed Sep  3 09:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;UNTIL=19970905T150000Z' do
      rrule = 'FREQ=DAILY;UNTIL=19970905T150000Z'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Wed Sep  3 09:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;UNTIL=19970902T160000Z' do
      rrule = 'FREQ=DAILY;UNTIL=19970902T160000Z'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;COUNT=3' do
      rrule = 'FREQ=WEEKLY;COUNT=3'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Tue Sep  9 09:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;BYMONTH=1,3;COUNT=4' do
      rrule = 'FREQ=WEEKLY;BYMONTH=1,3;COUNT=4'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Jan  6 09:00:00 PST 1998'),
        Time.parse('Tue Jan 13 09:00:00 PST 1998'),
        Time.parse('Tue Jan 20 09:00:00 PST 1998'),
        Time.parse('Tue Jan 27 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH' do
      rrule = 'FREQ=WEEKLY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan  1 09:00:00 PST 1998'),
        Time.parse('Tue Jan  6 09:00:00 PST 1998'),
        Time.parse('Thu Jan  8 09:00:00 PST 1998'),
        Time.parse('Tue Jan 13 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;COUNT=3;BYDAY=TU,TH' do
      rrule = 'FREQ=WEEKLY;COUNT=3;BYDAY=TU,TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 09:00:00 PDT 1997'),
        Time.parse('Tue Sep  9 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;COUNT=3;INTERVAL=2' do
      rrule = 'FREQ=WEEKLY;COUNT=3;INTERVAL=2'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 09:00:00 PDT 1997'),
        Time.parse('Tue Sep 30 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;COUNT=3;INTERVAL=20' do
      rrule = 'FREQ=WEEKLY;COUNT=3;INTERVAL=20'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Tue Jan 20 09:00:00 PST 1998'),
        Time.parse('Tue Jun  9 09:00:00 PDT 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;COUNT=3;BYDAY=TU,SU;WKST=MO;INTERVAL=2' do
      rrule = 'FREQ=WEEKLY;COUNT=3;BYDAY=TU,SU;WKST=MO;INTERVAL=2'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Sun Sep  7 09:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;COUNT=3;BYDAY=TU,SU;WKST=SU;INTERVAL=2' do
      rrule = 'FREQ=WEEKLY;COUNT=3;BYDAY=TU,SU;WKST=SU;INTERVAL=2'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Sun Sep 14 09:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=3' do
      rrule = 'FREQ=YEARLY;COUNT=3'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Wed Sep  2 09:00:00 PDT 1998'),
        Time.parse('Thu Sep  2 09:00:00 PDT 1999'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;BYMONTH=1,3;COUNT=4' do
      rrule = 'FREQ=YEARLY;BYMONTH=1,3;COUNT=4'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Fri Jan  2 09:00:00 PST 1998'),
        Time.parse('Mon Mar  2 09:00:00 PST 1998'),
        Time.parse('Sat Jan  2 09:00:00 PST 1999'),
        Time.parse('Tue Mar  2 09:00:00 PST 1999'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;BYMONTH=1,3;COUNT=4;BYMONTHDAY=5,7' do
      rrule = 'FREQ=YEARLY;BYMONTH=1,3;COUNT=4;BYMONTHDAY=5,7'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Mon Jan  5 09:00:00 PST 1998'),
        Time.parse('Wed Jan  7 09:00:00 PST 1998'),
        Time.parse('Thu Mar  5 09:00:00 PST 1998'),
        Time.parse('Sat Mar  7 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH;BYMONTHDAY=1,3' do
      rrule = 'FREQ=YEARLY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH;BYMONTHDAY=1,3'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan  1 09:00:00 PST 1998'),
        Time.parse('Tue Mar  3 09:00:00 PST 1998'),
        Time.parse('Thu Mar  1 09:00:00 PST 2001'),
        Time.parse('Tue Jan  1 09:00:00 PST 2002'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;BYMONTH=1,3;COUNT=4;BYDAY=1TU,-1TH' do
      rrule = 'FREQ=YEARLY;BYMONTH=1,3;COUNT=4;BYDAY=1TU,-1TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Jan  6 09:00:00 PST 1998'),
        Time.parse('Thu Jan 29 09:00:00 PST 1998'),
        Time.parse('Tue Mar  3 09:00:00 PST 1998'),
        Time.parse('Thu Mar 26 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;BYMONTH=1,3;COUNT=4;BYDAY=3TU,-3TH' do
      rrule = 'FREQ=YEARLY;BYMONTH=1,3;COUNT=4;BYDAY=3TU,-3TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan 15 09:00:00 PST 1998'),
        Time.parse('Tue Jan 20 09:00:00 PST 1998'),
        Time.parse('Thu Mar 12 09:00:00 PST 1998'),
        Time.parse('Tue Mar 17 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH' do
      rrule = 'FREQ=YEARLY;BYMONTH=1,3;COUNT=4;BYDAY=TU,TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan  1 09:00:00 PST 1998'),
        Time.parse('Tue Jan  6 09:00:00 PST 1998'),
        Time.parse('Thu Jan  8 09:00:00 PST 1998'),
        Time.parse('Tue Jan 13 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=4;BYMONTHDAY=1,3' do
      rrule = 'FREQ=YEARLY;COUNT=4;BYMONTHDAY=1,3'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Wed Sep  3 09:00:00 PDT 1997'),
        Time.parse('Wed Oct  1 09:00:00 PDT 1997'),
        Time.parse('Fri Oct  3 09:00:00 PDT 1997'),
        Time.parse('Sat Nov  1 09:00:00 PST 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=4;BYDAY=TU,TH;BYMONTHDAY=1,3' do
      rrule = 'FREQ=YEARLY;COUNT=4;BYDAY=TU,TH;BYMONTHDAY=1,3'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Jan  1 09:00:00 PST 1998'),
        Time.parse('Tue Feb  3 09:00:00 PST 1998'),
        Time.parse('Tue Mar  3 09:00:00 PST 1998'),
        Time.parse('Tue Sep  1 09:00:00 PDT 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=4;BYDAY=1TU,-1TH' do
      rrule = 'FREQ=YEARLY;COUNT=4;BYDAY=1TU,-1TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Dec 25 09:00:00 PST 1997'),
        Time.parse('Tue Jan  6 09:00:00 PST 1998'),
        Time.parse('Thu Dec 31 09:00:00 PST 1998'),
        Time.parse('Tue Jan  5 09:00:00 PST 1999'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=4;BYDAY=3TU,-3TH' do
      rrule = 'FREQ=YEARLY;COUNT=4;BYDAY=3TU,-3TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Thu Dec 11 09:00:00 PST 1997'),
        Time.parse('Tue Jan 20 09:00:00 PST 1998'),
        Time.parse('Thu Dec 17 09:00:00 PST 1998'),
        Time.parse('Tue Jan 19 09:00:00 PST 1999'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=3;BYDAY=TU,TH' do
      rrule = 'FREQ=YEARLY;COUNT=3;BYDAY=TU,TH'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 09:00:00 PDT 1997'),
        Time.parse('Tue Sep  9 09:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=4;BYWEEKNO=20' do
      rrule = 'FREQ=YEARLY;COUNT=4;BYWEEKNO=20'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Mon May 11 09:00:00 PDT 1998'),
        Time.parse('Tue May 12 09:00:00 PDT 1998'),
        Time.parse('Wed May 13 09:00:00 PDT 1998'),
        Time.parse('Thu May 14 09:00:00 PDT 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=4;BYDAY=MO;BYWEEKNO=1' do
      rrule = 'FREQ=YEARLY;COUNT=4;BYDAY=MO;BYWEEKNO=1'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Mon Dec 29 09:00:00 PST 1997'),
        Time.parse('Mon Jan  4 09:00:00 PST 1999'),
        Time.parse('Mon Jan  3 09:00:00 PST 2000'),
        Time.parse('Mon Jan  1 09:00:00 PST 2001'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=4;BYDAY=MO;BYWEEKNO=53' do
      rrule = 'FREQ=YEARLY;COUNT=4;BYDAY=MO;BYWEEKNO=53'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Mon Dec 28 09:00:00 PST 1998'),
        Time.parse('Mon Dec 27 09:00:00 PST 2004'),
        Time.parse('Mon Dec 28 09:00:00 PST 2009'),
        Time.parse('Mon Dec 28 09:00:00 PST 2015'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=4;BYDAY=SU;BYWEEKNO=52' do
      rrule = 'FREQ=YEARLY;COUNT=4;BYDAY=SU;BYWEEKNO=52'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Sun Dec 28 09:00:00 PST 1997'),
        Time.parse('Sun Dec 27 09:00:00 PST 1998'),
        Time.parse('Sun Jan  2 09:00:00 PST 2000'),
        Time.parse('Sun Dec 31 09:00:00 PST 2000'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=4;BYDAY=SU;BYWEEKNO=-1' do
      rrule = 'FREQ=YEARLY;COUNT=4;BYDAY=SU;BYWEEKNO=-1'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Sun Dec 28 09:00:00 PST 1997'),
        Time.parse('Sun Jan  3 09:00:00 PST 1999'),
        Time.parse('Sun Jan  2 09:00:00 PST 2000'),
        Time.parse('Sun Dec 31 09:00:00 PST 2000'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=5;BYYEARDAY=1,100,200,365' do
      rrule = 'FREQ=YEARLY;COUNT=5;BYYEARDAY=1,100,200,365'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Wed Dec 31 09:00:00 PST 1997'),
        Time.parse('Thu Jan  1 09:00:00 PST 1998'),
        Time.parse('Fri Apr 10 09:00:00 PDT 1998'),
        Time.parse('Sun Jul 19 09:00:00 PDT 1998'),
        Time.parse('Thu Dec 31 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=5;BYYEARDAY=-365,-266,-166,-1' do
      rrule = 'FREQ=YEARLY;COUNT=5;BYYEARDAY=-365,-266,-166,-1'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Wed Dec 31 09:00:00 PST 1997'),
        Time.parse('Thu Jan  1 09:00:00 PST 1998'),
        Time.parse('Fri Apr 10 09:00:00 PDT 1998'),
        Time.parse('Sun Jul 19 09:00:00 PDT 1998'),
        Time.parse('Thu Dec 31 09:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=3;INTERVAL=2' do
      rrule = 'FREQ=YEARLY;COUNT=3;INTERVAL=2'
      dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 PDT 1997'),
        Time.parse('Thu Sep  2 09:00:00 PDT 1999'),
        Time.parse('Sun Sep  2 09:00:00 PDT 2001'),
      ])
    end

    # At time of writing IANA timezone data was only available up until the year 2050
    # hence we perform these calculations in UTC in order to avoid problems
    # with periods of daylight savings time
    it 'returns the correct result with an rrule of FREQ=YEARLY;COUNT=3;INTERVAL=100' do
      rrule = 'FREQ=YEARLY;COUNT=3;INTERVAL=100'
      dtstart = Time.parse('Tue Sep  2 09:00:00 UTC 1997')

      rrule = RRule::Rule.new(rrule, dtstart: dtstart)
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 09:00:00 UTC 1997'),
        Time.parse('Mon Sep  2 09:00:00 UTC 2097'),
        Time.parse('Sat Sep  2 09:00:00 UTC 2197'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;INTERVAL=1;BYDAY=MO,-1TU;UNTIL=20160901T200000Z' do
      rrule = 'FREQ=YEARLY;INTERVAL=1;BYDAY=MO,-1TU;UNTIL=20160901T200000Z'
      dtstart = Time.parse('Mon Sep  1 19:00:00 PDT 2014')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Time.parse('Mon Sep  1 19:00:00 PDT 2014'),
        Time.parse('Mon Sep  8 19:00:00 PDT 2014'),
        Time.parse('Mon Sep 15 19:00:00 PDT 2014'),
        Time.parse('Mon Sep 22 19:00:00 PDT 2014'),
        Time.parse('Mon Sep 29 19:00:00 PDT 2014'),
        Time.parse('Mon Oct  6 19:00:00 PDT 2014'),
        Time.parse('Mon Oct 13 19:00:00 PDT 2014'),
        Time.parse('Mon Oct 20 19:00:00 PDT 2014'),
        Time.parse('Mon Oct 27 19:00:00 PDT 2014'),
        Time.parse('Mon Nov  3 19:00:00 PST 2014'),
        Time.parse('Mon Nov 10 19:00:00 PST 2014'),
        Time.parse('Mon Nov 17 19:00:00 PST 2014'),
        Time.parse('Mon Nov 24 19:00:00 PST 2014'),
        Time.parse('Mon Dec  1 19:00:00 PST 2014'),
        Time.parse('Mon Dec  8 19:00:00 PST 2014'),
        Time.parse('Mon Dec 15 19:00:00 PST 2014'),
        Time.parse('Mon Dec 22 19:00:00 PST 2014'),
        Time.parse('Mon Dec 29 19:00:00 PST 2014'),
        Time.parse('Tue Dec 30 19:00:00 PST 2014'),
        Time.parse('Mon Jan  5 19:00:00 PST 2015'),
        Time.parse('Mon Jan 12 19:00:00 PST 2015'),
        Time.parse('Mon Jan 19 19:00:00 PST 2015'),
        Time.parse('Mon Jan 26 19:00:00 PST 2015'),
        Time.parse('Mon Feb  2 19:00:00 PST 2015'),
        Time.parse('Mon Feb  9 19:00:00 PST 2015'),
        Time.parse('Mon Feb 16 19:00:00 PST 2015'),
        Time.parse('Mon Feb 23 19:00:00 PST 2015'),
        Time.parse('Mon Mar  2 19:00:00 PST 2015'),
        Time.parse('Mon Mar  9 19:00:00 PDT 2015'),
        Time.parse('Mon Mar 16 19:00:00 PDT 2015'),
        Time.parse('Mon Mar 23 19:00:00 PDT 2015'),
        Time.parse('Mon Mar 30 19:00:00 PDT 2015'),
        Time.parse('Mon Apr  6 19:00:00 PDT 2015'),
        Time.parse('Mon Apr 13 19:00:00 PDT 2015'),
        Time.parse('Mon Apr 20 19:00:00 PDT 2015'),
        Time.parse('Mon Apr 27 19:00:00 PDT 2015'),
        Time.parse('Mon May  4 19:00:00 PDT 2015'),
        Time.parse('Mon May 11 19:00:00 PDT 2015'),
        Time.parse('Mon May 18 19:00:00 PDT 2015'),
        Time.parse('Mon May 25 19:00:00 PDT 2015'),
        Time.parse('Mon Jun  1 19:00:00 PDT 2015'),
        Time.parse('Mon Jun  8 19:00:00 PDT 2015'),
        Time.parse('Mon Jun 15 19:00:00 PDT 2015'),
        Time.parse('Mon Jun 22 19:00:00 PDT 2015'),
        Time.parse('Mon Jun 29 19:00:00 PDT 2015'),
        Time.parse('Mon Jul  6 19:00:00 PDT 2015'),
        Time.parse('Mon Jul 13 19:00:00 PDT 2015'),
        Time.parse('Mon Jul 20 19:00:00 PDT 2015'),
        Time.parse('Mon Jul 27 19:00:00 PDT 2015'),
        Time.parse('Mon Aug  3 19:00:00 PDT 2015'),
        Time.parse('Mon Aug 10 19:00:00 PDT 2015'),
        Time.parse('Mon Aug 17 19:00:00 PDT 2015'),
        Time.parse('Mon Aug 24 19:00:00 PDT 2015'),
        Time.parse('Mon Aug 31 19:00:00 PDT 2015'),
        Time.parse('Mon Sep  7 19:00:00 PDT 2015'),
        Time.parse('Mon Sep 14 19:00:00 PDT 2015'),
        Time.parse('Mon Sep 21 19:00:00 PDT 2015'),
        Time.parse('Mon Sep 28 19:00:00 PDT 2015'),
        Time.parse('Mon Oct  5 19:00:00 PDT 2015'),
        Time.parse('Mon Oct 12 19:00:00 PDT 2015'),
        Time.parse('Mon Oct 19 19:00:00 PDT 2015'),
        Time.parse('Mon Oct 26 19:00:00 PDT 2015'),
        Time.parse('Mon Nov  2 19:00:00 PST 2015'),
        Time.parse('Mon Nov  9 19:00:00 PST 2015'),
        Time.parse('Mon Nov 16 19:00:00 PST 2015'),
        Time.parse('Mon Nov 23 19:00:00 PST 2015'),
        Time.parse('Mon Nov 30 19:00:00 PST 2015'),
        Time.parse('Mon Dec  7 19:00:00 PST 2015'),
        Time.parse('Mon Dec 14 19:00:00 PST 2015'),
        Time.parse('Mon Dec 21 19:00:00 PST 2015'),
        Time.parse('Mon Dec 28 19:00:00 PST 2015'),
        Time.parse('Tue Dec 29 19:00:00 PST 2015'),
        Time.parse('Mon Jan  4 19:00:00 PST 2016'),
        Time.parse('Mon Jan 11 19:00:00 PST 2016'),
        Time.parse('Mon Jan 18 19:00:00 PST 2016'),
        Time.parse('Mon Jan 25 19:00:00 PST 2016'),
        Time.parse('Mon Feb  1 19:00:00 PST 2016'),
        Time.parse('Mon Feb  8 19:00:00 PST 2016'),
        Time.parse('Mon Feb 15 19:00:00 PST 2016'),
        Time.parse('Mon Feb 22 19:00:00 PST 2016'),
        Time.parse('Mon Feb 29 19:00:00 PST 2016'),
        Time.parse('Mon Mar  7 19:00:00 PST 2016'),
        Time.parse('Mon Mar 14 19:00:00 PDT 2016'),
        Time.parse('Mon Mar 21 19:00:00 PDT 2016'),
        Time.parse('Mon Mar 28 19:00:00 PDT 2016'),
        Time.parse('Mon Apr  4 19:00:00 PDT 2016'),
        Time.parse('Mon Apr 11 19:00:00 PDT 2016'),
        Time.parse('Mon Apr 18 19:00:00 PDT 2016'),
        Time.parse('Mon Apr 25 19:00:00 PDT 2016'),
        Time.parse('Mon May  2 19:00:00 PDT 2016'),
        Time.parse('Mon May  9 19:00:00 PDT 2016'),
        Time.parse('Mon May 16 19:00:00 PDT 2016'),
        Time.parse('Mon May 23 19:00:00 PDT 2016'),
        Time.parse('Mon May 30 19:00:00 PDT 2016'),
        Time.parse('Mon Jun  6 19:00:00 PDT 2016'),
        Time.parse('Mon Jun 13 19:00:00 PDT 2016'),
        Time.parse('Mon Jun 20 19:00:00 PDT 2016'),
        Time.parse('Mon Jun 27 19:00:00 PDT 2016'),
        Time.parse('Mon Jul  4 19:00:00 PDT 2016'),
        Time.parse('Mon Jul 11 19:00:00 PDT 2016'),
        Time.parse('Mon Jul 18 19:00:00 PDT 2016'),
        Time.parse('Mon Jul 25 19:00:00 PDT 2016'),
        Time.parse('Mon Aug  1 19:00:00 PDT 2016'),
        Time.parse('Mon Aug  8 19:00:00 PDT 2016'),
        Time.parse('Mon Aug 15 19:00:00 PDT 2016'),
        Time.parse('Mon Aug 22 19:00:00 PDT 2016'),
        Time.parse('Mon Aug 29 19:00:00 PDT 2016'),
      ])
    end
  end

  describe '#between' do
    context 'server env timezone is different from the passed timezone' do
      around do |example|
        old_tz = ENV['TZ']
        ENV['TZ'] = 'UTC'
        example.run
        ENV['TZ'] = old_tz
      end

      it 'works when the day in the given timezone is different from the day in the server timezone' do
        # any time from 17:00 to 23:59:59 broke old code, test all hours of the day
        0.upto(23) do |hour|
          dtstart = Time.new(2018, 7, 1, hour, 0, 0, '-07:00')
          rrule = RRule::Rule.new('FREQ=WEEKLY', dtstart: dtstart, tzid: 'America/Los_Angeles')
          expect(rrule.between(dtstart, dtstart + 1.second)).to eq([dtstart])
        end
      end
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU' do
      rrule = 'FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU'
      dtstart = Time.parse('2018-02-04 04:00:00 +1000')
      timezone = 'Brisbane'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Sun, 08 Apr 2018 00:00:00 +0000'), Time.parse('Fri, 08 Jun 2018 23:59:59 +0000'))).to match_array([
        Time.parse('Sun, 08 Apr 2018 23:59:59 +1000'),
        Time.parse('Sun, 15 Apr 2018 23:59:59 +1000'),
        Time.parse('Sun, 22 Apr 2018 23:59:59 +1000'),
        Time.parse('Sun, 29 Apr 2018 23:59:59 +1000'),
        Time.parse('Sun, 06 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 13 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 20 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 27 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 03 Jun 2018 23:59:59 +1000'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU starting beyond the beginning of the result' do
      rrule = 'FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU'
      dtstart = Time.parse('2018-02-04 04:00:00 +1000')
      timezone = 'Brisbane'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Sun, 13 May 2018 23:59:59 +1000'), Time.parse('Fri, 08 Jun 2018 23:59:59 +0000'))).to match_array([
        Time.parse('Sun, 13 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 20 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 27 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 03 Jun 2018 23:59:59 +1000'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU with a limit' do
      rrule = 'FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU'
      dtstart = Time.parse('2018-02-04 04:00:00 +1000')
      timezone = 'Brisbane'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Sun, 08 Apr 2018 00:00:00 +0000'), Time.parse('Fri, 08 Jun 2018 23:59:59 +0000'), limit: 2)).to match_array([
        Time.parse('Sun, 08 Apr 2018 23:59:59 +1000'),
        Time.parse('Sun, 15 Apr 2018 23:59:59 +1000'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU starting beyond the beginning of the result with a limit' do
      rrule = 'FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU'
      dtstart = Time.parse('2018-02-04 04:00:00 +1000')
      timezone = 'Brisbane'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Sun, 13 May 2018 23:59:59 +1000'), Time.parse('Fri, 08 Jun 2018 23:59:59 +0000'), limit: 2)).to match_array([
        Time.parse('Sun, 13 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 20 May 2018 23:59:59 +1000'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;INTERVAL=2' do
      rrule = 'FREQ=DAILY;INTERVAL=2'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Tue Sep  2 06:00:00 PDT 1997'), Time.parse('Wed Oct 22 06:00:00 PDT 1997'))).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 06:00:00 PDT 1997'),
        Time.parse('Sat Sep  6 06:00:00 PDT 1997'),
        Time.parse('Mon Sep  8 06:00:00 PDT 1997'),
        Time.parse('Wed Sep 10 06:00:00 PDT 1997'),
        Time.parse('Fri Sep 12 06:00:00 PDT 1997'),
        Time.parse('Sun Sep 14 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 06:00:00 PDT 1997'),
        Time.parse('Thu Sep 18 06:00:00 PDT 1997'),
        Time.parse('Sat Sep 20 06:00:00 PDT 1997'),
        Time.parse('Mon Sep 22 06:00:00 PDT 1997'),
        Time.parse('Wed Sep 24 06:00:00 PDT 1997'),
        Time.parse('Fri Sep 26 06:00:00 PDT 1997'),
        Time.parse('Sun Sep 28 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 30 06:00:00 PDT 1997'),
        Time.parse('Thu Oct  2 06:00:00 PDT 1997'),
        Time.parse('Sat Oct  4 06:00:00 PDT 1997'),
        Time.parse('Mon Oct  6 06:00:00 PDT 1997'),
        Time.parse('Wed Oct  8 06:00:00 PDT 1997'),
        Time.parse('Fri Oct 10 06:00:00 PDT 1997'),
        Time.parse('Sun Oct 12 06:00:00 PDT 1997'),
        Time.parse('Tue Oct 14 06:00:00 PDT 1997'),
        Time.parse('Thu Oct 16 06:00:00 PDT 1997'),
        Time.parse('Sat Oct 18 06:00:00 PDT 1997'),
        Time.parse('Mon Oct 20 06:00:00 PDT 1997'),
        Time.parse('Wed Oct 22 06:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;INTERVAL=2 and a limit' do
      rrule = 'FREQ=DAILY;INTERVAL=2'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Tue Sep  2 06:00:00 PDT 1997'), Time.parse('Wed Oct 22 06:00:00 PDT 1997'), limit: 5)).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Thu Sep  4 06:00:00 PDT 1997'),
        Time.parse('Sat Sep  6 06:00:00 PDT 1997'),
        Time.parse('Mon Sep  8 06:00:00 PDT 1997'),
        Time.parse('Wed Sep 10 06:00:00 PDT 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;INTERVAL=2;WKST=SU' do
      rrule = 'FREQ=WEEKLY;INTERVAL=2;WKST=SU'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Tue Sep  2 06:00:00 PDT 1997'), Time.parse('Tue Feb 17 06:00:00 PST 1998'))).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 30 06:00:00 PDT 1997'),
        Time.parse('Tue Oct 14 06:00:00 PDT 1997'),
        Time.parse('Tue Oct 28 06:00:00 PST 1997'),
        Time.parse('Tue Nov 11 06:00:00 PST 1997'),
        Time.parse('Tue Nov 25 06:00:00 PST 1997'),
        Time.parse('Tue Dec  9 06:00:00 PST 1997'),
        Time.parse('Tue Dec 23 06:00:00 PST 1997'),
        Time.parse('Tue Jan  6 06:00:00 PST 1998'),
        Time.parse('Tue Jan 20 06:00:00 PST 1998'),
        Time.parse('Tue Feb  3 06:00:00 PST 1998'),
        Time.parse('Tue Feb 17 06:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;BYMONTHDAY=-3' do
      rrule = 'FREQ=MONTHLY;BYMONTHDAY=-3'
      dtstart = Time.parse('Sun Sep 28 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Sun Sep 28 06:00:00 PDT 1997'), Time.parse('Thu Feb 26 06:00:00 PST 1998'))).to match_array([
        Time.parse('Sun Sep 28 06:00:00 PDT 1997'),
        Time.parse('Wed Oct 29 06:00:00 PST 1997'),
        Time.parse('Fri Nov 28 06:00:00 PST 1997'),
        Time.parse('Mon Dec 29 06:00:00 PST 1997'),
        Time.parse('Thu Jan 29 06:00:00 PST 1998'),
        Time.parse('Thu Feb 26 06:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;INTERVAL=2;BYDAY=TU' do
      rrule = 'FREQ=MONTHLY;INTERVAL=2;BYDAY=TU'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Tue Sep  2 06:00:00 PDT 1997'), Time.parse('Tue Mar 31 06:00:00 PST 1998'))).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
        Time.parse('Tue Sep  9 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 16 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 23 06:00:00 PDT 1997'),
        Time.parse('Tue Sep 30 06:00:00 PDT 1997'),
        Time.parse('Tue Nov  4 06:00:00 PST 1997'),
        Time.parse('Tue Nov 11 06:00:00 PST 1997'),
        Time.parse('Tue Nov 18 06:00:00 PST 1997'),
        Time.parse('Tue Nov 25 06:00:00 PST 1997'),
        Time.parse('Tue Jan  6 06:00:00 PST 1998'),
        Time.parse('Tue Jan 13 06:00:00 PST 1998'),
        Time.parse('Tue Jan 20 06:00:00 PST 1998'),
        Time.parse('Tue Jan 27 06:00:00 PST 1998'),
        Time.parse('Tue Mar  3 06:00:00 PST 1998'),
        Time.parse('Tue Mar 10 06:00:00 PST 1998'),
        Time.parse('Tue Mar 17 06:00:00 PST 1998'),
        Time.parse('Tue Mar 24 06:00:00 PST 1998'),
        Time.parse('Tue Mar 31 06:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;BYDAY=20MO' do
      rrule = 'FREQ=YEARLY;BYDAY=20MO'
      dtstart = Time.parse('Mon May 19 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Mon May 19 06:00:00 PDT 1997'), Time.parse('Mon May 17 06:00:00 PDT 1999'))).to match_array([
        Time.parse('Mon May 19 06:00:00 PDT 1997'),
        Time.parse('Mon May 18 06:00:00 PDT 1998'),
        Time.parse('Mon May 17 06:00:00 PDT 1999'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO' do
      rrule = 'FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO'
      dtstart = Time.parse('Mon May 12 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Mon May 12 06:00:00 PDT 1997'), Time.parse('Mon May 17 06:00:00 PDT 1999'))).to match_array([
        Time.parse('Mon May 12 06:00:00 PDT 1997'),
        Time.parse('Mon May 11 06:00:00 PDT 1998'),
        Time.parse('Mon May 17 06:00:00 PDT 1999'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;BYMONTH=3;BYDAY=TH' do
      rrule = 'FREQ=YEARLY;BYMONTH=3;BYDAY=TH'
      dtstart = Time.parse('Thu Mar 13 06:00:00 PST 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Thu Mar 13 06:00:00 PST 1997'), Time.parse('Thu Mar 25 06:00:00 PST 1999'))).to match_array([
        Time.parse('Thu Mar 13 06:00:00 PST 1997'),
        Time.parse('Thu Mar 20 06:00:00 PST 1997'),
        Time.parse('Thu Mar 27 06:00:00 PST 1997'),
        Time.parse('Thu Mar  5 06:00:00 PST 1998'),
        Time.parse('Thu Mar 12 06:00:00 PST 1998'),
        Time.parse('Thu Mar 19 06:00:00 PST 1998'),
        Time.parse('Thu Mar 26 06:00:00 PST 1998'),
        Time.parse('Thu Mar  4 06:00:00 PST 1999'),
        Time.parse('Thu Mar 11 06:00:00 PST 1999'),
        Time.parse('Thu Mar 18 06:00:00 PST 1999'),
        Time.parse('Thu Mar 25 06:00:00 PST 1999'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8' do
      rrule = 'FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8'
      dtstart = Time.parse('Thu Jun  5 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Thu Jun  5 06:00:00 PDT 1997'), Time.parse('Thu Aug 26 06:00:00 PDT 1999'))).to match_array([
        Time.parse('Thu Jun  5 06:00:00 PDT 1997'),
        Time.parse('Thu Jun 12 06:00:00 PDT 1997'),
        Time.parse('Thu Jun 19 06:00:00 PDT 1997'),
        Time.parse('Thu Jun 26 06:00:00 PDT 1997'),
        Time.parse('Thu Jul  3 06:00:00 PDT 1997'),
        Time.parse('Thu Jul 10 06:00:00 PDT 1997'),
        Time.parse('Thu Jul 17 06:00:00 PDT 1997'),
        Time.parse('Thu Jul 24 06:00:00 PDT 1997'),
        Time.parse('Thu Jul 31 06:00:00 PDT 1997'),
        Time.parse('Thu Aug  7 06:00:00 PDT 1997'),
        Time.parse('Thu Aug 14 06:00:00 PDT 1997'),
        Time.parse('Thu Aug 21 06:00:00 PDT 1997'),
        Time.parse('Thu Aug 28 06:00:00 PDT 1997'),
        Time.parse('Thu Jun  4 06:00:00 PDT 1998'),
        Time.parse('Thu Jun 11 06:00:00 PDT 1998'),
        Time.parse('Thu Jun 18 06:00:00 PDT 1998'),
        Time.parse('Thu Jun 25 06:00:00 PDT 1998'),
        Time.parse('Thu Jul  2 06:00:00 PDT 1998'),
        Time.parse('Thu Jul  9 06:00:00 PDT 1998'),
        Time.parse('Thu Jul 16 06:00:00 PDT 1998'),
        Time.parse('Thu Jul 23 06:00:00 PDT 1998'),
        Time.parse('Thu Jul 30 06:00:00 PDT 1998'),
        Time.parse('Thu Aug  6 06:00:00 PDT 1998'),
        Time.parse('Thu Aug 13 06:00:00 PDT 1998'),
        Time.parse('Thu Aug 20 06:00:00 PDT 1998'),
        Time.parse('Thu Aug 27 06:00:00 PDT 1998'),
        Time.parse('Thu Jun  3 06:00:00 PDT 1999'),
        Time.parse('Thu Jun 10 06:00:00 PDT 1999'),
        Time.parse('Thu Jun 17 06:00:00 PDT 1999'),
        Time.parse('Thu Jun 24 06:00:00 PDT 1999'),
        Time.parse('Thu Jul  1 06:00:00 PDT 1999'),
        Time.parse('Thu Jul  8 06:00:00 PDT 1999'),
        Time.parse('Thu Jul 15 06:00:00 PDT 1999'),
        Time.parse('Thu Jul 22 06:00:00 PDT 1999'),
        Time.parse('Thu Jul 29 06:00:00 PDT 1999'),
        Time.parse('Thu Aug  5 06:00:00 PDT 1999'),
        Time.parse('Thu Aug 12 06:00:00 PDT 1999'),
        Time.parse('Thu Aug 19 06:00:00 PDT 1999'),
        Time.parse('Thu Aug 26 06:00:00 PDT 1999'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13' do
      rrule = 'FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13'
      dtstart = Time.parse('Sat Sep 13 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Sat Sep 13 06:00:00 PDT 1997'), Time.parse('Sat Jun 13 06:00:00 PDT 1998'))).to match_array([
        Time.parse('Sat Sep 13 06:00:00 PDT 1997'),
        Time.parse('Sat Oct 11 06:00:00 PDT 1997'),
        Time.parse('Sat Nov  8 06:00:00 PST 1997'),
        Time.parse('Sat Dec 13 06:00:00 PST 1997'),
        Time.parse('Sat Jan 10 06:00:00 PST 1998'),
        Time.parse('Sat Feb  7 06:00:00 PST 1998'),
        Time.parse('Sat Mar  7 06:00:00 PST 1998'),
        Time.parse('Sat Apr 11 06:00:00 PDT 1998'),
        Time.parse('Sat May  9 06:00:00 PDT 1998'),
        Time.parse('Sat Jun 13 06:00:00 PDT 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8' do
      rrule = 'FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8'
      dtstart = Time.parse('Tue Nov  5 06:00:00 PST 1996')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Tue Nov  5 06:00:00 PST 1996'), Time.parse('Tue Nov  2 06:00:00 PST 2004'))).to match_array([
        Time.parse('Tue Nov  5 06:00:00 PST 1996'),
        Time.parse('Tue Nov  7 06:00:00 PST 2000'),
        Time.parse('Tue Nov  2 06:00:00 PST 2004'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2' do
      rrule = 'FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2'
      dtstart = Time.parse('Mon Sep 29 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Mon Sep 29 06:00:00 PDT 1997'), Time.parse('Mon Mar 30 06:00:00 PST 1998'))).to match_array([
        Time.parse('Mon Sep 29 06:00:00 PDT 1997'),
        Time.parse('Thu Oct 30 06:00:00 PST 1997'),
        Time.parse('Thu Nov 27 06:00:00 PST 1997'),
        Time.parse('Tue Dec 30 06:00:00 PST 1997'),
        Time.parse('Thu Jan 29 06:00:00 PST 1998'),
        Time.parse('Thu Feb 26 06:00:00 PST 1998'),
        Time.parse('Mon Mar 30 06:00:00 PST 1998'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;COUNT=7 when the range extends beyond the end of the recurrence (run out of COUNT before the range ends)' do
      rrule ='FREQ=DAILY;COUNT=7'
      dtstart = Time.parse('Thu Feb  6 16:00:00 PST 2014')
      timezone = 'America/Los_Angeles'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(Time.parse('Sun Feb  9 16:00:00 PST 2014'), Time.parse('Wed Feb 19 16:00:00 PST 2014'))).to match_array([
        Time.parse('Sun Feb  9 16:00:00 PST 2014'),
        Time.parse('Mon Feb 10 16:00:00 PST 2014'),
        Time.parse('Tue Feb 11 16:00:00 PST 2014'),
        Time.parse('Wed Feb 12 16:00:00 PST 2014'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=DAILY;COUNT=10 and an EXDATE' do
      rrule = 'FREQ=DAILY;COUNT=10'
      dtstart = Time.parse('Tue Sep  2 06:00:00 PST 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone, exdate: [Time.parse('Fri Sep  5 06:00:00 PST 1997'), Time.parse('Mon Sep  8 06:00:00 PST 1997')])
      expect(rrule.all).to match_array([
        Time.parse('Tue Sep  2 06:00:00 PST 1997'),
        Time.parse('Wed Sep  3 06:00:00 PST 1997'),
        Time.parse('Thu Sep  4 06:00:00 PST 1997'),
        Time.parse('Sat Sep  6 06:00:00 PST 1997'),
        Time.parse('Sun Sep  7 06:00:00 PST 1997'),
        Time.parse('Tue Sep  9 06:00:00 PST 1997'),
        Time.parse('Wed Sep 10 06:00:00 PST 1997'),
        Time.parse('Thu Sep 11 06:00:00 PST 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;INTERVAL=4;BYDAY=TH' do
      rrule = 'FREQ=WEEKLY;INTERVAL=4;BYDAY=TH'
      timezone = 'America/Los_Angeles'
      dtstart = Time.parse('Thu Jan 28 17:00:00 PST 2016').in_time_zone(timezone)

      rrule = RRule.parse(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.between(
        Time.parse('Tue May 24 14:34:59 PDT 2016'),
        Time.parse('Sun Jul 24 14:35:09 PDT 2016')
      )).to match_array([
        Time.parse('Thu Jun 16 17:00:00 PDT 2016'),
        Time.parse('Thu Jul 14 17:00:00 PDT 2016'),
      ])
    end

    it 'returns the correct result with a date start right on the year border' do
      rrule = 'FREQ=DAILY'
      timezone = 'America/Los_Angeles'
      dtstart = Time.parse('Thu Dec 31 16:00:00 PST 2015')

      rule = RRule.parse(rrule, dtstart: dtstart, tzid: timezone)
      expect(rule.between(dtstart - 1.month, dtstart + 1.month).first).to eql(dtstart)
    end

    it 'returns the correct result when BYSETPOS specifies a position that does not exist' do
      rrule = 'FREQ=MONTHLY;BYDAY=WE;BYSETPOS=5'
      timezone = 'America/Chicago'
      dtstart = Time.parse('Wed Jan 30 09:00:00 PST 2013')

      rule = RRule.parse(rrule, dtstart: dtstart, tzid: timezone)
      start_time = Time.parse('Sun Jul 31 22:00:00 PDT 2016')
      expected_instance = Time.parse('Wed Aug 31 09:00:00 PDT 2016')
      end_time = Time.parse('Wed Aug 31 21:59:59 PDT 2016')
      expect(rule.between(start_time, end_time)).to eql([expected_instance])
    end


    describe 'iterating with a floor_date' do
      describe 'No COUNT or INTERVAL > 1' do
        it 'still limits to the given range' do
          rrule = 'FREQ=DAILY'
          dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
          timezone = 'America/New_York'

          rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)

          start_time = Time.parse('Mon Sep  3 06:00:00 PDT 2018')
          end_time   = Time.parse('Thu Sep  10 06:00:00 PDT 2018')

          expect(rrule.between(start_time, end_time).take(3)).to match_array([
            Time.parse('Tue Sep  3 06:00:00 PDT 2018'),
            Time.parse('Wed Sep  4 06:00:00 PDT 2018'),
            Time.parse('Thu Sep  5 06:00:00 PDT 2018'),
          ])
        end
      end

      describe 'COUNT present' do
        it 'still limits to the given range' do
          rrule = 'FREQ=DAILY;COUNT=10'
          dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
          timezone = 'America/New_York'

          rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)

          start_time = Time.parse('Wed Sep  3 06:00:00 PDT 1997')
          end_time   = Time.parse('Thu Sep  10 06:00:00 PDT 2018')

          expect(rrule.between(start_time, end_time).take(3)).to match_array([
            Time.parse('Tue Sep  3 06:00:00 PDT 1997'),
            Time.parse('Wed Sep  4 06:00:00 PDT 1997'),
            Time.parse('Thu Sep  5 06:00:00 PDT 1997'),
          ])
        end
      end

      describe 'INTERVAL present' do
        it 'still limits to the given range' do
          rrule = 'FREQ=DAILY;INTERVAL=10'
          dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
          timezone = 'America/New_York'

          rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)

          start_time = Time.parse('Wed Sep  3 06:00:00 PDT 1997')
          end_time   = Time.parse('Thu Sep  30 06:00:00 PDT 2018')

          expect(rrule.between(start_time, end_time).take(3)).to match_array([
            Time.parse('Tue Sep 12 06:00:00 PDT 1997'),
            Time.parse('Fri Sep 22 06:00:00 PDT 1997'),
            Time.parse('Mon Oct 02 06:00:00 PDT 1997'),
          ])
        end
      end

      describe 'INTERVAL AND COUNT present' do
        it 'still limits to the given range' do
          rrule = 'FREQ=DAILY;INTERVAL=10;COUNT=5'
          dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
          timezone = 'America/New_York'

          rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)

          start_time = Time.parse('Wed Sep  3 06:00:00 PDT 1997')
          end_time   = Time.parse('Thu Sep  30 06:00:00 PDT 2018')

          expect(rrule.between(start_time, end_time).take(3)).to match_array([
            Time.parse('Tue Sep 12 06:00:00 PDT 1997'),
            Time.parse('Fri Sep 22 06:00:00 PDT 1997'),
            Time.parse('Mon Oct 02 06:00:00 PDT 1997'),
          ])
        end
      end
    end
  end

  describe '#from' do
    it 'returns the correct result with an rrule of FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU' do
      rrule = 'FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU'
      dtstart = Time.parse('2018-02-04 04:00:00 +1000')
      timezone = 'Brisbane'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.from(Time.parse('Sun, 08 Apr 2018 00:00:00 +0000'), limit: 9))
        .to match_array([
        Time.parse('Sun, 08 Apr 2018 23:59:59 +1000'),
        Time.parse('Sun, 15 Apr 2018 23:59:59 +1000'),
        Time.parse('Sun, 22 Apr 2018 23:59:59 +1000'),
        Time.parse('Sun, 29 Apr 2018 23:59:59 +1000'),
        Time.parse('Sun, 06 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 13 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 20 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 27 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 03 Jun 2018 23:59:59 +1000'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU starting beyond the beginning of the result' do
      rrule = 'FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU'
      dtstart = Time.parse('2018-02-04 04:00:00 +1000')
      timezone = 'Brisbane'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.from(Time.parse('Sun, 13 May 2018 23:59:59 +1000'), limit: 4))
        .to match_array([
        Time.parse('Sun, 13 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 20 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 27 May 2018 23:59:59 +1000'),
        Time.parse('Sun, 03 Jun 2018 23:59:59 +1000'),
      ])
    end
  end

  it 'returns the correct result with an rrule of FREQ=WEEKLY;BYMONTH=1,3;COUNT=4;BYHOUR=2' do
    rrule = 'FREQ=WEEKLY;BYMONTH=1,3;COUNT=4;BYHOUR=2'
    dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
    timezone = 'America/Los_Angeles'

    rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)

    expect(rrule.all).to match_array([
      Time.parse('Tue Jan  6 02:00:00 PST 1998'),
      Time.parse('Tue Jan 13 02:00:00 PST 1998'),
      Time.parse('Tue Jan 20 02:00:00 PST 1998'),
      Time.parse('Tue Jan 27 02:00:00 PST 1998'),
    ])
  end

  it 'returns the correct result with an rrule of FREQ=WEEKLY;BYMONTH=1,3;COUNT=4;BYHOUR=2;BYMINUTE=44' do
    rrule = 'FREQ=WEEKLY;BYMONTH=1,3;COUNT=4;BYHOUR=2;BYMINUTE=44'
    dtstart = Time.parse('Tue Sep  2 09:00:00 PDT 1997')
    timezone = 'America/Los_Angeles'

    rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
    expect(rrule.all).to match_array([
      Time.parse('Tue Jan  6 02:44:00 PST 1998'),
      Time.parse('Tue Jan 13 02:44:00 PST 1998'),
      Time.parse('Tue Jan 20 02:44:00 PST 1998'),
      Time.parse('Tue Jan 27 02:44:00 PST 1998'),
    ])
  end

  it 'returns the correct result with an rrule of FREQ=WEEKLY;BYMONTH=1,3;COUNT=24;BYHOUR=2,4,6;BYMINUTE=33,22' do
    rrule = 'FREQ=WEEKLY;BYMONTH=1,3;COUNT=24;BYHOUR=2,4,6;BYMINUTE=33,22'
    dtstart = Time.parse('Tue Sep  2 09:23:42 PDT 1997')
    timezone = 'America/Los_Angeles'

    rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
    expect(rrule.all).to match_array([
      Time.parse('Tue Jan  6 02:22:42 PST 1998'),
      Time.parse('Tue Jan  6 02:33:42 PST 1998'),
      Time.parse('Tue Jan  6 04:22:42 PST 1998'),
      Time.parse('Tue Jan  6 04:33:42 PST 1998'),
      Time.parse('Tue Jan  6 06:22:42 PST 1998'),
      Time.parse('Tue Jan  6 06:33:42 PST 1998'),
      Time.parse('Tue Jan 13 02:22:42 PST 1998'),
      Time.parse('Tue Jan 13 02:33:42 PST 1998'),
      Time.parse('Tue Jan 13 04:22:42 PST 1998'),
      Time.parse('Tue Jan 13 04:33:42 PST 1998'),
      Time.parse('Tue Jan 13 06:22:42 PST 1998'),
      Time.parse('Tue Jan 13 06:33:42 PST 1998'),
      Time.parse('Tue Jan 20 02:22:42 PST 1998'),
      Time.parse('Tue Jan 20 02:33:42 PST 1998'),
      Time.parse('Tue Jan 20 04:22:42 PST 1998'),
      Time.parse('Tue Jan 20 04:33:42 PST 1998'),
      Time.parse('Tue Jan 20 06:22:42 PST 1998'),
      Time.parse('Tue Jan 20 06:33:42 PST 1998'),
      Time.parse('Tue Jan 27 02:22:42 PST 1998'),
      Time.parse('Tue Jan 27 02:33:42 PST 1998'),
      Time.parse('Tue Jan 27 04:22:42 PST 1998'),
      Time.parse('Tue Jan 27 04:33:42 PST 1998'),
      Time.parse('Tue Jan 27 06:22:42 PST 1998'),
      Time.parse('Tue Jan 27 06:33:42 PST 1998'),
    ])
  end

  context 'when DTSTART is a Date' do
    it 'returns the correct result with an rrule of FREQ=DAILY;COUNT=10 and a limit' do
      rrule = 'FREQ=DAILY;COUNT=10'
      dtstart = Date.parse('Tue Sep  2 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all(limit: 5)).to match_array([
        Date.parse('Tue Sep  2 1997'),
        Date.parse('Wed Sep  3 1997'),
        Date.parse('Thu Sep  4 1997'),
        Date.parse('Fri Sep  5 1997'),
        Date.parse('Sat Sep  6 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=WEEKLY;INTERVAL=1;WKST=SU and a limit' do
      rrule = 'FREQ=WEEKLY;INTERVAL=1;WKST=SU'
      dtstart = Date.parse('Fri Sep  5 1997')

      rrule = RRule::Rule.new(rrule, dtstart: dtstart)
      expect(rrule.all(limit: 4)).to match_array([
         Date.parse('Fri Sep  5 1997'),
         Date.parse('Fri Sep  12 1997'),
         Date.parse('Fri Sep  19 1997'),
         Date.parse('Fri Sep  26 1997'),
       ])
    end

    it 'returns the correct result with an rrule of FREQ=MONTHLY;UNTIL=19971224;BYDAY=1FR' do
      rrule = 'FREQ=MONTHLY;UNTIL=19971224;BYDAY=1FR'
      dtstart = Date.parse('Fri Sep  5 1997')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Date.parse('Fri Sep  5 1997'),
        Date.parse('Fri Oct  3 1997'),
        Date.parse('Fri Nov  7 1997'),
        Date.parse('Fri Dec  5 1997'),
      ])
    end

    it 'returns the correct result with an rrule of FREQ=YEARLY;UNTIL=20000131;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA' do
      rrule = 'FREQ=YEARLY;UNTIL=20000131;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA'
      dtstart = Date.parse('Thu Jan  1 1998')
      timezone = 'America/New_York'

      rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)
      expect(rrule.all).to match_array([
        Date.parse('Thu Jan  1 1998'),
        Date.parse('Fri Jan  2 1998'),
        Date.parse('Sat Jan  3 1998'),
        Date.parse('Sun Jan  4 1998'),
        Date.parse('Mon Jan  5 1998'),
        Date.parse('Tue Jan  6 1998'),
        Date.parse('Wed Jan  7 1998'),
        Date.parse('Thu Jan  8 1998'),
        Date.parse('Fri Jan  9 1998'),
        Date.parse('Sat Jan 10 1998'),
        Date.parse('Sun Jan 11 1998'),
        Date.parse('Mon Jan 12 1998'),
        Date.parse('Tue Jan 13 1998'),
        Date.parse('Wed Jan 14 1998'),
        Date.parse('Thu Jan 15 1998'),
        Date.parse('Fri Jan 16 1998'),
        Date.parse('Sat Jan 17 1998'),
        Date.parse('Sun Jan 18 1998'),
        Date.parse('Mon Jan 19 1998'),
        Date.parse('Tue Jan 20 1998'),
        Date.parse('Wed Jan 21 1998'),
        Date.parse('Thu Jan 22 1998'),
        Date.parse('Fri Jan 23 1998'),
        Date.parse('Sat Jan 24 1998'),
        Date.parse('Sun Jan 25 1998'),
        Date.parse('Mon Jan 26 1998'),
        Date.parse('Tue Jan 27 1998'),
        Date.parse('Wed Jan 28 1998'),
        Date.parse('Thu Jan 29 1998'),
        Date.parse('Fri Jan 30 1998'),
        Date.parse('Sat Jan 31 1998'),
        Date.parse('Fri Jan  1 1999'),
        Date.parse('Sat Jan  2 1999'),
        Date.parse('Sun Jan  3 1999'),
        Date.parse('Mon Jan  4 1999'),
        Date.parse('Tue Jan  5 1999'),
        Date.parse('Wed Jan  6 1999'),
        Date.parse('Thu Jan  7 1999'),
        Date.parse('Fri Jan  8 1999'),
        Date.parse('Sat Jan  9 1999'),
        Date.parse('Sun Jan 10 1999'),
        Date.parse('Mon Jan 11 1999'),
        Date.parse('Tue Jan 12 1999'),
        Date.parse('Wed Jan 13 1999'),
        Date.parse('Thu Jan 14 1999'),
        Date.parse('Fri Jan 15 1999'),
        Date.parse('Sat Jan 16 1999'),
        Date.parse('Sun Jan 17 1999'),
        Date.parse('Mon Jan 18 1999'),
        Date.parse('Tue Jan 19 1999'),
        Date.parse('Wed Jan 20 1999'),
        Date.parse('Thu Jan 21 1999'),
        Date.parse('Fri Jan 22 1999'),
        Date.parse('Sat Jan 23 1999'),
        Date.parse('Sun Jan 24 1999'),
        Date.parse('Mon Jan 25 1999'),
        Date.parse('Tue Jan 26 1999'),
        Date.parse('Wed Jan 27 1999'),
        Date.parse('Thu Jan 28 1999'),
        Date.parse('Fri Jan 29 1999'),
        Date.parse('Sat Jan 30 1999'),
        Date.parse('Sun Jan 31 1999'),
        Date.parse('Sat Jan  1 2000'),
        Date.parse('Sun Jan  2 2000'),
        Date.parse('Mon Jan  3 2000'),
        Date.parse('Tue Jan  4 2000'),
        Date.parse('Wed Jan  5 2000'),
        Date.parse('Thu Jan  6 2000'),
        Date.parse('Fri Jan  7 2000'),
        Date.parse('Sat Jan  8 2000'),
        Date.parse('Sun Jan  9 2000'),
        Date.parse('Mon Jan 10 2000'),
        Date.parse('Tue Jan 11 2000'),
        Date.parse('Wed Jan 12 2000'),
        Date.parse('Thu Jan 13 2000'),
        Date.parse('Fri Jan 14 2000'),
        Date.parse('Sat Jan 15 2000'),
        Date.parse('Sun Jan 16 2000'),
        Date.parse('Mon Jan 17 2000'),
        Date.parse('Tue Jan 18 2000'),
        Date.parse('Wed Jan 19 2000'),
        Date.parse('Thu Jan 20 2000'),
        Date.parse('Fri Jan 21 2000'),
        Date.parse('Sat Jan 22 2000'),
        Date.parse('Sun Jan 23 2000'),
        Date.parse('Mon Jan 24 2000'),
        Date.parse('Tue Jan 25 2000'),
        Date.parse('Wed Jan 26 2000'),
        Date.parse('Thu Jan 27 2000'),
        Date.parse('Fri Jan 28 2000'),
        Date.parse('Sat Jan 29 2000'),
        Date.parse('Sun Jan 30 2000'),
        Date.parse('Mon Jan 31 2000'),
      ])
    end
  end

  describe 'validation' do
    it 'raises RRule::InvalidRRule if FREQ is not provided' do
      expect { RRule::Rule.new('') }.to raise_error(RRule::InvalidRRule)
      expect { RRule::Rule.new('FREQ=') }.to raise_error(RRule::InvalidRRule)
      expect { RRule::Rule.new('FREQ=FOO') }.to raise_error(RRule::InvalidRRule)
      expect { RRule::Rule.new('COUNT=1') }.to raise_error(RRule::InvalidRRule)
      expect { RRule::Rule.new('FREQ=FOO;COUNT=1') }.to raise_error(RRule::InvalidRRule)
    end

    it 'raises RRule::InvalidRRule if INTERVAL is not a positive integer' do
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      expect { RRule::Rule.new('FREQ=DAILY;INTERVAL=0', dtstart: dtstart, tzid: timezone) }.to raise_error(RRule::InvalidRRule)
      expect { RRule::Rule.new('FREQ=DAILY;INTERVAL=-1', dtstart: dtstart, tzid: timezone) }.to raise_error(RRule::InvalidRRule)
      expect { RRule::Rule.new('FREQ=DAILY;INTERVAL=1.1', dtstart: dtstart, tzid: timezone) }.to raise_error(RRule::InvalidRRule)
      expect { RRule::Rule.new('FREQ=DAILY;INTERVAL=BOOM', dtstart: dtstart, tzid: timezone) }.to raise_error(RRule::InvalidRRule)
    end

    it 'raises RRule::InvalidRRule if COUNT is not an integer' do
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      expect { RRule::Rule.new('FREQ=DAILY;COUNT=BOOM', dtstart: dtstart, tzid: timezone) }.to raise_error(RRule::InvalidRRule)
      expect { RRule::Rule.new('FREQ=DAILY;COUNT=1.5', dtstart: dtstart, tzid: timezone) }.to raise_error(RRule::InvalidRRule)
    end

    it 'raises RRule::InvalidRRule if COUNT is negative' do
      dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
      timezone = 'America/New_York'

      expect { RRule::Rule.new('FREQ=DAILY;COUNT=-1', dtstart: dtstart, tzid: timezone) }.to raise_error(RRule::InvalidRRule)
    end
  end

  it "correctly parses rule strings with an 'RRULE:' prefix" do
    rrule = 'RRULE:INTERVAL=2;FREQ=DAILY;COUNT=10'
    dtstart = Time.parse('Tue Sep  2 06:00:00 PDT 1997')
    timezone = 'America/New_York'

    rrule = RRule::Rule.new(rrule, dtstart: dtstart, tzid: timezone)

    expect(rrule.next).to eql Time.parse('Tue Sep  2 06:00:00 PDT 1997')
    expect(rrule.next).to eql Time.parse('Wed Sep  4 06:00:00 PDT 1997')
    expect(rrule.next).to eql Time.parse('Thu Sep  6 06:00:00 PDT 1997')
  end

  it 'correctly returns the parsed rule when invoking the to_s method' do
    rrule_string = 'RRULE:INTERVAL=2;FREQ=DAILY;COUNT=10'
    rrule = RRule::Rule.new(rrule_string)

    expect(rrule.to_s).to eql rrule_string
  end

  describe '#humanize' do
    let(:dtstart) { Time.parse('Tue Sep  2 06:00:00 PDT 1997') }
    let(:timezone) { 'America/New_York' }
    let(:rrule) { RRule::Rule.new(rule, dtstart: dtstart, tzid: timezone) }

    context 'every day' do
      let(:rule) { 'RRULE:FREQ=DAILY;INTERVAL=1' }

      it { expect(rrule.humanize).to eq 'every day' }
    end

    context 'every day at 1' do
      let(:rule) { 'RRULE:FREQ=DAILY;INTERVAL=1;BYHOUR=1' }

      it { expect(rrule.humanize).to eq 'every day at 1' }
    end

    context 'every day weekly' do
      let(:rule) { 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR,SA,SU' }

      it { expect(rrule.humanize).to eq 'every day' }
    end

    context 'every week on Tuesday, Thursday' do
      let(:rule) { 'FREQ=WEEKLY;INTERVAL=1;BYDAY=TU,TH' }

      it { expect(rrule.humanize).to eq 'every week on Tuesday, Thursday' }
    end

    context 'every 2 weeks on Tuesday, Thursday' do
      let(:rule) { 'FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH' }

      it { expect(rrule.humanize).to eq 'every 2 weeks on Tuesday, Thursday' }
    end

    context 'every month on the last Friday for 7 times' do
      let(:rule) { 'FREQ=MONTHLY;BYDAY=-1FR;COUNT=7' }

      it { expect(rrule.humanize).to eq 'every month on the last Friday for 7 times' }
    end

    context 'every month on the first Monday and last Friday for 7 times' do
      let(:rule) { 'FREQ=MONTHLY;BYDAY=1MO,-1FR;COUNT=7' }

      it { expect(rrule.humanize).to eq 'every month on the 1st Monday and last Friday for 7 times' }
    end
  end
end
