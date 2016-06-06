require 'spec_helper'

describe RRule::Daily do
  let(:context) do
    RRule::Context.new(
        { interval: 1 },
        date,
        'America/Los_Angeles'
    )
  end

  describe '#possible_days' do
    subject { described_class.new(context).possible_days }

    context 'on the first day of the year' do
      let(:date) { Date.new(1997, 1, 1)}

      it { is_expected.to eql [0] }
    end

    context 'on a day in the first month' do
      let(:date) { Date.new(1997, 1, 25)}

      it { is_expected.to eql [24] }
    end

    context 'on a day in the next month' do
      let(:date) { Date.new(1997, 2, 25)}

      it { is_expected.to eql [55] }
    end
  end

  describe '#advance' do
    subject { described_class.new(context).advance }

    context 'on the first day of the year' do
      let(:date) { Date.new(1997, 1, 1)}

      it { is_expected.to eql date + 1.day }
    end

    context 'on the last day of February' do
      let(:date) { Date.new(1997, 2, 28)}

      it { is_expected.to eql date + 1.day }
    end

    context 'on the last day of the year' do
      let(:date) { Date.new(1997, 12, 31)}

      it { is_expected.to eql date + 1.day }
    end
  end
end
