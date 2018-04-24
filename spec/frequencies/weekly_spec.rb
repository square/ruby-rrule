require 'spec_helper'

describe RRule::Weekly do
  let(:interval) { 1 }
  let(:context) do
    RRule::Context.new(
        { interval: interval, wkst: 1 },
        date,
        'America/Los_Angeles'
    )
  end
  let(:filters) { [RRule::ByWeekDay.new([RRule::Weekday.new(date.wday)], context)] }
  let(:generator) { RRule::AllOccurrences.new(context) }
  let(:timeset) { [{ hour: date.hour, minute: date.min, second: date.sec }] }

  before { context.rebuild(date.year, date.month) }

  describe '#next_occurrences' do
    subject(:frequency) { described_class.new(context, filters, generator, timeset) }

    context 'with an interval of one' do
      let(:date) { Time.zone.local(1997, 1, 1) }

      it 'returns sequential weeks' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 8)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 15)]
      end
    end

    context 'with an interval of two' do
      let(:interval) { 2 }
      let(:date) { Time.zone.local(1997, 1, 1) }

      it 'returns every other week' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 15)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 29)]
      end
    end

    context 'on the first day of the year with five days left in the week' do
      let(:date) { Time.zone.local(1997, 1, 1) }

      it 'returns the next three weeks' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 8)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 15)]
      end
    end

    context 'on a day in the first month with two days left in the week' do
      let(:date) { Time.zone.local(1997, 1, 25) }

      it 'returns the next three weeks' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 25)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 2, 1)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 2, 8)]
      end
    end

    context 'on a day in the next month with six days left in the week' do
      let(:date) { Time.zone.local(1997, 2, 25) }

      it 'returns the next three weeks' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 2, 25)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 3, 4)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 3, 11)]
      end
    end

    context 'on the last day of February' do
      let(:date) { Time.zone.local(1997, 2, 28) }

      it 'returns the next three weeks' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 2, 28)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 3, 7)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 3, 14)]
      end
    end

    context 'on the last day of the year' do
      let(:date) { Time.zone.local(1997, 12, 31) }

      it 'returns the next three weeks' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 12, 31)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1998, 1, 7)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1998, 1, 14)]
      end
    end
  end
end
