# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Book
      # Represents a complete printed photobook volume.
      # It encapsulates global metadata and a structured sequence of book spreads.
      class Volume < Flatplan::Core::Story
        # @return [Array<Flatplan::Medium::Book::Spread>] ordered list of book spreads
        attr_reader :spreads

        def initialize(title, author:, description: nil, date: nil, elements:, spreads: [])
          # Core elements remain empty or hold flat blocks, but Volume introduces spreads
          super(title, author:, description:, date:, elements:)
          @spreads = spreads
        end
      end
    end
  end
end

