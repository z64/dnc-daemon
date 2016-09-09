# Gems
require 'bundler/setup'
require 'yaml'

# Config
# @return [Hash]
CONFIG = YAML.load_file('config.yaml')

# CAM folder
# @return [String]
CAM = CONFIG['dirs']['cam']

# Incoming folder
# @return [String]
INCOMING = CONFIG['dirs']['incoming']

# Outgoing folder
# @return [String]
OUTGOING = CONFIG['dirs']['outgoing']

# How often to poll the filesystem and process
# the file cache.
# @return [String] frequency to poll the filesystem
POLL = CONFIG['poll']

# Components
require_relative 'lib/dnc_daemon.rb'

# Create new Daemon
daemon = DncDaemon.new(logger: true)

# Register polling event
daemon.poll(POLL)

# Keep program running..
loop { ; }
