# frozen_string_literal: true

class Search < ApplicationRecord
  def self.search(query, collection, bucket, exact_name: false)
    return [] if query.blank?

    parameterize_query = Search.normalize_index_name query

    if exact_name
      query = "`index_name` LIKE '%#{parameterize_query}%'"
    else
      words = parameterize_query.split '-'
      query = words.map { |word| "`index_name` LIKE '%#{word}%'" }.join(' OR ')
    end

    limit_length = if parameterize_query.size <= 3
                     "CHAR_LENGTH(index_name) <= #{parameterize_query.size}"
                   else
                     '1 = 1'
                   end

    results = if bucket
                Search.select(:index_id)
                      .where(collection: collection)
                      .where('bucket = :bucket OR secondary_bucket = :bucket', bucket: bucket)
                      .where(query)
                      .where(limit_length)
                      .order("levenshtein(index_name, '#{parameterize_query}') ASC")
                      .limit(15)
              else
                Search.select(:index_id)
                      .where(collection: collection)
                      .where(query)
                      .where(limit_length)
                      .order("levenshtein(index_name, '#{parameterize_query}') ASC")
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
