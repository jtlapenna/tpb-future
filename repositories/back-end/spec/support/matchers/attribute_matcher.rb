require 'rspec/expectations'

module CustomMatchers
  module Attribute
    extend RSpec::Matchers::DSL

    matcher :match_attributes do |samples|
      match do |actuals|
        similar?(samples.dup, actuals.dup)
      end

      def similar?(samples, actuals)
        samples['ungrouped'].sort_by! { |a| a['name'] }
        actuals['ungrouped'].sort_by! { |a| a['name'] }

        samples['grouped'].each_key { |key| samples['grouped'][key].sort_by! { |a| a['name'] } }
        actuals['grouped'].each_key { |key| actuals['grouped'][key].sort_by! { |a| a['name'] } }

        expect(samples).to eq actuals
      end

      diffable
    end
  end
end
