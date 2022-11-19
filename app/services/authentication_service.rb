class AuthenticationService
  FailedTooManyTimesException = Class.new(StandardError)
  AccountNotFound = Class.new(StandardError)

  def valid?(account:, password:, otp:)
    client = RestClient::Resource.new('http://jimytc.com',
                                      headers: {
                                        'Content-Type' => 'application/json',
                                        'Accept' => 'application/json'
                                      })

    is_locked_response = client[:api][:failed_counter][:is_locked].post(account: account)
    is_locked = JSON.parse(is_locked_response.body, object_class: OpenStruct).locked

    if is_locked
      raise FailedTooManyTimesException, "account #{account}"
    end

    # Get Password
    user_from_db = User.find_by(account: account)
    if user_from_db.nil?
      raise AccountNotFound, "account #{account}"
    end
    password_from_db = user_from_db.password

    # Hash
    password_from_input = Digest::SHA256.hexdigest(password)

    # Get Otp
    otp_response = client[:api][:authenticate].post(account: user, password: pass)
    current_otp = JSON.parse(otp_response.body, object_class: OpenStruct).otp

    # Compare
    if password_from_db == password_from_input && otp == current_otp
      client[:api][:failed_counter][:reset].post(account: account)

      true
    else
      client[:api][:failed_counter][:increment].post(account: account)

      failed_count_response = client[:api][:failed_counter][:failed_count].post(account: account)
      failed_count = JSON.parse(failed_count_response.body, object_class: OpenStruct).count
      Rails.logger.info("account #{account} failed times: #{failed_count}")

      message = "#{account} tries to login but failed"
      client = Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])
      client.chat_postMessage(channel: CHANNEL, text: message, as_user: true)

      false
    end
  end
end