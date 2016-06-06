require 'spec_helper'

describe RRule::ByMonthDay do
  let(:context) do
    RRule::Context.new(
        { freq: 'MONTHLY', count: 4 },
        Time.parse('Wed Jan  1 00:00:00 PST 1997'),
        'America/Los_Angeles'
    )
  end

  subject { described_class.new([3, -3], context).reject?(date.yday - 1) }

  before(:each) { context.rebuild(1997, 1) }

  describe '#reject?' do
    context 'for the third day of the month' do
      let(:date) { Date.new(1997, 1, 3) }

      it { is_expected.to be false }
    end

    context 'for the fourth day of the month' do
      let(:date) { Date.new(1997, 1, 4) }

      it { is_expected.to be true }
    end

    context 'for the third-to-last day of the month' do
      let(:date) { Date.new(1997, 1, 29) }

      it { is_expected.to be false }
    end
  end
end
