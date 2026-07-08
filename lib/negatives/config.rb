require_relative 'basic'
require_relative 'configuration'

module Negatives

  # Aplication configuration Singleton
  class Config < ::Basic::Configuration
    manage Configuration
  end
end
