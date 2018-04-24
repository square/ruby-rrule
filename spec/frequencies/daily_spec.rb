require 'spec_helper'

describe RRule::Daily do
  let(:interval) { 1 }
  let(:context) do
    RRule::Context.new(
        { interval: interval },
        date,
        'America/Los_Angeles'
    )
  end
  let(:filters) { [] }
  let(:generator) { RRule::AllOccurrences.new(context) }
  let(:timeset) { [{ hour: date.hour, minute: date.min, second: date.sec }] }

  before { context.rebuild(date.year, date.month) }

  describe '#next_occurrences' do
    subject(:frequency) { described_class.new(context, filters, generator, timeset) }

    context 'with an interval of one' do
      let(:date) { Time.zone.local(1997, 1, 1) }

      it 'returns sequential days' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 2)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 3)]
      end
    end

    context 'with an interval of two' do
      let(:interval) { 2 }
      let(:date) { Time.zone.local(1997, 1, 1) }

      it 'returns every other day' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 3)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 5)]
      end
    end

    context 'on the last day of February' do
      let(:date) { Time.zone.local(1997, 2, 28) }

      it 'goes into the next month' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 2, 28)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 3, 1)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 3, 2)]
      end
    end

    context 'on the last day of the year' do
      let(:date) { Time.zone.local(1997, 12, 31) }

      it 'goes into the next year' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 12, 31)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1998, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1998, 1, 2)]
      end
    end
  end
end
