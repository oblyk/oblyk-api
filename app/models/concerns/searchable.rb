# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    index_name { "#{ENV['ES_PREFIX'] || Rails.env}-#{name.downcase}" }

    after_touch   { __elasticsearch__.index_document }
    after_save    { __elasticsearch__.index_document }
    after_destroy { __elasticsearch__.delete_document }
  end
end
