require 'spec_helper'

describe RRule::SimpleWeekly do
  let(:context) { RRule::Context.new({ interval: interval }, date, 'America/Los_Angeles') }
  let(:frequency) { described_class.new(context, nil, generator, timeset) }
  let(:generator) { RRule::AllOccurrences.new(context) }
  let(:timeset) { [{ hour: date.hour, minute: date.min, second: date.sec }] }

  describe '#next_occurrences' do
    let(:date) { Time.zone.local(1997, 1, 1) }

    context 'with an interval of 1' do
      let(:interval) { 1 }

      it 'returns occurrences every week' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 8)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 15)]
      end
    end

    context 'with an interval of 2' do
      let(:interval) { 2 }

      it 'returns occurrences every other week' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 15)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 29)]
      end
    end
  end
end
