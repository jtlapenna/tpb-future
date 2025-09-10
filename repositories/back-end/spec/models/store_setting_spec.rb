require 'rails_helper'

describe StoreSetting, type: :model do
  let(:settings) { build :store_setting }

  it 'is valid' do
    expect(settings).to be_valid
  end

  it 'is not valid without store' do
    settings.store = nil

    expect(settings).not_to be_valid
  end

  context 'load settings' do
    let(:accessors) do
      %i[admin_email printer_location pos_location main_color secondary_color
         featured_products_on_top_for_brands_page featured_products_on_top_for_effects_and_uses_page featured_products_on_top_for_products_page
         idle_delay restart_delay service_worker_log default_product_description heap_id disable_tax_message rfid_popup_setting]
    end

    before do
      accessors.each_with_index do |accessor, index|
        settings.send("#{accessor}=", index + 1)
      end
    end

    it 'should exists in settings as attributes' do
      accessors.each_with_index do |accessor, index|
        expect(settings.send(accessor)).to eq (index + 1)
      end
    end
  end
end
