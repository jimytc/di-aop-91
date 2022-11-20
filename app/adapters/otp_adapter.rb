class OtpAdapter
  include OtpMethods
  attr_reader :client

  def initialize
    @client = RestClient::Resource.new('https://otp.jimytc.com',
                                       headers: {
                                         'Content-Type' => 'application/json',
                                         'Accept' => 'application/json'
                                       })
  end

  def get_current_otp(account)
    otp_response = client[:api].post(account: account)
    JSON.parse(otp_response.body, object_class: OpenStruct).otp
  end
end
