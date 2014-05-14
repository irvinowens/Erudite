require File.expand_path('test_helper')
require 'yaml'

class ConfigTest < MiniTest::Unit::TestCase
  def test_can_load_config
    @config = EruditeConfig.get_config
    puts "EruditeConfig: #{@config.inspect}"
    assert_equal(@config["client_to_server"]["interface"], "0.0.0.0")
  end
end