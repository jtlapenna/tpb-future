class Article < ApplicationRecord
  belongs_to :category, optional: true

  validates :title, :text, presence: true

  validates :tag, presence: true, unless: ->(article) { article.category.present? }
  validates :category, presence: true, unless: ->(article) { article.tag.present? }
end

# == Schema Information
#
# Table name: articles
#
#  id          :bigint           not null, primary key
#  excerpt     :string
#  icon        :string
#  tag         :string
#  text        :text
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :bigint
#
# Indexes
#
#  index_articles_on_category_id  (category_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#
