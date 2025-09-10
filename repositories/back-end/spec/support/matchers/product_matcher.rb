require 'rspec/expectations'

module CustomMatchers
  module Product
    extend RSpec::Matchers::DSL

    def product_diff(actual, sample)
      return [] if sample.blank? || actual.blank?

      # sort product_values
      actual['product_values']&.sort_by! { |pv| -pv['id'] }
      sample['product_values']&.sort_by! { |pv| -pv['id'] }
      actual['rfids']&.sort!
      sample['rfids']&.sort!

      Hashdiff.diff(actual, sample)
    end

    matcher :match_product do |sample|
      match do |actual|
        @diff = product_diff(sample.dup, actual.dup)
        @diff.empty?
      end

      failure_message do |actual|
        str = "expected that #{actual} equals to #{sample}"
        str += "\n\n Hash diff: \n\n#{@diff}"
      end
    end

    matcher :match_products do |samples|
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
        samples.count.times { |i| @diffs << product_diff(actuals[i], samples[i]) }

        @diffs.flatten.select(&:present?).empty?
      end
    end
  end
end
