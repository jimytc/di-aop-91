require "test_helper"

def substitute(target_module)
  raise 'Not a module' unless target_module.is_a?(Module)

  class_name = "#{target_module}FakeImpl"
  klass = if Object.const_defined?(class_name)
            Object.const_get(class_name)
          else
            Object.const_set(class_name, Class.new do
              include target_module

              target_module.instance_methods.each do |m|
                define_method m do |*_args, **_kwargs|
                end
              end
            end)
          end
  klass.new
end

class AuthenticationServiceTest < ActiveSupport::TestCase
  setup do
    @profile_repo = substitute(ProfileRepoMethods)
    @hashie = substitute(HashieMethods)
    @failed_counter = substitute(FailedCounterMethods)
    @otp = substitute(OtpMethods)
    @notifier = substitute(NotifierMethods)
    @logger = substitute(LoggerMethods)

    @service = AuthenticationService.new(profile_repo: @profile_repo, hashie: @hashie, failed_counter: @failed_counter, otp: @otp, notifier: @notifier, logger: @logger)
  end

  def test_valid
    @failed_counter.expects(:is_locked?).with('jimaop').returns(false)
    @profile_repo.expects(:get_password_from_db).with('jimaop').returns('hashed password')
    @hashie.expects(:hashify).with('123').returns('hashed password')
    @otp.expects(:get_current_otp).with('jimaop').returns('jimaop_123_bbb')

    assert @service.valid?(account: 'jimaop', password: '123', otp: 'jimaop_123_bbb')
  end
end
