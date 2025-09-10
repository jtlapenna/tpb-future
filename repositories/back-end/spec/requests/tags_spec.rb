require 'rails_helper'

describe 'Tags API' do
  let(:user) { create :user }

  def tag_json(tag)
    tag.as_json(only: [:name])
  end

  context '#index' do
    let(:tags) { ActsAsTaggableOn::Tag.all.order(name: :asc) }
    let(:expected_tags) { tags.map { |t| tag_json(t) } }

    before do
      create :product, tag_list: 'tag 2, tag1, tag3, another'
    end

    it 'respond with tags ordered by name' do
      get tags_path, headers: auth_headers(user)

      expect(json).to have_key('tags')
      expect(json['tags'].count).to eq 4
      expect(json['tags']).to eq expected_tags
    end

    context 'filtering tags' do
      let(:tags) { ActsAsTaggableOn::Tag.where("name ilike '%tag%'").order(name: :asc) }

      it 'filter result' do
        get tags_path, params: { q: 'tag' }, headers: auth_headers(user)

        expect(json).to have_key('tags')
        expect(json['tags'].count).to eq 3
        expect(json['tags']).to eq expected_tags
      end
    end
  end

  context 'exist tags for 2 kiosks (own tags, and kiosk product)' do
    let(:kiosk) { create :kiosk, store: store_product.store }
    let(:kiosk2) { create :kiosk, store: store_product2.store }
    let(:store_product) { create :store_product }
    let(:store_product2) { create :store_product }

    before do
      (1..10).each { |n| ActsAsTaggableOn::Tag.create!(name: "tag-#{n}") } # tags randoms alone

      create :kiosk_product, kiosk: kiosk, store_product: store_product
      create :kiosk_product, kiosk: kiosk2, store_product: store_product2

      store_product.tag_list.add('tag-kiosk-product') && store_product.save
      kiosk.tag_list.add('tag-kiosk') && kiosk.save

      store_product2.tag_list.add('kiosk-2-tag-kiosk-product') && store_product2.save
      kiosk2.tag_list.add('kiosk-2-tag-kiosk') && kiosk2.save
    end

    it 'get tags specific kiosk' do
      get tags_path, params: { kiosk_id: kiosk.id, q: 'a' }, headers: auth_headers(user)

      expected_tags = %w[tag-kiosk tag-kiosk-product]
      expect(json['tags'].map { |t| t['name'] }.sort).to eq expected_tags
    end
  end
end
