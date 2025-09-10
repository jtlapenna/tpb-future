require 'rails_helper'

describe StoreArticle do
  let(:main_article) { build_stubbed :article, tag: 'Article tag', title: 'An article', text: 'text' }
  let(:article) { build_stubbed :store_article, article: main_article }

  it 'is valid' do
    expect(article).to be_valid
  end

  it 'is not valid without a main article' do
    article.article = nil

    expect(article).not_to be_valid
    expect(article.errors[:article]).to eq ['must exist']
  end

  it 'is not valid without store' do
    article.store = nil

    expect(article).not_to be_valid
    expect(article.errors[:store]).to eq ['must exist']
  end

  it 'return title from main article' do
    expect(article.title).to eq 'An article'
  end

  it 'return tag from main article' do
    expect(article.tag).to eq 'Article tag'
  end

  it 'return tag from main article' do
    expect(article.text).to eq 'text'
  end

  context 'article is unique for a catalog' do
    let(:store) { article.store }
    let!(:main_article) { create :article }
    let!(:article) { create :store_article, article: main_article }

    it 'store article is invalid with the same main article' do
      ca = build :store_article, store: store, article: main_article

      expect(ca).not_to be_valid
      expect(ca.errors[:article_id]).to eq ['article is already used in store']
    end

    it 'store article is valid with the same main article on another store' do
      ca = build :store_article, article: main_article

      expect(ca).to be_valid
    end
  end

  context 'products_for_catalog' do
    let(:store) { article.store }
    let(:category) { store.store_categories.first }
    let!(:main_article) { create :article, tag: 'tag 1', category: nil }
    let!(:article) { create :store_article, article: main_article }
    let(:variant) { create :product_variant }

    before do
      create :store_product, tag_list: ['tag 1']
      create :store_product, store_category: category, tag_list: ['tag 3']
    end

    it 'return product in catalog with the tag by default' do
      create :store_product, store_category: category, product_variant: create(:product_variant, product: create(:product, tag_list: ['tag 1']))
      create :store_product, store_category: category, product_variant: create(:product_variant, tag_list: ['tag 1'])
      create_list :store_product, 9, store_category: category, tag_list: ['tag 1', 'tag 2'], product_variant: variant

      expected_products = StoreProduct.offset(2).order(id: :asc).limit(10)

      expect(article.products_for_catalog).to match_products expected_products
    end

    context 'return default product in catalog when exist category' do
      let!(:main_article) { create :article, tag: nil, category: build(:category) }

      before do
        create :store_product, store_category: category, product_variant: create(:product_variant, product: create(:product, tag_list: ['tag 1']))
        create :store_product, store_category: category, product_variant: create(:product_variant, tag_list: ['tag 1'])
        create_list :store_product, 9, store_category: category, tag_list: ['tag 1', 'tag 2'], product_variant: variant
        main_article.update(tag: nil)
      end

      it 'and category name do not match store caterory name' do
        category.update(name: "#{main_article.category.name}1")

        expect(article.products_for_catalog.size).to eq 0
      end

      it 'and category name match store caterory name' do
        category.update(name: main_article.category.name)

        expected_products = StoreProduct.offset(1).order(id: :asc).limit(10)

        expect(article.products_for_catalog).to match_products expected_products
      end

      it 'and category name match store caterory name and have tag' do
        main_article.update(tag: 'tag 1')
        category.update(name: main_article.category.name)

        expected_products = StoreProduct.offset(1).order(id: :asc).limit(10)

        expect(article.products_for_catalog).to match_products expected_products
      end
    end

    it 'return catalog product relation when it has records' do
      create_list :store_product, 2, store_category: category, tag_list: ['tag 1', 'tag 2'], product_variant: variant

      article.store_products << category.store_products.first

      expect(article.products_for_catalog).to match_products article.store_products
    end
  end
end
