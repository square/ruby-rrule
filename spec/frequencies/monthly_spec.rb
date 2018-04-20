require 'spec_helper'

describe RRule::Monthly do
  let(:context) do
    RRule::Context.new(
        { interval: 1 },
        date,
        'America/Los_Angeles'
    )
  end

  before(:each) { context.rebuild(1997, 1) }

  describe '#possible_days' do
    subject { described_class.new(context, nil, nil, nil).possible_days }

    context 'on the first day of the year' do
      let(:date) { Date.new(1997, 1, 1)}

      it { is_expected.to eql (0..30).to_a }
    end

    context 'on a day in the first month' do
      let(:date) { Date.new(1997, 1, 25)}

      it { is_expected.to eql (0..30).to_a }
    end

    context 'on a day in the next month' do
      let(:date) { Date.new(1997, 2, 25)}

      it { is_expected.to eql (31..58).to_a }
    end
  end

  describe '#advance' do
    subject { described_class.new(context, nil, nil, nil).advance }

    context 'on the first day of the year' do
      let(:date) { Date.new(1997, 1, 1)}

      it { is_expected.to eql date + 1.month }
    end

    context 'on the last day of February' do
      let(:date) { Date.new(1997, 2, 28)}

      it { is_expected.to eql date + 1.month }
    end

    context 'on the last day of the year' do
      let(:date) { Date.new(1997, 12, 31)}

      it { is_expected.to eql date + 1.month }
    end
  end
end
