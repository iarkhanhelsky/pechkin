module Pechkin
  # Processes feeded data chunks and sends them via connectors to needed IM
  # services. Can skip some requests acording to filters.
  class Handler
    attr_reader :channels, :message_matcher
    attr_accessor :logger

    def initialize(channels, stdout = $stdout, stderr = $stderr)
      @channels = channels
      # Create empty logger by default
      @logger = Logger.new(IO::NULL)
      @stdout = stdout
      @stderr = stderr
      @message_matcher = MessageMatcher.new(@logger)
    end

    # Handles message request. Each request has three parameters: channel id,
    # message id, and data object. By channel id we determine where to send
    # data, by message id we determine how to transform this data to real
    # message.
    #
    # @param channel_id [String] channel name from configuration. This name is
    #  obtained from directory structure we have in configuration directory.
    # @param msg_id [String] message name from configuration. This name is
    #  references yml file with message description
    # @param data [Object] data object to render via template. This is usualy
    #  deserialized json.
    # @see Configuration
    def handle(channel_id, msg_id, data)
      channel_config, message_config, text =
        prepare_message(channel_id, msg_id, data)
      chats = channel_config.chat_ids
      connector = channel_config.connector

      if message_allowed?(message_config, data)
        if chats.empty? || chats[0] == nil
          connector.send_message(data["email"], text, message_config)
        else
          chats.map { |chat| connector.send_message(chat, text, message_config) }
        end
      else
        logger.warn "#{channel_id}/#{msg_id}: " \
                    "Skip sending message. Because it's not allowed"
        []
      end
    end

    # Executes message handling and renders template using connector logic
    #
    # @param channel_id [String] channel name from configuration. This name is
    #  obtained from directory structure we have in configuration directory.
    # @param msg_id [String] message name from configuration. This name is
    #  references yml file with message description
    # @param data [Object] data object to render via template. This is usualy
    #  deserialized json.
    # @see Configuration
    def preview(channel_id, msg_id, data)
      channel_config, message_config, text =
        prepare_message(channel_id, msg_id, data)
      chats = channel_config.chat_ids
      connector = channel_config.connector

      if message_allowed?(message_config, data)
        connector.preview(chats, text, message_config)
      else
        puts "No message sent beacuse it's not allowed"
      end
    end

    def message?(channel_id, msg_id)
      channels.key?(channel_id) && channels[channel_id].messages.key?(msg_id)
    end

    private

    def puts(msg)
      @stdout.puts(msg)
    end

    # Find channel by it's id or trow ChannelNotFoundError
    def fetch_channel(channel_id)
      raise ChannelNotFoundError, channel_id unless channels.key?(channel_id)

      channels[channel_id]
    end

    # Find message config by it's id or throw MessageNotFoundError
    def fetch_message(channel_config, msg_id)
      message_list = channel_config.messages
      raise MessageNotFoundError, msg_id unless message_list.key?(msg_id)

      message_list[msg_id]
    end

    def message_allowed?(message_config, data)
      message_matcher.matches?(message_config, data)
    end

    def prepare_message(channel_id, msg_id, data)
      channel_config = fetch_channel(channel_id)
      # Find message and try substitute values to message parameters.
      message = fetch_message(channel_config, msg_id)
      message_config, text = message.prepare(data)

      [channel_config, message_config, text]
    end

    def substitute(data, message_desc)
      substitute_recursive(Substitute.new(data), message_desc)
    end

    def substitute_recursive(substitutions, object)
      case object
      when String
        substitutions.process(object)
      when Array
        object.map { |o| substitute_recursive(substitutions, o) }
      when Hash
        r = {}
        object.each { |k, v| r[k] = substitute_recursive(substitutions, v) }
        r
      else
        object
      end
    end
  end
end
