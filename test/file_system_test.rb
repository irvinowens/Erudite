require File.expand_path('test_helper')
require '../lib/Erudite/file_system'
require 'logger'
require 'yaml'
require '../lib/Erudite/erudite_config'

class FileSystemTest < MiniTest::Unit::TestCase
  # Can we initialize the file system?
  def setup
    @filesystem = FileSystem.new
  end

  def test_can_read_config
    assert_equal(@filesystem.config["logging"]["level"], "DEBUG")
  end
end