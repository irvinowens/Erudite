require File.expand_path('test_helper')
require 'yaml'

class ConfigTest < MiniTest::Unit::TestCase
  def test_can_load_config
    @config = YAML.load_file(File.expand_path('../conf/config.yaml'))
    puts "Config: #{@config.inspect}"
    assert_equal(@config["client_to_server"]["interface"], "0.0.0.0")
  end
end