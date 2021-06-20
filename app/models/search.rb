# frozen_string_literal: true

class Search < ApplicationRecord

  def self.search(query, collection, bucket)
    return [] if query.blank?

    parameterize_query = Search.normalize_index_name query
    results = if bucket
                Search.select(:index_id)
                      .where(collection: collection)
                      .where('bucket = :bucket OR secondary_bucket = :bucket', bucket: bucket)
                      .where('SOUNDEX(index_name) LIKE SOUNDEX(:query)', query: parameterize_query)
                      .where('levenshtein(index_name, :query) <= 2', query: parameterize_query)
                      .order("levenshtein(index_name, '#{parameterize_query}') DESC")
                      .limit(15)
              else
                Search.select(:index_id)
                      .where(collection: collection)
                      .where('SOUNDEX(index_name) LIKE SOUNDEX(:query)', query: parameterize_query)
                      .where('levenshtein(index_name, :query) <= 2', query: parameterize_query)
                      .order("levenshtein(index_name, '#{parameterize_query}') DESC")
                      .limit(15)
              end
    results.pluck(:index_id).uniq
  end

  def self.push(name, id, collection, bucket = nil, secondary_bucket = nil)
    parameterize_name = Search.normalize_index_name name
    new_index = Search.find_or_initialize_by index_name: parameterize_name,
                                             index_id: id,
                                             collection: collection,
                                             bucket: bucket,
                                             secondary_bucket: secondary_bucket
    new_index.save
  end

  def self.delete_collection(collection)
    collections = Search.where(collection: collection)
    collections.delete_all
  end

  def self.delete_object(collection, object_id)
    objects = Search.where(collection: collection)
                    .where(index_id: object_id)
    objects.delete_all
  end

  def self.normalize_index_name(name)
    name = name.split(' - ').first
    name = name.parameterize
    2.times do
      name.gsub!(/^(le|la|les|l)-/, '')
      name.gsub!(/-(de|des|l|la|le|d|du|et|en)-/, '-')
    end
    name
  end
end
