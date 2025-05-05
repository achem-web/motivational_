require 'sinatra'
require 'json'
require 'net/http'
require 'uri'

# Replace with your actual Gemini API key
API_KEY = 'AIzaSyBjptcdGVz9N0Ijtudh9QnWVp0XzyWHUug'
GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=#{API_KEY}"

post '/generate-motivation' do
  content_type :json
  request_payload = JSON.parse(request.body.read)

  mood = request_payload['mood']

  # Create a prompt based on the mood
  prompt = "Give me a short motivational quote and a follow-up message for someone feeling #{mood}."

  uri = URI.parse(GEMINI_URL)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
  request.body = {
    contents: [
      {
        parts: [
          {
            text: prompt
          }
        ]
      }
    ]
  }.to_json

  response = http.request(request)

  if response.is_a?(Net::HTTPSuccess)
    ai_response = JSON.parse(response.body)
    ai_text = ai_response['candidates'][0]['content']['parts'][0]['text']

    # Split the response into quote and advice
    quote, *rest = ai_text.split("\n")
    advice = rest.join(" ")

    # Return the response in JSON
    { quote: quote, advice: advice }.to_json
  else
    status 500
    { error: 'Error generating motivation' }.to_json
  end
end

# Start the server
run Sinatra::Application.run!
