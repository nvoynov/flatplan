# frozen_string_literal: true

module Flatplan
  module Core
    # Abstract interface defining how data blocks should be constructed.
    # Concrete factories (Web, Book, Zine) implement this to attach medium-specific styles.
    class Factory
      def text(body, **kwargs) = raise(NotImplementedError)
      def media(filepath, **kwargs) = raise(NotImplementedError)
      def media_assets(assets, **kwargs) = raise(NotImplementedError)
      def text_and_media(text, media)  = raise(NotImplementedError)
      def story(title, elements:, **kwargs) = raise(NotImplementedError)
    end
  end
end

