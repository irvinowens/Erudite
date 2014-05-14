require 'yaml'
require 'logger'

# the config class will wrap the configuration file
# and handle all queries for it

class EruditeConfig

  attr_accessor :config

  def initialize
    @config = YAML.load_file(File.expand_path('../conf/config.yaml'))
  end

  # Will just get the entire config and return it

  def self.get_config
    return YAML.load_file(File.expand_path('../conf/config.yaml'))
  end
end