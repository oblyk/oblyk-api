# frozen_string_literal: true

RspecApiDocumentation.configure do |config|
  # Output folder
  # config.docs_dir = Rails.root.join("doc", "api")

  # An array of output format(s).
  # Possible values are :json, :html, :combined_text, :combined_json,
  #   :json_iodocs, :textile, :markdown, :append_json
  config.format = [:json]

  config.request_headers_to_include = ['HttpApiAccessToken']
  config.response_headers_to_include = []
end

module RspecApiDocumentation
  class RackTestClient < ClientBase
    def response_body
      last_response.body.encode('utf-8')
    end
  end
end
