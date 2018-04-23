require 'spec_helper'

describe RRule::Monthly do
  let(:interval) { 1 }
  let(:context) do
    RRule::Context.new(
        { interval: interval },
        date,
        'UTC'
    )
  end
  let(:filters) { [RRule::ByMonthDay.new([date.day], context)] }
  let(:generator) { RRule::AllOccurrences.new(context) }
  let(:timeset) { [{ hour: date.hour, minute: date.min, second: date.sec }] }

  before { context.rebuild(date.year, date.month) }

  describe '#next_occurrences' do
    subject(:frequency) { described_class.new(context, filters, generator, timeset) }

    context 'with an interval of one' do
      let(:date) { Time.utc(1997, 1, 1) }

      it 'returns sequential months' do
        expect(frequency.next_occurrences).to eql [Time.utc(1997, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.utc(1997, 2, 1)]
        expect(frequency.next_occurrences).to eql [Time.utc(1997, 3, 1)]
      end
    end

    context 'with an interval of two' do
      let(:interval) { 2 }
      let(:date) { Time.utc(1997, 1, 1) }

      it 'returns every other month' do
        expect(frequency.next_occurrences).to eql [Time.utc(1997, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.utc(1997, 3, 1)]
        expect(frequency.next_occurrences).to eql [Time.utc(1997, 5, 1)]
      end
    end

    context 'on the last day of February' do
      let(:date) { Time.utc(1997, 2, 28) }

      it 'returns the next three months' do
        expect(frequency.next_occurrences).to eql [Time.utc(1997, 2, 28)]
        expect(frequency.next_occurrences).to eql [Time.utc(1997, 3, 28)]
        expect(frequency.next_occurrences).to eql [Time.utc(1997, 4, 28)]
      end
    end

    context 'on the last day of the year' do
      let(:date) { Time.utc(1997, 12, 31) }

      it 'returns empty arrays for periods with no matching occurrences' do
        expect(frequency.next_occurrences).to eql [Time.utc(1997, 12, 31)]
        expect(frequency.next_occurrences).to eql [Time.utc(1998, 1, 31)]
        expect(frequency.next_occurrences).to eql []
        expect(frequency.next_occurrences).to eql [Time.utc(1998, 3, 31)]
      end
    end
  end
end
