module Paged
  extend ActiveSupport::Concern

  def page
    params[:page] || 1
  end

  def page_size
    params[:per_page] || Kaminari.config.default_per_page
  end

  def pagination_dict(collection, enable_automate_promotions = false)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      enable_automate_promotions: enable_automate_promotions
    }
  end
end
