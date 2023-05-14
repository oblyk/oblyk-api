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

      # Iterate through each mirror
      blob.service.mirrors.each do |mirror|

        # If the file doesn't exist on the mirror, upload it
        mirror.upload(blob.key, File.open(local_file), checksum: blob.checksum) unless mirror.exist? blob.key

      end
    end

    out.puts ''
    out.puts 'end'
  end
end
