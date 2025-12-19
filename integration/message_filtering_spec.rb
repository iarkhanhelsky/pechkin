require_relative 'spec_helper'

RSpec.describe 'Message filtering' do
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

  it 'sends message when filter allows it' do
    slack_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage')
                 .with(body: hash_including('text' => 'Hello, Filtered!'))
                 .to_return(status: 200, body: { ok: true }.to_json)

    response = post_to_pechkin(
      '/test-slack-channel/with-filter',
      { name: 'Filtered', branch: 'master' }
    )

    expect(response.code).to eq('200')
    expect(slack_stub).to have_been_requested.times(1)
  end

  it 'skips message when filter forbids it' do
    slack_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage')
                 .to_return(status: 200, body: { ok: true }.to_json)

    response = post_to_pechkin(
      '/test-slack-channel/with-filter',
      { name: 'Filtered', branch: 'develop' }
    )

    expect(response.code).to eq('200')
    expect(slack_stub).not_to have_been_requested
  end
end
