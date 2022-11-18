class SlackMessageService
  CHANNEL = '#91-di-aop'

  attr_reader :message

  def self.call(message: '')
    new(message: message).call
  end

  def initialize(message:)
    @message = message
  end

  def call
    client.chat_postMessage(channel: CHANNEL, text: message, as_user: true)
  end

  private

  def client
    Slack::Web::Client.new
  end
end