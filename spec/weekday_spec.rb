# frozen_string_literal: true

require 'spec_helper'

describe RRule::Weekday do
  describe '.parse' do
    subject(:weekday) { described_class.parse(weekday_string) }

    context 'with an explicit + for the ordinal' do
      let(:weekday_string) { '+2SU' }

      it 'parses correctly' do
        expect(weekday.ordinal).to eql 2
        expect(weekday.index).to eql 0
      end
    end

    context 'with an implied + for the ordinal' do
      let(:weekday_string) { '2SU' }

      it 'parses correctly' do
        expect(weekday.ordinal).to eql 2
        expect(weekday.index).to eql 0
      end
    end

    context 'with a negative ordinal' do
      let(:weekday_string) { '-3TU' }

      it 'parses correctly' do
        expect(weekday.ordinal).to eql(-3)
        expect(weekday.index).to eql 2
      end
    end
  end
end
