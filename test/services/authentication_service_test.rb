require "test_helper"

class AuthenticationServiceTest < ActiveSupport::TestCase
  def test_valid
    assert AuthenticationService.new.valid?(account: 'jimaop', password: 'asdfqwer', otp: 'bbb')
  end
end
