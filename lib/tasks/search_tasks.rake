# frozen_string_literal: true

namespace :search_tasks do
  desc 'Import model into search'
  task :import, %i[model out] => :environment do |_t, args|
    out = args[:out] || $stdout
    model = args[:model]

    klass = Object.const_get model

    out.puts "Flush #{model}"
    Search.delete_collection model

    out.puts ''
    out.puts "Import #{model} in search"

    total_count = klass.count
    loop_count = 0
    klass.all.each do |object|
      loop_count += 1
      name = object.has_attribute?(:first_name) ? object.full_name : object.name
      out.puts "-> #{loop_count} / #{total_count} : #{name}"
      object.refresh_search_index
    end

    out.puts 'End'
  end
end
