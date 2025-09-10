class Favorite < ApplicationRecord
end

# == Schema Information
#
# Table name: favorites
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint           not null
#  store_id   :bigint           not null
#  user_id    :string           not null
#
# Indexes
#
#  index_favorites_on_product_id  (product_id)
#  index_favorites_on_store_id    (store_id)
#
