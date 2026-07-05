require_relative 'layout_section'

module Flatplan
  module Model

    # A specialized section where textual narrative interacts directly
    # with a structural grid of photographs.
    class TextAndMediaSection < LayoutSection
      # @return [Symbol] text block placement (:left, :right, :centered)
      attr_accessor :text_alignment

      # @return [Symbol] media grid placement (:left, :right, :centered)
      attr_accessor :media_alignment

      # @return [Array<String>] array of textual paragraphs
      attr_accessor :paragraphs
  
      # @return [Symbol] spacing between paragraphs
      attr_accessor :spacing

      # Initializes an editorial text-and-media layout spread.
      #
      # @param media_assets [Array<LayoutAsset>] collection of section assets
      # @param text_alignment [Symbol] layout side for text columns
      # @param media_alignment [Symbol] layout side for image grid
      # @param paragraphs [Array<String>] collection of body paragraphs
      # @param spacing [Symbol] spacing bettewn paragraphs
      def initialize(
        media_assets: [],
        text_alignment: :left,
        media_alignment: :right,
        paragraphs: [],
        spacing: :medium
      )
        super(media_assets:)
        @text_alignment = text_alignment
        @media_alignment = media_alignment
        @paragraphs = paragraphs
      end
    end

  end
end
