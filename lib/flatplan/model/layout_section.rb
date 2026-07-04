# lib/flatplan/model/layout_section.rb

module Flatplan
  module Model
    # Abstract base class representing a generic editorial block or layout spread.
    # It acts as a domain entity holding visual assets.
    class LayoutSection
      # @return [Array<LayoutAsset>] list of photos assigned to this section
      attr_accessor :media_assets

      # Initializes a basic layout section.
      #
      # @param media_assets [Array<LayoutAsset>] collection of assets
      def initialize(media_assets: [])
        @media_assets = media_assets
      end

      # Polymorphic factory method to instantiate a specific layout section.
      #
      # @param type [Symbol, String] the desired section subclass type
      # @param kwargs [Hash] arbitrary keyword arguments for instantiation
      # @return [LayoutSection] an instance of a specialized section subclass
      # @raise [ArgumentError] if the provided type is unrecognized or unsupported
      def self.create(type, **kwargs)
        case type.to_sym
        when :text_and_media
          TextAndMediaSection.new(**kwargs)
        when :visual_pause
          VisualPauseSection.new(**kwargs)
        when :editorial_hero
          EditorialHeroSection.new(**kwargs)
        else
          raise ArgumentError, "Unknown layout section type: #{type}"
        end
      end
    end
  end
end
