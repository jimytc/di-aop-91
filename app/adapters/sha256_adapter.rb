class SHA256Adapter
  include HashieMethods

  def hashify(password)
    Digest::SHA256.hexdigest(password)
  end
end
