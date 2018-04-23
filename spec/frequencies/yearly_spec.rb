require 'spec_helper'

describe RRule::Yearly do
  let(:interval) { 1 }
  let(:context) do
    RRule::Context.new(
        { interval: interval, wkst: 1 },
        date,
        'America/Los_Angeles'
    )
  end
  let(:filters) { [RRule::ByMonth.new([date.month], context), RRule::ByMonthDay.new([date.day], context)] }
  let(:generator) { RRule::AllOccurrences.new(context) }
  let(:timeset) { [{ hour: date.hour, minute: date.min, second: date.sec }] }

  before(:each) { context.rebuild(date.year, date.month) }

  describe '#next_occurrences' do
    subject(:frequency) { described_class.new(context, filters, generator, timeset) }

    context 'on the first day of the year' do
      let(:date) { Time.new(1997, 1, 1) }

      it 'returns the next three years' do
        expect(frequency.next_occurrences).to eql [Time.new(1997, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.new(1998, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.new(1999, 1, 1)]
      end
    end

    context 'on the last day of February in a leap year' do
      let(:date) { Time.new(2000, 2, 29) }

      it 'skips non-leap years' do
        expect(frequency.next_occurrences).to eql [Time.new(2000, 2, 29)]
        expect(frequency.next_occurrences).to eql []
        expect(frequency.next_occurrences).to eql []
        expect(frequency.next_occurrences).to eql []
        expect(frequency.next_occurrences).to eql [Time.new(2004, 2, 29)]
      end
    end

    context 'with an interval of two' do
      let(:interval) { 2 }
      let(:date) { Time.new(1997, 1, 1) }

      it 'returns every other year' do
        expect(frequency.next_occurrences).to eql [Time.new(1997, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.new(1999, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.new(2001, 1, 1)]
      end
    end
  end
end
