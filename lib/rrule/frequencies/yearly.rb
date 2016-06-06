module RRule
  class Yearly < Frequency
    def possible_days
      (0...context.year_length_in_days).to_a
    end

    private

    def advance_by
      { years: context.options[:interval] }
    end
  end
end

