class SHA256Adapter
  def hashify(password)
    Digest::SHA256.hexdigest(password)
  end
end
