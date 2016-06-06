require 'spec_helper'

describe RRule::ByWeekDay do
  let(:context) do
    RRule::Context.new(
        { freq: 'WEEKLY', count: 4 },
        Time.parse('Wed Jan  1 00:00:00 PST 1997'),
        'America/Los_Angeles'
    )
  end

  subject { described_class.new([RRule::Weekday.parse('TU'), RRule::Weekday.parse('FR')], context).reject?(date.yday - 1) }

  before(:each) { context.rebuild(1997, 1) }

  describe '#reject?' do
    context 'for the Friday of the week' do
      let(:date) { Date.new(1997, 1, 3) }

      it { is_expected.to be false }
    end

    context 'for the Saturday of the week' do
      let(:date) { Date.new(1997, 1, 4) }

      it { is_expected.to be true }
    end

    context 'for the Tuesday of the next week' do
      let(:date) { Date.new(1997, 1, 7) }

      it { is_expected.to be false }
    end
  end
end
