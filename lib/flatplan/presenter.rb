require_relative 'presenter/manifest_serializer'

module Flatplan

  # Presenters namespace
  module Presenter
  end

  # Internal shortcut for rapid manifest transformation within services
  SerializeManifest = Presenter::ManifestSerializer
end
