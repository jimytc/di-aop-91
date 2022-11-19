class ProfileRepo
  include IProfileRepo

  AccountNotFound = Class.new(StandardError)

  def get_password_from_db(account)
    user_from_db = User.find_by(account: account)
    raise AccountNotFound, "account #{account}" if user_from_db.nil?
    user_from_db.password
  end
end