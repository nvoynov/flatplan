# frozen_string_literal: true

require_relative 'serializable'

module Flatplan
  module Core

    # Base class
    class Base
      def self.initialize_args
        instance_method(:initialize).parameters
          .map { |_type, name| name }
          .compact
      end

      def initialize_args = self.class.initialize_args
    end
  end
end

