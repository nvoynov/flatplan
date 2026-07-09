require_relative 'base'

module Flatplan
  module Model
    # Represents an atomic content asset—a photograph with its presentation,
    # curatorial metadata, and unique attributes.
    class LayoutAsset < Base
      # @return [String] the unique filename or relative path of the asset
      attr_accessor :filename

      # @return [String, nil] the Markdown fallback alternate caption
      attr_accessor :caption

      # @return [String, nil] individual artistic title curated for this series
      attr_accessor :title

      # @return [Time, nil] specific timestamp metadata of the shutter click
      attr_accessor :captured_at

      # @return [Integer, nil] original image width in pixels
      attr_accessor :width

      # @return [Integer, nil] original image height in pixels
      attr_accessor :height

      # Initializes a new layout photography asset structure.
      #
      # @param filename [String] the asset identifier or file path
      # @param caption [String, nil] fallback template caption
      # @param title [String, nil] fine-art custom title string
      # @param captured_at [Time, nil] timestamp metadata string
      # @param width [Integer, nil] source image width
      # @param height [Integer, nil] source image height
      def initialize(
        filename:, 
        caption: nil, 
        title: nil, 
        captured_at: nil, 
        width: nil, 
        height: nil
      )
        super()
        @filename = filename
        @caption = caption || ''
        @title = title || ''
        @captured_at = captured_at
        @width = width
        @height = height
      end
    end
  end
end
