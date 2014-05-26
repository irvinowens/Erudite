require 'yaml'
require 'logger'

# the config class will wrap the configuration file
# and handle all queries for it

class EruditeConfig

  attr_accessor :config

  def initialize
    @config = YAML.load_file(File.expand_path('../conf/config.yaml'))
  end

  # will get a given property by the provided key

  def get_property_by_key(key)
    return @config[key]
  end

  # get the data folders

  def get_data_folders
    return @config["data_folders"]
  end

  def get_backup_folders
    return @config["backup_folders"]
  end

  # Will just get the entire config and return it

  def self.get_config
    return YAML.load_file(File.expand_path('../conf/config.yaml'))
  end
end