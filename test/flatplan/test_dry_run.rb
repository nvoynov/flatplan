# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'support/mother_core'

describe 'Flatplan Publication Lifecycle Dry-Run' do
  let(:raw_text)  { MotherCore.text("Svalovichi: An entry into the quiet wild.") }
  let(:raw_media) { MotherCore.media_assets(["images/photo1.jpg", "images/photo2.jpg"]) }
  
  let(:filenames) { raw_media.assets.map(&:filepath) }
  let(:metadata_db) do
    {
      "photo1" => { "caption" => "The lonely house", "width" => 3000, "height" => 2000 },
      "photo2" => { "caption" => "The wooden boat", "width" => 3000, "height" => 2000 }
    }
  end

  it 'successfully completes the round-trip for both Web and Book mediums' do
    # -------------------------------------------------------------------------
    # 1. Сборка стартового Web-графа через StoryInitializer
    # -------------------------------------------------------------------------
    web_factory     = Flatplan::Medium::Web::Factory.new
    web_initializer = Flatplan::Core::StoryInitializer.new(web_factory)

    web_page = web_initializer.call(
      title: "Svalovichi: Two Journeys",
      author: "Nikolay Voynov",
      filenames: filenames,
      raw_text: raw_text.body,
      metadata: metadata_db
    )

    # Верифицируем применение вебовских дефолтов в PORO-модели
    # puts ">>> Original <<<"; pp web_page
    assert_equal "svalovichi-two-journeys", web_page.slug
    assert_equal :left, web_page.elements.first.text_position
    assert_equal false, web_page.elements.first.flow

    # -------------------------------------------------------------------------
    # 2. Сериализация в плоский манифест web.md
    # -------------------------------------------------------------------------
    web_serializer = Flatplan::Medium::Web::Serializer.new
    manifest_text  = web_serializer.serialize(web_page)

    # Проверяем, что свойства презентации выгрузились в красивые ключи
    assert_match(/adjust: left/, manifest_text)
    assert_match(/flow: false/, manifest_text)
    assert_match(/columns: 2/, manifest_text)

    # -------------------------------------------------------------------------
    # 3. Восстановление состояния из манифеста в Web (Парсинг/Билд)
    # -------------------------------------------------------------------------
    web_builder   = Flatplan::Medium::Web::Builder.new(web_factory)
    compiled_page = web_builder.build(manifest_text)
    # puts ">>> Copy <<<"; pp compiled_page

    # Проверяем эквивалентность данных до и после сохранения
    assert_equal web_page.title, compiled_page.title
    assert_equal web_page.author, compiled_page.author
    assert_equal web_page.elements.size, compiled_page.elements.size
    
    compiled_block = compiled_page.elements.first
    assert_equal :left, compiled_block.text_position
    assert_equal false, compiled_block.flow
    assert_equal "images/photo1.jpg", compiled_block.assets.first.filepath
skip
    # -------------------------------------------------------------------------
    # 4. Проверка расширяемости: Переиспользование манифеста в слое Книги
    # -------------------------------------------------------------------------
    book_factory = Flatplan::Medium::Book::Factory.new
    book_builder = Flatplan::Medium::Book::Builder.new(book_factory)
    # puts manifest_text

    # Книжный билдер читает тот же маркдаун, но строит пространственную структуру разворотов
    book_volume = book_builder.build(manifest_text)
    pp book_volume
    # Проверяем печатные инварианты
    assert_equal "Svalovichi: Two Journeys", book_volume.title
    assert_equal 2, book_volume.spreads.size # Композиция + Технический Колофон
    
    # Левая полоса первого разворота — текст, правая — сетка картинок
    first_spread = book_volume.spreads.first
    assert_match(/Svalovichi/, first_spread.left_page.body)
    assert_equal "classic_diptych", first_spread.right_page.metadata[:print_template]
    
    # Последний разворот содержит автоматически добавленный колофон
    assert_equal "ArtPrint Co", book_volume.spreads.last.right_page.metadata[:printer]
  end
end

