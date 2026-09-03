# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Book

      # Represents a physical two-page book spread (left and right layout pages).
      class Spread < Flatplan::Core::Base
        # @return [Object, nil] layout element placed on the left page
        attr_reader :left_page

        # @return [Object, nil] layout element placed on the right page
        attr_reader :right_page

        def initialize(left_page = nil, right_page = nil, **kwargs)
          @left_page  = left_page
          @right_page = right_page
          super()
        end
      end
    end
  end
end

