require 'rails_helper'

describe 'Product Layout API' do
  let(:user) { create :user }

  def product_layout_json(layout, minimal: false)
    json = layout.as_json(only: %i[id name stylesheet])

    json['elements'] = layout.elements.map { |e| element_json(e) } unless minimal
    json['tabs'] = layout.tabs.map { |t| tab_json(t) } unless minimal

    json
  end

  def tab_json(tab)
    json = tab.as_json(only: %i[id name order])
    json['elements'] = tab.elements.map { |e| element_json(e) }
    json
  end

  def element_json(element)
    element.as_json(only: %i[id element_type coord_x coord_y hint width])
  end

  context '#index' do
    let(:layouts) { ProductLayout.all.order(id: :desc) }
    let(:expected_layouts) { layouts.map { |c| product_layout_json(c, minimal: true) } }

    before do
      create_list :product_layout, 3
      get product_layouts_path, headers: auth_headers(user)
    end

    it 'respond with layouts' do
      expect(json).to have_key('product_layouts')
      expect(json['product_layouts'].count).to eq 3
      expect(json['product_layouts']).to eq expected_layouts
    end
  end

  context '#index#sort' do
    let(:layouts) { ProductLayout.all.order(name: :asc) }
    let(:expected_layouts) { layouts.map { |c| product_layout_json(c, minimal: true) } }

    before do
      create :product_layout, name: 'Layout 3'
      create :product_layout, name: 'Layout 1'
      create :product_layout, name: 'Layout 2'
      get product_layouts_path, params: { sort_by: 'name', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted layouts' do
      expect(json).to have_key('product_layouts')
      expect(json['product_layouts'].count).to eq 3
      expect(json['product_layouts']).to eq expected_layouts
    end
  end

  it_behaves_like 'paginated resource', ProductLayout

  context '#create' do
    let(:layout) { ProductLayout.last }
    let(:params) { { product_layout: { name: 'Layout 1' } } }
    let(:missing_name_params) { { product_layout: { active: false } } }

    it 'create ProductLayout' do
      expect do
        post product_layouts_path, params: params, headers: auth_headers(user)
      end.to change {
        ProductLayout.count
      }.by 1
    end

    it 'respond with ProductLayout' do
      post product_layouts_path, params: params, headers: auth_headers(user)

      expect(json).to have_key('product_layout')
      expect(json['product_layout']).to eq product_layout_json(layout)
    end

    it 'return errors' do
      post product_layouts_path, params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end

    context 'with nested attributes' do
      let(:params) do
        {
          product_layout: {
            name: 'Layout 1',
            stylesheet: 'css',
            elements_attributes: [{
              element_type: 'medium',
              coord_x: '0',
              coord_y: '0',
              hint: 'background'
            }],
            tabs_attributes: [{
              name: 'Tab 1', order: 2,
              elements_attributes: [{
                element_type: 'medium',
                coord_x: '1%',
                coord_y: '2%',
                hint: 'some hint'
              }, {
                element_type: 'dot',
                coord_x: '3%',
                coord_y: '4%',
                hint: 'some hint 2'
              }]
            }, {
              name: 'Tab 2', order: -1,
              elements_attributes: [{
                element_type: 'text',
                coord_x: '3%',
                coord_y: '4%',
                width: '10px'
              }]
            }]
          }
        }
      end

      it 'create nested entities' do
        post product_layouts_path, params: params, headers: auth_headers(user)

        expect(json['product_layout']).to eq product_layout_json(layout)

        layout = ProductLayout.last
        expect(layout.elements.count).to eq 1
        expect(layout.tabs.count).to eq 2
        expect(layout.tabs.first.elements.count).to eq 2
        expect(layout.tabs.second.elements.count).to eq 1
      end
    end
  end

  context '#update' do
    let(:params) { { id: layout.id, product_layout: { name: 'new name' } } }
    let(:layout) { create :product_layout, name: 'layout', stylesheet: 'layout css' }
    let(:missing_name_params) { { product_layout: { name: '' } } }

    it 'update client' do
      put product_layout_path(layout), params: params, headers: auth_headers(user)

      expect(layout.reload.name).to eq 'new name'
    end

    it 'return updated ProductLayout' do
      put product_layout_path(layout), params: params, headers: auth_headers(user)

      expect(json).to have_key('product_layout')
      expect(json['product_layout']).to eq product_layout_json(layout.reload)
    end

    it 'return errors' do
      put product_layout_path(layout), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('name')
      expect(json['errors']).to eq('name' => ["can't be blank"])
    end

    context 'with nested attributes' do
      let(:tabs) { create_list :product_layout_tab, 2, product_layout: layout }
      let(:element) { create :product_layout_text, coord_x: '1', coord_y: '2', source: tabs.second }
      let(:common_element) { create :product_layout_text, coord_x: '1', coord_y: '2', source: layout }
      let(:params) do
        {
          product_layout: {
            id: layout.id,
            name: 'new name',
            stylesheet: 'new layout css',
            elements_attributes: [{
              id: common_element.id,
              hint: 'BAC'
            }],
            tabs_attributes: [{
              id: tabs.first.id, name: 'Tab 1', order: 2, _destroy: true
            }, {
              id: tabs.second.id, name: 'Tab 2 new name', order: 19,
              elements_attributes: [{
                id: element.id,
                element_type: 'medium',
                coord_x: '1%',
                coord_y: '2%',
                hint: 'some hint',
                width: '50px'
              }]
            }, {
              name: 'New Tab 3', order: 3
            }]
          }
        }
      end

      it 'update nested entities' do
        put product_layout_path(layout), params: params, headers: auth_headers(user)

        expect(json['product_layout']).to eq product_layout_json(layout.reload)
        expect(layout.elements.count).to eq 1
        expect(layout.elements.pluck(:hint)).to eq ['BAC']
        expect(layout.tabs.count).to eq 2
        expect(layout.tabs.sorted.pluck(:name)).to eq ['New Tab 3', 'Tab 2 new name']
        expect(element_json(layout.tabs.reload.first.elements.first)).to eq({
          id: element.id, element_type: 'medium', coord_x: '1%', coord_y: '2%', hint: 'some hint', width: '50px'
        }.as_json)
      end
    end
  end

  context '#show' do
    let(:params) { { id: layout.id } }
    let(:layout) { create :product_layout, name: 'Layout' }

    it 'return layout' do
      get product_layout_path(layout), params: params, headers: auth_headers(user)

      expect(json).to have_key('product_layout')
      expect(json['product_layout']).to eq(product_layout_json(layout))
    end
  end
end
