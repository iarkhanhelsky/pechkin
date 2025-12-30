require 'ostruct'
require 'stringio'

RSpec.describe 'CLI send command integration' do
  let(:config_dir) { File.expand_path('fixtures/config', __dir__) }

  before(:each) do
    # Set required environment variables for test bots
    ENV['TEST_SLACK_BOT_TOKEN'] = 'xoxb-test-slack-token'
    ENV['TEST_TELEGRAM_BOT_TOKEN'] = 'test-telegram-token'

    # Setup default WebMock stubs
    setup_default_stubs
  end

  after(:each) do
    # Clean up
    stop_pechkin_server if respond_to?(:stop_pechkin_server)
  end

  describe '--send command' do
    it 'successfully sends message via CLI with correct handler.handle signature' do
      # Stub Slack API call
      slack_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage')
                   .with(
                     body: hash_including('channel' => '#test-channel', 'text' => 'Hello, World!'),
                     headers: { 'Authorization' => 'Bearer xoxb-test-slack-token' }
                   )
                   .to_return(status: 200, body: { ok: true }.to_json)

      # Create SendData command with proper options (simulating CLI --send flag)
      options = OpenStruct.new(
        send_data: 'test-slack-channel/hello',
        data: '{"name": "World"}',
        preview: false,
        config_dir: config_dir
      )

      stdout = StringIO.new
      stderr = StringIO.new
      cmd = Pechkin::Command::SendData.new(options, stdout: stdout, stderr: stderr)

      # Execute the command
      cmd.execute

      # Verify that the command output indicates successful message sending
      # The command outputs each result with " * #{result.inspect}"
      output = stdout.string
      expect(output).to include('* {')
      expect(output).to match(/channel.*#test-channel/)
      expect(output).to match(/code.*200/)

      # Verify that the Slack API was called (confirming handler.handle executed successfully)
      expect(slack_stub).to have_been_requested
    end

    it 'returns error for non-existent channel' do
      options = OpenStruct.new(
        send_data: 'non-existent-channel/hello',
        data: '{"name": "World"}',
        preview: false,
        config_dir: config_dir
      )

      stdout = StringIO.new
      stderr = StringIO.new
      cmd = Pechkin::Command::SendData.new(options, stdout: stdout, stderr: stderr)

      expect { cmd.execute }.to raise_error(StandardError, %r{non-existent-channel/hello not found})
    end

    it 'returns error for non-existent message' do
      options = OpenStruct.new(
        send_data: 'test-slack-channel/non-existent',
        data: '{"name": "World"}',
        preview: false,
        config_dir: config_dir
      )

      stdout = StringIO.new
      stderr = StringIO.new
      cmd = Pechkin::Command::SendData.new(options, stdout: stdout, stderr: stderr)

      expect { cmd.execute }.to raise_error(StandardError, %r{test-slack-channel/non-existent not found})
    end

    it 'supports preview mode' do
      options = OpenStruct.new(
        send_data: 'test-slack-channel/hello',
        data: '{"name": "World"}',
        preview: true,
        config_dir: config_dir
      )

      stdout = StringIO.new
      stderr = StringIO.new
      cmd = Pechkin::Command::SendData.new(options, stdout: stdout, stderr: stderr)

      cmd.execute

      # Preview mode should output the rendered message without sending
      output = stdout.string
      expect(output).to include('Hello, World!')
      expect(output).to include('Connector: Pechkin::Connector::Slack')
      expect(output).to include('#test-channel')
    end
  end
end
