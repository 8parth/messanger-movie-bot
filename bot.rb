require 'facebook/messenger'
require 'httparty' # you should require this one
require 'feedjira'
require 'json' # and that one
require_relative 'shows'
# require 'dotenv'
# Dotenv.load


include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])

def get_buttons(entries)
  entries.map do |entry|
    {
      type: 'web_url',
      url: entry.url,
      title: entry.title
    }
  end
end
def get_button(entry)
  {
    type: 'web_url',
    url: entry.url,
    title: entry.title
  }
end

def wait_for_user_input
  Bot.on :message do |message|
    begin
      message.typing_on
      case message.text.downcase
      when 'hi', 'hello', 'hey' # we use regexp to match parts of strings
        message.reply(text: 'Hey there!')
      else
        if message.text.start_with?('find')
          str = message.text.sub('find', '').lstrip
          show_url = Shows.search_from_shows(str)
          if show_url.nil?
            text = 'Show Not Found!'
            message.reply(text: text)
          else
            xml = HTTParty.get(show_url).body
            entries = Feedjira::Feed.parse(xml).entries
            if entries.nil?
              message.reply(text: 'Could not find anything! Please find some other show')
            else
              message.reply(text:"Found #{entries.length} links... ")
              entries.first(5).each do |entry|
                message.reply(
                  text: "TITLE: #{entry.title}\nURL: #{entry.url}"
                )
              end
              message.reply(text: 'Hope you found right links!')
            end
            # message.reply(text: "TITLE: #{feed.entries.first.title}\n URL: #{feed.entries.first.url}")
          end
        else
          message.reply(text: 'I know nothing!')
        end
      end
    rescue => e
      puts e.message
      message.reply(text: e.message)
      message.reply(text: 'Sorry, something bad happened!')
    end
  end
end

wait_for_user_input
