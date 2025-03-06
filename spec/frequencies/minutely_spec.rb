# frozen_string_literal: true

require 'spec_helper'

describe RRule::Minutely do
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
      let(:date) { Time.zone.local(1997, 1, 1, 0, 0) }

      it 'returns sequential minutes' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1, 0, 0)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1, 0, 1)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1, 0, 2)]
      end
    end

    context 'with an interval of two' do
      let(:interval) { 2 }
      let(:date) { Time.zone.local(1997, 1, 1, 0, 0) }

      it 'returns every other minute' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1, 0, 0)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1, 0, 2)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1, 0, 4)]
      end
    end

    context 'at the end of the hour' do
      let(:date) { Time.zone.local(1997, 1, 1, 0, 59) }

      it 'goes into the next hour' do
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1, 0, 59)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1, 1, 0)]
        expect(frequency.next_occurrences).to eql [Time.zone.local(1997, 1, 1, 1, 1)]
      end
    end
  end
end
