require 'rails_helper'

RSpec.describe CovasoftApiParser do
  RSpec.configure do |config|
    config.include ActiveSupport::Testing::TimeHelpers
  end
  describe '#promotion_active?' do
    let(:parser) { described_class.new(store_id: 1) }
    
    around do |example|
      travel_to Time.zone.local(2024, 1, 15, 14, 30) do # Tuesday at 2:30 PM
        example.run
      end
    end

    context 'when promotion is nil' do
      it 'returns true for backward compatibility' do
        expect(parser.send(:promotion_active?, nil)).to be true
      end
    end

    context 'when promotion status is not Active' do
      let(:promotion) { { Status: 'Inactive', Period: {} } }

      it 'returns false' do
        expect(parser.send(:promotion_active?, promotion)).to be false
      end
    end

    context 'when promotion has missing required fields' do
      let(:promotion) { { Status: 'Active' } } # Missing Period

      it 'returns true for backward compatibility' do
        expect(parser.send(:promotion_active?, promotion)).to be true
      end
    end

    context 'with Definite period type' do
      let(:base_promotion) do
        {
          Status: 'Active',
          Period: {
            Tag: 'Definite',
            DateRanges: []
          }
        }
      end

      it 'returns true when current time is within a date range' do
        promotion = base_promotion.deep_merge(
          Period: {
            DateRanges: [{
              StartDate: '2024-01-01T00:00:00',
              EndDate: '2024-01-31T23:59:59'
            }]
          }
        )
        expect(parser.send(:promotion_active?, promotion)).to be true
      end

      it 'returns false when current time is outside all date ranges' do
        promotion = base_promotion.deep_merge(
          Period: {
            DateRanges: [{
              StartDate: '2024-02-01T00:00:00',
              EndDate: '2024-02-28T23:59:59'
            }]
          }
        )
        expect(parser.send(:promotion_active?, promotion)).to be false
      end

      it 'returns true if any date range matches' do
        promotion = base_promotion.deep_merge(
          Period: {
            DateRanges: [
              {
                StartDate: '2023-12-01T00:00:00',
                EndDate: '2023-12-31T23:59:59'
              },
              {
                StartDate: '2024-01-01T00:00:00',
                EndDate: '2024-01-31T23:59:59'
              }
            ]
          }
        )
        expect(parser.send(:promotion_active?, promotion)).to be true
      end

      it 'returns false when DateRanges array is empty' do
        promotion = base_promotion.deep_merge(
          Period: {
            DateRanges: []
          }
        )
        expect(parser.send(:promotion_active?, promotion)).to be false
      end
    end

    context 'with Recurrent period type' do
      let(:base_promotion) do
        {
          Status: 'Active',
          Period: {
            Tag: 'Recurrent',
            Pattern: {
              DaysOfTheWeek: ['Monday', 'Tuesday', 'Wednesday']
            },
            TimeSchedule: {
              StartTime: '09:00:00',
              EndTime: '17:00:00'
            },
            EffectiveDateRange: {
              StartDate: '2024-01-01T00:00:00',
              EndDate: '2024-12-31T23:59:59'
            }
          }
        }
      end

      it 'returns true when all conditions match' do
        expect(parser.send(:promotion_active?, base_promotion)).to be true
      end

      it 'returns false when outside effective date range' do
        promotion = base_promotion.deep_merge(
          Period: {
            EffectiveDateRange: {
              StartDate: '2025-01-01T00:00:00',
              EndDate: '2025-12-31T23:59:59'
            }
          }
        )
        expect(parser.send(:promotion_active?, promotion)).to be false
      end

      it 'returns false when day of week does not match' do
        promotion = base_promotion.deep_merge(
          Period: {
            Pattern: {
              DaysOfTheWeek: ['Thursday', 'Friday']
            }
          }
        )
        expect(parser.send(:promotion_active?, promotion)).to be false
      end

      it 'returns false when outside time schedule' do
        promotion = base_promotion.deep_merge(
          Period: {
            TimeSchedule: {
              StartTime: '17:31:00',
              EndTime: '23:59:59'
            }
          }
        )
        expect(parser.send(:promotion_active?, promotion)).to be false
      end

    end

    context 'with unknown period type' do
      let(:promotion) do
        {
          Status: 'Active',
          Period: {
            Tag: 'Unknown'
          }
        }
      end

      it 'returns true for backward compatibility' do
        expect(parser.send(:promotion_active?, promotion)).to be true
      end

      it 'handles case-insensitive period tags' do
        promotion = {
          Status: 'Active',
          Period: {
            Tag: 'DEFINITE'
          }
        }
        expect(parser.send(:promotion_active?, promotion)).to be true
      end
    end
  end
end
