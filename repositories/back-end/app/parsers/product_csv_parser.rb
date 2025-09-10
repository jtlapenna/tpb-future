require 'csv'

class ProductCSVParser
  def initialize(file:, store_id:)
    @file = file
    @store_id = store_id
  end

  def store
    @store ||= Store.find(@store_id)
  end

  def fixed_headers
    %w[sku name category stock]
  end

  def dynaminc_headers
    store.store_prices.map(&:name)
  end

  def required_headers
    fixed_headers + dynaminc_headers
  end

  def parse
    csv_text = @file.read

    store_sync = StoreSync.new(store_id: @store_id)
    csv = CSV.parse(csv_text, headers: true, header_converters: ->(f) { f.strip })
    result = { errors: [], sync: nil }
    errors = []

    unknow_headers = csv.headers - required_headers
    missing_headers = required_headers - csv.headers

    if unknow_headers.present? || missing_headers.present?
      if unknow_headers.present?
        result[:errors] << {
          row: 1, messages: { headers: ["Incorrect headers: #{unknow_headers.join(',')}"] }
        }
      end
      if missing_headers.present?
        result[:errors] << {
          row: 1, messages: { headers: ["Missing headers: #{missing_headers.join(',')}"] }
        }
      end
    else
      csv.each_with_index do |row, index|
        prices = dynaminc_headers.map do |key|
          value = safe_float(row[key])
          { name: key, value: safe_float(row[key]) } if value
        end.compact

        item = StoreSyncItem.new(
          sku: safe_string(row['sku']),
          name: safe_string(row['name']),
          category: safe_string(row['category']),
          stock: safe_integer(row['stock']),
          store_sync: store_sync,
          prices: prices
        )

        if item.valid?
          store_sync.store_sync_items << item
        else
          # Index is 0 based
          result[:errors] << { row: index + 1, messages: item.errors.messages }
        end
      end
    end

    result[:sync] = store_sync if result[:errors].blank? && store_sync.save

    result
  end

  private

  def safe_string(value)
    value.present? ? value.strip : nil
  end

  def safe_integer(value)
    value.present? ? value.to_i : nil
  end

  def safe_float(value)
    value.present? ? value.to_f : nil
  end
end
