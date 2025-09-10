require 'rails_helper'

describe 'AttributeGroup API' do
  let(:user) { create :user }

  def group_json(group, include_attr_def: false)
    g_json = group.as_json(only: %i[id name group_type order])
    g_json['attribute_defs'] = group.attribute_defs.as_json if include_attr_def
    g_json
  end

  context '#index' do
    let(:groups) { AttributeGroup.all.order(id: :desc) }
    let(:expected_groups) { groups.map { |c| group_json(c, include_attr_def: include_attr_def) } }
    let(:include_attr_def) { false }
    let(:params) { {} }

    before do
      create_list :attribute_group, 3
      get attribute_groups_path, params: params, headers: auth_headers(user)
    end

    it 'respond with groups' do
      expect(json).to have_key('attribute_groups')
      expect(json['attribute_groups'].count).to eq 3
      expect(json['attribute_groups']).to eq expected_groups
    end

    context 'with attributes def' do
      let(:include_attr_def) { true }
      let(:params) { { include_attr_def: include_attr_def } }

      it 'return attributes def ' do
        expect(json).to have_key('attribute_groups')
        expect(json['attribute_groups'].count).to eq 3
        expect(json['attribute_groups']).to eq expected_groups
      end
    end
  end

  context '#index#sort' do
    let(:groups) { AttributeGroup.all.order(name: :asc) }
    let(:expected_groups) { groups.map { |c| group_json(c) } }

    before do
      create :attribute_group, name: 'Group 3'
      create :attribute_group, name: 'Group 1'
      create :attribute_group, name: 'Group 2'
      get attribute_groups_path, params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted groups' do
      expect(json).to have_key('attribute_groups')
      expect(json['attribute_groups'].count).to eq 3
      expect(json['attribute_groups']).to eq expected_groups
    end
  end

  it_behaves_like 'paginated resource', AttributeGroup

  context '#create' do
    let(:group) { AttributeGroup.last }
    let(:params) { { attribute_group: { name: 'Group 1', order: '22' } } }
    let(:missing_name_params) { { attribute_group: { name: '' } } }

    it 'create Brand' do
      expect do
        post attribute_groups_path, params: params, headers: auth_headers(user)
      end.to change {
        AttributeGroup.count
      }.by 1
    end

    it 'created group values' do
      post attribute_groups_path, params: params, headers: auth_headers(user)

      expect(group).to be
      expect(group.name).to eq 'Group 1'
      expect(group.order).to eq 22
    end

    it 'respond with group' do
      post attribute_groups_path, params: params, headers: auth_headers(user)
      expect(json).to have_key('attribute_group')
      expect(json['attribute_group']).to eq group_json(group)
    end

    it 'return errors' do
      post attribute_groups_path, params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end
  end

  context '#update' do
    let(:params) { { id: group.id, attribute_group: { name: 'new name' } } }
    let(:group) { create :attribute_group, name: 'group 1' }
    let(:missing_name_params) { { attribute_group: { name: '' } } }

    it 'update group' do
      put attribute_group_path(group), params: params, headers: auth_headers(user)

      expect(group.reload.name).to eq 'new name'
    end

    it 'return updated group' do
      put attribute_group_path(group), params: params, headers: auth_headers(user)

      expect(json).to have_key('attribute_group')
      expect(json['attribute_group']).to eq group_json(group.reload)
    end

    it 'return errors' do
      put attribute_group_path(group), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end
  end

  context '#show' do
    let(:params) { { id: group.id } }
    let(:group) { create :attribute_group, name: 'Brand' }

    it 'return group' do
      get attribute_group_path(group), params: params, headers: auth_headers(user)

      expect(json).to have_key('attribute_group')
      expect(json['attribute_group']).to eq(group_json(group))
    end
  end

  context 'destroy' do
    let(:params) { { id: group.id } }
    let(:group) { create :attribute_group, name: 'Brand' }

    before { group.touch }

    it 'destroy group' do
      expect do
        delete attribute_group_path(group), params: params, headers: auth_headers(user)
      end.to change {
        AttributeGroup.count
      }.from(1).to 0

      expect(response).to have_http_status(:ok)
    end
  end
end
