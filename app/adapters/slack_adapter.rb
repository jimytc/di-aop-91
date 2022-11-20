class SlackAdapter
  include NotifierMethods

  attr_reader :client

  def initialize
    @client = Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])
  end

  def notify(account, message)
    puts "Notify account #{account}"
    client.chat_postMessage(channel: '#91-di-aop', text: message, as_user: true)
  end
end
