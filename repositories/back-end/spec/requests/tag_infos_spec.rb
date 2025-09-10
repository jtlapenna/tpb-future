require 'rails_helper'

describe 'TagInfo API' do
  let(:user) { create :user }

  def tag_info_json(tag_info)
    tag_info.as_json(only: %i[id tag description])
  end

  context '#index' do
    let(:tag_infos) { TagInfo.all.order(tag: :asc) }
    let(:expected_tags) { tag_infos.map { |c| tag_info_json(c) } }

    before do
      create_list :tag_info, 3
      get tag_infos_path, headers: auth_headers(user)
    end

    it 'respond with attributes' do
      expect(json).to have_key('tag_infos')
      expect(json['tag_infos'].count).to eq 3
      expect(json['tag_infos']).to eq expected_tags
    end
  end

  context '#index#sort' do
    let(:tag_infos) { TagInfo.all.order(tag: :desc) }
    let(:expected_tags) { tag_infos.map { |c| tag_info_json(c) } }

    before do
      create :tag_info, tag: 'Tag 3'
      create :tag_info, tag: 'Tag 1'
      create :tag_info, tag: 'Tag 2'
      get tag_infos_path, params: { sort_by: 'tag', sort_direction: 'desc' }, headers: auth_headers(user)
    end

    it 'respond with sorted attributes' do
      expect(json).to have_key('tag_infos')
      expect(json['tag_infos'].count).to eq 3
      expect(json['tag_infos']).to eq expected_tags
    end
  end

  it_behaves_like 'paginated resource', TagInfo

  context '#create' do
    let(:tag_info) { TagInfo.last }
    let(:params) { { tag_info: { tag: 'Tag 1', description: 'YYY' } } }
    let(:missing_name_params) { { tag_info: { tag: '', description: 'XYZ' } } }

    it 'create Brand' do
      expect do
        post tag_infos_path, params: params, headers: auth_headers(user)
      end.to change {
        TagInfo.count
      }.by 1
    end

    it 'created tag_info values' do
      post tag_infos_path, params: params, headers: auth_headers(user)

      expect(tag_info).to be
      expect(tag_info.tag).to eq 'Tag 1'
    end

    it 'respond with tag info' do
      post tag_infos_path, params: params, headers: auth_headers(user)
      expect(json).to have_key('tag_info')
      expect(json['tag_info']).to eq tag_info_json(tag_info)
    end

    it 'return errors' do
      post tag_infos_path, params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('tag')
      expect(json['errors']).to eq('tag' => ["can't be blank"])
    end
  end

  context '#update' do
    let(:params) { { id: tag_info.id, tag_info: { tag: 'new tag', description: 'XYZ' } } }
    let(:tag_info) { create :tag_info, tag: 'Tag 1' }
    let(:missing_name_params) { { tag_info: { tag: '', description: 'XYZ' } } }

    it 'update tag info' do
      put tag_info_path(tag_info), params: params, headers: auth_headers(user)

      expect(tag_info.reload.tag).to eq 'new tag'
    end

    it 'return updated tag_info' do
      put tag_info_path(tag_info), params: params, headers: auth_headers(user)

      expect(json).to have_key('tag_info')
      expect(json['tag_info']).to eq tag_info_json(tag_info.reload)
    end

    it 'return errors' do
      put tag_info_path(tag_info), params: missing_name_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('tag')
      expect(json['errors']).to eq('tag' => ["can't be blank"])
    end
  end

  context '#show' do
    let(:params) { { id: tag_info.id } }
    let(:tag_info) { create :tag_info, tag: 'Tag 1' }

    it 'return tag_info' do
      get tag_info_path(tag_info), params: params, headers: auth_headers(user)

      expect(json).to have_key('tag_info')
      expect(json['tag_info']).to eq(tag_info_json(tag_info))
    end
  end

  context 'destroy' do
    let(:params) { { id: tag_info.id } }
    let!(:tag_info) { create :tag_info, tag: 'Tag 1' }

    it 'destroy tag_info' do
      expect do
        delete tag_info_path(tag_info), params: params, headers: auth_headers(user)
      end.to change {
        TagInfo.count
      }.from(1).to 0

      expect(response).to have_http_status(:ok)
    end
  end
end
