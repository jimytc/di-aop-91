class AuthenticationService
  FailedTooManyTimesException = Class.new(StandardError)
  AccountNotFound = Class.new(StandardError)

  def valid?(account:, password:, otp:)
    client = RestClient::Resource.new('http://jimytc.com',
                                      headers: {
                                        'Content-Type' => 'application/json',
                                        'Accept' => 'application/json'
                                      })

    is_locked = get_is_locked?(account, client)
    if is_locked
      raise FailedTooManyTimesException, "account #{account}"
    end

    password_from_db = get_password_from_db(account)
    hashed_password = get_hashed_password(password)
    current_otp = get_current_otp(client)

    if password_from_db == hashed_password && otp == current_otp
      client[:api][:failed_counter][:reset].post(account: account)
      true
    else
      increment_failed_count(account, client)
      log_failed_count(account, client)
      notify(account)
      false
    end
  end

  private

  def notify(account)
    message = "#{account} tries to login but failed"
    client = Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])
    client.chat_postMessage(channel: CHANNEL, text: message, as_user: true)
  end

  def log_failed_count(account, client)
    failed_count_response = client[:api][:failed_counter][:failed_count].post(account: account)
    failed_count = JSON.parse(failed_count_response.body, object_class: OpenStruct).count
    Rails.logger.info("account #{account} failed times: #{failed_count}")
  end

  def increment_failed_count(account, client)
    client[:api][:failed_counter][:increment].post(account: account)
  end

  def get_current_otp(client)
    otp_response = client[:api][:authenticate].post(account: user, password: pass)
    JSON.parse(otp_response.body, object_class: OpenStruct).otp
  end

  def get_hashed_password(password)
    Digest::SHA256.hexdigest(password)
  end

  def get_password_from_db(account)
    user_from_db = User.find_by(account: account)
    raise AccountNotFound, "account #{account}" if user_from_db.nil?
    user_from_db.password
  end

  def get_is_locked?(account, client)
    is_locked_response = client[:api][:failed_counter][:is_locked].post(account: account)
    JSON.parse(is_locked_response.body, object_class: OpenStruct).locked
  end
end