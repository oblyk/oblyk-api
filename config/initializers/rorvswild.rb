# frozen_string_literal: true

RorVsWild.start(api_key: ENV.fetch("ROR_WS_WILD_API_KEY", nil), features: [ "server_metrics" ]) if ENV.fetch("ENABLE_ROR_WS_WILD", false) == "true"
