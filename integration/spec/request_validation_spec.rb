RSpec.describe 'Request validation' do
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

  it 'handles empty request body gracefully' do
    # Use Rack::Test directly for raw requests
    post '/test-slack-channel/hello', '', { 'CONTENT_TYPE' => 'application/json' }

    # Should not crash, may return error or use empty data
    expect([503]).to include(last_response.status)
  end

  it 'handles invalid JSON gracefully' do
    # Use Rack::Test directly for raw requests
    post '/test-slack-channel/hello', 'not valid json', { 'CONTENT_TYPE' => 'application/json' }

    # Should return an error
    expect([503]).to include(last_response.status)
  end
end
