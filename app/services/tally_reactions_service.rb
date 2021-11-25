require 'slack'


Slack.configure do |config|
  config.token = 'xoxb-646437706976-2768305551106-6QzP5z7VdNBgUfHxakr2Silr'
  config.token = ENV['SLACK_API_TOKEN']
end

client = Slack::Web::Client.new
client.auth_test
client.chat_postMessage(channel: '#テスト', text: 'Hello, Slack bot!')