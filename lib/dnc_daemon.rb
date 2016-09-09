# Gems
require 'rufus-scheduler'

# Modules
require_relative 'regex'
require_relative 'cam_file'
require_relative 'logger'

# DncDaemon
class DncDaemon
  include Logger

  # Scheduler
  SCHEDULER = Rufus::Scheduler.new

  # A list of file paths in INCOMING
  # @return [Array<String>]
  attr_reader :incoming

  # A list of file paths in OUTGOING
  # @return [Array<String>]
  attr_reader :outgoing

  # A list of file paths in CAM
  # @return [Array<String>]
  attr_reader :cam

  # Initializes a new DncDaemon
  #
  # @param attributes [Hash] the attributes to create a new daemon with
  # @option attributes [anything] :logger enables verbose logging if defined
  def initialize(attributes = {})
    # Configure logger
    @logger = attributes[:logger] if attributes[:logger]
    info('new daemon created')

    # Initializes instance vars
    @cam      = []
    @incoming = []
    @outgoing = []
  end

  # Updates file listings. If a time string is specified,
  # then it will register a new polling event with SCHEDULER
  #
  # @param [String] time how often to poll each dir
  def poll(time)
    SCHEDULER.every time do
      find_updates
      # process_cache!
      info("(cam: #{cam.count} out: #{outgoing.count} in: #{incoming.count})")
    end
    SCHEDULER.jobs.last.call
    info("polling every: #{time}")
  end

  # Scans each dir, checks for differences, then
  # updates the internal file list instance variables.
  def find_updates
    updated_cam = scan_files(CAM)
    cam_diff = updated_files(cam, updated_cam)
    @cam = updated_cam unless cam_diff.empty?

    updated_incoming = scan_files(INCOMING)
    incoming_diff = updated_files(incoming, updated_incoming)
    @incoming = updated_incoming unless incoming_diff.empty?

    updated_outgoing = scan_files(OUTGOING)
    outgoing_diff = updated_files(outgoing, updated_outgoing)
    @outgoing = updated_outgoing unless outgoing_diff.empty?
  end

  # Compares two lists of files, and returns what files are new
  # or were removed.
  #
  # @param [Array<String>] a a list of file paths
  # @param [Array<String>] b a list of file paths
  # @return [Array<String>] new or deleted entries
  def updated_files(a, b)
    diff = a - b | b - a
    unless diff.empty?
      info("updated: #{diff.inspect} (#{diff.count}"\
      	   " updated, #{b.count} total)")
    end
    diff
  end

  # Scans a directory for CAM files.
  #
  # @param [String] dir the directory to search
  # @return [Array<String>] a list of discovered file paths matching CAM regex
  def scan_files(dir)
    Dir.glob(dir).select { |fn| fn[Regex::CAMFILE] }
  end

  # Takes a CamFile and checks to see if we have a matching path cached
  # in incoming or outgoing. It will then set the CamFiles incoming_file
  # and outgoing_file attribute File handlers if possible.
  #
  # @param camfile [CamFile] an existing CamFile with an open file handle
  def match_file!(camfile)
    info("matching cam file #{camfile.name}")
    begin
      incoming_file = File.open(incoming.find { |f| f.include? camfile.name })
      camfile.incoming_file = incoming_file
      info("matched incoming for #{camfile.name}")
    rescue
      info("no incoming file found for #{camfile.name}")
    end

    begin
      outgoing_file = File.open(outgoing.find { |f| f.include? camfile.name })
      camfile.outgoing_file = outgoing_file
      info("matched outgoing for #{camfile.name}")
    rescue
      info("no outgoing file found for #{camfile.name}")
    end
  end

  # Processes the internal cache of CamFiles, and archives them with
  # CamFile#mv.
  def process_cache!
    cam.each do |path|
      file = CamFile.new(path)
      match_file!(file)
      file.mv
    end
  end
end
