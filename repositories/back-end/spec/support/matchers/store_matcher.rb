require 'rspec/expectations'

module CustomMatchers
  module Store
    extend RSpec::Matchers::DSL

    def store_diff(actual, sample)
      return [] if sample.blank? || actual.blank?

      # sort categories
      actual['store_categories']&.sort_by! { |pv| -pv['id'] }
      sample['store_categories']&.sort_by! { |pv| -pv['id'] }

      Hashdiff.diff(actual, sample)
    end

    matcher :match_store do |sample|
      match do |actual|
        @diff = store_diff(sample.dup, actual.dup)
        @diff.empty?
      end

      failure_message do |actual|
        str = "expected that #{actual} equals to #{sample}"
        str += "\n\n Hash diff: \n\n#{@diff}"
      end
    end

    matcher :match_stores do |samples|
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
        samples.count.times { |i| @diffs << store_diff(actuals[i], samples[i]) }

        @diffs.flatten.select(&:present?).empty?
      end
    end
  end
end
