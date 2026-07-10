require_relative "base"

module Flatplan
  module Service
    # Reads a specific Markdown publishing manifest from the file storage context
    # and compiles it into a validated SeriesPublication domain aggregate tree.
    class LoadPublication < Base
      # Executes the layout manifest loading and parsing routines.
      #
      # @param directory_path [String] project subdirectory holding the manifest
      # @param manifest_name [String, nil] alternative manifest file name override
      # @return [Model::SeriesPublication] populated and structured domain entity
      # @raise [ArgumentError] if the folder or required manifest doesn't exist
      def call(directory_path:, manifest_name: nil)
        unless file_store.directory_exists?(directory_path)
          raise ArgumentError, "Target directory does not exist: #{directory_path}"
        end

        # Fallback dynamically onto the config default if no override is supplied
        active_name = manifest_name || config.series_manifest_name

        manifest_path = file_store.join_paths(directory_path, active_name)
        manifest_content = file_store.read_text_file(manifest_path)
        
        # Execute the domain compilation via the inner parsing aggregate builder
        ParseManifest.call(content: manifest_content)
      end
    end
  end
end
