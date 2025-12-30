require 'spec_helper'

module Pechkin
  module Command
    describe List do
      let(:stdout) { StringIO.new }
      let(:stderr) { StringIO.new }
      let(:options) { OpenStruct.new(list?: true, config_dir: '/tmp') }
      let(:cmd) { List.new(options, stdout: stdout, stderr: stderr) }

      let(:bot_token) { 'xoxb-secret-token-12345' }
      let(:bot) { Bot.new(token: bot_token, connector: 'slack', name: 'test-bot') }
      let(:bots) { { 'test-bot' => bot } }
      let(:channels) { {} }
      let(:configuration) do
        config = double('Configuration')
        allow(config).to receive(:working_dir).and_return('/tmp')
        allow(config).to receive(:bots).and_return(bots)
        allow(config).to receive(:channels).and_return(channels)
        config
      end

      before do
        allow(cmd).to receive(:configuration).and_return(configuration)
      end

      it 'hides bot tokens in output' do
        cmd.execute

        expect(stdout.string).to include('*hidden*')
        expect(stdout.string).not_to include(bot_token)
      end

      it 'shows bot name and connector' do
        cmd.execute

        expect(stdout.string).to include('test-bot')
        expect(stdout.string).to include('slack')
      end
    end

    describe Check do
      let(:stdout) { StringIO.new }
      let(:stderr) { StringIO.new }
      let(:options) { OpenStruct.new(check?: true, list?: true, config_dir: '/tmp') }
      let(:cmd) { Check.new(options, stdout: stdout, stderr: stderr) }

      let(:bot_token) { 'xoxb-secret-token-12345' }
      let(:bot) { Bot.new(token: bot_token, connector: 'slack', name: 'test-bot') }
      let(:bots) { { 'test-bot' => bot } }
      let(:channels) { {} }
      let(:configuration) do
        config = double('Configuration')
        allow(config).to receive(:working_dir).and_return('/tmp')
        allow(config).to receive(:bots).and_return(bots)
        allow(config).to receive(:channels).and_return(channels)
        config
      end

      before do
        allow(cmd).to receive(:configuration).and_return(configuration)
      end

      it 'hides bot tokens in output' do
        cmd.execute

        expect(stdout.string).to include('*hidden*')
        expect(stdout.string).not_to include(bot_token)
      end

      it 'shows bot name and connector' do
        cmd.execute

        expect(stdout.string).to include('test-bot')
        expect(stdout.string).to include('slack')
      end
    end
  end
end
