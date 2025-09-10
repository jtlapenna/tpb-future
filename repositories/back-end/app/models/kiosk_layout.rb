class KioskLayout < ApplicationRecord
  enum template: { shopping: 0, brand: 1, limited: 2, menu_boards_layout: 3 }
  enum home_layout: { swipe: 0, rfidswipe: 1, rfidnav: 2, default: 3, swipenav: 4, on_sale:5 ,brand_selector:6, spotlight:7, spotlightcards: 8, split_screen: 9, menu_boards: 10, quick_checkout: 11, video_image_background: 12 }
  enum nav_ui: { regular: 0, condensed: 1 }
  enum stand_side: { left: 0, right: 1 }, _prefix: true
  enum screen_type: { tablet: 0, big_screen: 1 }, _suffix: true

  belongs_to :kiosk
  belongs_to :store_category, optional: true
  has_one :navigation, class_name: 'LayoutNavigation', dependent: :destroy
  accepts_nested_attributes_for :navigation, allow_destroy: true, reject_if: :all_blank

  belongs_to :welcome_asset, optional: true, dependent: :destroy
  accepts_nested_attributes_for :welcome_asset, allow_destroy: true, reject_if: :all_blank

  belongs_to :video_image_background_asset, optional: true, dependent: :destroy
  accepts_nested_attributes_for :video_image_background_asset, allow_destroy: true, reject_if: :all_blank
  has_many :kiosk_assets, dependent: :destroy
  accepts_nested_attributes_for :kiosk_assets, allow_destroy: true, reject_if: :all_blank

  belongs_to :product_layout, optional: true

  has_many :store_category_kiosk_layouts, dependent: :destroy
  has_many :store_categories, through: :store_category_kiosk_layouts

  validates :template, presence: true

  before_create :template_shopping, unless: :template
  before_create :build_default_navigation, unless: :navigation

  after_update :destroy_previous_product_layout_value, if: :saved_change_to_product_layout_id?

  def template_shopping
    self.template = 'shopping'
  end

  def build_default_navigation
    build_navigation
    true
  end

  private

  def destroy_previous_product_layout_value
    return if product_layout_id_before_last_save.blank?

    ProductLayoutValue.for_kiosk(kiosk_id)
                      .for_layout(product_layout_id_before_last_save)
                      .destroy_all
  end
end

# == Schema Information
#
# Table name: kiosk_layouts
#
#  id                              :bigint           not null, primary key
#  checkout_text                   :string
#  disable_overlay_mask            :boolean          default(FALSE)
#  fast_animation                  :boolean          default(FALSE)
#  home_layout                     :integer
#  home_screen_title               :string
#  nav_ui                          :integer          default("regular")
#  on_sale_badges                  :boolean
#  pagination_time                 :integer
#  rfid_disabled                   :boolean          default(FALSE)
#  screen_type                     :integer          default("big_screen")
#  shopping_disabled               :boolean          default(FALSE)
#  stand_side                      :integer          default("left")
#  template                        :integer          default("shopping")
#  welcome_message                 :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  kiosk_id                        :bigint
#  product_layout_id               :bigint
#  store_category_id               :bigint
#  video_image_background_asset_id :bigint
#  welcome_asset_id                :integer
#
# Indexes
#
#  index_kiosk_layouts_on_kiosk_id                         (kiosk_id)
#  index_kiosk_layouts_on_product_layout_id                (product_layout_id)
#  index_kiosk_layouts_on_store_category_id                (store_category_id)
#  index_kiosk_layouts_on_video_image_background_asset_id  (video_image_background_asset_id)
#  index_kiosk_layouts_on_welcome_asset_id                 (welcome_asset_id)
#
# Foreign Keys
#
#  fk_rails_...  (kiosk_id => kiosks.id)
#  fk_rails_...  (product_layout_id => product_layouts.id)
#  fk_rails_...  (store_category_id => store_categories.id)
#  fk_rails_...  (video_image_background_asset_id => video_image_background_assets.id)
#  fk_rails_...  (welcome_asset_id => welcome_assets.id)
#
