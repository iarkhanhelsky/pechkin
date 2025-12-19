require_relative 'spec_helper'

RSpec.describe 'Error handling' do
  let(:config_dir) { File.expand_path('fixtures/config', __dir__) }

  before(:each) do
    # Set required environment variables for test bots
    ENV['TEST_SLACK_BOT_TOKEN'] = 'xoxb-test-slack-token'
    ENV['TEST_TELEGRAM_BOT_TOKEN'] = 'test-telegram-token'

    # Reset WebMock and setup default stubs
    setup_default_stubs

    # Start Pechkin server for this test
    start_pechkin_server(config_dir: config_dir)
  end

  after(:each) do
    # Stop Pechkin server after each test
    stop_pechkin_server
  end

  describe 'Slack API errors' do
    it 'handles Slack API errors gracefully' do
      # Stub an error response from Slack
      slack_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage')
                   .to_return(
                     status: 200,
                     body: { ok: false, error: 'channel_not_found' }.to_json
                   )

      response = post_to_pechkin('/test-slack-channel/hello', { name: 'Test' })

      expect(response.code).to eq('200')
      expect(slack_stub).to have_been_requested
    end

    it 'handles rate limiting errors' do
      slack_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage')
                   .to_return(
                     status: 200,
                     body: { ok: false, error: 'rate_limited' }.to_json
                   )

      response = post_to_pechkin('/test-slack-channel/hello', { name: 'Test' })

      expect(response.code).to eq('200')
      expect(slack_stub).to have_been_requested
    end

    it 'handles invalid auth errors' do
      slack_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage')
                   .to_return(
                     status: 200,
                     body: { ok: false, error: 'invalid_auth' }.to_json
                   )

      response = post_to_pechkin('/test-slack-channel/hello', { name: 'Test' })

      expect(response.code).to eq('200')
      expect(slack_stub).to have_been_requested
    end
  end

  describe 'Telegram API errors' do
    it 'handles Telegram API errors gracefully' do
      telegram_stub = stub_request(:post, %r{https://api\.telegram\.org/bot.*/sendMessage})
                      .to_return(
                        status: 400,
                        body: { ok: false, description: 'Bad Request: chat not found' }.to_json
                      )

      response = post_to_pechkin('/test-telegram-channel/hello', { name: 'Test' })

      expect(response.code).to eq('200')
      expect(telegram_stub).to have_been_requested
    end

    it 'handles bot blocked by user error' do
      telegram_stub = stub_request(:post, %r{https://api\.telegram\.org/bot.*/sendMessage})
                      .to_return(
                        status: 403,
                        body: { ok: false, description: 'Forbidden: bot was blocked by the user' }.to_json
                      )

      response = post_to_pechkin('/test-telegram-channel/hello', { name: 'Test' })

      expect(response.code).to eq('200')
      expect(telegram_stub).to have_been_requested
    end
  end

  describe 'Custom user lookup' do
    it 'can stub custom user lookup responses' do
      # Stub user lookup
      lookup_stub = stub_request(:get, 'https://slack.com/api/users.lookupByEmail')
                    .with(query: hash_including('email' => 'custom@example.com'))
                    .to_return(
                      status: 200,
                      body: {
                        ok: true,
                        user: {
                          id: 'U9999999999',
                          team_id: 'T1234567890',
                          name: 'customuser',
                          profile: {
                            email: 'custom@example.com',
                            real_name: 'Custom User',
                            display_name: 'customuser'
                          }
                        }
                      }.to_json
                    )

      # Stub message send
      message_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage')
                     .with(body: hash_including('channel' => 'U9999999999'))
                     .to_return(status: 200, body: { ok: true }.to_json)

      response = post_to_pechkin(
        '/test-email-channel/hello',
        { name: 'CustomUser', email: 'custom@example.com' }
      )

      expect(response.code).to eq('200')
      expect(lookup_stub).to have_been_requested
      expect(message_stub).to have_been_requested
    end

    it 'handles user not found errors' do
      # Stub must match with query parameters
      lookup_stub = stub_request(:get, %r{https://slack\.com/api/users\.lookupByEmail.*})
                    .to_return(
                      status: 200,
                      body: { ok: false, error: 'users_not_found' }.to_json
                    )

      message_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage')
                     .to_return(status: 200, body: { ok: true }.to_json)

      response = post_to_pechkin(
        '/test-email-channel/hello',
        { name: 'Test', email: 'nonexistent@example.com' }
      )

      # Currently returns 503 when user lookup fails (error accessing nil user data)
      expect(response.code).to eq('503')
      expect(lookup_stub).to have_been_requested
      expect(message_stub).not_to have_been_requested
    end
  end

  describe 'Custom response matching' do
    it 'can stub responses with custom matchers' do
      # Track requests to verify behavior
      error_requests = []
      success_requests = []

      # Stub to capture all requests and respond based on content
      stub_request(:post, 'https://slack.com/api/chat.postMessage')
        .to_return do |request|
          body = JSON.parse(request.body)
          if body['text'].include?('error')
            error_requests << request
            { status: 200, body: { ok: false, error: 'message_rejected' }.to_json }
          else
            success_requests << request
            { status: 200, body: { ok: true }.to_json }
          end
        end

      # This should get the error response
      response1 = post_to_pechkin('/test-slack-channel/hello', { name: 'error' })
      expect(response1.code).to eq('200')

      # This should get the default success response
      response2 = post_to_pechkin('/test-slack-channel/hello', { name: 'success' })
      expect(response2.code).to eq('200')

      expect(error_requests.size).to eq(1)
      expect(success_requests.size).to eq(1)
    end
  end
end
