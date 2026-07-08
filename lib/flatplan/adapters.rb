require_relative 'adapters/file_system_store'
require_relative 'adapters/negatives_metadata'

module Flatplan

  # Adapters namespace
  module Adapters     
  end

  FileSystemStoreAdapter = Adapters::FileSystemStore
  NegativesMetadataAdapter = Adapters::NegativesMetadata
end
