shared_examples 'paginated resource' do |klass|
  let(:resource_name) { klass.name.underscore }
  let(:factory_name) { resource_name.to_sym }
  let(:result_key) { resource_name.pluralize }
  let(:url_params) { {} }
  let(:skip_creation) { false }
  let(:headers) { auth_headers(user) }

  let(:path) { url_for(url_params.merge(controller: resource_name.pluralize, action: :index)) }

  before do
    create_list(factory_name, 15) unless skip_creation
  end

  it 'return pagination info without any pagination params' do
    get path, headers: headers

    expect(json).to have_key('meta')
    expect(json['meta']).to eq({
      current_page: 1, next_page: 2, prev_page: nil,
      total_pages: 2, total_count: 15
    }.stringify_keys)

    expect(json[result_key].count).to eq 10
  end

  it 'return pagination info on page 2' do
    get path, params: { page: 2 }, headers: headers

    expect(json).to have_key('meta')
    expect(json['meta']).to eq({
      current_page: 2, next_page: nil, prev_page: 1,
      total_pages: 2, total_count: 15
    }.stringify_keys)

    expect(json[result_key].count).to eq 5
  end

  it 'when page is out of range, dont return results' do
    get path, params: { page: 3 }, headers: headers

    expect(json).to have_key('meta')
    expect(json['meta']).to eq({
      current_page: 3, next_page: nil, prev_page: nil,
      total_pages: 2, total_count: 15
    }.stringify_keys)

    expect(json[result_key].count).to eq 0
  end

  it 'return resutls changing page size' do
    get path, params: { per_page: 3, page: 2 }, headers: headers

    expect(json).to have_key('meta')
    expect(json['meta']).to eq({
      current_page: 2, next_page: 3, prev_page: 1,
      total_pages: 5, total_count: 15
    }.stringify_keys)

    expect(json[result_key].count).to eq 3
  end
end
