require_relative 'service/base'
require_relative 'service/create_initial_manifest'


module Flatplan

  # Services namespace
  module Service
  end

  # Global upper-level aliases for rapid script orchestration (Developer Experience)
  CreateInitialManifest = Service::CreateInitialManifest
end
