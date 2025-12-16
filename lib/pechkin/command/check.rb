require_relative 'list'

module Pechkin
  module Command
    # Check configuration consistency and exit.
    class Check < Base
      def matches?
        options.check?
      end

      def execute
        cfg = configuration # load configuration from disk

        # If list option is also provided, print the channels
        return unless options.list?

        puts "Working dir: #{cfg.working_dir}"
        print_bots(cfg.bots)
        print_channels(cfg.channels)
      end

      private

      def print_bots(bots)
        puts "\nBots:"
        puts format(BOT_ENTRY_FORMAT, 'NAME', 'CONNECTOR', 'TOKEN')
        bots.each do |name, bot|
          puts format(BOT_ENTRY_FORMAT, name, bot.connector, '*hidden*')
        end
      end

      def print_channels(channels)
        puts "\nChannels:"
        puts format(CHAT_ENTRY_FORMAT, 'CHANNEL', 'MESSAGE', 'BOT')
        channels.each do |channel_name, channel|
          channel.messages.each_key do |message_name|
            puts format(CHAT_ENTRY_FORMAT, channel_name, message_name, channel.connector.name)
          end
        end
      end
    end
  end
end
