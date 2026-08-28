# frozen_string_literal: true

require_relative '../../../lib/flatplan/core'
require_relative '../../../lib/flatplan/medium'

# Object Mother pattern implementation for Flatplan Core entities.
# Provides pre-validated, high-quality test data graph structures
# to keep test code expressive and isolated from setup boilerplate.
module MotherCore
  extend self
  
  # Generates a minimal valid text content entity
  def text(body = "Svalovichi story text content.")
    Flatplan::Core::Text.new(body)
  end

  # Generates a single media entity
  def media(filepath = "images/01_road.jpg", caption: "The long dust road")
    Flatplan::Core::Media.new(filepath, caption: caption, alt: "Road photo", width: 3000, height: 2000)
  end

  # Generates a complete media assets collection containing two images
  def media_assets(paths = ["images/01.jpg", "images/02.jpg"])
    assets = paths.map { |path| media(path) }
    Flatplan::Core::MediaAssets.new(assets)
  end

  # Generates a linked TextAndMedia layout sequence
  def text_and_media(text_body = nil, paths = nil)
    text_element  = text(text_body || "Default split block text.")
    media_element = media_assets(paths || ["img1.jpg", "img2.jpg"])
    Flatplan::Core::TextAndMedia.new(text: text_element, media: media_element)
  end
end

