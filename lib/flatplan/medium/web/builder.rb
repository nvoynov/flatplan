# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Web
      # Concrete Web builder strategy.
      # It inherits the flat manifest parsing engine from Core and implements
      # property translation rules specific to Web layout elements.
      class Builder < Flatplan::Core::StoryBuilder
        # Initializes the web builder with its matching factory.
        # @param factory [Flatplan::Medium::Web::Factory]
        def initialize(factory = Flatplan::Medium::Web::Factory.new)
          super(factory)
        end

        private

        def default_media_options
          { size: :standard }
        end

        # Translates manifest syntax (e.g., adjust: right) into web model properties.
        # @param properties [Hash{Symbol => String}] raw keywords from the file
        # @return [Hash{Symbol => Object}] translated keywords for Web::Factory
        def translate_metadata(properties)
          mapped = {}

          # Translate 'adjust' to proper placement domains based on context
          if properties[:adjust]
            mapped[:text_position] = properties[:adjust] == 'right' ? :right : :left
            mapped[:alignment]     = properties[:adjust].to_sym
          end

          mapped[:columns]     = properties[:columns].to_i if properties[:columns]
          mapped[:flow]        = properties[:flow] == 'true' if properties[:flow]
          mapped[:aspect_mode] = properties[:aspect].to_sym if properties[:aspect]

          mapped
        end
      end
    end
  end
end

