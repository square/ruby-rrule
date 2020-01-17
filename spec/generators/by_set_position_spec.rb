# frozen_string_literal: true

require 'spec_helper'

describe RRule::BySetPosition do
  let(:context) do
    RRule::Context.new(
        { interval: 1, wkst: 1 },
        Time.parse('Wed Jan  1 00:00:00 PST 1997'),
        'America/Los_Angeles'
    )
  end

  around(:each) do |example|
    Time.use_zone('America/Los_Angeles') do
      example.run
    end
  end

  before(:each) { context.rebuild(1997, 1) }

  describe '#combine_dates_and_times' do
    subject { described_class.new(positions, context).combine_dates_and_times(dates, times)}

    context 'with a single set position' do
      let(:positions) { [0] }
      let(:dates) { [0, 1, 2, 3, 4] }
      let(:times) { [{ hour: 12, minute: 30, second: 15 }] }

      it { is_expected.to match_array [Time.parse('Wed Jan  1 12:30:15 PST 1997')] }
    end

    context 'with multiple set positions' do
      let(:positions) { [1, 3] }
      let(:dates) { [0, 1, 2, 3, 4] }
      let(:times) { [{ hour: 12, minute: 30, second: 15 }] }

      it { is_expected.to match_array [Time.parse('Wed Jan  1 12:30:15 PST 1997'), Time.parse('Fri Jan  3 12:30:15 PST 1997')] }
    end
  end
end
