require_relative 'builder/initial_series_publication'
require_relative 'builder/manifest_parser'
require_relative 'builder/section_factory'

module Flatplan

  # Builder namespace
  module Builder
  end

  # Internal shortcut for rapid domain compilation within services
  BuildInitialSeriesPublication = Builder::InitialSeriesPublication
  ParseManifest = Builder::ManifestParser
  BuildSection = Builder::SectionFactory
end
