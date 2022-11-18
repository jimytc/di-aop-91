class HashifyTextService
  attr_reader :text

  def initialize(text:)
    @text = text
  end

  def call
    Digest::SHA256.hexdigest(text)
  end
end