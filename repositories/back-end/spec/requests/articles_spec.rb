require 'rails_helper'

describe 'Articles API' do
  let(:user) { create :user }

  def article_json(article)
    includes = { category: { only: %i[id name] } }
    a_json = article.as_json(only: %i[id title text tag icon excerpt], include: includes)
    a_json['category'] = nil unless a_json['category']

    a_json
  end

  context '#index' do
    let(:articles) { Article.all.order(id: :desc) }
    let(:expected_articles) { articles.map { |a| article_json(a) } }

    before do
      create_list :article, 3
      get articles_path, headers: auth_headers(user)
    end

    it 'respond with articles' do
      expect(json).to have_key('articles')
      expect(json['articles'].count).to eq 3
      expect(json['articles']).to eq expected_articles
    end
  end

  context '#index#sort' do
    let(:articles) { Article.all.order(title: :asc) }
    let(:expected_articles) { articles.map { |a| article_json(a) } }

    before do
      3.times { |i| create :article, title: "Article #{i}" }

      get articles_path, params: { sort_by: 'title', sort_direction: 'asc' }, headers: auth_headers(user)
    end

    it 'respond with sorted articles' do
      expect(json).to have_key('articles')
      expect(json['articles'].count).to eq 3
      expect(json['articles']).to eq expected_articles
    end
  end

  it_behaves_like 'paginated resource', Article

  context '#create' do
    let(:article) { Article.last }
    let(:params) { { article: { title: 'Article 1', text: 'Article text', tag: 'tag 1', icon: 'icon 1', excerpt: 'excerpt 1' } } }
    let(:missing_title_params) { { article: { title: '', text: 'Article text', tag: 'tag 1' } } }

    it 'create article' do
      expect do
        post articles_path, params: params, headers: auth_headers(user)
      end.to change {
        Article.count
      }.by 1
    end

    it 'created article values' do
      post articles_path, params: params, headers: auth_headers(user)

      expect(article).to be
      expect(article.title).to eq 'Article 1'
    end

    it 'respond with article' do
      post articles_path, params: params, headers: auth_headers(user)
      expect(json).to have_key('article')
      expect(json['article']).to eq article_json(article)
    end

    it 'return errors' do
      post articles_path, params: missing_title_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('title')
      expect(json['errors']).to eq('title' => ["can't be blank"])
    end
  end

  context '#update' do
    let(:params) { { id: article.id, article: { title: 'new name' } } }
    let(:article) { create :article, title: 'article' }
    let(:missing_title_params) { { article: { title: '' } } }

    it 'update article' do
      put article_path(article), params: params, headers: auth_headers(user)

      expect(article.reload.title).to eq 'new name'
    end

    it 'return updated article' do
      put article_path(article), params: params, headers: auth_headers(user)

      expect(json).to have_key('article')
      expect(json['article']).to eq article_json(article.reload)
    end

    it 'return errors' do
      put article_path(article), params: missing_title_params, headers: auth_headers(user)

      expect(json).to have_key('errors')
      expect(json['errors']).to have_key('title')
      expect(json['errors']).to eq('title' => ["can't be blank"])
    end
  end

  context '#show' do
    let(:params) { { id: article.id } }
    let(:article) { create :article }

    it 'return article' do
      get article_path(article), params: params, headers: auth_headers(user)

      expect(json).to have_key('article')
      expect(json['article']).to eq(article_json(article))
    end
  end
end
