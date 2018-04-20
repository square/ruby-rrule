require 'spec_helper'

describe RRule::Weekly do
  let(:context) do
    RRule::Context.new(
        { interval: 1, wkst: 1 },
        date,
        'America/Los_Angeles'
    )
  end

  before(:each) { context.rebuild(1997, 1) }

  describe '#possible_days' do
    subject { described_class.new(context, nil, nil, nil).possible_days }

    context 'on the first day of the year with five days left in the week' do
      let(:date) { Date.new(1997, 1, 1)}

      it { is_expected.to eql (0..4).to_a }
    end

    context 'on a day in the first month with two days left in the week' do
      let(:date) { Date.new(1997, 1, 25)}

      it { is_expected.to eql (24..25).to_a }
    end

    context 'on a day in the next month with six days left in the week' do
      let(:date) { Date.new(1997, 2, 25)}

      it { is_expected.to eql (55..60).to_a }
    end
  end

  describe '#advance' do
    subject { described_class.new(context, nil, nil, nil).advance }

    context 'on the first day of the year' do
      let(:date) { Date.new(1997, 1, 1)}

      it { is_expected.to eql date.next_week }
    end

    context 'on the last day of February' do
      let(:date) { Date.new(1997, 2, 28)}

      it { is_expected.to eql date.next_week }
    end

    context 'on the last day of the year' do
      let(:date) { Date.new(1997, 12, 31)}

      it { is_expected.to eql date.next_week }
    end
  end
end
