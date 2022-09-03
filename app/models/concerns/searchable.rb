# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    after_touch   { search_push }
    after_save    { search_push }
    after_destroy { search_destroy }

    def self.search(query, bucket = nil, exact_name: false)
      search_results = Search.search query, name, bucket, exact_name: exact_name
      sql_results = where id: search_results
      order_results = []
      search_results.each do |search_result|
        order_results += sql_results.select { |sql_result| sql_result.id == search_result }
      end
      order_results
    end
  end

  def refresh_search_index
    search_push
  end

  private

  def search_push
    return unless search_activated?

    Search.delete_object self.class.name, id
    search_indexes.each do |index|
      next if index[:value].blank?

      Search.push index[:value], id, self.class.name, index[:bucket], index[:secondary_bucket]
    end
  end

  def search_destroy
    return unless search_activated?

    Search.delete_object self.class.name, id
  end

  def search_activated?
    search_ingest = ENV.fetch('SEARCH_INGESTABLE', 'false')
    search_ingest != 'false'
  end
end
