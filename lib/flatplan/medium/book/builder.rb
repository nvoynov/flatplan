# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Book
      # Compiles a flat book.md manifest into a structured physical Book::Volume.
      # It leverages the core text-parsing algorithms, then redistributes 
      # flat blocks into paired layout Spreads.
      class Builder < Flatplan::Core::Builder
        def initialize(factory = Flatplan::Medium::Book::Factory.new)
          super(factory)
        end

        def build(manifest_content)
          flat_volume = super(manifest_content)

          paired_spreads = layout_into_spreads(flat_volume.elements)

          Flatplan::Medium::Book::Volume.new(
            flat_volume.title,
            author: flat_volume.author,
            description: flat_volume.description,
            date: flat_volume.date,
            elements: flat_volume.elements,
            spreads: paired_spreads
          )
        end

        private

        def translate_metadata(properties)
          mapped = {}
          mapped[:print_layout]   = properties[:layout].to_sym if properties[:layout]
          mapped[:print_template] = properties[:template] if properties[:template]
          mapped[:font_size]      = properties[:font].to_i if properties[:font]
          mapped
        end

        def layout_into_spreads(elements)
          spreads = []
          
          elements.each do |el|
            if el.is_a?(TextAndMedia) && el.print_layout == :text_left_images_right
              spreads << @factory.spread(el.text, el.media_assets, layout: :split)
            else
              spreads << @factory.spread(nil, el)
            end
          end
          
          spreads << @factory.spread(
            nil, 
            @factory.colophon(printer: "ArtPrint Co", paper_type: "Matte 170g", edition_size: 100)
          )
          
          spreads
        end
      end
    end
  end
end
