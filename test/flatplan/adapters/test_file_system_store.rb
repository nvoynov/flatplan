require "fileutils"
require "tmpdir"
require_relative "../test_helper"
require_relative "../ports/shared_file_store_test"

class FileSystemStoreTest < Minitest::Test
  # Inject the shared contract tests. Minitest will run all verification loops automatically!
  include SharedFileStoreTest

  def setup
    # 1. Instantiate the concrete infrastructure adapter under test
    @store = Flatplan::Adapters::FileSystemStore.new
    
    # 2. Establish a dynamic physical system tempfolder for file disk mutations
    @tmp_dir = Dir.mktmpdir("flatplan_adapter_test_")
    @valid_dir_path = @tmp_dir
  end

  def teardown
    # 3. Clean up the disk footprint after test suite completion
    FileUtils.remove_entry(@tmp_dir) if Dir.exist?(@tmp_dir)
  end
end
