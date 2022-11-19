class SHA256Adapter
  include IHashie

  def hashify(password)
    Digest::SHA256.hexdigest(password)
  end
end
