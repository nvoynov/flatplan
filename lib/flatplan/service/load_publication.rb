# lib/flatplan/service/load_publication.rb
require_relative 'base'

module Flatplan
  module Service
    # Reads a Markdown publishing manifest from the file storage context
    # and compiles it into a validated SeriesPublication domain aggregate.
    class LoadPublication < Base
      # Executes the layout manifest loading and parsing routines.
      #
      # @param directory_path [String] project subdirectory holding the manifest
      # @return [Model::SeriesPublication] populated and structured domain entity
      # @raise [ArgumentError] if the folder or required manifest doesn't exist
      def call(directory_path:)
        unless file_store.directory_exists?(directory_path)
          raise ArgumentError, "Target directory does not exist: #{directory_path}"
        end

        manifest_path = file_store.join_paths(directory_path, config.manifest_name)
        manifest_content = file_store.read_text_file(manifest_path)
        
        # Execute the domain compilation via the updated parser builder
        ParseManifest.call(content: manifest_content)
      end
    end
  end
end
