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
#
# The first four hex digits will represent the server upon which to find the file shard
# the next four hex digits will represent the data folder in which the actual content will
# be saved.  This will support up to 65535 folders in use per server.
#
# Deleting content will be known as purging, and it will be an expensive operation involving
# creating a new file with all of the non-deleted content and renaming them.

require 'logger'
require 'yaml'
require 'murmurhash3'

class FileSystem
  attr_accessor :logger, :config
  def initialize
    @config = EruditeConfig.get_config
    @logger = FileSystem.init_logger(pname:'FileSystem',conf:@config)
    @logger.debug "Config: #{@config}"
    @logger.info 'Filesystem Initialization Complete'
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

  def create_keyspace_dir(ks_name)
    # create keyspace folder under each data folder
    @config['data_folders'].each do |data_folder|
      FileUtils.mkpath(File.expand_path(data_folder) + '/' + hash(ks_name));
    end
  end

  # create new toc file in keyspace

  def create_new_toc_file(keyspace:nil)
    ks = keyspace || ArgumentError.throw('Keyspace can not be nil')
    ks =  hash(ks)
    toc_fn = SecureRandom.uuid + '.toc'
    @config['data_folders'].each do |data_folder|
      File.open(File.expand_path(data_folder) + '/' + ks + '/' + toc_fn, 'w+') {
        @logger.info("Creating TOC file #{toc_fn} for keyspace #{ks} in data folder #{data_folder}")
      }
    end
  end

  # get array of hash sections

  def hash_sections(hash)
    hash.scan(/.{4}/)
  end

  # get data folder by row id

  def find_data_folder(row_id, data_folders)
    h_arr = hash_sections row_id
    data_folders_length = data_folders.length
    token_share_per_folder = (65535 / data_folders_length).round
    data_folders_length.times do |i|
      if h_arr[1].to_i(16) < (token_share_per_folder * (i + 1))
        return data_folders[i]
      end
    end
    data_folders.last
  end

  # create new data file in keyspace, will extrapolate file name from
  # murmur3 row hash.  This will be based on the second 64 bits of the
  # hash string

  def create_new_file_in_keyspace(keyspace:nil, row_id:nil)
    ks = keyspace || ArgumentError.throw('Keyspace must be defined')
    rid = row_id || ArgumentError.throw('You must provide a row ID')
    ks = hash(ks)
    fn = hash_sections(row_id)[1]
    data_folder = find_data_folder(rid, @config['data_folders'])
    File.open(File.expand_path(data_folder) + '/' + ks + '/' + fn + '.db', 'w+') {
      @logger.info("Creating data file #{fn}.db for keyspace #{ks} in data folder #{data_folder}")
    }
  end

  # hash string

  def hash(string)
    MurmurHash3::Native128::murmur3_128_str_hexdigest(string)
  end

  # append to file in keyspace

  def append_to_file_in_keyspace(keyspace:nil,
                                 row_id:nil,
                                 data_stream:nil)
    ks = keyspace || ArgumentError.throw('Keyspace must be defined')
    rid = row_id || ArgumentError.throw('You must provide a row ID')
    ds = data_stream || ArgumentError.throw('You must provide a data stream to append')
    ks = hash(ks)
    fn = hash_sections(row_id)[1]
    data_folder = find_data_folder(row_id, @config['data_folders'])
    file_start_offset = nil
    data_length = nil
    data_f = File.expand_path(data_folder) + '/' + ks + '/' + fn + '.db'
    File.open(data_f, 'a') { |f|
      file_start_offset = File.size(f)
      @logger.info("Appending content to data file #{fn}.db for keyspace #{ks} in data folder #{data_folder}")
      data_length = IO.copy_stream(ds,f)
    }
    append_entry_to_toc(data_file:data_f,
                        data_offset:file_start_offset,
                        data_length:data_length,
                        row_id:rid, keyspace:keyspace)
  end

  # append to toc file

  def append_entry_to_toc(data_file:nil,
                          data_offset:nil,
                          data_length:nil,
                          row_id:nil,
                          keyspace:nil)
    df = data_file || ArgumentError.throw('Data file name must be defined')
    rid = row_id || ArgumentError.throw('You must provide a row ID')
    dof = data_offset || ArgumentError.throw('You must provide a data offset')
    dal = data_length || ArgumentError.throw('You must provide a data length')
    ks = keyspace || ArgumentError.throw('Keyspace must be defined')
    ks = hash(ks)
    data_folder = find_data_folder(row_id, @config['data_folders'])
    toc_file = nil
    Dir.glob('**/*.toc').each do |tc|
      toc_file = tc
    end
    if toc_file.eql?(nil)
      RuntimeError.throw('You can\'t append to the data file without appending to the TOC file')
      return
    end
    File.open(File.expand_path(data_folder) + '/' + ks + '/' + toc_file,'a'){ |file|
      @logger.info("Appending record to toc file #{toc_file} in data folder #{data_folder}")
      file.write "{ 'row_id':'#{rid}','data_file':'#{df}','data_offset':#{dof},'data_length':#{dal} }"
    }
  end

  # seek and read from offset and length in keyspace

  def read_from_offset_in_keyspace(keyspace: nil,
                                   file_name:nil,
                                   offset:0,
                                   length:-1)
    ks = keyspace || ArgumentError.throw('Keyspace must be defined')
    fn = file_name || ArgumentError.throw('File Name must be defined')
    ln = (length > 0 ) || ArgumentError.throw('Length must be provided')
  end

  # Initialize the logger with a config and a pname

  def self.init_logger(pname: 'erudite', conf:nil)
    config = conf || ArgumentError.throw('Conf must have a value')
    if File.exist?(config['logging']['file'])
      # skip, file exists
    else
      FileUtils.mkpath(File.dirname(File.expand_path(config['logging']['file'])))
      File.open(config['logging']['file'],'w+') { |f| f.write('Opening Logfile\n')}
    end
    logger = Logger.new(File.expand_path(config['logging']['file']), 'daily')
    logger.level = Logger.const_get config['logging']['level']
    logger.progname = pname
    return logger
  end
end