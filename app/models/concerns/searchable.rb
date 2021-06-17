# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    after_touch   { sonic_push }
    after_save    { sonic_push }
    after_destroy { sonic_destroy }

    def self.search(query, bucket = 'all')
      sonic = SonicSearch.new
      sonic_results = sonic.search(name, query, bucket).split(' ')
      sql_results = where id: sonic_results
      order_results = []
      sonic_results.each do |sonic_result|
        order_results += sql_results.select { |sql_result| sql_result.id == sonic_result.to_i }
      end
      order_results
    end
  end

  def refresh_sonic_index
    sonic_push
  end

  private

  def sonic_push
    sonic = SonicSearch.new
    sonic.flusho self.class.name, id
    sonic_indexes.each { |index| sonic.push self.class.name, index[:value], id, index[:bucket] }
  end

  def sonic_destroy
    sonic = SonicSearch.new
    sonic.flusho self.class.name, id
  end
end
