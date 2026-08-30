require_relative 'base'

module Flatplan
  module Command
    
    # Creates story from manifest file
    class Read < Base
      class << self
        def web = new(Flatplan::Medium::Web::Builder.new) 
        def book = new(Flatplan::Medium::Book::Builder.new) 
      end
      
      def initialize(builder)
        @builder = builder  
        super()
      end

      # @param manifest [String] target manifest
      # @return [Core::Story] object
      def call(manifest)
        raise "Manifest file does not exist: #{manifest}" \
          unless File.exist?(manifest)

        content = File.read(manifest)
        @builder.build(content)
      end
    end
  end
end
