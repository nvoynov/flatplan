require_relative 'configuration'
require_relative '../basic'

module Flatplan

  # Aplication configuration Singleton
  class Config < ::Basic::Configuration
    manage Configuration
  end
end
