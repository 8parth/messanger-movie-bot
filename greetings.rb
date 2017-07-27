class Greetings
  def self.enable
    # Set greeting (for first contact)
    # Facebook::Messenger::Thread.set({
    #   setting_type: 'greeting',
    #   greeting: {
    #     text: 'Welcome! I will help you find TV show episodes.'
    #   },
    #   get_started: {
    #     payload: 'INITIATE'
    #   }
    # }, access_token: ENV['ACCESS_TOKEN'])
  end
end
