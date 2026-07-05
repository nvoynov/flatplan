require_relative 'presenter/manifest_serializer'
require_relative 'presenter/console_flatplan'
require_relative 'presenter/pandoc_manifest_serializer'

module Flatplan

  # Presenters namespace
  module Presenter
  end

  # Internal shortcut for rapid manifest transformation within services
  SerializeManifest = Presenter::ManifestSerializer
  SerializePandocManifest = Presenter::PandocManifestSerializer
  RenderConsoleFlatplan = Presenter::ConsoleFlatplan
end
