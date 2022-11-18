class ObtainOtpService
  AUTH_URL = 'http://localhost:4567/authenticate'

  UnableToAuthenticate = Class.new(StandardError)

  attr_reader :user, :pass

  def initialize(user:, pass:)
    @user = user
    @pass = pass
  end

  def call
    response = Typhoeus.post(AUTH_URL, body: { username: user, password: pass })
    raise UnableToAuthenticate, "Cannot authenticate #{response.code}" unless response.success?

    JSON.parse(response.body, object_class: OpenStruct)
  end
end