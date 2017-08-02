require 'sinatra'

# Talk to Facebook
get "/webhook" do
  params['hub.challenge'] if ENV['VERIFY_TOKEN'] == params['hub.verify_token']
end

get "/" do
  "Nothing to see here"
end
# https://termsfeed.com/privacy-policy/b901f8f467d2c308c8177b4c97646d1b
get '/privacy-policy' do
  erb :'privacy-policy.html'
end
