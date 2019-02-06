# frozen_string_literal: true

require 'spec_helper'

describe RRule::ByMonth do
  let(:context) do
    RRule::Context.new(
        { freq: 'MONTHLY', count: 4 },
        Time.parse('Wed Jan  1 00:00:00 PST 1997'),
        'America/Los_Angeles'
    )
  end

  subject { described_class.new([1, 3], context).reject?(date.yday) }

  before(:each) { context.rebuild(1997, 1) }

  describe '#reject?' do
    context 'for a day in January' do
      let(:date) { Date.new(1997, 1, 15) }

      it { is_expected.to be false }
    end

    context 'for a day in February' do
      let(:date) { Date.new(1997, 2, 15) }

      it { is_expected.to be true }
    end

    context 'for a day in March' do
      let(:date) { Date.new(1997, 3, 15) }

      it { is_expected.to be false }
    end
  end
end
