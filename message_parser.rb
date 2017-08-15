class MessageParser
  TYPES = ['GREETING', 'ABOUT_SELF', 'FIND_SHOW', 'FIND_SHOW_EMPTY'].freeze
  attr_reader :message, :first_word, :message_without_first_letter_, :words, :type

  def initialize(message)
    @message = message.downcase.strip
    @words = message.split(/[^[[:word:]]]+/)
    @first_word = words[0]
  end

  def message_without_first_letter
    @message_without_first_letter_ ||= words[1..words.length].join(' ')
  end

  def message_type
    case first_word
    when 'hi', 'hello', 'hey'
      @type = 'GREETING'
    when 'find'
      @type = message_without_first_letter.empty? ? 'FIND_SHOW_EMPTY' : 'FIND_SHOW'
    when 'tell'
      if words.include?('about') && (words.include?('you') || words.include?('yourself'))
        @type = 'ABOUT_SELF'
      else
        @type = 'AMBIGIOUS'
      end
    when 'how'
      if message_without_first_letter == 'are you?'
        @type = 'HOW_ARE_YOU'
      else
        @type = 'AMBIGIOUS'
      end
    when 'who'
      if words.include?('created')
        if words.last.gsub(/\?.*/, '') == 'you'
          @type = 'ABOUT_CREATOR'
        elsif words.last.gsub(/\?.*/, '') == 'logo'
          @type = 'ABOUT_LOGO'
        else
          @type = 'AMBIGIOUS'
        end
      else
        @type = 'AMBIGIOUS'
      end
    else
      @type = 'AMBIGIOUS'
    end
    type
  end
end
