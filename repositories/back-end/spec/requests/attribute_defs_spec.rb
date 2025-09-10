require 'rails_helper'

describe 'AttributeDef API' do
  let(:user) { create :user }

  def attribute_json(attr)
    includes = { attribute_group: { only: %i[id name group_type order] } }

    attr.as_json(only: %i[id name restricted values], include: includes)
  end

  context '#index' do
    let(:attributes) { AttributeDef.all.order(id: :desc) }
    let(:expected_attributes) { attributes.map { |c| attribute_json(c) } }

    before do
      create_list :attribute_def, 3
      get attribute_defs_path, headers: auth_headers(user)
    end

    it 'respond with attributes' do
      expect(json).to have_key('attribute_defs')
      expect(json['attribute_defs'].count).to eq 3
      expect(json['attribute_defs']).to eq expected_attributes
    end
  end

  context '#index#sort' do
    let(:attributes) { AttributeDef.all.order(name: :asc) }
    let(:expected_attributes) { attributes.map { |c| attribute_json(c) } }

    before do
      create :attribute_def, name: 'Attribute 3'
      create :attribute_def, name: 'Attribute 1'
      create :attribute_def, name: 'Attribute 2'
      get attribute_defs_path, params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted attributes' do
      expect(json).to have_key('attribute_defs')
      expect(json['attribute_defs'].count).to eq 3
      expect(json['attribute_defs']).to eq expected_attributes
    end
  end

  context '#index#filter' do
    let(:group) { create :attribute_group }
    let!(:expected_attributes) do
      [
        create(:attribute_def, name: 'Attribute 1', attribute_group: group),
        create(:attribute_def, name: 'Attribute 2', attribute_group: group)
      ].map { |c| attribute_json(c) }
    end

    before do
      create :attribute_def, name: 'Attribute 3'
      get attribute_defs_path, params: { attribute_group_id: group.id, sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with filtered attributes' do
      expect(json).to have_key('attribute_defs')
      expect(json['attribute_defs'].count).to eq 2
      expect(json['attribute_defs']).to eq expected_attributes
    end
  end

  it_behaves_like 'paginated resource', AttributeDef

  context '#create' do
    let(:group) { create :attribute_group }
    let(:attribute) { AttributeDef.last }
    let(:params) { { attribute_def: { name: 'Attribute 1', attribute_group_id: group.id } } }
    let(:missing_name_params) { { attribute_def: { name: '' } } }

    it 'create Brand' do
      expect do
        post attribute_defs_path, params: params, headers: auth_headers(user)
      end.to change {
        AttributeDef.count
      }.by 1
    end

    it 'created attribute values' do
      post attribute_defs_path, params: params, headers: auth_headers(user)

      expect(attribute).to be
      expect(attribute.name).to eq 'Attribute 1'
    end

    it 'respond with attribute' do
      post attribute_defs_path, params: params, headers: auth_headers(user)
      expect(json).to have_key('attribute_def')
      expect(json['attribute_def']).to eq attribute_json(attribute)
    end

    it 'return errors' do
      post attribute_defs_path, params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end

    context 'restricted values' do
      let(:params) do
        {
          attribute_def: {
            name: 'Attribute 1', attribute_group_id: group.id, restricted: true, values: ['value 1', 'value 2']
          }
        }
      end

      it 'created attribute values' do
        post attribute_defs_path, params: params, headers: auth_headers(user)

        expect(attribute).to be
        expect(attribute).to be_restricted
        expect(attribute.values).to eq ['value 1', 'value 2']
      end
    end
  end

  context '#update' do
    let(:group) { create :attribute_group }
    let(:params) { { id: attribute.id, attribute_def: { name: 'new name', attribute_group_id: group.id } } }
    let(:attribute) { create :attribute_def, name: 'Attribute 1' }
    let(:missing_name_params) { { attribute_def: { name: '' } } }

    it 'update attribute' do
      put attribute_def_path(attribute), params: params, headers: auth_headers(user)

      expect(attribute.reload.name).to eq 'new name'
    end

    it 'return updated attribute' do
      put attribute_def_path(attribute), params: params, headers: auth_headers(user)

      expect(json).to have_key('attribute_def')
      expect(json['attribute_def']).to eq attribute_json(attribute.reload)
    end

    it 'return errors' do
      put attribute_def_path(attribute), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end
  end

  context '#show' do
    let(:params) { { id: attribute.id } }
    let(:attribute) { create :attribute_def, name: 'Attribute' }

    it 'return attribute' do
      get attribute_def_path(attribute), params: params, headers: auth_headers(user)

      expect(json).to have_key('attribute_def')
      expect(json['attribute_def']).to eq(attribute_json(attribute))
    end
  end

  context 'destroy' do
    let(:params) { { id: attribute.id } }
    let(:attribute) { create :attribute_def, name: 'Attribute' }

    before do
      attribute.touch
      prod = create :product
      variant = create :product_variant, product: prod
      create :attribute_value, target: prod, attribute_def: attribute
      create :attribute_value, target: variant, attribute_def: attribute
      create :attribute_value, target: variant, attribute_def: create(:attribute_def)
    end

    it 'destroy attributes' do
      expect do
        delete attribute_def_path(attribute), params: params, headers: auth_headers(user)
      end.to change {
        AttributeDef.count
      }.from(2).to 1

      expect(response).to have_http_status(:ok)
    end
  end
end
