require 'spec_helper'

describe RRule::Generator do
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

  describe '#process_timeset' do
    describe "single timeset" do
      subject { described_class.new(context).process_timeset(date, timeset)}

      context 'with a timeset with only 1 set' do
        let(:date) { Time.parse('Wed Jan  1 00:11:22 PST 1997') }
        let(:timeset) { [{ hour: 12, minute: 30, second: 15 }] }

        it { is_expected.to match_array [Time.parse('Wed Jan  1 12:30:15 PST 1997')] }
      end

      context 'with multiple hours in the timeset' do
        let(:date) { Time.parse('Wed Jan  1 00:11:22 PST 1997') }
        let(:timeset) { [{ hour: [12, 15], minute: 30, second: 15 }] }

        it { is_expected.to match_array [Time.parse('Wed Jan  1 12:30:15 PST 1997'), Time.parse('Wed Jan  1 15:30:15 PST 1997')] }
      end

      context 'with multiple minutes in the timeset' do
        let(:date) { Time.parse('Wed Jan  1 00:11:22 PST 1997') }
        let(:timeset) { [{ hour: [12], minute: [15, 30], second: 15 }] }

        it { is_expected.to match_array [Time.parse('Wed Jan  1 12:15:15 PST 1997'), Time.parse('Wed Jan  1 12:30:15 PST 1997')] }
      end

      context 'with multiple seconds in the timeset' do
        let(:date) { Time.parse('Wed Jan  1 00:11:22 PST 1997') }
        let(:timeset) { [{ hour: [12], minute: [30], second: [15, 59] }] }

        it { is_expected.to match_array [Time.parse('Wed Jan  1 12:30:15 PST 1997'), Time.parse('Wed Jan  1 12:30:59 PST 1997')] }
      end

      context 'with multiple hours, minutes, and seconds in the timeset' do
        let(:date) { Time.parse('Wed Jan  1 00:11:22 PST 1997') }
        let(:timeset) { [{ hour: [12, 20], minute: [30, 55], second: [15, 59] }] }

        it { is_expected.to eq [
          Time.parse('Wed Jan  1 12:30:15 PST 1997'),
          Time.parse('Wed Jan  1 12:30:59 PST 1997'),
          Time.parse('Wed Jan  1 12:55:15 PST 1997'),
          Time.parse('Wed Jan  1 12:55:59 PST 1997'),
          Time.parse('Wed Jan  1 20:30:15 PST 1997'),
          Time.parse('Wed Jan  1 20:30:59 PST 1997'),
          Time.parse('Wed Jan  1 20:55:15 PST 1997'),
          Time.parse('Wed Jan  1 20:55:59 PST 1997'),
        ] }
      end

      context 'with multiple hours, minutes, and seconds in the timeset, unsorted' do
        let(:date) { Time.parse('Wed Jan  1 00:11:22 PST 1997') }
        let(:timeset) { [{ hour: [20, 12], minute: [55, 30], second: [59, 15] }] }

        it { is_expected.to eq [
          Time.parse('Wed Jan  1 12:30:15 PST 1997'),
          Time.parse('Wed Jan  1 12:30:59 PST 1997'),
          Time.parse('Wed Jan  1 12:55:15 PST 1997'),
          Time.parse('Wed Jan  1 12:55:59 PST 1997'),
          Time.parse('Wed Jan  1 20:30:15 PST 1997'),
          Time.parse('Wed Jan  1 20:30:59 PST 1997'),
          Time.parse('Wed Jan  1 20:55:15 PST 1997'),
          Time.parse('Wed Jan  1 20:55:59 PST 1997'),
        ] }
      end
    end
  end

  describe "multiple timesets" do
    subject { described_class.new(context).process_timeset(date, timeset)}

      context 'with multiple timsets' do
        let(:date) { Time.parse('Wed Jan  1 00:11:22 PST 1997') }
        let(:timeset) { [{ hour: 12, minute: 30, second: 15 }, { hour: 18, minute: 45, second: 20 }] }

        it { is_expected.to eq [Time.parse('Wed Jan  1 12:30:15 PST 1997'), Time.parse('Wed Jan  1 18:45:20 PST 1997')] }
      end

      context 'with multiple timsets with multiple hour sets' do
        let(:date) { Time.parse('Wed Jan  1 00:11:22 PST 1997') }
        let(:timeset) { [{ hour: [12, 20], minute: 30, second: [15, 45] }, { hour: 18, minute: [22, 45], second: 20 }] }

        it { is_expected.to eq [
          Time.parse('Wed Jan  1 12:30:15 PST 1997'),
          Time.parse('Wed Jan  1 12:30:45 PST 1997'),
          Time.parse('Wed Jan  1 20:30:15 PST 1997'),
          Time.parse('Wed Jan  1 20:30:45 PST 1997'),
          Time.parse('Wed Jan  1 18:22:20 PST 1997'),
          Time.parse('Wed Jan  1 18:45:20 PST 1997')
        ] }
      end
  end
end
