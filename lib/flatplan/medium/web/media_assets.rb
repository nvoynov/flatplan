# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Web
      # Represents a collection of media assets arranged in a layout grid for the web.
      # It mixes in the core {Flatplan::Content::MediaAssets} structure and defines
      # grid properties like columns count and aspect ratio constraints.
      class MediaAssets < Flatplan::Core::MediaAssets

        # @return [Integer] the number of layout columns in the grid row
        attr_reader :columns

        # @return [Symbol] the crop or aspect ratio mode for the grid items (:natural, :square)
        attr_reader :aspect_mode

        # Initializes a web media grid collection.
        # @param assets [Array<Object>] collection of elements implementing {Flatplan::Content::Media}
        # @param columns [Integer] how many columns to display in a single row
        # @param aspect_mode [Symbol] the visual framing mode for images in the grid
        def initialize(assets, columns: 2, aspect_mode: :natural)
          super(assets, columns:, aspect_mode:)
          @columns     = columns
          @aspect_mode = aspect_mode
        end
      end
    end
  end
end

