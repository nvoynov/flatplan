# lib/flatplan/ports.rb

require "forwardable"

module Flatplan
  module Ports
    # Immutable context registry class locked at boot time.
    # Proxies global system toolchains directly to the isolated instance.
    class Context
      class << self
        extend Forwardable

        # Proxy core ports to the internal underlying container instance
        def_delegators :@instance, :file_store, :metadata_store

        # Freezes and registers the global infrastructure context.
        #
        # @param container [Object] the initialized infrastructure container
        # @raise [RuntimeError] if domain ports context is already frozen
        def setup(container)
          raise "Domain ports context is already frozen!" if @instance

          @instance = container
        end
      end
    end
  end
end
