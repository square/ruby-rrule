# frozen_string_literal: true

require 'spec_helper'

describe RRule::Context do
  let(:context) do
    RRule::Context.new(
      { freq: 'DAILY', count: 3 },
      Time.parse('Tue Sep  2 06:00:00 PDT 1997'),
      'America/Los_Angeles'
    )
  end

  before(:each) { context.rebuild(1997, 1) }

  describe '#year_length_in_days' do
    subject { context.year_length_in_days }

    context 'in a non leap year' do
      before(:each) { context.rebuild(1997, 1) }

      it { is_expected.to eql 365 }
    end

    context 'in a leap year' do
      before(:each) { context.rebuild(2000, 1) }

      it { is_expected.to eql 366 }
    end
  end

  describe '#next_year_length_in_days' do
    subject { context.next_year_length_in_days }

    context 'in a year not prior to a leap year' do
      before(:each) { context.rebuild(1997, 1) }

      it { is_expected.to eql 365 }
    end

    context 'in a year prior to a leap year' do
      before(:each) { context.rebuild(1999, 1) }

      it { is_expected.to eql 366 }
    end
  end

  describe '#first_day_of_year' do
    subject { context.first_day_of_year }

    it { is_expected.to eq Date.new(1997, 1, 1) }
  end

  describe '#month_by_day_of_year' do
    subject(:month_by_day_of_year) { context.month_by_day_of_year }

    context 'in a leap year' do
      before(:each) { context.rebuild(2000, 1) }

      it 'maps the day of the year to the month number' do
        expect(month_by_day_of_year.length).to eql 366 + 7 # 7 padding days
        expect(month_by_day_of_year[0]).to eql 1
        expect(month_by_day_of_year[59]).to eql 2
        expect(month_by_day_of_year[365]).to eql 12
      end
    end

    context 'in a non leap year' do
      before(:each) { context.rebuild(1997, 1) }

      it 'maps the day of the year to the month number' do
        expect(month_by_day_of_year.length).to eql 365 + 7 # 7 padding days
        expect(month_by_day_of_year[0]).to eql 1
        expect(month_by_day_of_year[59]).to eql 3
        expect(month_by_day_of_year[364]).to eql 12
      end
    end
  end

  describe '#month_day_by_day_of_year' do
    subject(:month_day_by_day_of_year) { context.month_day_by_day_of_year }

    context 'in a leap year' do
      before(:each) { context.rebuild(2000, 1) }

      it 'maps the month day of the year to the month number' do
        expect(month_day_by_day_of_year.length).to eql 366 + 7 # 7 padding days
        expect(month_day_by_day_of_year[0]).to eql 1
        expect(month_day_by_day_of_year[1]).to eql 2
        expect(month_day_by_day_of_year[59]).to eql 29
        expect(month_day_by_day_of_year[365]).to eql 31
      end
    end

    context 'in a non leap year' do
      before(:each) { context.rebuild(1997, 1) }

      it 'maps the month day of the year to the month number' do
        expect(month_day_by_day_of_year.length).to eql 365 + 7 # 7 padding days
        expect(month_day_by_day_of_year[0]).to eql 1
        expect(month_day_by_day_of_year[1]).to eql 2
        expect(month_day_by_day_of_year[59]).to eql 1
        expect(month_day_by_day_of_year[364]).to eql 31
      end
    end
  end

  describe '#negative_month_day_by_day_of_year' do
    subject(:negative_month_day_by_day_of_year) { context.negative_month_day_by_day_of_year }

    context 'in a leap year' do
      before(:each) { context.rebuild(2000, 1) }

      it 'maps the month day of the year to the month number' do
        expect(negative_month_day_by_day_of_year.length).to eql 366 + 7 # 7 padding days
        expect(negative_month_day_by_day_of_year[0]).to eql(-31)
        expect(negative_month_day_by_day_of_year[1]).to eql(-30)
        expect(negative_month_day_by_day_of_year[59]).to eql(-1)
        expect(negative_month_day_by_day_of_year[365]).to eql(-1)
      end
    end

    context 'in a non leap year' do
      before(:each) { context.rebuild(1997, 1) }

      it 'maps the month day of the year to the month number' do
        expect(negative_month_day_by_day_of_year.length).to eql 365 + 7 # 7 padding days
        expect(negative_month_day_by_day_of_year[0]).to eql(-31)
        expect(negative_month_day_by_day_of_year[1]).to eql(-30)
        expect(negative_month_day_by_day_of_year[59]).to eql(-31)
        expect(negative_month_day_by_day_of_year[364]).to eql(-1)
      end
    end
  end

  describe '#week_number_by_day_of_year' do
    subject(:week_number_by_day_of_year) { context.week_number_by_day_of_year }

    context 'when the first day of the year is in the first week of that calendar-week-based year' do
      before(:each) { context.rebuild(1997, 1) }

      it 'is part of the current calendar-week-based year' do
        expect(week_number_by_day_of_year[0]).to eql 1
      end
    end

    context 'when the first day of the year is in the last week of the previous calendar-week-based year' do
      before(:each) { context.rebuild(1999, 1) }

      it 'is part of the previous calendar-week-based year' do
        expect(week_number_by_day_of_year[0]).to eql 53
      end
    end

    context 'when the last day of the year is in the last week of that calendar-week-based year' do
      before(:each) { context.rebuild(1999, 1) }

      it 'is part of the current calendar-week-based year' do
        expect(week_number_by_day_of_year[364]).to eql 52
      end
    end

    context 'when the last day of the year is in the first week of the next calendar-week-based year' do
      before(:each) { context.rebuild(1997, 1) }

      it 'is part of the next calendar-week-based year' do
        expect(week_number_by_day_of_year[364]).to eql 1
      end
    end
  end

  describe '#negative_week_number_by_day_of_year' do
    subject(:negative_week_number_by_day_of_year) { context.negative_week_number_by_day_of_year }

    context 'when the first day of the year is in the first week of that calendar-week-based year' do
      before(:each) { context.rebuild(1997, 1) }

      it 'is part of the current calendar-week-based year' do
        expect(negative_week_number_by_day_of_year[0]).to eql(-52)
      end
    end

    context 'when the first day of the year is in the last week of the previous calendar-week-based year' do
      before(:each) { context.rebuild(1999, 1) }

      it 'is part of the previous calendar-week-based year' do
        expect(negative_week_number_by_day_of_year[0]).to eql(-1)
      end
    end

    context 'when the last day of the year is in the last week of that calendar-week-based year' do
      before(:each) { context.rebuild(1999, 1) }

      it 'is part of the current calendar-week-based year' do
        expect(negative_week_number_by_day_of_year[364]).to eql(-1)
      end
    end

    context 'when the last day of the year is in the first week of the next calendar-week-based year' do
      before(:each) { context.rebuild(1997, 1) }

      it 'is part of the next calendar-week-based year' do
        expect(negative_week_number_by_day_of_year[364]).to eql(-53)
      end
    end
  end

  describe '#first_weekday_of_year' do
    subject { context.first_weekday_of_year }

    it { is_expected.to eq 3 }
  end

  describe '#weekday_by_day_of_year' do
    subject { context.weekday_by_day_of_year }

    it { is_expected.to start_with(3, 4, 5, 6, 0, 1, 2) }
  end

  describe '#elapsed_days_in_year_by_month' do
    subject { context.elapsed_days_in_year_by_month }

    context 'in a leap year' do
      before(:each) { context.rebuild(2000, 1) }

      it { is_expected.to start_with(0, 31, 60, 91) }
    end

    context 'in a non leap year' do
      before(:each) { context.rebuild(1997, 1) }

      it { is_expected.to start_with(0, 31, 59, 90) }
    end
  end

  describe '#day_of_year_mask' do
    let(:context) do
      RRule::Context.new(
          { freq: 'MONTHLY', count: 3, bynweekday: [RRule::Weekday.parse('3TU'), RRule::Weekday.parse('-2MO')] },
          Time.parse('Wed Jan  1 00:00:00 PST 1997'),
          'America/Los_Angeles'
      )
    end

    subject(:day_of_year_mask) { context.day_of_year_mask }

    it 'correctly masks all days except the third Tuesday and the next-to-last Monday in January 1997' do
      day_of_year_mask.each_with_index do |available, day_of_year|
        expect(available).to be [19, 20].include?(day_of_year)
      end
    end

    context 'when the month is advanced' do
      before(:each) { context.rebuild(1997, 2) }

      it 'correctly masks all days except the third Tuesday and the next-to-last Monday in February 1997' do
        day_of_year_mask.each_with_index do |available, day_of_year|
          expect(available).to be [48, 47].include?(day_of_year)
        end
      end
    end
  end
end
