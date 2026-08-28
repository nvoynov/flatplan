# frozen_string_literal: true

module Flatplan
  module Core
    # A semantic marker indicating a deliberate pause or breach in the visual rhythm.
    # It carries no raw content data, serving strictly as a structural anchor 
    # that presentation layers translate into screen-snaps, physical page breaks, 
    # or blank spreads.
    class VisualPause
      # Initializes a new visual pause marker.
      def initialize; end
    end
  end
end

