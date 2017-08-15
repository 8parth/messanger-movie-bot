require 'facebook/messenger'
require 'httparty' # you should require this one
require 'feedjira'
require 'json' # and that one
require_relative 'shows'
require_relative 'greetings'
require_relative 'message_parser'
# require 'dotenv'
# Dotenv.load

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])

Facebook::Messenger::Profile.set({
  greeting: [
    {
      locale: 'default',
      text: 'Welcome! I will help you find TV show episodes.'
    }
  ],
  get_started: {
    payload: 'INITIATE'
  }
}, access_token: ENV['ACCESS_TOKEN'])

Bot.on :postback do |postback|
  sender_id = postback.sender['id']
  case postback.payload
  when 'INITIATE'
    say(sender_id, 'Type in \'find arrow\' and you will recieve information of last two episodes!')
  end
end

# helper function to send messages declaratively and directly
def say(recipient_id, text, quick_replies = nil)
  message_options = {
    recipient: { id: recipient_id },
    message: { text: text }
  }

  Bot.deliver(message_options, access_token: ENV['ACCESS_TOKEN'])
end

def create_about_me_button
  {
      attachment: {
      type: "template",
      payload: {
        template_type: "button",
        text: "Hi! I created the bot. Here are the ways you can connect with me.",
        buttons: [
          {
            type: "web_url",
            url: "http://parthrmodi.com/blog/about/",
            title: "Blog | About Me"
          },
          {
            type: "web_url",
            url: "https://www.facebook.com/parth.modi.359",
            title: "Parth Modi's Facebook Profile"
          }
        ]
      }
    }
  }
end

def create_about_logo_button
  {
    attachment:{
      type: "template",
      payload: {
        template_type: "button",
        text: "Hi! I created logo of the Movie Bot.",
        buttons: [
          {
            type: "web_url",
            url: "https://www.facebook.com/rishi.au19",
            title: "Rishi Dave's Facebook Profile"
          }
        ]
      }
    }
  }
end

def send_show_response(message, show_url)
  if show_url.nil?
    text = 'Show Not Found!'
    message.reply(text: text)
  else
    xml = HTTParty.get(show_url).body
    entries = Feedjira::Feed.parse(xml).entries.first(2)
    if entries.nil?
      message.reply(text: 'Could not find anything! Please find some other show.')
    else
      entries.each do |entry|
        message.reply(text: "TITLE: #{entry.title}")
      end
      # message.reply(text: 'Hope you found right links!')
    end
  end
end

def wait_for_user_input
  Bot.on :message do |message|
    begin
      message.typing_on
      parser = MessageParser.new(message.text)

      case parser.message_type
      when 'GREETING'
        message.reply(text: 'Hey there!')
      when 'ABOUT_SELF'
        message.reply(text: 'I am learning about TV shows and movies.')
        message.reply(text: 'Just type find name-of-the-show, and I will send last episode\'s name.')
      when 'ABOUT_CREATOR'
        message.reply(create_about_me_button)
      when 'ABOUT_LOGO'
        message.reply(create_about_logo_button)
      when 'FIND_SHOW'
        show_url = Shows.search_from_shows(parser.message_without_first_letter)
        send_show_response(message, show_url)
      when 'FIND_SHOW_EMPTY'
        message.reply(text: 'Show not found!')
      when 'HOW_ARE_YOU'
        message.reply('I am fine, thanks for asking!')
        message.reply('Hopefully your day was good! However, I am not comfertable doing small talk. Let me show how I can help you.')
        message.reply('Just type find name-of-the-show, and I will send name of last episode for that TV show.')
      else
        message.reply(text: 'I know nothing!')
      end
    rescue => e
      puts e.message
      message.reply(text: e.message)
      message.reply(text: 'Sorry, something bad happened!')
    end
  end
end

wait_for_user_input
