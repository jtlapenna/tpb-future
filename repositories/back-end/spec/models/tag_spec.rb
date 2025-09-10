require 'rails_helper'

describe ActsAsTaggableOn::Tag do
  context 'exist some tags' do
    before do
      (1..10).each { |n| ActsAsTaggableOn::Tag.create!(name: "tag-#{n}") }

      tag = ActsAsTaggableOn::Tag.create!(name: 'special tag')
    end

    it 'find by scope name_like' do
      expect(ActsAsTaggableOn::Tag.name_like('a').count).to eq 11
      expect(ActsAsTaggableOn::Tag.name_like('special').count).to eq 1
    end

    context 'existing tags in kiosk' do
      let(:kiosk) { create :kiosk }

      before do
        kiosk.tag_list.add('awesome', 'amazing', 'wonderful')
        kiosk.save
      end

      it 'get only kiosk tags ' do
        expect(ActsAsTaggableOn::Tag.name_like('a').for_model(Kiosk).map(&:name).sort).to eq %w[amazing awesome]
      end

      context 'exists more tags in others kiosks' do
        let(:kiosk2) { create :kiosk }

        before do
          kiosk2.tag_list.add('awesome2', 'amazing2', 'wonderful2')
          kiosk2.save

          kiosk3 = create :kiosk
          kiosk3.tag_list.add('awesome3', 'amazing3', 'wonderful3')
          kiosk3.save
        end

        it 'get tags for all kiosks' do
          expect(ActsAsTaggableOn::Tag.name_like('a').for_model(Kiosk).map(&:name).sort).to eq %w[amazing amazing2 amazing3 awesome awesome2 awesome3]
        end

        it 'get tags for 2 specifics kiosks' do
          expect(ActsAsTaggableOn::Tag.name_like('a').for_objects([kiosk, kiosk2]).map(&:name).sort).to eq %w[amazing amazing2 awesome awesome2]
        end

        it 'get tags only for one kiosk' do
          expect(ActsAsTaggableOn::Tag.name_like('a').for_object(kiosk).map(&:name).sort).to eq %w[amazing awesome]
        end
      end
    end

    context 'and existing tags in kiosk product' do
      let(:store_product) { create :store_product }

      before do
        store_product.tag_list.add('awesome', 'amazing', 'wonderful')
        store_product.save
      end

      it 'get only kiosk product tags ' do
        expect(ActsAsTaggableOn::Tag.name_like('a').for_model(StoreProduct).map(&:name).sort).to eq %w[amazing awesome]
      end
    end
  end
end
