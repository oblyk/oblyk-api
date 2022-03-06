# frozen_string_literal: true

namespace :delete_cache do
  desc 'Delete summary cache for specific model'
  task :for_summary, %i[model out] => :environment do |_t, args|
    out = args[:out] || $stdout
    model = args[:model]

    klass = Object.const_get model
    item_count = klass.all.count
    loop = 0

    klass.all.find_each do |item|
      loop += 1
      cache_key = "#{item.cache_key_with_version}/summary_#{model.downcase}"
      out.puts "#{loop}/#{item_count} : delete #{cache_key}"
      Rails.cache.delete(cache_key)
    end
  end
end
