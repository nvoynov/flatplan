# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Web
      # Concrete factory responsible for constructing Web presentation components.
      # It implements the core factory contract, embedding default design decisions
      # suited for a minimalist, "quiet" art gallery layout.
      class Factory
        # Constructs a Web-specific text presentation block.
        #
        # @param body [String] the raw text content in Pandoc Markdown format
        # @param alignment [Symbol] horizontal text alignment (:left, :center, :right)
        # @param width_category [Symbol] structural width constraint (:narrow, :normal, :wide)
        # @return [Flatplan::Medium::Web::Text]
        def text(body, alignment: :left, width_category: :narrow)
          Flatplan::Medium::Web::Text.new(body, alignment:, width_category:)
        end

        # Constructs a single minimalist Web media asset.
        #
        # @param filepath [String] the file path or URI to the original media file
        # @param caption [String, nil] the visible description of the image
        # @param alt [String, nil] the accessibility description
        # @param width [Integer, nil] the intrinsic width in pixels
        # @param height [Integer, nil] the intrinsic height in pixels
        # @param size [Symbol] the layout size relative to the page grid (:standard, :large)
        # @return [Flatplan::Medium::Web::Media]
        def media(filepath, caption: nil, alt: nil, width: nil, height: nil, size: :standard)
          Flatplan::Medium::Web::Media
            .new(filepath, caption:, alt:, width:, height:, size:)
        end

        # Constructs a Web grid collection of media assets.
        #
        # @param assets [Array<Flatplan::Medium::Web::Media>] collection of web media objects
        # @param columns [Integer] how many columns to display in a single row
        # @param aspect_mode [Symbol] visual framing mode for images in the grid (:natural, :square)
        # @return [Flatplan::Medium::Web::MediaAssets]
        def media_assets(assets, columns: 2, aspect_mode: :natural)
          Flatplan::Medium::Web::MediaAssets.new(assets, columns:, aspect_mode:)
        end

        # Constructs a combined Web text-and-media composition block.
        #
        # @param web_text [Flatplan::Medium::Web::Text] the configured web text component
        # @param web_media_assets [Flatplan::Medium::Web::MediaAssets] the web media grid component
        # @param text_position [Symbol] side of the screen for the text column (:left, :right)
        # @param flow [Boolean] toggle for text-wrapping/grid-expanding behavior
        # @return [Flatplan::Medium::Web::TextAndMedia]
        def text_and_media(web_text, web_media_assets, text_position: :left, flow: false)
          Flatplan::Medium::Web::TextAndMedia
            .new(web_text, web_media_assets, text_position:, flow:)
        end

        # Constructs a final root Web::Page publication container.
        #
        # @param title [String] the title of the story
        # @param author [String] the author name
        # @param slug [String, nil] unique URL slug (auto-generated if nil)
        # @param description [String, nil] short page description
        # @param date [Object, nil] publication timestamp
        # @param elements [Array<Object>] list of web layout components
        # @return [Flatplan::Medium::Web::Page]
        def story(title, author:, slug: nil, description: nil, date: nil, elements: [])
          Flatplan::Medium::Web::Page
            .new(title, author:, slug:, description:, date:, elements:)
        end
      end
    end
  end
end

