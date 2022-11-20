class RailsLogger
  include LoggerMethods

  def info(message)
    Rails.logger.info(message)
  end
end
