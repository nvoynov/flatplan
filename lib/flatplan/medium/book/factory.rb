# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Book
      # Concrete factory for print photobook components.
      # Embeds default typesetting variables like page sides and font scales.
      class Factory < Flatplan::Core::Factory
        # @return [Flatplan::Core::Text]
        def text(body, column_side: :left, font_size: 11, **_)
          Flatplan::Core::Text.new(body, column_side:, font_size:)
        end

        # @return [Flatplan::Core::Media]
        def media(filepath, caption: nil, alt: nil, width: nil, height: nil, **_)
          Flatplan::Core::Media.new(filepath, caption:, alt:, width:, height:)
        end

        # @return [Flatplan::Core::MediaAssets]
        def media_assets(assets, print_template: 'classic_diptych', **_)
          Flatplan::Core::MediaAssets.new(assets, print_template:)
        end

        # @return [Flatplan::Medium::Book::TextAndMedia]
        def text_and_media(text, media_assets, print_layout: :text_left_images_right, **_)
          TextAndMedia.new(text, media_assets, print_layout:)
        end

        # @return [Flatplan::Medium::Book::Volume]
        def story(title, author:, description: nil, date: nil, elements: [], **_)
          Volume.new(title, author:, description:, date:, elements:, spreads: [])
        end

        # Специфичные методы фабрики только для Книги
        def spread(left, right, **kwargs) = Spread.new(left, right, **kwargs)
        def colophon(**kwargs)            = Colophon.new(**kwargs)
      end
    end
  end
end
