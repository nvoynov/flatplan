# frozen_string_literal: true

require_relative '../basic'

module Flatplan
  extend Basic::AliasMembers

  # default configuration
  ASSETS_DIR       = '~/Pictures'
  STORIES_DIR      = '~/Documents/flatplans'
  IMAGE_EXTENSIONS = %w[tif jpg jpeg webp].freeze
  AUTHOR           = 'Author'
  KEYWORDS         = %w[photography documentary].freeze 

  # Configuration data  
  ConfigData = Data.define(
    :assets_dir,
    :stories_dir,
    :image_extensions,
    :author,
    :keywords 
  ) do
    def initialize(
      assets_dir:  ASSETS_DIR,
      stories_dir: STORIES_DIR,
      image_extensions: IMAGE_EXTENSIONS,
      author: AUTHOR,
      keywords: KEYWORDS  
    )
      assets_dir = File.expand_path(assets_dir)
      stories_dir = File.expand_path(stories_dir)
      super(assets_dir:, stories_dir:, image_extensions:, author:, keywords:)
    end
  end

  # Flatplan configuration
  class Config < Basic::Configuration
    manage ConfigData
  end
end
