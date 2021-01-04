# frozen_string_literal: true

module Search
  class OblykSearch
    MODELS_TO_SEARCH = [Crag, CragRoute, CragSector, GuideBookPaper, Gym].freeze
    attr_accessor :query

    def initialize(query)
      @query = query
    end

    def self.call(query)
      new(query).call
    end

    def call
      results.map do |result|
        {
          record: build_record(result),
          record_type: result.class.name,
          record_id: result.id
        }
      end
    end

    private

    def results
      Elasticsearch::Model.search(search_query, MODELS_TO_SEARCH).records
    end

    def build_record(record)
      RecordBuilder.call(record)
    end

    def search_query
      {
        "size": 50,
        "query": {
          "function_score": {
            "query": {
              "bool": {
                "must": [multi_match]
              }
            }
          }
        }
      }
    end

    def multi_match
      {
        "multi_match": {
          "query": @query,
          "fields": %w[name],
          "fuzziness": 'auto'
        }
      }
    end

    def priorities
      [
        {
          "filter": {
            "term": { "_type": 'crag' }
          },
          "weight": 1
        }
      ]
    end
  end
end
