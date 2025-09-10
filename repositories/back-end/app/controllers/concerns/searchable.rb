module Searchable
  extend ActiveSupport::Concern

  def do_search(scope, q, options_override = {})
    if algoliasearch_disabled?
      return scope.name_like(q)
                  .page(page)
                  .per(page_size)
                  .order(order_fields)
    end

    options = {
      page: page.to_i - 1,
      hitsPerPage: page_size.to_i,
      attributesToRetrieve: 'objectID',
      typoTolerance: :min
    }.merge(options_override)
    scope = scope.search(q, options)
    raw_answer = scope.raw_answer
    Kaminari.paginate_array(scope, total_count: raw_answer['nbHits']).page(page).per(page_size)
  end

  private

  def algoliasearch_disabled?
    ENV['ALGOLIASEARCH_DISABLED'] == 'true'
  end
end
