RSpec.describe 'HTTP endpoints' do
  let(:config_dir) { File.expand_path('fixtures/config', __dir__) }

  before(:each) do
    # Set required environment variables for test bots
    ENV['TEST_SLACK_BOT_TOKEN'] = 'xoxb-test-slack-token'
    ENV['TEST_TELEGRAM_BOT_TOKEN'] = 'test-telegram-token'

    # Setup default WebMock stubs
    setup_default_stubs

    # Start Pechkin server for this test
    start_pechkin_server(config_dir: config_dir)
  end

  after(:each) do
    # Stop Pechkin server after each test
    stop_pechkin_server
  end

  describe 'GET /favicon.ico' do
    it 'returns 405 Method Not Allowed' do
      get '/favicon.ico'

      expect(last_response.status).to eq(405)
      expect(last_response.body).to eq('{"message":"Method Not Allowed"}')
    end
  end

  describe 'GET /health' do
    it 'returns 200 with health status' do
      get '/health'

      expect(last_response.status).to eq(200)
      expect(last_response.headers['Content-Type']).to include('application/json')

      body = JSON.parse(last_response.body)
      expect(body['status']).to eq('ok')
      expect(body['message']).to eq('Pechkin is running')
      expect(body['version']).to eq(Pechkin::Version.version_string)
    end

    it 'returns health status for POST requests as well' do
      post '/health', '{}', 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(200)
      body = JSON.parse(last_response.body)
      expect(body['status']).to eq('ok')
    end
  end
end
