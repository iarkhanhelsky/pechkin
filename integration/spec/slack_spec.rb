RSpec.describe 'Slack integration' do
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
    it 'sends a simple message to Slack channel' do
      slack_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage')
                   .with(
                     body: hash_including('channel' => '#test-channel', 'text' => 'Hello, World!'),
                     headers: { 'Authorization' => 'Bearer xoxb-test-slack-token' }
                   )
                   .to_return(status: 200, body: { ok: true }.to_json)

      response = post_to_pechkin('/test-slack-channel/hello', { name: 'World' })

      expect(response.code).to eq('200')
      expect(slack_stub).to have_been_requested
    end

    it 'includes authorization header in Slack requests' do
      slack_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage')
                   .with(headers: { 'Authorization' => 'Bearer xoxb-test-slack-token' })
                   .to_return(status: 200, body: { ok: true }.to_json)

      response = post_to_pechkin('/test-slack-channel/hello', { name: 'Test' })

      expect(response.code).to eq('200')
      expect(slack_stub).to have_been_requested
    end

    it 'returns error for non-existent channel' do
      response = post_to_pechkin('/non-existent-channel/hello', { name: 'World' })

      expect(response.code).to eq('404')
      body = JSON.parse(response.body)
      expect(body['status']).to eq('error')
    end

    it 'returns error for non-existent message' do
      response = post_to_pechkin('/test-slack-channel/non-existent', { name: 'World' })

      expect(response.code).to eq('404')
      body = JSON.parse(response.body)
      expect(body['status']).to eq('error')
    end
  end

  describe 'email-based user resolution' do
    it 'resolves Slack user by email and sends DM' do
      # Stub user lookup
      lookup_stub = stub_request(:get, 'https://slack.com/api/users.lookupByEmail')
                    .with(query: hash_including('email' => 'test@example.com'))
                    .to_return(
                      status: 200,
                      body: {
                        ok: true,
                        user: {
                          id: 'U1234567890',
                          team_id: 'T1234567890',
                          name: 'testuser',
                          profile: { email: 'test@example.com' }
                        }
                      }.to_json
                    )

      # Stub message send
      message_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage')
                     .with(
                       body: hash_including('channel' => 'U1234567890', 'text' => 'Hello, EmailUser!')
                     )
                     .to_return(status: 200, body: { ok: true }.to_json)

      response = post_to_pechkin(
        '/test-email-channel/hello',
        { name: 'EmailUser', email: 'test@example.com' }
      )

      expect(response.code).to eq('200')
      expect(lookup_stub).to have_been_requested
      expect(message_stub).to have_been_requested
    end
  end
end
