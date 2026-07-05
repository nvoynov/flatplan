require_relative 'base'

module Flatplan
  module Model

    # Represents an atomic content asset—a photograph with its presentation
    # metadata within a layout structure.
    class LayoutAsset < Base
      # @return [String] the unique filename or relative path of the asset
      attr_accessor :filename

      # @return [String, nil] the human-readable caption or description
      attr_accessor :caption

      # @return [Integer, nil] the original image width in pixels
      attr_accessor :width

      # @return [Integer, nil] the original image height in pixels
      attr_accessor :height

      # Initializes a new layout photography asset.
      #
      # @param filename [String] the asset identifier or file path
      # @param caption [String, nil] textual accompaniment for the image
      # @param width [Integer, nil] source image width
      # @param height [Integer, nil] source image height
      def initialize(filename:, caption: nil, width: nil, height: nil)
        @filename = filename
        @caption = caption
        @width = width
        @height = height
      end
    end
  end
end
