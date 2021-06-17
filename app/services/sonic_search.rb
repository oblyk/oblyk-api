# frozen_string_literal: true

class SonicSearch
  attr_accessor :client

  def initialize
    self.client = Sonic::Client.new ENV.fetch('SONIC_HOST', '127.0.0.1'),
                                    ENV.fetch('SONIC_PORT', '1491'),
                                    ENV.fetch('SONIC_PASSWORD', 'SecretPassword')
  end

  def search(collection, query, bucket = 'all')
    return '' if query.blank?

    search = client.channel(:search)
    search.query(collection, bucket, query)
  end

  def suggest(collection, query, bucket = 'all')
    search = client.channel(:search)
    search.suggest(collection, bucket, query)
  end

  def push(collection, value, object_id, bucket = 'all')
    ingest = client.channel(:ingest)
    ingest.push(collection, bucket, object_id, value)
  end

  def pop(collection, value, object_id, bucket = 'all')
    ingest = client.channel(:ingest)
    ingest.pop(collection, bucket, object_id, value)
  end

  def count(collection, object_id, bucket = 'all')
    ingest = client.channel(:ingest)
    ingest.count(collection, bucket, object_id)
  end

  def flushc(collection)
    ingest = client.channel(:ingest)
    ingest.flushc(collection)
  end

  def flushb(collection, bucket = 'all')
    ingest = client.channel(:ingest)
    ingest.flushb(collection, bucket)
  end

  def flusho(collection, object_id, bucket = 'all')
    ingest = client.channel(:ingest)
    ingest.flusho(collection, bucket, object_id)
  end
end
