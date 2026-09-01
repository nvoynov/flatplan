# frozen_string_literal: true

require_relative '../../core'
require_relative '../../../kairos'

module Flatplan
  module Medium
    module Web

      # Web-specific manifest serializer.
      # It injects web layout vocabulary mappings into the core serialization engine.
      class Serializer < Flatplan::Core::Serializer
        # Translation map specific only to Web platform display keys
        WEB_PROPERTY_MAP = {
          text_position: 'adjust',
          alignment:     'adjust',
          columns:       'columns',
          flow:          'flow',
          size:          'size',
          aspect_mode:   'aspect'
        }.freeze

        def initialize
          super(WEB_PROPERTY_MAP)
        end

        def serialize(page)
          @current_page = page
          super(page)
        ensure
          @current_page = nil
        end

        private

        def serialize_media_asset(media)
          buffer = []
          
          buffer << "title: #{media.title}" if media.respond_to?(:title) && media.title && !media.title.empty?
          buffer << "alt: #{media.alt}" unless media.alt.empty?
          
          if media.respond_to?(:captured_at) && media.captured_at
            buffer << "captured_at: #{media.captured_at}"
            
            if !media.respond_to?(:title) || media.title.nil? || media.title.empty?
              keywords = @current_page.respond_to?(:keywords) ? @current_page.keywords : []
              
              Kairos.call(media.captured_at, keywords).each do |key, value|
                buffer << "kairos_#{key}_hint: #{value}"
              end
            end
          end
          
          buffer << ''
        end
      end
    end
  end
end

