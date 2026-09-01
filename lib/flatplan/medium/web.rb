require_relative 'web/text'
require_relative 'web/media'
require_relative 'web/media_assets'
require_relative 'web/text_and_media'
require_relative 'web/page'
require_relative 'web/factory'
require_relative 'web/serializer'
require_relative 'web/builder'
require_relative 'web/presenter'

module Flatplan
  module Medium 
    # Web content models namespace
    module Web
    end
  end

  WebPresenter = Medium::Web::Presenter \
    unless defined?(WebPresenter)
end

