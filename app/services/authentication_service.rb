class AuthenticationService
  attr_reader :profile_repo, :hash_adapter, :failed_counter_adapter, :otp_adapter, :slack_notifier, :rails_logger_adapter

  def initialize
    @profile_repo = ProfileRepo.new
    @hash_adapter = SHA256Adapter.new
    @failed_counter_adapter = FailedCounterAdapter.new
    @otp_adapter = OtpAdapter.new
    @slack_notifier = SlackAdapter.new
    @rails_logger_adapter = RailsLogger.new
  end

  def valid?(account:, password:, otp:)
    is_locked = failed_counter_adapter.is_locked?(account)
    if is_locked
      raise FailedTooManyTimesException, "account #{account}"
    end

    password_from_db = profile_repo.get_password_from_db(account)
    hashed_password = hash_adapter.hashify(password)
    current_otp = otp_adapter.get_current_otp(account)

    if password_from_db == hashed_password && otp == current_otp
      failed_counter_adapter.reset(account)
      true
    else
      failed_counter_adapter.increment_failed_count(account)
      failed_count = failed_counter_adapter.current_failed_count(account)
      rails_logger_adapter.info("account #{account} failed times: #{failed_count}")
      slack_notifier.notify(account, "#{account} tries to login but failed")
      false
    end
  end

  FailedTooManyTimesException = Class.new(StandardError)
end
