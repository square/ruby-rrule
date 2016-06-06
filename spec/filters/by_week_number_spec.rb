require 'spec_helper'

describe RRule::ByWeekNumber do
  let(:context) do
    RRule::Context.new(
        { freq: 'YEARLY', wkst: 1 },
        Time.parse('Wed Jan  1 00:00:00 PST 1997'),
        'America/Los_Angeles'
    )
  end

  subject { described_class.new([2, -3], context).reject?(date.yday - 1) }

  before(:each) { context.rebuild(1997, 1) }

  describe '#reject?' do
    context 'for the first week of the year' do
      let(:date) { Date.new(1997, 1, 2) }

      it { is_expected.to be true }
    end

    context 'for the second week of the year' do
      let(:date) { Date.new(1997, 1, 8) }

      it { is_expected.to be false }
    end

    context 'for the fourth week of the year' do
      let(:date) { Date.new(1997, 1, 22) }

      it { is_expected.to be true }
    end

    context 'for the third-to-last week of the year' do
      let(:date) { Date.new(1997, 12, 9) }

      it { is_expected.to be false }
    end
  end
end
