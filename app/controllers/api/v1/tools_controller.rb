# frozen_string_literal: true

module Api
  module V1
    class ToolsController < ApiController
      def qr_coder
        qr = RQRCode::QRCode.new params[:message].to_s
        send_data qr.as_svg(viewbox: true),
                  type: 'image/svg+xml',
                  disposition: 'attachment',
                  filename: 'qr-code.svg'
      end
    end
  end
end
