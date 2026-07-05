require_relative 'layout_section'

module Flatplan
  module Model

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

  end
end
