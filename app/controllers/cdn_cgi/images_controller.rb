# frozen_string_literal: true

module CdnCgi
  class ImagesController < ApplicationController
    def variante_path
      attachment = ActiveStorage::Attachment.joins(:blob).includes(:blob).find_by(active_storage_blobs: { key: params[:key] })
      options = { 'quality': '90' }
      params[:options].split(',').each do |option|
        option = option.split('=')
        options[option.first] = option.second
      end

      case options['fit']
      when 'scale-down'
        resize_attachement = attachment.variant(resize_to_limit: [options['width'].to_i, options['height'].to_i], saver: { quality: options['quality'].to_i }).processed
        redirect_to "#{ENV['OBLYK_API_URL']}#{Rails.application.routes.url_helpers.rails_representation_url(resize_attachement, only_path: true)}", allow_other_host: true

      when 'crop'
        resize_attachement = attachment.variant(resize_to_fill: [options['width'].to_i, options['height'].to_i], saver: { quality: options['quality'].to_i }).processed
        redirect_to "#{ENV['OBLYK_API_URL']}#{Rails.application.routes.url_helpers.rails_representation_url(resize_attachement, only_path: true)}", allow_other_host: true

      else
        redirect_to "#{ENV['OBLYK_API_URL']}#{Rails.application.routes.url_helpers.polymorphic_url(attachment, only_path: true)}", allow_other_host: true
      end
    end
  end
end
