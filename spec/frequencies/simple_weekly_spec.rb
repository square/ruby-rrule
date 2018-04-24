require 'spec_helper'

describe RRule::SimpleWeekly do
  let(:context) { RRule::Context.new({ interval: interval }, date, nil) }
  let(:frequency) { described_class.new(context, nil, nil, nil) }

  describe '#next_occurrences' do
    let(:date) { Date.new(1997, 1, 1) }

    context 'with an interval of 1' do
      let(:interval) { 1 }

      it 'returns occurrences every week' do
        expect(frequency.next_occurrences).to eql [Date.new(1997, 1, 1)]
        expect(frequency.next_occurrences).to eql [Date.new(1997, 1, 8)]
        expect(frequency.next_occurrences).to eql [Date.new(1997, 1, 15)]
      end
    end

    context 'with an interval of 2' do
      let(:interval) { 2 }

      it 'returns occurrences every other week' do
        expect(frequency.next_occurrences).to eql [Date.new(1997, 1, 1)]
        expect(frequency.next_occurrences).to eql [Date.new(1997, 1, 15)]
        expect(frequency.next_occurrences).to eql [Date.new(1997, 1, 29)]
      end
    end
  end
end
