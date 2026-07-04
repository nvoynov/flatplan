require_relative 'flatplan/model'
require_relative 'flatplan/builder'
require_relative 'flatplan/presenter'
require_relative 'flatplan/ports'
require_relative 'flatplan/service'
require_relative 'flatplan/config'
require_relative 'flatplan/callable'

# Root domain namespace
module Flatplan

  # Global upper-level aliases for rapid script orchestration (Developer Experience)
  CreateInitialManifest = Service::CreateInitialManifest
end
