# lib/flatplan/model/sections.rb

module Flatplan
  module Model
    # TODO: extract all sections as one source per section

    # A specialized section where textual narrative interacts directly
    # with a structural grid of photographs.
    class TextAndMediaSection < LayoutSection
      # @return [Symbol] text block placement (:left, :right, :centered)
      attr_accessor :text_alignment

      # @return [Symbol] media grid placement (:left, :right, :centered)
      attr_accessor :media_alignment

      # @return [Array<String>] array of textual paragraphs
      attr_accessor :paragraphs

      # Initializes an editorial text-and-media layout spread.
      #
      # @param media_assets [Array<LayoutAsset>] collection of section assets
      # @param text_alignment [Symbol] layout side for text columns
      # @param media_alignment [Symbol] layout side for image grid
      # @param paragraphs [Array<String>] collection of body paragraphs
      def initialize(
        media_assets: [],
        text_alignment: :left,
        media_alignment: :right,
        paragraphs: []
      )
        super(media_assets:)
        @text_alignment = text_alignment
        @media_alignment = media_alignment
        @paragraphs = paragraphs
      end
    end

    # A deliberate structural pause consisting solely of media tracks,
    # establishing empty space and visual silence.
    class VisualPauseSection < LayoutSection
      # @return [Symbol] depth parameters for layout spacing (:medium, :large)
      attr_accessor :spacing

      # Initializes a visual pause layout block.
      #
      # @param media_assets [Array<LayoutAsset>] collection of section assets
      # @param spacing [Symbol] whitespace size descriptor
      def initialize(media_assets: [], spacing: :medium)
        super(media_assets:)
        @spacing = spacing
      end
    end

    # A high-impact centerpiece element showcasing a single full-screen image,
    # optionally supported by an overlaid blockquote.
    class EditorialHeroSection < LayoutSection
      # @return [Symbol] hero style variant flag (:hero)
      attr_accessor :layout_style

      # @return [Symbol] framing layout alignment (:centered)
      attr_accessor :media_alignment

      # Initializes a large-scale editorial hero spread.
      #
      # @param media_assets [Array<LayoutAsset>] collection of section assets
      # @param layout_style [Symbol] aesthetic type definition
      # @param media_alignment [Symbol] boundary focus alignment
      def initialize(
        media_assets: [],
        layout_style: :hero,
        media_alignment: :centered
      )
        super(media_assets:)
        @layout_style = layout_style
        @media_alignment = media_alignment
      end
    end
  end
end
