require "test_helper"

class AuthenticationServiceTest < ActiveSupport::TestCase
  def test_valid
    profile_repo = ProfileRepo.new
    service = AuthenticationService.new(profile_repo: profile_repo, hashie: SHA256Adapter.new, failed_counter: FailedCounterAdapter.new, opt: OtpAdapter.new, notifier: SlackAdapter.new, logger: RailsLogger.new)
    assert service.valid?(account: 'jimaop', password: 'asdfqwer', otp: 'bbb')
  end
end
