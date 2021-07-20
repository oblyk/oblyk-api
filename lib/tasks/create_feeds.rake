# frozen_string_literal: true

namespace :create_feeds do
  desc 'Create feed for model'
  task :for_model, %i[model out] => :environment do |_t, args|
    out = args[:out] || $stdout
    model = args[:model]

    unless Feed::FEEDABLE_LIST.include? model
      out.puts "#{model} not in feedable list"
      raise
    end

    klass = Object.const_get model

    out.puts ''
    out.puts "create feed for #{model}"

    klass.all.find_each(&:save_feed!)

    out.puts 'End'
  end
end
