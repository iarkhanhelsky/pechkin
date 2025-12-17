module Pechkin
  module Command
    BOT_ENTRY_FORMAT = '  %-25s   %-10s   %-60s '.freeze
    CHAT_ENTRY_FORMAT = '  %-40s   %-40s   %-30s '.freeze

    # List channels configuration
    class List < Base
      def matches?
        options.list?
      end

      def execute
        cfg = configuration

        puts "Working dir: #{cfg.working_dir}"
        print_bots(cfg.bots)
        print_channels(cfg.channels)
      end

      private

      def print_bots(bots)
        puts "\nBots:"
        puts format(BOT_ENTRY_FORMAT, 'NAME', 'CONNECTOR', 'TOKEN')
        bots.each do |name, bot|
          puts format(BOT_ENTRY_FORMAT, name, bot.connector, bot.token)
        end
      end

      def print_channels(channels)
        puts "\nChannels:"
        puts format(CHAT_ENTRY_FORMAT, 'CHANNEL', 'MESSAGE', 'BOT')
        channels.each do |channel_name, channel|
          channel.messages.each_key do |message_name|
            puts format(CHAT_ENTRY_FORMAT,
                        channel_name, message_name, channel.connector.name)
          end
        end
      end
    end
  end
end
