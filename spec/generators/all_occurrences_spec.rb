# frozen_string_literal: true

require 'spec_helper'

describe RRule::AllOccurrences do
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
    subject { described_class.new(context).combine_dates_and_times(dates, times)}

    context 'with a single date and time' do
      let(:dates) { [0] }
      let(:times) { [{ hour: 12, minute: 30, second: 15 }] }

      it { is_expected.to match_array [Time.parse('Wed Jan  1 12:30:15 PST 1997')] }
    end

    context 'with multiple dates and a single time' do
      let(:dates) { [0, 15] }
      let(:times) { [{ hour: 12, minute: 30, second: 15 }] }

      it { is_expected.to match_array [Time.parse('Wed Jan  1 12:30:15 PST 1997'), Time.parse('Thu Jan 16 12:30:15 PST 1997')] }
    end

    context 'with a single date and multiple times' do
      let(:dates) { [0] }
      let(:times) { [{ hour: 12, minute: 30, second: 15 }, { hour: 18, minute: 45, second: 20 }] }

      it { is_expected.to match_array [Time.parse('Wed Jan  1 12:30:15 PST 1997'), Time.parse('Wed Jan  1 18:45:20 PST 1997')] }
    end
  end
end
