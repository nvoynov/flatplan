module Negatives

  # An immutable value object representing the component configuration
  Configuration = Data.define(
    :negatives_dir,    # [String] root path to master negatives directory
    :image_extensions, # [Array<String>] list of file extensions to scan
    :datastore         # [String] datastore file 
  ) do

    NEGATIVES_DIR = '~/Photos'
    IMAGE_EXTENSIONS = %w[.tif .rw2]
    DATASTORE = 'data/negatives.json'
    
    def initialize(
      negatives_dir: NEGATIVES_DIR,
      image_extensions: IMAGE_EXTENSIONS,
      datastore: DATASTORE
    )
      super(negatives_dir:, image_extensions:, datastore:)
    end
  end
  
end
