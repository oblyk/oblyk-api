# frozen_string_literal: true

RorVsWild.start(api_key: ENV['ROR_WS_WILD_API_KEY'], features: ['server_metrics']) if ENV.fetch('ENABLE_ROR_WS_WILD', false) == 'true'
