class AuthenticationService
  attr_reader :profile_repo, :hashie, :failed_counter, :otp, :notifier, :logger

  def initialize(profile_repo: ProfileRepo.new, hashie: SHA256Adapter.new, failed_counter: FailedCounterAdapter.new, opt: OtpAdapter.new, notifier: SlackAdapter.new, logger: RailsLogger.new)
    @profile_repo = profile_repo
    @hashie = hashie
    @failed_counter = failed_counter
    @otp = opt
    @notifier = notifier
    @logger = logger
  end

  def valid?(account:, password:, otp:)
    is_locked = failed_counter.is_locked?(account)
    if is_locked
      raise FailedTooManyTimesError, "account #{account}"
    end

    password_from_db = profile_repo.get_password_from_db(account)
    hashed_password = hashie.hashify(password)
    current_otp = otp.get_current_otp(account)

    if password_from_db == hashed_password && otp == current_otp
      failed_counter.reset(account)
      true
    else
      failed_counter.increment_failed_count(account)
      failed_count = failed_counter.current_failed_count(account)
      logger.info("account #{account} failed times: #{failed_count}")
      notifier.notify(account, "#{account} tries to login but failed")
      false
    end
  end
end
