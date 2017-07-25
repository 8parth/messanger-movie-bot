require 'facebook/messenger'
require 'httparty' # you should require this one
require 'feedjira'
require 'json' # and that one
# require 'dotenv'
# Dotenv.load


include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])

def wait_for_user_input
  Bot.on :message do |message|
    begin
      message.typing_on
      case message.text.downcase
      when 'hi', 'hello', 'hey' # we use regexp to match parts of strings
        message.reply(text: 'Hey there!')
      when 'got', 'game of thrones'
        xml = HTTParty.get("http://showrss.info/show/262.rss").body
        feed = Feedjira::Feed.parse(xml)
        message.reply(text: "TITLE: #{feed.entries.first.title}\n URL: #{feed.entries.first.url}")
      else
        message.reply(text: 'I know nothing.')
      end
    rescue => e
      puts e.message
    end
  end
end


wait_for_user_input
