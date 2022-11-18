class AuthenticationService
  def valid?(account:, password:, otp:)
    user_from_db = User.find_by(account: account)
    return false unless user_from_db
    password_from_db = user_from_db.password

    password_from_input = Digest::SHA256.hexdigest(password)

    current_otp = begin
                    response = Typhoeus.post(AUTH_URL, body: { username: user, password: pass })
                    return nil unless response.success?

                    JSON.parse(response.body, object_class: OpenStruct).otp
                  end

    return false unless current_otp

    password_from_db == password_from_input && otp == current_otp
  end
end