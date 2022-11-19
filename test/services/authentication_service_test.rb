require "test_helper"

class AuthenticationServiceTest < ActiveSupport::TestCase
  def test_valid
    service = AuthenticationService.new
    assert service.valid?(account: 'jimaop', password: 'asdfqwer', otp: 'bbb')
  end
end
