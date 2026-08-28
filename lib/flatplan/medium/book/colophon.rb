# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Book
      
      # A print-only structural block containing publishing details 
      # (printer, paper type, edition size, ISBN).
      class Colophon < Flatplan::Core::Base
        attr_reader :printer, :paper_type, :edition_size

        def initialize(printer:, paper_type:, edition_size:)
          @printer      = printer
          @paper_type   = paper_type
          @edition_size = edition_size
          super(printer: printer, paper_type: paper_type, edition_size: edition_size)
        end
      end
    end
  end
end

