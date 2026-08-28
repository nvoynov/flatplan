# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Book
      # Represents a print-specific text and media layout block.
      # It encapsulates core items and stores book typesetting directives
      # for the spread calculation engine.
      class TextAndMedia < Flatplan::Core::TextAndMedia
        # @return [Symbol] layout template for book spread (e.g., :text_left_images_right)
        attr_reader :print_layout

        # @param text [Flatplan::Core::Text] core text block
        # @param media_assets [Flatplan::Core::MediaAssets] core media assets collection
        # @param print_layout [Symbol] spread typography layout rules
        def initialize(text, media_assets, print_layout: :text_left_images_right)
          super(text, media_assets, print_layout:)
          @print_layout = print_layout
        end
      end
    end
  end
end

