# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Web
      # Represents a single media asset configured for a minimalist web gallery.
      # It focuses strictly on visual scale within the page flow, leaving 
      # interaction like lightboxes to the rendering engine.
      class Media < Flatplan::Core::Media

        # @return [Symbol] the visual scale of the asset on the page (:standard, :large)
        attr_reader :size

        # Initializes a minimalist web media block.
        # @param filepath [String] the file path or URI to the original media file
        # @param captured_at [Time]
        # @param caption [String, nil] the visible description of the image
        # @param alt [String, nil] the accessibility description
        # @param width [Integer, nil] the intrinsic width
        # @param height [Integer, nil] the intrinsic height
        # @param size [Symbol] the layout size relative to the page grid
        def initialize(filepath, captured_at: nil, caption: nil, alt: nil, width: nil, height: nil, size: :standard)
          super(filepath, captured_at:, caption:, alt:, width:, height:)
          @size = size
        end
      end
    end
  end
end

