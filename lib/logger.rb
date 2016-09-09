# A simple console logger.
module Logger
  # Prints debug text to console with a timestamp
  # and event number.
  #
  # @param [String] string the text to be printed to console
  def info(string = 'ping')
    if @logger
      @events = @events.nil? ? 0 : @events + 1
      puts "INFO [#{@events} - #{Time.now}] #{string}"
    end
  end
end
