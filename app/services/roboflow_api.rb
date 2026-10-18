# frozen_string_literal: true

class RoboflowApi
  ROBOLOW_OUTLINE_END_POINT = ENV.fetch("ROBOLOW_OUTLINE_END_POINT", nil)
  ROBOLOW_API_KEY = ENV.fetch("ROBOLOW_API_KEY", nil)

  # @param [Array] coordinates
  def self.outline_holds(image_url)
    request = RestClient::Request.execute(
      method: :post,
      url: ROBOLOW_OUTLINE_END_POINT,
      payload: { inputs: { image: { type: "url", value: image_url } } }.to_json,
      headers: {
        accept: :json,
        content_type: :json,
        authorization: "Bearer #{ROBOLOW_API_KEY}"
      },
      timeout: 300,
      open_timeout: 30
    )

    return false if request.code != 200

    JSON.parse(request.body)["outputs"].first
  rescue StandardError
    false
  end
end
