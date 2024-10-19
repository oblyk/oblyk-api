# frozen_string_literal: true

class Search < ApplicationRecord
  def self.search(query, collection, bucket, exact_name: false)
    return [] if query.blank?

    parameterize_query = Search.normalize_index_name query

    results = Search
    if exact_name
      results = results.where('index_name LIKE ?', "%#{parameterize_query}%")
    else
      Search.ngram_splitter(parameterize_query, 4).each_with_index do |ngram, index|
        results = results.where('index_name LIKE ?', "%#{ngram}%") if index.zero?
        results = results.or(Search.where('index_name LIKE ?', "%#{ngram}%")) if index.positive?
      end
    end

    results = results.where('CHAR_LENGTH(index_name) <= ?', parameterize_query.size) if parameterize_query.size <= 2
    results = results.where('bucket = :bucket OR secondary_bucket = :bucket', bucket: bucket) if bucket
    results = results.select(:index_id, :index_name).where(collection: collection)

    levenshtein_results = []
    results.each do |result|
      levenshtein_score = Levenshtein.distance(result.index_name, parameterize_query)

      levenshtein_results << { index_id: result.index_id, levenshtein_score: levenshtein_score }
    end
    levenshtein_results.sort_by! { |levenshtein_result| levenshtein_result[:levenshtein_score] }
    limited_results = []
    levenshtein_results.each_with_index do |levenshtein_result, index|
      limited_results << levenshtein_result[:index_id]
      break if index > 14
    end
    limited_results.uniq
  end

  def self.infinite_search(query, collections = nil, page = 1)
    return [] if query.blank?

    parameterize_query = Search.normalize_index_name query

    results = Search
    Search.ngram_splitter(parameterize_query, 4).each_with_index do |ngram, index|
      results = results.where('index_name LIKE ?', "%#{ngram}%") if index.zero?
      results = results.or(Search.where('index_name LIKE ?', "%#{ngram}%")) if index.positive?
    end

    results = results.where('CHAR_LENGTH(index_name) <= ?', parameterize_query.size) if parameterize_query.size <= 2
    results = results.where(collection: collections) if collections
    results = results.distinct.select(:index_id, :index_name, :collection)

    levenshtein_results = []
    results.each do |result|
      levenshtein_score = Levenshtein.distance(result.index_name, parameterize_query)
      levenshtein_results << { index_id: result.index_id, levenshtein_score: levenshtein_score, collection: result.collection.to_sym }
    end
    levenshtein_results.sort_by! { |levenshtein_result| levenshtein_result[:levenshtein_score] }
    limit_start = (page - 1) * 25
    limit_end = (page * 25) - 1
    levenshtein_results[limit_start..limit_end]
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

  def self.ngram_splitter(query, gram = 3)
    return [query] if query.size < gram

    ngram_array = []
    (0..query.size - gram).each do |index|
      ngram_array << query.at(index..index + gram - 1)
    end
    ngram_array
  end
end
