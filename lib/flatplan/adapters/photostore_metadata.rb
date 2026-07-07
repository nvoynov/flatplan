require "fileutils"
require 'json'
require_relative '../ports'
require_relative '../../basic'

module Flatplan
  module Adapters
    
    # Concrete Hexagonal Infrastructure Adapter that connects the abstract
    # Ports::FileStore port directly to the host operating system file system.
    class PhotoStoreMetadata < Ports::MetadataStore
      # @see Ports::MetadataStore#fetch
      # @return [Hash<Key symbol, Metadata hash >]
      def fetch(*keys)
        PhotoStoreCli.call(*keys)
          # .tap{ pp it }
          .map{ [ File.basename(it['filename'], '.*'), it] }
          .to_h
      end

      protected

      class PhotoStoreCli < ::Basic::CliTool
        def call(*image_keys)
          return [] if image_keys.empty?

          binary_path = File.join(Dir.pwd, "bin", "photostore")
          raw_json = execute_command(binary_path, *image_keys)
          return [] if raw_json.strip.empty?

          parsed_data = JSON.parse(raw_json)
          parsed_data.is_a?(Array) ? parsed_data : [parsed_data]
        end
      end
      
    end

  end
end
