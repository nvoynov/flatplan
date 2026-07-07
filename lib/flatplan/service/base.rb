# lib/flatplan/service/base.rb

require "forwardable"
require_relative "../callable"
require_relative "../config"
require_relative "../ports"

module Flatplan
  module Service
    # Abstract base class for all domain use cases, services, and tasks.
    # Encapsulates clean dependency proxying and modern invocation sugar.
    class Base
      extend Callable
      extend Forwardable

      # Delegate configuration singleton registry directly to the object level
      def_delegator :'Flatplan::Config', :instance, :config

      # Delegate core infrastructure context calls directly to the object level
      def_delegators :'Flatplan::Ports::Context', :file_store, :metadata_store
    end
  end
end
