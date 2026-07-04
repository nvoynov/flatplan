require_relative "../test_helper"

describe Flatplan::Service::CreateInitialManifest do
  
  Contatiner = Struct.new(:file_store)
  
  before do
    @config = Config.instance
    @mock_store = Minitest::Mock.new
    container = Contatiner.new(file_store: @mock_store)
    
    # Сбрасываем Ports::Context через метапрограммирование для изоляции
    Flatplan::Ports::Context.instance_variable_set(:@instance, nil)
    Flatplan::Ports::Context.setup(container)
  end

  it "raises an ArgumentError if the target directory does not exist" do
    # Программируем мок: на вызов directory_exists? с плохим путем вернуть false
    @mock_store.expect :directory_exists?, false, ["invalid/path"]

    assert_raises(ArgumentError) do
      Flatplan::Service::CreateInitialManifest.call(
        directory_path: "invalid/path"
      )
    end
    
    # Проверяем, что метод действительно вызывался
    @mock_store.verify
  end

  it "successfully orchestrates initial manifest generation using mocks" do
    dir = "gallery/svalovichi"
    intro_text = "Some places call you back.\n\nThey hold a quiet truth."
    
    # 2. Программируем цепочку ожидаемых вызовов (Contract Expectation)
    @mock_store.expect :directory_exists?, true, [dir]
    @mock_store.expect :basename, "svalovichi", [dir]
    
    # Симулируем содержимое папки
    simulated_entries = ["DP2Q2553.webp", "notes.txt", "DP2Q2554.jpg"]
    @mock_store.expect :list_entries, simulated_entries, [dir]
    
    # Наш сервис будет вызывать extname для каждого файла
    @mock_store.expect :extname, ".webp", ["DP2Q2553.webp"]
    @mock_store.expect :extname, ".txt", ["notes.txt"]
    @mock_store.expect :extname, ".jpg", ["DP2Q2554.jpg"]
    
    # Ожидаем склейку пути для ALBUM.md
    expected_manifest_path = "gallery/svalovichi/#{@config.manifest_name}"
    @mock_store.expect :join_paths, expected_manifest_path, [dir, @config.manifest_name]
    
    # Самая важная проверка: проверяем, что запишется именно правильный контент
    # Мы используем лямбду (Minitest::Mock::GenericExpectation) для валидации текста
    content_validator = ->(content) do
      content.include?("% Svalovichi") &&
        content.include?("# Svalovichi") &&
        content.include?("text: left") &&
        content.include?("Some places call you back.") &&
        content.include?("![](DP2Q2553.webp)") &&
        !content.include?("notes.txt") # txt должен быть отфильтрован
    end
    
    @mock_store.expect :write_text_file, true, [expected_manifest_path, content_validator]

    # 3. Выполняем наш сервис-команду
    result_path = Flatplan::Service::CreateInitialManifest.call(
      directory_path: dir,
      raw_text: intro_text
    )

    # 4. Финальные ассерты и верификация мока
    assert_equal expected_manifest_path, result_path
    @mock_store.verify # Гарантирует, что ВСЕ методы были вызваны строго по контракту
  end
end
