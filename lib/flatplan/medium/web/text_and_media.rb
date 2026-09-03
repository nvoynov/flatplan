# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Web
      # Represents a combined text and media layout block for the web.
      # It inherits from {Flatplan::Content::TextAndMedia} and introduces
      # spatial layout configurations like text positioning and flow behavior.
      class TextAndMedia < Flatplan::Core::TextAndMedia
        # @return [Symbol] the horizontal position of the text column (:left, :right)
        attr_reader :text_position

        # @return [Boolean] whether the media grid should flow beneath the text column 
        #   once the text narrative ends
        attr_reader :flow

        # Initializes a web text-and-media composition block.
        # @param web_text [Flatplan::Web::Text] the web text component
        # @param web_media_assets [Flatplan::Web::MediaAssets] the web media collection component
        # @param text_position [Symbol] side of the screen where the text is rendered
        # @param flow [Boolean] toggle for text-wrapping/grid-expanding behavior
        def initialize(text, media_assets, text_position: :left, flow: false)
          super(text, media_assets)
          @text_position = text_position
          @flow = flow
        end
      end
    end
  end
end
