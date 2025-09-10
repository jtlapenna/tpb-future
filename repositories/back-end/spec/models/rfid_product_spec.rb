require 'rails_helper'

describe RfidProduct do
  let(:rfid_product) { build_stubbed :rfid_product }

  it 'is valid' do
    expect(rfid_product).to be_valid
  end

  it 'convert to rfid upcase' do
    rfid_product.rfid = 'AbcDef'

    expect do
      rfid_product.valid?
    end.to change {
      rfid_product.rfid
    }.from('AbcDef').to 'ABCDEF'
  end

  context 'uniqueness' do
    let(:rfid_product) { create :rfid_product }

    it 'rfid is unique by catalog' do
      expect(rfid_product).to be_valid

      same_kiosk = build_stubbed :rfid_product, rfid: rfid_product.rfid, rfid_entity: rfid_product.rfid_entity

      expect(same_kiosk).not_to be_valid
      expect(same_kiosk.errors[:rfid]).to eq ['has already been taken']

      other_catalog = build_stubbed :rfid_product, rfid: rfid_product.rfid
      expect(other_catalog).to be_valid
    end
  end

  context 'denormalize store_id' do
    let(:rfid_product) { build :rfid_product }

    it 'denormalize kiosk_id' do
      expect do
        rfid_product.save
      end.to change {
        rfid_product.kiosk_id
      }.from(nil).to rfid_product.rfid_entity.kiosk_id
    end
  end
end
