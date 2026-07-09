module Flatplan
  
  # An immutable configuration structure tracking global image masks,
  # custom manifest naming conventions, and default publication author tags.
  Configuration = Data.define(
    :series_dir,           # [String] path to the series directory
    :image_extensions,     # [Array<String>] list of supported image extensions
    :series_manifest_name, # [String] naming convention for series manifest files
    :author,               # [String, nil] default fallback author name for metadata
    :default_keywords      # [Array<String>] default fallback tags for SEO front matter
  ) do

    SERIES_DIR           = '~/Pictures/Series'
    IMAGE_EXTENSIONS     = %w[.tif .jpg .jpeg .webp]
    SERIES_MANIFEST_NAME = 'SERIES.md'
    AUTHOR               = 'Unknown Author'
    DEFAULT_KEYWORDS     = %w[nature photograpy documentary] 
  
    def initialize(
      series_dir:            SERIES_DIR,
      image_extensions:      IMAGE_EXTENSIONS,    
      series_manifest_name:  SERIES_MANIFEST_NAME, 
      author:                AUTHOR,               
      default_keywords:      DEFAULT_KEYWORDS  
    )
      super(
        series_dir:,
        image_extensions:,
        series_manifest_name:,
        author:,
        default_keywords:
      )
    end
  end
end
