class RailsLogger
  include ILogger

  def info(message)
    Rails.logger.info(message)
  end
end
