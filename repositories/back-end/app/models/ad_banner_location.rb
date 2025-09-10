class AdBannerLocation < ApplicationRecord
    has_many :ad_banners    
    validates :text, presence: true, uniqueness: true   
    validates :codename, presence: true, uniqueness: true
    validates :special_type, uniqueness: true, allow_nil: true
end

# == Schema Information
#
# Table name: ad_banner_locations
#
#  id           :bigint           not null, primary key
#  codename     :string
#  special_type :string
#  text         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_ad_banner_locations_on_text  (text) UNIQUE
#
