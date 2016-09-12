# Gems
require 'digest/md5'
require 'fileutils'

# A pristine (master) CAM file
class CamFile
  # The file handler of the master CAM file.
  # @return [File]
  attr_reader :file

  # The file handler of a matching program in INCOMING.
  # @return [File]
  attr_accessor :incoming_file

  # The file handler of a matching program in OUTGOING.
  # @return [File]
  attr_accessor :outgoing_file

  # The base name of the file.
  # @return [String]
  attr_reader :name

  def initialize(file)
    @file = File.open(file)
    @name = File.basename(@file)
  rescue => e
    raise e.inspect
  end

  # Uses an MD5 digest to check if the incoming_file is different
  # from the CamFile.
  #
  # @return [true|false] whether the file has changed
  def changed?
    unless incoming_file.nil?
      @file_contents     ||= file.read
      @incoming_contents ||= incoming_file.read
      @file_contents != @incoming_contents
    else
      nil
    end
  end

  # Returns a hash of CamFile properties.
  #
  # @return [Hash]
  def to_hash
    hash = {}
    hash[:cam] = file.path
    unless incoming_file.nil?
      hash[:incoming] = incoming_file.path
      hash[:changed] = changed?
    end
    hash[:outgoing] = outgoing_file.path unless outgoing_file.nil?
    hash
  end

  # Creates daemon folders in the CAM directory
  # if they don't already exist.
  #
  # @return [Hash<String>] hash of paths, either existing or created
  def daemon_folders?
    time = Time.now.strftime('%Y-%m-%d')
    folders = [
      "#{File.dirname(file.path)}/daemon-incoming #{time}",
      "#{File.dirname(file.path)}/daemon-outgoing #{time}"
    ]
    folders = FileUtils.mkdir_p(folders)
    return { incoming: folders.first, outgoing: folders.last }
  end

  # Moves files from INCOMING and OUTGOING into daemon_folders? respectively.
  def mv
    unless incoming_file.nil?
      puts incoming_file.inspect #=> #<File..
      begin
        incoming_file.close
        FileUtils.mv(incoming_file.path, daemon_folders?[:incoming])
      rescue => e
        puts e
      end
    end

    unless outgoing_file.nil?
      begin
        outgoing_file.close
        FileUtils.mv(outgoing_file.path, daemon_folders?[:outgoing])
      rescue => e
        puts e
      end
    end
  end

  private :daemon_folders?
end
