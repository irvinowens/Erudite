require File.expand_path('test_helper')
require '../lib/Erudite/file_system'
require 'logger'
require 'yaml'
require 'murmurhash3'
require '../lib/Erudite/erudite_config'

class FileSystemTest < MiniTest::Unit::TestCase
  # Can we initialize the file system?
  def setup
    @filesystem = FileSystem.new
  end

  def test_can_read_config
    assert_equal(@filesystem.config["logging"]["level"], "DEBUG")
  end

  def test_create_keyspace_folder
    ks_name = "maximillian"
    @filesystem.create_keyspace_dir ks_name
    assert(File.exist?(@filesystem.config["data_folders"][0] + "/" + MurmurHash3::Native128::murmur3_128_str_hexdigest(ks_name)))
  end

  def test_create_toc_file
    ks_name = "maximillian"
    @filesystem.create_keyspace_dir(ks_name)
    dirs = nil
    @filesystem.create_new_toc_file(keyspace:ks_name)
    Dir.glob('**/*.toc').each do |dir|
      dirs = dir
    end
    assert(dirs)
  end

  def teardown
    FileUtils.rmtree("var")
  end
end