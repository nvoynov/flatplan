# frozen_string_literal: true

require_relative 'serializable'

module Flatplan
  module Core

    # Base class providing dynamic metadata handling, automatic getter generation,
    # and serialization capability for all publication blocks.
    class Base
      include Serializable

      def initialize
      end
    end
  end
end

