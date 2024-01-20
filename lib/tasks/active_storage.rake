# frozen_string_literal: true

namespace :active_storage do

  desc 'Sync local file with mirrors'
  task :sync_mirror, %i[out] => :environment do |_t, args|
    out = args[:out] || $stdout

    # Iterate through each blob
    blobs = ActiveStorage::Blob.all
    count = blobs.count
    loop_index = 0
    out.puts "sync #{count} files"
    out.puts ''

    blobs.find_each do |blob|
      loop_index += 1
      out.puts "File #{loop_index} / #{count}"

      local_file = ActiveStorage::Blob.service.primary.path_for blob.key

      next unless File.exist? local_file

      # Iterate through each mirror
      blob.service.mirrors.each do |mirror|

        # If the file doesn't exist on the mirror, upload it
        mirror.upload(blob.key, File.open(local_file), checksum: blob.checksum) unless mirror.exist? blob.key

      end
    end

    out.puts ''
    out.puts 'end'
  end

  task :check_local_file_exist, %i[out] => :environment do |_t, args|
    out = args[:out] || $stdout

    # Iterate through each blob
    blobs = ActiveStorage::Blob.all
    count = blobs.count
    loop_index = 0
    out.puts "Database storage #{count} files"
    out.puts ''
    exists_count = 0
    un_exists_count = 0
    un_exist_ids = []

    blobs.find_each do |blob|
      loop_index += 1
      out.puts "File #{loop_index} / #{count}"

      local_file = ActiveStorage::Blob.service.primary.path_for blob.key
      if File.exist? local_file
        exists_count += 1
        out.puts 'Exist !'
      else
        un_exist_ids << blob.id
        un_exists_count += 1
        out.puts 'Not exist ...'
      end
    end
    out.puts ''
    out.puts "All files : #{count}"
    out.puts "Exists count : #{exists_count}"
    out.puts "Un exists count : #{un_exists_count}"
    out.puts ''
    out.puts 'Un exist ids'
    un_exist_ids.each do |id|
      out.puts "- blob id : #{id}"
    end
    out.puts 'End'
  end
end
