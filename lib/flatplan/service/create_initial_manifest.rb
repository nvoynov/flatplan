require_relative 'base'

module Flatplan
  module Service
    # Orchestrates the creation of a starting Flatplan Markdown manifest
    # using uniform, executable domain commands across all system layers.
    class CreateInitialManifest < Base
      # Executes the manifest generation task.
      #
      # @param directory_path [String] the target directory to scan and populate
      # @param raw_text [String, nil] optional starting text for the album
      # @return [String] the absolute path to the newly written manifest file
      # @raise [ArgumentError] if the directory path is invalid or missing
      def call(directory_path:, raw_text: nil)
        unless file_store.directory_exists?(directory_path)
          raise ArgumentError, "Target directory does not exist: #{directory_path}"
        end

        # 0. Return manifest when it exists already
        manifest_path = file_store.join_paths(directory_path, config.manifest_name)
        return manifest_path if file_store.file_exist?(manifest_path)
        
        folder_name = file_store.basename(directory_path)
        title = folder_name.gsub(/[-_]/, " ").capitalize
        all_files = file_store.list_entries(directory_path)
        
        images = all_files.select do
          ext = file_store.extname(it).downcase
          config.image_extensions.include?(ext)
        end

        # 1. Compilation Step (Builder shortcut call)
        publication = BuildInitialSeriesPublication.call(
          title: title,
          raw_text: raw_text,
          filenames: images
        )

        # 2. Serialization Step (Presenter shortcut call)
        manifest_content = SerializeManifest.call(publication)

        # 3. Persistence Step
        manifest_path = file_store.join_paths(directory_path, config.manifest_name)
        file_store.write_text_file(manifest_path, manifest_content)

        manifest_path
      end
    end
  end
end
