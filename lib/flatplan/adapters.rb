require_relative 'adapters/file_system_store'
require_relative 'adapters/photostore_metadata'

module Flatplan

  # Adapters namespace
  module Adapters     
  end

  FileSystemStoreAdapter = Adapters::FileSystemStore
  PhotoStoreMetadataAdapter = Adapters::PhotoStoreMetadata
end
