require 'spec_helper'

module Pechkin
  describe ConfigurationLoaderBots do
    let(:loader) { ConfigurationLoaderBots.new }
    let(:temp_dir) { Dir.mktmpdir }
    let(:bots_dir) { File.join(temp_dir, 'bots') }

    before do
      FileUtils.mkdir_p(bots_dir)
    end

    after do
      FileUtils.rm_rf(temp_dir)
    end

    describe 'environment variable error handling' do
      let(:bot_file) { File.join(bots_dir, 'test-bot.yml') }

      context 'when token_env field is missing from configuration' do
        it 'raises error indicating missing field' do
          File.write(bot_file, { 'connector' => 'slack' }.to_yaml)

          expect { loader.load_from_directory(temp_dir) }
            .to raise_error(ConfigurationError, /token_env.*is missing in configuration/)
        end
      end

      context 'when environment variable specified in token_env is not set' do
        it 'raises error with both env var name and field name' do
          File.write(bot_file, { 'token_env' => 'MY_BOT_TOKEN', 'connector' => 'slack' }.to_yaml)

          # Ensure the environment variable is not set
          ENV.delete('MY_BOT_TOKEN')

          expect { loader.load_from_directory(temp_dir) }
            .to raise_error(ConfigurationError) do |error|
              # Error should include the actual environment variable name
              expect(error.message).to include('MY_BOT_TOKEN')
              # Error should indicate it came from token_env field
              expect(error.message).to include('token_env')
              # Error should include the bot file path
              expect(error.message).to include('test-bot.yml')
              # Error should clearly state it's not set
              expect(error.message).to match(/is not set/)
            end
        end
      end

      context 'when environment variable is set but empty' do
        it 'raises error with both env var name and field name' do
          File.write(bot_file, { 'token_env' => 'EMPTY_TOKEN', 'connector' => 'slack' }.to_yaml)

          ENV['EMPTY_TOKEN'] = '   '

          expect { loader.load_from_directory(temp_dir) }
            .to raise_error(ConfigurationError) do |error|
              expect(error.message).to include('EMPTY_TOKEN')
              expect(error.message).to include('token_env')
              expect(error.message).to include('test-bot.yml')
              expect(error.message).to match(/is not set/)
            end
        ensure
          ENV.delete('EMPTY_TOKEN')
        end
      end

      context 'when environment variable is properly set' do
        it 'loads bot successfully' do
          File.write(bot_file, { 'token_env' => 'VALID_TOKEN', 'connector' => 'slack' }.to_yaml)

          ENV['VALID_TOKEN'] = 'xoxb-valid-token'

          expect { loader.load_from_directory(temp_dir) }.not_to raise_error

          bots = loader.load_from_directory(temp_dir)
          expect(bots['test-bot']).to be_a(Bot)
          expect(bots['test-bot'].token).to eq('xoxb-valid-token')
        ensure
          ENV.delete('VALID_TOKEN')
        end
      end
    end
  end
end
