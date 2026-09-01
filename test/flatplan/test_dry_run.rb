# frozen_string_literal: true

require_relative 'test_helper'

describe 'Flatplan Publication Lifecycle' do
  # Общие исходные контентные примитивы из MotherCore
  let(:core_text)   { MotherCore.text("Svalovichi: An entry into the quiet wild.") }
  let(:core_media)  { MotherCore.media_assets(["images/photo1.jpg", "images/photo2.jpg"]) }
  let(:filenames)   { core_media.assets.map(&:filepath) }
  
  let(:metadata_db) do
    {
      "photo1" => { "caption" => "The lonely house", "width" => 3000, "height" => 2000 },
      "photo2" => { "caption" => "The wooden boat", "width" => 3000, "height" => 2000 }
    }
  end

  describe 'Web medium architecture' do
    it 'performs a perfect round-trip serialization and parsing' do
      web_factory     = Flatplan::Medium::Web::Factory.new
      web_initializer = Flatplan::Core::Initializer.new(web_factory)

      # 1. Создаем оригинальный Web-объект
      web_page = web_initializer.call(
        title: "Svalovichi: Two Journeys",
        author: "Nikolay Voynov",
        filenames: filenames,
        raw_text: core_text.body,
        metadata: metadata_db
      )

      # 2. Сериализуем в вебовский манифест
      web_serializer = Flatplan::Medium::Web::Serializer.new
      web_manifest   = web_serializer.serialize(web_page)

      # Проверяем, что в манифесте появились строго вебовские ключи
      assert_match(/adjust: left/, web_manifest)
      assert_match(/flow: false/, web_manifest)

      # 3. Восстанавливаем объект из вебовского манифеста
      web_builder   = Flatplan::Medium::Web::Builder.new(web_factory)
      compiled_page = web_builder.build(web_manifest)

      # Проверяем идентичность графа объектов веба
      assert_equal "svalovichi-two-journeys", compiled_page.slug
      assert_equal web_page.title, compiled_page.title
      
      compiled_block = compiled_page.elements.first
      assert_equal :left, compiled_block.text_position
      assert_equal false, compiled_block.flow
    end
  end

  describe 'Book medium architecture' do
    it 'build book!' do
      builder = Flatplan::Medium::Book::Builder.new
      builder.build(BOOK_MANIFEST)
    end

    it 'compiles flat print manifest into spatial layout spreads' do
      book_factory     = Flatplan::Medium::Book::Factory.new
      book_initializer = Flatplan::Core::Initializer.new(book_factory)

      # 1. Создаем оригинальный объект Книги (Volume)
      # В реальной жизни свойства презентации здесь будут настроены под печать
      book_initializer.call(
        title: "Svalovichi: Printed Edition",
        author: "Nikolay Voynov",
        filenames: filenames,
        raw_text: core_text.body,
        metadata: metadata_db
      )

      # 2. Симулируем чтение реального книжного манифеста (book.md)
      # Обрати внимание: здесь используются исключительно печатные ключи!
      book_manifest = <<~MARKDOWN
        ---
        title: "Svalovichi: Printed Edition"
        author: "Nikolay Voynov"
        description: "Initial draft of book edition"
        ---

        # TextAndMedia
        layout: text_left_images_right
        template: classic_diptych
        font: 12

        Svalovichi: An entry into the quiet wild.

        ![](images/photo1.jpg)
        ![](images/photo2.jpg)
      MARKDOWN

      # 3. Восстанавливаем объект через Книжный Билдер
      book_builder = Flatplan::Medium::Book::Builder.new(book_factory)
      compiled_book = book_builder.build(book_manifest)

      # Проверяем строго книжные пространственные инварианты
      assert_equal "Svalovichi: Printed Edition", compiled_book.title
      assert_equal 2, compiled_book.spreads.size # Наша композиция + Колофон

      # Проверяем, что первый разворот правильно разложил компоненты по полосам
      first_spread = compiled_book.spreads.first
      assert_match(/Svalovichi/, first_spread.left_page.body)
      assert_equal "classic_diptych", first_spread.right_page.metadata[:print_template]

      # Проверяем наличие автоматического колофона на последнем развороте
      assert_equal "ArtPrint Co", compiled_book.spreads.last.right_page.metadata[:printer]
    end
  end
end

