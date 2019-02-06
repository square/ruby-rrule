# frozen_string_literal: true

require 'spec_helper'

describe RRule::ByYearDay do
  let(:context) do
    RRule::Context.new(
        { freq: 'YEARLY', count: 4 },
        Time.parse('Wed Jan  1 00:00:00 PST 1997'),
        'America/Los_Angeles'
    )
  end

  subject { described_class.new([45, -45], context).reject?(date.yday - 1) }

  before(:each) { context.rebuild(1997, 1) }

  describe '#reject?' do
    context 'for the 45th day of the year' do
      let(:date) { Date.new(1997, 2, 14) }

      it { is_expected.to be false }
    end

    context 'for the 60th day of the year' do
      let(:date) { Date.new(1997, 3, 1) }

      it { is_expected.to be true }
    end

    context 'for the 45th-from-last day of the month' do
      let(:date) { Date.new(1997, 11, 17) }

      it { is_expected.to be false }
    end
  end
end
