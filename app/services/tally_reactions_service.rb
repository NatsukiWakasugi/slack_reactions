class TallyReactionsService

  def initialize
  end

  def execute
    client = Slack::Web::Client.new
    client.chat_postMessage(channel: '#ใในใ', text: "Hello, Slack bot! #{Time.now}")
  end
end

