require_relative 'flatplan/version'
require_relative 'flatplan/banner'
require_relative 'flatplan/callable'
require_relative 'flatplan/config'
require_relative 'flatplan/model'
require_relative 'flatplan/builder'
require_relative 'flatplan/presenter'
require_relative 'flatplan/ports'
require_relative 'flatplan/service'
require_relative 'flatplan/adapters'
require_relative 'flatplan/cli'

# Root domain namespace
module Flatplan
  def self.default!
    container = Struct.new(:file_store, :metadata_store)
      .new(
        file_store: FileSystemStoreAdapter.new,
        metadata_store: NegativesMetadataAdapter.new
      )
    Ports::Context.setup(container)
  end
end
