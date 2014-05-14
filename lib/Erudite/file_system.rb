# Author: badbeef<0x8badbeef@sigsegv.us>
# The filesystem class controls creating, modifying, deleting, and moving files
# It will use consistent hashing to access the data.  It will assume that the
# filesystem is at least 32-bits so it will create large files with random
# access
# It will try to maintain at least three replicas of the data on different
# machines if available

require "logger"
require "yaml"

class FileSystem
  attr_accessor :logger, :config
  def initialize
    @config = YAML.load_file(File.expand_path('../conf/config.yaml'))
    if File.exist?(@config["logging"]["file"])
      # skip, file exists
    else
      FileUtils.mkpath(File.dirname(File.expand_path(@config["logging"]["file"])))
      File.open(@config["logging"]["file"],"w+") { |f| f.write("Opening Logfile\n")}
    end
    @logger = Logger.new(File.expand_path(@config["logging"]["file"]), 'daily')
    @logger.level = Logger.const_get @config["logging"]["level"]
    @logger.progname = 'FileSystem'
    @logger.debug "Config: #{@config}"
    @logger.info "Filesystem Initialization Complete"
  end
end