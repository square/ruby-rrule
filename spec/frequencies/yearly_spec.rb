require 'spec_helper'

describe RRule::Yearly do
  let(:date) { Date.new(1997, 1, 1) }
  let(:context) do
    RRule::Context.new(
        { interval: 1, wkst: 1 },
        date,
        'America/Los_Angeles'
    )
  end

  before(:each) { context.rebuild(1997, 1) }

  describe '#possible_days' do
    subject { described_class.new(context).possible_days }

    context 'in a non leap year' do
      before(:each) { context.rebuild(1997, 1) }

      it { is_expected.to eql (0..364).to_a }
    end

    context 'in a leap year' do
      before(:each) { context.rebuild(2000, 1) }

      it { is_expected.to eql (0..365).to_a }
    end
  end

  describe '#advance' do
    subject { described_class.new(context).advance }

    context 'on the first day of the year' do
      let(:date) { Date.new(1997, 1, 1)}

      it { is_expected.to eql date + 1.year }
    end

    context 'on the last day of February' do
      let(:date) { Date.new(1997, 2, 28)}

      it { is_expected.to eql date + 1.year }
    end

    context 'on the last day of the year' do
      let(:date) { Date.new(1997, 12, 31)}

      it { is_expected.to eql date + 1.year }
    end
  end
end
