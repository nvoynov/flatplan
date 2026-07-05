require_relative 'layout_section'

module Flatplan
  module Model

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
