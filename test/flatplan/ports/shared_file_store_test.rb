# Shared contract test suite for any adapter implementing the
# Flatplan::Ports::FileStore abstract interface.
#
# @example
# 
#   class SystemFileStoreTest < Minitest::Test
#     include Flatplan::Test::SharedFileStoreTest
#  
#     def setup
#       @store = Flatplan::Adapter::SystemFileStore.new
#       @valid_dir_path = File.expand_path("../support/fixtures", __dir__)
#     end
#   end
#
# To use this contract, include this module inside your concrete
# Minitest test class and ensure `@store` is initialized in the `setup`.
module SharedFileStoreTest
  # Verifies that #directory_exists? correctly handles true/false states.
  def test_contract_directory_exists
    assert_respond_to @store, :directory_exists?
    
    # We assume the test setup provides at least one valid path
    assert_equal true, @store.directory_exists?(@valid_dir_path)
    assert_equal false, @store.directory_exists?("non/existent/dir/path")
  end

  # Verifies that #basename correctly extracts the trailing path component.
  def test_contract_basename
    assert_respond_to @store, :basename
    assert_equal "svalovichi", @store.basename("gallery/svalovichi")
    assert_equal "photo.webp", @store.basename("photo.webp")
  end

  # Verifies that #list_entries returns an array of strings.
  def test_contract_list_entries
    assert_respond_to @store, :list_entries
    entries = @store.list_entries(@valid_dir_path)
    
    assert_kind_of Array, entries
    entries.each { assert_kind_of String, it }
  end

  # Verifies that #extname extracts correct filename extensions.
  def test_contract_extname
    assert_respond_to @store, :extname
    assert_equal ".webp", @store.extname("photo.webp")
    assert_equal ".TIF", @store.extname("image.TIF")
    assert_equal "", @store.extname("Makefile")
  end

  # Verifies that #join_paths assembles path segments properly.
  def test_contract_join_paths
    assert_respond_to @store, :join_paths
    combined = @store.join_paths("gallery", "svalovichi", "ALBUM.md")
    assert_equal "gallery/svalovichi/ALBUM.md", combined
  end

  # Verifies that #write_text_file responds correctly to invocation.
  def test_contract_write_text_file
    assert_respond_to @store, :write_text_file
    target_path = @store.join_paths(@valid_dir_path, "TEST_MANIFEST.md")
    
    # Contract demands it accepts path and content without crashing
    @store.write_text_file(target_path, "# Test Content")
  end
  
  # Verifies that #read_text_file responds correctly to invocation.
  def test_contract_read_text_file
    assert_respond_to @store, :read_text_file
    target_path = @store.join_paths(@valid_dir_path, "TEST_MANIFEST.md")
    
    # Contract demands it returns a string when file exists
    @store.write_text_file(target_path, "# Existing Content")
    assert_equal "# Existing Content", @store.read_text_file(target_path)
  end
end
