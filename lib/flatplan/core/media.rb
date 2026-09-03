# frozen_string_literal: true

require_relative 'base'

module Flatplan
  module Core
    
    # Shared interface for a single media asset (image or video).
    # It holds the intrinsic properties of the visual content that are independent
    # of any specific output medium.
    class Media < Base
      # @return [String] the file path or URI to the original media file
      attr_reader :filepath

      # @return [Time]
      attr_reader :captured_at
      
      # @return [String, nil] the visible caption or title of the artwork
      attr_reader :caption

      # @return [String, nil] the alternative text describing the image content for accessibility
      attr_reader :alt

      # @return [Integer, nil] the intrinsic width of the media asset
      attr_reader :width

      # @return [Integer, nil] the intrinsic height of the media asset
      attr_reader :height

      # Initializes the core content attributes for a single media asset.
      # @param filepath [String] the file path or URI
      # @param captured_at [Time]
      # @param caption [String, nil] the visible description of the image
      # @param alt [String, nil] the accessibility description
      # @param width [Integer, nil] the intrinsic width
      # @param height [Integer, nil] the intrinsic height
      def initialize(filepath, captured_at: nil, caption: nil, alt: nil, width: nil, height: nil)
        @filepath = filepath
        @captured_at = captured_at
        @caption  = caption || ''
        @alt      = alt || ''
        @width    = width
        @height   = height
        super()
      end
    end
  end
end

