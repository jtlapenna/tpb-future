require 'rails_helper'

describe KioskProduct do
  let(:product) { build_stubbed :kiosk_product }

  it 'is valid' do
    expect(product).to be_valid
  end

  it 'is not valid without store_product' do
    product.store_product = nil

    expect(product).not_to be_valid
    expect(product.errors[:store_product]).to eq ['must exist']
  end

  context '#destroy' do
    let(:kiosk_product) { create :kiosk_product }

    it 'should destroy rfids, attributes values, videos and product values' do
      rfid = create :rfid_product, rfid_entity: kiosk_product

      kiosk_product.destroy

      # Do not remove rfids
      expect(RfidProduct.count).to eq 1
      expect(rfid.reload.rfid_entity_id).to be_nil
    end
  end

  context 'fetured product' do
    let(:kiosk) { create :kiosk, store: store }
    let(:store_product) { create :store_product, store: store }
    let(:product) { create :kiosk_product, store_product: store_product, kiosk: kiosk }

    context 'when store is on rfid mode' do
      let(:store) { create :store, categories_count: 1, featured_mode: :rfid_featured }

      it 'it is not featured' do
        expect(product).not_to be_featured_product
      end

      it 'it is not featured event if flag is true' do
        product.update_attribute(:featured, true)

        expect(product).not_to be_featured_product
      end

      context 'with rfids' do
        before do
          create :rfid_product, rfid_entity: product
        end

        it 'is featured' do
          expect(product).to be_featured_product
        end
      end
    end

    context 'when store is on manual mode' do
      let(:store) { create :store, categories_count: 1, featured_mode: :manual_featured }

      it 'it is not featured' do
        expect(product).not_to be_featured_product
      end

      it 'it is not featured event with an rfid' do
        create :rfid_product, rfid_entity: product

        expect(product).not_to be_featured_product
      end

      context 'with featured flag' do
        before do
          product.update_attribute(:featured, true)
        end

        it 'is featured' do
          expect(product).to be_featured_product
        end
      end
    end

    context 'when store is on mixed mode' do
      let(:store) { create :store, categories_count: 1, featured_mode: :rfid_and_manual_featured }

      it 'it is not featured' do
        expect(product).not_to be_featured_product
      end

      it 'it is featured with an rfid' do
        create :rfid_product, rfid_entity: product

        expect(product).to be_featured_product
      end

      it 'it is featured when the flag is on' do
        product.update_attribute(:featured, true)

        expect(product).to be_featured_product
      end

      it 'it is featured when the flag is on an rfid exist' do
        create :rfid_product, rfid_entity: product
        product.update_attribute(:featured, true)

        expect(product).to be_featured_product
      end

      it 'it is featured when the flag is off an rfid exist' do
        create :rfid_product, rfid_entity: product
        product.update_attribute(:featured, false)

        expect(product).to be_featured_product
      end
    end
  end
end
