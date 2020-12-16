# frozen_string_literal: true

Elasticsearch::Model.client = Elasticsearch::Client.new host: ENV.fetch('ES_HOST', '127.0.0.1'),
                                                        port: ENV.fetch('ES_PORT', '19200'),
                                                        log: ENV.fetch('ES_LOG', false)
