module Flatplan
  module Ports
    
    # Abstract interface contract for getting image metadata
    class MetadataStore

      # @param keys [Array<String>] image keys
      # @return [Hash<Key symbol, Metadata hash >]
      def fetch(*keys)
        raise NotImplementedError, "#{self.class} must implement #fetch?"
      end
    end
  end
end
