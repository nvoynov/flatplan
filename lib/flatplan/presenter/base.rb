require "forwardable"
require_relative '../callable'
require_relative "../config"
require_relative '../model'

module Flatplan
  module Presenter
    
    # Parses raw Flatplan Markdown manifest strings into validated
    # Model::SeriesPublication domain entity aggregates based on header tracking.
    class Base
      extend Callable
      extend Forwardable

      # Delegate configuration singleton registry directly to the object level
      def_delegator :'Flatplan::Config', :instance, :config
    end

  end
end
