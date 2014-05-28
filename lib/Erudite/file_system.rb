# Author: Irvin Owens Jr<0x8badbeef@sigsegv.us>
# The filesystem class controls creating, modifying, deleting, and moving files
# It will use consistent hashing to access the data.  It will assume that the
# filesystem is at least 32-bits so it will create large files with random
# access
#
# Erudite will back itself up nightly to the backup folder location, it would be
# best to locate this folder on a different device
#
# We will consistently hash rows and keys into TOC files, the TOC files will point to
# the value arrays.  The value arrays will contain versioned key values.
#
# Data will not be deleted, instead it will be marked for deletion, and a job will need
# to be run as a process that will actually remove data flagged for deletion.  The idea
# behind that is to keep operation as simple as possible and performance as consistent
# as possible.
#
# Adding data folders will increase the capacity of a given database host, however removing
# a folder will cause the database to stop operation, to maximize data correctness.

require "logger"
require "yaml"
require "murmurhash3"

class FileSystem
  attr_accessor :logger, :config
  def initialize
    @config = EruditeConfig.get_config
    @logger = FileSystem.init_logger(pname:'FileSystem',conf:@config)
    @logger.debug "Config: #{@config}"
    @logger.info "Filesystem Initialization Complete"
    config = EruditeConfig.new
    # create backup folders as required
    config.get_backup_folders.each do |backup_folder|
      FileUtils.mkpath(File.expand_path(backup_folder)) unless File.exist?(backup_folder)
    end
    # create data folders as required
    config.get_data_folders.each do |folder|
      FileUtils.mkpath(File.expand_path(folder)) unless File.exist?(folder)
    end
  end

  # Create a keyspace directory under the data dirs, in the case that we
  # write to one of the other folders.  Erudite will only start writing
  # to other folders if there is an error in writing to an individual folder
  # in other words, it will fill up each folder before using another
  #
  # The directory will be a hash of the name, so feel free to use spaces
  # whatever.

  def create_keyspace_dir ks_name
    # create keyspace folder under each data folder
    @config["data_folders"].each do |data_folder|
      FileUtils.mkpath(File.expand_path(data_folder) + "/" + MurmurHash3::Native128::murmur3_128_str_hexdigest(ks_name));
    end
  end

  # create new toc file in keyspace

  def create_new_toc_file(keyspace:nil)
    ks = keyspace || ArgumentError.throw("Keyspace can not be nil")
    ks =  MurmurHash3::Native128::murmur3_128_str_hexdigest(ks)
    toc_fn = SecureRandom.uuid() + ".toc"
    @config["data_folders"].each do |data_folder|
      File.open(File.expand_path(data_folder) + "/" + ks + "/" + toc_fn, 'w+') {
        @logger.info("Creating TOC file #{toc_fn} for keyspace #{ks} in data folder #{data_folder}")
      }
    end
  end

  # create new data file in keyspace

  def create_new_file_in_keyspace(keyspace:nil, file_name:nil)
    ks = keyspace || ArgumentError.throw("Keyspace must be defined")
    fn = file_name || ArgumentError.throw("File name must be defined")
  end

  # append to file in keyspace

  def append_to_file_in_keyspace(keyspace:nil,
                                 file_name:nil)
    ks = keyspace || ArgumentError.throw("Keyspace must be defined")
    fn = file_name || ArgumentError.throw("File name must be defined")

  end

  # seek and read from offset and length in keyspace

  def read_from_offset_in_keyspace(keyspace: nil,
                                   file_name:nil,
                                   offset:0,
                                   length:-1)
    ks = keyspace || ArgumentError.throw("Keyspace must be defined")
    fn = file_name || ArgumentError.throw("File Name must be defined")
    ln = (length > 0 ) || ArgumentError.throw("Length must be provided")
  end

  # Initialize the logger with a config and a pname

  def self.init_logger(pname: 'erudite', conf:nil)
    config = conf || ArgumentError.throw('Conf must have a value')
    if File.exist?(config["logging"]["file"])
      # skip, file exists
    else
      FileUtils.mkpath(File.dirname(File.expand_path(config["logging"]["file"])))
      File.open(config["logging"]["file"],"w+") { |f| f.write("Opening Logfile\n")}
    end
    logger = Logger.new(File.expand_path(config["logging"]["file"]), 'daily')
    logger.level = Logger.const_get config["logging"]["level"]
    logger.progname = pname
    return logger
  end
end