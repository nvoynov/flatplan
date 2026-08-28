require_relative 'book/text_and_media'
require_relative 'book/volume'
require_relative 'book/spread'
require_relative 'book/colophon'
require_relative 'book/factory'
require_relative 'book/builder'

module Flatplan
  module Medium
    # Book Medium namespace
    # В слое книги публикация — это не плоская страница, а Том (Volume),
    # который состоит из Разворотов (Spreads). Каждый разворот физически
    # делит элементы на левую и правую Полосы (Pages). Также здесь появляется
    # чисто печатный элемент — Колофон (Colophon) (сведения о тираже и типографии),
    # которого в вебе принципиально быть не может.
    module Book
    end
  end
end
