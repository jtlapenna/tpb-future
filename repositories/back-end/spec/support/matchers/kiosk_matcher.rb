require 'rspec/expectations'

module CustomMatchers
  module Kiosk
    extend RSpec::Matchers::DSL

    def kiosk_diff(actual, sample)
      return [] if sample.blank? || actual.blank?

      Hashdiff.diff(actual, sample)
    end

    matcher :match_kiosk do |sample|
      match do |actual|
        @diff = kiosk_diff(sample.dup, actual.dup)
        @diff.empty?
      end

      failure_message do |actual|
        str = "expected that #{actual} equals to #{sample}"
        str += "\n\n Hash diff: \n\n#{@diff}"
      end
    end

    matcher :match_kiosks do |samples|
      match do |actuals|
        similar?(samples, actuals)
      end

      failure_message do |actuals|
        str = "expected that #{actuals} equals to #{samples}"
        str += "\n\n Hash diff: \n\n #{@diffs}"
      end

      def similar?(samples, actuals)
        return false if samples.blank? || actuals.blank?
        return false if samples.count != actuals.count

        @diffs = []
        samples.count.times { |i| @diffs << kiosk_diff(actuals[i], samples[i]) }

        @diffs.flatten.select(&:present?).empty?
      end
    end
  end
end
