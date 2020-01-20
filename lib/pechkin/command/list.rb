module Pechkin
  module Command
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
        bots.each do |name, bot|
          puts "  #{name}(#{bot.connector}): #{bot.token}"
        end
      end

      def print_channels(channels)
        puts "\nChannels:"
        channels.each do |channel_name, channel|
          puts "  - name #{channel_name}"
          puts "    bot: #{channel.connector.name}"
          puts '    messages: '
          channel.messages.each do |message_name, _message|
            puts "     - /#{channel_name}/#{message_name}"
          end
          puts
        end
      end
    end
  end
end
