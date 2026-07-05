require_relative 'base'

module Flatplan
  module Builder
    
    # A standalone factory responsible for polymorphically instantiating
    # specialized LayoutSection domain objects without coupling the base entity.
    class SectionFactory < Base

      # Instantiates a specific layout section subclass based on the given type.
      #
      # @param type [Symbol, String] the desired section subclass identifier
      # @param kwargs [Hash] arbitrary keyword arguments for instantiation
      # @return [Model::LayoutSection] an instance of a specialized section
      # @raise [ArgumentError] if the provided type is unrecognized
      def call(type, **kwargs)
        case type.to_sym
        when :text_and_media
          Model::TextAndMediaSection.new(**kwargs)
        when :visual_pause
          Model::VisualPauseSection.new(**kwargs)
        when :editorial_hero
          Model::EditorialHeroSection.new(**kwargs)
        else
          raise ArgumentError, "Unknown layout section type: #{type}"
        end
      end
    end
  end
end
