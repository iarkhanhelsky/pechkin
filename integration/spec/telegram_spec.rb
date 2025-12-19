RSpec.describe 'Telegram integration' do
  let(:config_dir) { File.expand_path('fixtures/config', __dir__) }

  before(:each) do
    # Set required environment variables for test bots
    ENV['TEST_SLACK_BOT_TOKEN'] = 'xoxb-test-slack-token'
    ENV['TEST_TELEGRAM_BOT_TOKEN'] = 'test-telegram-token'

    # Setup default WebMock stubs and clear request history
    setup_default_stubs

    # Start Pechkin server for this test
    start_pechkin_server(config_dir: config_dir)
  end

  after(:each) do
    # Stop Pechkin server after each test
    stop_pechkin_server
  end

  describe 'message sending' do
    it 'sends a message to Telegram chat' do
      telegram_stub = stub_request(:post, %r{https://api\.telegram\.org/bot.*-telegram-token/sendMessage})
                      .with(
                        body: hash_including(
                          'text' => 'Hello, Telegram!',
                          'chat_id' => '123456789',
                          'parse_mode' => 'markdown'
                        )
                      )
                      .to_return(
                        status: 200,
                        body: {
                          ok: true,
                          result: {
                            message_id: 123,
                            chat: { id: 123_456 },
                            text: 'Hello, Telegram!'
                          }
                        }.to_json
                      )

      response = post_to_pechkin('/test-telegram-channel/hello', { name: 'Telegram' })

      expect(response.code).to eq('200')
      expect(telegram_stub).to have_been_requested
    end
  end
end
